import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

class CustomTitleBar extends StatefulWidget {
  final String? title;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final bool showTitle;

  const CustomTitleBar({
    super.key,
    this.title,
    this.backgroundColor,
    this.foregroundColor,
    this.showTitle = true,
  });

  @override
  State<CustomTitleBar> createState() => _CustomTitleBarState();
}

class _CustomTitleBarState extends State<CustomTitleBar> with WindowListener {
  bool _isMaximized = false;

  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
    _init();
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
  }

  void _init() async {
    final isMaximized = await windowManager.isMaximized();
    setState(() {
      _isMaximized = isMaximized;
    });
  }

  @override
  void onWindowMaximize() {
    setState(() {
      _isMaximized = true;
    });
  }

  @override
  void onWindowUnmaximize() {
    setState(() {
      _isMaximized = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bgColor = widget.backgroundColor ?? theme.colorScheme.surface;
    final fgColor = widget.foregroundColor ?? theme.colorScheme.onSurface;
    final neutralHoverColor = Color.alphaBlend(
      fgColor.withOpacity(0.08),
      bgColor,
    );

    return Container(
      height: 40,
      color: bgColor,
      child: Row(
        children: [
          Expanded(
            child: DragToMoveArea(
              child: Container(
                padding: const EdgeInsets.only(left: 16),
                alignment: Alignment.centerLeft,
                child: widget.showTitle && widget.title != null
                    ? Text(
                        widget.title!,
                        style: TextStyle(
                          color: fgColor,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      )
                    : null,
              ),
            ),
          ),
          _WindowCaptionButton(
            icon: Icons.remove,
            onPressed: () => windowManager.minimize(),
            foregroundColor: fgColor,
            hoverColor: neutralHoverColor,
          ),
          _WindowCaptionButton(
            icon: _isMaximized ? Icons.filter_none : Icons.crop_square,
            onPressed: () async {
              if (_isMaximized) {
                await windowManager.unmaximize();
              } else {
                await windowManager.maximize();
              }
            },
            foregroundColor: fgColor,
            hoverColor: neutralHoverColor,
          ),
          _WindowCaptionButton(
            icon: Icons.close,
            onPressed: () => windowManager.close(),
            foregroundColor: fgColor,
            hoverColor: Colors.red,
            hoverForegroundColor: Colors.white,
          ),
        ],
      ),
    );
  }
}

class _WindowCaptionButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final Color foregroundColor;
  final Color hoverColor;
  final Color? hoverForegroundColor;

  const _WindowCaptionButton({
    required this.icon,
    required this.onPressed,
    required this.foregroundColor,
    required this.hoverColor,
    this.hoverForegroundColor,
  });

  @override
  State<_WindowCaptionButton> createState() => _WindowCaptionButtonState();
}

class _WindowCaptionButtonState extends State<_WindowCaptionButton> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    final iconColor = _isHovering && widget.hoverForegroundColor != null
        ? widget.hoverForegroundColor!
        : widget.foregroundColor;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onPressed,
        child: SizedBox(
          width: 46,
          height: 40,
          child: Stack(
            fit: StackFit.expand,
            children: [
              AnimatedOpacity(
                duration: const Duration(milliseconds: 150),
                curve: Curves.easeInOut,
                opacity: _isHovering ? 1 : 0,
                child: ColoredBox(color: widget.hoverColor),
              ),
              Center(
                child: Icon(widget.icon, color: iconColor, size: 18),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
