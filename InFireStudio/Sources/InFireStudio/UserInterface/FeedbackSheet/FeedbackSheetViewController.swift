//
//  File.swift
//  InFireStudio
//
//  Created by furkan vural on 20.06.2025.
//

import UIKit

public protocol FeedbackSheetProtocol: AnyObject {
    func didClickedBadButton()
    func didClickedNormalButton()
    func didClickedGoodButton()
    func didClickedVeryGoodButton()
    func didClickedSendButton()
}

@MainActor
@available(iOS 15.0, *)
public final class FeedbackSheetViewController: UIViewController {
    
    public weak var delegate: FeedbackSheetProtocol?
    
    private var selectedButton: UIButton?
    
    private let definitionLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 22)
        label.textColor = .label
        label.numberOfLines = 0
        label.textAlignment = .center
        label.text = "How was your experience?"
        return label
    }()
    
    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 6
        stack.alignment = .center
        stack.distribution = .equalSpacing
        return stack
    }()
    
    private let slightlyFrowningFaceButton: UIButton = {
        let button = UIButton()
        let image: UIImage? = InFireAssets.slightlyFace()
        button.setImage(image, for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.backgroundColor = .clear
        button.layer.cornerRadius = 8
        // Başlangıçta soluk görünüm
        button.alpha = 0.6
        return button
    }()
    
    private let neutralFaceButton: UIButton = {
        let button = UIButton()
        let image: UIImage? = InFireAssets.neutralFace()
        button.setImage(image, for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.backgroundColor = .clear
        button.layer.cornerRadius = 8
        // Başlangıçta soluk görünüm
        button.alpha = 0.6
        return button
    }()
    
    private let smilingFaceButton: UIButton = {
        let button = UIButton()
        let image: UIImage? = InFireAssets.smilingFace()
        button.setImage(image, for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.backgroundColor = .clear
        button.layer.cornerRadius = 8
        // Başlangıçta soluk görünüm
        button.alpha = 0.6
        return button
    }()
    
    private let smilingHeartsFaceButton: UIButton = {
        let button = UIButton()
        let image: UIImage? = InFireAssets.smilingHeartsFace()
        button.setImage(image, for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.backgroundColor = .clear
        button.layer.cornerRadius = 8
        
        button.alpha = 0.6
        return button
    }()
    
    private let sendButton: UIButton = {
        let button = UIButton()
        button.setTitle("Send", for: .normal)
        button.backgroundColor = .systemGreen
        button.layer.cornerRadius = 8
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 35, right: 0)
        return button
    }()
    
    private let thankYouLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 18)
        label.textColor = .label.withAlphaComponent(0.8)
        label.numberOfLines = 0
        label.textAlignment = .center
        label.text = "Thanks for feedback 🎉"
        return label
    }()
    
    public var feedback: Feedback
    
    public init(feedback: Feedback) {
        self.feedback = feedback
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupSheetPresentation()
        setupLayout()
        
        self.presentationController?.delegate = self
    }
    
    
    
    
    private func setupSheetPresentation() {
        if let sheet = self.sheetPresentationController {
            if #available(iOS 16.0, *) {
                sheet.detents = [
                    .custom(resolver: { context in
                        return context.maximumDetentValue * 0.3
                    })
                ]
            } else {
            }
            sheet.prefersGrabberVisible = true
            sheet.preferredCornerRadius = 20
            sheet.prefersGrabberVisible = true
            sheet.prefersScrollingExpandsWhenScrolledToEdge = false
            sheet.preferredCornerRadius = 20
        }
    }
    
    private func setupLayout() {
        view.addSubview(definitionLabel)
        view.addSubview(stackView)
        
        stackView.addArrangedSubview(slightlyFrowningFaceButton)
        stackView.addArrangedSubview(neutralFaceButton)
        stackView.addArrangedSubview(smilingFaceButton)
        stackView.addArrangedSubview(smilingHeartsFaceButton)
        
        // Buton boyutlarını ayarlayın
        slightlyFrowningFaceButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
        slightlyFrowningFaceButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        neutralFaceButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
        neutralFaceButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        smilingFaceButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
        smilingFaceButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        smilingHeartsFaceButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
        smilingHeartsFaceButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        definitionLabel.translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            definitionLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
            definitionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            definitionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            
            stackView.topAnchor.constraint(equalTo: definitionLabel.bottomAnchor, constant: 15),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 34),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -34),
            stackView.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        neutralFaceButton.addTarget(self, action: #selector(didTapNormalButton), for: .touchUpInside)
        smilingHeartsFaceButton.addTarget(self, action: #selector(didTapVeryGood), for: .touchUpInside)
        slightlyFrowningFaceButton.addTarget(self, action: #selector(didTapBad), for: .touchUpInside)
        smilingFaceButton.addTarget(self, action: #selector(didTapGood), for: .touchUpInside)
        
        view.addSubview(sendButton)
        sendButton.isHidden = true
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            sendButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            sendButton.topAnchor.constraint(equalTo: stackView.centerYAnchor, constant: 75),
            sendButton.heightAnchor.constraint(equalToConstant: 100),
            sendButton.widthAnchor.constraint(equalTo: view.widthAnchor)
        ])
        
        sendButton.addTarget(self, action: #selector(didClickedSendButton), for: .touchUpInside)
        
        view.addSubview(thankYouLabel)
        
        thankYouLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            thankYouLabel.topAnchor.constraint(equalTo: definitionLabel.bottomAnchor, constant: 24),
            thankYouLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            thankYouLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            thankYouLabel.heightAnchor.constraint(equalToConstant: 60)
        ])
        
        thankYouLabel.isHidden = true
        
    }
    
    @objc private func didClickedSendButton() {
        DispatchQueue.main.async {
            self.stackView.isHidden = true
            self.thankYouLabel.isHidden = false
        }
        
        UIView.animate(withDuration: 0.3) {
            self.sendButton.alpha = 0
        }
        delegate?.didClickedSendButton()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.dismiss(animated: true)
        }
        
        sendFeedback(with: feedback)
    }
    
    /// Database feedback gönderir.
    /// Feedback nesnesi geçilmek zorundadır.
    private func sendFeedback(with feedback: Feedback) {
        let database = SupabaseLogService()
        Task {
            await database.sendFeedback(feedback)
        }
    }
    
    
    private func updateButtonSelection(_ selectedButton: UIButton) {
        resetAllButtons()
        
        
        UIView.animate(withDuration: 0.3) {
            selectedButton.alpha = 1.0
        }
        
        self.selectedButton = selectedButton
        unhideSendButton()
    }
    
    private func resetAllButtons() {
        let allButtons = [slightlyFrowningFaceButton, neutralFaceButton, smilingFaceButton, smilingHeartsFaceButton]
        
        UIView.animate(withDuration: 0.3) {
            allButtons.forEach { button in
                button.alpha = 0.3
            }
        }
    }
    
    private func unhideSendButton() {
        DispatchQueue.main.async {
            self.sendButton.isHidden = false
        }
    }
    
    @objc private func didTapNormalButton() {
        feedback.rating = Feedback.Rating.normal.rawValue
        updateButtonSelection(neutralFaceButton)
        delegate?.didClickedNormalButton()
    }
    
    @objc private func didTapGood() {
        feedback.rating = Feedback.Rating.good.rawValue
        updateButtonSelection(smilingFaceButton)
        delegate?.didClickedGoodButton()
    }
    
    @objc private func didTapBad() {
        feedback.rating = Feedback.Rating.bad.rawValue
        updateButtonSelection(slightlyFrowningFaceButton)
        delegate?.didClickedBadButton()
    }
    
    @objc private func didTapVeryGood() {
        feedback.rating = Feedback.Rating.veryGood.rawValue
        updateButtonSelection(smilingHeartsFaceButton)
        delegate?.didClickedVeryGoodButton()
    }
}

@available(iOS 15.0, *)
extension FeedbackSheetViewController: UIAdaptivePresentationControllerDelegate {
    public func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        feedback.rating = Feedback.Rating.none.rawValue
        sendFeedback(with: feedback)
        UserDefaults.standard.set(true, forKey: "isFeedbackCompleted")
    }
}


@MainActor
public struct Feedback: Codable {
    var userId: String
    var rating: String
    var appVersion: String
    var appName: String
    var deviceModel: String
    var osVersion: String
    var locale: String
    var screenName: String
    var isBugReport: Bool
    var feedbackType: String
    var action: FeedbackAction
    
    // CodingKeys
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case rating
        case appVersion = "app_version"
        case appName = "app_name"
        case deviceModel = "device_model"
        case osVersion = "os_version"
        case locale
        case screenName = "screen_name"
        case isBugReport = "is_bug_report"
        case feedbackType = "feedback_type"
        case action
    }
    
    public init(userId: String, rating: Rating, appVersion: String, appName: String, deviceModel: String, osVersion: String, locale: String, screenName: String, isBugReport: Bool, feedbackType: FeedbackType, action: FeedbackAction) {
        self.userId = userId
        self.rating = rating.rawValue
        self.appVersion = appVersion
        self.appName = appName
        self.deviceModel = deviceModel
        self.osVersion = osVersion
        self.locale = locale
        self.screenName = screenName
        self.isBugReport = isBugReport
        self.feedbackType = feedbackType.rawValue
        self.action = action
    }
    
    public enum FeedbackType: String, Codable {
        case feature
        case bug
        case general
    }
    
    public enum Rating: String, Codable {
        case bad
        case normal
        case good
        case veryGood
        case none
    }
    
    @MainActor
    public enum FeedbackAction: String, Codable {
        case dismiss
        case submit
    }
}
