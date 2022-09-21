import 'package:example/ios_popover/_ios_popover_menu.dart';
import 'package:example/ios_popover/_ios_toolbar.dart';
import 'package:example/ios_popover/_toolbar_example.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';

void main() {
  group('iOS Toolbar', () {
    group('pointing up', () {
      testGoldens('without focal point', (tester) async {
        await loadAppFonts();

        await _pumpToolbarScaffold(
          tester,
          child: IosToolbar(
            arrowDirection: ArrowDirection.up,
            children: const [
              IosMenuItem(label: 'Style'),
              IosMenuItem(label: 'Duplicate'),
              IosMenuItem(label: 'Cut'),
              IosMenuItem(label: 'Copy'),
              IosMenuItem(label: 'Paste')
            ],
          ),
        );

        await screenMatchesGolden(tester, 'ios-toolbar/pointing-up');
      });

      testGoldens('with left focal point', (tester) async {
        await loadAppFonts();

        await _pumpToolbarScaffold(
          tester,
          child: IosToolbar(
            arrowDirection: ArrowDirection.up,
            arrowFocalPoint: 70,
            children: const [
              IosMenuItem(label: 'Style'),
              IosMenuItem(label: 'Duplicate'),
              IosMenuItem(label: 'Cut'),
              IosMenuItem(label: 'Copy'),
              IosMenuItem(label: 'Paste')
            ],
          ),
        );

        await screenMatchesGolden(tester, 'ios-toolbar/pointing-up-left-focal-point');
      });

      testGoldens('with left focal point too low', (tester) async {
        await loadAppFonts();

        await _pumpToolbarScaffold(
          tester,
          child: IosToolbar(
            arrowDirection: ArrowDirection.up,
            arrowFocalPoint: 0,
            children: const [
              IosMenuItem(label: 'Style'),
              IosMenuItem(label: 'Duplicate'),
              IosMenuItem(label: 'Cut'),
              IosMenuItem(label: 'Copy'),
              IosMenuItem(label: 'Paste')
            ],
          ),
        );

        await screenMatchesGolden(tester, 'ios-toolbar/pointing-up-left-focal-point-too-low');
      });

      testGoldens('with right focal point', (tester) async {
        await loadAppFonts();

        await _pumpToolbarScaffold(
          tester,
          child: IosToolbar(
            arrowDirection: ArrowDirection.up,
            arrowFocalPoint: 200,
            children: const [
              IosMenuItem(label: 'Style'),
              IosMenuItem(label: 'Duplicate'),
              IosMenuItem(label: 'Cut'),
              IosMenuItem(label: 'Copy'),
              IosMenuItem(label: 'Paste')
            ],
          ),
        );

        await screenMatchesGolden(tester, 'ios-toolbar/pointing-up-right-focal-point');
      });

      testGoldens('with right focal point too big', (tester) async {
        await loadAppFonts();

        await _pumpToolbarScaffold(
          tester,
          child: IosToolbar(
            arrowDirection: ArrowDirection.up,
            arrowFocalPoint: 2000,
            children: const [
              IosMenuItem(label: 'Style'),
              IosMenuItem(label: 'Duplicate'),
              IosMenuItem(label: 'Cut'),
              IosMenuItem(label: 'Copy'),
              IosMenuItem(label: 'Paste')
            ],
          ),
        );

        await screenMatchesGolden(tester, 'ios-toolbar/pointing-up-right-focal-point-too-big');
      });
    });

    group('pointing down', () {
      testGoldens('without focal point', (tester) async {
        await loadAppFonts();

        await _pumpToolbarScaffold(
          tester,
          child: IosToolbar(
            arrowDirection: ArrowDirection.down,
            children: const [
              IosMenuItem(label: 'Style'),
              IosMenuItem(label: 'Duplicate'),
              IosMenuItem(label: 'Cut'),
              IosMenuItem(label: 'Copy'),
              IosMenuItem(label: 'Paste')
            ],
          ),
        );

        await screenMatchesGolden(tester, 'ios-toolbar/pointing-down');
      });

      testGoldens('with left focal point', (tester) async {
        await loadAppFonts();

        await _pumpToolbarScaffold(
          tester,
          child: IosToolbar(
            arrowDirection: ArrowDirection.down,
            arrowFocalPoint: 70,
            children: const [
              IosMenuItem(label: 'Style'),
              IosMenuItem(label: 'Duplicate'),
              IosMenuItem(label: 'Cut'),
              IosMenuItem(label: 'Copy'),
              IosMenuItem(label: 'Paste')
            ],
          ),
        );

        await screenMatchesGolden(tester, 'ios-toolbar/pointing-down-left-focal-point');
      });

      testGoldens('with left focal point too low', (tester) async {
        await loadAppFonts();

        await _pumpToolbarScaffold(
          tester,
          child: IosToolbar(
            arrowDirection: ArrowDirection.down,
            arrowFocalPoint: 0,
            children: const [
              IosMenuItem(label: 'Style'),
              IosMenuItem(label: 'Duplicate'),
              IosMenuItem(label: 'Cut'),
              IosMenuItem(label: 'Copy'),
              IosMenuItem(label: 'Paste')
            ],
          ),
        );

        await screenMatchesGolden(tester, 'ios-toolbar/pointing-down-left-focal-point-too-low');
      });

      testGoldens('with right focal point', (tester) async {
        await loadAppFonts();

        await _pumpToolbarScaffold(
          tester,
          child: IosToolbar(
            arrowDirection: ArrowDirection.down,
            arrowFocalPoint: 200,
            children: const [
              IosMenuItem(label: 'Style'),
              IosMenuItem(label: 'Duplicate'),
              IosMenuItem(label: 'Cut'),
              IosMenuItem(label: 'Copy'),
              IosMenuItem(label: 'Paste')
            ],
          ),
        );

        await screenMatchesGolden(tester, 'ios-toolbar/pointing-down-right-focal-point');
      });

      testGoldens('with right focal point too big', (tester) async {
        await loadAppFonts();

        await _pumpToolbarScaffold(
          tester,
          child: IosToolbar(
            arrowDirection: ArrowDirection.down,
            arrowFocalPoint: 2000,
            children: const [
              IosMenuItem(label: 'Style'),
              IosMenuItem(label: 'Duplicate'),
              IosMenuItem(label: 'Cut'),
              IosMenuItem(label: 'Copy'),
              IosMenuItem(label: 'Paste')
            ],
          ),
        );

        await screenMatchesGolden(tester, 'ios-toolbar/pointing-down-right-focal-point-too-big');
      });
    });

    group('pagination', () {
      testGoldens('auto paginates to fit available space', (tester) async {
        await loadAppFonts();

        await _pumpToolbarScaffold(
          tester,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 300),
            child: IosToolbar(
              arrowDirection: ArrowDirection.down,
              children: const [
                IosMenuItem(label: 'Style'),
                IosMenuItem(label: 'Duplicate'),
                IosMenuItem(label: 'Cut'),
                IosMenuItem(label: 'Copy'),
                IosMenuItem(label: 'Paste'),
                IosMenuItem(label: 'Delete'),
                IosMenuItem(label: 'Long Thing 1'),
                IosMenuItem(label: 'Long Thing 2'),
                IosMenuItem(label: 'Long Thing 3'),
                IosMenuItem(label: 'Long Thing 4'),
              ],
            ),
          ),
        );

        await screenMatchesGolden(tester, 'ios-toolbar/auto-paginated-page1');

        // Tap the next page button.
        await tester.tap(find.widgetWithIcon(TextButton, Icons.arrow_right));
        await tester.pumpAndSettle();

        await screenMatchesGolden(tester, 'ios-toolbar/auto-paginated-page2');

        // Tap the next page button.
        await tester.tap(find.widgetWithIcon(TextButton, Icons.arrow_right));
        await tester.pumpAndSettle();

        await screenMatchesGolden(tester, 'ios-toolbar/auto-paginated-page3');

        // Tap the next page button.
        await tester.tap(find.widgetWithIcon(TextButton, Icons.arrow_right));
        await tester.pumpAndSettle();

        await screenMatchesGolden(tester, 'ios-toolbar/auto-paginated-page4');
      });

      testGoldens('respects manual pagination', (tester) async {
        await loadAppFonts();

        await _pumpToolbarScaffold(
          tester,
          child: IosToolbar.paginated(
            arrowDirection: ArrowDirection.down,
            pages: [
              MenuPage(
                items: const [
                  IosMenuItem(label: 'Style'),
                  IosMenuItem(label: 'Duplicate'),
                ],
              ),
              MenuPage(
                items: const [
                  IosMenuItem(label: 'Cut'),
                  IosMenuItem(label: 'Copy'),
                  IosMenuItem(label: 'Paste'),
                  IosMenuItem(label: 'Delete'),
                  IosMenuItem(label: 'Long Thing 1'),
                ],
              ),
            ],
          ),
        );

        await screenMatchesGolden(tester, 'ios-toolbar/manual-pagination-page1');

        // Tap the next page button.
        await tester.tap(find.widgetWithIcon(TextButton, Icons.arrow_right));
        await tester.pumpAndSettle();

        await screenMatchesGolden(tester, 'ios-toolbar/manual-pagination-page2');
      });
    });
  });

  group('iOS Popover Menu', () {
    group('pointing up', () {
      testGoldens('without focal point', (tester) async {
        await _pumpPopoverMenuTestApp(
          tester,
          arrowDirection: ArrowDirection.up,
        );

        await screenMatchesGolden(tester, 'ios-popover-menu/pointing-up');
      });

      testGoldens('with left focal point', (tester) async {
        await _pumpPopoverMenuTestApp(
          tester,
          arrowDirection: ArrowDirection.up,
          arrowFocalPoint: 40,
        );

        await screenMatchesGolden(tester, 'ios-popover-menu/pointing-up-left-focal-point');
      });

      testGoldens('with left focal point too low', (tester) async {
        await _pumpPopoverMenuTestApp(
          tester,
          arrowDirection: ArrowDirection.up,
          arrowFocalPoint: 0,
        );

        await screenMatchesGolden(tester, 'ios-popover-menu/pointing-up-left-focal-point-too-low');
      });

      testGoldens('with right focal point', (tester) async {
        await _pumpPopoverMenuTestApp(
          tester,
          arrowDirection: ArrowDirection.up,
          arrowFocalPoint: 200,
        );

        await screenMatchesGolden(tester, 'ios-popover-menu/pointing-up-right-focal-point');
      });

      testGoldens('with right focal point too big', (tester) async {
        await _pumpPopoverMenuTestApp(
          tester,
          arrowDirection: ArrowDirection.up,
          arrowFocalPoint: 2000,
        );

        await screenMatchesGolden(tester, 'ios-popover-menu/pointing-up-right-focal-point-too-big');
      });
    });

    group('pointing down', () {
      testGoldens('without focal point', (tester) async {
        await _pumpPopoverMenuTestApp(
          tester,
          arrowDirection: ArrowDirection.down,
        );

        await screenMatchesGolden(tester, 'ios-popover-menu/pointing-down');
      });

      testGoldens('with left focal point', (tester) async {
        await _pumpPopoverMenuTestApp(
          tester,
          arrowDirection: ArrowDirection.down,
          arrowFocalPoint: 40,
        );

        await screenMatchesGolden(tester, 'ios-popover-menu/pointing-down-left-focal-point');
      });

      testGoldens('with left focal point too low', (tester) async {
        await _pumpPopoverMenuTestApp(
          tester,
          arrowDirection: ArrowDirection.down,
          arrowFocalPoint: 0,
        );

        await screenMatchesGolden(tester, 'ios-popover-menu/pointing-down-left-focal-point-too-low');
      });

      testGoldens('with right focal point', (tester) async {
        await _pumpPopoverMenuTestApp(
          tester,
          arrowDirection: ArrowDirection.down,
          arrowFocalPoint: 200,
        );

        await screenMatchesGolden(tester, 'ios-popover-menu/pointing-down-right-focal-point');
      });

      testGoldens('with right focal point too big', (tester) async {
        await _pumpPopoverMenuTestApp(
          tester,
          arrowDirection: ArrowDirection.down,
          arrowFocalPoint: 2000,
        );

        await screenMatchesGolden(tester, 'ios-popover-menu/pointing-down-right-focal-point-too-big');
      });
    });

    group('pointing left', () {
      testGoldens('without focal point', (tester) async {
        await _pumpPopoverMenuTestApp(
          tester,
          arrowDirection: ArrowDirection.left,
        );

        await screenMatchesGolden(tester, 'ios-popover-menu/pointing-left');
      });

      testGoldens('with top focal point', (tester) async {
        await _pumpPopoverMenuTestApp(
          tester,
          arrowDirection: ArrowDirection.left,
          arrowFocalPoint: 40,
        );

        await screenMatchesGolden(tester, 'ios-popover-menu/pointing-left-top-focal-point');
      });

      testGoldens('with top focal point too low', (tester) async {
        await _pumpPopoverMenuTestApp(
          tester,
          arrowDirection: ArrowDirection.left,
          arrowFocalPoint: 0,
        );

        await screenMatchesGolden(tester, 'ios-popover-menu/pointing-left-top-focal-point-too-low');
      });

      testGoldens('with bottom focal point', (tester) async {
        await _pumpPopoverMenuTestApp(
          tester,
          arrowDirection: ArrowDirection.left,
          arrowFocalPoint: 100,
        );

        await screenMatchesGolden(tester, 'ios-popover-menu/pointing-left-bottom-focal-point');
      });

      testGoldens('with bottom focal point too big', (tester) async {
        await _pumpPopoverMenuTestApp(
          tester,
          arrowDirection: ArrowDirection.left,
          arrowFocalPoint: 2000,
        );

        await screenMatchesGolden(tester, 'ios-popover-menu/pointing-left-bottom-focal-point-too-big');
      });
    });

    group('pointing right', () {
      testGoldens('without focal point', (tester) async {
        await _pumpPopoverMenuTestApp(
          tester,
          arrowDirection: ArrowDirection.right,
        );

        await screenMatchesGolden(tester, 'ios-popover-menu/pointing-right');
      });

      testGoldens('with top focal point', (tester) async {
        await _pumpPopoverMenuTestApp(
          tester,
          arrowDirection: ArrowDirection.right,
          arrowFocalPoint: 40,
        );

        await screenMatchesGolden(tester, 'ios-popover-menu/pointing-right-top-focal-point');
      });

      testGoldens('with top focal point too low', (tester) async {
        await _pumpPopoverMenuTestApp(
          tester,
          arrowDirection: ArrowDirection.right,
          arrowFocalPoint: 0,
        );

        await screenMatchesGolden(tester, 'ios-popover-menu/pointing-right-top-focal-point-too-low');
      });

      testGoldens('with bottom focal point', (tester) async {
        await _pumpPopoverMenuTestApp(
          tester,
          arrowDirection: ArrowDirection.right,
          arrowFocalPoint: 100,
        );

        await screenMatchesGolden(tester, 'ios-popover-menu/pointing-right-bottom-focal-point');
      });

      testGoldens('with bottom focal point too big', (tester) async {
        await _pumpPopoverMenuTestApp(
          tester,
          arrowDirection: ArrowDirection.right,
          arrowFocalPoint: 2000,
        );

        await screenMatchesGolden(tester, 'ios-popover-menu/pointing-right-bottom-focal-point-too-big');
      });
    });
  });
}

Future<void> _pumpToolbarScaffold(WidgetTester tester, {required Widget child}) async {
  await tester.pumpWidget(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(child: child),
      ),
    ),
  );
}

Future<void> _pumpPopoverMenuTestApp(
  WidgetTester tester, {
  required ArrowDirection arrowDirection,
  double? arrowFocalPoint,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: IosPopoverMenu(
            arrowDirection: arrowDirection,
            arrowFocalPoint: arrowFocalPoint,
            child: const SizedBox(
              width: 254,
              height: 159,
              child: Center(
                child: Text(
                  'Popover Content',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
