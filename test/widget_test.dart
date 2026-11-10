import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:habit_app/data/habit_store.dart';

void main() {
  late Directory storageDirectory;

  setUp(() async {
    storageDirectory = await Directory.systemTemp.createTemp('habit_app_test');
    Hive.init(storageDirectory.path);
    await Hive.openBox(HabitStore.boxName);
  });

  tearDown(() async {
    await Hive.close();
    await storageDirectory.delete(recursive: true);
  });

  test('habit completion updates the store and daily progress', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final habits = container.read(habitStoreProvider).habits;
    expect(habits, hasLength(3));

    container.read(habitStoreProvider.notifier).toggle(habits.first.id);

    expect(
      container.read(habitStoreProvider.notifier).isDone(habits.first.id),
      isTrue,
    );
    expect(
      container.read(habitStoreProvider.notifier).progressToday,
      closeTo(1 / 3, 0.001),
    );
    await Hive.box(HabitStore.boxName).flush();
  });
}
