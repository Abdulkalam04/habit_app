import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Call once in main() before runApp.
Future<void> initStorage() async {
  await Hive.initFlutter();
  await Hive.openBox(HabitStore.boxName);
}

String dateKey(DateTime d) =>
    '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

class Habit {
  const Habit({required this.id, required this.name});
  final String id;
  final String name;
}

class AppData {
  const AppData({
    required this.habits,
    required this.completions,
    required this.moods,
  });

  final List<Habit> habits;

  /// dateKey -> ids of habits completed that day
  final Map<String, Set<String>> completions;

  /// dateKey -> mood value 0.0 to 1.0
  final Map<String, double> moods;
}

class HabitStore extends Notifier<AppData> {
  static const boxName = 'habit_app';
  Box get _box => Hive.box(boxName);

  @override
  AppData build() {
    final rawHabits = (_box.get('habits') as List?) ?? [];
    final habits = rawHabits
        .map((e) => Map<String, dynamic>.from(e as Map))
        .map((m) => Habit(id: m['id'] as String, name: m['name'] as String))
        .toList();

    final rawDone = Map<String, dynamic>.from(
      (_box.get('completions') as Map?) ?? {},
    );
    final completions = rawDone.map(
      (k, v) => MapEntry(k, Set<String>.from(v as List)),
    );

    final rawMoods = Map<String, dynamic>.from(
      (_box.get('moods') as Map?) ?? {},
    );
    final moods = rawMoods.map((k, v) => MapEntry(k, (v as num).toDouble()));

    // First launch: start with three default habits.
    if (habits.isEmpty) {
      habits.addAll(const [
        Habit(id: 'water', name: 'Drink water'),
        Habit(id: 'read', name: 'Read 20 pages'),
        Habit(id: 'workout', name: 'Workout'),
      ]);
    }

    return AppData(habits: habits, completions: completions, moods: moods);
  }

  // ---- Reading ----

  bool isDone(String habitId, [DateTime? day]) =>
      state.completions[dateKey(day ?? DateTime.now())]?.contains(habitId) ??
      false;

  double get progressToday {
    if (state.habits.isEmpty) return 0;
    final done = state.habits.where((h) => isDone(h.id)).length;
    return done / state.habits.length;
  }

  double? get moodToday => state.moods[dateKey(DateTime.now())];

  /// Oldest first, last item is today. Each value is 0.0 to 1.0.
  List<double> heatmapValues(int weeks) {
    final today = DateTime.now();
    final total = weeks * 7;
    return List.generate(total, (i) {
      final day = today.subtract(Duration(days: total - 1 - i));
      if (state.habits.isEmpty) return 0.0;
      final done = state.habits.where((h) => isDone(h.id, day)).length;
      return done / state.habits.length;
    });
  }

  // ---- Writing ----

  void toggle(String habitId) {
    final key = dateKey(DateTime.now());
    final next = Map<String, Set<String>>.from(state.completions);
    final set = Set<String>.from(next[key] ?? {});
    set.contains(habitId) ? set.remove(habitId) : set.add(habitId);
    next[key] = set;
    _update(completions: next);
  }

  void setMood(double value) {
    final next = Map<String, double>.from(state.moods);
    next[dateKey(DateTime.now())] = value;
    _update(moods: next);
  }

  void addHabit(String name) {
    final habit = Habit(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      name: name,
    );
    _update(habits: [...state.habits, habit]);
  }

  /// Fills 60 days of fake history. Great for screenshots. Remove later.
  void seedDemo() {
    final rng = math.Random(7);
    final next = <String, Set<String>>{};
    final today = DateTime.now();
    for (int back = 59; back >= 1; back--) {
      final day = today.subtract(Duration(days: back));
      final chance = back <= 5 ? 1.0 : 0.65; // recent streak
      next[dateKey(day)] = {
        for (final h in state.habits)
          if (rng.nextDouble() < chance) h.id,
      };
    }
    next[dateKey(today)] = state.completions[dateKey(today)] ?? {};
    _update(completions: next);
  }

  // ---- Saving ----

  void _update({
    List<Habit>? habits,
    Map<String, Set<String>>? completions,
    Map<String, double>? moods,
  }) {
    state = AppData(
      habits: habits ?? state.habits,
      completions: completions ?? state.completions,
      moods: moods ?? state.moods,
    );
    _box.put(
      'habits',
      state.habits.map((h) => {'id': h.id, 'name': h.name}).toList(),
    );
    _box.put(
      'completions',
      state.completions.map((k, v) => MapEntry(k, v.toList())),
    );
    _box.put('moods', state.moods);
  }
}

final habitStoreProvider = NotifierProvider<HabitStore, AppData>(
  HabitStore.new,
);
