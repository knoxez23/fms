import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pamoja_twalima/core/di/injection.dart';
import 'package:pamoja_twalima/core/presentation/settings/app_localizations.dart';
import 'package:pamoja_twalima/core/presentation/widgets/modern_app_bar.dart';
import 'package:pamoja_twalima/features/farm_mgmt/presentation/overview_screen.dart';
import 'package:pamoja_twalima/features/farm_mgmt/presentation/crops/crops_screen.dart';
import 'package:pamoja_twalima/features/farm_mgmt/presentation/animals/animals_screen.dart';
import 'package:pamoja_twalima/features/farm_mgmt/presentation/tasks/tasks_screen.dart';
import 'package:pamoja_twalima/core/presentation/widgets/app_scaffold.dart';
import 'bloc/navigation/farm_nav_cubit.dart';

class FarmMgmtScreen extends StatelessWidget {
  const FarmMgmtScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<FarmNavCubit>(),
      child: const _FarmMgmtView(),
    );
  }
}

class _FarmMgmtView extends StatelessWidget {
  const _FarmMgmtView();

  static const List<Widget> _screens = [
    OverviewScreen(),
    CropsScreen(),
    AnimalsScreen(),
    TasksScreen(),
  ];

  static const List<IconData> _icons = [
    Icons.dashboard,
    Icons.agriculture,
    Icons.pets,
    Icons.task,
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final categories = <String>[
      context.tr('farm_overview'),
      context.tr('farm_crops'),
      context.tr('farm_animals'),
      context.tr('farm_tasks'),
    ];

    return BlocBuilder<FarmNavCubit, FarmNavState>(
      builder: (context, state) {
        return AppScaffold(
          backgroundColor: theme.colorScheme.surface,
          appBar: ModernAppBar(
            title: context.tr('farm_management'),
            variant: AppBarVariant.home,
          ),
          body: Column(
            children: [
              Container(
                color: theme.colorScheme.surface,
                padding: const EdgeInsets.all(16),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: List.generate(categories.length, (index) {
                      final isSelected = index == state.index;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _icons[index],
                                size: 16,
                                color: isSelected
                                    ? theme.colorScheme.primary
                                    : theme.colorScheme.onSurface
                                        .withValues(alpha: 0.6),
                              ),
                              const SizedBox(width: 6),
                              Text(categories[index]),
                            ],
                          ),
                          selected: isSelected,
                          checkmarkColor: theme.colorScheme.primary,
                          selectedColor:
                              theme.colorScheme.primary.withValues(alpha: 0.15),
                          labelStyle: TextStyle(
                            color: isSelected
                                ? theme.colorScheme.primary
                                : theme.colorScheme.onSurface
                                    .withValues(alpha: 0.8),
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                          onSelected: (_) =>
                              context.read<FarmNavCubit>().select(index),
                          backgroundColor: theme.cardColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                            side: BorderSide(
                              color: isSelected
                                  ? theme.colorScheme.primary
                                  : theme.dividerColor.withValues(alpha: 0.3),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ),
              Divider(
                height: 1,
                thickness: 1,
                color: theme.dividerColor.withValues(alpha: 0.1),
              ),
              Expanded(
                child: _screens[state.index],
              ),
            ],
          ),
        );
      },
    );
  }
}
