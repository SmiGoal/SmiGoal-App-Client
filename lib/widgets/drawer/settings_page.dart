import 'package:flutter/material.dart';
import '../../functions/settings_manager.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _autoAnalyze = true;
  final _settingsManager = SettingsManager();

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    bool isEnabled = await _settingsManager.isForegroundServiceEnabled();
    setState(() {
      _autoAnalyze = isEnabled;
    });
  }

  void _showWarning() async {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("경고"),
            content: Text("앱 내 데이터베이스에 있는 모든 문자 데이터가 삭제됩니다.\n정말 삭제하시겠습니까?"),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text("취소"),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _settingsManager.deleteAllInDB();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('삭제되었습니다.'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                child: const Text(
                  "삭제",
                  style: TextStyle(
                    color: Colors.red,
                  ),
                ),
              ),
            ],
            actionsPadding: EdgeInsets.all(8),
          );
        }).then((value) {
      if (value) {
        _settingsManager.deleteAllInDB();
      } else {
        dispose();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('설정'),
        leading: Image.asset('assets/images/icon_smigoal_removed_bg.png'),
      ),
      body: ListView(
        children: <Widget>[
          ListTile(
            title: Text('메시지 자동 분석'),
            trailing: Switch(
              value: _autoAnalyze,
              onChanged: (value) {
                setState(() {
                  _autoAnalyze = value;
                });
                _settingsManager.setForegroundServiceEnabled(value);
              },
            ),
          ),
          const Divider(),
          ListTile(
            title: Text('데이터베이스 초기화'),
            onTap: () {
              _showWarning();
            },
          ),
          Divider(),
        ],
      ),
    );
  }
}

// class SettingsPage extends StatelessWidget {
//   const SettingsPage({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('설정'),
//         leading: Image.asset('assets/icon_smigoal_removed_bg.png'),
//       ),
//       body: SizedBox(
//         height: double.infinity,
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             SMIconButton(
//               onPressed: () {},
//               asset: 'assets/icon_smigoal_removed_bg.png',
//               label: '데이터베이스 초기화',
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }
