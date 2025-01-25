import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Dock<IconData>(
            items: const [
              Icons.person,
              Icons.message,
              Icons.call,
              Icons.camera,
              Icons.photo,
            ],
            builder: (e) {
              return Container(
                constraints: const BoxConstraints(minWidth: 48),
                height: 48,
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.primaries[e.hashCode % Colors.primaries.length],
                ),
                child: Center(child: Icon(e, color: Colors.white)),
              );
            },
          ),
        ),
      ),
    );
  }
}

class Dock<T extends IconData> extends StatefulWidget {
  const Dock({
    super.key,
    this.items = const [],
    required this.builder,
  });

  final List<T> items;
  final Widget Function(T) builder;

  @override
  State<Dock<T>> createState() => _DockState<T>();
}

class _DockState<T extends IconData> extends State<Dock<T>> {
  late final List<T> _items = widget.items.toList();
  int? _hoveredIndex;
  int? _draggingIndex;
  T? _draggingItem;
  bool _isDragging = false; // Flag to track dragging state

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.black12,
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: _items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          return DragTarget<T>(
            onWillAcceptWithDetails: (details) {
              setState(() {
                _draggingIndex = index;
              });
              return true;
            },
            onLeave: (data) {
              setState(() {
                _draggingIndex = null;
              });
            },
            onAcceptWithDetails: (details) {
              setState(() {
                final oldIndex = _items.indexOf(details.data);
                if (oldIndex >= 0 && oldIndex < _items.length) {
                  _items.removeAt(oldIndex);
                }
                if (index >= 0 && index <= _items.length) {
                  _items.insert(index, details.data);
                }
                _draggingIndex = null;
                _draggingItem = null;
                _isDragging = false; // Reset dragging state
              });
            },
            builder: (context, candidateData, rejectedData) {
              return Row(
                children: [
                  if (_draggingIndex == index) SizedBox(width: 48),
                  Draggable<T>(
                    data: item,
                    feedback: Opacity(
                      opacity: 0.5,
                      child: widget.builder(item),
                    ),
                    childWhenDragging: Opacity(
                      opacity: 0.5,
                      child: widget.builder(item),
                    ),
                    onDragStarted: () {
                      setState(() {
                        _draggingItem = item;
                        _isDragging = true; // Set dragging state
                      });
                    },
                    onDragEnd: (details) {
                      setState(() {
                        _draggingItem = null;
                        _isDragging = false; // Reset dragging state
                      });
                    },
                    child: MouseRegion(
                      onEnter: (_) {
                        if (!_isDragging) { // Disable hover effect while dragging
                          setState(() {
                            _hoveredIndex = index;
                          });
                        }
                      },
                      onExit: (_) {
                        if (!_isDragging) { // Disable hover effect while dragging
                          setState(() {
                            _hoveredIndex = null;
                          });
                        }
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        transform: Matrix4.identity()
                          ..scale(_hoveredIndex == index && !_isDragging ? 1.2 : 1.0), // Disable hover effect while dragging
                        child: widget.builder(item),
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        }).toList(),
      ),
    );
  }
}