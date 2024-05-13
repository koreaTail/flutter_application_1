import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '365공동체 성경읽기',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: "Pretendard",
      ),
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
  bool _isLiked = false;
  bool _todayIsLiked = false;
  TextEditingController _memoController = TextEditingController();
  TextEditingController _todayMemoController = TextEditingController();
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<bool>> _likedDays = {};
  DateTime _normalizeDateTime(DateTime dateTime) {
    return DateTime(dateTime.year, dateTime.month, dateTime.day);
  }

  late DatabaseHelper _dbHelper;

  @override
  void initState() {
    super.initState();
    _dbHelper = DatabaseHelper.instance;
    _loadData(_formatDate(DateTime.now()));
    _loadTodayData();
    _loadAllLikedDays();
    print("Initial liked days: $_likedDays");
  }

  void _loadData(String date) async {
    bool? isLiked = await _dbHelper.getLikedStatus(date);
    String? memo = await _dbHelper.getMemo(date);
    setState(() {
      _isLiked = isLiked ?? false;
      _memoController.text = memo ?? '';
      if (isLiked != null) {
        _likedDays[DateTime.parse(date)] = [isLiked];
      }
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

  void _loadAllLikedDays() async {
    var allLikes = await _dbHelper.getAllLikes();
    setState(() {
      _likedDays = allLikes
          .map((date, liked) => MapEntry(DateTime.parse(date), [liked]));
    });
  }

  void _updateData(String date, bool liked, String memo) async {
    await _dbHelper.updateDayDetails(date, liked, memo);
    _loadData(date);
    if (date == _formatDate(DateTime.now())) {
      _loadTodayData();
    }
  }

  void _onTabTapped(int index) {
    setState(() {
      _selectedIndex = index;
      if (index == 0) {
        DateTime today = DateTime.now();
        _focusedDay = today;
        _selectedDay = today;
        _loadData(_formatDate(today));
      }
    });
  }

  Widget buildTodayTab() {
    DateTime today = DateTime.now();
    String todayKey = _formatDate(today);

    return Column(
      children: [
        InkWell(
          onTap: () async {
            const url = 'https://www.youtube.com/@PRS/videos';
            if (await canLaunch(url)) {
              await launch(url);
            } else {
              throw 'Could not launch $url';
            }
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              "Watch PRS Videos on YouTube",
              style: TextStyle(
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                  fontSize: 16),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            DateFormat('yyyy년 M월 d일').format(today),
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
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
                _loadData(_formatDate(selectedDay));
              });
            },
            calendarBuilders: CalendarBuilders(
              markerBuilder: (context, date, events) {
                bool isLiked =
                    _likedDays[_normalizeDateTime(date)]?.first ?? false;
                if (isLiked) {
                  return Positioned(
                    right: 26, // 오른쪽 정렬을 유지하면서
                    bottom: 9, // 날짜의 바닥에서 5 단위 높이에 빨간 점을 위치
                    child: Container(
                      height: 7.0, // 원의 크기를 조금 줄임
                      width: 7.0,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.red,
                      ),
                    ),
                  );
                }
                return null; // 회색 점을 표시하지 않고, 시청 완료된 날짜에만 빨간 점 표시
              },
            ),
          ),
          if (_selectedDay != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                DateFormat('yyyy년 M월 d일').format(_selectedDay!),
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
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
      appBar: AppBar(title: Text('365 공동체 성경읽기')),
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
        onTap: _onTabTapped,
      ),
    );
  }

  bool isLeapYear(int year) {
    return (year % 4 == 0) && (year % 100 != 0 || year % 400 == 0);
  }

  Widget buildProfileTab() {
    DateTime now = DateTime.now();
    int totalDaysThisYear = 365 +
        (isLeapYear(now.year)
            ? 1
            : 0); // Calculate the total days including leap year
    int daysSinceYearStart = now.difference(DateTime(now.year)).inDays + 1;
    int daysWatchedThisYear = _likedDays.keys
        .where(
            (date) => date.year == now.year && _likedDays[date]?.first == true)
        .length;

    double periodCompletionRate =
        (daysWatchedThisYear / daysSinceYearStart) * 100;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text(
              "내 정보",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          // Text(
          //   "${daysWatchedThisYear}회 / ${totalDaysThisYear}일",
          //   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          // ),
          Text(
            "시청완료: ${daysWatchedThisYear}회 / ${daysSinceYearStart}일",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Text(
            "시청완료율: ${periodCompletionRate.toStringAsFixed(2)}%",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _memoController.dispose();
    _todayMemoController.dispose;
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

  Future<Map<String, bool>> getAllLikes() async {
    Database db = await instance.database;
    var res = await db.query(table, columns: [columnDate, columnLiked]);
    Map<String, bool> likes = {};
    for (var row in res) {
      likes[row[columnDate] as String] = row[columnLiked] == 1;
    }
    return likes;
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
