import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habit_app/core/theme.dart';
import 'package:habit_app/data/habit_store.dart';
import 'package:habit_app/widgets/mood_picker.dart';

class MoodScreen extends ConsumerStatefulWidget {
  const MoodScreen({super.key});

  @override
  ConsumerState<MoodScreen> createState() => _MoodScreenState();
}

class _MoodScreenState extends ConsumerState<MoodScreen> {
  late double _moodValue;

  @override
  void initState() {
    super.initState();
    _moodValue = ref.read(habitStoreProvider.notifier).moodToday ?? 0.5;
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpace.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back, color: AppColors.text),
                  ),
                ],
              ),
              SizedBox(height: AppSpace.md),
              Text('HOW ARE YOU FEELING?', style: textTheme.labelSmall),
              Expanded(
                child: Center(
                  child: MoodPicker(
                    initial: _moodValue,
                    onChanged: (value) => _moodValue = value,
                  ),
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    ref.read(habitStoreProvider.notifier).setMood(_moodValue);
                    Navigator.pop(context);
                  },
                  child: const Text('Save check-in'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
