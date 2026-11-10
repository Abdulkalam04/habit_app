import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habit_app/core/theme.dart';
import 'package:habit_app/data/habit_store.dart';
import 'package:habit_app/widgets/habit_check.dart';
import 'package:habit_app/widgets/progress_ring.dart';
import 'package:habit_app/screens/mood_screen.dart';
import 'package:habit_app/screens/stats_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final habits = ref.watch(habitStoreProvider).habits;
    final store = ref.read(habitStoreProvider.notifier);

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.all(AppSpace.lg),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  Text('TUESDAY, 10 NOV', style: textTheme.labelSmall),
                  SizedBox(height: AppSpace.sm),
                  Text('Today', style: textTheme.displayLarge),
                  SizedBox(height: AppSpace.xl),
                  Center(child: ProgressRing(progress: store.progressToday)),
                  SizedBox(height: AppSpace.xl),
                  for (var index = 0; index < habits.length; index++) ...[
                    _HabitRow(
                          name: habits[index].name,
                          checked: ref
                              .read(habitStoreProvider.notifier)
                              .isDone(habits[index].id),
                          onChanged: (_) => ref
                              .read(habitStoreProvider.notifier)
                              .toggle(habits[index].id),
                        )
                        .animate(delay: Duration(milliseconds: 100 * index))
                        .fadeIn(curve: AppMotion.curve)
                        .slideY(begin: 0.2, curve: AppMotion.curve),
                    if (index < habits.length - 1) const Divider(),
                  ],
                  SizedBox(height: AppSpace.lg),
                  Row(
                    children: [
                      TextButton.icon(
                        onPressed: () =>
                            _pushScreen(context, const MoodScreen()),
                        icon: Icon(Icons.arrow_forward, size: AppSpace.md),
                        label: const Text('Check in your mood'),
                      ),
                      TextButton.icon(
                        onPressed: () =>
                            _pushScreen(context, const StatsScreen()),
                        icon: Icon(Icons.arrow_forward, size: AppSpace.md),
                        label: const Text('View stats'),
                      ),
                    ],
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static void _pushScreen(BuildContext context, Widget screen) {
    Navigator.of(context).push(
      PageRouteBuilder<void>(
        transitionDuration: AppMotion.medium,
        pageBuilder: (context, animation, secondaryAnimation) => screen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final curvedAnimation = CurvedAnimation(
            parent: animation,
            curve: AppMotion.curve,
          );
          return FadeTransition(
            opacity: curvedAnimation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.08),
                end: Offset.zero,
              ).animate(curvedAnimation),
              child: child,
            ),
          );
        },
      ),
    );
  }
}

class _HabitRow extends StatelessWidget {
  const _HabitRow({
    required this.name,
    required this.checked,
    required this.onChanged,
  });

  final String name;
  final bool checked;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final nameStyle = textTheme.bodyLarge!.copyWith(
      color: checked ? AppColors.muted : null,
      decoration: checked ? TextDecoration.lineThrough : TextDecoration.none,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpace.md),
      child: Row(
        children: [
          Expanded(
            child: AnimatedDefaultTextStyle(
              style: nameStyle,
              duration: AppMotion.medium,
              child: Text(name),
            ),
          ),
          HabitCheck(checked: checked, onChanged: onChanged),
        ],
      ),
    );
  }
}
