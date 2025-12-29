import 'package:flutter/material.dart';
import '../data/models/routine_models.dart';
import '../data/repositories/routine_repository.dart';

class TemplateViewModel extends ChangeNotifier {
  final RoutineRepository _repository;
  final String _userId;

  List<RoutineTemplate> _templates = [];
  bool _isLoading = false;

  TemplateViewModel(this._repository, this._userId) {
    _listenToTemplates();
  }

  List<RoutineTemplate> get templates => _templates;
  bool get isLoading => _isLoading;

  void _listenToTemplates() {
    _setLoading(true);
    _repository.getUserTemplates(_userId).listen((data) {
      _templates = data;
      _setLoading(false);
      notifyListeners();
    });
  }

  Future<void> addTemplate(RoutineTemplate template) async {
    await _repository.saveTemplate(template);
  }

  Future<void> toggleTemplateStatus(String templateId, bool isActive) async {
    final template = _templates.firstWhere((t) => t.id == templateId);
    final updated = RoutineTemplate(
      id: template.id,
      userId: template.userId,
      name: template.name,
      daysOfWeek: template.daysOfWeek,
      tasks: template.tasks,
      isActive: isActive,
    );
    await _repository.saveTemplate(updated);
  }

  void _setLoading(bool val) {
    _isLoading = val;
    notifyListeners();
  }
}
