import 'package:flutter/material.dart';
import 'package:custom_interactive_viewer/custom_interactive_viewer.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Config-based Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late final CustomInteractiveViewerController _controller;

  // Configuration presets
  final _defaultConfig = const ZoomConfig();
  final _imageViewerConfig = const ZoomConfig(
    minScale: 0.8,
    maxScale: 8.0,
    enableDoubleTapZoom: true,
    doubleTapZoomFactor: 3.0,
  );
  
  ZoomConfig _currentZoomConfig = const ZoomConfig();
  InteractionConfig _currentInteractionConfig = const InteractionConfig();
  KeyboardConfig _currentKeyboardConfig = const KeyboardConfig();

  @override
  void initState() {
    super.initState();
    _controller = CustomInteractiveViewerController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _applyPreset(String preset) {
    setState(() {
      switch (preset) {
        case 'default':
          _currentZoomConfig = const ZoomConfig();
          _currentInteractionConfig = const InteractionConfig();
          _currentKeyboardConfig = const KeyboardConfig();
          break;
        case 'imageViewer':
          _currentZoomConfig = const ZoomConfig(
            minScale: 0.8,
            maxScale: 8.0,
            enableDoubleTapZoom: true,
            doubleTapZoomFactor: 3.0,
          );
          _currentInteractionConfig = const InteractionConfig.imageViewer();
          _currentKeyboardConfig = const KeyboardConfig();
          break;
        case 'disabled':
          _currentZoomConfig = const ZoomConfig.disabled();
          _currentInteractionConfig = const InteractionConfig.disabled();
          _currentKeyboardConfig = const KeyboardConfig.disabled();
          break;
        case 'fastKeyboard':
          _currentZoomConfig = const ZoomConfig();
          _currentInteractionConfig = const InteractionConfig();
          _currentKeyboardConfig = const KeyboardConfig.fast();
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Config-based Interactive Viewer'),
      ),
      body: Column(
        children: [
          // Preset selector
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Wrap(
              spacing: 8.0,
              children: [
                ElevatedButton(
                  onPressed: () => _applyPreset('default'),
                  child: const Text('Default'),
                ),
                ElevatedButton(
                  onPressed: () => _applyPreset('imageViewer'),
                  child: const Text('Image Viewer'),
                ),
                ElevatedButton(
                  onPressed: () => _applyPreset('disabled'),
                  child: const Text('Disabled'),
                ),
                ElevatedButton(
                  onPressed: () => _applyPreset('fastKeyboard'),
                  child: const Text('Fast Keyboard'),
                ),
              ],
            ),
          ),
          // Interactive controls
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Wrap(
              spacing: 8.0,
              children: [
                FilterChip(
                  label: const Text('Constrain Bounds'),
                  selected: _currentInteractionConfig.constrainBounds,
                  onSelected: (value) {
                    setState(() {
                      _currentInteractionConfig = _currentInteractionConfig.copyWith(
                        constrainBounds: value,
                      );
                    });
                  },
                ),
                FilterChip(
                  label: const Text('Enable Rotation'),
                  selected: _currentInteractionConfig.enableRotation,
                  onSelected: (value) {
                    setState(() {
                      _currentInteractionConfig = _currentInteractionConfig.copyWith(
                        enableRotation: value,
                      );
                    });
                  },
                ),
                FilterChip(
                  label: const Text('Double Tap Zoom'),
                  selected: _currentZoomConfig.enableDoubleTapZoom,
                  onSelected: (value) {
                    setState(() {
                      _currentZoomConfig = _currentZoomConfig.copyWith(
                        enableDoubleTapZoom: value,
                      );
                    });
                  },
                ),
              ],
            ),
          ),
          // Viewer
          Expanded(
            child: CustomInteractiveViewer(
              controller: _controller,
              contentSize: const Size(1000, 1000),
              zoomConfig: _currentZoomConfig,
              interactionConfig: _currentInteractionConfig,
              keyboardConfig: _currentKeyboardConfig,
              child: Container(
                width: 1000,
                height: 1000,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.blue.shade100,
                      Colors.purple.shade100,
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    // Grid pattern
                    GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 10,
                      ),
                      itemCount: 100,
                      itemBuilder: (context, index) {
                        return Container(
                          margin: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.3),
                            border: Border.all(
                              color: Colors.black12,
                              width: 0.5,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              '$index',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ),
                        );
                      },
                    ),
                    // Center content
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.touch_app,
                              size: 64,
                              color: Colors.blue.shade600,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Interactive Content',
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Pan, zoom, and rotate',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _controller.reset(),
        tooltip: 'Reset',
        child: const Icon(Icons.refresh),
      ),
    );
  }
}