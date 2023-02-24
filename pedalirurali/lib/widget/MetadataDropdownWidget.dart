import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pedalirurali/model/Metadata.dart';
import 'package:pedalirurali/provider/MetadataProvider.dart';

class MetadataDropdownWidget2 extends StatefulWidget {
  final ValueChanged<Metadata> onChanged;
  final String label;
  final Metadata selected;
  final MetadataTypes mdType;

  MetadataDropdownWidget2(
      {Key key,
      @required this.mdType,
      @required this.onChanged,
      @required this.label,
      this.selected})
      : super(key: key);

  @override
  _MetadataDropdownWidget2State createState() =>
      _MetadataDropdownWidget2State();
}

class _MetadataDropdownWidget2State extends State<MetadataDropdownWidget2> {
  Metadata _value;
  List<Metadata> _values;

  void _onChange() {
    print("MetadataDropdownWidget2 OnChange: " + _value.toString());
    widget.onChanged(_value);
  }

  @override
  void initState() {
    super.initState();
    _value = widget.selected != null ? widget.selected : Metadata.def();
    _values = [_value];
    load();
  }

  @override
  Widget build(BuildContext context) {
    return getBody(context);
  }

  Widget getBody(BuildContext context) {
    Widget drw = DropdownButton<Metadata>(
        value: _value,
        elevation: 16,
        // style: TextStyle(color: COLOR_DARK),
        onChanged: (Metadata newValue) {
          setState(() {
            _value = newValue;
          });
          _onChange();
        },
        items: _values.map<DropdownMenuItem<Metadata>>((Metadata value) {
          return DropdownMenuItem<Metadata>(
            value: value,
            child: Text(value.name),
          );
        }).toList());

    return ListTile(title: Text(widget.label), trailing: drw);
  }

  Future<void> load() async {
    List<Metadata> values =
        await MetadataProvider().getMetadataList(widget.mdType);
    if (values.length > 0) {
      setState(() {
        _values.clear();
        _values.addAll(values);
        _value = _values.singleWhere((i) => _value.id == i.id,
            orElse: () => _values.elementAt(0));
      });
    }
  }
}
