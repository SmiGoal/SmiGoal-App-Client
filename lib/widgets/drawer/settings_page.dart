import 'package:flutter/material.dart';
import '../../widgets/button/sm_icon_button.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _isSwitched1 = true;

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
              value: _isSwitched1,
              onChanged: (value) {
                setState(() {
                  _isSwitched1 = value;
                });
              },
            ),
          ),
          Divider(),
          ListTile(
            title: Text('데이터베이스 초기화'),
            onTap: () {},
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