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
      title: 'Custom Interactive Viewer Web Test',
      theme: ThemeData(primarySwatch: Colors.blue),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Web Zoom Test')),
      body: Center(
        child: CustomInteractiveViewer(
          controller: _controller,
          contentSize: const Size(800, 600),
          zoomConfig: const ZoomConfig(enableCtrlScrollToScale: true),
          child: Container(
            width: 800,
            height: 600,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.blue, width: 2),
              color: Colors.blue.withValues(alpha: 0.1),
            ),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 10,
              ),
              itemCount: 100,
              itemBuilder: (context, index) {
                return Container(
                  margin: const EdgeInsets.all(4),
                  color: Colors.blue.withValues(alpha: 0.5),
                  child: Center(
                    child: Text(
                      '$index',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () => _controller.zoom(factor: 0.2),
            tooltip: 'Zoom In',
            child: const Icon(Icons.zoom_in),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            onPressed: () => _controller.zoom(factor: -0.2),
            tooltip: 'Zoom Out',
            child: const Icon(Icons.zoom_out),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            onPressed: () => _controller.reset(),
            tooltip: 'Reset',
            child: const Icon(Icons.refresh),
          ),
        ],
      ),
    );
  }
}
