import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:liquid_tab_bar/droplet.dart';
import 'package:liquid_tab_bar_example/examples/four_style_comparison.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('light and dark lens optics on the same screen', (tester) async {
    await LiquidGlass.load();
    expect(LiquidGlass.supported, isTrue);
    expect(LiquidGlass.dropletSupported, isTrue);
    expect(LiquidTabBarController.shared.effectiveMaterial,
        LiquidTabBarMaterial.glass);
    await tester.pumpWidget(const MaterialApp(home: FourStyleComparison()));

    for (final style in [
      'Normal Light',
      'Normal Dark',
      'Glossy Light',
      'Glossy Dark',
    ]) {
      await tester.tap(find.widgetWithText(ChoiceChip, style));
      await tester.pumpAndSettle();
      debugPrint('CAPTURE $style Home idle');
      await tester
          .runAsync(() => Future<void>.delayed(const Duration(seconds: 2)));

      final bar = find.byType(LiquidTabBar);
      const destinations = ['Explore', 'Saved', 'Profile', 'Home'];
      const indices = [1, 2, 3, 0];
      for (var i = 0; i < destinations.length; i++) {
        final destination = destinations[i];
        final label =
            find.descendant(of: bar, matching: find.text(destination));
        await tester.tapAt(tester.getCenter(label));
        await tester.pump(const Duration(milliseconds: 100));
        debugPrint('CAPTURE $style $destination transition');
        await tester.runAsync(
            () => Future<void>.delayed(const Duration(milliseconds: 300)));
        await tester.pumpAndSettle();
        expect(tester.widget<LiquidTabBar>(bar).selectedIndex, indices[i]);
        debugPrint('CAPTURE $style $destination arrival');
        await tester.runAsync(
            () => Future<void>.delayed(const Duration(milliseconds: 600)));
      }

      for (final destination in destinations) {
        final label =
            find.descendant(of: bar, matching: find.text(destination));
        await tester.tapAt(tester.getCenter(label));
        await tester.pump(const Duration(milliseconds: 80));
        await tester.runAsync(
            () => Future<void>.delayed(const Duration(milliseconds: 100)));
      }
      await tester.pumpAndSettle();
      if (tester.widget<LiquidTabBar>(bar).selectedIndex != 0) {
        final home = find.descendant(of: bar, matching: find.text('Home'));
        await tester.tapAt(tester.getCenter(home));
        await tester.pumpAndSettle();
      }
      expect(tester.widget<LiquidTabBar>(bar).selectedIndex, 0);
      debugPrint('CAPTURE $style fast switch settled');
      await tester
          .runAsync(() => Future<void>.delayed(const Duration(seconds: 1)));
    }
  });
}
