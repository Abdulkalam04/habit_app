import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habit_app/core/theme.dart';
import 'package:habit_app/data/habit_store.dart';
import 'package:habit_app/widgets/streak_heatmap.dart';

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    ref.watch(habitStoreProvider);
    final values = ref.read(habitStoreProvider.notifier).heatmapValues(12);
    final completionRate =
        values.where((value) => value > 0).length / values.length * 100;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
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
              Text('YOUR STATS', style: textTheme.labelSmall),
              SizedBox(height: AppSpace.md),
              Text('${currentStreak(values)}', style: textTheme.displayLarge),
              Text('DAY STREAK', style: textTheme.labelSmall),
              SizedBox(height: AppSpace.xl),
              StreakHeatmap(values: values),
              SizedBox(height: AppSpace.xl),
              _StatRow(
                label: 'Best streak',
                value: '${bestStreak(values)} days',
              ),
              const Divider(),
              _StatRow(
                label: 'Completion rate',
                value: '${completionRate.round()}%',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpace.md),
      child: Row(
        children: [
          Expanded(child: Text(label, style: textTheme.bodyLarge)),
          Text(value, style: textTheme.bodyMedium),
        ],
      ),
    );
  }
}
