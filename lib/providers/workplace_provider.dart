import 'package:flutter/foundation.dart';
import '../models/workplace.dart';
import '../services/database_service.dart';
import 'auth_provider.dart';

class WorkplaceProvider extends ChangeNotifier {
  List<Workplace> _workplaces = [];
  final DatabaseService _db = DatabaseService.instance;
  AuthProvider? _authProvider;

  List<Workplace> get workplaces => _workplaces;

  void setAuthProvider(AuthProvider authProvider) {
    _authProvider = authProvider;
    loadWorkplaces();
  }

  Future<void> loadWorkplaces() async {
    if (_authProvider?.currentUser == null) return;

    _workplaces = await _db.getWorkplaces(_authProvider!.currentUser!.id!);
    notifyListeners();
  }

  Future<void> addWorkplace(Workplace workplace) async {
    if (_authProvider?.currentUser == null) return;

    final id = await _db.insertWorkplace(workplace, _authProvider!.currentUser!.id!);
    final newWorkplace = Workplace(
      id: id,
      name: workplace.name,
      payday: workplace.payday,
      color: workplace.color,
      deductTax: workplace.deductTax,
      deductInsurance: workplace.deductInsurance,
    );
    _workplaces.add(newWorkplace);
    notifyListeners();
  }

  Future<void> updateWorkplace(Workplace workplace) async {
    await _db.updateWorkplace(workplace);
    final index = _workplaces.indexWhere((w) => w.id == workplace.id);
    if (index != -1) {
      _workplaces[index] = workplace;
      notifyListeners();
    }
  }

  Future<void> deleteWorkplace(int workplaceId) async {
    await _db.deleteWorkplace(workplaceId);
    _workplaces.removeWhere((w) => w.id == workplaceId);
    notifyListeners();
  }

  Workplace? getWorkplaceById(int id) {
    try {
      return _workplaces.firstWhere((w) => w.id == id);
    } catch (e) {
      return null;
    }
  }
}