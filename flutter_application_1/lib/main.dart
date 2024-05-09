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
  late DateTime _focusedDay;
  DateTime? _selectedDay;
  Map<DateTime, bool> watchedDays = {};
  SharedPreferences? prefs;

  @override
  void initState() {
    super.initState();
    DateTime now = DateTime.now();
    _focusedDay = DateTime(now.year, now.month, now.day);
    _selectedDay = _focusedDay;
    _controller = YoutubePlayerController(
      initialVideoId: 'LyCelsH_9L0',
      flags: YoutubePlayerFlags(autoPlay: false),
    );
    initPrefs();
    _loadWatchedStatus();
  }

  void initPrefs() async {
    prefs = await SharedPreferences.getInstance();
  }

  void _savePreferences() async {
    if (prefs != null) {
      DateTime now = DateTime.now();
      String formattedDate = DateFormat('yyyyMMdd').format(now);
      await prefs!.setBool(formattedDate, _isLiked);
      await prefs!.setString(formattedDate + '_memo', _memoController.text);
      watchedDays[now] = _isLiked;
      print('Saved: $formattedDate, isLiked: $_isLiked, Date: $now');
      setState(() {});
    }
  }

  void _loadWatchedStatus() async {
    if (prefs != null) {
      Set<String> keys = prefs!.getKeys();
      watchedDays.clear();
      for (String key in keys) {
        if (key.endsWith('_memo')) continue;
        DateTime date = DateFormat('yyyyMMdd').parse(key);
        bool watched = prefs!.getBool(key) ?? false;
        watchedDays[date] = watched;
        print('Loaded: $key, watched: $watched, Date: $date');
      }
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Flutter App')),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          // Add other widgets as needed
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
