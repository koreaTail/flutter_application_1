// common_date_like_memo_widget.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CommonDateLikeMemoWidget extends StatefulWidget {
  final DateTime date;
  final bool isLiked;
  final Function toggleLiked;
  final TextEditingController memoController;

  const CommonDateLikeMemoWidget({
    Key? key,
    required this.date,
    required this.isLiked,
    required this.toggleLiked,
    required this.memoController,
  }) : super(key: key);

  @override
  _CommonDateLikeMemoWidgetState createState() =>
      _CommonDateLikeMemoWidgetState();
}

class _CommonDateLikeMemoWidgetState extends State<CommonDateLikeMemoWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            DateFormat('yyyy년 M월 d일').format(widget.date),
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
        IconButton(
          icon: Icon(widget.isLiked ? Icons.favorite : Icons.favorite_border),
          color: Colors.red,
          onPressed: () => widget.toggleLiked(),
        ),
        TextField(
          controller: widget.memoController,
          decoration:
              InputDecoration(labelText: '메모', border: OutlineInputBorder()),
          maxLines: 5,
        ),
      ],
    );
  }
}
