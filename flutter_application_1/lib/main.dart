import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

Future<String> fetchLatestVideoId(String playlistId, String apiKey) async {
  final String url = 'https://www.googleapis.com/youtube/v3/playlistItems'
      '?part=snippet&maxResults=1'
      '&playlistId=$playlistId'
      '&key=$apiKey';
  final response = await http.get(Uri.parse(url));

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    final videoId = data['items'][0]['snippet']['resourceId']['videoId'];
    return videoId;
  } else {
    throw Exception('Failed to load video id');
  }
}

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
  int _selectedIndex = 1;
  YoutubePlayerController? _youtubeController; // YoutubePlayerController 초기화 변경
  bool _isLiked = false;
  bool _todayIsLiked = false;
  TextEditingController _memoController = TextEditingController();
  TextEditingController _todayMemoController = TextEditingController();
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  late DatabaseHelper _dbHelper;

  @override
  void initState() {
    super.initState();
    _dbHelper = DatabaseHelper.instance;
    _loadData(_formatDate(DateTime.now()));
    _loadTodayData();
    fetchLatestVideoId('PLJSBQHYszd6jd5uVyqSGbQd5Td25Qw1j5',
            'AIzaSyAdiA4UAZcPxO_kJuiy42P1oYyPHBKkGPU')
        .then((videoId) {
      setState(() {
        _youtubeController = YoutubePlayerController(
          initialVideoId: videoId,
          flags: YoutubePlayerFlags(autoPlay: true, mute: false),
        );
      });
    }).catchError((error) {
      print('Failed to load video ID: $error');
    });
  }

  Widget buildYoutubePlayer() {
    if (_youtubeController == null) {
      return Center(child: CircularProgressIndicator());
    }
    return YoutubePlayer(
      controller: _youtubeController!,
      showVideoProgressIndicator: true,
      onReady: () {
        _youtubeController!.addListener(() {});
      },
    );
  }

  void _loadData(String date) async {
    bool? isLiked = await _dbHelper.getLikedStatus(date);
    String? memo = await _dbHelper.getMemo(date);
    setState(() {
      _isLiked = isLiked ?? false;
      _memoController.text = memo ?? '';
    });
  }

  void _loadTodayData() async {
    String todayKey = _formatDate(DateTime.now());
    bool? isLiked = await _dbHelper.getLikedStatus(todayKey);
    String? memo = await _dbHelper.getMemo(todayKey);
    setState(() {
      _todayIsLiked = isLiked ?? false;
      _todayMemoController.text = memo ?? '';
    });
  }

  void _updateData(String date, bool liked, String memo) async {
    await _dbHelper.updateDayDetails(date, liked, memo);
    _loadData(date);
    if (date == _formatDate(DateTime.now())) {
      _loadTodayData();
    }
  }

  Widget buildTodayTab() {
    DateTime today = DateTime.now();
    String todayKey = _formatDate(today);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            DateFormat('yyyy년 M월 d일').format(today),
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
        buildYoutubePlayer(),
        IconButton(
          icon: Icon(_todayIsLiked ? Icons.favorite : Icons.favorite_border,
              size: 48),
          color: Colors.red,
          onPressed: () {
            bool newLiked = !_todayIsLiked;
            _updateData(todayKey, newLiked, _todayMemoController.text);
          },
        ),
        TextField(
          controller: _todayMemoController,
          decoration:
              InputDecoration(labelText: '메모', border: OutlineInputBorder()),
          maxLines: 5,
          onChanged: (text) {
            _updateData(_formatDate(DateTime.now()), _todayIsLiked, text);
          },
        ),
      ],
    );
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
                _focusedDay = focusedDay;
              });
              _loadData(_formatDate(selectedDay));
            },
          ),
          if (_selectedDay != null)
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
              _isLiked = !_isLiked;
              _updateData(_formatDate(_selectedDay ?? DateTime.now()), _isLiked,
                  _memoController.text);
            },
          ),
          TextField(
            controller: _memoController,
            decoration:
                InputDecoration(labelText: '메모', border: OutlineInputBorder()),
            maxLines: 5,
            onChanged: (text) {
              _updateData(
                  _formatDate(_selectedDay ?? DateTime.now()), _isLiked, text);
            },
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dateTime) =>
      DateFormat('yyyyMMdd').format(dateTime);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Flutter App')),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          buildCalendarTab(),
          buildTodayTab(),
          buildProfileTab(),
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
            if (index == 0) {
              DateTime today = DateTime.now();
              _focusedDay = today;
              _selectedDay = today;
              _loadData(_formatDate(today));
            }
          });
        },
      ),
    );
  }

  Widget buildProfileTab() {
    return Center(
      child: Text('Profile Tab Content'),
    );
  }

  @override
  void dispose() {
    _youtubeController?.dispose();
    _memoController.dispose();
    _todayMemoController.dispose();
    super.dispose();
  }
}

class DatabaseHelper {
  static final _databaseName = "MyDatabase.db";
  static final _databaseVersion = 1;
  static final table = 'day_details';
  static final columnDate = 'date';
  static final columnLiked = 'liked';
  static final columnMemo = 'memo';

  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(path,
        version: _databaseVersion, onCreate: _onCreate);
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
          CREATE TABLE $table (
            $columnDate TEXT PRIMARY KEY,
            $columnLiked INTEGER NOT NULL,
            $columnMemo TEXT NOT NULL
          )
          ''');
  }

  Future<bool?> getLikedStatus(String date) async {
    Database db = await instance.database;
    var res = await db.query(table,
        columns: [columnLiked], where: '$columnDate = ?', whereArgs: [date]);
    if (res.isNotEmpty) {
      return res.first[columnLiked] == 1;
    }
    return null;
  }

  Future<String?> getMemo(String date) async {
    Database db = await instance.database;
    var res = await db.query(table,
        columns: [columnMemo], where: '$columnDate = ?', whereArgs: [date]);
    if (res.isNotEmpty) {
      return res.first[columnMemo] as String?;
    }
    return null;
  }

  Future<void> updateDayDetails(String date, bool liked, String memo) async {
    Database db = await instance.database;
    var res = await db.update(
        table, {columnLiked: liked ? 1 : 0, columnMemo: memo},
        where: '$columnDate = ?', whereArgs: [date]);
    if (res == 0) {
      // If no update occurred, insert new record
      await db.insert(table,
          {columnDate: date, columnLiked: liked ? 1 : 0, columnMemo: memo});
    }
  }
}
