import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '_ios_popover_menu.dart';

class IosToolbar extends StatelessWidget {
  /// Creates a toolbar which auto paginates its children.
  const IosToolbar({
    Key? key,
    this.radius = const Radius.circular(12),
    this.arrowWidth = 18.0,
    this.arrowLength = 12.0,
    required this.arrowDirection,
    this.padding,
    this.backgroundColor = const Color(0xFF333333),
    this.arrowFocalPoint,
    required this.children,
  })  : pages = null,
        assert(arrowDirection == ArrowDirection.up || arrowDirection == ArrowDirection.down),
        super(key: key);

  /// Creates a toolbar which is paginated using [pages].
  const IosToolbar.paginated({
    Key? key,
    this.radius = const Radius.circular(12),
    this.arrowWidth = 18.0,
    this.arrowLength = 12.0,
    required this.arrowDirection,
    this.padding,
    this.backgroundColor = const Color(0xFF333333),
    this.arrowFocalPoint,
    required this.pages,
  })  : children = null,
        super(key: key);

  /// Radius of the menu decoration.
  final Radius radius;

  /// Width of the arrow.
  final double arrowWidth;

  /// Distance from the base to the end of the arrow.
  final double arrowLength;

  /// Direction where the arrow points to.
  final ArrowDirection arrowDirection;

  /// Center point of the arrow.
  final double? arrowFocalPoint;

  /// Padding around the menu content.
  final EdgeInsets? padding;

  /// Background color of the toolbar.
  final Color backgroundColor;

  /// Pages of menu items.
  final List<MenuPage>? pages;

  /// List of menu items.
  ///
  /// The pages are automatically computed.
  final List<Widget>? children;

  @override
  Widget build(BuildContext context) {
    return IosPopoverMenu(
      radius: radius,
      arrowWidth: arrowWidth,
      arrowLength: arrowLength,
      arrowDirection: arrowDirection,
      backgroundColor: backgroundColor,
      arrowFocalPoint: arrowFocalPoint,
      child: _IosToolbarContent(
        pages: pages,
        children: children,
      ),
    );
  }
}

/// A page of menu items.
class MenuPage {
  MenuPage({required this.items});
  final List<Widget> items;
}

/// A popover menu which displays [pages] of items or automatically
/// paginates its [children] based on the available size.
///
/// Buttons to access the next/previous page are included by default.
///
/// Either [pages] of [children] must be non-null.
class _IosToolbarContent extends StatefulWidget {
  const _IosToolbarContent({
    Key? key,
    this.pages,
    this.children,
  })  : assert(pages != null || children != null),
        assert(pages == null || children == null),
        super(key: key);

  /// List of items to be auto-paginated.
  final List<Widget>? children;

  /// List of pages containing the menu items.
  final List<MenuPage>? pages;

  @override
  State<_IosToolbarContent> createState() => _IosToolbarContentState();
}

class _IosToolbarContentState extends State<_IosToolbarContent> {
  final _MenuPageController _controller = _MenuPageController();

  /// Creates the button which points to the previous page.
  Widget _buildPreviousPageButton() {
    return TextButton(
      style: TextButton.styleFrom(
        padding: const EdgeInsets.all(0),
        minimumSize: const Size(30, 0),
      ),
      onPressed: _controller.goToPrevious,
      child: Icon(
        Icons.arrow_left,
        color: _controller.isFirstPage ? Colors.grey : Colors.white,
      ),
    );
  }

  /// Creates the button which points to the next page.
  Widget _buildNextPageButton() {
    return TextButton(
      style: TextButton.styleFrom(
        padding: const EdgeInsets.all(0),
        minimumSize: const Size(30, 0),
      ),
      onPressed: _controller.goToNext,
      child: Icon(
        Icons.arrow_right,
        color: _controller.isLastPage ? Colors.grey : Colors.white,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return _IosPaginatedMenu(
          controller: _controller,
          previousButton: _buildPreviousPageButton(),
          nextButton: _buildNextPageButton(),
          pages: widget.pages,
          children: widget.children,
        );
      },
    );
  }
}

/// Controls a paginated menu.
class _MenuPageController extends ChangeNotifier {
  int _currentPage = 1;
  int _maxPages = 1;

  /// Indicates if the current page is the last page.
  bool get isLastPage => _currentPage == _maxPages;

  /// Indicates if the current page is the first page.
  bool get isFirstPage => _currentPage == 1;

  /// Current page in the menu.
  int get currentPage => _currentPage;
  set currentPage(int value) {
    if (value != _currentPage) {
      _currentPage = value;
      notifyListeners();
    }
  }

  /// Number of pages in the menu.
  int get pageCount => _maxPages;
  set pageCount(int value) {
    if (value != _maxPages) {
      _maxPages = value;
      notifyListeners();
    }
  }

  /// Advances to the next page, notifying listeners.
  void goToNext() {
    if (currentPage < pageCount) {
      currentPage++;
    }
  }

  /// Goes back to the previous page, notifying listeners.
  void goToPrevious() {
    if (currentPage > 1) {
      currentPage--;
    }
  }
}

/// Displays a list of menu itens.
///
/// Use [pages] to manually control the items in each page.
///
/// Use [children] to let this widget auto-paginate based on the available space.
class _IosPaginatedMenu extends MultiChildRenderObjectWidget {
  _IosPaginatedMenu({
    required this.controller,
    required Widget previousButton,
    required Widget nextButton,
    List<Widget>? children,
    List<MenuPage>? pages,
  })  : _pages = pages,
        assert(children != null || pages != null),
        assert(children == null || pages == null),
        super(children: [
          previousButton,
          if (children != null) ...children,
          if (pages != null) ...pages.map((e) => e.items).expand((e) => e),
          nextButton,
        ]);

  final List<MenuPage>? _pages;

  /// Indicates if this widget must compute the pages.
  bool get _autoPaginated => _pages == null;

  final _MenuPageController controller;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderIosPagedMenu(
      controller: controller,
      autoPaginated: _autoPaginated,
      pages: _menuPagesToPageInfo(),
    );
  }

  @override
  void updateRenderObject(BuildContext context, covariant _RenderIosPagedMenu renderObject) {
    renderObject
      ..controller = controller
      ..autoPaginated = _autoPaginated
      ..pages = _menuPagesToPageInfo();
  }

  List<_MenuPageInfo>? _menuPagesToPageInfo() {
    if (_pages == null) {
      return null;
    }

    final pageInfoList = <_MenuPageInfo>[];

    // Starts from 1 because index 0 is the previous button.
    int currentIndex = 1;
    for (final page in _pages!) {
      int endingIndex = currentIndex + page.items.length;
      pageInfoList.add(
        _MenuPageInfo(
          startingIndex: currentIndex,
          endingIndex: endingIndex,
        ),
      );
      currentIndex = endingIndex;
    }

    return pageInfoList;
  }
}

class _IosPagerParentData extends ContainerBoxParentData<RenderBox> {}

/// Render a paginated menu.
class _RenderIosPagedMenu extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, _IosPagerParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, _IosPagerParentData> {
  _RenderIosPagedMenu({
    required _MenuPageController controller,
    List<_MenuPageInfo>? pages,
    bool autoPaginated = true,
  })  : _controller = controller,
        _pages = pages,
        _autoPaginated = autoPaginated;

  /// [Paint] used to paint the lines between items.
  final _linePaint = Paint()..color = const Color(0xFF555555);

  _MenuPageController _controller;
  _MenuPageController get controller => _controller;
  set controller(_MenuPageController value) {
    if (_controller != value) {
      _controller = value;
      markNeedsLayout();
    }
  }

  bool _autoPaginated;
  bool get autoPaginated => _autoPaginated;
  set autoPaginated(bool value) {
    if (_autoPaginated != value) {
      _autoPaginated = value;
      markNeedsLayout();
    }
  }

  List<_MenuPageInfo>? _pages;
  List<_MenuPageInfo>? get pages => _pages;
  set pages(List<_MenuPageInfo>? value) {
    if (_pages != value) {
      _pages = value;
      markNeedsLayout();
    }
  }

  @override
  void attach(covariant PipelineOwner owner) {
    super.attach(owner);
    _controller.addListener(markNeedsLayout);
  }

  @override
  void detach() {
    _controller.removeListener(markNeedsLayout);
    super.detach();
  }

  @override
  void setupParentData(covariant RenderObject child) {
    if (child.parentData is! _IosPagerParentData) {
      child.parentData = _IosPagerParentData();
    }
  }

  @override
  void performLayout() {
    if (autoPaginated) {
      _computePages();
    }
    _scheduleUpdateControllerPageCount();

    final hasMultiplePages = _pages!.length > 1;

    // Children include the navigation buttons.
    final children = getChildrenAsList();

    double height = 0;
    double width = 0;

    // Layout all the children and get the maxHeight.
    for (int i = 0; i < children.length; i++) {
      final child = children[i];
      child.layout(constraints, parentUsesSize: true);
      height = max(height, child.size.height);
    }

    // Page to be displayed.
    final currentPage = _pages![_controller.currentPage - 1];

    if (hasMultiplePages) {
      // Computes previous button position.
      final previousButton = children.first;
      final previousButtonParentData = previousButton.parentData as _IosPagerParentData;
      previousButtonParentData.offset = Offset(width, (height - previousButton.size.height) / 2);

      // Update current width.
      width += previousButton.size.width;
    }

    // Set offset of children which belong to current page.
    for (int i = currentPage.startingIndex; i < currentPage.endingIndex; i++) {
      final child = children[i];
      final childSize = child.size;
      final childParentData = child.parentData as _IosPagerParentData;
      childParentData.offset = Offset(width, (height - childSize.height) / 2);

      // Update current width.
      width += childSize.width;
    }

    if (hasMultiplePages) {
      // Computes next button position.
      final nextButton = children.last;
      final nextButtonButtonParentData = nextButton.parentData as _IosPagerParentData;
      nextButtonButtonParentData.offset = Offset(width, (height - nextButton.size.height) / 2);

      // Update current width.
      width += nextButton.size.width;
    }

    size = Size(width, height);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final children = getChildrenAsList();
    final page = _pages![_controller.currentPage - 1];

    late Offset childOffset;
    final hasMultiplePages = (_pages?.length ?? 0) > 1;

    if (hasMultiplePages) {
      // Paint the previous page button.
      final previousButton = children.first;
      childOffset = (previousButton.parentData as _IosPagerParentData).offset;
      context.paintChild(previousButton, childOffset + offset);
    }

    for (int i = page.startingIndex; i < page.endingIndex; i++) {
      final child = children[i];
      childOffset = (child.parentData as _IosPagerParentData).offset;

      if (hasMultiplePages || i > page.startingIndex) {
        // Paint the separator.
        context.canvas.drawLine(
          offset + Offset(childOffset.dx, 0),
          offset + Offset(childOffset.dx, size.height),
          _linePaint,
        );
      }

      // Paint the child content.
      context.paintChild(child, childOffset + offset);
    }

    if (hasMultiplePages) {
      final nextButton = children.last;
      childOffset = (nextButton.parentData as _IosPagerParentData).offset;

      // Paint the separator.
      context.canvas.drawLine(
        offset + Offset(childOffset.dx, 0),
        offset + Offset(childOffset.dx, size.height),
        _linePaint,
      );

      // Paint the next page button.
      context.paintChild(nextButton, childOffset + offset);
    }
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    final page = _pages![_controller.currentPage - 1];

    final children = getChildrenAsList();
    final previousButton = children.first;
    final nextButton = children.last;

    // Check if we hit the previous button.
    if (_hitTestChild(result, position: position, child: previousButton)) {
      return true;
    }

    // Check if we hit the next button.
    if (_hitTestChild(result, position: position, child: nextButton)) {
      return true;
    }

    // Hit test the items on the current page.
    for (int i = page.startingIndex; i < page.endingIndex; i++) {
      final child = children[i];
      final isHit = _hitTestChild(
        result,
        position: position,
        child: child,
      );
      if (isHit) {
        return true;
      }
    }

    return false;
  }

  bool _hitTestChild(BoxHitTestResult result, {required Offset position, required RenderBox child}) {
    final childParentData = child.parentData! as _IosPagerParentData;

    return result.addWithPaintOffset(
      offset: childParentData.offset,
      position: position,
      hitTest: (BoxHitTestResult result, Offset transformed) {
        assert(transformed == position - childParentData.offset);
        return child.hitTest(result, position: transformed);
      },
    );
  }

  /// Computes all the pages.
  void _computePages() {
    final pages = <_MenuPageInfo>[];
    int currentPageStartingIndex = 1;

    // Children includes navigation buttons.
    final children = getChildrenAsList();
    final previousButton = children.first;
    final nextButton = children.last;

    final previousButtonSize = previousButton.getDryLayout(constraints);
    final nextButtonSize = nextButton.getDryLayout(constraints);

    double currentPageWidth = 0.0;
    double buttonsWidth = previousButtonSize.width + nextButtonSize.width;

    for (int i = 1; i < children.length; i++) {
      final child = children[i];
      final isLastChild = i == children.length - 1;

      final childSize = child.getDryLayout(constraints);

      final requiredWidthWithoutNavigationButtons = currentPageWidth + childSize.width;
      final requiredWidthWithNavigationButtons = requiredWidthWithoutNavigationButtons + buttonsWidth;

      if ((requiredWidthWithNavigationButtons > constraints.maxWidth) &&
          !(requiredWidthWithoutNavigationButtons <= constraints.maxWidth && isLastChild && pages.length == 1)) {
        pages.add(
          _MenuPageInfo(
            startingIndex: currentPageStartingIndex,
            endingIndex: i,
          ),
        );

        currentPageStartingIndex = i;
        currentPageWidth = 0.0;
      }

      currentPageWidth += childSize.width;
    }

    pages.add(
      _MenuPageInfo(
        startingIndex: currentPageStartingIndex,
        endingIndex: childCount - 1,
      ),
    );

    _pages = pages;
  }

  void _scheduleUpdateControllerPageCount() {
    // Updates the page count on the controller,
    // so the buttons can be rendered accordingly.
    WidgetsBinding.instance.addPostFrameCallback(
      (d) => _updateControllerPageCount(),
    );
  }

  void _updateControllerPageCount() {
    // Temporarily remove the listener so we don't layout again.
    _controller.removeListener(markNeedsLayout);
    try {
      _controller.pageCount = _pages!.length;
    } finally {
      _controller.addListener(markNeedsLayout);
    }
  }
}

/// Represent the start and end indexes of a page.
class _MenuPageInfo {
  _MenuPageInfo({
    required this.startingIndex,
    required this.endingIndex,
  });

  /// Index of the first item in the page, inclusive.
  final int startingIndex;

  /// Index of the first item after the current page.
  final int endingIndex;
}
