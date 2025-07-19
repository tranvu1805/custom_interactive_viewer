import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:custom_interactive_viewer/src/controller/interactive_controller.dart';
import 'package:custom_interactive_viewer/src/enums/scroll_mode.dart';

/// A handler for keyboard interactions with [CustomInteractiveViewer]
class KeyboardHandler with WidgetsBindingObserver {
  /// The controller that manages the view state
  final CustomInteractiveViewerController controller;

  /// Distance to pan on each arrow key press
  final double keyboardPanDistance;

  /// Factor by which to zoom on each zoom key press
  final double keyboardZoomFactor;

  /// Whether keyboard controls are enabled
  final bool enableKeyboardControls;

  /// Whether to invert the direction of arrow keys
  /// If true, pressing left moves view left
  /// If false, pressing left moves content right
  final bool invertArrowKeyDirection;

  /// Whether key repeat is enabled
  final bool enableKeyRepeat;

  /// Delay before key repeat starts
  final Duration keyRepeatInitialDelay;

  /// Interval between repeated key actions
  final Duration keyRepeatInterval;

  /// Whether to animate transitions when using keyboard controls
  final bool animateKeyboardTransitions;

  /// Duration of keyboard transition animations
  final Duration keyboardAnimationDuration;

  /// Animation curve for keyboard transitions
  final Curve keyboardAnimationCurve;

  /// Focus node to receive keyboard input
  final FocusNode focusNode;

  /// Constrains operations to the content bounds if true
  final bool constrainBounds;

  /// Size of the content being viewed
  final Size? contentSize;

  /// The currently pressed keys
  final Set<LogicalKeyboardKey> _pressedKeys = {};

  /// Timer for initial key repeat delay
  Timer? _keyRepeatInitialDelayTimer;

  /// Timer for key repeat interval
  Timer? _keyRepeatTimer;

  /// Flag to track if the application has focus
  bool _hasAppFocus = true;

  /// Safety timer to check for stale key states
  Timer? _safetyCheckTimer;

  /// The reference to the viewport
  final GlobalKey viewportKey;

  /// Minimum allowed scale
  final double minScale;

  /// Maximum allowed scale
  final double maxScale;

  /// Whether keyboard zoom is enabled
  final bool enableKeyboardZoom;

  /// The scroll mode that determines allowed scroll directions
  final ScrollMode scrollMode;

  /// Creates a keyboard handler
  KeyboardHandler({
    required this.controller,
    required this.keyboardPanDistance,
    required this.keyboardZoomFactor,
    required this.enableKeyboardControls,
    required this.enableKeyRepeat,
    required this.keyRepeatInitialDelay,
    required this.keyRepeatInterval,
    required this.animateKeyboardTransitions,
    required this.keyboardAnimationDuration,
    required this.keyboardAnimationCurve,
    required this.focusNode,
    required this.constrainBounds,
    required this.contentSize,
    required this.viewportKey,
    required this.minScale,
    required this.maxScale,
    required this.enableKeyboardZoom,
    this.invertArrowKeyDirection = false,
    this.scrollMode = ScrollMode.both,
  }) {
    // Register as an observer to detect app lifecycle changes
    WidgetsBinding.instance.addObserver(this);

    // Set up a safety timer to periodically check for stale key states
    _setupSafetyTimer();

    // Add listener to focus node to track focus changes
    focusNode.addListener(_handleFocusChange);
  }

  /// Handles a key event and returns whether it was handled
  KeyEventResult handleKeyEvent(KeyEvent event) {
    if (!enableKeyboardControls) {
      return KeyEventResult.ignored;
    }

    // Reset safety timer whenever we get a key event
    _resetSafetyTimer();

    // Handle key down events
    if (event is KeyDownEvent) {
      final key = event.logicalKey;

      // Track the key press
      if (_isHandledKey(key)) {
        if (_pressedKeys.add(key)) {
          // Returns true if key was added (not already in set)
          _setupKeyRepeatTimer();
        }
        return KeyEventResult.handled;
      }

      // Handle one-time actions (like Home key)
      if (key == LogicalKeyboardKey.home) {
        controller.reset();
        return KeyEventResult.handled;
      }
    }
    // Handle key up events
    else if (event is KeyUpEvent) {
      final key = event.logicalKey;

      if (_pressedKeys.remove(key)) {
        if (_pressedKeys.isEmpty) {
          _keyRepeatTimer?.cancel();
          _keyRepeatInitialDelayTimer?.cancel();
        } else if (_isHandledKey(key)) {
          // If there are still keys pressed, recalculate actions
          _setupKeyRepeatTimer();
        }
        return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  }

  /// Checks if the key is one we handle for continuous actions
  bool _isHandledKey(LogicalKeyboardKey key) {
    return key == LogicalKeyboardKey.arrowLeft ||
        key == LogicalKeyboardKey.arrowRight ||
        key == LogicalKeyboardKey.arrowUp ||
        key == LogicalKeyboardKey.arrowDown ||
        (key == LogicalKeyboardKey.minus ||
                key == LogicalKeyboardKey.numpadSubtract ||
                key == LogicalKeyboardKey.equal ||
                key == LogicalKeyboardKey.numpadAdd) &&
            enableKeyboardZoom;
  }

  /// Process key actions for currently pressed keys
  void _processKeyActions() {
    if (!enableKeyboardControls || _pressedKeys.isEmpty) return;

    // If already animating and using key repeat, skip to prevent animation conflicts
    if (controller.isAnimating &&
        animateKeyboardTransitions &&
        _keyRepeatTimer != null) {
      return;
    }

    double? newScale;
    Offset? newOffset;
    bool actionPerformed = false;

    // Process zoom keys
    if (enableKeyboardZoom) {
      // Get the viewport size for centered zooming
      final RenderBox? box =
          viewportKey.currentContext?.findRenderObject() as RenderBox?;
      if (box != null &&
          (_pressedKeys.contains(LogicalKeyboardKey.minus) ||
              _pressedKeys.contains(LogicalKeyboardKey.numpadSubtract) ||
              (_pressedKeys.contains(LogicalKeyboardKey.equal) &&
                  HardwareKeyboard.instance.isShiftPressed) ||
              _pressedKeys.contains(LogicalKeyboardKey.add) ||
              _pressedKeys.contains(LogicalKeyboardKey.numpadAdd))) {
        // Get the center of the viewport as the focal point
        final Size viewportSize = box.size;
        final Offset center = Offset(
          viewportSize.width / 2,
          viewportSize.height / 2,
        );

        // Calculate the new scale factor
        final double currentScale = controller.scale;
        double targetScale = currentScale;

        if (_pressedKeys.contains(LogicalKeyboardKey.minus) ||
            _pressedKeys.contains(LogicalKeyboardKey.numpadSubtract)) {
          targetScale = (currentScale / keyboardZoomFactor).clamp(
            minScale,
            maxScale,
          );
        } else if ((_pressedKeys.contains(LogicalKeyboardKey.equal) &&
                HardwareKeyboard.instance.isShiftPressed) ||
            _pressedKeys.contains(LogicalKeyboardKey.add) ||
            _pressedKeys.contains(LogicalKeyboardKey.numpadAdd)) {
          targetScale = (currentScale * keyboardZoomFactor).clamp(
            minScale,
            maxScale,
          );
        }

        if (targetScale != currentScale) {
          // Get the center point in content coordinates before scaling
          final Offset contentCenter = controller.state.screenToContentPoint(
            center,
          );

          // Calculate the new offset to keep the center point fixed during zoom
          newOffset = center - (contentCenter * targetScale);
          newScale = targetScale;
          actionPerformed = true;
        }
      }
    }

    // Process arrow keys for panning if no zoom action was performed
    if (!actionPerformed) {
      final Offset panDelta = _calculatePanDeltaFromKeys();
      if (panDelta != Offset.zero) {
        newOffset = controller.offset + panDelta;
        actionPerformed = true;
      }
    }

    // Apply actions if needed
    if (actionPerformed) {
      if (animateKeyboardTransitions) {
        // Use shorter animation duration for key repeats to avoid queuing delays
        final isKeyRepeat = _keyRepeatTimer?.isActive ?? false;
        final effectiveDuration =
            isKeyRepeat
                ? Duration(
                  milliseconds: keyboardAnimationDuration.inMilliseconds ~/ 10,
                )
                : keyboardAnimationDuration;

        // Create a target transformation state
        final targetState = controller.state.copyWith(
          scale: newScale,
          offset: newOffset,
        );

        // Animate to the new state
        controller.animateTo(
          targetState: targetState,
          duration: effectiveDuration,
          curve: keyboardAnimationCurve,
          animate: true,
        );
      } else {
        // Update immediately without animation
        controller.update(newScale: newScale, newOffset: newOffset);
      }

      if (constrainBounds && contentSize != null) {
        final RenderBox? box =
            viewportKey.currentContext?.findRenderObject() as RenderBox?;
        if (box != null) {
          controller.constrainToBounds(contentSize!, box.size);
        }
      }
    }
  }

  /// Calculate pan delta from currently pressed keys
  Offset _calculatePanDeltaFromKeys() {
    double dx = 0, dy = 0;

    // Direction multiplier based on the invertArrowKeyDirection setting
    final int directionMultiplier = invertArrowKeyDirection ? -1 : 1;

    if (_pressedKeys.contains(LogicalKeyboardKey.arrowLeft)) {
      dx += keyboardPanDistance * directionMultiplier;
    }
    if (_pressedKeys.contains(LogicalKeyboardKey.arrowRight)) {
      dx -= keyboardPanDistance * directionMultiplier;
    }
    if (_pressedKeys.contains(LogicalKeyboardKey.arrowUp)) {
      dy += keyboardPanDistance * directionMultiplier;
    }
    if (_pressedKeys.contains(LogicalKeyboardKey.arrowDown)) {
      dy -= keyboardPanDistance * directionMultiplier;
    }

    // Constrain pan delta based on scroll mode
    switch (scrollMode) {
      case ScrollMode.horizontal:
        return Offset(dx, 0);
      case ScrollMode.vertical:
        return Offset(0, dy);
      case ScrollMode.none:
        return Offset.zero;
      case ScrollMode.both:
        return Offset(dx, dy);
    }
  }

  /// Setup key repeat timer when a key is pressed
  void _setupKeyRepeatTimer() {
    _keyRepeatTimer?.cancel();
    _keyRepeatInitialDelayTimer?.cancel();

    // Apply action immediately for the first press
    _processKeyActions();

    if (!enableKeyRepeat) return;

    // Set initial delay before rapid repeat starts
    _keyRepeatInitialDelayTimer = Timer(keyRepeatInitialDelay, () {
      // Start continuous repeat timer after initial delay
      _keyRepeatTimer = Timer.periodic(keyRepeatInterval, (_) {
        _processKeyActions();
      });
    });
  }

  /// Handles focus changes to reset key states when focus is lost
  void _handleFocusChange() {
    if (!focusNode.hasFocus) {
      // Reset state when focus is lost
      _resetAllKeyStates();
    }
  }

  /// Set up the safety timer that periodically checks for stale key states
  void _setupSafetyTimer() {
    _safetyCheckTimer?.cancel();
    _safetyCheckTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      // Check if any keys are still pressed but the app might not be in focus
      if (!_hasAppFocus || !focusNode.hasFocus) {
        _resetAllKeyStates();
      }
    });
  }

  /// Reset the safety timer when activity is detected
  void _resetSafetyTimer() {
    _setupSafetyTimer();
  }

  /// Reset all key states and cancel timers
  void _resetAllKeyStates() {
    if (_pressedKeys.isNotEmpty) {
      _pressedKeys.clear();
      _keyRepeatTimer?.cancel();
      _keyRepeatInitialDelayTimer?.cancel();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Update app focus state
    _hasAppFocus = state == AppLifecycleState.resumed;

    if (!_hasAppFocus) {
      // Reset state when app loses focus
      _resetAllKeyStates();
    }
  }

  /// Cleans up resources
  void dispose() {
    _keyRepeatTimer?.cancel();
    _keyRepeatInitialDelayTimer?.cancel();
    _safetyCheckTimer?.cancel();
    focusNode.removeListener(_handleFocusChange);
    WidgetsBinding.instance.removeObserver(this);
  }
}
