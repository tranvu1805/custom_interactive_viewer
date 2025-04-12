## 0.0.2 - 2024-04-12

### Added
- Fling behavior for smooth inertial scrolling after quick pan gestures
- Dynamic friction coefficient that's adjusted based on gesture velocity
- Optimizations for fling animation performance

## 0.0.1 - 2024-04-12

### Added
- Initial release of the Custom Interactive Viewer package
- Core CustomInteractiveViewer widget with enhanced pan and zoom capabilities
- CustomInteractiveViewerController for programmatically controlling transformations
- TransformationState model for clean state management
- Support for keyboard navigation with arrow keys and zoom controls
- Mouse/touch gesture support including pinch-to-zoom and panning
- Optional content rotation functionality
- Support for content constraints to keep content within bounds
- Double-tap to zoom functionality
- Ctrl+scroll to scale for desktop environments
- Animation support for all transformations with customizable durations and curves
- Focal point preservation during zoom operations
- Helper methods for common operations:
  - Zoom in/out
  - Fit to screen
  - Center content
  - Zoom to specific regions
  - Reset to initial state
