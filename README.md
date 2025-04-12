# Custom Interactive Viewer

A highly customizable replacement for Flutter's InteractiveViewer with advanced features including keyboard navigation, custom transformations, and more flexible gesture controls.

## Features

- **Enhanced Zooming** - Zoom with gestures, keyboard controls, or programmatically with animations
- **Precise Panning** - Pan content with touch, mouse, or keyboard arrow keys
- **Optional Rotation** - Enable rotation with multi-touch gestures
- **Keyboard Navigation** - Built-in keyboard controls with customizable key repeat
- **Programmable Controls** - Full API for controlling the view programmatically
- **Bounds Constraints** - Optional content constraints to keep content within viewport
- **Custom Animation** - Animate transformations with customizable durations and curves
- **Focal Point Zooming** - Zoom to a specific point with proper focal point preservation
- **Double Tap Support** - Optional double-tap to zoom feature
- **Ctrl+Scroll Zooming** - Desktop-friendly zoom with keyboard modifier keys
- **Region Targeting** - Zoom to specific regions of content

## Getting Started

Add the package to your `pubspec.yaml` file:

```yaml
dependencies:
  custom_interactive_viewer: ^1.0.0
```

Then import it in your Dart code:

```dart
import 'package:custom_interactive_viewer/custom_interactive_viewer.dart';
```

## Usage

### Basic Usage

```dart
// Create a controller
final controller = CustomInteractiveViewerController();

// Use the widget
CustomInteractiveViewer(
  controller: controller,
  child: Image.asset('assets/image.jpg'),
);
```

### With Content Size and Constraints

```dart
CustomInteractiveViewer(
  controller: controller,
  contentSize: const Size(1000, 800),
  constrainBounds: true,
  minScale: 0.5,
  maxScale: 4.0,
  child: Image.asset('assets/map.jpg'),
);
```

### Programmatic Control

```dart
// Zoom in to a point
controller.zoomIn(
  factor: 1.5,
  focalPoint: Offset(100, 100),
);

// Fit content to screen
controller.fitToScreen(
  contentSize, 
  viewportSize,
  animate: true,
);

// Reset to initial state
controller.reset();
```

## Package Structure

This package is designed with a clean architecture for maximum maintainability:

```
lib/
├── custom_interactive_viewer.dart  # Main entry point that exports public API
└── src/
    ├── widget.dart                 # Main widget implementation
    ├── controller.dart             # Controller implementation
    ├── controller/
    │   └── interactive_controller.dart  # Enhanced controller implementation
    ├── handlers/
    │   ├── gesture_handler.dart    # Touch/pointer interaction logic
    │   └── keyboard_handler.dart   # Keyboard interaction logic
    └── models/
        └── transformation_state.dart  # Transformation data model
```

### Core Components

- **CustomInteractiveViewer** (`widget.dart`) - The main widget that orchestrates all components
- **CustomInteractiveViewerController** (`controller.dart`) - Manages view state and provides API

### Models

- **TransformationState** - An immutable class encapsulating transformation properties:
  - Scale factor
  - Offset (translation)
  - Rotation angle
  - Utility methods for coordinate conversion and constraints

### Handlers

- **KeyboardHandler** - Manages all keyboard interactions:
  - Arrow keys for panning
  - +/- keys for zooming
  - Key repeat logic for continuous movement
  - Home key for reset functionality
  
- **GestureHandler** - Handles touch and pointer interactions:
  - Pinch to zoom
  - Drag to pan
  - Double tap to zoom
  - Rotation gestures
  - Ctrl+scroll for desktop zooming

## Advanced Configuration

The widget offers extensive configuration options:

```dart
CustomInteractiveViewer(
  controller: controller,
  contentSize: contentSize,
  minScale: 0.5,
  maxScale: 4.0,
  enableRotation: true,
  constrainBounds: true,
  enableDoubleTapZoom: true,
  doubleTapZoomFactor: 2.0,
  enableKeyboardControls: true,
  keyboardPanDistance: 20.0,
  keyboardZoomFactor: 1.1,
  enableKeyRepeat: true,
  keyRepeatInitialDelay: const Duration(milliseconds: 500),
  keyRepeatInterval: const Duration(milliseconds: 50),
  enableCtrlScrollToScale: true,
  child: yourWidget,
);
```

## Version Information

This is the first release (0.0.1) of the Custom Interactive Viewer package. The package provides a solid foundation of features while maintaining good performance and a clean API.

## Contributing

If you find any issues or have suggestions for improvements, please file an issue or submit a pull request.