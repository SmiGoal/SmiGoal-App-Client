import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../resources/app_resources.dart';

class AnalysisManualPage extends StatefulWidget {
  const AnalysisManualPage({super.key});

  @override
  State<AnalysisManualPage> createState() => _AnalysisManualPageState();
}

class _AnalysisManualPageState extends State<AnalysisManualPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  DateTime? _selectedDate;

  void _presentDatePicker() {
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      locale: const Locale('ko', 'KR'),
    ).then((pickedDate) {
      if (pickedDate == null) return;
      setState(() {
        _selectedDate = pickedDate;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('스미싱 분석'),
      ),
      body: Container(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('전화번호', style: TextStyle(fontSize: 16)),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                          child: TextFormField(
                            controller: _titleController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              hintText: '전화번호를 입력하세요',
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text('수신 날짜', style: TextStyle(fontSize: 16)),
                      Card(
                        child: Row(
                          children: [
                            SizedBox(width: 10),
                            Icon(Icons.calendar_today),
                            const SizedBox(width: 20),
                            Flexible(
                              child: InkWell(
                                onTap: _presentDatePicker,
                                child: Container(
                                  width: double.infinity,
                                  height: 50,
                                  alignment: Alignment.centerLeft,
                                  // decoration: const BoxDecoration(
                                  //   border: Border(bottom: BorderSide(color: Colors.grey)),
                                  // ),
                                  child: Text(
                                    _selectedDate == null
                                        ? '날짜 선택'
                                        : DateFormat('yyyy-MM-dd')
                                            .format(_selectedDate!),
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text('문자 메시지', style: TextStyle(fontSize: 16)),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                          child: TextField(
                            controller: _messageController,
                            decoration: const InputDecoration(
                              hintText: '메시지를 입력하세요',
                              border: InputBorder.none,
                            ),
                            maxLines: 4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    AlertDialog(
                      title: Text('dfadd'),
                    ).build(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.contentColorBlue,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
                  ),
                  child: const Text('분석', style: TextStyle(color: AppColors.contentColorWhite)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
