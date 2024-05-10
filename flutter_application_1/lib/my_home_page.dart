import 'package:flutter/material.dart';
import 'calendar_tab.dart';
import 'today_tab.dart';

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('성경읽기 서포터')),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          CalendarTab(), // 별도 파일로 분리된 위젯
          TodayTab(), // 별도 파일로 분리된 위젯
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
}
