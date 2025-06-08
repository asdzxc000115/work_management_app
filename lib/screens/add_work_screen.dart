//근무 추가 화면
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/work.dart';
import '../providers/work_provider.dart';
import '../providers/workplace_provider.dart';

class AddWorkScreen extends StatefulWidget {
  final DateTime selectedDate;
  final Work? work;

  AddWorkScreen({required this.selectedDate, this.work});

  @override
  _AddWorkScreenState createState() => _AddWorkScreenState();
}

class _AddWorkScreenState extends State<AddWorkScreen> {
  final _formKey = GlobalKey<FormState>();
  final _hourlyWageController = TextEditingController();
  final _extraPayController = TextEditingController();
  final _extraPayNoteController = TextEditingController();

  int? _selectedWorkplaceId;
  String _payType = '시급';
  List<DateTime> _selectedDates = [];
  TimeOfDay _startTime = TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _endTime = TimeOfDay(hour: 18, minute: 0);
  int _breakMinutes = 0;

  // 2024년 최저시급 (예시)
  final double _minimumWage = 9860;

  @override
  void initState() {
    super.initState();
    _selectedDates = [widget.selectedDate];
    _hourlyWageController.text = _minimumWage.toString();

    if (widget.work != null) {
      _selectedWorkplaceId = widget.work!.workplaceId;
      _payType = widget.work!.payType;
      _hourlyWageController.text = widget.work!.hourlyWage.toString();
      _startTime = TimeOfDay.fromDateTime(widget.work!.startTime);
      _endTime = TimeOfDay.fromDateTime(widget.work!.endTime);
      _breakMinutes = widget.work!.breakMinutes;
      _extraPayController.text = widget.work!.extraPay.toString();
      _extraPayNoteController.text = widget.work!.extraPayNote ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final workplaceProvider = Provider.of<WorkplaceProvider>(context);

    if (workplaceProvider.workplaces.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text('근무 등록')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.orange),
              SizedBox(height: 16),
              Text('먼저 근무지를 등록해주세요', style: TextStyle(fontSize: 16)),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('돌아가기'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.work == null ? '근무 등록' : '근무 수정'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 근무지 선택
              DropdownButtonFormField<int>(
                value: _selectedWorkplaceId,
                decoration: InputDecoration(
                  labelText: '근무지',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.business),
                ),
                items: workplaceProvider.workplaces.map((workplace) {
                  return DropdownMenuItem(
                    value: workplace.id,
                    child: Row(
                      children: [
                        Container(
                          width: 20,
                          height: 20,
                          margin: EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            color: workplace.color,
                            shape: BoxShape.circle,
                          ),
                        ),
                        Text(workplace.name),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedWorkplaceId = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return '근무지를 선택해주세요';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),

              // 급여 종류
              Text('급여 종류', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<String>(
                      title: Text('시급'),
                      value: '시급',
                      groupValue: _payType,
                      onChanged: (value) {
                        setState(() {
                          _payType = value!;
                        });
                      },
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<String>(
                      title: Text('일급'),
                      value: '일급',
                      groupValue: _payType,
                      onChanged: (value) {
                        setState(() {
                          _payType = value!;
                        });
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),

              // 시급/일급 입력
              TextFormField(
                controller: _hourlyWageController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: _payType == '시급' ? '시급' : '일급',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.attach_money),
                  hintText: '최저시급: $_minimumWage원',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '금액을 입력해주세요';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),

              // 근무 날짜 선택
              Text('근무 날짜', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('선택된 날짜: ${_selectedDates.length}일'),
                        TextButton(
                          onPressed: () => _selectMultipleDates(context),
                          child: Text('날짜 선택'),
                        ),
                      ],
                    ),
                    if (_selectedDates.isNotEmpty)
                      Wrap(
                        spacing: 8,
                        children: _selectedDates.map((date) {
                          return Chip(
                            label: Text('${date.month}/${date.day}'),
                            onDeleted: () {
                              setState(() {
                                _selectedDates.remove(date);
                              });
                            },
                          );
                        }).toList(),
                      ),
                  ],
                ),
              ),
              SizedBox(height: 20),

              // 근무시간
              Text('근무시간', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => _selectTime(context, true),
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: '시작 시간',
                          border: OutlineInputBorder(),
                        ),
                        child: Text(_startTime.format(context)),
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: InkWell(
                      onTap: () => _selectTime(context, false),
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: '종료 시간',
                          border: OutlineInputBorder(),
                        ),
                        child: Text(_endTime.format(context)),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),

              // 휴게시간
              Row(
                children: [
                  Text('휴게시간', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  SizedBox(width: 8),
                  InkWell(
                    onTap: () => _showHelpDialog('휴게시간', '근무 중 쉬는 시간을 의미합니다. 총 근무시간에서 휴게시간을 제외한 시간이 실제 근무시간이 됩니다.'),
                    child: Icon(Icons.help_outline, size: 16, color: Colors.grey),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<int>(
                      title: Text('없음'),
                      value: 0,
                      groupValue: _breakMinutes,
                      onChanged: (value) {
                        setState(() {
                          _breakMinutes = value!;
                        });
                      },
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<int>(
                      title: Text('30분'),
                      value: 30,
                      groupValue: _breakMinutes,
                      onChanged: (value) {
                        setState(() {
                          _breakMinutes = value!;
                        });
                      },
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<int>(
                      title: Text('1시간'),
                      value: 60,
                      groupValue: _breakMinutes,
                      onChanged: (value) {
                        setState(() {
                          _breakMinutes = value!;
                        });
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),

              // 추가수당
              Row(
                children: [
                  Text('추가수당', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  SizedBox(width: 8),
                  InkWell(
                    onTap: () => _showHelpDialog('추가수당', '기본 급여 외에 추가로 받는 수당입니다. 예: 야간수당, 주휴수당, 연장근로수당 등'),
                    child: Icon(Icons.help_outline, size: 16, color: Colors.grey),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _extraPayController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: '추가수당 금액',
                        border: OutlineInputBorder(),
                        prefixText: '₩ ',
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    flex: 3,
                    child: TextFormField(
                      controller: _extraPayNoteController,
                      decoration: InputDecoration(
                        labelText: '메모 (선택)',
                        border: OutlineInputBorder(),
                        hintText: '예: 야간수당',
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 32),

              // 저장 버튼
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _saveWork,
                  child: Text(
                    widget.work == null ? '등록하기' : '수정하기',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectTime(BuildContext context, bool isStartTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStartTime ? _startTime : _endTime,
    );
    if (picked != null) {
      setState(() {
        if (isStartTime) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  Future<void> _selectMultipleDates(BuildContext context) async {
    final DateTime firstDate = DateTime.now().subtract(Duration(days: 365));
    final DateTime lastDate = DateTime.now().add(Duration(days: 365));

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('날짜 선택'),
              content: Container(
                width: double.maxFinite,
                height: 400,
                child: CalendarDatePicker(
                  initialDate: widget.selectedDate,
                  firstDate: firstDate,
                  lastDate: lastDate,
                  onDateChanged: (date) {
                    setState(() {
                      if (_selectedDates.any((d) =>
                      d.year == date.year &&
                          d.month == date.month &&
                          d.day == date.day)) {
                        _selectedDates.removeWhere((d) =>
                        d.year == date.year &&
                            d.month == date.month &&
                            d.day == date.day);
                      } else {
                        _selectedDates.add(date);
                      }
                    });
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('완료'),
                ),
              ],
            );
          },
        );
      },
    );
    setState(() {});
  }

  void _showHelpDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('확인'),
          ),
        ],
      ),
    );
  }

  void _saveWork() {
    if (_formKey.currentState!.validate() && _selectedDates.isNotEmpty) {
      final workProvider = Provider.of<WorkProvider>(context, listen: false);

      for (DateTime date in _selectedDates) {
        final work = Work(
          id: widget.work?.id,
          workplaceId: _selectedWorkplaceId!,
          date: date,
          payType: _payType,
          hourlyWage: double.parse(_hourlyWageController.text),
          startTime: DateTime(date.year, date.month, date.day, _startTime.hour, _startTime.minute),
          endTime: DateTime(date.year, date.month, date.day, _endTime.hour, _endTime.minute),
          breakMinutes: _breakMinutes,
          extraPay: double.tryParse(_extraPayController.text) ?? 0,
          extraPayNote: _extraPayNoteController.text.isEmpty ? null : _extraPayNoteController.text,
        );

        if (widget.work == null) {
          workProvider.addWork(work);
        } else {
          workProvider.updateWork(work);
        }
      }

      Navigator.of(context).pop();
    } else if (_selectedDates.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('근무 날짜를 선택해주세요')),
      );
    }
  }
}