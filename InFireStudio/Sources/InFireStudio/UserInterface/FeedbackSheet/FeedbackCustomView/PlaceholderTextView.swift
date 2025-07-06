//
//  File.swift
//  InFireStudio
//
//  Created by furkan vural on 27.06.2025.
//
import UIKit

@MainActor
public final class PlaceholderTextView: UITextView {

    public var placeholder: String? {
        didSet { placeholderLabel.text = placeholder }
    }
    public var placeholderColor: UIColor = .white.withAlphaComponent(0.2) {
        didSet { placeholderLabel.textColor = placeholderColor }
    }
    public var onSend: ((String) -> Void)?

    
    private let placeholderLabel: UILabel = {
        let lbl = UILabel()
        lbl.numberOfLines = 0
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()

    
    public override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        commonInit()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: – Setup
    private func commonInit() {
        
        addSubview(placeholderLabel)
        
        placeholderLabel.font = self.font
        placeholderLabel.textColor = placeholderColor
        
        textContainerInset = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        textContainer.lineFragmentPadding = 0
        
        NSLayoutConstraint.activate([
            placeholderLabel.topAnchor.constraint(equalTo: topAnchor, constant: textContainerInset.top),
            placeholderLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: textContainerInset.left),
            placeholderLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -textContainerInset.right)
        ])

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(textDidChange),
            name: UITextView.textDidChangeNotification,
            object: self
        )
        
        self.returnKeyType = .send
        self.delegate = self
    }

    @objc private func textDidChange() {
        placeholderLabel.isHidden = !text.isEmpty
    }
}


extension PlaceholderTextView: UITextViewDelegate {
    public func textView(
        _ textView: UITextView,
        shouldChangeTextIn range: NSRange,
        replacementText text: String
    ) -> Bool {
        if text == "\n" {
            let content = textView.text.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !content.isEmpty else { return false }
            
            print("User sent feedback:", content)
            onSend?(content)
            
            textView.resignFirstResponder()
            textView.text = ""
            placeholderLabel.isHidden = false
            return false
        }
        return true
    }
}
