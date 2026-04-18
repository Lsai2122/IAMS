import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class SmartWatchSlider extends StatefulWidget {
  final int selectedIndex;
  final Function(int) onPageChanged;
  final List<IconData> icons;

  const SmartWatchSlider({
    super.key,
    required this.selectedIndex,
    required this.onPageChanged,
    required this.icons,
  });

  @override
  State<SmartWatchSlider> createState() => _SmartWatchSliderState();
}

class _SmartWatchSliderState extends State<SmartWatchSlider> with SingleTickerProviderStateMixin {
  late FixedExtentScrollController _controller;
  bool _isExpanded = false;
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  
  final int _loopFactor = 1000;

  @override
  void initState() {
    super.initState();
    _controller = FixedExtentScrollController(
      initialItem: _getInitialItem(widget.selectedIndex),
    );
    
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    
    _slideAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );
  }

  int _getInitialItem(int index) {
    int safeIndex = index >= 0 ? index : 0;
    return safeIndex + (widget.icons.length * (_loopFactor ~/ 2));
  }

  @override
  void didUpdateWidget(SmartWatchSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_isExpanded && oldWidget.selectedIndex != widget.selectedIndex) {
      _controller.jumpToItem(_getInitialItem(widget.selectedIndex));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _toggleExpanded(bool expand) {
    if (expand == _isExpanded) return;
    setState(() => _isExpanded = expand);
    if (expand) {
      _animationController.forward();
      _controller.jumpToItem(_getInitialItem(widget.selectedIndex));
    } else {
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    const double expandedSize = 120.0;
    const double collapsedSize = 40.0;
    // Fix: Defined a constant interaction height to maintain the center point
    const double interactionHeight = expandedSize * 2.2;

    IconData currentIcon = widget.selectedIndex >= 0 ? widget.icons[widget.selectedIndex] : Icons.apps;

    return AnimatedBuilder(
      animation: _slideAnimation,
      builder: (context, child) {
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => _toggleExpanded(!_isExpanded),
          child: MouseRegion(
            onEnter: (_) => _toggleExpanded(true),
            onExit: (_) => _toggleExpanded(false),
            child: SizedBox(
              height: interactionHeight, // Keep height constant so center doesn't move
              child: Stack(
                alignment: Alignment.centerRight,
                children: [
                  // THE SEMI-CIRCLE MENU
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOutCubic,
                    width: _isExpanded ? expandedSize : collapsedSize,
                    height: _isExpanded ? interactionHeight : collapsedSize,
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor.withOpacity(0.5),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(expandedSize),
                        bottomLeft: Radius.circular(expandedSize),
                      ),
                    ),
                    child: _isExpanded ? Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ListWheelScrollView.useDelegate(
                        controller: _controller,
                        itemExtent: 50,
                        perspective: 0.01,
                        diameterRatio: 1.0,
                        offAxisFraction: -1.6,
                        physics: const FixedExtentScrollPhysics(),
                        onSelectedItemChanged: (index) {
                          widget.onPageChanged(index % widget.icons.length);
                        },
                        childDelegate: ListWheelChildBuilderDelegate(
                          builder: (context, index) {
                            final actualIndex = index % widget.icons.length;
                            final isSelected = widget.selectedIndex >= 0 && actualIndex == widget.selectedIndex;
                            
                            return Center(
                              child: AnimatedScale(
                                scale: isSelected ? 1.0 : 0.6,
                                duration: const Duration(milliseconds: 200),
                                child: Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    gradient: isSelected ? AppTheme.primaryGradient : null,
                                    color: isSelected ? null : AppTheme.lightBlue.withOpacity(0.2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    widget.icons[actualIndex],
                                    color: isSelected ? Colors.white : AppTheme.primaryBlue,
                                    size: 16,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ) : const SizedBox.shrink(),
                  ),

                  // THE INACTIVE BALL
                  if (!_isExpanded)
                    Container(
                      width: collapsedSize,
                      height: collapsedSize,
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor.withOpacity(0.6),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            gradient: AppTheme.primaryGradient,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            currentIcon,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
