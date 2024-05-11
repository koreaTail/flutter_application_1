// common_widgets.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateLikeMemoWidget extends StatelessWidget {
  final DateTime date;
  final bool isLiked;
  final VoidCallback onLikedToggle;
  final TextEditingController memoController;

  const DateLikeMemoWidget({
    Key? key,
    required this.date,
    required this.isLiked,
    required this.onLikedToggle,
    required this.memoController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            DateFormat('yyyy년 M월 d일').format(date),
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
        IconButton(
          icon: Icon(isLiked ? Icons.favorite : Icons.favorite_border),
          color: Colors.red,
          onPressed: onLikedToggle,
        ),
        TextField(
          controller: memoController,
          decoration:
              InputDecoration(labelText: '메모', border: OutlineInputBorder()),
          maxLines: 5,
        ),
      ],
    );
  }
}
