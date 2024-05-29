import 'package:flutter/material.dart';
import 'package:meet_in_ground/constant/themes_service.dart';

class Messages extends StatelessWidget {
  const Messages({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeService.background,
      appBar: AppBar(
        backgroundColor: ThemeService.background,
        title: Text(
          'Requested Posts',
          style: TextStyle(
            color: ThemeService.textColor,
            fontFamily: 'Billabong',
            fontSize: 25,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView.builder(
        itemCount: 5,
        itemBuilder: (context, index) {
          return ListTile(
            onTap: () {},
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('User $index'),
                Text(
                  "7-8-2024",
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 3),
              child: Text(
                'Last message $index',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.grey),
              ),
            ),
            leading: CircleAvatar(
              backgroundColor: Colors.grey[300],
              child: Icon(Icons.person),
            ),
          );
        },
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     // Action on pressing the FAB
      //   },
      //   child: const Icon(Icons.chat),
      // ),
    );
  }
}
