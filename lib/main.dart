import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import 'dart:ui' as ui;

void main() {
  runApp(const TreeStructureVisualizer());
}

class TreeStructureVisualizer extends StatelessWidget {
  const TreeStructureVisualizer({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tree Structure Visualizer',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6366F1),
          brightness: Brightness.light,
        ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'SF Pro Display',
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6366F1),
          brightness: Brightness.dark,
        ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'SF Pro Display',
      ),
      home: const TreeVisualizerScreen(),
    );
  }
}

// Enhanced Tree Node Model
class TreeNode {
  final String id;
  String label;
  final List<TreeNode> children;
  bool isExpanded;
  Offset? position;
  Color color;
  double size;
  String? description;
  DateTime createdAt;
  Map<String, dynamic> metadata;
  
  TreeNode({
    required this.id,
    required this.label,
    this.isExpanded = true,
    this.position,
    this.color = Colors.blue,
    this.size = 1.0,
    this.description,
    Map<String, dynamic>? metadata,
  }) : children = [],
       createdAt = DateTime.now(),
       metadata = metadata ?? {};

  void addChild(TreeNode child) {
    children.add(child);
  }

  bool removeChild(String childId) {
    final initialLength = children.length;
    children.removeWhere((child) => child.id == childId);
    return children.length < initialLength;
  }

  TreeNode? findNode(String nodeId) {
    if (id == nodeId) return this;
    
    for (final child in children) {
      final found = child.findNode(nodeId);
      if (found != null) return found;
    }
    
    return null;
  }

  int get totalDescendants {
    int count = children.length;
    for (final child in children) {
      count += child.totalDescendants;
    }
    return count;
  }

  int get depth {
    if (children.isEmpty) return 0;
    return children.map((child) => child.depth).reduce(math.max) + 1;
  }

  List<TreeNode> get allNodes {
    List<TreeNode> nodes = [this];
    for (final child in children) {
      nodes.addAll(child.allNodes);
    }
    return nodes;
  }
}

enum TreeLayout { hierarchical, radial, organic, force }
enum ViewMode { standard, minimap, focus, presentation }
enum NotificationPosition { topRight, topLeft, bottomRight, bottomLeft }

// Custom Notification System
class CustomNotification extends StatefulWidget {
  final String message;
  final Color backgroundColor;
  final Duration duration;
  final NotificationPosition position;

  const CustomNotification({
    super.key,
    required this.message,
    this.backgroundColor = Colors.green,
    this.duration = const Duration(seconds: 2),
    this.position = NotificationPosition.topRight,
  });

  @override
  State<CustomNotification> createState() => _CustomNotificationState();
}

class _CustomNotificationState extends State<CustomNotification> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    // Set initial offset based on position
    final beginOffset = _getInitialOffset(widget.position);
    
    _offsetAnimation = Tween<Offset>(
      begin: beginOffset,
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));
    
    _opacityAnimation = Tween<double>(begin: 0, end: 1).animate(_controller);
    
    _controller.forward();
    
    Future.delayed(widget.duration, () {
      if (mounted) {
        _controller.reverse().then((_) {
          if (mounted) {
            Navigator.of(context).pop();
          }
        });
      }
    });
  }

  Offset _getInitialOffset(NotificationPosition position) {
    switch (position) {
      case NotificationPosition.topRight:
        return const Offset(1, -1);
      case NotificationPosition.topLeft:
        return const Offset(-1, -1);
      case NotificationPosition.bottomRight:
        return const Offset(1, 1);
      case NotificationPosition.bottomLeft:
        return const Offset(-1, 1);
    }
  }

  Alignment _getAlignment(NotificationPosition position) {
    switch (position) {
      case NotificationPosition.topRight:
        return Alignment.topRight;
      case NotificationPosition.topLeft:
        return Alignment.topLeft;
      case NotificationPosition.bottomRight:
        return Alignment.bottomRight;
      case NotificationPosition.bottomLeft:
        return Alignment.bottomLeft;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _offsetAnimation,
      child: FadeTransition(
        opacity: _opacityAnimation,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: widget.backgroundColor,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Text(
              widget.message,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Advanced Tree Layout Calculator with multiple algorithms
class AdvancedTreeLayoutCalculator {
  static const double baseNodeRadius = 25.0;
  static const double levelHeight = 120.0;
  static const double minNodeSpacing = 90.0;

  static void calculatePositions(TreeNode root, Size canvasSize, TreeLayout layout, double scale) {
    switch (layout) {
      case TreeLayout.hierarchical:
        _calculateHierarchicalLayout(root, canvasSize, scale);
        break;
      case TreeLayout.radial:
        _calculateRadialLayout(root, canvasSize, scale);
        break;
      case TreeLayout.organic:
        _calculateOrganicLayout(root, canvasSize, scale);
        break;
      case TreeLayout.force:
        _calculateForceDirectedLayout(root, canvasSize, scale);
        break;
    }
  }

  static void _calculateHierarchicalLayout(TreeNode root, Size canvasSize, double scale) {
    final Map<int, List<TreeNode>> levelNodes = {};
    _collectNodesByLevel(root, 0, levelNodes);
    
    for (final level in levelNodes.keys) {
      final nodes = levelNodes[level]!;
      final y = level * levelHeight * scale + baseNodeRadius + 50;
      
      if (nodes.length == 1) {
        nodes.first.position = Offset(canvasSize.width / 2, y);
      } else {
        final totalWidth = (nodes.length - 1) * minNodeSpacing * scale;
        final startX = (canvasSize.width - totalWidth) / 2;
        
        for (int i = 0; i < nodes.length; i++) {
          nodes[i].position = Offset(startX + i * minNodeSpacing * scale, y);
        }
      }
    }
  }

  static void _calculateRadialLayout(TreeNode root, Size canvasSize, double scale) {
    final center = Offset(canvasSize.width / 2, canvasSize.height / 2);
    root.position = center;
    
    _positionRadialChildren(root, center, 0, 2 * math.pi, 80 * scale, 1);
  }

  static void _positionRadialChildren(TreeNode node, Offset center, double startAngle, double endAngle, double radius, int level) {
    if (node.children.isEmpty || !node.isExpanded) return;
    
    final angleStep = (endAngle - startAngle) / node.children.length;
    
    for (int i = 0; i < node.children.length; i++) {
      final child = node.children[i];
      final angle = startAngle + (i + 0.5) * angleStep;
      
      child.position = Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      );
      
      final childStartAngle = angle - angleStep / 2;
      final childEndAngle = angle + angleStep / 2;
      
      _positionRadialChildren(child, child.position!, childStartAngle, childEndAngle, radius * 0.7, level + 1);
    }
  }

  static void _calculateOrganicLayout(TreeNode root, Size canvasSize, double scale) {
    final center = Offset(canvasSize.width / 2, canvasSize.height / 2);
    root.position = center;
    
    _positionOrganicChildren(root, center, scale);
  }

  static void _positionOrganicChildren(TreeNode node, Offset parentPos, double scale) {
    if (node.children.isEmpty || !node.isExpanded) return;
    
    final random = math.Random(node.id.hashCode);
    final baseDistance = 100 * scale;
    
    for (int i = 0; i < node.children.length; i++) {
      final child = node.children[i];
      final angle = (i / node.children.length) * 2 * math.pi + random.nextDouble() * 0.5;
      final distance = baseDistance + random.nextDouble() * 50 * scale;
      
      child.position = Offset(
        parentPos.dx + distance * math.cos(angle),
        parentPos.dy + distance * math.sin(angle),
      );
      
      _positionOrganicChildren(child, child.position!, scale);
    }
  }

  static void _calculateForceDirectedLayout(TreeNode root, Size canvasSize, double scale) {
    final allNodes = root.allNodes;
    final random = math.Random(42);
    
    // Initialize positions randomly
    for (final node in allNodes) {
      if (node == root) {
        node.position = Offset(canvasSize.width / 2, canvasSize.height / 2);
      } else {
        node.position = Offset(
          random.nextDouble() * canvasSize.width,
          random.nextDouble() * canvasSize.height,
        );
      }
    }
    
    // Apply force-directed algorithm
    for (int iteration = 0; iteration < 100; iteration++) {
      final forces = <TreeNode, Offset>{};
      
      // Initialize forces
      for (final node in allNodes) {
        forces[node] = Offset.zero;
      }
      
      // Repulsion forces
      for (int i = 0; i < allNodes.length; i++) {
        for (int j = i + 1; j < allNodes.length; j++) {
          final node1 = allNodes[i];
          final node2 = allNodes[j];
          final diff = node1.position! - node2.position!;
          final distance = math.max(diff.distance, 1.0);
          final repulsion = diff / distance * (1000 * scale / (distance * distance));
          
          forces[node1] = forces[node1]! + repulsion;
          forces[node2] = forces[node2]! - repulsion;
        }
      }
      
      // Attraction forces (for connected nodes)
      _applyAttractionForces(root, forces, scale);
      
      // Apply forces
      for (final node in allNodes) {
        if (node != root) {
          final force = forces[node]! * 0.1;
          node.position = node.position! + force;
        }
      }
    }
  }

  static void _applyAttractionForces(TreeNode node, Map<TreeNode, Offset> forces, double scale) {
    for (final child in node.children) {
      if (!node.isExpanded) continue;
      
      final diff = child.position! - node.position!;
      final distance = math.max(diff.distance, 1.0);
      final attraction = diff / distance * (distance - 100 * scale) * 0.5;
      
      forces[node] = forces[node]! + attraction;
      forces[child] = forces[child]! - attraction;
      
      _applyAttractionForces(child, forces, scale);
    }
  }

  static void _collectNodesByLevel(TreeNode node, int level, Map<int, List<TreeNode>> levelNodes) {
    levelNodes.putIfAbsent(level, () => []).add(node);
    
    if (node.isExpanded) {
      for (final child in node.children) {
        _collectNodesByLevel(child, level + 1, levelNodes);
      }
    }
  }
}

// Advanced Tree Painter with 3D effects and animations
class AdvancedTreePainter extends CustomPainter {
  final TreeNode rootNode;
  final String? activeNodeId;
  final String? hoveredNodeId;
  final Set<String> selectedNodes;
  final TreeLayout layout;
  final ViewMode viewMode;
  final Animation<double> animation;
  final bool showLabels;
  final bool show3D;
  final double scale;
  final bool isDarkMode;

  AdvancedTreePainter({
    required this.rootNode,
    this.activeNodeId,
    this.hoveredNodeId,
    this.selectedNodes = const {},
    this.layout = TreeLayout.hierarchical,
    this.viewMode = ViewMode.standard,
    required this.animation,
    this.showLabels = true,
    this.show3D = true,
    this.scale = 1.0,
    this.isDarkMode = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    AdvancedTreeLayoutCalculator.calculatePositions(rootNode, size, layout, scale);
    
    // Draw background effects
    _drawBackgroundEffects(canvas, size);
    
    // Draw edges with advanced styling
    _drawAdvancedEdges(canvas, rootNode);
    
    // Draw nodes with 3D effects
    _drawAdvancedNodes(canvas, rootNode);
    
    // Draw overlays and effects
    _drawOverlayEffects(canvas, size);
  }

  // Replace _drawBackgroundEffects with simpler version
void _drawBackgroundEffects(Canvas canvas, Size size) {
  // Simple subtle gradient background
  final gradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: isDarkMode
        ? [
            const Color(0xFF1a1a2e),
            const Color(0xFF16213e),
          ]
        : [
            const Color(0xFFF8FAFF),
            const Color(0xFFE8F4FD),
          ],
  );
  
  final gradientPaint = Paint()
    ..shader = gradient.createShader(Rect.fromLTWH(0, 0, size.width, size.height));
  
  canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), gradientPaint);
}

  void _drawAdvancedEdges(Canvas canvas, TreeNode node) {
    if (!node.isExpanded || node.position == null) return;
    
    for (final child in node.children) {
      if (child.position != null) {
        _drawAdvancedEdge(canvas, node, child);
      }
    }
    
    for (final child in node.children) {
      _drawAdvancedEdges(canvas, child);
    }
  }

  // Replace _drawAdvancedEdge with simpler version
void _drawAdvancedEdge(Canvas canvas, TreeNode parent, TreeNode child) {
  final start = parent.position!;
  final end = child.position!;
  
  // Simple straight line instead of curved path
  final edgePaint = Paint()
    ..color = selectedNodes.contains(parent.id) || selectedNodes.contains(child.id)
        ? parent.color
        : (isDarkMode ? Colors.grey[600]! : Colors.grey[400]!)
    ..strokeWidth = selectedNodes.contains(parent.id) || selectedNodes.contains(child.id) ? 2 : 1
    ..style = PaintingStyle.stroke;
  
  canvas.drawLine(start, end, edgePaint);
}

  void _drawEdgeParticles(Canvas canvas, Path path) {
    final pathMetrics = path.computeMetrics();
    for (final metric in pathMetrics) {
      for (int i = 0; i < 3; i++) {
        final progress = (animation.value + i * 0.33) % 1.0;
        final tangent = metric.getTangentForOffset(progress * metric.length);
        if (tangent != null) {
          final particlePaint = Paint()
            ..color = Colors.white.withOpacity(0.8)
            ..style = PaintingStyle.fill;
          
          canvas.drawCircle(tangent.position, 2, particlePaint);
        }
      }
    }
  }

  // Replace the _drawAdvancedNodes method with a simpler version
void _drawAdvancedNodes(Canvas canvas, TreeNode node) {
  if (node.position == null) return;
  
  final isActive = node.id == activeNodeId;
  final isHovered = node.id == hoveredNodeId;
  final isSelected = selectedNodes.contains(node.id);
  
  final nodeRadius = AdvancedTreeLayoutCalculator.baseNodeRadius * node.size * scale;
  final position = node.position!;
  
  // Simple shadow effect
  if (show3D) {
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.2)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    
    canvas.drawCircle(position + const Offset(2, 2), nodeRadius, shadowPaint);
  }
  
  // Main node - simple solid color
  final nodePaint = Paint()
    ..color = node.color
    ..style = PaintingStyle.fill;
  
  canvas.drawCircle(position, nodeRadius, nodePaint);
  
  // Simple border
  final borderWidth = isActive ? 3.0 : (isHovered ? 2.0 : 1.0);
  final borderColor = isActive ? Colors.white : Colors.black.withOpacity(0.3);
  
  final borderPaint = Paint()
    ..color = borderColor
    ..strokeWidth = borderWidth
    ..style = PaintingStyle.stroke;
  
  canvas.drawCircle(position, nodeRadius, borderPaint);
  
  // Node label
  if (showLabels) {
    _drawNodeLabel(canvas, node, position, nodeRadius, isActive);
  }
  
  // Collapse indicator (simple plus/minus)
  if (node.children.isNotEmpty && !node.isExpanded) {
    _drawCollapseIndicator(canvas, position, nodeRadius);
  }
  
  // Recursively draw children
  if (node.isExpanded) {
    for (final child in node.children) {
      _drawAdvancedNodes(canvas, child);
    }
  }
}
  void _drawCollapseIndicator(Canvas canvas, Offset position, double radius) {
  final indicatorPaint = Paint()
    ..color = Colors.white
    ..style = PaintingStyle.fill;
  
  // Draw a simple plus sign
  final indicatorSize = radius * 0.4;
  canvas.drawRect(
    Rect.fromCenter(
      center: position + Offset(0, radius + 10),
      width: indicatorSize * 2,
      height: indicatorSize / 3,
    ),
    indicatorPaint,
  );
  canvas.drawRect(
    Rect.fromCenter(
      center: position + Offset(0, radius + 10),
      width: indicatorSize / 3,
      height: indicatorSize * 2,
    ),
    indicatorPaint,
  );
}

void _drawNodeShape(Canvas canvas, Offset center, double radius, Paint paint) {
  // Only draw circles (removed shape variability)
  canvas.drawCircle(center, radius, paint);
}

void _drawNodeLabel(Canvas canvas, TreeNode node, Offset position, double radius, bool isActive) {
  final textStyle = TextStyle(
    fontSize: math.max(12, radius * 0.4),
    fontWeight: isActive ? FontWeight.bold : FontWeight.w600,
    color: _getContrastColor(node.color),
    shadows: [
      Shadow(
        offset: const Offset(1, 1),
        blurRadius: 2,
        color: Colors.black.withOpacity(0.3),
      ),
    ],
  );
  
  final textPainter = TextPainter(
    text: TextSpan(text: node.label, style: textStyle),
    textDirection: TextDirection.ltr,
    textAlign: TextAlign.center,
  );
  
  textPainter.layout();
  
  final labelOffset = position - Offset(textPainter.width / 2, textPainter.height / 2);
  textPainter.paint(canvas, labelOffset);
  
  // Description below node
  if (node.description != null && isActive) {
    final descStyle = TextStyle(
      fontSize: 10,
      color: isDarkMode ? Colors.grey[300] : Colors.grey[600],
    );
    
    final descPainter = TextPainter(
      text: TextSpan(text: node.description, style: descStyle),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    
    descPainter.layout(maxWidth: 100);
    final descOffset = position + Offset(-descPainter.width / 2, radius + 10);
    
    // Background for description
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          descOffset.dx - 5,
          descOffset.dy - 2,
          descPainter.width + 10,
          descPainter.height + 4,
        ),
        const Radius.circular(4),
      ),
      Paint()..color = Colors.black.withOpacity(0.7),
    );
    
    descPainter.paint(canvas, descOffset);
  }
}

void _drawNodeMetadata(Canvas canvas, TreeNode node, Offset position, double radius) {
  // Draw creation time indicator if recent
  final hoursSinceCreated = DateTime.now().difference(node.createdAt).inHours;
  if (hoursSinceCreated < 24) {
    final newIndicator = Paint()
      ..color = Colors.green
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(position + Offset(radius - 5, -radius + 5), 4, newIndicator);
  }
  
  // Draw child count
  if (node.children.isNotEmpty) {
    final countText = node.children.length.toString();
    final countStyle = TextStyle(
      fontSize: 10,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    );
    
    final countPainter = TextPainter(
      text: TextSpan(text: countText, style: countStyle),
      textDirection: TextDirection.ltr,
    );
    
    countPainter.layout();
    
    // Background circle
    canvas.drawCircle(
      position + Offset(radius - 8, radius - 8),
      8,
      Paint()..color = Colors.red,
    );
    
    // Count text
    countPainter.paint(
      canvas,
      position + Offset(radius - 8 - countPainter.width / 2, radius - 8 - countPainter.height / 2),
    );
  }
}
  void _drawOverlayEffects(Canvas canvas, Size size) {
    // Draw connection strength indicators for selected nodes
    if (selectedNodes.length > 1) {
      _drawConnectionStrengths(canvas);
    }
    
    // Draw performance metrics in presentation mode
    if (viewMode == ViewMode.presentation) {
      _drawPresentationOverlay(canvas, size);
    }
  }

  void _drawConnectionStrengths(Canvas canvas) {
    // Implementation for showing connection strengths between selected nodes
    final selectedNodesList = selectedNodes.map((id) => rootNode.findNode(id)).whereType<TreeNode>().toList();
    
    for (int i = 0; i < selectedNodesList.length; i++) {
      for (int j = i + 1; j < selectedNodesList.length; j++) {
        final node1 = selectedNodesList[i];
        final node2 = selectedNodesList[j];
        
        if (node1.position != null && node2.position != null) {
          final distance = (node1.position! - node2.position!).distance;
          final strength = math.max(0, 1 - distance / 500);
          
          if (strength > 0.1) {
            final connectionPaint = Paint()
              ..color = Colors.yellow.withOpacity(strength * 0.5)
              ..strokeWidth = strength * 5
              ..style = PaintingStyle.stroke;
            
            canvas.drawLine(node1.position!, node2.position!, connectionPaint);
          }
        }
      }
    }
  }

  void _drawPresentationOverlay(Canvas canvas, Size size) {
    // Draw tree statistics
    final statsText = 'Nodes: ${rootNode.totalDescendants + 1} | Depth: ${rootNode.depth + 1}';
    final statsStyle = TextStyle(
      fontSize: 14,
      color: isDarkMode ? Colors.white70 : Colors.black54,
      fontWeight: FontWeight.w500,
    );
    
    final statsPainter = TextPainter(
      text: TextSpan(text: statsText, style: statsStyle),
      textDirection: TextDirection.ltr,
    );
    
    statsPainter.layout();
    statsPainter.paint(canvas, Offset(20, size.height - 40));
  }

  Color _getContrastColor(Color color) {
    return color.computeLuminance() > 0.5 ? Colors.black : Colors.white;
  }

  @override
  bool shouldRepaint(AdvancedTreePainter oldDelegate) {
    return oldDelegate.rootNode != rootNode ||
           oldDelegate.activeNodeId != activeNodeId ||
           oldDelegate.hoveredNodeId != hoveredNodeId ||
           oldDelegate.selectedNodes != selectedNodes ||
           oldDelegate.layout != layout ||
           oldDelegate.viewMode != viewMode ||
           oldDelegate.animation.value != animation.value ||
           oldDelegate.showLabels != showLabels ||
           oldDelegate.show3D != show3D ||
           oldDelegate.scale != scale ||
           oldDelegate.isDarkMode != isDarkMode;
  }
}

// Interactive Tree Widget with advanced features
class InteractiveAdvancedTreeWidget extends StatelessWidget {
  final TreeNode rootNode;
  final String? activeNodeId;
  final String? hoveredNodeId;
  final Set<String> selectedNodes;
  final Function(String) onNodeTap;
  final Function(String) onNodeDoubleTap;
  final Function(String) onNodeHover;
  final Function(String) onNodeRightClick;
  final TreeLayout layout;
  final ViewMode viewMode;
  final Animation<double> animation;
  final bool showLabels;
  final bool show3D;
  final double scale;
  final bool isDarkMode;

  const InteractiveAdvancedTreeWidget({
    super.key,
    required this.rootNode,
    this.activeNodeId,
    this.hoveredNodeId,
    this.selectedNodes = const {},
    required this.onNodeTap,
    required this.onNodeDoubleTap,
    required this.onNodeHover,
    required this.onNodeRightClick,
    this.layout = TreeLayout.hierarchical,
    this.viewMode = ViewMode.standard,
    required this.animation,
    this.showLabels = true,
    this.show3D = true,
    this.scale = 1.0,
    this.isDarkMode = false,
  });

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onHover: (event) {
        final hitNode = _findHitNode(event.localPosition, rootNode);
        if (hitNode != null) {
          onNodeHover(hitNode.id);
        }
      },
      child: GestureDetector(
        onTapUp: (details) {
          final hitNode = _findHitNode(details.localPosition, rootNode);
          if (hitNode != null) {
            onNodeTap(hitNode.id);
          }
        },
        onDoubleTapDown: (details) {
          final hitNode = _findHitNode(details.localPosition, rootNode);
          if (hitNode != null && hitNode.children.isNotEmpty) {
            onNodeDoubleTap(hitNode.id);
          }
        },
        onSecondaryTapUp: (details) {
          final hitNode = _findHitNode(details.localPosition, rootNode);
          if (hitNode != null) {
            onNodeRightClick(hitNode.id);
          }
        },
        child: CustomPaint(
          painter: AdvancedTreePainter(
            rootNode: rootNode,
            activeNodeId: activeNodeId,
            hoveredNodeId: hoveredNodeId,
            selectedNodes: selectedNodes,
            layout: layout,
            viewMode: viewMode,
            animation: animation,
            showLabels: showLabels,
            show3D: show3D,
            scale: scale,
            isDarkMode: isDarkMode,
          ),
          size: Size.infinite,
        ),
      ),
    );
  }

  TreeNode? _findHitNode(Offset tapPosition, TreeNode node) {
    if (node.position != null) {
      final distance = (tapPosition - node.position!).distance;
      final nodeRadius = AdvancedTreeLayoutCalculator.baseNodeRadius * node.size * scale;
      if (distance <= nodeRadius) {
        return node;
      }
    }

    if (node.isExpanded) {
      for (final child in node.children) {
        final hit = _findHitNode(tapPosition, child);
        if (hit != null) return hit;
      }
    }

    return null;
  }
}

// Node Properties Panel
class NodePropertiesPanel extends StatefulWidget {
  final TreeNode? selectedNode;
  final Function(TreeNode) onNodeUpdate;
  final VoidCallback onClose;

  const NodePropertiesPanel({
    super.key,
    this.selectedNode,
    required this.onNodeUpdate,
    required this.onClose,
  });

  @override
  State<NodePropertiesPanel> createState() => _NodePropertiesPanelState();
}

class _NodePropertiesPanelState extends State<NodePropertiesPanel> {
  late TextEditingController _labelController;
  late TextEditingController _descriptionController;
  late Color _selectedColor;
  late double _selectedSize;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    final node = widget.selectedNode;
    _labelController = TextEditingController(text: node?.label ?? '');
    _descriptionController = TextEditingController(text: node?.description ?? '');
    _selectedColor = node?.color ?? Colors.blue;
    _selectedSize = node?.size ?? 1.0;
  }

  @override
  void didUpdateWidget(NodePropertiesPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedNode != oldWidget.selectedNode) {
      _initializeControllers();
    }
  }

  @override
  void dispose() {
    _labelController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.selectedNode == null) {
      return const SizedBox.shrink();
    }

    return Container(
      width: 300,
      height: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(-2, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              border: Border(
                bottom: BorderSide(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                ),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.settings,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
                const SizedBox(width: 8),
                Text(
                  'Node Properties',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: widget.onClose,
                  icon: const Icon(Icons.close),
                  iconSize: 20,
                ),
              ],
            ),
          ),
          
          // Properties
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Label
                Text(
                  'Label',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _labelController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Enter node label',
                  ),
                ),
                const SizedBox(height: 16),
                
                // Description
                Text(
                  'Description',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _descriptionController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Enter node description',
                  ),
                ),
                const SizedBox(height: 16),
                
                // Color
                Text(
                  'Color',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    Colors.blue,
                    Colors.red,
                    Colors.green,
                    Colors.orange,
                    Colors.purple,
                    Colors.teal,
                    Colors.amber,
                    Colors.pink,
                  ].map((color) => GestureDetector(
                    onTap: () => setState(() => _selectedColor = color),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: _selectedColor == color
                            ? Border.all(color: Colors.white, width: 3)
                            : null,
                      ),
                    ),
                  )).toList(),
                ),
                const SizedBox(height: 16),
                
                // Size
                Text(
                  'Size: ${_selectedSize.toStringAsFixed(1)}',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                const SizedBox(height: 8),
                Slider(
                  value: _selectedSize,
                  min: 0.5,
                  max: 2.0,
                  divisions: 15,
                  onChanged: (size) => setState(() => _selectedSize = size),
                ),
                const SizedBox(height: 24),
                
                // Apply Button
                FilledButton.icon(
                  onPressed: _applyChanges,
                  icon: const Icon(Icons.check),
                  label: const Text('Apply Changes'),
                ),
                const SizedBox(height: 8),
                
                // Node Statistics
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Statistics',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        const SizedBox(height: 8),
                        Text('ID: ${widget.selectedNode!.id}'),
                        Text('Children: ${widget.selectedNode!.children.length}'),
                        Text('Descendants: ${widget.selectedNode!.totalDescendants}'),
                        Text('Depth: ${widget.selectedNode!.depth}'),
                        Text('Created: ${_formatDate(widget.selectedNode!.createdAt)}'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _applyChanges() {
    final node = widget.selectedNode!;
    node.label = _labelController.text;
    node.description = _descriptionController.text.isEmpty ? null : _descriptionController.text;
    node.color = _selectedColor;
    node.size = _selectedSize;
    
    widget.onNodeUpdate(node);
    
    // Show notification instead of snackbar
    _showNotification('Node properties updated', Colors.green);
  }

  void _showNotification(String message, Color color) {
    OverlayEntry overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: 16,
        right: 16,
        child: CustomNotification(
          message: message,
          backgroundColor: color,
        ),
      ),
    );
    
    Overlay.of(context).insert(overlayEntry);
    
    // Remove overlay after duration
    Future.delayed(const Duration(seconds: 2), () {
      overlayEntry.remove();
    });
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

// Main Screen Widget with all advanced features
class TreeVisualizerScreen extends StatefulWidget {
  const TreeVisualizerScreen({super.key});

  @override
  State<TreeVisualizerScreen> createState() => _TreeVisualizerScreenState();
}

class _TreeVisualizerScreenState extends State<TreeVisualizerScreen>
    with TickerProviderStateMixin {
  late TreeNode rootNode;
  String? activeNodeId;
  String? hoveredNodeId;
  Set<String> selectedNodes = {};
  int _nodeCounter = 1;
  TreeLayout currentLayout = TreeLayout.hierarchical;
  ViewMode currentViewMode = ViewMode.standard;
  bool showLabels = true;
  bool show3D = true;
  double currentScale = 1.0;
  bool showPropertiesPanel = false;
  
  late AnimationController _animationController;
  late AnimationController _layoutAnimationController;
  late Animation<double> _scaleAnimation;
  final TransformationController _transformationController = TransformationController();

  @override
  void initState() {
    super.initState();
    _initializeTree();
    _initializeAnimations();
  }

  void _initializeTree() {
    rootNode = TreeNode(
      id: '1',
      label: '1',
      color: Colors.indigo,
      description: 'Root Node',
    );
    activeNodeId = '1';
  }

  // Replace the existing _initializeAnimations method
void _initializeAnimations() {
  _animationController = AnimationController(
    duration: const Duration(milliseconds: 1000),
    vsync: this,
  )..repeat();
  
  // Remove the complex layout animation controller
  // and replace with a simple one for basic pulsing
  _layoutAnimationController = AnimationController(
    duration: const Duration(milliseconds: 300),
    vsync: this,
  );
  
  _scaleAnimation = Tween<double>(
    begin: 1.0,
    end: 1.0, // No scaling animation
  ).animate(CurvedAnimation(
    parent: _layoutAnimationController,
    curve: Curves.easeOut,
  ));
}

// Replace the _addChildNode method with simpler animation
void _addChildNode({Color? color}) {
  if (activeNodeId == null) return;
  
  final activeNode = rootNode.findNode(activeNodeId!);
  if (activeNode == null) return;
  
  _nodeCounter++;
  final colors = [Colors.blue, Colors.red, Colors.green, Colors.orange, Colors.purple];
  
  final newChild = TreeNode(
    id: _nodeCounter.toString(),
    label: _nodeCounter.toString(),
    color: color ?? colors[(_nodeCounter - 1) % colors.length],
    description: 'Node $_nodeCounter - Child of ${activeNode.label}',
  );
  
  activeNode.addChild(newChild);
  
  setState(() {});
  
  // Simple brief animation instead of complex one
  _layoutAnimationController.forward().then((_) {
    _layoutAnimationController.reset();
  });
  
  HapticFeedback.lightImpact();
  _showNotification('Added node $_nodeCounter', Colors.green);
}

@override
void dispose() {
  _animationController.dispose();
  _layoutAnimationController.dispose();
  _transformationController.dispose();
  super.dispose();
}

  void _deleteNode() {
    if (activeNodeId == null || activeNodeId == '1') return;
    
    final nodeToDelete = rootNode.findNode(activeNodeId!);
    final childCount = nodeToDelete?.totalDescendants ?? 0;
    
    _deleteNodeRecursive(rootNode, activeNodeId!);
    selectedNodes.remove(activeNodeId);
    
    setState(() {
      activeNodeId = '1';
    });
    
    HapticFeedback.mediumImpact();
    _showNotification(
      'Deleted node and ${childCount > 0 ? '$childCount children' : 'no children'}',
      Colors.red,
    );
  }

  bool _deleteNodeRecursive(TreeNode parent, String targetId) {
    for (int i = 0; i < parent.children.length; i++) {
      if (parent.children[i].id == targetId) {
        parent.children.removeAt(i);
        return true;
      }
      
      if (_deleteNodeRecursive(parent.children[i], targetId)) {
        return true;
      }
    }
    return false;
  }

  void _toggleNodeExpansion(String nodeId) {
    final node = rootNode.findNode(nodeId);
    if (node != null && node.children.isNotEmpty) {
      setState(() {
        node.isExpanded = !node.isExpanded;
      });
      
      HapticFeedback.selectionClick();
      _showNotification(
        'Node $nodeId ${node.isExpanded ? 'expanded' : 'collapsed'}',
        Colors.blue,
      );
    }
  }

  void _resetView() {
    _transformationController.value = Matrix4.identity();
    setState(() {
      activeNodeId = '1';
      selectedNodes.clear();
      hoveredNodeId = null;
      currentScale = 1.0;
    });
  }

  void _changeLayout(TreeLayout newLayout) {
    setState(() {
      currentLayout = newLayout;
    });
    
    HapticFeedback.selectionClick();
    _showNotification('Layout changed to ${newLayout.name}', Colors.blue);
  }

  void _toggleSelection(String nodeId) {
    setState(() {
      if (selectedNodes.contains(nodeId)) {
        selectedNodes.remove(nodeId);
      } else {
        selectedNodes.add(nodeId);
      }
    });
  }

  void _showNodeContextMenu(String nodeId, Offset position) {
    final node = rootNode.findNode(nodeId);
    if (node == null) return;
    
    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(position.dx, position.dy, position.dx, position.dy),
      items: [
        PopupMenuItem(
          child: const ListTile(
            leading: Icon(Icons.edit),
            title: Text('Edit Properties'),
            dense: true,
          ),
          onTap: () {
            setState(() {
              activeNodeId = nodeId;
              showPropertiesPanel = true;
            });
          },
        ),
        PopupMenuItem(
          child: const ListTile(
            leading: Icon(Icons.add),
            title: Text('Add Child'),
            dense: true,
          ),
          onTap: () {
            setState(() => activeNodeId = nodeId);
            _addChildNode();
          },
        ),
        if (nodeId != '1')
          PopupMenuItem(
            child: const ListTile(
              leading: Icon(Icons.delete),
              title: Text('Delete'),
              dense: true,
            ),
            onTap: () {
              setState(() => activeNodeId = nodeId);
              _deleteNode();
            },
          ),
        PopupMenuItem(
          child: ListTile(
            leading: Icon(selectedNodes.contains(nodeId) ? Icons.check_box : Icons.check_box_outline_blank),
            title: const Text('Toggle Selection'),
            dense: true,
          ),
          onTap: () => _toggleSelection(nodeId),
        ),
      ],
    );
  }

  void _showNotification(String message, Color color, {NotificationPosition position = NotificationPosition.topRight}) {
    OverlayEntry overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: position.toString().contains('top') ? 16 : null,
        bottom: position.toString().contains('bottom') ? 16 : null,
        left: position.toString().contains('Left') ? 16 : null,
        right: position.toString().contains('Right') ? 16 : null,
        child: Align(
          alignment: _getAlignment(position),
          child: CustomNotification(
            message: message,
            backgroundColor: color,
            position: position,
          ),
        ),
      ),
    );
    
    Overlay.of(context).insert(overlayEntry);
    
    // Remove overlay after duration
    Future.delayed(const Duration(seconds: 2), () {
      overlayEntry.remove();
    });
  }

  Alignment _getAlignment(NotificationPosition position) {
    switch (position) {
      case NotificationPosition.topRight:
        return Alignment.topRight;
      case NotificationPosition.topLeft:
        return Alignment.topLeft;
      case NotificationPosition.bottomRight:
        return Alignment.bottomRight;
      case NotificationPosition.bottomLeft:
        return Alignment.bottomLeft;
    }
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Settings'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SwitchListTile(
              title: const Text('Show Labels'),
              value: showLabels,
              onChanged: (value) => setState(() => showLabels = value),
            ),
            SwitchListTile(
              title: const Text('3D Effects'),
              value: show3D,
              onChanged: (value) => setState(() => show3D = value),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: _buildAppBar(),
      body: Row(
        children: [
          // Main tree view
          Expanded(
            child: Column(
              children: [
                _buildControlPanel(),
                _buildStatusBar(),
                Expanded(child: _buildTreeView(isDarkMode)),
              ],
            ),
          ),
          
          // Properties panel
          if (showPropertiesPanel)
            NodePropertiesPanel(
              selectedNode: rootNode.findNode(activeNodeId ?? ''),
              onNodeUpdate: (node) => setState(() {}),
              onClose: () => setState(() => showPropertiesPanel = false),
            ),
        ],
      ),
      floatingActionButton: _buildFloatingActionButtons(),
      drawer: _buildDrawer(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text(
        'Advanced Tree Visualizer',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
      elevation: 0,
      actions: [
        PopupMenuButton<TreeLayout>(
          icon: const Icon(Icons.account_tree),
          tooltip: 'Change Layout',
          onSelected: _changeLayout,
          itemBuilder: (context) => TreeLayout.values.map((layout) {
            return PopupMenuItem(
              value: layout,
              child: Row(
                children: [
                  if (layout == currentLayout) const Icon(Icons.check, size: 16),
                  if (layout == currentLayout) const SizedBox(width: 8),
                  Text(layout.name.toUpperCase()),
                ],
              ),
            );
          }).toList(),
        ),
        IconButton(
          icon: const Icon(Icons.settings),
          tooltip: 'Settings',
          onPressed: _showSettingsDialog,
        ),
        IconButton(
          icon: const Icon(Icons.center_focus_strong),
          tooltip: 'Reset View',
          onPressed: _resetView,
        ),
        IconButton(
          icon: Icon(showPropertiesPanel ? Icons.close : Icons.tune),
          tooltip: showPropertiesPanel ? 'Hide Properties' : 'Show Properties',
          onPressed: () => setState(() => showPropertiesPanel = !showPropertiesPanel),
        ),
      ],
    );
  }

  Widget _buildControlPanel() {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surface,
      border: Border(
        bottom: BorderSide(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
    ),
    child: Wrap(
      spacing: 12,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: [
        FilledButton.icon(
          onPressed: _addChildNode,
          icon: const Icon(Icons.add),
          label: const Text('Add Child'),
        ),
        FilledButton.tonalIcon(
          onPressed: activeNodeId != '1' ? _deleteNode : null,
          icon: const Icon(Icons.remove),
          label: const Text('Delete Node'),
        ),
        OutlinedButton.icon(
          onPressed: _resetView,
          icon: const Icon(Icons.center_focus_strong),
          label: const Text('Reset View'),
        ),
        if (selectedNodes.isNotEmpty)
          FilledButton.icon(
            onPressed: () => setState(() => selectedNodes.clear()),
            icon: const Icon(Icons.clear),
            label: Text('Clear (${selectedNodes.length})'),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
          ),
      ],
    ),
  ); // Added missing closing parenthesis
}

  Widget _buildStatusBar() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
          ),
        ),
      ),
      child: Wrap(
        spacing: 24,
        runSpacing: 8,
        children: [
          _buildStatusItem('Active', activeNodeId ?? 'None'),
          _buildStatusItem('Total Nodes', '${rootNode.totalDescendants + 1}'),
          _buildStatusItem('Max Depth', '${rootNode.depth + 1}'),
          _buildStatusItem('Selected', '${selectedNodes.length}'),
          _buildStatusItem('Layout', currentLayout.name.toUpperCase()),
          if (hoveredNodeId != null)
            _buildStatusItem('Hovered', hoveredNodeId!),
        ],
      ),
    );
  }

  Widget _buildStatusItem(String label, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$label: ',
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildTreeView(bool isDarkMode) {
    return InteractiveViewer(
      transformationController: _transformationController,
      constrained: false,
      boundaryMargin: const EdgeInsets.all(200),
      minScale: 0.1,
      maxScale: 5.0,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Container(
            width: math.max(1200, MediaQuery.of(context).size.width * 1.5),
            height: math.max(800, MediaQuery.of(context).size.height * 2),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDarkMode
                    ? [
                        const Color(0xFF1a1a2e),
                        const Color(0xFF16213e),
                        const Color(0xFF0f3460),
                      ]
                    : [
                        const Color(0xFFF8FAFF),
                        const Color(0xFFE8F4FD),
                        const Color(0xFFDCEDFF),
                      ],
              ),
            ),
            child: InteractiveAdvancedTreeWidget(
              rootNode: rootNode,
              activeNodeId: activeNodeId,
              hoveredNodeId: hoveredNodeId,
              selectedNodes: selectedNodes,
              layout: currentLayout,
              viewMode: currentViewMode,
              animation: _animationController,
              showLabels: showLabels,
              show3D: show3D,
              scale: currentScale * _scaleAnimation.value,
              isDarkMode: isDarkMode,
              onNodeTap: (nodeId) {
                setState(() {
                  activeNodeId = nodeId;
                });
                HapticFeedback.selectionClick();
              },
              onNodeDoubleTap: _toggleNodeExpansion,
              onNodeHover: (nodeId) {
                setState(() {
                  hoveredNodeId = nodeId;
                });
              },
              onNodeRightClick: (nodeId) {
                // Context menu will be shown at the cursor position
                _showNodeContextMenu(nodeId, Offset.zero);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildFloatingActionButtons() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FloatingActionButton(
          heroTag: "add",
          onPressed: _addChildNode,
          backgroundColor: Colors.green,
          tooltip: 'Add Child Node',
          child: const Icon(Icons.add, color: Colors.white),
        ),
        const SizedBox(height: 12),
        FloatingActionButton(
          heroTag: "delete",
          onPressed: activeNodeId != '1' ? _deleteNode : null,
          backgroundColor: activeNodeId != '1' ? Colors.red : Colors.grey,
          tooltip: activeNodeId != '1' ? 'Delete Node' : 'Cannot delete root',
          child: const Icon(Icons.remove, color: Colors.white),
        ),
        const SizedBox(height: 12),
        FloatingActionButton.small(
          heroTag: "zoom_in",
          onPressed: () => setState(() => currentScale = (currentScale * 1.2).clamp(0.5, 3.0)),
          tooltip: 'Zoom In',
          child: const Icon(Icons.zoom_in, size: 16),
        ),
        const SizedBox(height: 8),
        FloatingActionButton.small(
          heroTag: "zoom_out",
          onPressed: () => setState(() => currentScale = (currentScale * 0.8).clamp(0.5, 3.0)),
          tooltip: 'Zoom Out',
          child: const Icon(Icons.zoom_out, size: 16),
        ),
      ],
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.primaryContainer,
                ],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.account_tree,
                  size: 40,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
                const SizedBox(height: 16),
                Text(
                  'Tree Visualizer',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Advanced Features',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
          
          // Layout Section
          ExpansionTile(
            leading: const Icon(Icons.account_tree),
            title: const Text('Layout Options'),
            children: TreeLayout.values.map((layout) {
              return ListTile(
                title: Text(layout.name.toUpperCase()),
                leading: Radio<TreeLayout>(
                  value: layout,
                  groupValue: currentLayout,
                  onChanged: (value) {
                    if (value != null) {
                      _changeLayout(value);
                      Navigator.pop(context);
                    }
                  },
                ),
                onTap: () {
                  _changeLayout(layout);
                  Navigator.pop(context);
                },
              );
            }).toList(),
          ),
          
          // View Options
          ExpansionTile(
            leading: const Icon(Icons.visibility),
            title: const Text('View Options'),
            children: [
              SwitchListTile(
                title: const Text('Show Labels'),
                subtitle: const Text('Display node labels'),
                value: showLabels,
                onChanged: (value) => setState(() => showLabels = value),
              ),
              SwitchListTile(
                title: const Text('3D Effects'),
                subtitle: const Text('Enable 3D visual effects'),
                value: show3D,
                onChanged: (value) => setState(() => show3D = value),
              ),
              ListTile(
                title: const Text('Scale'),
                subtitle: Text('Current: ${currentScale.toStringAsFixed(1)}x'),
                trailing: SizedBox(
                  width: 150,
                  child: Slider(
                    value: currentScale,
                    min: 0.5,
                    max: 3.0,
                    divisions: 25,
                    onChanged: (value) => setState(() => currentScale = value),
                  ),
                ),
              ),
            ],
          ),
          
          // Quick Actions
          ExpansionTile(
            leading: const Icon(Icons.flash_on),
            title: const Text('Quick Actions'),
            children: [
              ListTile(
                leading: const Icon(Icons.add_box),
                title: const Text('Add Random Tree'),
                onTap: _addRandomTree,
              ),
              ListTile(
                leading: const Icon(Icons.colorize),
                title: const Text('Randomize Colors'),
                onTap: _randomizeColors,
              ),
              ListTile(
                leading: const Icon(Icons.expand_more),
                title: const Text('Expand All'),
                onTap: _expandAll,
              ),
              ListTile(
                leading: const Icon(Icons.expand_less),
                title: const Text('Collapse All'),
                onTap: _collapseAll,
              ),
              ListTile(
                leading: const Icon(Icons.clear_all),
                title: const Text('Clear Tree'),
                onTap: _clearTree,
              ),
            ],
          ),
          
          const Divider(),
          
          // Statistics
          ListTile(
            leading: const Icon(Icons.analytics),
            title: const Text('Tree Statistics'),
            onTap: _showStatistics,
          ),
          
          ListTile(
            leading: const Icon(Icons.help_outline),
            title: const Text('Help & Tips'),
            onTap: _showHelpDialog,
          ),
          
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('About'),
            onTap: _showAboutDialog,
          ),
        ],
      ),
    );
  }

  void _addRandomTree() {
    final random = math.Random();
    final colors = [Colors.red, Colors.green, Colors.blue, Colors.orange, Colors.purple];
    
    void addRandomChildren(TreeNode parent, int maxDepth, int currentDepth) {
      if (currentDepth >= maxDepth) return;
      
      final childCount = random.nextInt(4) + 1; // 1-4 children
      
      for (int i = 0; i < childCount; i++) {
        _nodeCounter++;
        final child = TreeNode(
          id: _nodeCounter.toString(),
          label: _nodeCounter.toString(),
          color: colors[random.nextInt(colors.length)],
          size: 0.8 + random.nextDouble() * 0.4, // 0.8 - 1.2
          description: 'Random node $_nodeCounter',
        );
        
        parent.addChild(child);
        
        if (random.nextBool()) {
          addRandomChildren(child, maxDepth, currentDepth + 1);
        }
      }
    }
    
    final activeNode = rootNode.findNode(activeNodeId ?? '1');
    if (activeNode != null) {
      addRandomChildren(activeNode, 3, 0);
      setState(() {});
      _showNotification('Added random tree structure', Colors.green);
    }
  }

  void _randomizeColors() {
    final colors = [
      Colors.red, Colors.blue, Colors.green, Colors.orange, 
      Colors.purple, Colors.teal, Colors.amber, Colors.pink,
      Colors.indigo, Colors.cyan, Colors.lime, Colors.deepOrange,
    ];
    final random = math.Random();
    
    void randomizeNodeColors(TreeNode node) {
      node.color = colors[random.nextInt(colors.length)];
      for (final child in node.children) {
        randomizeNodeColors(child);
      }
    }
    
    randomizeNodeColors(rootNode);
    setState(() {});
    _showNotification('Colors randomized successfully', Colors.blue);
  }

  void _expandAll() {
    void expandNode(TreeNode node) {
      node.isExpanded = true;
      for (final child in node.children) {
        expandNode(child);
      }
    }
    
    expandNode(rootNode);
    setState(() {});
    _showNotification('All nodes expanded', Colors.green);
  }

  void _collapseAll() {
    void collapseNode(TreeNode node) {
      if (node != rootNode) {
        node.isExpanded = false;
      }
      for (final child in node.children) {
        collapseNode(child);
      }
    }
    
    collapseNode(rootNode);
    setState(() {});
    _showNotification('All nodes collapsed', Colors.orange);
  }

  void _clearTree() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Tree'),
        content: const Text('Are you sure you want to clear the entire tree? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                rootNode.children.clear();
                _nodeCounter = 1;
                activeNodeId = '1';
                selectedNodes.clear();
                hoveredNodeId = null;
              });
              _showNotification('Tree cleared successfully', Colors.red);
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _showStatistics() {
    final stats = _calculateTreeStatistics();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tree Statistics'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildStatRow('Total Nodes', stats['totalNodes'].toString()),
              _buildStatRow('Maximum Depth', stats['maxDepth'].toString()),
              _buildStatRow('Average Children', stats['avgChildren'].toStringAsFixed(1)),
              _buildStatRow('Leaf Nodes', stats['leafNodes'].toString()),
              _buildStatRow('Selected Nodes', selectedNodes.length.toString()),
              const Divider(),
              const Text('Node Colors:', style: TextStyle(fontWeight: FontWeight.bold)),
              ...stats['colorStats'].entries.map((entry) => 
                _buildStatRow(entry.key, entry.value.toString())),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

Widget _buildStatRow(String label, String value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    ),
  ); // Added missing closing parenthesis
}

Map<String, dynamic> _calculateTreeStatistics() {
  final allNodes = rootNode.allNodes;
  final leafNodes = allNodes.where((node) => node.children.isEmpty).length;
  final totalChildren = allNodes.map((node) => node.children.length).reduce((a, b) => a + b);
  final avgChildren = allNodes.isNotEmpty ? totalChildren / allNodes.length : 0.0;
  
  final colorStats = <String, int>{};
  
  for (final node in allNodes) {
    final colorName = _getColorName(node.color);
    colorStats[colorName] = (colorStats[colorName] ?? 0) + 1; // Fixed logical OR to null coalescing
  }
  
  return {
    'totalNodes': allNodes.length,
    'maxDepth': rootNode.depth + 1,
    'avgChildren': avgChildren,
    'leafNodes': leafNodes,
    'colorStats': colorStats,
  };
}

  String _getColorName(Color color) {
    if (color == Colors.red) return 'Red';
    if (color == Colors.blue) return 'Blue';
    if (color == Colors.green) return 'Green';
    if (color == Colors.orange) return 'Orange';
    if (color == Colors.purple) return 'Purple';
    if (color == Colors.teal) return 'Teal';
    if (color == Colors.amber) return 'Amber';
    if (color == Colors.pink) return 'Pink';
    if (color == Colors.indigo) return 'Indigo';
    if (color == Colors.cyan) return 'Cyan';
    return 'Other';
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Help & Tips'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('🖱️ Mouse Controls:', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('• Single click: Select node'),
              Text('• Double click: Expand/collapse node'),
              Text('• Right click: Show context menu'),
              Text('• Mouse hover: Preview node'),
              SizedBox(height: 16),
              Text('📱 Touch Controls:', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('• Tap: Select node'),
              Text('• Double tap: Expand/collapse'),
              Text('• Pinch: Zoom in/out'),
              Text('• Drag: Pan view'),
              SizedBox(height: 16),
              Text('⌨️ Keyboard Shortcuts:', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('• Space: Add child to active node'),
              Text('• Delete: Remove active node'),
              Text('• Escape: Clear selection'),
              Text('• R: Reset view'),
              SizedBox(height: 16),
              Text('✨ Pro Tips:', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('• Use different layouts for better visualization'),
              Text('• Enable 3D effects for enhanced graphics'),
              Text('• Use properties panel to customize nodes'),
              Text('• Select multiple nodes to see connections'),
              Text('• Use drawer menu for quick actions'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it!'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog() {
    showAboutDialog(
      context: context,
      applicationName: 'Advanced Tree Visualizer',
      applicationVersion: '2.0.0',
      applicationIcon: const Icon(Icons.account_tree, size: 64),
      children: [
        const Text(
          'A powerful and beautiful tree visualization tool built with Flutter. '
          'Features advanced graphics, multiple layouts, 3D effects, and comprehensive '
          'node management capabilities.',
        ),
        const SizedBox(height: 16),
        const Text(
          'Features:',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const Text('• Multiple tree layout algorithms'),
        const Text('• 3D visual effects and animations'),
        const Text('• Interactive node editing'),
        const Text('• Advanced selection and filtering'),
        const Text('• Comprehensive statistics'),
        const Text('• Export and import capabilities'),
        const Text('• Responsive design for all screen sizes'),
      ],
    );
  }
}