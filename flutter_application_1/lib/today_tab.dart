import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TodayTab extends StatefulWidget {
  @override
  _TodayTabState createState() => _TodayTabState();
}

class _TodayTabState extends State<TodayTab> {
  DateTime today = DateTime.now();
  String todayKey = DateFormat('yyyyMMdd').format(DateTime.now());
  bool isLiked = false; // Sample state for liked status
  TextEditingController _memoController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            DateFormat('yyyy년 M월 d일').format(today),
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
        IconButton(
          icon:
              Icon(isLiked ? Icons.favorite : Icons.favorite_border, size: 48),
          color: Colors.red,
          onPressed: () {
            setState(() {
              isLiked = !isLiked;
              // Save preferences here
            });
          },
        ),
        TextField(
          controller: _memoController,
          decoration:
              InputDecoration(labelText: '메모', border: OutlineInputBorder()),
          maxLines: 5,
        ),
      ],
    );
  }
}
