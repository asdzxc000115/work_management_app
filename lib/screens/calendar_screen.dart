import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:work_management_app/models/work.dart';
import 'package:work_management_app/providers/work_provider.dart';
import 'package:work_management_app/providers/workplace_provider.dart';
import 'package:work_management_app/screens/add_work_screen.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({Key? key}) : super(key: key);

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  StartingDayOfWeek _startingDayOfWeek = StartingDayOfWeek.sunday;
  bool _showWorkDetails = true;
  Map<int, bool> _visibleWorkplaces = {};

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
  }

  List<Work> _getEventsForDay(DateTime day, WorkProvider workProvider) {
    return workProvider.getWorksByDate(day).where((work) {
      return _visibleWorkplaces[work.workplaceId] ?? true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final workProvider = Provider.of<WorkProvider>(context);
    final workplaceProvider = Provider.of<WorkplaceProvider>(context);

    // 근무지 필터 초기화
    if (_visibleWorkplaces.isEmpty) {
      for (var workplace in workplaceProvider.workplaces) {
        _visibleWorkplaces[workplace.id!] = true;
      }
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          // 캘린더 컨테이너
          Container(
            margin: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                // 년/월 선택 및 필터
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Color(0xFF1976D2).withOpacity(0.1),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.chevron_left),
                            onPressed: () {
                              setState(() {
                                _focusedDay = DateTime(
                                  _focusedDay.year,
                                  _focusedDay.month - 1,
                                );
                              });
                            },
                          ),
                          TextButton(
                            onPressed: () => _selectYearMonth(context),
                            child: Text(
                              DateFormat('yyyy년 MM월').format(_focusedDay),
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1976D2),
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.chevron_right),
                            onPressed: () {
                              setState(() {
                                _focusedDay = DateTime(
                                  _focusedDay.year,
                                  _focusedDay.month + 1,
                                );
                              });
                            },
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _selectedDay = DateTime.now();
                                _focusedDay = DateTime.now();
                              });
                            },
                            child: Text(
                              '오늘',
                              style: TextStyle(
                                color: Color(0xFF1976D2),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.filter_list),
                            onPressed: () => _showFilterDialog(context, workplaceProvider),
                            tooltip: '근무지 필터',
                          ),
                          IconButton(
                            icon: Icon(Icons.settings),
                            onPressed: () => _showCalendarSettings(context),
                            tooltip: '캘린더 설정',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // 캘린더
                TableCalendar<Work>(
                  firstDay: DateTime.utc(2020, 1, 1),
                  lastDay: DateTime.utc(2030, 12, 31),
                  focusedDay: _focusedDay,
                  calendarFormat: _calendarFormat,
                  startingDayOfWeek: _startingDayOfWeek,
                  locale: 'ko_KR',
                  selectedDayPredicate: (day) {
                    return isSameDay(_selectedDay, day);
                  },
                  eventLoader: (day) => _getEventsForDay(day, workProvider),
                  calendarStyle: CalendarStyle(
                    outsideDaysVisible: false,
                    weekendTextStyle: TextStyle(color: Colors.red),
                    todayDecoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    selectedDecoration: BoxDecoration(
                      color: Color(0xFF1976D2),
                      shape: BoxShape.circle,
                    ),
                    todayTextStyle: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    markersMaxCount: 3,
                    markerDecoration: BoxDecoration(
                      color: Colors.orange,
                      shape: BoxShape.circle,
                    ),
                  ),
                  headerStyle: HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,
                  ),
                  daysOfWeekStyle: DaysOfWeekStyle(
                    weekdayStyle: TextStyle(fontWeight: FontWeight.bold),
                    weekendStyle: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                  calendarBuilders: CalendarBuilders(
                    markerBuilder: (context, date, events) {
                      if (events.isNotEmpty && _showWorkDetails) {
                        return Positioned(
                          bottom: 1,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: events.take(3).map((event) {
                              final workplace = workplaceProvider.getWorkplaceById(event.workplaceId);
                              return Container(
                                width: 6,
                                height: 6,
                                margin: EdgeInsets.symmetric(horizontal: 1),
                                decoration: BoxDecoration(
                                  color: workplace?.color ?? Colors.grey,
                                  shape: BoxShape.circle,
                                ),
                              );
                            }).toList(),
                          ),
                        );
                      }
                      return null;
                    },
                    todayBuilder: (context, day, focusedDay) {
                      return Container(
                        margin: EdgeInsets.all(4),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.3),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.orange, width: 2),
                        ),
                        child: Text(
                          '${day.day}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.orange[800],
                          ),
                        ),
                      );
                    },
                  ),
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });
                  },
                  onFormatChanged: (format) {
                    setState(() {
                      _calendarFormat = format;
                    });
                  },
                  onPageChanged: (focusedDay) {
                    _focusedDay = focusedDay;
                  },
                ),
              ],
            ),
          ),
          SizedBox(height: 8),
          // 근무 목록
          Expanded(
            child: _buildWorkList(workProvider, workplaceProvider),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddWorkScreen(
                selectedDate: _selectedDay ?? DateTime.now(),
              ),
            ),
          );
        },
        icon: Icon(Icons.add),
        label: Text('근무 추가'),
        backgroundColor: Color(0xFF1976D2),
      ),
    );
  }

  Widget _buildWorkList(WorkProvider workProvider, WorkplaceProvider workplaceProvider) {
    final works = _getEventsForDay(_selectedDay ?? DateTime.now(), workProvider);

    if (works.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_busy, size: 64, color: Colors.grey[400]),
            SizedBox(height: 16),
            Text(
              '이 날짜에 등록된 근무가 없습니다',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            SizedBox(height: 8),
            Text(
              '+ 버튼을 눌러 근무를 추가하세요',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 16),
      itemCount: works.length,
      itemBuilder: (context, index) {
        final work = works[index];
        final workplace = workplaceProvider.getWorkplaceById(work.workplaceId);

        return Container(
          margin: EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 5,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: ListTile(
            contentPadding: EdgeInsets.all(16),
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: workplace?.color.withOpacity(0.2) ?? Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  workplace?.name.substring(0, 1) ?? '?',
                  style: TextStyle(
                    color: workplace?.color ?? Colors.grey,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
            title: Text(
              workplace?.name ?? '알 수 없는 근무지',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.access_time, size: 16, color: Colors.grey),
                    SizedBox(width: 4),
                    Text(
                      '${_formatTime(work.startTime)} - ${_formatTime(work.endTime)}',
                      style: TextStyle(fontSize: 14),
                    ),
                    SizedBox(width: 12),
                    Icon(Icons.timer, size: 16, color: Colors.grey),
                    SizedBox(width: 4),
                    Text(
                      '${work.workHours.toStringAsFixed(1)}시간',
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
                SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.attach_money, size: 16, color: Colors.green),
                    SizedBox(width: 4),
                    Text(
                      '${_formatCurrency(work.totalPay)}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[700],
                      ),
                    ),
                    if (work.extraPay > 0) ...[
                      SizedBox(width: 8),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.orange[100],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '+${_formatCurrency(work.extraPay)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.orange[800],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
            trailing: PopupMenuButton(
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit, size: 20),
                      SizedBox(width: 8),
                      Text('수정'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, size: 20, color: Colors.red),
                      SizedBox(width: 8),
                      Text('삭제', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
              onSelected: (value) {
                if (value == 'edit') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddWorkScreen(
                        selectedDate: work.date,
                        work: work,
                      ),
                    ),
                  );
                } else if (value == 'delete') {
                  _showDeleteConfirmation(context, work.id!);
                }
              },
            ),
          ),
        );
      },
    );
  }

  String _formatTime(DateTime time) {
    return DateFormat('HH:mm').format(time);
  }

  String _formatCurrency(double amount) {
    final formatter = NumberFormat('#,###', 'ko_KR');
    return '₩${formatter.format(amount)}';
  }

  void _showDeleteConfirmation(BuildContext context, int workId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('근무 삭제'),
        content: Text('이 근무 기록을 삭제하시겠습니까?'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        actions: [
          TextButton(
            child: Text('취소'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          ElevatedButton(
            child: Text('삭제'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () {
              Provider.of<WorkProvider>(context, listen: false)
                  .deleteWork(workId);
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  Future<void> _selectYearMonth(BuildContext context) async {
    // 년도 선택 다이얼로그
    int? selectedYear = await showDialog<int>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('년도 선택'),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          content: Container(
            width: double.minPositive,
            height: 300,
            child: YearPicker(
              firstDate: DateTime(2020),
              lastDate: DateTime(2030),
              selectedDate: _focusedDay,
              onChanged: (DateTime dateTime) {
                Navigator.pop(context, dateTime.year);
              },
            ),
          ),
        );
      },
    );

    if (selectedYear != null) {
      setState(() {
        _focusedDay = DateTime(selectedYear, _focusedDay.month);
      });
    }
  }

  void _showFilterDialog(BuildContext context, WorkplaceProvider provider) {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('근무지 필터'),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: provider.workplaces.map((workplace) {
                    return CheckboxListTile(
                      title: Text(workplace.name),
                      secondary: CircleAvatar(
                        backgroundColor: workplace.color,
                        radius: 12,
                      ),
                      value: _visibleWorkplaces[workplace.id!] ?? true,
                      onChanged: (value) {
                        setState(() {
                          _visibleWorkplaces[workplace.id!] = value ?? true;
                        });
                      },
                    );
                  }).toList(),
                ),
              ),
              actions: [
                TextButton(
                  child: Text('닫기'),
                  onPressed: () {
                    Navigator.of(context).pop();
                    this.setState(() {});
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showCalendarSettings(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('캘린더 설정'),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    title: Text('근무 표시'),
                    trailing: Switch(
                      value: _showWorkDetails,
                      onChanged: (value) {
                        setState(() {
                          _showWorkDetails = value;
                        });
                      },
                    ),
                  ),
                  ListTile(
                    title: Text('시작 요일'),
                    trailing: DropdownButton<StartingDayOfWeek>(
                      value: _startingDayOfWeek,
                      items: [
                        DropdownMenuItem(
                          value: StartingDayOfWeek.sunday,
                          child: Text('일요일'),
                        ),
                        DropdownMenuItem(
                          value: StartingDayOfWeek.monday,
                          child: Text('월요일'),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _startingDayOfWeek = value!;
                        });
                      },
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  child: Text('닫기'),
                  onPressed: () {
                    Navigator.of(context).pop();
                    this.setState(() {});
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }
}