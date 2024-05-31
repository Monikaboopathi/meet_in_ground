// ignore_for_file: unused_element, deprecated_member_use

import 'package:flutter/material.dart';

import 'package:meet_in_ground/constant/themes_service.dart';

class DeleteDialog extends StatefulWidget {
  final Future<void> Function() onDelete;

  const DeleteDialog({
    Key? key,
    required this.onDelete,
  }) : super(key: key);
  @override
  _DeleteDialogState createState() => _DeleteDialogState();
}

class _DeleteDialogState extends State<DeleteDialog> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.all(15),
          child: AlertDialog(
            insetPadding: EdgeInsets.all(2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
            content: Container(
              width: MediaQuery.of(context).size.width,
              child: SingleChildScrollView(
                physics: ClampingScrollPhysics(),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Align(
                            alignment: Alignment.topLeft,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  "MEET IN GROUND",
                                  style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 15,
                                      color: ThemeService.textColor),
                                ),
                              ],
                            )),
                        Align(
                          alignment: Alignment.topRight,
                          child: GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: Icon(
                              Icons.close,
                              size: 25,
                              color: ThemeService.textColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    Text(
                      "Do you want delete this Post?",
                      style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 15,
                          color: ThemeService.textColor),
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Container(
                      width: double.infinity,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              backgroundColor: Colors.grey.shade400,
                              padding: EdgeInsets.symmetric(vertical: 10),
                            ),
                            child: Container(
                              alignment: Alignment.center,
                              child: Text(
                                "No",
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () async {
                              await widget.onDelete();
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              backgroundColor: Colors.red.shade400,
                              padding: EdgeInsets.symmetric(vertical: 10),
                            ),
                            child: Container(
                              alignment: Alignment.center,
                              child: Text(
                                "Yes",
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

void showDeleteDialog(BuildContext context, final onDelete) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (context) => DeleteDialog(
      onDelete: onDelete,
    ),
  );
}
