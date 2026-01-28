import 'package:flutter/material.dart';

class LoadingButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final Color? color;
  final Color? disabledColor;
  final double? width;
  final double height;
  final double borderRadius;
  final bool isLoading;

  const LoadingButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.color,
    this.disabledColor,
    this.width,
    this.height = 50,
    this.borderRadius = 25,
    this.isLoading = false,
  });

  @override
  State<LoadingButton> createState() => _LoadingButtonState();
}

class _LoadingButtonState extends State<LoadingButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (!widget.isLoading && widget.onPressed != null) {
      _controller.forward();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (!widget.isLoading && widget.onPressed != null) {
      _controller.reverse();
    }
  }

  void _handleTapCancel() {
    if (!widget.isLoading && widget.onPressed != null) {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final buttonColor = widget.color ?? theme.primaryColor;
    final isDisabled = widget.onPressed == null || widget.isLoading;

    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onTap: widget.isLoading ? null : widget.onPressed,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: isDisabled
                ? (widget.disabledColor ?? buttonColor.withValues(alpha: 0.5))
                : buttonColor,
            borderRadius: BorderRadius.circular(widget.borderRadius),
            boxShadow: isDisabled
                ? []
                : [
                    BoxShadow(
                      color: buttonColor.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
          ),
          child: Center(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: widget.isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : widget.child,
            ),
          ),
        ),
      ),
    );
  }
}
