//월급 화면
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/work_provider.dart';
import '../providers/workplace_provider.dart';
import '../models/work.dart';
import '../models/workplace.dart';

class SalaryScreen extends StatefulWidget {
  @override
  _SalaryScreenState createState() => _SalaryScreenState();
}

class _SalaryScreenState extends State<SalaryScreen> {
  DateTime _selectedMonth = DateTime.now();
  String _viewType = '전체'; // '전체', '근무지별', '급여종류별'

  @override
  Widget build(BuildContext context) {
    final workProvider = Provider.of<WorkProvider>(context);
    final workplaceProvider = Provider.of<WorkplaceProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('월급 계산'),
        actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.filter_list),
            onSelected: (value) {
              setState(() {
                _viewType = value;
              });
            },
            itemBuilder: (context) => [
              PopupMenuItem(value: '전체', child: Text('전체 보기')),
              PopupMenuItem(value: '근무지별', child: Text('근무지별 보기')),
              PopupMenuItem(value: '급여종류별', child: Text('급여종류별 보기')),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // 월 선택
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Icon(Icons.chevron_left),
                  onPressed: () {
                    setState(() {
                      _selectedMonth = DateTime(
                        _selectedMonth.year,
                        _selectedMonth.month - 1,
                      );
                    });
                  },
                ),
                TextButton(
                  onPressed: () => _selectMonth(context),
                  child: Text(
                    '${_selectedMonth.year}년 ${_selectedMonth.month}월',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.chevron_right),
                  onPressed: () {
                    setState(() {
                      _selectedMonth = DateTime(
                        _selectedMonth.year,
                        _selectedMonth.month + 1,
                      );
                    });
                  },
                ),
              ],
            ),
          ),

          // 총 급여 표시
          Container(
            margin: EdgeInsets.all(16),
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue, Colors.blue.shade700],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.3),
                  blurRadius: 10,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  '이번 달 총 급여',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  '₩ ${_calculateTotalSalary(workProvider).toStringAsFixed(0)}',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildSummaryItem(
                      '총 근무일',
                      '${_getWorkDays(workProvider)}일',
                      Icons.calendar_today,
                    ),
                    _buildSummaryItem(
                      '총 근무시간',
                      '${_getTotalHours(workProvider).toStringAsFixed(1)}시간',
                      Icons.access_time,
                    ),
                  ],
                ),
              ],
            ),
          ),

          // 상세 내역
          Expanded(
            child: _buildDetailView(workProvider, workplaceProvider),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white.withOpacity(0.9), size: 20),
        SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 12,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailView(WorkProvider workProvider, WorkplaceProvider workplaceProvider) {
    switch (_viewType) {
      case '근무지별':
        return _buildWorkplaceView(workProvider, workplaceProvider);
      case '급여종류별':
        return _buildPayTypeView(workProvider, workplaceProvider);
      default:
        return _buildAllWorksView(workProvider, workplaceProvider);
    }
  }

  Widget _buildWorkplaceView(WorkProvider workProvider, WorkplaceProvider workplaceProvider) {
    final monthWorks = _getMonthWorks(workProvider);
    final Map<int, List<Work>> worksByWorkplace = {};

    for (var work in monthWorks) {
      if (!worksByWorkplace.containsKey(work.workplaceId)) {
        worksByWorkplace[work.workplaceId] = [];
      }
      worksByWorkplace[work.workplaceId]!.add(work);
    }

    if (worksByWorkplace.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: worksByWorkplace.length,
      itemBuilder: (context, index) {
        final workplaceId = worksByWorkplace.keys.elementAt(index);
        final works = worksByWorkplace[workplaceId]!;
        final workplace = workplaceProvider.getWorkplaceById(workplaceId);
        final totalPay = works.fold(0.0, (sum, work) => sum + work.totalPay);

        return Card(
          margin: EdgeInsets.only(bottom: 12),
          child: ExpansionTile(
            leading: CircleAvatar(
              backgroundColor: workplace?.color ?? Colors.grey,
              child: Text(
                workplace?.name.substring(0, 1) ?? '?',
                style: TextStyle(color: Colors.white),
              ),
            ),
            title: Text(workplace?.name ?? '알 수 없는 근무지'),
            subtitle: Text('근무 ${works.length}건'),
            trailing: Text(
              '₩ ${totalPay.toStringAsFixed(0)}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            children: works.map((work) => ListTile(
              dense: true,
              title: Text(
                '${work.date.month}/${work.date.day} - ${work.workHours.toStringAsFixed(1)}시간',
              ),
              trailing: Text('₩ ${work.totalPay.toStringAsFixed(0)}'),
            )).toList(),
          ),
        );
      },
    );
  }

  Widget _buildPayTypeView(WorkProvider workProvider, WorkplaceProvider workplaceProvider) {
    final monthWorks = _getMonthWorks(workProvider);
    final Map<String, List<Work>> worksByPayType = {};

    for (var work in monthWorks) {
      if (!worksByPayType.containsKey(work.payType)) {
        worksByPayType[work.payType] = [];
      }
      worksByPayType[work.payType]!.add(work);
    }

    if (worksByPayType.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: worksByPayType.length,
      itemBuilder: (context, index) {
        final payType = worksByPayType.keys.elementAt(index);
        final works = worksByPayType[payType]!;
        final totalPay = works.fold(0.0, (sum, work) => sum + work.totalPay);

        return Card(
          margin: EdgeInsets.only(bottom: 12),
          child: ExpansionTile(
            leading: CircleAvatar(
              backgroundColor: _getPayTypeColor(payType),
              child: Icon(
                _getPayTypeIcon(payType),
                color: Colors.white,
              ),
            ),
            title: Text(payType),
            subtitle: Text('근무 ${works.length}건'),
            trailing: Text(
              '₩ ${totalPay.toStringAsFixed(0)}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            children: works.map((work) {
              final workplace = workplaceProvider.getWorkplaceById(work.workplaceId);
              return ListTile(
                dense: true,
                leading: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: workplace?.color ?? Colors.grey,
                    shape: BoxShape.circle,
                  ),
                ),
                title: Text(
                  '${work.date.month}/${work.date.day} - ${workplace?.name ?? "알 수 없음"}',
                ),
                trailing: Text('₩ ${work.totalPay.toStringAsFixed(0)}'),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildAllWorksView(WorkProvider workProvider, WorkplaceProvider workplaceProvider) {
    final monthWorks = _getMonthWorks(workProvider);

    if (monthWorks.isEmpty) {
      return _buildEmptyState();
    }

    // 날짜별로 정렬
    monthWorks.sort((a, b) => b.date.compareTo(a.date));

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: monthWorks.length,
      itemBuilder: (context, index) {
        final work = monthWorks[index];
        final workplace = workplaceProvider.getWorkplaceById(work.workplaceId);

        return Card(
          margin: EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: workplace?.color ?? Colors.grey,
              child: Text(
                '${work.date.day}',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(workplace?.name ?? '알 수 없는 근무지'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${work.payType} - ${work.workHours.toStringAsFixed(1)}시간'),
                if (work.extraPay > 0)
                  Text(
                    '추가수당: ₩${work.extraPay.toStringAsFixed(0)} ${work.extraPayNote ?? ""}',
                    style: TextStyle(fontSize: 12, color: Colors.orange),
                  ),
              ],
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '₩ ${work.totalPay.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (workplace?.deductTax == true || workplace?.deductInsurance == true)
                  Text(
                    '실수령 ₩ ${_calculateNetPay(work, workplace!).toStringAsFixed(0)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_busy, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            '이번 달 등록된 근무가 없습니다',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  List<Work> _getMonthWorks(WorkProvider workProvider) {
    return workProvider.works.where((work) {
      return work.date.year == _selectedMonth.year &&
          work.date.month == _selectedMonth.month;
    }).toList();
  }

  double _calculateTotalSalary(WorkProvider workProvider) {
    final monthWorks = _getMonthWorks(workProvider);
    return monthWorks.fold(0.0, (sum, work) => sum + work.totalPay);
  }

  int _getWorkDays(WorkProvider workProvider) {
    final monthWorks = _getMonthWorks(workProvider);
    final uniqueDays = monthWorks.map((work) =>
        DateTime(work.date.year, work.date.month, work.date.day)
    ).toSet();
    return uniqueDays.length;
  }

  double _getTotalHours(WorkProvider workProvider) {
    final monthWorks = _getMonthWorks(workProvider);
    return monthWorks.fold(0.0, (sum, work) => sum + work.workHours);
  }

  double _calculateNetPay(Work work, Workplace workplace) {
    double netPay = work.totalPay;

    if (workplace.deductTax) {
      netPay -= work.totalPay * 0.033; // 3.3% 세금
    }

    if (workplace.deductInsurance) {
      netPay -= work.totalPay * 0.091; // 약 9.1% 4대보험
    }

    return netPay;
  }

  Color _getPayTypeColor(String payType) {
    switch (payType) {
      case '시급':
        return Colors.blue;
      case '일급':
        return Colors.green;
      case '월급':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  IconData _getPayTypeIcon(String payType) {
    switch (payType) {
      case '시급':
        return Icons.access_time;
      case '일급':
        return Icons.today;
      case '월급':
        return Icons.calendar_month;
      default:
        return Icons.attach_money;
    }
  }

  Future<void> _selectMonth(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedMonth,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      initialDatePickerMode: DatePickerMode.year,
    );

    if (picked != null) {
      setState(() {
        _selectedMonth = DateTime(picked.year, picked.month);
      });
    }
  }
}