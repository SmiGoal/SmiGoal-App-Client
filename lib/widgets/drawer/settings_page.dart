import 'package:flutter/material.dart';
import '../../widgets/button/sm_icon_button.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('설정'),
        leading: Image.asset('assets/icon_smigoal_removed_bg.png'),
      ),
      body: SizedBox(
        height: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SMIconButton(
              onPressed: () {},
              asset: 'assets/icon_smigoal_removed_bg.png',
              label: '데이터베이스 초기화',
            )
          ],
        ),
      ),
    );
  }
}
