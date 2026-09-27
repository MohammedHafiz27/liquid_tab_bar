import 'package:flutter/material.dart';
import 'package:liquid_tab_bar/liquid_tab_bar.dart';

import 'showcase_content.dart';

/// Cycles through: Normal Light → Normal Dark → Glossy Light → Glossy Dark.
///
/// Same background, same navigation sequence (Home → Explore → Saved → Profile → Home)
/// so visual differences are easy to compare.
class FourStyleComparison extends StatefulWidget {
  const FourStyleComparison({super.key});
  @override
  State<FourStyleComparison> createState() => _FourStyleComparisonState();
}

class _FourStyleComparisonState extends State<FourStyleComparison> {
  int _selected = 0;
  int _styleIndex = 0;

  static const _styleLabels = [
    'Normal Light',
    'Normal Dark',
    'Glossy Light',
    'Glossy Dark',
  ];

  LiquidTabBarTheme _themeForIndex(int index) {
    switch (index) {
      case 0: // Normal Light
        return const LiquidTabBarTheme();
      case 1: // Normal Dark
        return const LiquidTabBarTheme.dark();
      case 2: // Glossy Light
        return LiquidTabBarTheme(barStyle: LiquidBarStyle.glossy());
      case 3: // Glossy Dark
        return LiquidTabBarTheme.dark(barStyle: LiquidBarStyle.glossy());
      default:
        return const LiquidTabBarTheme();
    }
  }

  bool get _isDarkStyle => _styleIndex == 1 || _styleIndex == 3;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: _isDarkStyle
          ? ThemeData(
              brightness: Brightness.dark,
              scaffoldBackgroundColor: const Color(0xFF0B0D11),
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF0A84FF),
                brightness: Brightness.dark,
              ),
              useMaterial3: true,
              appBarTheme: const AppBarTheme(
                elevation: 0,
                scrolledUnderElevation: 0,
                surfaceTintColor: Colors.transparent,
                shadowColor: Colors.transparent,
              ),
            )
          : ThemeData(
              brightness: Brightness.light,
              scaffoldBackgroundColor: const Color(0xFFF8F9FA),
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF007AFF),
                brightness: Brightness.light,
              ),
              useMaterial3: true,
              appBarTheme: const AppBarTheme(
                elevation: 0,
                scrolledUnderElevation: 0,
                surfaceTintColor: Colors.transparent,
                shadowColor: Colors.transparent,
              ),
            ),
      child: Builder(
        builder: (context) => Scaffold(
          extendBody: true,
          appBar: AppBar(
            title: Text(_styleLabels[_styleIndex]),
            actions: [
              TextButton(
                onPressed: () =>
                    setState(() => _styleIndex = (_styleIndex + 1) % 4),
                child: Text(
                  'Next →',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          body: ShowcaseContent(
            selected: _selected,
            controls: Wrap(
              spacing: 8,
              children: [
                for (var i = 0; i < 4; i++)
                  ChoiceChip(
                    label: Text(_styleLabels[i]),
                    selected: _styleIndex == i,
                    onSelected: (_) => setState(() => _styleIndex = i),
                  ),
              ],
            ),
          ),
          bottomNavigationBar: LiquidTabBar(
            key: ValueKey('comparison-$_styleIndex'),
            shrinkOnScroll: false,
            selectedIndex: _selected,
            onSelected: (index) => setState(() => _selected = index),
            items: showcaseItems(),
            theme: _themeForIndex(_styleIndex),
          ),
        ),
      ),
    );
  }
}
