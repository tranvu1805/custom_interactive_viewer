import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:custom_interactive_viewer/src/controller/interactive_controller.dart';

/// A handler for keyboard interactions with [CustomInteractiveViewer]
class KeyboardHandler {
  /// The controller that manages the view state
  final CustomInteractiveViewerController controller;

  /// Distance to pan on each arrow key press
  final double keyboardPanDistance;

  /// Factor by which to zoom on each zoom key press
  final double keyboardZoomFactor;

  /// Whether keyboard controls are enabled
  final bool enableKeyboardControls;

  /// Whether key repeat is enabled
  final bool enableKeyRepeat;

  /// Delay before key repeat starts
  final Duration keyRepeatInitialDelay;

  /// Interval between repeated key actions
  final Duration keyRepeatInterval;

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

  /// The reference to the viewport
  final GlobalKey viewportKey;

  /// Minimum allowed scale
  final double minScale;

  /// Maximum allowed scale
  final double maxScale;

  /// Creates a keyboard handler
  KeyboardHandler({
    required this.controller,
    required this.keyboardPanDistance,
    required this.keyboardZoomFactor,
    required this.enableKeyboardControls,
    required this.enableKeyRepeat,
    required this.keyRepeatInitialDelay,
    required this.keyRepeatInterval,
    required this.focusNode,
    required this.constrainBounds,
    required this.contentSize,
    required this.viewportKey,
    required this.minScale,
    required this.maxScale,
  });

  /// Handles a key event and returns whether it was handled
  KeyEventResult handleKeyEvent(KeyEvent event) {
    if (!enableKeyboardControls) {
      return KeyEventResult.ignored;
    }

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
        key == LogicalKeyboardKey.minus ||
        key == LogicalKeyboardKey.numpadSubtract ||
        key == LogicalKeyboardKey.equal ||
        key == LogicalKeyboardKey.numpadAdd;
  }

  /// Process key actions for currently pressed keys
  void _processKeyActions() {
    if (!enableKeyboardControls || _pressedKeys.isEmpty) return;

    double? newScale;
    Offset? newOffset;
    bool actionPerformed = false;

    // Process zoom keys
    if (_pressedKeys.contains(LogicalKeyboardKey.minus) ||
        _pressedKeys.contains(LogicalKeyboardKey.numpadSubtract)) {
      newScale = (controller.scale / keyboardZoomFactor).clamp(
        minScale,
        maxScale,
      );
      actionPerformed = true;
    } else if ((_pressedKeys.contains(LogicalKeyboardKey.equal) &&
            HardwareKeyboard.instance.isShiftPressed) ||
        _pressedKeys.contains(LogicalKeyboardKey.numpadAdd)) {
      newScale = (controller.scale * keyboardZoomFactor).clamp(
        minScale,
        maxScale,
      );
      actionPerformed = true;
    }

    // Process arrow keys for panning
    final Offset panDelta = _calculatePanDeltaFromKeys();
    if (panDelta != Offset.zero) {
      newOffset = controller.offset + panDelta;
      actionPerformed = true;
    }

    // Apply actions if needed
    if (actionPerformed) {
      controller.update(newScale: newScale, newOffset: newOffset);

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

    if (_pressedKeys.contains(LogicalKeyboardKey.arrowLeft)) {
      dx -= keyboardPanDistance;
    }
    if (_pressedKeys.contains(LogicalKeyboardKey.arrowRight)) {
      dx += keyboardPanDistance;
    }
    if (_pressedKeys.contains(LogicalKeyboardKey.arrowUp)) {
      dy -= keyboardPanDistance;
    }
    if (_pressedKeys.contains(LogicalKeyboardKey.arrowDown)) {
      dy += keyboardPanDistance;
    }

    return Offset(dx, dy);
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

  /// Cleans up resources
  void dispose() {
    _keyRepeatTimer?.cancel();
    _keyRepeatInitialDelayTimer?.cancel();
  }
}
