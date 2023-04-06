import 'package:flutter/material.dart';

class PlayerScore extends StatelessWidget {
  final List<Map> userData;
  const PlayerScore({super.key, required this.userData});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Center(
        child: SizedBox(
          height: double.maxFinite,
          child: ListView.builder(
            itemBuilder: (context, index) {
              var data = userData[index].values;
              return ListTile(
                title: Text(
                  data.elementAt(0),
                  style: const TextStyle(color: Colors.black, fontSize: 23),
                ),
                subtitle: Text(
                  data.elementAt(1),
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
