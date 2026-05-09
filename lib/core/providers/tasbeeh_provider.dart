import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// State management for the Tasbeeh (digital counter) feature.
///
/// Supports multiple dhikr presets, count tracking, target goals,
/// and optional haptic feedback on every tap.
class TasbeehProvider extends ChangeNotifier {
  int _count = 0;
  int _totalCount = 0; // lifetime total across resets
  int _targetCount = 33;
  String _currentDhikr = 'سبحان الله';

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

  /// Increment the counter by 1 with optional haptic feedback.
  void increment({bool haptic = true}) {
    _count++;
    _totalCount++;
    if (haptic) {
      HapticFeedback.lightImpact();
    }
    notifyListeners();
  }

  /// Reset the current session counter to 0.
  void reset() {
    _count = 0;
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
    _count = 0;
    notifyListeners();
  }

  /// Set a custom dhikr text.
  void setCustomDhikr(String text, {int target = 100}) {
    _currentDhikr = text;
    _targetCount = target;
    _count = 0;
    notifyListeners();
  }
}
