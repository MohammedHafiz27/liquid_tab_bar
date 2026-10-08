import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_tab_bar/liquid_tab_bar.dart';

class _PageProbe extends StatefulWidget {
  const _PageProbe({required this.label, required this.onDispose});
  final String label;
  final VoidCallback onDispose;
  @override
  State<_PageProbe> createState() => _PageProbeState();
}

class _PageProbeState extends State<_PageProbe>
    with AutomaticKeepAliveClientMixin<_PageProbe> {
  @override
  bool get wantKeepAlive => true;
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Center(child: Text(widget.label));
  }

  @override
  void dispose() {
    widget.onDispose();
    super.dispose();
  }
}

void main() {
  testWidgets('padding threshold changes retain PageView and its active page',
      (tester) async {
    final controller = PageController();
    var disposals = 0;
    final pages = PageView(
      controller: controller,
      children: [
        _PageProbe(label: 'Home body', onDispose: () => disposals++),
        _PageProbe(label: 'Search body', onDispose: () => disposals++),
      ],
    );
    Future<void> pump(double bottom) => tester.pumpWidget(MaterialApp(
          home: MediaQuery(
            data: MediaQueryData(padding: EdgeInsets.only(bottom: bottom)),
            child: LiquidScrollPadding(child: pages),
          ),
        ));
    await pump(0);
    controller.jumpToPage(1);
    await tester.pumpAndSettle();
    final pageState = tester.state(find.byType(PageView));
    expect(find.text('Search body'), findsOneWidget);
    for (final bottom in [400.0, 0.0, 400.0, 0.0]) {
      await pump(bottom);
      await tester.pumpAndSettle();
      expect(tester.state(find.byType(PageView)), same(pageState));
      expect(disposals, 0);
      expect(controller.page, 1);
      expect(find.text('Search body'), findsOneWidget);
      expect(tester.takeException(), isNull);
    }
    await tester.pumpWidget(const SizedBox.shrink());
    controller.dispose();
  });
}
