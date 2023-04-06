import 'package:flutter/material.dart';
import 'package:scribbleio_clone/screens/create_room_screen.dart';
import 'package:scribbleio_clone/screens/join_room_screen.dart';
import 'package:scribbleio_clone/widgets/custom_button.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void navigateToCreateRoomScreen(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const CreateRoomScreen(),
      ),
    );
  }

  void navigateToJoinRoomScreen(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const JoinRoomScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            'Create/Join room to play!',
            style: TextStyle(
              color: Colors.black,
              fontSize: 24,
            ),
          ),
          SizedBox(height: height * 0.1),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              CustomButton(
                title: 'Create',
                func: () => navigateToCreateRoomScreen(context),
              ),
              CustomButton(
                title: 'Join',
                func: () => navigateToJoinRoomScreen(context),
              )
            ],
          )
        ],
      ),
    );
  }
}
