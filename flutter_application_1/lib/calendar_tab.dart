import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'preferences_manager.dart'; // SharedPreferences 관리 클래스 임포트

class CalendarTab extends StatefulWidget {
  @override
  _CalendarTabState createState() => _CalendarTabState();
}

class _CalendarTabState extends State<CalendarTab> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  TextEditingController _memoController = TextEditingController();
  bool _isLiked = false; // 좋아요 상태 초기화

  @override
  void initState() {
    super.initState();
    _loadLikedStatus();
  }

  void _loadLikedStatus() async {
    // 선택된 날짜가 있으면 해당 날짜의 좋아요 상태를 로드
    if (_selectedDay != null) {
      String keyDate = DateFormat('yyyyMMdd').format(_selectedDay!);
      bool? likedStatus = await PreferencesManager.loadLikedStatus(keyDate);
      setState(() {
        _isLiked = likedStatus ?? false;
      });
    }
  }

  void _toggleLiked() async {
    if (_selectedDay != null) {
      String keyDate = DateFormat('yyyyMMdd').format(_selectedDay!);
      _isLiked = !_isLiked; // 좋아요 상태 토글
      await PreferencesManager.saveLikedStatus(keyDate, _isLiked);
      setState(() {}); // UI 갱신
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2010, 10, 16),
            lastDay: DateTime.utc(2030, 3, 14),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
              _loadLikedStatus(); // 날짜 선택 시 좋아요 상태 로드
            },
          ),
          if (_selectedDay != null) // 선택된 날짜가 있을 경우에만 표시
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    DateFormat('yyyy년 M월 d일').format(_selectedDay!),
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  icon: Icon(_isLiked ? Icons.favorite : Icons.favorite_border),
                  color: Colors.red,
                  onPressed: _toggleLiked, // 좋아요 상태 토글 버튼
                ),
                TextField(
                  controller: _memoController,
                  decoration: InputDecoration(
                      labelText: '메모장', border: OutlineInputBorder()),
                  maxLines: 5,
                ),
              ],
            ),
        ],
      ),
    );
  }
}
