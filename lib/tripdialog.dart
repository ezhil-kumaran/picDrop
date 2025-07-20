import 'package:flutter/material.dart';

class Myinputalertbox extends StatelessWidget {
  final TextEditingController biocontroller;
  final String hintText;
  final Function()? onSubmit;
  final String submittext;

  const Myinputalertbox({
    super.key,
    required this.biocontroller,
    required this.hintText,
    required this.onSubmit,
    required this.submittext,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      content: TextField(
        controller: biocontroller,
        decoration: InputDecoration(
          hintText: hintText,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(),
          ),
        ),
        maxLength: 300,
        maxLines: 4,
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            biocontroller.clear();
          },
          child: Text(
            "Cancel",
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontSize: 20,
            ),
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            onSubmit!();
            biocontroller.clear();
          },
          child: Text(submittext, style: TextStyle(fontSize: 20)),
        ),
      ],
    );
  }
}
