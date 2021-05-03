import 'dart:async';
import 'package:flutter/material.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'dialogs.dart';
import 'images.dart';
import 'messaging.dart';

final FirebaseMessaging _messaging = FirebaseMessaging();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final FirebaseApp app = await FirebaseApp.configure(
    name: 'CBA Retreat',
    options: const FirebaseOptions(
      googleAppID: '1:1069252633339:android:4c101d7b716ff3f2',
      gcmSenderID: '1069252633339',
      databaseURL: 'https://cba-retreat.firebaseio.com/',
      storageBucket: 'cba-retreat.appspot.com',
      apiKey: 'AIzaSyBkhrchnoMwgz67nJGi3qETa6EgG1xXjM0',
      projectID: 'cba-retreat'
    )
  );
  _messaging.subscribeToTopic('2019winter');
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'CBA Retreat',
    theme: ThemeData(primarySwatch: Colors.teal),
    initialRoute: '/',
    routes: {
      '/': (_) => MyHomePage(title: 'CBA 수련회 Home Page'),
      'login_dialog': (_) => LoginDialogPage(),
      '/messaging_dialog': (_) => MessagingDialogPage(),
      '/post_list': (_) => PostListPage(),
      
      '/menu': (_) => ImagePage('menu.png', title: '식단',),
      '/lecture': (_) => ImagePage('lecture.png', title: '강의',),
      '/mealwork': (_) => ImagePage('mealwork.png', title: '배식/간식 봉사',),
      '/cleaning': (_) => ImagePage('cleaning.png', title: '청소 구역',),
      '/room': (_) => ImagesTabPage(tabs: ['2층', '별관(형제)', '3층(형제/자매)', '4층(자매)'], image: 'room', title: '숙소',),
      '/campus_place': (_) => ImagesTabPage(tabs: ['3층', '4층', '5층', '별관'], image: 'campus_place', title: '캠퍼스 모임 장소',),
      '/gbs_place': (_) => ImagesTabPage(tabs: ['2층(C/OJ)', '3층(CH)', '4층(CH/A,B)', '5층(E,F,J)'], image: 'gbs_place', title: 'GBS 장소',),
    },
  );
}

class MyHomePage extends StatefulWidget {
  final String? title;

  MyHomePage({Key? key, this.title}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _index = 0;
  final tabs = <BottomNavigationBarItem>[
    BottomNavigationBarItem(icon: Icon(Icons.info), label: '정보',),
    BottomNavigationBarItem(icon: Icon(Icons.event), label: '일정',),
    BottomNavigationBarItem(icon: Icon(Icons.menu), label: '메뉴',),
  ];
  final pages = <Widget>[
    InfoPage(),
    ImagePage('timetable.png', appbar: false,),
    MenuPage(),
  ];

  Future<dynamic> _gotoPost(Map<String, dynamic> message) async => Navigator.pushNamed(context, '/post_list');

  @override
  void initState() {
    super.initState();
    _messaging.requestNotificationPermissions();
    _messaging.configure(onMessage: _gotoPost, onLaunch: _gotoPost, onResume: _gotoPost);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Image.asset('assets/images/logo.png'), automaticallyImplyLeading: false, actions: <Widget>[
      IconButton(icon: Icon(Icons.chat), tooltip: 'Q&A', onPressed: () => _gotoPost({})),
      IconButton(icon: Icon(Icons.account_circle), onPressed: () => Navigator.pushNamed(context, 'login_dialog')),
    ],),
    body: pages[_index],
    bottomNavigationBar: BottomNavigationBar(items: tabs, currentIndex: _index, onTap: (i) => setState(() => _index = i),),
  );
}



class InfoPage extends StatelessWidget {
  const InfoPage({Key? key}): super(key: key);

  @override
  Widget build(BuildContext context) => Column(children: <Widget>[
          Expanded(child: Image.asset('assets/images/backgroundtext.webp')),
          Row(children: <Widget>[
            IconButton(icon: Icon(Icons.place), tooltip: '수련회장 위치', onPressed: () => launchURL('http://naver.me/5CxdC0vS')),
            IconButton(icon: Icon(Icons.airport_shuttle), tooltip: '차량 봉사자에게 연락', onPressed: () => launchURL('tel:01033974842')),
            IconButton(icon: Icon(Icons.call), tooltip: '본부 연락', onPressed: () => launchURL('tel:01050254375'))
          ], mainAxisAlignment: MainAxisAlignment.center,),
          Row(children: <Widget>[
            ImageButton(assetPath: 'assets/images/instagram.b&w.webp', tooltip: 'CBA 인스타그램', onTap: () => launchURL('https://www.instagram.com/cba.sungrak/')),
            ImageButton(assetPath: 'assets/images/yt_icon_mono_light.webp', tooltip: 'CBA 유튜브', onTap: () => launchURL('https://www.youtube.com/channel/UCW6bF9L0ZK__Tlwl19B0FYQ')),
            ImageButton(assetPath: 'assets/images/naver.blog.color.webp', tooltip: 'CBA 블로그', onTap: () => launchURL('https://blog.naver.com/thebondofpeace')),
            IconButton(icon: Icon(Icons.home), tooltip: 'CBA 홈페이지', onPressed: () => launchURL('http://cba.sungrak.or.kr/HomePage/Index'))
          ], mainAxisAlignment: MainAxisAlignment.center,)
        ],);

}
      
class MenuPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) => ListView(
    children: <Widget>[
      DrawerHeader(child: Text('메뉴'), decoration: BoxDecoration(color: Theme.of(context).primaryColor)),
      ListTile(title: Text('식단'), leading: Icon(Icons.restaurant),
        onTap: () => Navigator.pushNamed(context, '/menu'), ),
      ListTile(title: Text('강의'), leading: Icon(Icons.school),
        onTap: () => Navigator.pushNamed(context, '/lecture'), ),
      ListTile(title: Text('배식/간식 봉사'), leading: Icon(Icons.restaurant_menu),
        onTap: () => Navigator.pushNamed(context, '/mealwork'), ),
      ListTile(title: Text('청소 구역'), leading: Icon(Icons.brush),
        onTap: () => Navigator.pushNamed(context, '/cleaning'), ),
      Divider(),
      ListTile(title: Text('숙소'), leading: Icon(Icons.hotel),
      onTap: () => Navigator.pushNamed(context, '/room'), ),
      ListTile(title: Text('캠퍼스 모임 장소'), leading: Icon(Icons.people),
        onTap: () => Navigator.pushNamed(context, '/campus_place'), ),
      ListTile(title: Text('GBS 장소'), leading: Text('GBS', style: TextStyle(color: Colors.black),),
        onTap: () => Navigator.pushNamed(context, '/gbs_place'), ),
      ],
    );
}
