import 'package:flutter/material.dart';

class StatusToggle extends StatefulWidget {
  final Function(String) onStatusChanged;

  StatusToggle({required this.onStatusChanged});

  @override
  _StatusToggleState createState() => _StatusToggleState();
}

class _StatusToggleState extends State<StatusToggle> {
  String _currentStatus = "Available";

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: _currentStatus,
      items: ["Available", "Busy", "Unavailable"].map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      onChanged: (newStatus) {
        setState(() {
          _currentStatus = newStatus!;
          widget.onStatusChanged(_currentStatus);
        });
      },
    );
  }
}
