import 'package:flutter/material.dart';
import '../../resources/app_colors.dart';
import '../../widgets/drawer/settings_page.dart';

class DrawerPage extends StatelessWidget {
  const DrawerPage({super.key});

  void _showDeveloperInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('개발자 정보'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  'Team SmiGoal',
                  style: TextStyle(
                      color: Colors.green,
                      fontStyle: FontStyle.values.first,
                      fontWeight: FontWeight.bold,
                      fontSize: 20
                  ),
                ),
                Text('Computer Engineering \'19'),
                Text('Konkuk University'),
                Text('Contact: developer@example.com'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('닫기'),
              onPressed: () {
                Navigator.of(context).pop(); // Dialog를 닫습니다.
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
            child: Text(
              '설정',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.message),
            title: Text('메시지 통계'),
            onTap: () {
              // 여기에 메시지 항목이 클릭됐을 때의 동작을 추가하세요.
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.account_circle),
            title: Text('개발자 정보'),
            onTap: () {
              Navigator.pop(context);
              _showDeveloperInfoDialog(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text('설정'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingsPage()), // 설정 화면으로 이동합니다.
              );
            },
          ),
        ],
      ),
    );
  }
}
