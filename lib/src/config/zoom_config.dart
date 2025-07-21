import 'package:flutter/material.dart';

/// Configuration for zoom-related behavior in CustomInteractiveViewer.
@immutable
class ZoomConfig {
  /// Whether to enable zooming/scaling.
  final bool enableZoom;

  /// The minimum scale factor.
  final double minScale;

  /// The maximum scale factor.
  final double maxScale;

  /// Whether to enable zooming on double tap.
  final bool enableDoubleTapZoom;

  /// The factor by which to zoom on double tap.
  final double doubleTapZoomFactor;

  /// Whether to enable scaling with Ctrl+scroll.
  final bool enableCtrlScrollToScale;

  /// Creates a zoom configuration.
  const ZoomConfig({
    this.enableZoom = true,
    this.minScale = 0.5,
    this.maxScale = 4.0,
    this.enableDoubleTapZoom = false,
    this.doubleTapZoomFactor = 2.0,
    this.enableCtrlScrollToScale = true,
  });

  /// Creates a configuration with zoom disabled.
  const ZoomConfig.disabled()
    : enableZoom = false,
      minScale = 1.0,
      maxScale = 1.0,
      enableDoubleTapZoom = false,
      doubleTapZoomFactor = 1.0,
      enableCtrlScrollToScale = false;

  /// Creates a copy of this configuration with the given fields replaced.
  ZoomConfig copyWith({
    bool? enableZoom,
    double? minScale,
    double? maxScale,
    bool? enableDoubleTapZoom,
    double? doubleTapZoomFactor,
    bool? enableCtrlScrollToScale,
  }) {
    return ZoomConfig(
      enableZoom: enableZoom ?? this.enableZoom,
      minScale: minScale ?? this.minScale,
      maxScale: maxScale ?? this.maxScale,
      enableDoubleTapZoom: enableDoubleTapZoom ?? this.enableDoubleTapZoom,
      doubleTapZoomFactor: doubleTapZoomFactor ?? this.doubleTapZoomFactor,
      enableCtrlScrollToScale:
          enableCtrlScrollToScale ?? this.enableCtrlScrollToScale,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ZoomConfig &&
          runtimeType == other.runtimeType &&
          enableZoom == other.enableZoom &&
          minScale == other.minScale &&
          maxScale == other.maxScale &&
          enableDoubleTapZoom == other.enableDoubleTapZoom &&
          doubleTapZoomFactor == other.doubleTapZoomFactor &&
          enableCtrlScrollToScale == other.enableCtrlScrollToScale;

  @override
  int get hashCode =>
      enableZoom.hashCode ^
      minScale.hashCode ^
      maxScale.hashCode ^
      enableDoubleTapZoom.hashCode ^
      doubleTapZoomFactor.hashCode ^
      enableCtrlScrollToScale.hashCode;
}
