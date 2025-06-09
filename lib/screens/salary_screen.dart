import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:work_management_app/providers/work_provider.dart';
import 'package:work_management_app/providers/workplace_provider.dart';
import 'package:work_management_app/models/work.dart';
import 'package:work_management_app/models/workplace.dart';

class SalaryScreen extends StatefulWidget {
  const SalaryScreen({Key? key}) : super(key: key);

  @override
  State<SalaryScreen> createState() => _SalaryScreenState();
}

class _SalaryScreenState extends State<SalaryScreen> {
  DateTime _selectedMonth = DateTime.now();
  String _viewType = '전체'; // '전체', '근무지별', '급여종류별'

  @override
  Widget build(BuildContext context) {
    final workProvider = Provider.of<WorkProvider>(context);
    final workplaceProvider = Provider.of<WorkplaceProvider>(context);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          // 월 선택 헤더
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 5,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
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
                        DateFormat('yyyy년 MM월').format(_selectedMonth),
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1976D2),
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
                SizedBox(height: 8),
                // 보기 모드 선택
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      _buildViewTypeButton('전체', Icons.list),
                      _buildViewTypeButton('근무지별', Icons.business),
                      _buildViewTypeButton('급여종류별', Icons.attach_money),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 총 급여 카드
          Container(
            margin: EdgeInsets.all(16),
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1976D2), Color(0xFF42A5F5)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Color(0xFF1976D2).withOpacity(0.3),
                  blurRadius: 15,
                  offset: Offset(0, 8),
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
                SizedBox(height: 12),
                Text(
                  _formatCurrency(_calculateTotalSalary(workProvider)),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 20),
                IntrinsicHeight(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildSummaryItem(
                        '총 근무일',
                        '${_getWorkDays(workProvider)}일',
                        Icons.calendar_today,
                      ),
                      VerticalDivider(
                        color: Colors.white.withOpacity(0.3),
                        thickness: 1,
                      ),
                      _buildSummaryItem(
                        '총 근무시간',
                        '${_getTotalHours(workProvider).toStringAsFixed(1)}시간',
                        Icons.access_time,
                      ),
                      VerticalDivider(
                        color: Colors.white.withOpacity(0.3),
                        thickness: 1,
                      ),
                      _buildSummaryItem(
                        '시간당 평균',
                        _formatCurrency(_getAverageHourlyWage(workProvider)),
                        Icons.trending_up,
                      ),
                    ],
                  ),
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

  Widget _buildViewTypeButton(String title, IconData icon) {
    final isSelected = _viewType == title;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _viewType = title),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Color(0xFF1976D2) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected ? Colors.white : Colors.grey[600],
              ),
              SizedBox(width: 4),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? Colors.white : Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white.withOpacity(0.9), size: 24),
        SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 12,
          ),
        ),
        SizedBox(height: 4),
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
        final totalHours = works.fold(0.0, (sum, work) => sum + work.workHours);

        return Container(
          margin: EdgeInsets.only(bottom: 12),
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
          child: Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              tilePadding: EdgeInsets.all(16),
              childrenPadding: EdgeInsets.only(bottom: 8),
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
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                '${works.length}건 • ${totalHours.toStringAsFixed(1)}시간',
                style: TextStyle(fontSize: 13),
              ),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _formatCurrency(totalPay),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1976D2),
                    ),
                  ),
                  if (workplace?.deductTax == true || workplace?.deductInsurance == true)
                    Text(
                      '실수령 ${_formatCurrency(_calculateNetPay(totalPay, workplace!))}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                ],
              ),
              children: works.map((work) => Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        SizedBox(width: 48),
                        Text(
                          DateFormat('MM/dd (E)', 'ko_KR').format(work.date),
                          style: TextStyle(fontSize: 14),
                        ),
                        SizedBox(width: 12),
                        Text(
                          '${work.workHours.toStringAsFixed(1)}시간',
                          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                    Text(
                      _formatCurrency(work.totalPay),
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              )).toList(),
            ),
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

        return Container(
          margin: EdgeInsets.only(bottom: 12),
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
          child: Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              tilePadding: EdgeInsets.all(16),
              childrenPadding: EdgeInsets.only(bottom: 8),
              leading: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _getPayTypeColor(payType).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getPayTypeIcon(payType),
                  color: _getPayTypeColor(payType),
                ),
              ),
              title: Text(
                payType,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text('${works.length}건'),
              trailing: Text(
                _formatCurrency(totalPay),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1976D2),
                ),
              ),
              children: works.map((work) {
                final workplace = workplaceProvider.getWorkplaceById(work.workplaceId);
                return Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            margin: EdgeInsets.only(left: 24, right: 12),
                            decoration: BoxDecoration(
                              color: workplace?.color ?? Colors.grey,
                              shape: BoxShape.circle,
                            ),
                          ),
                          Text(
                            '${DateFormat('MM/dd').format(work.date)} - ${workplace?.name ?? "알 수 없음"}',
                            style: TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                      Text(
                        _formatCurrency(work.totalPay),
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
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
                  '${work.date.day}',
                  style: TextStyle(
                    color: workplace?.color ?? Colors.grey,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            title: Text(
              workplace?.name ?? '알 수 없는 근무지',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.access_time, size: 14, color: Colors.grey),
                    SizedBox(width: 4),
                    Text(
                      '${work.payType} • ${work.workHours.toStringAsFixed(1)}시간',
                      style: TextStyle(fontSize: 13),
                    ),
                  ],
                ),
                if (work.extraPay > 0) ...[
                  SizedBox(height: 4),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.orange[100],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '추가수당 ${_formatCurrency(work.extraPay)} ${work.extraPayNote ?? ""}',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.orange[800],
                      ),
                    ),
                  ),
                ],
              ],
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _formatCurrency(work.totalPay),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1976D2),
                  ),
                ),
                if (workplace?.deductTax == true || workplace?.deductInsurance == true)
                  Text(
                    '실수령 ${_formatCurrency(_calculateNetPayForWork(work, workplace!))}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
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
          Icon(Icons.event_busy, size: 80, color: Colors.grey[300]),
          SizedBox(height: 16),
          Text(
            '이번 달 등록된 근무가 없습니다',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
          SizedBox(height: 8),
          Text(
            '캘린더에서 근무를 추가해보세요',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  String _formatCurrency(double amount) {
    final formatter = NumberFormat('#,###', 'ko_KR');
    return '₩${formatter.format(amount)}';
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

  double _getAverageHourlyWage(WorkProvider workProvider) {
    final totalHours = _getTotalHours(workProvider);
    if (totalHours == 0) return 0;
    return _calculateTotalSalary(workProvider) / totalHours;
  }

  double _calculateNetPay(double totalPay, Workplace workplace) {
    double netPay = totalPay;

    if (workplace.deductTax) {
      netPay -= totalPay * 0.033; // 3.3% 세금
    }

    if (workplace.deductInsurance) {
      netPay -= totalPay * 0.091; // 약 9.1% 4대보험
    }

    return netPay;
  }

  double _calculateNetPayForWork(Work work, Workplace workplace) {
    return _calculateNetPay(work.totalPay, workplace);
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
      locale: Locale('ko', 'KR'),
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
        _selectedMonth = DateTime(picked.year, picked.month);
      });
    }
  }
}