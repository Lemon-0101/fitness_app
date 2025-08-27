import 'package:flutter/material.dart';

class TextListItem extends StatefulWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final ValueChanged<String> onChanged;
  final String initialValue;

  const TextListItem({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onChanged,
    this.initialValue = '',
  });

  @override
  _TextListItemState createState() => _TextListItemState();
}

class _TextListItemState extends State<TextListItem> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
    _controller.addListener(() {
      widget.onChanged(_controller.text);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: Icon(widget.icon),
            title: Text(widget.title),
            subtitle: Text(widget.subtitle),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: TextFormField(
              controller: _controller,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter text...',
              ),
            ),
          ),
          // You can add a save button or remove this part
          const SizedBox(height: 16.0),
        ],
      ),
    );
  }
}