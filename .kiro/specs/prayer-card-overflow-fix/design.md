# Design Document

## Overview

The prayer card overflow issue stems from the rigid layout structure that doesn't adapt to different screen sizes. The current implementation uses fixed heights and spacing that cause content to overflow on smaller screens. This design addresses the issue through responsive layout techniques, flexible sizing, and proper constraint handling.

## Architecture

The solution follows a layered approach:

1. **Container Layer**: Maintains the card structure with proper constraints
2. **Layout Layer**: Implements responsive design using flexible widgets
3. **Content Layer**: Adapts content sizing based on available space
4. **Scrolling Layer**: Provides fallback scrolling when content exceeds bounds

## Components and Interfaces

### PrayerCard Widget Structure

```
PrayerCard
├── Container (bounded)
├── Card (with elevation and shape)
├── Container (with gradient decoration)
└── SafeArea (prevents system UI overlap)
    └── LayoutBuilder (provides size constraints)
        └── SingleChildScrollView (fallback scrolling)
            └── ConstrainedBox (minimum height constraint)
                └── IntrinsicHeight (natural height calculation)
                    └── Column (main layout)
                        ├── Header (fixed height)
                        ├── Central Circle (responsive size)
                        ├── Date Section (fixed height)
                        └── Prayer Times (flexible/scrollable)
```

### Key Design Changes

1. **Responsive Central Circle**: Scale based on available screen space
2. **Flexible Prayer Times List**: Use ListView.builder for efficient scrolling
3. **Adaptive Spacing**: Dynamic spacing based on screen height
4. **Safe Area Implementation**: Prevent overlap with system UI
5. **Layout Builder Integration**: Access real-time size constraints

## Data Models

No changes required to the existing Prayer model. The current structure supports all necessary data:

```dart
class Prayer {
  final String name;
  final String arabicName;
  final String time;
  final Color primaryColor;
  final Color secondaryColor;
  final IconData icon;
  final String quote;
  bool isPrayed;
  bool isTracked;
}
```

## Error Handling

### Overflow Prevention
- Implement SafeArea to handle system UI intrusion
- Use LayoutBuilder to get actual available space
- Provide SingleChildScrollView as fallback for extreme cases

### Content Adaptation
- Scale central circle based on available height
- Adjust spacing dynamically
- Prioritize essential content visibility

### Edge Cases
- Very small screens: Minimum viable layout with scrolling
- Landscape orientation: Horizontal layout adaptation
- Large screens: Maximum size constraints to prevent over-stretching

## Testing Strategy

### Unit Tests
- Test responsive sizing calculations
- Verify overflow prevention logic
- Test content adaptation algorithms

### Widget Tests
- Test prayer card rendering on different screen sizes
- Verify scrolling behavior when content exceeds bounds
- Test layout adaptation in different orientations

### Integration Tests
- Test prayer card within parent containers
- Verify interaction with other UI elements
- Test performance with multiple prayer cards

### Visual Regression Tests
- Compare layouts across different screen sizes
- Verify gradient and decorative elements preservation
- Test typography and spacing consistency

## Implementation Approach

### Phase 1: Core Layout Fixes
- Wrap content in SafeArea and LayoutBuilder
- Implement responsive central circle sizing
- Add SingleChildScrollView fallback

### Phase 2: Content Optimization
- Convert prayer times to ListView.builder
- Implement dynamic spacing calculations
- Add content prioritization logic

### Phase 3: Polish and Testing
- Fine-tune responsive breakpoints
- Add smooth animations for size changes
- Comprehensive testing across devices

## Technical Considerations

### Performance
- Use ListView.builder for efficient prayer times rendering
- Implement const constructors where possible
- Minimize widget rebuilds during responsive changes

### Accessibility
- Maintain semantic structure for screen readers
- Ensure touch targets meet minimum size requirements
- Preserve text scaling support

### Maintainability
- Extract responsive logic into utility functions
- Use named constants for breakpoints and sizing
- Document responsive behavior clearly