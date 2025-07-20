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
      title: 'Scroll Mode Test',
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
  ScrollMode _scrollMode = ScrollMode.both;

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
      appBar: AppBar(
        title: const Text('Scroll Mode Test'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Wrap(
              spacing: 8.0,
              children: [
                ChoiceChip(
                  label: const Text('Both'),
                  selected: _scrollMode == ScrollMode.both,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() => _scrollMode = ScrollMode.both);
                    }
                  },
                ),
                ChoiceChip(
                  label: const Text('Horizontal'),
                  selected: _scrollMode == ScrollMode.horizontal,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() => _scrollMode = ScrollMode.horizontal);
                    }
                  },
                ),
                ChoiceChip(
                  label: const Text('Vertical'),
                  selected: _scrollMode == ScrollMode.vertical,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() => _scrollMode = ScrollMode.vertical);
                    }
                  },
                ),
                ChoiceChip(
                  label: const Text('None'),
                  selected: _scrollMode == ScrollMode.none,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() => _scrollMode = ScrollMode.none);
                    }
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: CustomInteractiveViewer(
              controller: _controller,
              contentSize: const Size(1200, 1200),
              interactionConfig: InteractionConfig(
                scrollMode: _scrollMode,
              ),
              zoomConfig: const ZoomConfig(
                enableCtrlScrollToScale: true,
                enableDoubleTapZoom: true,
              ),
              child: Container(
                width: 1200,
                height: 1200,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.blue, width: 2),
                  color: Colors.blue.withOpacity(0.1),
                ),
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 20,
                  ),
                  itemCount: 400,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: const EdgeInsets.all(2),
                      color: Colors.primaries[index % Colors.primaries.length],
                      child: Center(
                        child: Text(
                          '$index',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
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
          const SizedBox(height: 16),
          FloatingActionButton(
            onPressed: () async {
              final state = _controller.state;
              await _controller.center(
                contentSize: const Size(1200, 1200),
                viewportSize: MediaQuery.of(context).size,
              );
            },
            tooltip: 'Center',
            child: const Icon(Icons.center_focus_strong),
          ),
        ],
      ),
    );
  }
}