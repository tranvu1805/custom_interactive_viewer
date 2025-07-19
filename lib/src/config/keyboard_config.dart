import 'package:flutter/material.dart';

/// Configuration for keyboard controls in CustomInteractiveViewer.
@immutable
class KeyboardConfig {
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

  /// Whether to invert the direction of arrow keys.
  /// If true, pressing left moves view left.
  /// If false, pressing left moves content right.
  final bool invertArrowKeyDirection;

  /// Creates a keyboard configuration.
  const KeyboardConfig({
    this.enableKeyboardControls = true,
    this.keyboardPanDistance = 20.0,
    this.keyboardZoomFactor = 1.1,
    this.enableKeyRepeat = true,
    this.keyRepeatInitialDelay = const Duration(milliseconds: 500),
    this.keyRepeatInterval = const Duration(milliseconds: 50),
    this.animateKeyboardTransitions = true,
    this.keyboardAnimationDuration = const Duration(milliseconds: 200),
    this.keyboardAnimationCurve = Curves.easeOutCubic,
    this.invertArrowKeyDirection = false,
  });

  /// Creates a configuration with keyboard controls disabled.
  const KeyboardConfig.disabled()
      : enableKeyboardControls = false,
        keyboardPanDistance = 20.0,
        keyboardZoomFactor = 1.1,
        enableKeyRepeat = false,
        keyRepeatInitialDelay = const Duration(milliseconds: 500),
        keyRepeatInterval = const Duration(milliseconds: 50),
        animateKeyboardTransitions = false,
        keyboardAnimationDuration = const Duration(milliseconds: 200),
        keyboardAnimationCurve = Curves.easeOutCubic,
        invertArrowKeyDirection = false;

  /// Creates a configuration with fast, responsive keyboard controls.
  const KeyboardConfig.fast()
      : enableKeyboardControls = true,
        keyboardPanDistance = 40.0,
        keyboardZoomFactor = 1.2,
        enableKeyRepeat = true,
        keyRepeatInitialDelay = const Duration(milliseconds: 300),
        keyRepeatInterval = const Duration(milliseconds: 30),
        animateKeyboardTransitions = false,
        keyboardAnimationDuration = const Duration(milliseconds: 100),
        keyboardAnimationCurve = Curves.linear,
        invertArrowKeyDirection = false;

  /// Creates a copy of this configuration with the given fields replaced.
  KeyboardConfig copyWith({
    bool? enableKeyboardControls,
    double? keyboardPanDistance,
    double? keyboardZoomFactor,
    bool? enableKeyRepeat,
    Duration? keyRepeatInitialDelay,
    Duration? keyRepeatInterval,
    bool? animateKeyboardTransitions,
    Duration? keyboardAnimationDuration,
    Curve? keyboardAnimationCurve,
    bool? invertArrowKeyDirection,
  }) {
    return KeyboardConfig(
      enableKeyboardControls: enableKeyboardControls ?? this.enableKeyboardControls,
      keyboardPanDistance: keyboardPanDistance ?? this.keyboardPanDistance,
      keyboardZoomFactor: keyboardZoomFactor ?? this.keyboardZoomFactor,
      enableKeyRepeat: enableKeyRepeat ?? this.enableKeyRepeat,
      keyRepeatInitialDelay: keyRepeatInitialDelay ?? this.keyRepeatInitialDelay,
      keyRepeatInterval: keyRepeatInterval ?? this.keyRepeatInterval,
      animateKeyboardTransitions: animateKeyboardTransitions ?? this.animateKeyboardTransitions,
      keyboardAnimationDuration: keyboardAnimationDuration ?? this.keyboardAnimationDuration,
      keyboardAnimationCurve: keyboardAnimationCurve ?? this.keyboardAnimationCurve,
      invertArrowKeyDirection: invertArrowKeyDirection ?? this.invertArrowKeyDirection,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is KeyboardConfig &&
          runtimeType == other.runtimeType &&
          enableKeyboardControls == other.enableKeyboardControls &&
          keyboardPanDistance == other.keyboardPanDistance &&
          keyboardZoomFactor == other.keyboardZoomFactor &&
          enableKeyRepeat == other.enableKeyRepeat &&
          keyRepeatInitialDelay == other.keyRepeatInitialDelay &&
          keyRepeatInterval == other.keyRepeatInterval &&
          animateKeyboardTransitions == other.animateKeyboardTransitions &&
          keyboardAnimationDuration == other.keyboardAnimationDuration &&
          keyboardAnimationCurve == other.keyboardAnimationCurve &&
          invertArrowKeyDirection == other.invertArrowKeyDirection;

  @override
  int get hashCode =>
      enableKeyboardControls.hashCode ^
      keyboardPanDistance.hashCode ^
      keyboardZoomFactor.hashCode ^
      enableKeyRepeat.hashCode ^
      keyRepeatInitialDelay.hashCode ^
      keyRepeatInterval.hashCode ^
      animateKeyboardTransitions.hashCode ^
      keyboardAnimationDuration.hashCode ^
      keyboardAnimationCurve.hashCode ^
      invertArrowKeyDirection.hashCode;
}