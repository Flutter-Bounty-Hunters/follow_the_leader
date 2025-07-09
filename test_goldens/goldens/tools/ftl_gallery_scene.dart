import 'package:flutter/widgets.dart';
import 'package:flutter_test_goldens/flutter_test_goldens.dart';

const ftlGridGoldenSceneLayout = GridGoldenSceneLayout(
  spacing: GridSpacing(around: EdgeInsets.all(48), between: 24),
  background: GoldenSceneBackground.color(Color(0xff01040d)),
  itemDecorator: _itemDecorator,
);

Widget _itemDecorator(
  BuildContext context,
  GoldenScreenshotMetadata metadata,
  Widget content,
) {
  return ColoredBox(
    color: const Color(0xff020817),
    child: IntrinsicWidth(
      child: PixelSnapColumn(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PixelSnapAlign(
            alignment: Alignment.topLeft,
            child: content,
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              metadata.description,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xff1e293b),
                fontFamily: TestFonts.openSans,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
