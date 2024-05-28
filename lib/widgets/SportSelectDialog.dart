import 'package:flutter/material.dart';
import 'package:meet_in_ground/constant/themes_service.dart';

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
    return Dialog(
      backgroundColor: ThemeService.background,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Select a Sport',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: ThemeService.textColor),
            ),
            SizedBox(height: 16.0),
            SingleChildScrollView(
              child: Wrap(
                spacing: 8.0,
                runSpacing: 4.0,
                children: <Widget>[
                  for (String sport in sportNames)
                    ChoiceChip(
                      label: Text(
                        sport,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                      selectedColor: ThemeService.buttonBg,
                      backgroundColor: ThemeService.placeHolder,
                      selected: selectedSport == sport,
                      onSelected: (selected) {
                        if (selected) {
                          Navigator.pop(context);
                          onSportSelected(sport);
                        }
                      },
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
