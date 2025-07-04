//
//  DynamicFloatingActionButton.swift
//  DynamicFloatingActionButton
//
//  Created by Swapnilkumar K Patel on 04/07/25.
//

import UIKit
import Foundation

// MARK: - FAB Menu Item Model
struct FABMenuItem {
    let id: String
    let title: String
    let icon: String
    let backgroundColor: UIColor
    let iconColor: UIColor
    let action: () -> Void
    
    public init(id: String, title: String, icon: String, backgroundColor: UIColor = .systemBlue, iconColor: UIColor = .white, action: @escaping () -> Void) {
        self.id = id
        self.title = title
        self.icon = icon
        self.backgroundColor = backgroundColor
        self.iconColor = iconColor
        self.action = action
    }
}

// MARK: - FAB Configuration
struct FABConfiguration {
    let mainButtonColor: UIColor
    let mainButtonIcon: String
    let mainButtonIconColor: UIColor
    let shadowColor: UIColor
    let shadowOpacity: Float
    let shadowRadius: CGFloat
    let animationDuration: TimeInterval
    let labelBackgroundColor: UIColor
    let labelTextColor: UIColor
    let labelFont: UIFont
    
    public init(
        mainButtonColor: UIColor = .systemBlue,
        mainButtonIcon: String = "plus",
        mainButtonIconColor: UIColor = .white,
        shadowColor: UIColor = .black,
        shadowOpacity: Float = 0.3,
        shadowRadius: CGFloat = 4,
        animationDuration: TimeInterval = 0.3,
        labelBackgroundColor: UIColor = .black,
        labelTextColor: UIColor = .white,
        labelFont: UIFont = UIFont.systemFont(ofSize: 14, weight: .medium)
    ) {
        self.mainButtonColor = mainButtonColor
        self.mainButtonIcon = mainButtonIcon
        self.mainButtonIconColor = mainButtonIconColor
        self.shadowColor = shadowColor
        self.shadowOpacity = shadowOpacity
        self.shadowRadius = shadowRadius
        self.animationDuration = animationDuration
        self.labelBackgroundColor = labelBackgroundColor
        self.labelTextColor = labelTextColor
        self.labelFont = labelFont
    }
}

// MARK: - FAB Delegate Protocol
protocol DynamicFABDelegate: AnyObject {
    func fabDidTapMainButton(_ fab: DynamicFloatingActionButton)
    func fabDidTapMenuItem(_ fab: DynamicFloatingActionButton, item: FABMenuItem, at index: Int)
    func fabDidExpand(_ fab: DynamicFloatingActionButton)
    func fabDidCollapse(_ fab: DynamicFloatingActionButton)
}

// MARK: - Floating Action Button
class DynamicFloatingActionButton: UIView {
    
    // MARK: - Public
    public weak var delegate: DynamicFABDelegate?
    public var isExpanded: Bool = false { didSet { updateMainButtonIcon() } }
    public var configuration: FABConfiguration { didSet { applyConfiguration() } }
    var menuItems: [FABMenuItem] = []
    var widthConstraint: NSLayoutConstraint?
    
    
    // MARK: - Private
    private let mainButton = UIButton()
    private var menuButtons: [UIButton] = []
    private var menuLabels: [UILabel] = []
    private var buttonConstraints: [NSLayoutConstraint] = []
    private var labelConstraints: [NSLayoutConstraint] = []
    private var backgroundDismissView: UIButton?
    
    
    // MARK: - Init
    public init(configuration: FABConfiguration = FABConfiguration()) {
        self.configuration = configuration
        super.init(frame: .zero)
        setupMainButton()
        applyConfiguration()
    }
    
    required init?(coder: NSCoder) {
        self.configuration = FABConfiguration()
        super.init(coder: coder)
        setupMainButton()
        applyConfiguration()
    }
    
    // MARK: - Setup
    private func setupMainButton() {
        mainButton.layer.cornerRadius = 28
        mainButton.translatesAutoresizingMaskIntoConstraints = false
        mainButton.addTarget(self, action: #selector(mainButtonTapped), for: .touchUpInside)
        addSubview(mainButton)
        
        NSLayoutConstraint.activate([
            mainButton.widthAnchor.constraint(equalToConstant: 56),
            mainButton.heightAnchor.constraint(equalToConstant: 56),
            mainButton.bottomAnchor.constraint(equalTo: bottomAnchor),
            mainButton.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
        
        // Center anchor point for rotation
        DispatchQueue.main.async {
            self.mainButton.layer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
            self.mainButton.layer.position = CGPoint(
                x: self.mainButton.frame.midX,
                y: self.mainButton.frame.midY
            )
        }
    }
    
    private func applyConfiguration() {
        mainButton.backgroundColor = configuration.mainButtonColor
        if let img = UIImage(systemName:  configuration.mainButtonIcon)?.withRenderingMode(.alwaysTemplate) {
            mainButton.setImage(img, for: .normal)
        }
        mainButton.tintColor = configuration.mainButtonIconColor
    
        mainButton.layer.shadowColor = configuration.shadowColor.cgColor
        mainButton.layer.shadowOpacity = configuration.shadowOpacity
        mainButton.layer.shadowOffset = CGSize(width: 0, height: 2)
        mainButton.layer.shadowRadius = configuration.shadowRadius
    }
    
    private func updateMainButtonIcon() {
        if let img = UIImage(systemName: configuration.mainButtonIcon)?.withRenderingMode(.alwaysTemplate) {
            mainButton.setImage(img, for: .normal)
        }
    }
    
    // MARK: - Menu Management
    public func setMenuItems(_ items: [FABMenuItem]) {
        clearMenuItems()
        menuItems = items
        for (index, item) in items.enumerated() {
            createMenuButtonForItem(item, at: index)
        }
        setupConstraints()
    }
    
    private func clearMenuItems() {
        menuButtons.forEach { $0.removeFromSuperview() }
        menuLabels.forEach { $0.removeFromSuperview() }
        menuButtons.removeAll()
        menuLabels.removeAll()
        NSLayoutConstraint.deactivate(buttonConstraints + labelConstraints)
        buttonConstraints.removeAll()
        labelConstraints.removeAll()
    }
    
    private func createMenuButtonForItem(_ item: FABMenuItem, at index: Int) {
        let button = UIButton()
        button.backgroundColor = item.backgroundColor
        button.layer.cornerRadius = 24
        button.setImage(UIImage(systemName: item.icon)?.withRenderingMode(.alwaysTemplate), for: .normal)
        button.tintColor = item.iconColor
        button.alpha = 0
        button.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        button.tag = index
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(menuButtonTapped(_:)), for: .touchUpInside)
        addSubview(button)
        menuButtons.append(button)
        
        let label = UILabel()
        label.text = item.title
        label.font = configuration.labelFont
        label.textColor = configuration.labelTextColor
        label.backgroundColor = configuration.labelBackgroundColor
        label.layer.cornerRadius = 12
        label.clipsToBounds = true
        label.alpha = 0
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        addSubview(label)
        menuLabels.append(label)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.deactivate(buttonConstraints + labelConstraints)
        buttonConstraints.removeAll()
        labelConstraints.removeAll()
        
        for (index, button) in menuButtons.enumerated() {
            let yOffset = CGFloat(70 * (index + 1))
            buttonConstraints.append(contentsOf: [
                button.bottomAnchor.constraint(equalTo: mainButton.topAnchor, constant: -yOffset + 56),
                button.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -4),
                button.widthAnchor.constraint(equalToConstant: 48),
                button.heightAnchor.constraint(equalToConstant: 48)
            ])
            
            let label = menuLabels[index]
            labelConstraints.append(contentsOf: [
                label.centerYAnchor.constraint(equalTo: button.centerYAnchor),
                label.trailingAnchor.constraint(equalTo: button.leadingAnchor, constant: -12),
                label.widthAnchor.constraint(greaterThanOrEqualToConstant: 100),
                label.heightAnchor.constraint(equalToConstant: 32)
            ])
        }
        
        NSLayoutConstraint.activate(buttonConstraints + labelConstraints)
    }
    
    // MARK: - Expand/Collapse
    public func expand(animated: Bool = true) {
        guard !isExpanded else { return }
        isExpanded = true
        animateMenu(expand: true, animated: animated)
        delegate?.fabDidExpand(self)
    }
    
    public func collapse(animated: Bool = true) {
        guard isExpanded else { return }
        isExpanded = false
        animateMenu(expand: false, animated: animated)
        delegate?.fabDidCollapse(self)
    }
    
    public func toggle(animated: Bool = true) {
        isExpanded ? collapse(animated: animated) : expand(animated: animated)
    }
    
    private func animateMenu(expand: Bool, animated: Bool) {
        let targetWidth: CGFloat = expand ? 200 : 56
        let duration = animated ? configuration.animationDuration : 0
        
        if expand {
            addBackgroundDismissView()
        }
        
        UIView.animate(withDuration: duration, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, options: .curveEaseInOut) {
            self.mainButton.transform = expand ? CGAffineTransform(rotationAngle: .pi / 4) : .identity
            self.widthConstraint?.constant = targetWidth
            self.superview?.layoutIfNeeded()
            
            for (index, button) in self.menuButtons.enumerated() {
                button.alpha = expand ? 1 : 0
                button.transform = expand ? .identity : CGAffineTransform(scaleX: 0.5, y: 0.5)
                self.menuLabels[index].alpha = expand ? 1 : 0
            }
        } completion: { _ in
            if !expand {
                self.removeBackgroundDismissView()
            }
        }
    }
    
    
    // MARK: - Actions
    @objc private func mainButtonTapped() {
        delegate?.fabDidTapMainButton(self)
        toggle()
    }
    
    @objc private func menuButtonTapped(_ sender: UIButton) {
        let index = sender.tag
        guard index < menuItems.count else { return }
        let item = menuItems[index]
        delegate?.fabDidTapMenuItem(self, item: item, at: index)
        item.action()
        collapse()
    }
    
    private func addBackgroundDismissView() {
        guard let parentView = self.superview else { return }
        
        let background = UIButton()
        background.translatesAutoresizingMaskIntoConstraints = false
        background.backgroundColor = UIColor.clear
        background.addTarget(self, action: #selector(backgroundTapped), for: .touchUpInside)
        
        parentView.insertSubview(background, belowSubview: self)
        NSLayoutConstraint.activate([
            background.leadingAnchor.constraint(equalTo: parentView.leadingAnchor),
            background.trailingAnchor.constraint(equalTo: parentView.trailingAnchor),
            background.topAnchor.constraint(equalTo: parentView.topAnchor),
            background.bottomAnchor.constraint(equalTo: parentView.bottomAnchor)
        ])
        
        self.backgroundDismissView = background
    }
    
    private func removeBackgroundDismissView() {
        backgroundDismissView?.removeFromSuperview()
        backgroundDismissView = nil
    }
    
    @objc private func backgroundTapped() {
        collapse()
    }
    
}

// MARK: - FAB Builder (Optional Convenience)
class FABBuilder {
    private var items: [FABMenuItem] = []
    private var configuration = FABConfiguration()
    
    public init() {}
    
    func addItem(id: String, title: String, icon: String, action: @escaping () -> Void) -> FABBuilder {
        let item = FABMenuItem(id: id, title: title, icon: icon, action: action)
        items.append(item)
        return self
    }
    
    func setConfiguration(_ config: FABConfiguration) -> FABBuilder {
        self.configuration = config
        return self
    }
    
    func build() -> DynamicFloatingActionButton {
        let fab = DynamicFloatingActionButton(configuration: configuration)
        fab.setMenuItems(items)
        return fab
    }
}

// MARK: - Extension for UIViewController
extension UIViewController {
    func addFloatingActionButton(_ fab: DynamicFloatingActionButton, margin: CGFloat = 20) {
        fab.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(fab)
        
        let height = CGFloat(fab.menuItems.count * 70 + 56)
        let widthConstraint = fab.widthAnchor.constraint(equalToConstant: 56)
        fab.widthConstraint = widthConstraint
        
        NSLayoutConstraint.activate([
            fab.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -margin),
            fab.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -margin),
            widthConstraint,
            fab.heightAnchor.constraint(equalToConstant: height)
        ])
    }
}

// MARK: - Usage Examples
class ExampleViewController: BaseController, LoadableController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupFAB()
    }
    
    private func setupFAB() {
        // Method 1: Using Builder Pattern
      
        let fab = FABBuilder()
            .addItem(id: "share", title: "Share Content", icon: "square.and.arrow.up") {
                print("Share action triggered")
            }
            .addItem(id: "bookmark", title: "Add Bookmark", icon: "bookmark.fill") {
                print("Bookmark action triggered")
            }
            .addItem(id: "edit", title: "Edit Item", icon: "pencil") {
                print("Edit action triggered")
            }
            .build()
        
        fab.delegate = self
        addFloatingActionButton(fab)
        
        
        // Method 2: Manual Configuration
        /*
         let customConfig = FABConfiguration(
         mainButtonColor: .systemPurple,
         mainButtonIcon: "star.fill",
         shadowOpacity: 0.5,
         animationDuration: 0.5
         )
         
         let fab2 = DynamicFloatingActionButton(configuration: customConfig)
         
         let items = [
         FABMenuItem(id: "item1", title: "Custom Action 1", icon: "heart.fill", backgroundColor: .systemPink) {
         print("Custom action 1")
         },
         FABMenuItem(id: "item2", title: "Custom Action 2", icon: "star.fill", backgroundColor: .systemYellow) {
         print("Custom action 2")
         }
         ]
         
         fab2.setMenuItems(items)
         fab2.delegate = self
         addFloatingActionButton(fab2, margin: 30)
         */
    }
}

// MARK: - Example Delegate Implementation
extension ExampleViewController: DynamicFABDelegate {
    func fabDidTapMainButton(_ fab: DynamicFloatingActionButton) {
        print("Main FAB button tapped")
    }
    
    func fabDidTapMenuItem(_ fab: DynamicFloatingActionButton, item: FABMenuItem, at index: Int) {
        print("Menu item tapped: \(item.title) at index: \(index)")
    }
    
    func fabDidExpand(_ fab: DynamicFloatingActionButton) {
        print("FAB expanded")
    }
    
    func fabDidCollapse(_ fab: DynamicFloatingActionButton) {
        print("FAB collapsed")
    }
}
