import 'package:flutter/material.dart';

class HorizontalBoardScroll extends StatefulWidget {
  const HorizontalBoardScroll({
    super.key,
    required this.padding,
    required this.child,
  });

  final EdgeInsets padding;
  final Widget child;

  @override
  State<HorizontalBoardScroll> createState() => _HorizontalBoardScrollState();
}

class _HorizontalBoardScrollState extends State<HorizontalBoardScroll> {
  final ScrollController _controller = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      controller: _controller,
      thumbVisibility: true,
      trackVisibility: true,
      interactive: true,
      child: SingleChildScrollView(
        controller: _controller,
        scrollDirection: Axis.horizontal,
        padding: widget.padding,
        child: widget.child,
      ),
    );
  }
}
