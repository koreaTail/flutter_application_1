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
  bool _isMemoEnabled = false;
  bool _isTodayMemoEnabled = false;
  TextEditingController _memoController = TextEditingController();
  TextEditingController _todayMemoController = TextEditingController();
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<bool>> _likedDays = {};
  Map<DateTime, String?> _memoDays = {}; // 메모가 있는 날을 저장하는 맵

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
    _loadAllMemoDays(); // 메모가 있는 날을 로드
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
      _memoDays[DateTime.parse(date)] = memo; // 메모 정보를 저장
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

  void _loadAllMemoDays() async {
    var allMemos = await _dbHelper.getAllMemos();
    setState(() {
      _memoDays =
          allMemos.map((date, memo) => MapEntry(DateTime.parse(date), memo));
    });
  }

  void _updateMemo(String date, String memo) async {
    await _dbHelper.updateDayDetails(date, _isLiked, memo);
    _loadData(date);
  }

  void _updateTodayMemo(String date, String memo) async {
    await _dbHelper.updateDayDetails(date, _todayIsLiked, memo);
    _loadTodayData();
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

    return GestureDetector(
      onTap: () {
        FocusScope.of(this.context).unfocus(); // 메모 외의 다른 부분을 누를 때 키보드를 비활성화
      },
      child: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
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
                icon: Icon(
                    _todayIsLiked ? Icons.favorite : Icons.favorite_border,
                    size: 48),
                color: Colors.red,
                onPressed: () {
                  bool newLiked = !_todayIsLiked;
                  _updateData(todayKey, newLiked, _todayMemoController.text);
                },
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _isTodayMemoEnabled = !_isTodayMemoEnabled;
                  });
                },
                child: Text(_isTodayMemoEnabled ? '메모 숨기기' : '메모하기'),
              ),
              if (_isTodayMemoEnabled)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: _todayMemoController,
                    decoration: InputDecoration(
                        labelText: '메모', border: OutlineInputBorder()),
                    maxLines: 5,
                    onChanged: (value) {
                      _updateTodayMemo(todayKey, value);
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildCalendarTab() {
    return GestureDetector(
      onTap: () {
        FocusScope.of(this.context).unfocus(); // 메모 외의 다른 부분을 누를 때 키보드를 비활성화
      },
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
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
                markerBuilder: (BuildContext context, date, events) {
                  bool isLiked =
                      _likedDays[_normalizeDateTime(date)]?.first ?? false;
                  bool hasMemo =
                      _memoDays[_normalizeDateTime(date)]?.isNotEmpty ?? false;
                  if (isLiked || hasMemo) {
                    return Positioned(
                      bottom: 4,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (isLiked)
                            Container(
                              height: 7.0,
                              width: 7.0,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.red,
                              ),
                            ),
                          if (isLiked && hasMemo)
                            SizedBox(width: 4.0), // 두 점 사이의 간격
                          if (hasMemo)
                            Container(
                              height: 7.0,
                              width: 7.0,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.blue,
                              ),
                            ),
                        ],
                      ),
                    );
                  }
                  return null;
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
            if (_memoController.text.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  _memoController.text,
                  style: TextStyle(fontSize: 15),
                ),
              ),
            IconButton(
              icon: Icon(_isLiked ? Icons.favorite : Icons.favorite_border,
                  size: 48),
              color: Colors.red,
              onPressed: () {
                _isLiked = !_isLiked;
                _updateData(_formatDate(_selectedDay ?? DateTime.now()),
                    _isLiked, _memoController.text);
              },
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _isMemoEnabled = !_isMemoEnabled;
                });
              },
              child: Text(_isMemoEnabled ? '메모 숨기기' : '메모하기'),
            ),
            if (_isMemoEnabled)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: _memoController,
                  decoration: InputDecoration(
                      labelText: '메모', border: OutlineInputBorder()),
                  maxLines: 5,
                  onChanged: (value) {
                    _updateMemo(
                        _formatDate(_selectedDay ?? DateTime.now()), value);
                  },
                ),
              ),
          ],
        ),
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
    return (year % 4 == 0) && (year % 100 != 0) || (year % 400 == 0);
  }

  Widget buildProfileTab() {
    DateTime now = DateTime.now();
    int totalDaysThisYear =
        365 + (isLeapYear(now.year) ? 1 : 0); // 윤년 포함 총 일수 계산
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

  Future<Map<String, bool>> getAllLikes() async {
    Database db = await instance.database;
    var res = await db.query(table, columns: [columnDate, columnLiked]);
    Map<String, bool> likes = {};
    for (var row in res) {
      likes[row[columnDate] as String] = row[columnLiked] == 1;
    }
    return likes;
  }

  Future<Map<String, String?>> getAllMemos() async {
    Database db = await instance.database;
    var res = await db.query(table, columns: [columnDate, columnMemo]);
    Map<String, String?> memos = {};
    for (var row in res) {
      memos[row[columnDate] as String] = row[columnMemo] as String?;
    }
    return memos;
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
      await db.insert(table,
          {columnDate: date, columnLiked: liked ? 1 : 0, columnMemo: memo});
    }
  }
}
