import 'package:flutter/material.dart'; // 플러터의 머티리얼 디자인 라이브러리를 가져옵니다.
import 'package:youtube_player_flutter/youtube_player_flutter.dart'; // YouTube 비디오 재생을 위한 패키지를 가져옵니다.
import 'package:table_calendar/table_calendar.dart'; // 달력을 표시하기 위한 패키지를 가져옵니다.

void main() {
  runApp(MyApp()); // 앱의 시작점입니다. MyApp 클래스를 실행합니다.
}

class MyApp extends StatelessWidget {
  // StatelessWidget은 변경되지 않는 위젯을 생성할 때 사용합니다.
  @override
  Widget build(BuildContext context) {
    // build 메소드는 위젯의 모양을 정의합니다.
    return MaterialApp(
      // MaterialApp은 플러터 앱의 루트 위젯으로, 여러 플러터 앱 설정을 포함합니다.
      title: 'Flutter App', // 앱의 타이틀을 설정합니다.
      theme: ThemeData(
        // 앱의 전반적인 테마를 설정합니다.
        primarySwatch: Colors.blue, // 앱의 주 색상을 파란색으로 설정합니다.
      ),
      home: MyHomePage(), // 앱이 실행될 때 처음 보여질 화면을 MyHomePage로 설정합니다.
    );
  }
}

class MyHomePage extends StatefulWidget {
  // StatefulWidget은 상태 변경이 가능한 위젯을 생성할 때 사용합니다.
  @override
  _MyHomePageState createState() =>
      _MyHomePageState(); // StatefulWidget은 상태를 가지는 클래스를 따로 생성해야 합니다.
}

class _MyHomePageState extends State<MyHomePage> {
  // MyHomePage의 상태를 관리하는 클래스입니다.
  int _selectedIndex = 0; // 선택된 탭의 인덱스를 저장하는 변수입니다.
  late YoutubePlayerController
      _controller; // YouTube 플레이어 컨트롤러를 선언합니다. late는 나중에 초기화될 것임을 나타냅니다.
  bool _isLiked = false; // '좋아요' 상태를 저장하는 변수입니다.
  TextEditingController _memoController =
      TextEditingController(); // 텍스트 입력을 관리하는 컨트롤러입니다.
  CalendarFormat _calendarFormat =
      CalendarFormat.month; // 달력의 표시 형식을 월간으로 설정합니다.
  DateTime _focusedDay = DateTime.now(); // 현재 포커스된 날짜를 저장합니다.
  DateTime? _selectedDay; // 선택된 날짜를 저장합니다. ?는 변수가 null일 수 있음을 나타냅니다.

  @override
  void initState() {
    super.initState(); // initState는 위젯 생성 시 최초 한 번 호출됩니다.
    _controller = YoutubePlayerController(
      // YouTube 플레이어 컨트롤러를 초기화합니다.
      initialVideoId: 'LyCelsH_9L0', // 초기 비디오 ID를 설정합니다.
      flags: YoutubePlayerFlags(autoPlay: false), // 자동 재생을 비활성화합니다.
    );
  }

  static List<Widget> _widgetOptions(_MyHomePageState state) => <Widget>[
        // 화면에 표시될 위젯 리스트를 정의합니다.
        // 달력 탭
        TableCalendar(
          firstDay: DateTime.utc(2010, 10, 16), // 달력의 시작 날짜를 설정합니다.
          lastDay: DateTime.utc(2030, 3, 14), // 달력의 마지막 날짜를 설정합니다.
          focusedDay: state._focusedDay, // 현재 포커스된 날짜를 설정합니다.
          calendarFormat: state._calendarFormat, // 달력의 형식을 설정합니다.
          selectedDayPredicate: (day) {
            // 선택된 날짜를 확인하는 함수입니다.
            return isSameDay(state._selectedDay, day);
          },
          onDaySelected: (selectedDay, focusedDay) {
            // 날짜를 선택했을 때 호출되는 함수입니다.
            state._selectedDay = selectedDay; // 선택된 날짜를 업데이트합니다.
            state._focusedDay = focusedDay; // 포커스된 날짜를 업데이트합니다.
            state.setState(() {}); // 위젯의 상태를 업데이트하여 화면을 다시 그립니다.
          },
        ),
        // 오늘 탭
        Column(
          // 세로로 위젯을 나열하는 컨테이너입니다.
          children: [
            YoutubePlayer(
              controller: state._controller, // YouTube 플레이어를 설정합니다.
            ),
            IconButton(
              // 아이콘 버튼 위젯입니다.
              icon: Icon(
                  state._isLiked ? Icons.favorite : Icons.favorite_border,
                  size: 48), // 아이콘의 상태에 따라 다른 아이콘을 표시합니다.
              color: Colors.red,
              onPressed: () {
                // 버튼을 눌렀을 때 호출되는 함수입니다.
                state.setState(() {
                  state._isLiked = !state._isLiked; // 좋아요 상태를 토글합니다.
                });
              },
            ),
            TextField(
              // 텍스트 입력 필드입니다.
              controller: state._memoController, // 입력을 관리하는 컨트롤러를 설정합니다.
              decoration: InputDecoration(
                labelText: '메모', // 입력 필드의 라벨을 '메모'로 설정합니다.
                border: OutlineInputBorder(), // 테두리 스타일을 설정합니다.
              ),
              maxLines: 5, // 최대 입력 줄 수를 5로 설정합니다.
            ),
          ],
        ),
        // 내 정보 탭
        Text('내 정보 화면',
            style: TextStyle(
                fontSize: 24, fontWeight: FontWeight.bold)), // 텍스트 위젯입니다.
      ];

  void _onItemTapped(int index) {
    // 탭을 선택했을 때 호출되는 함수입니다.
    setState(() {
      _selectedIndex = index; // 선택된 탭의 인덱스를 업데이트합니다.
    });
  }

  @override
  Widget build(BuildContext context) {
    // 위젯의 UI를 구성합니다.
    return Scaffold(
      // 기본적인 머티리얼 디자인 레이아웃을 제공하는 위젯입니다.
      appBar: AppBar(
        title: Text('플러터 앱'), // 앱바의 타이틀을 설정합니다.
      ),
      body: Center(
        // 본문의 내용을 중앙에 배치합니다.
        child: _widgetOptions(this)
            .elementAt(_selectedIndex), // 선택된 탭에 해당하는 위젯을 표시합니다.
      ),
      bottomNavigationBar: BottomNavigationBar(
        // 하단 네비게이션 바를 설정합니다.
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: '달력',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: '오늘',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: '내 정보',
          ),
        ],
        currentIndex: _selectedIndex, // 현재 선택된 탭의 인덱스를 표시합니다.
        selectedItemColor: Colors.amber[800], // 선택된 아이템의 색상을 설정합니다.
        onTap: _onItemTapped, // 탭을 선택했을 때 처리할 함수를 연결합니다.
      ),
    );
  }

  @override
  void dispose() {
    // 위젯이 제거될 때 호출되는 함수입니다.
    _controller.dispose(); // YouTube 플레이어 컨트롤러를 정리합니다.
    _memoController.dispose(); // 메모 입력 컨트롤러를 정리합니다.
    super.dispose();
  }
}
