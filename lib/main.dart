import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.yellow,
        scaffoldBackgroundColor: Color.fromARGB(255, 19, 19, 19),
      ),
      home: Scaffold(
        body: MyHomePage(),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  MyHomePageState createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> {
  FlutterTts flutterTts = FlutterTts();

  void _speak() async {
    await flutterTts.speak("오늘의 가장 중요한 일은 무엇인가요?");
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        SizedBox(
          height: 11,
        ),
        Text(
          'LV3',
          style: TextStyle(
              fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        Padding(
          padding: EdgeInsets.all(22.0),
          child: Text(
            '가장 중요하다고 말한 그 일, 달성했나요?',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.white),
          ),
        ),
        Spacer(), // 이 위젯은 상단 요소와 버튼 사이의 공간을 자동으로 조절합니다.
        ElevatedButton(
          onPressed: _speak,
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.black, backgroundColor: Colors.yellow,
            minimumSize: Size(MediaQuery.of(context).size.width,
                MediaQuery.of(context).size.height / 4), // 버튼의 크기 설정
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(90), // 왼쪽 상단 모서리 둥글게
                topRight: Radius.circular(90), // 오른쪽 상단 모서리 둥글게
              ),
            ),
          ),
          child: Text(
            '음성답변',
            style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600), // 텍스트 크기를 증가시켜 더 보이기 쉽게 만듭니다.
          ),
        ),
      ],
    );
  }
}
