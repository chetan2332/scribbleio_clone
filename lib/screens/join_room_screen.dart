import 'package:flutter/material.dart';
import 'package:scribbleio_clone/screens/paint_screen.dart';
import 'package:scribbleio_clone/widgets/custom_button.dart';
import 'package:scribbleio_clone/widgets/custom_text_field.dart';

class JoinRoomScreen extends StatefulWidget {
  const JoinRoomScreen({super.key});

  @override
  State<JoinRoomScreen> createState() => _JoinRoomScreenState();
}

class _JoinRoomScreenState extends State<JoinRoomScreen> {
  final nameController = TextEditingController();
  final roomNameController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    roomNameController.dispose();
    super.dispose();
  }

  void joinRoom() {
    if (nameController.text.isNotEmpty && roomNameController.text.isNotEmpty) {
      Map<String, String> data = {
        "nickname": nameController.text,
        "name": roomNameController.text,
      };
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => PaintScreen(data: data, screenFrom: 'joinRoom'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "Join Room",
            style: TextStyle(
              color: Colors.black,
              fontSize: 30,
            ),
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.08),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            child: CustomTextField(
              controller: nameController,
              hintText: "Enter your name",
            ),
          ),
          const SizedBox(height: 20),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            child: CustomTextField(
              controller: roomNameController,
              hintText: "Enter Room Name",
            ),
          ),
          const SizedBox(height: 40),
          CustomButton(title: 'Join', func: joinRoom),
        ],
      ),
    );
  }
}
