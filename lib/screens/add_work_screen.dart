import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
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

  // 2024년 최저시급
  final double _minimumWage = 9860;

  @override
  void initState() {
    super.initState();
    _selectedDates = [widget.selectedDate];
    _hourlyWageController.text = _formatNumberInput(_minimumWage);

    if (widget.work != null) {
      _selectedWorkplaceId = widget.work!.workplaceId;
      _payType = widget.work!.payType;
      _hourlyWageController.text = _formatNumberInput(widget.work!.hourlyWage);
      _startTime = TimeOfDay.fromDateTime(widget.work!.startTime);
      _endTime = TimeOfDay.fromDateTime(widget.work!.endTime);
      _breakMinutes = widget.work!.breakMinutes;
      if (widget.work!.extraPay > 0) {
        _extraPayController.text = _formatNumberInput(widget.work!.extraPay);
      }
      _extraPayNoteController.text = widget.work!.extraPayNote ?? '';
      _selectedDates = [widget.work!.date];
    }
  }

  String _formatNumberInput(double value) {
    return NumberFormat('#,###', 'ko_KR').format(value.toInt());
  }

  double _parseNumberInput(String value) {
    return double.tryParse(value.replaceAll(',', '')) ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    final workplaceProvider = Provider.of<WorkplaceProvider>(context);

    if (workplaceProvider.workplaces.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          title: Text('근무 등록'),
          backgroundColor: Color(0xFF1976D2),
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.error_outline, size: 64, color: Colors.orange),
              ),
              SizedBox(height: 24),
              Text(
                '먼저 근무지를 등록해주세요',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => Navigator.of(context).pop(),
                icon: Icon(Icons.arrow_back),
                label: Text('돌아가기'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF1976D2),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(widget.work == null ? '근무 등록' : '근무 수정'),
        backgroundColor: Color(0xFF1976D2),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            children: [
              // 상단 요약 정보
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Color(0xFF1976D2),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(32),
                    bottomRight: Radius.circular(32),
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      DateFormat('yyyy년 MM월 dd일 (E)', 'ko_KR').format(_selectedDates.first),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (_selectedDates.length > 1) ...[
                      SizedBox(height: 4),
                      Text(
                        '외 ${_selectedDates.length - 1}일',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 근무지 선택
                    Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '근무지',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 12),
                            DropdownButtonFormField<int>(
                              value: _selectedWorkplaceId,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                filled: true,
                                fillColor: Colors.grey[50],
                                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                              ),
                              hint: Text('근무지를 선택하세요'),
                              items: workplaceProvider.workplaces.map((workplace) {
                                return DropdownMenuItem(
                                  value: workplace.id,
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 24,
                                        height: 24,
                                        margin: EdgeInsets.only(right: 12),
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
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 16),

                    // 급여 정보
                    Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '급여 정보',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 16),
                            // 급여 종류
                            Row(
                              children: [
                                Expanded(
                                  child: RadioListTile<String>(
                                    title: Text('시급'),
                                    value: '시급',
                                    groupValue: _payType,
                                    contentPadding: EdgeInsets.zero,
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
                                    contentPadding: EdgeInsets.zero,
                                    onChanged: (value) {
                                      setState(() {
                                        _payType = value!;
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 16),
                            // 급여 입력
                            TextFormField(
                              controller: _hourlyWageController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: _payType == '시급' ? '시급' : '일급',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                filled: true,
                                fillColor: Colors.grey[50],
                                prefixText: '₩ ',
                                suffixText: '원',
                                helperText: '최저시급: ${_formatNumberInput(_minimumWage)}원',
                              ),
                              onChanged: (value) {
                                final number = value.replaceAll(',', '');
                                if (number.isNotEmpty) {
                                  final formatted = _formatNumberInput(double.parse(number));
                                  _hourlyWageController.value = TextEditingValue(
                                    text: formatted,
                                    selection: TextSelection.collapsed(offset: formatted.length),
                                  );
                                }
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return '금액을 입력해주세요';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 16),

                    // 근무 날짜 선택
                    if (widget.work == null)
                      Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: InkWell(
                          onTap: () => _selectMultipleDates(context),
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '근무 날짜',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Icon(Icons.calendar_today, color: Color(0xFF1976D2)),
                                  ],
                                ),
                                SizedBox(height: 12),
                                Text(
                                  '선택된 날짜: ${_selectedDates.length}일',
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                                if (_selectedDates.isNotEmpty) ...[
                                  SizedBox(height: 8),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: _selectedDates.map((date) {
                                      return Chip(
                                        label: Text(
                                          DateFormat('MM/dd(E)', 'ko_KR').format(date),
                                          style: TextStyle(fontSize: 12),
                                        ),
                                        deleteIcon: Icon(Icons.close, size: 18),
                                        onDeleted: _selectedDates.length > 1
                                            ? () {
                                          setState(() {
                                            _selectedDates.remove(date);
                                          });
                                        }
                                            : null,
                                      );
                                    }).toList(),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                    if (widget.work == null) SizedBox(height: 16),

                    // 근무시간
                    Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '근무시간',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: InkWell(
                                    onTap: () => _selectTime(context, true),
                                    child: Container(
                                      padding: EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Colors.grey[300]!),
                                        borderRadius: BorderRadius.circular(12),
                                        color: Colors.grey[50],
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '시작 시간',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                          SizedBox(height: 4),
                                          Text(
                                            _startTime.format(context),
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 16),
                                  child: Icon(Icons.arrow_forward, color: Colors.grey),
                                ),
                                Expanded(
                                  child: InkWell(
                                    onTap: () => _selectTime(context, false),
                                    child: Container(
                                      padding: EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Colors.grey[300]!),
                                        borderRadius: BorderRadius.circular(12),
                                        color: Colors.grey[50],
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '종료 시간',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                          SizedBox(height: 4),
                                          Text(
                                            _endTime.format(context),
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 16),
                            // 총 근무시간 표시
                            Container(
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.blue[50],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.access_time, size: 20, color: Colors.blue[700]),
                                  SizedBox(width: 8),
                                  Text(
                                    '총 근무시간: ${_calculateWorkHours()}시간',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue[700],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 16),

                    // 휴게시간
                    Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  '휴게시간',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(width: 8),
                                InkWell(
                                  onTap: () => _showHelpDialog(
                                    '휴게시간',
                                    '근무 중 쉬는 시간을 의미합니다.\n총 근무시간에서 휴게시간을 제외한 시간이 실제 근무시간이 됩니다.',
                                  ),
                                  child: Icon(
                                    Icons.help_outline,
                                    size: 18,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              children: [
                                _buildBreakTimeChip(0, '없음'),
                                _buildBreakTimeChip(30, '30분'),
                                _buildBreakTimeChip(60, '1시간'),
                                _buildBreakTimeChip(90, '1시간 30분'),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 16),

                    // 추가수당
                    Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  '추가수당',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(width: 8),
                                InkWell(
                                  onTap: () => _showHelpDialog(
                                    '추가수당',
                                    '기본 급여 외에 추가로 받는 수당입니다.\n예: 야간수당, 주휴수당, 연장근로수당 등',
                                  ),
                                  child: Icon(
                                    Icons.help_outline,
                                    size: 18,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 16),
                            TextFormField(
                              controller: _extraPayController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: '추가수당 금액',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                filled: true,
                                fillColor: Colors.grey[50],
                                prefixText: '₩ ',
                                suffixText: '원',
                              ),
                              onChanged: (value) {
                                final number = value.replaceAll(',', '');
                                if (number.isNotEmpty) {
                                  final formatted = _formatNumberInput(double.parse(number));
                                  _extraPayController.value = TextEditingValue(
                                    text: formatted,
                                    selection: TextSelection.collapsed(offset: formatted.length),
                                  );
                                }
                              },
                            ),
                            SizedBox(height: 12),
                            TextFormField(
                              controller: _extraPayNoteController,
                              decoration: InputDecoration(
                                labelText: '메모 (선택)',
                                hintText: '예: 야간수당, 주휴수당',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                filled: true,
                                fillColor: Colors.grey[50],
                              ),
                              textCapitalization: TextCapitalization.none,
                              enableSuggestions: true,
                              autocorrect: false,
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 32),

                    // 저장 버튼
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _saveWork,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF1976D2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          widget.work == null ? '등록하기' : '수정하기',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBreakTimeChip(int minutes, String label) {
    final isSelected = _breakMinutes == minutes;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _breakMinutes = minutes;
        });
      },
      selectedColor: Color(0xFF1976D2).withOpacity(0.2),
      checkmarkColor: Color(0xFF1976D2),
      labelStyle: TextStyle(
        color: isSelected ? Color(0xFF1976D2) : Colors.grey[700],
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  String _calculateWorkHours() {
    final start = DateTime(2024, 1, 1, _startTime.hour, _startTime.minute);
    final end = DateTime(2024, 1, 1, _endTime.hour, _endTime.minute);
    final duration = end.difference(start);
    final totalMinutes = duration.inMinutes - _breakMinutes;
    final hours = totalMinutes / 60;
    return hours.toStringAsFixed(1);
  }

  Future<void> _selectTime(BuildContext context, bool isStartTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStartTime ? _startTime : _endTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Color(0xFF1976D2),
            ),
          ),
          child: child!,
        );
      },
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
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(Icons.help_outline, color: Color(0xFF1976D2)),
            SizedBox(width: 8),
            Text(title),
          ],
        ),
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
          hourlyWage: _parseNumberInput(_hourlyWageController.text),
          startTime: DateTime(date.year, date.month, date.day, _startTime.hour, _startTime.minute),
          endTime: DateTime(date.year, date.month, date.day, _endTime.hour, _endTime.minute),
          breakMinutes: _breakMinutes,
          extraPay: _parseNumberInput(_extraPayController.text),
          extraPayNote: _extraPayNoteController.text.isEmpty ? null : _extraPayNoteController.text.trim(),
        );

        if (widget.work == null) {
          workProvider.addWork(work);
        } else {
          workProvider.updateWork(work);
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.work == null ? '근무가 등록되었습니다' : '근무가 수정되었습니다'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );

      Navigator.of(context).pop();
    } else if (_selectedDates.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('근무 날짜를 선택해주세요'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
    }
  }
}