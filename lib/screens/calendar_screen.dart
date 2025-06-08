//캘린더 화면
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:provider/provider.dart';
import '../providers/work_provider.dart';
import '../providers/workplace_provider.dart';
import '../screens/add_work_screen.dart';
import '../models/work.dart';

class CalendarScreen extends StatefulWidget {
  @override
  _CalendarScreenState createState() => _CalendarScreenState();
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
      appBar: AppBar(
        title: Text('캘린더'),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: () => _showFilterDialog(context, workplaceProvider),
          ),
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () => _showCalendarSettings(context),
          ),
        ],
      ),
      body: Column(
        children: [
          TableCalendar<Work>(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            startingDayOfWeek: _startingDayOfWeek,
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            eventLoader: (day) => _getEventsForDay(day, workProvider),
            calendarStyle: CalendarStyle(
              outsideDaysVisible: false,
              todayDecoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: Colors.blue,
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
              formatButtonVisible: true,
              titleCentered: true,
              formatButtonShowsNext: false,
              formatButtonDecoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(16.0),
              ),
              formatButtonTextStyle: TextStyle(
                color: Colors.white,
              ),
            ),
            calendarBuilders: CalendarBuilders(
              markerBuilder: (context, date, events) {
                if (events.isNotEmpty && _showWorkDetails) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: events.take(3).map((event) {
                      final workplace = workplaceProvider.getWorkplaceById(event.workplaceId);
                      return Container(
                        width: 7,
                        height: 7,
                        margin: EdgeInsets.symmetric(horizontal: 1),
                        decoration: BoxDecoration(
                          color: workplace?.color ?? Colors.grey,
                          shape: BoxShape.circle,
                        ),
                      );
                    }).toList(),
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
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${day.day}',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '오늘',
                        style: TextStyle(fontSize: 10, color: Colors.orange),
                      ),
                    ],
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
          const SizedBox(height: 8.0),
          Expanded(
            child: _buildWorkList(workProvider, workplaceProvider),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
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
            Icon(Icons.event_busy, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              '이 날짜에 등록된 근무가 없습니다',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: works.length,
      itemBuilder: (context, index) {
        final work = works[index];
        final workplace = workplaceProvider.getWorkplaceById(work.workplaceId);

        return Card(
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: workplace?.color ?? Colors.grey,
              child: Text(
                workplace?.name.substring(0, 1) ?? '?',
                style: TextStyle(color: Colors.white),
              ),
            ),
            title: Text(workplace?.name ?? '알 수 없는 근무지'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_formatTime(work.startTime)} - ${_formatTime(work.endTime)}',
                ),
                Text(
                  '${work.payType}: ${work.workHours.toStringAsFixed(1)}시간 / ₩${work.totalPay.toStringAsFixed(0)}',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            trailing: IconButton(
              icon: Icon(Icons.edit),
              onPressed: () {
                // 수정 화면으로 이동
              },
            ),
          ),
        );
      },
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  void _showFilterDialog(BuildContext context, WorkplaceProvider provider) {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('근무지 필터'),
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
                      value: _visibleWorkplaces[workplace.id] ?? true,
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
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    title: Text('근무 표시 방식'),
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