import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:scribbleio_clone/constants.dart';
import 'package:scribbleio_clone/models/my_custom_painter.dart';
import 'package:scribbleio_clone/models/touch_points.dart';
import 'package:scribbleio_clone/screens/home_screen.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

class PaintScreen extends StatefulWidget {
  const PaintScreen({super.key, required this.data, required this.screenFrom});
  final Map<String, String> data;
  final String screenFrom;

  @override
  State<PaintScreen> createState() => _PaintScreenState();
}

class _PaintScreenState extends State<PaintScreen> {
  late io.Socket _socket;
  Map dataOfRoom = {};
  Color selectedColor = Colors.black;
  List<TouchPoints> points = [];
  StrokeCap strokeType = StrokeCap.round;
  double opacity = 1;
  double strokeWidth = 2;
  late Timer _timer;
  int _start = 60;

  @override
  void initState() {
    super.initState();
    connect();
  }

  void startTimer() {
    const oneSec = Duration(seconds: 1);
    _timer = Timer.periodic(oneSec, (timer) {
      if (_start == 0) {
        _socket.emit('change-turn', dataOfRoom['name']);
        setState(() {
          _timer.cancel();
        });
      } else {
        setState(() {
          _start--;
        });
      }
    });
  }

  void connect() {
    _socket = io.io(host, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });
    _socket.connect();

    if (widget.screenFrom == 'createRoom') {
      _socket.emit('create-game', widget.data);
    } else {
      _socket.emit('join-game', widget.data);
    }

    // listen to socket
    _socket.onConnect((data) {
      // print('data');
      _socket.on('updateRoom', (roomData) {
        dataOfRoom = roomData;
      });

      _socket.on(
        'notCorrectGame',
        (data) => Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
          (route) => false,
        ),
      );

      _socket.on('points', (point) {
        if (point['details'] != null) {
          points.add(
            TouchPoints(
              paint: Paint()
                ..strokeCap = strokeType
                ..isAntiAlias = true
                ..color = selectedColor.withOpacity(opacity)
                ..strokeWidth = strokeWidth,
              points: Offset(
                (point['details']['dx']).toDouble(),
                (point['details']['dy']).toDouble(),
              ),
            ),
          );
          if (mounted) setState(() {});
        }
      });

      _socket.on('color-change', (colorString) {
        int value = int.parse(colorString, radix: 16);
        Color otherColor = Color(value);
        selectedColor = otherColor;
        setState(() {});
      });

      _socket.on('stroke-width', (value) {
        strokeWidth = value.toDouble();
        setState(() {});
      });

      _socket.on('clear-screen', (_) {
        points.clear();
        setState(() {});
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    void selectColor() {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
            title: const Text("Choose Color"),
            content: SingleChildScrollView(
              child: BlockPicker(
                pickerColor: selectedColor,
                onColorChanged: (color) {
                  String colorString = color.toString();
                  String valueString =
                      colorString.split('(0x')[1].split(')')[0];
                  Map map = {
                    'color': valueString,
                    'roomName': dataOfRoom['name']
                  };
                  _socket.emit('color-change', map);
                },
              ),
            ),
            actions: [
              TextButton(
                  onPressed: Navigator.of(context).pop,
                  child: const Text('Close'))
            ]),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(
                width: width,
                height: height * 0.55,
                child: GestureDetector(
                    onPanUpdate: (details) {
                      _socket.emit('paint', {
                        'details': {
                          'dx': details.localPosition.dx,
                          'dy': details.localPosition.dy,
                        },
                        'roomName': widget.data['name'],
                      });
                    },
                    onPanStart: (details) {
                      _socket.emit('paint', {
                        'details': {
                          'dx': details.localPosition.dx,
                          'dy': details.localPosition.dy,
                        },
                        'roomName': widget.data['name'],
                      });
                    },
                    onPanEnd: (details) {
                      _socket.emit('paint', {
                        'details': null,
                        'roomName': widget.data['name'],
                      });
                    },
                    child: SizedBox.expand(
                      child: ClipRRect(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(20)),
                        child: RepaintBoundary(
                          child: CustomPaint(
                            size: Size.infinite,
                            painter: MyCustomPainter(pointsList: points),
                          ),
                        ),
                      ),
                    )),
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: selectColor,
                    icon: Icon(
                      Icons.color_lens,
                      color: selectedColor,
                    ),
                  ),
                  Expanded(
                    child: Slider(
                      value: strokeWidth,
                      activeColor: selectedColor,
                      min: 1,
                      max: 10,
                      label: "Strokewidth $strokeWidth",
                      onChanged: (value) {
                        Map map = {
                          'value': value,
                          'roomName': dataOfRoom['name']
                        };
                        _socket.emit('stroke-width', map);
                      },
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      _socket.emit('clear-screen', dataOfRoom['name']);
                    },
                    icon: Icon(
                      Icons.clear_all,
                      color: selectedColor,
                    ),
                  )
                ],
              )
            ],
          )
        ],
      ),
    );
  }
}
