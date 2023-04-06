import 'package:flutter/material.dart';
import 'package:scribbleio_clone/screens/paint_screen.dart';
import 'package:scribbleio_clone/widgets/custom_button.dart';
import 'package:scribbleio_clone/widgets/custom_text_field.dart';

class CreateRoomScreen extends StatefulWidget {
  const CreateRoomScreen({super.key});

  @override
  State<CreateRoomScreen> createState() => _CreateRoomScreenState();
}

class _CreateRoomScreenState extends State<CreateRoomScreen> {
  final nameController = TextEditingController();
  final roomNameController = TextEditingController();
  String? maxRoundsValue;
  String? roomSizeValue;

  @override
  void dispose() {
    nameController.dispose();
    roomNameController.dispose();
    super.dispose();
  }

  void createRoom() {
    if (nameController.text.isNotEmpty &&
        roomNameController.text.isNotEmpty &&
        maxRoundsValue != null &&
        roomSizeValue != null) {
      Map<String, String> data = {
        "nickname": nameController.text,
        "name": roomNameController.text,
        "occupancy": maxRoundsValue!,
        "maxRounds": roomSizeValue!
      };
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) =>
              PaintScreen(data: data, screenFrom: 'createRoom'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "Create Room",
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
          const SizedBox(height: 20),
          DropdownButton<String>(
            value: maxRoundsValue,
            focusColor: const Color(0xffF5F6FA),
            items: <String>["2", "5", "10", "15"]
                .map<DropdownMenuItem<String>>(
                  (String value) => DropdownMenuItem(
                    value: value,
                    child: Text(
                      value,
                      style: const TextStyle(color: Colors.black),
                    ),
                  ),
                )
                .toList(),
            hint: const Text(
              'Select Max Rounds',
              style: TextStyle(
                color: Colors.black,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            onChanged: (String? value) {
              setState(() {
                maxRoundsValue = value;
              });
            },
          ),
          const SizedBox(height: 20),
          DropdownButton<String>(
            value: roomSizeValue,
            focusColor: const Color(0xffF5F6FA),
            items: <String>["2", "3", "4", "5", "6", "7", "8"]
                .map<DropdownMenuItem<String>>(
                  (String value) => DropdownMenuItem(
                    value: value,
                    child: Text(
                      value,
                      style: const TextStyle(color: Colors.black),
                    ),
                  ),
                )
                .toList(),
            hint: const Text('Select Room Size',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                )),
            onChanged: (String? value) {
              setState(() {
                roomSizeValue = value;
              });
            },
          ),
          const SizedBox(height: 40),
          CustomButton(title: 'Create', func: createRoom),
        ],
      ),
    );
  }
}
