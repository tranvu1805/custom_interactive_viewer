import 'package:custom_interactive_viewer/src/controller/interactive_controller.dart';
import 'package:custom_interactive_viewer/src/handlers/gesture_handler.dart';
import 'package:custom_interactive_viewer/src/handlers/keyboard_handler.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';

/// A customizable widget for viewing content with interactive transformations.
///
/// This widget allows for panning, zooming, and optionally rotating its child.
/// It provides greater control and customization than Flutter's built-in
/// [InteractiveViewer].
class CustomInteractiveViewer extends StatefulWidget {
  /// The child widget to display.
  final Widget child;

  /// The controller that manages the transformation state.
  final CustomInteractiveViewerController? controller;

  /// The size of the content being displayed. Used for centering and constraints.
  final Size? contentSize;

  /// The minimum scale factor.
  final double minScale;

  /// The maximum scale factor.
  final double maxScale;

  /// Whether to enable zooming/scaling. When false, all zoom operations are disabled.
  final bool enableZoom;

  /// Whether to enable scaling with Ctrl+scroll.
  final bool enableCtrlScrollToScale;

  /// Whether to enable rotation of the content.
  final bool enableRotation;

  /// Whether to constrain the content to the widget bounds.
  final bool constrainBounds;

  /// Whether to enable zooming on double tap.
  final bool enableDoubleTapZoom;

  /// The factor by which to zoom on double tap.
  final double doubleTapZoomFactor;

  /// Whether to enable keyboard controls.
  final bool enableKeyboardControls;

  /// The distance to pan when using keyboard arrow keys.
  final double keyboardPanDistance;

  /// The factor by which to zoom when using keyboard zoom keys.
  final double keyboardZoomFactor;

  /// Whether to enable key repeat for keyboard controls.
  final bool enableKeyRepeat;

  /// The delay before key repeat begins.
  final Duration keyRepeatInitialDelay;

  /// The interval between repeated key actions.
  final Duration keyRepeatInterval;

  /// Whether to animate transitions when using keyboard controls.
  final bool animateKeyboardTransitions;

  /// Duration of keyboard transition animations.
  final Duration keyboardAnimationDuration;

  /// Animation curve for keyboard transitions.
  final Curve keyboardAnimationCurve;

  /// Whether to enable fling behavior for smooth scrolling after a quick pan gesture.
  final bool enableFling;

  /// External focus node for keyboard input.
  /// If provided, this focus node will be used for keyboard events.
  /// If null, an internal focus node will be created.
  final FocusNode? focusNode;

  /// Whether to invert the direction of arrow keys.
  /// If true, pressing left moves view left.
  /// If false, pressing left moves content right.
  final bool invertArrowKeyDirection;

  /// Creates a [CustomInteractiveViewer].
  ///
  /// The [child] and [controller] parameters are required.
  const CustomInteractiveViewer({
    super.key,
    required this.child,
    required this.controller,
    this.contentSize,
    this.minScale = 0.5,
    this.maxScale = 4,
    this.enableZoom = true,
    this.enableRotation = false,
    this.constrainBounds = false,

    /// Enabling this may cause a delay in any gesture detector in the child
    this.enableDoubleTapZoom = false,
    this.doubleTapZoomFactor = 2.0,
    this.enableKeyboardControls = true,
    this.keyboardPanDistance = 20.0,
    this.keyboardZoomFactor = 1.1,
    this.enableKeyRepeat = true,
    this.keyRepeatInitialDelay = const Duration(milliseconds: 500),
    this.keyRepeatInterval = const Duration(milliseconds: 50),
    this.animateKeyboardTransitions = true,
    this.keyboardAnimationDuration = const Duration(milliseconds: 200),
    this.keyboardAnimationCurve = Curves.easeOutCubic,
    this.enableCtrlScrollToScale = true,
    this.enableFling = true,
    this.focusNode,
    this.invertArrowKeyDirection = false,
  });

  @override
  CustomInteractiveViewerState createState() => CustomInteractiveViewerState();
}

/// The state for a [CustomInteractiveViewer].
class CustomInteractiveViewerState extends State<CustomInteractiveViewer>
    with TickerProviderStateMixin {

  late final CustomInteractiveViewerController controller =
      widget.controller ?? CustomInteractiveViewerController(vsync: this);
  
  /// The key for the viewport.
  final GlobalKey _viewportKey = GlobalKey();

  /// Focus node for keyboard input.
  late final FocusNode _focusNode;

  /// Handles gesture interactions.
  late GestureHandler _gestureHandler;

  /// Handles keyboard interactions.
  late KeyboardHandler _keyboardHandler;
  @override
  void initState() {
    super.initState();
    // Initialize the focus node: use the provided one or create our own
    _focusNode = widget.focusNode ?? FocusNode();

    controller.vsync = this;
    controller.addListener(_onControllerUpdate);

    // Register size getters with the controller
    _registerControllerSizeGetters();

    _initializeHandlers();

    // Add listener for control key state
    HardwareKeyboard.instance.addHandler(_handleHardwareKeyChange);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _centerContentIfNeeded();
    });
  }

  /// Register viewport and content size getters with the controller
  void _registerControllerSizeGetters() {
    // Register viewport size getter
    controller.viewportSizeGetter = () {
      final RenderBox? box =
          _viewportKey.currentContext?.findRenderObject() as RenderBox?;
      return box?.size;
    };

    // Register content size getter if available
    if (widget.contentSize != null) {
      controller.contentSizeGetter = () => widget.contentSize;
    }
  }

  /// Initialize gesture and keyboard handlers
  void _initializeHandlers() {
    _gestureHandler = GestureHandler(
      controller: controller,
      enableRotation: widget.enableRotation,
      constrainBounds: widget.constrainBounds,
      enableDoubleTapZoom: widget.enableZoom && widget.enableDoubleTapZoom,
      doubleTapZoomFactor: widget.doubleTapZoomFactor,
      contentSize: widget.contentSize,
      viewportKey: _viewportKey,
      enableCtrlScrollToScale:
          widget.enableZoom && widget.enableCtrlScrollToScale,
      minScale: widget.minScale,
      maxScale: widget.maxScale,
      enableFling: widget.enableFling,
      enableZoom: widget.enableZoom,
    );
    _keyboardHandler = KeyboardHandler(
      controller: controller,
      keyboardPanDistance: widget.keyboardPanDistance,
      keyboardZoomFactor: widget.keyboardZoomFactor,
      enableKeyboardControls: widget.enableKeyboardControls,
      enableKeyboardZoom: widget.enableZoom && widget.enableKeyboardControls,
      enableKeyRepeat: widget.enableKeyRepeat,
      keyRepeatInitialDelay: widget.keyRepeatInitialDelay,
      keyRepeatInterval: widget.keyRepeatInterval,
      animateKeyboardTransitions: widget.animateKeyboardTransitions,
      keyboardAnimationDuration: widget.keyboardAnimationDuration,
      keyboardAnimationCurve: widget.keyboardAnimationCurve,
      focusNode: _focusNode,
      constrainBounds: widget.constrainBounds,
      contentSize: widget.contentSize,
      viewportKey: _viewportKey,
      minScale: widget.minScale,
      maxScale: widget.maxScale,
      invertArrowKeyDirection: widget.invertArrowKeyDirection,
    );
  }

  /// Center the content if a content size is provided
  void _centerContentIfNeeded() {
    if (widget.contentSize != null) {
      centerContent();
    }
  }

  @override
  void didUpdateWidget(CustomInteractiveViewer oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Update content size getter if content size changes
    if (oldWidget.contentSize != widget.contentSize) {
      if (widget.contentSize != null) {
        controller.contentSizeGetter = () => widget.contentSize!;
      } else {
        controller.contentSizeGetter = null;
      }
    }

    // Reinitialize handlers if needed properties change
    if (oldWidget.enableRotation != widget.enableRotation ||
        oldWidget.constrainBounds != widget.constrainBounds ||
        oldWidget.enableDoubleTapZoom != widget.enableDoubleTapZoom ||
        oldWidget.doubleTapZoomFactor != widget.doubleTapZoomFactor ||
        oldWidget.enableCtrlScrollToScale != widget.enableCtrlScrollToScale ||
        oldWidget.enableFling != widget.enableFling ||
        oldWidget.minScale != widget.minScale ||
        oldWidget.maxScale != widget.maxScale ||
        oldWidget.keyboardPanDistance != widget.keyboardPanDistance ||
        oldWidget.keyboardZoomFactor != widget.keyboardZoomFactor ||
        oldWidget.enableKeyboardControls != widget.enableKeyboardControls ||
        oldWidget.enableKeyRepeat != widget.enableKeyRepeat ||
        oldWidget.keyRepeatInitialDelay != widget.keyRepeatInitialDelay ||
        oldWidget.keyRepeatInterval != widget.keyRepeatInterval) {
      _initializeHandlers();
    }
  }

  @override
  void dispose() {
    controller.removeListener(_onControllerUpdate);
    _focusNode.dispose();
    _keyboardHandler.dispose();
    if(widget.controller == null) {
      controller.dispose();
    }

    HardwareKeyboard.instance.removeHandler(_handleHardwareKeyChange);
    // Remove key listener

    super.dispose();
  }

  /// Handle hardware key changes to track ctrl key state
  bool _handleHardwareKeyChange(KeyEvent event) {
    if (event is KeyDownEvent &&
        (event.logicalKey == LogicalKeyboardKey.controlLeft ||
            event.logicalKey == LogicalKeyboardKey.controlRight)) {
      setState(() {
        _gestureHandler.isCtrlPressed = true;
      });
    } else if (event is KeyUpEvent &&
        (event.logicalKey == LogicalKeyboardKey.controlLeft ||
            event.logicalKey == LogicalKeyboardKey.controlRight)) {
      setState(() {
        _gestureHandler.isCtrlPressed = false;
      });
    }
    return false; // Allow other handlers to process this event
  }

  /// Update the UI when the controller state changes
  void _onControllerUpdate() => setState(() {});

  /// Center the content in the viewport
  Future<void> centerContent({
    bool animate = true,
    Duration duration = const Duration(milliseconds: 300),
    Curve curve = Curves.easeInOut,
  }) async {
    if (widget.contentSize == null) return;
    final RenderBox? box =
        _viewportKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return;

    final Size viewportSize = box.size;

    await controller.center(
      contentSize: widget.contentSize,
      viewportSize: viewportSize,
      animate: animate,
      duration: duration,
      curve: curve,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FocusTraversalGroup(
      policy: _NoArrowTraversalPolicy(),
      child: KeyboardListener(
        focusNode: _focusNode,
        onKeyEvent: _keyboardHandler.handleKeyEvent,
        child: Listener(
          onPointerSignal: (PointerSignalEvent event) {
            if (event is PointerScrollEvent) {
              _gestureHandler.handlePointerScroll(event, context);
            }
          },
          child: GestureDetector(
            onScaleStart: _gestureHandler.handleScaleStart,
            onScaleUpdate: _gestureHandler.handleScaleUpdate,
            onScaleEnd:
                widget.enableFling ? _gestureHandler.handleScaleEnd : null,
            onDoubleTapDown:
                widget.enableDoubleTapZoom
                    ? _gestureHandler.handleDoubleTapDown
                    : null,
            onDoubleTap:
                widget.enableDoubleTapZoom
                    ? () => _gestureHandler.handleDoubleTap(context)
                    : null,
            onTap: () {
              if (!_focusNode.hasFocus) {
                _focusNode.requestFocus();
              }
            },
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Container(
                  color: Colors.transparent,
                  child: ClipRRect(
                    child: OverflowBox(
                      key: _viewportKey,
                      maxWidth: double.infinity,
                      maxHeight: double.infinity,
                      alignment: Alignment.topLeft,
                      child: Transform(
                        alignment: Alignment.topLeft,
                        transform: controller.transformationMatrix,
                        child: widget.child,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _NoArrowTraversalPolicy extends WidgetOrderTraversalPolicy {
  @override
  bool inDirection(FocusNode currentNode, TraversalDirection direction) {
    // Block arrow key focus movement
    if (direction == TraversalDirection.left ||
        direction == TraversalDirection.right ||
        direction == TraversalDirection.up ||
        direction == TraversalDirection.down) {
      return false;
    }
    return super.inDirection(currentNode, direction);
  }
}
