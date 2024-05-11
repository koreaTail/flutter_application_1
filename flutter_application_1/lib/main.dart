import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

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
  late DatabaseHelper _dbHelper;

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController(
      initialVideoId: 'LyCelsH_9L0',
      flags: YoutubePlayerFlags(autoPlay: false),
    );
    _dbHelper = DatabaseHelper.instance;
    _loadData();
  }

  void _loadData() async {
    _isLiked =
        await _dbHelper.getLikedStatus(_formatDate(_focusedDay)) ?? false;
    _memoController.text =
        await _dbHelper.getMemo(_formatDate(_focusedDay)) ?? '';
  }

  void _updateData(String date, bool liked, String memo) async {
    await _dbHelper.updateDayDetails(date, liked, memo);
    _loadData();
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
              _loadData();
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
      appBar: AppBar(title: Text('플러터 앱')),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          buildCalendarTab(),
          // Other tabs widgets here
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
