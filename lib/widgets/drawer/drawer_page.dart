import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import '../../resources/app_resources.dart';
import '../../widgets/drawer/settings_page.dart';
import '../../widgets/statistic_page.dart';

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
                    fontFamily: Assets.nanumSquareNeo,
                    color: Colors.green,
                    fontStyle: FontStyle.values.first,
                    fontWeight: FontWeight.bold,
                    fontSize: 20),
                ),
                Text('Computer Engineering \'19'),
                Text('Konkuk University'),
                Text('Contact: popopy0412@konkuk.ac.kr'),
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
              image: const DecorationImage(
                  image: AssetImage(Assets.appIconPath)),
              color: AppColors.contentColorBlue,
              gradient: LinearGradient(colors: [
                AppColors.contentColorBlue.withOpacity(0.9),
                AppColors.contentColorBlue.withOpacity(0.5)
              ],
              begin: Alignment.centerLeft),
            ),
            child: null,
            // child: Text(
            //   '설정',
            //   style: TextStyle(
            //     color: Colors.white,
            //     fontSize: 24,
            //   ),
            // ),
          ),
          // ListTile(
          //   leading: const Icon(Icons.message),
          //   title: const Text('메시지 통계'),
          //   onTap: () {
          //     // 여기에 메시지 항목이 클릭됐을 때의 동작을 추가하세요.
          //     Navigator.pop(context);
          //     Navigator.push(
          //       context,
          //       MaterialPageRoute(builder: (context) => const StatisticPage()),
          //     );
          //   },
          // ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('설정'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => SettingsPage()), // 설정 화면으로 이동합니다.
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.account_circle),
            title: const Text('개발자 정보'),
            onTap: () {
              Navigator.pop(context);
              _showDeveloperInfoDialog(context);
            },
          ),
        ],
      ),
    );
  }
}
