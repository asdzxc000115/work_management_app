import 'package:flutter/foundation.dart';
import '../models/work.dart';
import '../services/database_service.dart';
import 'auth_provider.dart';

class WorkProvider extends ChangeNotifier {
  List<Work> _works = [];
  final DatabaseService _db = DatabaseService.instance;
  AuthProvider? _authProvider;

  List<Work> get works => _works;

  void setAuthProvider(AuthProvider authProvider) {
    _authProvider = authProvider;
    loadWorks();
  }

  Future<void> loadWorks() async {
    if (_authProvider?.currentUser == null) return;

    _works = await _db.getWorks(_authProvider!.currentUser!.id!);
    notifyListeners();
  }

  Future<void> addWork(Work work) async {
    if (_authProvider?.currentUser == null) return;

    final id = await _db.insertWork(work, _authProvider!.currentUser!.id!);
    final newWork = Work(
      id: id,
      workplaceId: work.workplaceId,
      date: work.date,
      payType: work.payType,
      hourlyWage: work.hourlyWage,
      startTime: work.startTime,
      endTime: work.endTime,
      breakMinutes: work.breakMinutes,
      extraPay: work.extraPay,
      extraPayNote: work.extraPayNote,
    );
    _works.add(newWork);
    notifyListeners();
  }

  Future<void> updateWork(Work work) async {
    await _db.updateWork(work);
    final index = _works.indexWhere((w) => w.id == work.id);
    if (index != -1) {
      _works[index] = work;
      notifyListeners();
    }
  }

  Future<void> deleteWork(int workId) async {
    await _db.deleteWork(workId);
    _works.removeWhere((w) => w.id == workId);
    notifyListeners();
  }

  Future<void> deleteWorksByWorkplace(int workplaceId) async {
    await _db.deleteWorksByWorkplace(workplaceId);
    _works.removeWhere((w) => w.workplaceId == workplaceId);
    notifyListeners();
  }

  List<Work> getWorksByDate(DateTime date) {
    return _works.where((work) {
      return work.date.year == date.year &&
          work.date.month == date.month &&
          work.date.day == date.day;
    }).toList();
  }

  List<Work> getWorksByMonth(int year, int month) {
    return _works.where((work) {
      return work.date.year == year && work.date.month == month;
    }).toList();
  }

  List<Work> getWorksByWorkplace(int workplaceId) {
    return _works.where((work) => work.workplaceId == workplaceId).toList();
  }

  double getTotalSalaryByMonth(int year, int month) {
    final monthWorks = getWorksByMonth(year, month);
    return monthWorks.fold(0.0, (sum, work) => sum + work.totalPay);
  }

  Map<String, double> getSalaryByPayType(int year, int month) {
    final monthWorks = getWorksByMonth(year, month);
    final Map<String, double> salaryByType = {};

    for (var work in monthWorks) {
      if (!salaryByType.containsKey(work.payType)) {
        salaryByType[work.payType] = 0;
      }
      salaryByType[work.payType] = salaryByType[work.payType]! + work.totalPay;
    }

    return salaryByType;
  }

  Map<int, double> getSalaryByWorkplace(int year, int month) {
    final monthWorks = getWorksByMonth(year, month);
    final Map<int, double> salaryByWorkplace = {};

    for (var work in monthWorks) {
      if (!salaryByWorkplace.containsKey(work.workplaceId)) {
        salaryByWorkplace[work.workplaceId] = 0;
      }
      salaryByWorkplace[work.workplaceId] =
          salaryByWorkplace[work.workplaceId]! + work.totalPay;
    }

    return salaryByWorkplace;
  }
}