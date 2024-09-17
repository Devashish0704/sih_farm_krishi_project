import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'UnitsList.dart';

class UnitsDropdownField extends StatefulWidget {
  final Function(String) callback;
  final String label;
  final String? defaultValue;

  UnitsDropdownField({
    required this.callback,
    required this.label,
    this.defaultValue,
  });

  @override
  _UnitsDropdownFieldState createState() => _UnitsDropdownFieldState();
}

class _UnitsDropdownFieldState extends State<UnitsDropdownField> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.defaultValue != null) {
      _controller.text = widget.defaultValue!;
    }
  }

  void _setControllerValue(String value) {
    setState(() {
      _controller.text = value;
    });
    widget.callback(value);
  }

  void _showUnitListDropdown(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => UnitList(_setControllerValue),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.green[800]!,
          width: 0.5,
        ),
        borderRadius: BorderRadius.circular(20.0),
        color: Colors.white,
      ),
      margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
      child: Row(
        children: <Widget>[
          Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
            child: Icon(
              FontAwesomeIcons.weightHanging,
              color: Colors.green[800],
            ),
          ),
          Container(
            height: 30.0,
            width: 0.5,
            color: Colors.green[800],
            margin: const EdgeInsets.only(left: 0.0, right: 10.0),
          ),
          Expanded(
            child: TextField(
              controller: _controller,
              readOnly: true,
              onTap: () {
                FocusScope.of(context).unfocus();
                _showUnitListDropdown(context);
              },
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: widget.label,
                hintStyle: TextStyle(color: Colors.grey, fontFamily: 'Varela'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
