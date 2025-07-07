import 'package:example/kitchen_sink/demo_kitchen_sink.dart';
import 'package:example/kitchen_sink/pin_and_follower_drag_arena.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class KitchenSinkMobileScaffold extends StatefulWidget {
  const KitchenSinkMobileScaffold({
    super.key,
    required this.controller,
    required this.child,
  });

  final KitchenSinkDemoController controller;

  final Widget child;

  @override
  State<KitchenSinkMobileScaffold> createState() => _KitchenSinkMobileScaffoldState();
}

class _KitchenSinkMobileScaffoldState extends State<KitchenSinkMobileScaffold> {
  final _textInputClient = _NoOpTextInputClient();
  TextInputConnection? _textInputConnection;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: widget.child,
        ),
        _buildBottomToolbar(),
      ],
    );
  }

  Widget _buildBottomToolbar() {
    return Container(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 8),
      color: Theme.of(context).cardColor.withValues(alpha: 0.8),
      child: SafeArea(
        top: false,
        child: Row(
          spacing: 4,
          children: [
            Expanded(
              child: _IconButton(
                icon: Icons.fit_screen,
                label: "Boundary",
                onPressed: () {
                  _showBoundarySelectionSheet(context, widget.controller);
                },
              ),
            ),
            Expanded(
              child: _IconButton(
                icon: Icons.vertical_align_center,
                label: "Alignment",
                onPressed: () {
                  _showAlignmentSelectionSheet(context, widget.controller);
                },
              ),
            ),
            Expanded(
              child: ListenableBuilder(
                  listenable: widget.controller.config,
                  builder: (context, child) {
                    return _IconButton(
                      icon: widget.controller.config.value.fadeBeyondBoundary //
                          ? Icons.visibility_off
                          : Icons.visibility,
                      label: "Visibility",
                      onPressed: () {
                        widget.controller.toggleFadeBeyondBoundary();
                      },
                    );
                  }),
            ),
            Expanded(
              child: _IconButton(
                icon: Icons.dashboard,
                label: "Menu Type",
                onPressed: () {
                  _showMenuTypeSelectionSheet(context, widget.controller);
                },
              ),
            ),
            Expanded(
              child: _IconButton(
                icon: _textInputConnection == null ? Icons.keyboard_rounded : Icons.keyboard_hide,
                label: _textInputConnection == null ? "Open" : "Close",
                onPressed: () {
                  if (_textInputConnection == null) {
                    _textInputConnection = TextInput.attach(_textInputClient, const TextInputConfiguration())..show();
                  } else {
                    _textInputConnection!.close();
                    _textInputConnection = null;
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IconButton extends StatelessWidget {
  const _IconButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(8),
      color: Theme.of(context).cardColor.withValues(alpha: 0.3),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Icon(icon),
              ),
              Center(
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 10),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<void> _showBoundarySelectionSheet(BuildContext context, KitchenSinkDemoController controller) async {
  await showModalBottomSheet(
    context: context,
    builder: (sheetContext) {
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _BottomSheetRadioTile(
              label: "Screen Boundary",
              isActive: controller.config.value.followerConstraints == FollowerConstraint.screen,
              onPressed: () {
                Navigator.of(context).pop();
                controller.onScreenBoundsTap();
              },
            ),
            _BottomSheetRadioTile(
              label: "Keyboard & Screen",
              isActive: controller.config.value.followerConstraints == FollowerConstraint.keyboardAndScreen,
              onPressed: () {
                Navigator.of(context).pop();
                controller.onKeyboardAndScreenBoundsTap();
              },
            ),
            _BottomSheetRadioTile(
              label: "Keyboard Only",
              isActive: controller.config.value.followerConstraints == FollowerConstraint.keyboardOnly,
              onPressed: () {
                Navigator.of(context).pop();
                controller.onKeyboardOnlyBoundsTap();
              },
            ),
            _BottomSheetRadioTile(
              label: "Safe Area Boundary",
              isActive: controller.config.value.followerConstraints == FollowerConstraint.safeArea,
              onPressed: () {
                Navigator.of(context).pop();
                controller.onSafeAreaBoundsTap();
              },
            ),
            _BottomSheetRadioTile(
              label: "Widget Boundary",
              isActive: controller.config.value.followerConstraints == FollowerConstraint.widget,
              onPressed: () {
                Navigator.of(context).pop();
                controller.onWidgetBoundsTap();
              },
            ),
            _BottomSheetRadioTile(
              label: "No Boundary",
              isActive: controller.config.value.followerConstraints == FollowerConstraint.none,
              onPressed: () {
                Navigator.of(context).pop();
                controller.onNoLimitsTap();
              },
            ),
            const SizedBox(height: 48),
          ],
        ),
      );
    },
  );
}

class _BottomSheetRadioTile extends StatelessWidget {
  const _BottomSheetRadioTile({
    required this.label,
    this.isActive = false,
    required this.onPressed,
  });

  final String label;
  final bool isActive;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(label),
      leading: isActive
          ? const Icon(
              Icons.check_circle,
              color: Colors.green,
            )
          : const Icon(
              Icons.circle_outlined,
              color: Colors.grey,
            ),
      onTap: onPressed,
    );
  }
}

Future<void> _showAlignmentSelectionSheet(BuildContext context, KitchenSinkDemoController controller) async {
  await showModalBottomSheet(
    context: context,
    builder: (sheetContext) {
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text("Top"),
              onTap: () {
                Navigator.of(context).pop();
                controller.configureToolbarAligner(FollowerDirection.up);
              },
            ),
            ListTile(
              title: const Text("Bottom"),
              onTap: () {
                Navigator.of(context).pop();
                controller.configureToolbarAligner(FollowerDirection.down);
              },
            ),
            ListTile(
              title: const Text("Left"),
              onTap: () {
                Navigator.of(context).pop();
                controller.configureToolbarAligner(FollowerDirection.left);
              },
            ),
            ListTile(
              title: const Text("Right"),
              onTap: () {
                Navigator.of(context).pop();
                controller.configureToolbarAligner(FollowerDirection.right);
              },
            ),
            ListTile(
              title: const Text("Automatic"),
              onTap: () {
                Navigator.of(context).pop();
                controller.configureToolbarAligner(FollowerDirection.automatic);
              },
            ),
            ListTile(
              title: const Text("Widget Boundary"),
              onTap: () {
                Navigator.of(context).pop();
                controller.onWidgetBoundsTap();
              },
            ),
          ],
        ),
      );
    },
  );
}

Future<void> _showMenuTypeSelectionSheet(BuildContext context, KitchenSinkDemoController controller) async {
  await showModalBottomSheet(
    context: context,
    builder: (sheetContext) {
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text("Small Box"),
              onTap: () {
                Navigator.of(context).pop();
                controller.useGenericMenu();
              },
            ),
            ListTile(
              title: const Text("iOS Toolbar"),
              onTap: () {
                Navigator.of(context).pop();
                controller.useIOSToolbar();
              },
            ),
            ListTile(
              title: const Text("iOS Popover"),
              onTap: () {
                Navigator.of(context).pop();
                controller.useIOSPopover();
              },
            ),
            ListTile(
              title: const Text("Android Spellcheck"),
              onTap: () {
                Navigator.of(context).pop();
                controller.useAndroidSpellcheck();
              },
            ),
          ],
        ),
      );
    },
  );
}

class _NoOpTextInputClient implements TextInputClient {
  @override
  void connectionClosed() {}

  @override
  AutofillScope? get currentAutofillScope => throw UnimplementedError();

  @override
  TextEditingValue? get currentTextEditingValue => const TextEditingValue();

  @override
  void didChangeInputControl(TextInputControl? oldControl, TextInputControl? newControl) {}

  @override
  void insertContent(KeyboardInsertedContent content) {}

  @override
  void insertTextPlaceholder(Size size) {}

  @override
  void performAction(TextInputAction action) {}

  @override
  void performPrivateCommand(String action, Map<String, dynamic> data) {}

  @override
  void performSelector(String selectorName) {}

  @override
  void removeTextPlaceholder() {}

  @override
  void showAutocorrectionPromptRect(int start, int end) {}

  @override
  void showToolbar() {}

  @override
  void updateEditingValue(TextEditingValue value) {}

  @override
  void updateFloatingCursor(RawFloatingCursorPoint point) {}
}
