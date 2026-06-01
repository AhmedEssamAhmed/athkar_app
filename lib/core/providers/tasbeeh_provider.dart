import 'package:flutter/material.dart';

import '../storage/hive_service.dart';

/// State management for the Tasbeeh (digital counter) feature.
///
/// Supports multiple dhikr presets, count tracking, target goals.
class TasbeehProvider extends ChangeNotifier {
  int _count = 0;
  int _totalCount = 0; // lifetime total across resets
  int _targetCount = 33;
  String _currentDhikr = 'سبحان الله';

  TasbeehProvider() {
    _init();
  }

  void _init() {
    _totalCount = HiveService.lifetimeTotal();
    _currentDhikr = HiveService.getCachedValue('last_dhikr') as String? ?? 'سبحان الله';
    _count = HiveService.getCachedValue('count_$_currentDhikr') as int? ?? 0;
    
    final preset = presets.firstWhere((p) => p['text'] == _currentDhikr, orElse: () => presets.first);
    _targetCount = preset['target'] as int;
  }

  int get count => _count;
  int get totalCount => _totalCount;
  int get targetCount => _targetCount;
  String get currentDhikr => _currentDhikr;
  double get progress =>
      _targetCount > 0 ? (_count / _targetCount).clamp(0.0, 1.0) : 0.0;
  bool get isComplete => _count >= _targetCount;

  /// Common dhikr presets with their typical counts.
  static const List<Map<String, dynamic>> presets = [
    {'text': 'سبحان الله', 'target': 33},
    {'text': 'الحمد لله', 'target': 33},
    {'text': 'الله أكبر', 'target': 34},
    {'text': 'لا إله إلا الله', 'target': 100},
    {'text': 'أستغفر الله', 'target': 100},
    {'text': 'سبحان الله وبحمده', 'target': 100},
    {'text': 'لا حول ولا قوة إلا بالله', 'target': 100},
  ];

  void increment() {
    _count++;
    _totalCount++;
    HiveService.cacheValue('count_$_currentDhikr', _count);
    notifyListeners();
  }

  /// Reset the current session counter to 0.
  void reset() {
    _count = 0;
    HiveService.cacheValue('count_$_currentDhikr', 0);
    notifyListeners();
  }

  /// Set a new target count.
  void setTarget(int target) {
    _targetCount = target;
    notifyListeners();
  }

  /// Switch to a different dhikr preset.
  void selectPreset(Map<String, dynamic> preset) {
    _currentDhikr = preset['text'] as String;
    _targetCount = preset['target'] as int;
    _count = HiveService.getCachedValue('count_$_currentDhikr') as int? ?? 0;
    
    HiveService.cacheValue('last_dhikr', _currentDhikr);
    notifyListeners();
  }
}
