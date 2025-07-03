import 'dart:math';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

enum SheetState { min, half, max }

class CustomModalWindow extends StatefulWidget {
  const CustomModalWindow(
      {super.key, required this.url, required this.onClose});
  final String url;
  final VoidCallback onClose;

  @override
  State<CustomModalWindow> createState() => _CustomModalWindowState();
}

class _CustomModalWindowState extends State<CustomModalWindow> {
  late double maxHeight;
  late WebViewController controller;
  Orientation? _lastOrientation;

  SheetState sheetState = SheetState.half;
  double currentHeight = 0;

  final double minHeightRatio = 0.1;
  final double halfHeightRatio = 0.5;
  final double fullHeightRatio = 1;

  void _onDragUpdate(DragUpdateDetails details) {
    final minHeight = _getNonWebViewContentHeight();
    final newHeight = currentHeight - details.delta.dy;
    setState(() {
      currentHeight = newHeight.clamp(minHeight, maxHeight);
    });
  }

  void _onDragEnd(DragEndDetails details) {
    double min = _getNonWebViewContentHeight();
    double half = maxHeight * halfHeightRatio;
    double full = maxHeight * fullHeightRatio;

    if (currentHeight < (min + half) / 2) {
      sheetState = SheetState.min;
      currentHeight = min;
    } else if (currentHeight < (half + full) / 2) {
      sheetState = SheetState.half;
      currentHeight = half;
    } else {
      sheetState = SheetState.max;
      currentHeight = full;
    }

    setState(() {});
  }

  void _toggleCollapseOrClose() {
    if (sheetState == SheetState.min) {
      widget.onClose();
    } else {
      setState(() {
        sheetState = SheetState.min;
        currentHeight = _getNonWebViewContentHeight();
      });
    }
  }

  double _getNonWebViewContentHeight() {
    return 89;
  }

  @override
  void initState() {
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(widget.url));
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final currentOrientation = MediaQuery.of(context).orientation;

    if (_lastOrientation != currentOrientation) {
      _lastOrientation = currentOrientation;

      final double topStatusBarHeight = MediaQuery.of(context).viewPadding.top;
      final double bottomStatusBarHeight =
          MediaQuery.of(context).viewPadding.bottom;
      final double appBarHeight = kToolbarHeight;
      final double screenHeight = MediaQuery.of(context).size.height;

      maxHeight = screenHeight -
          topStatusBarHeight -
          appBarHeight -
          bottomStatusBarHeight -
          20;

      setState(() {
        switch (sheetState) {
          case SheetState.min:
            currentHeight = _getNonWebViewContentHeight();
            break;
          case SheetState.half:
            currentHeight = maxHeight * halfHeightRatio;
            break;
          case SheetState.max:
            currentHeight = maxHeight * fullHeightRatio;
            break;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
        children: [
          _buildBackgroundOverlay(),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            bottom: 0,
            left: 0,
            right: 0,
            height: currentHeight,
            child: Material(
              elevation: 8,
              color: Colors.white,
              child: SafeArea(
                top: false,
                child: Column(
                  children: [
                    _dragButton(),
                    _actionButton(),
                    const Divider(height: 1),
                    _buildWebView(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Expanded _buildWebView() {
    return Expanded(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SizedBox(
            width: constraints.maxWidth,
            height: constraints.maxHeight,
            child: WebViewWidget(
              key: ValueKey(
                  sheetState == SheetState.min ? sheetState : SheetState.max),
              controller: controller,
            ),
          );
        },
      ),
    );
  }

  Widget _buildBackgroundOverlay() {
    return GestureDetector(
      onTap: widget.onClose,
      child: Container(
        color: Colors.black54,
        width: double.infinity,
        height: double.infinity,
      ),
    );
  }

  GestureDetector _dragButton() {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onVerticalDragUpdate: _onDragUpdate,
      onVerticalDragEnd: _onDragEnd,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        child: const Icon(Icons.drag_handle),
      ),
    );
  }

  Row _actionButton() {
    return Row(
      children: [
        const SizedBox(width: 8),
        IconButton(
          icon: Icon(sheetState == SheetState.min
              ? Icons.close
              : Icons.expand_more_rounded),
          onPressed: _toggleCollapseOrClose,
        ),
        const Spacer(),
      ],
    );
  }
}
