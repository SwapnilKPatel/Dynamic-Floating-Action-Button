# DynamicFloatingActionButton

A highly customizable, animated Floating Action Button (FAB) component for iOS applications built with Swift and UIKit. This component provides a Material Design-inspired floating action button with expandable menu items and smooth animations.

## Features

- 🎯 **Expandable Menu**: Tap to reveal multiple action items
- 🎨 **Highly Customizable**: Colors, icons, fonts, and animations
- 📱 **iOS Native**: Built with UIKit and Swift
- 🔄 **Smooth Animations**: Spring-based animations with customizable duration
- 🎭 **Delegate Pattern**: Clean separation of concerns
- 🏗️ **Builder Pattern**: Easy construction with fluent API
- 🎪 **Auto-dismiss**: Tap outside to collapse the menu
- 📐 **Constraint-based**: Auto Layout compatible

## Requirements

- iOS 13.0+
- Swift 5.0+
- Xcode 12.0+

## Installation

### Manual Installation

1. Download the `DynamicFloatingActionButton.swift` file
2. Add it to your Xcode project
3. Import and use in your view controllers

### CocoaPods (Coming Soon)

```ruby
pod 'DynamicFloatingActionButton'
```

### Swift Package Manager (Coming Soon)

```swift
dependencies: [
    .package(url: "https://github.com/yourusername/DynamicFloatingActionButton.git", from: "1.0.0")
]
```

## Quick Start

### Basic Usage

```swift
import UIKit

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupFAB()
    }
    
    private func setupFAB() {
        let fab = FABBuilder()
            .addItem(id: "share", title: "Share", icon: "square.and.arrow.up") {
                print("Share action triggered")
            }
            .addItem(id: "bookmark", title: "Bookmark", icon: "bookmark") {
                print("Bookmark action triggered")
            }
            .addItem(id: "favorite", title: "Favorite", icon: "heart") {
                print("Favorite action triggered")
            }
            .build()
        
        fab.delegate = self
        addFloatingActionButton(fab)
    }
}

extension ViewController: DynamicFABDelegate {
    func fabDidTapMainButton(_ fab: DynamicFloatingActionButton) {
        print("Main FAB button tapped")
    }
    
    func fabDidTapMenuItem(_ fab: DynamicFloatingActionButton, item: FABMenuItem, at index: Int) {
        print("Menu item tapped: \(item.title)")
    }
    
    func fabDidExpand(_ fab: DynamicFloatingActionButton) {
        print("FAB expanded")
    }
    
    func fabDidCollapse(_ fab: DynamicFloatingActionButton) {
        print("FAB collapsed")
    }
}
```

## Advanced Usage

### Custom Configuration

```swift
let customConfig = FABConfiguration(
    mainButtonColor: .systemPurple,
    mainButtonIcon: "star.fill",
    mainButtonIconColor: .white,
    shadowColor: .black,
    shadowOpacity: 0.5,
    shadowRadius: 6,
    animationDuration: 0.4,
    labelBackgroundColor: .systemBackground,
    labelTextColor: .label,
    labelFont: UIFont.systemFont(ofSize: 16, weight: .medium)
)

let fab = DynamicFloatingActionButton(configuration: customConfig)
```

### Manual Menu Item Creation

```swift
let items = [
    FABMenuItem(
        id: "create_meeting",
        title: "Book a Meeting",
        icon: "calendar.badge.plus",
        backgroundColor: .systemBlue,
        iconColor: .white
    ) {
        // Handle meeting creation
        self.createMeeting()
    },
    FABMenuItem(
        id: "create_block",
        title: "Block a Slot",
        icon: "calendar.badge.minus",
        backgroundColor: .systemRed,
        iconColor: .white
    ) {
        // Handle slot blocking
        self.blockSlot()
    }
]

fab.setMenuItems(items)
```

### Programmatic Control

```swift
// Expand the FAB menu
fab.expand(animated: true)

// Collapse the FAB menu
fab.collapse(animated: true)

// Toggle the FAB menu
fab.toggle(animated: true)

// Check if expanded
if fab.isExpanded {
    print("FAB is currently expanded")
}
```

## API Reference

### FABMenuItem

```swift
struct FABMenuItem {
    let id: String                  // Unique identifier
    let title: String              // Display text
    let icon: String               // SF Symbol name
    let backgroundColor: UIColor   // Button background color
    let iconColor: UIColor         // Icon tint color
    let action: () -> Void         // Action closure
}
```

### FABConfiguration

```swift
struct FABConfiguration {
    let mainButtonColor: UIColor           // Main button background
    let mainButtonIcon: String             // Main button SF Symbol
    let mainButtonIconColor: UIColor       // Main button icon color
    let shadowColor: UIColor               // Shadow color
    let shadowOpacity: Float               // Shadow opacity (0.0-1.0)
    let shadowRadius: CGFloat              // Shadow blur radius
    let animationDuration: TimeInterval    // Animation duration
    let labelBackgroundColor: UIColor      // Label background color
    let labelTextColor: UIColor            // Label text color
    let labelFont: UIFont                  // Label font
}
```

### DynamicFABDelegate

```swift
protocol DynamicFABDelegate: AnyObject {
    func fabDidTapMainButton(_ fab: DynamicFloatingActionButton)
    func fabDidTapMenuItem(_ fab: DynamicFloatingActionButton, item: FABMenuItem, at index: Int)
    func fabDidExpand(_ fab: DynamicFloatingActionButton)
    func fabDidCollapse(_ fab: DynamicFloatingActionButton)
}
```

### Public Methods

```swift
// Set menu items
func setMenuItems(_ items: [FABMenuItem])

// Expand/Collapse
func expand(animated: Bool = true)
func collapse(animated: Bool = true)
func toggle(animated: Bool = true)
```

## Customization Examples

### Theme Variations

```swift
// Dark Theme
let darkConfig = FABConfiguration(
    mainButtonColor: .systemGray,
    mainButtonIcon: "plus",
    shadowOpacity: 0.8,
    labelBackgroundColor: .systemGray6,
    labelTextColor: .label
)

// Colorful Theme
let colorfulConfig = FABConfiguration(
    mainButtonColor: .systemPink,
    mainButtonIcon: "sparkles",
    shadowColor: .systemPink,
    shadowOpacity: 0.6,
    animationDuration: 0.5
)
```

### Custom Positioning

```swift
// Custom margin
addFloatingActionButton(fab, margin: 30)

// Manual positioning
fab.translatesAutoresizingMaskIntoConstraints = false
view.addSubview(fab)
NSLayoutConstraint.activate([
    fab.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
    fab.centerYAnchor.constraint(equalTo: view.centerYAnchor),
    fab.widthAnchor.constraint(equalToConstant: 56),
    fab.heightAnchor.constraint(equalToConstant: 300)
])
```

## Best Practices

1. **Limit Menu Items**: Keep menu items between 3-6 for optimal UX
2. **Use SF Symbols**: Leverage iOS system icons for consistency
3. **Meaningful Actions**: Ensure menu items represent primary actions
4. **Test Animations**: Verify smooth performance on target devices
5. **Accessibility**: Consider adding accessibility labels and hints

## Common Issues & Solutions

### Issue: FAB not appearing
**Solution**: Ensure the view is added to the view hierarchy and constraints are properly set.

### Issue: Animation stuttering
**Solution**: Reduce animation duration or simplify the animation by reducing the number of menu items.

### Issue: Touch targets too small
**Solution**: Ensure minimum 44x44 point touch targets for menu items.

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Inspired by Material Design's Floating Action Button
- Built with ❤️ for the iOS community

## Support

If you find this library useful, please consider:
- ⭐ Starring the repository
- 🐛 Reporting bugs
- 💡 Suggesting new features
- 📖 Improving documentation

---

**Created by [MrNightfox]** - Feel free to contact me for any questions or suggestions!
