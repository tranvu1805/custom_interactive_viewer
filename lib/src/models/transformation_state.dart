import 'dart:math';
import 'package:custom_interactive_viewer/src/widget.dart';
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart';

/// Represents the transformation state of a [CustomInteractiveViewer].
///
/// Contains information about scale, offset, and rotation, and provides
/// utility methods for working with transformations.
class TransformationState {
  /// The current scale factor.
  final double scale;

  /// The current offset of the content.
  final Offset offset;

  /// The current rotation in radians.
  final double rotation;

  /// Creates a new [TransformationState] with the given values.
  const TransformationState({
    this.scale = 1.0,
    this.offset = Offset.zero,
    this.rotation = 0.0,
  });

  /// Creates a copy of this state with the given fields replaced.
  TransformationState copyWith({
    double? scale,
    Offset? offset,
    double? rotation,
  }) {
    return TransformationState(
      scale: scale ?? this.scale,
      offset: offset ?? this.offset,
      rotation: rotation ?? this.rotation,
    );
  }

  /// Returns a [Matrix4] representing the current transformation.
  Matrix4 toMatrix4() {
    return Matrix4.identity()
      ..translate(offset.dx, offset.dy)
      ..scale(scale)
      ..rotateZ(rotation);
  }

  /// Converts a point from screen coordinates to content coordinates.
  Offset screenToContentPoint(Offset screenPoint) {
    // The inverse of our transformation
    final Matrix4 inverseTransform =
        Matrix4.identity()
          ..rotateZ(-rotation)
          ..scale(1 / scale)
          ..translate(-offset.dx, -offset.dy);

    final Vector3 contentPoint = inverseTransform.transform3(
      Vector3(screenPoint.dx, screenPoint.dy, 0),
    );
    return Offset(contentPoint.x, contentPoint.y);
  }

  /// Converts a point from content coordinates to screen coordinates.
  Offset contentToScreenPoint(Offset contentPoint) {
    final Vector3 screenPoint = toMatrix4().transform3(
      Vector3(contentPoint.dx, contentPoint.dy, 0),
    );
    return Offset(screenPoint.x, screenPoint.y);
  }

  /// Creates a [TransformationState] to fit the content to the viewport.
  static TransformationState fitContent(
    Size contentSize,
    Size viewportSize, {
    double padding = 20.0,
  }) {
    // Calculate the scale needed to fit the content in the viewport with padding
    final double horizontalScale =
        (viewportSize.width - 2 * padding) / contentSize.width;
    final double verticalScale =
        (viewportSize.height - 2 * padding) / contentSize.height;
    final double targetScale =
        horizontalScale < verticalScale ? horizontalScale : verticalScale;

    // Calculate the offset to center the content
    final Offset targetOffset = Offset(
      (viewportSize.width - contentSize.width * targetScale) / 2,
      (viewportSize.height - contentSize.height * targetScale) / 2,
    );

    return TransformationState(scale: targetScale, offset: targetOffset);
  }

  /// Creates a [TransformationState] to center the content in the viewport.
  static TransformationState centerContent(
    Size contentSize,
    Size viewportSize,
    double scale,
  ) {
    final Offset targetOffset = Offset(
      (viewportSize.width - contentSize.width * scale) / 2,
      (viewportSize.height - contentSize.height * scale) / 2,
    );

    return TransformationState(scale: scale, offset: targetOffset);
  }

  /// Creates a [TransformationState] for zooming to a specific region.
  static TransformationState zoomToRegion(
    Rect region,
    Size viewportSize, {
    double padding = 20.0,
  }) {
    // Calculate the scale needed to fit the region in the viewport with padding
    final double horizontalScale =
        (viewportSize.width - 2 * padding) / region.width;
    final double verticalScale =
        (viewportSize.height - 2 * padding) / region.height;
    final double targetScale =
        horizontalScale < verticalScale ? horizontalScale : verticalScale;

    // Calculate the offset to center the region
    final double centerX = region.left + region.width / 2;
    final double centerY = region.top + region.height / 2;
    final Offset targetOffset = Offset(
      viewportSize.width / 2 - centerX * targetScale,
      viewportSize.height / 2 - centerY * targetScale,
    );

    return TransformationState(scale: targetScale, offset: targetOffset);
  }

  /// Constrains the transformation to the given bounds.
  TransformationState constrainToViewport(Size contentSize, Size viewportSize) {
    double newX = offset.dx;
    double newY = offset.dy;

    // Calculate the bounding box of the rotated content
    final double absRotation = rotation.abs();
    final double cosRotation = cos(absRotation);
    final double sinRotation = sin(absRotation);

    // Calculate the dimensions of the bounding box that contains the rotated content
    final double rotatedWidth =
        (contentSize.width * cosRotation + contentSize.height * sinRotation)
            .abs() *
        scale;
    final double rotatedHeight =
        (contentSize.width * sinRotation + contentSize.height * cosRotation)
            .abs() *
        scale;

    if (rotatedWidth <= viewportSize.width) {
      // If rotated content is smaller than viewport, center it horizontally
      newX = (viewportSize.width - contentSize.width * scale) / 2;
    } else {
      // Otherwise restrict panning to keep rotated content filling the viewport
      // Calculate the offset adjustment needed due to rotation
      final double centerX = contentSize.width * scale / 2;
      final double centerY = contentSize.height * scale / 2;
      final double rotatedCenterX =
          centerX * cosRotation - centerY * sinRotation;
      final double offsetAdjustmentX = centerX - rotatedCenterX;

      final double minX = viewportSize.width - rotatedWidth + offsetAdjustmentX;
      final double maxX = offsetAdjustmentX;
      newX = newX.clamp(minX, maxX);
    }

    if (rotatedHeight <= viewportSize.height) {
      // If rotated content is smaller than viewport, center it vertically
      newY = (viewportSize.height - contentSize.height * scale) / 2;
    } else {
      // Otherwise restrict panning to keep rotated content filling the viewport
      // Calculate the offset adjustment needed due to rotation
      final double centerX = contentSize.width * scale / 2;
      final double centerY = contentSize.height * scale / 2;
      final double rotatedCenterY =
          centerX * sinRotation + centerY * cosRotation;
      final double offsetAdjustmentY = centerY - rotatedCenterY;

      final double minY =
          viewportSize.height - rotatedHeight + offsetAdjustmentY;
      final double maxY = offsetAdjustmentY;
      newY = newY.clamp(minY, maxY);
    }

    if (newX == offset.dx && newY == offset.dy) {
      return this;
    }

    return copyWith(offset: Offset(newX, newY));
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TransformationState &&
        other.scale == scale &&
        other.offset == offset &&
        other.rotation == rotation;
  }

  @override
  int get hashCode => Object.hash(scale, offset, rotation);

  @override
  String toString() =>
      'TransformationState(scale: $scale, offset: $offset, rotation: $rotation)';
}
