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

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController(
      initialVideoId: 'LyCelsH_9L0',
      flags: YoutubePlayerFlags(autoPlay: false),
    );
    _loadPreferences();
  }

  void _loadPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _isLiked =
          prefs.getBool(DateFormat('yyyyMMdd').format(DateTime.now())) ?? false;
      _memoController.text = prefs.getString(
              DateFormat('yyyyMMdd').format(DateTime.now()) + '_memo') ??
          '';
    });
  }

  void _savePreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(
        DateFormat('yyyyMMdd').format(DateTime.now()), _isLiked);
    await prefs.setString(
        DateFormat('yyyyMMdd').format(DateTime.now()) + '_memo',
        _memoController.text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('플러터 앱')),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2010, 10, 16),
            lastDay: DateTime.utc(2030, 3, 14),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {},
          ),
          Column(
            children: [
              Text(
                DateFormat('yyyy년 M월 d일').format(DateTime.now()),
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              YoutubePlayer(controller: _controller),
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
                decoration: InputDecoration(
                    labelText: '메모', border: OutlineInputBorder()),
                maxLines: 5,
                onChanged: (text) {
                  _savePreferences();
                },
              ),
            ],
          ),
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
