import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:custom_interactive_viewer/src/controller/interactive_controller.dart';

/// A handler for gesture interactions with [CustomInteractiveViewer]
class GestureHandler {
  /// The controller that manages the view state
  final CustomInteractiveViewerController controller;

  /// Whether rotation is enabled
  final bool enableRotation;

  /// Whether to constrain content to bounds
  final bool constrainBounds;

  /// Whether double-tap zoom is enabled
  final bool enableDoubleTapZoom;

  /// Factor by which to zoom on double-tap
  final double doubleTapZoomFactor;

  /// Size of the content being viewed
  final Size? contentSize;

  /// The reference to the viewport
  final GlobalKey viewportKey;

  /// Whether Ctrl+Scroll scaling is enabled
  final bool enableCtrlScrollToScale;

  /// Minimum allowed scale
  final double minScale;

  /// Maximum allowed scale
  final double maxScale;

  /// Stores the last focal point during scale gesture
  Offset _lastFocalPoint = Offset.zero;

  /// Stores the last scale during scale gesture
  double _lastScale = 1.0;

  /// Stores the last rotation during scale gesture
  double _lastRotation = 0.0;

  /// Tracks position of double tap for zoom
  Offset? _doubleTapPosition;

  /// Tracks whether Ctrl key is currently pressed
  bool _isCtrlPressed = false;

  /// Creates a gesture handler
  GestureHandler({
    required this.controller,
    required this.enableRotation,
    required this.constrainBounds,
    required this.enableDoubleTapZoom,
    required this.doubleTapZoomFactor,
    required this.contentSize,
    required this.viewportKey,
    required this.enableCtrlScrollToScale,
    required this.minScale,
    required this.maxScale,
  });

  /// Sets the current Ctrl key state
  set isCtrlPressed(bool value) {
    _isCtrlPressed = value;
  }

  /// Handles the start of a scale gesture
  void handleScaleStart(ScaleStartDetails details) {
    _lastFocalPoint = details.focalPoint;
    _lastScale = controller.scale;
    _lastRotation = controller.rotation;
  }

  /// Handles updates to a scale gesture
  void handleScaleUpdate(ScaleUpdateDetails details) {
    // Calculate updated scale with optional clamping
    double newScale = _lastScale * details.scale;
    newScale = newScale.clamp(minScale, maxScale);

    final Offset focalDiff = details.focalPoint - _lastFocalPoint;

    // Handle rotation if enabled
    double? newRotation;
    if (enableRotation && details.pointerCount >= 2) {
      newRotation = _lastRotation + details.rotation;
    }

    controller.update(
      newScale: newScale,
      newOffset: controller.offset + focalDiff,
      newRotation: newRotation,
    );

    _applyConstraints();

    _lastFocalPoint = details.focalPoint;
  }

  /// Stores double tap position for zoom
  void handleDoubleTapDown(TapDownDetails details) {
    if (!enableDoubleTapZoom) return;
    _doubleTapPosition = details.globalPosition;
  }

  /// Handles double tap for zoom
  void handleDoubleTap() {
    if (!enableDoubleTapZoom || _doubleTapPosition == null) return;

    final RenderBox? box =
        viewportKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return;

    final Offset localPosition = box.globalToLocal(_doubleTapPosition!);

    // Calculate focal point for zoom
    if (controller.scale > (minScale + maxScale) / 2) {
      // If we're zoomed in, zoom out to minimum
      controller.zoomOut(
        factor: controller.scale / minScale,
        focalPoint: localPosition,
      );
    } else {
      // Otherwise zoom in by the zoom factor
      controller.zoomIn(factor: doubleTapZoomFactor, focalPoint: localPosition);
    }
  }

  /// Handles pointer scroll events
  void handlePointerScroll(PointerScrollEvent event, BuildContext context) {
    // Determine if scaling should occur based on ctrl key
    if (enableCtrlScrollToScale && _isCtrlPressed) {
      _handleCtrlScroll(event, context);
    } else {
      _handleNormalScroll(event);
    }
  }

  /// Handle Ctrl+Scroll for zooming
  void _handleCtrlScroll(PointerScrollEvent event, BuildContext context) {
    final RenderBox? box = context.findRenderObject() as RenderBox?;
    if (box == null) return;

    final Offset localPosition = box.globalToLocal(event.position);

    // Zoom in or out based on scroll direction
    if (event.scrollDelta.dy > 0) {
      controller.zoomOut(
        factor: 1.05,
        focalPoint: localPosition,
        animate: false,
      );
    } else {
      controller.zoomIn(
        factor: 1.05,
        focalPoint: localPosition,
        animate: false,
      );
    }

    _applyConstraints();
  }

  /// Handle normal scroll for panning
  void _handleNormalScroll(PointerScrollEvent event) {
    // Pan using scroll delta
    controller.panBy(-event.scrollDelta, animate: false);

    _applyConstraints();
  }

  /// Apply constraints if needed
  void _applyConstraints() {
    if (constrainBounds && contentSize != null) {
      final RenderBox? box =
          viewportKey.currentContext?.findRenderObject() as RenderBox?;
      if (box != null) {
        controller.constrainToBounds(contentSize!, box.size);
      }
    }
  }
}
