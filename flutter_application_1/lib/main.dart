import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;
  late YoutubePlayerController _controller;
  bool _isLiked = false;
  TextEditingController _memoController = TextEditingController();
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<String, bool> likedDays = {};
  Map<String, String> memoDays = {};

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController(
      initialVideoId: 'LyCelsH_9L0',
      flags: YoutubePlayerFlags(autoPlay: false),
    );
    _loadPreferences(); // 초기 설정에서 전체 데이터 로드
  }

  void _loadPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      likedDays = Map<String, bool>.fromIterable(
          prefs.getKeys().where((key) => key.endsWith('_liked')),
          key: (item) => item as String,
          value: (item) => prefs.getBool(item) ?? false);
      memoDays = Map<String, String>.fromIterable(
          prefs.getKeys().where((key) => key.endsWith('_memo')),
          key: (item) => item as String,
          value: (item) => prefs.getString(item) ?? '');
    });
  }

  void _savePreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String formattedDate =
        DateFormat('yyyyMMdd').format(_selectedDay ?? DateTime.now());
    await prefs.setBool(formattedDate + '_liked', _isLiked);
    await prefs.setString(formattedDate + '_memo', _memoController.text);
  }

  void _updateDataForSelectedDay(DateTime selectedDay) {
    String keyDate = DateFormat('yyyyMMdd').format(selectedDay);
    setState(() {
      _isLiked = likedDays[keyDate + '_liked'] ?? false;
      _memoController.text = memoDays[keyDate + '_memo'] ?? '';
    });
  }

  void _saveTodayPreferences(String keyDate, bool isLiked, String memo) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(keyDate + '_liked', isLiked);
    await prefs.setString(keyDate + '_memo', memo);
  }

  Widget buildCalendarTab() {
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
                _focusedDay = focusedDay; // Update `_focusedDay` here as well
              });
              _updateDataForSelectedDay(selectedDay);
            },
          ),
          if (_selectedDay != null) // 선택된 날짜가 있을 경우에만 표시
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                DateFormat('yyyy년 M월 d일').format(_selectedDay!),
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
          IconButton(
            icon: Icon(_isLiked ? Icons.favorite : Icons.favorite_border,
                size: 48),
            color: Colors.red,
            onPressed: () {
              setState(() {
                _isLiked = !_isLiked;
              });
              _savePreferences();
            },
          ),
          TextField(
            controller: _memoController,
            decoration:
                InputDecoration(labelText: '메모', border: OutlineInputBorder()),
            maxLines: 5,
            onChanged: (text) {
              _savePreferences();
            },
          ),
        ],
      ),
    );
  }

  Widget buildTodayTab() {
    DateTime today = DateTime.now();
    String todayKey = DateFormat('yyyyMMdd').format(today);

    // '오늘' 탭을 위한 상태 업데이트
    bool todayIsLiked = likedDays[todayKey + '_liked'] ?? false;
    String todayMemo = memoDays[todayKey + '_memo'] ?? '';

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
          icon: Icon(todayIsLiked ? Icons.favorite : Icons.favorite_border,
              size: 48),
          color: Colors.red,
          onPressed: () {
            setState(() {
              likedDays[todayKey + '_liked'] = !todayIsLiked;
              _saveTodayPreferences(todayKey, !todayIsLiked, todayMemo);
            });
          },
        ),
        TextField(
          controller: TextEditingController(text: todayMemo),
          decoration:
              InputDecoration(labelText: '메모', border: OutlineInputBorder()),
          maxLines: 5,
          onChanged: (text) {
            _saveTodayPreferences(todayKey, todayIsLiked, text);
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    DateTime today = DateTime.now();
    String todayKey = DateFormat('yyyyMMdd').format(today);

    return Scaffold(
      appBar: AppBar(title: Text('플러터 앱')),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          buildCalendarTab(), // '달력' 탭 UI를 메서드 호출로 대체
          buildTodayTab(), // '오늘' 탭 UI 구성 메서드를 호출 (정의 필요)
          // 다른 탭의 위젯 구성
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today), label: '달력'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: '오늘'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: '내 정보'),
        ],
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _memoController.dispose();
    super.dispose();
  }
}
