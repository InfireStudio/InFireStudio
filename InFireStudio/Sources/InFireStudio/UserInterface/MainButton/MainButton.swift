//
//  File.swift
//  InFireStudio
//
//  Created by furkan vural on 22.06.2025.
//

import UIKit

// MARK: - Button Style Enum
public enum MainButtonStyle {
    case normal
    case bounce
    case gradient
}

// MARK: - MainButton Class
public class MainButton: UIButton {
    
    // MARK: - Properties
    private var buttonStyle: MainButtonStyle = .normal
    private var gradientLayer: CAGradientLayer?
    private var originalTransform: CGAffineTransform = .identity
    
    // Customizable properties
    public var cornerRadius: CGFloat = 12 {
        didSet { updateAppearance() }
    }
    
    public var buttonHeight: CGFloat = 50 {
        didSet { updateHeight() }
    }
    
    public var primaryColor: UIColor = .systemBlue {
        didSet { updateAppearance() }
    }
    
    public var textColor: UIColor = .white {
        didSet { updateAppearance() }
    }
    
    public var fontSize: CGFloat = 17 {
        didSet { updateFont() }
    }
    
    public var fontWeight: UIFont.Weight = .semibold {
        didSet { updateFont() }
    }
    
    // Action closure
    public var onTap: (() -> Void)?
    
    // MARK: - Initializers
    public init(title: String, style: MainButtonStyle = .normal) {
        super.init(frame: .zero)
        self.buttonStyle = style
        setupButton(title: title)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupButton(title: "Button")
    }
    
    // MARK: - Setup Methods
    private func setupButton(title: String) {
        setTitle(title, for: .normal)
        setupAppearance()
        setupConstraints()
        setupActions()
        setupAccessibility()
    }
    
    private func setupAppearance() {
        translatesAutoresizingMaskIntoConstraints = false
        layer.cornerRadius = cornerRadius
        clipsToBounds = false
        
        // Shadow
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 4
        layer.shadowOpacity = 0.1
        
        updateAppearance()
        updateFont()
    }
    
    private func setupConstraints() {
        heightAnchor.constraint(equalToConstant: buttonHeight).isActive = true
    }
    
    private func setupActions() {
        addTarget(self, action: #selector(buttonTouchDown), for: .touchDown)
        addTarget(self, action: #selector(buttonTouchUpInside), for: .touchUpInside)
        addTarget(self, action: #selector(buttonTouchUpOutside), for: .touchUpOutside)
        addTarget(self, action: #selector(buttonTouchCancel), for: .touchCancel)
    }
    
    private func setupAccessibility() {
        isAccessibilityElement = true
        accessibilityTraits = .button
    }
    
    // MARK: - Update Methods
    private func updateAppearance() {
        setTitleColor(textColor, for: .normal)
        layer.cornerRadius = cornerRadius
        
        switch buttonStyle {
        case .normal, .bounce:
            backgroundColor = primaryColor
            gradientLayer?.removeFromSuperlayer()
            gradientLayer = nil
            
        case .gradient:
            setupGradientBackground()
        }
        
        updateShadow()
    }
    
    private func setupGradientBackground() {
        gradientLayer?.removeFromSuperlayer()
        
        let gradient = CAGradientLayer()
        gradient.colors = [
            primaryColor.cgColor,
            primaryColor.withAlphaComponent(0.7).cgColor
        ]
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 1, y: 1)
        gradient.cornerRadius = cornerRadius
        
        layer.insertSublayer(gradient, at: 0)
        gradientLayer = gradient
        backgroundColor = .clear
    }
    
    private func updateFont() {
        titleLabel?.font = UIFont.systemFont(ofSize: fontSize, weight: fontWeight)
    }
    
    private func updateHeight() {
        constraints.forEach { constraint in
            if constraint.firstAttribute == .height {
                constraint.constant = buttonHeight
            }
        }
    }
    
    private func updateShadow() {
        switch buttonStyle {
        case .normal:
            layer.shadowColor = primaryColor.withAlphaComponent(0.3).cgColor
            layer.shadowRadius = 4
            layer.shadowOffset = CGSize(width: 0, height: 2)
            
        case .bounce:
            layer.shadowColor = primaryColor.withAlphaComponent(0.4).cgColor
            layer.shadowRadius = 6
            layer.shadowOffset = CGSize(width: 0, height: 3)
            
        case .gradient:
            layer.shadowColor = primaryColor.withAlphaComponent(0.5).cgColor
            layer.shadowRadius = 6
            layer.shadowOffset = CGSize(width: 0, height: 4)
        }
    }
    
    // MARK: - Layout
    public override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer?.frame = bounds
    }
    
    // MARK: - Touch Handling
    @objc private func buttonTouchDown() {
        switch buttonStyle {
        case .normal, .gradient:
            animatePress(scale: 0.98)
            
        case .bounce:
            // Bounce effect will be handled in touchUpInside
            break
        }
    }
    
    @objc private func buttonTouchUpInside() {
        switch buttonStyle {
        case .normal, .gradient:
            animateRelease()
            
        case .bounce:
            animateBounce()
        }
        
        onTap?()
    }
    
    @objc private func buttonTouchUpOutside() {
        animateRelease()
    }
    
    @objc private func buttonTouchCancel() {
        animateRelease()
    }
    
    // MARK: - Animations
    private func animatePress(scale: CGFloat) {
        UIView.animate(withDuration: 0.1, delay: 0, options: [.allowUserInteraction, .curveEaseInOut], animations: {
            self.transform = CGAffineTransform(scaleX: scale, y: scale)
            self.layer.shadowOpacity = 0.05
        })
    }
    
    private func animateRelease() {
        UIView.animate(withDuration: 0.1, delay: 0, options: [.allowUserInteraction, .curveEaseInOut], animations: {
            self.transform = .identity
            self.layer.shadowOpacity = 0.1
        })
    }
    
    private func animateBounce() {
        // First compress
        UIView.animate(withDuration: 0.1, delay: 0, options: [.allowUserInteraction, .curveEaseIn], animations: {
            self.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
            self.layer.shadowOpacity = 0.05
            self.layer.shadowRadius = 3
        }) { _ in
            // Then bounce back with spring
            UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.8, options: [.allowUserInteraction], animations: {
                self.transform = .identity
                self.layer.shadowOpacity = 0.1
                self.layer.shadowRadius = 6
            })
        }
    }
    
    // MARK: - Public Configuration Methods
    public func configure(
        title: String? = nil,
        style: MainButtonStyle? = nil,
        primaryColor: UIColor? = nil,
        textColor: UIColor? = nil,
        cornerRadius: CGFloat? = nil,
        height: CGFloat? = nil,
        fontSize: CGFloat? = nil,
        fontWeight: UIFont.Weight? = nil
    ) {
        if let title = title {
            setTitle(title, for: .normal)
        }
        
        if let style = style {
            self.buttonStyle = style
        }
        
        if let primaryColor = primaryColor {
            self.primaryColor = primaryColor
        }
        
        if let textColor = textColor {
            self.textColor = textColor
        }
        
        if let cornerRadius = cornerRadius {
            self.cornerRadius = cornerRadius
        }
        
        if let height = height {
            self.buttonHeight = height
        }
        
        if let fontSize = fontSize {
            self.fontSize = fontSize
        }
        
        if let fontWeight = fontWeight {
            self.fontWeight = fontWeight
        }
    }
}

// MARK: - Convenience Factory Methods
public extension MainButton {
    
    static func normal(title: String, primaryColor: UIColor = .systemBlue) -> MainButton {
        let button = MainButton(title: title, style: .normal)
        button.primaryColor = primaryColor
        return button
    }
    
    static func bounce(title: String, primaryColor: UIColor = .systemGreen) -> MainButton {
        let button = MainButton(title: title, style: .bounce)
        button.primaryColor = primaryColor
        return button
    }
    
    static func gradient(title: String, primaryColor: UIColor = .systemPurple) -> MainButton {
        let button = MainButton(title: title, style: .gradient)
        button.primaryColor = primaryColor
        return button
    }
}

