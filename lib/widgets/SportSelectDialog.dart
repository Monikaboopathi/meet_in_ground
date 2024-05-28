import 'package:flutter/material.dart';

class SportSelectDialog extends StatelessWidget {
  final List<String> sportNames;
  final String? selectedSport;
  final Function(String) onSportSelected;

  const SportSelectDialog({
    Key? key,
    required this.sportNames,
    required this.onSportSelected,
    this.selectedSport,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Select a Sport'),
      content: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            for (String sportName in sportNames)
              ListTile(
                title: Text(
                  sportName,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.normal,
                    color: sportName == selectedSport
                        ? Colors.blue // Highlight selected sport
                        : Colors.black,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  onSportSelected(sportName);
                },
              ),
          ],
        ),
      ),
    );
  }
}
