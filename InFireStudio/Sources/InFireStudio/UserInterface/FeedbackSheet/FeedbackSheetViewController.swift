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
    func didSubmitChatText(message: String)
}

@MainActor
@available(iOS 15.0, *)
public final class FeedbackSheetViewController: UIViewController, UIAdaptivePresentationControllerDelegate {
    
    private let language = Locale.current.languageCode ?? "en"
    
    public weak var delegate: FeedbackSheetProtocol?
    let checkingValue = "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"
     
    private var selectedButton: UIButton?
    
    private let definitionLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 22)
        label.textColor = .white
        label.numberOfLines = 0
        label.textAlignment = .left
        label.text = "How was your experience?"
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17)
        label.textColor = .white.withAlphaComponent(0.5)
        label.numberOfLines = 0
        label.adjustsFontSizeToFitWidth = true
        label.textAlignment = .left
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
        button.titleLabel?.font = .boldSystemFont(ofSize: 20)
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
        return label
    }()
    
    private lazy var feedbackTextView: PlaceholderTextView = {
        let feedbackTextView = PlaceholderTextView()
        feedbackTextView.placeholder = "Message..."
        feedbackTextView.returnKeyType = .send
        feedbackTextView.placeholderColor = .white.withAlphaComponent(0.3)
        feedbackTextView.font = UIFont.systemFont(ofSize: 15)
        feedbackTextView.textContainerInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        return feedbackTextView
    }()
    
    private let dontShowAgainButton: UIButton = {
        let button = UIButton(type: .system)
        
        return button
    }()
    
    public var feedback = Feedback(
        userId: UUID().uuidString,
        rating: .bad,
        appVersion: "",
        appName: "",
        deviceModel: "",
        osVersion: "",
        locale: "tr",
        screenName: "",
        isBugReport: false,
        feedbackType: .general,
        action: .dismiss,
        answerType: .rating,
        chatAnswer: ""
    )
    
    public var config: FeedbackConfig
    
    public init(config: FeedbackConfig) {
        self.config = config
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        configureLocalizationText()
        setupSheetPresentation()
        checkFeedbackType()
        self.presentationController?.delegate = self
    }
    
    
    private func checkFeedbackType() {
        switch config.feedbackType {
        case .rating:
            setupLayout()
        case .chat:
            setupChatLayout()
        }
    }
    
    private func setupSheetPresentation() {
        if let sheet = self.sheetPresentationController {
            if #available(iOS 16.0, *) {
                sheet.detents = [
                    .custom(resolver: { context in
                        return context.maximumDetentValue * 0.4
                    })
                ]
            }
            sheet.prefersGrabberVisible = true
            sheet.preferredCornerRadius = 15
            sheet.prefersScrollingExpandsWhenScrolledToEdge = false
        }
    }
    
    
    private func configureLocalizationText() {
        
        let definitionText = config.title[language] ?? config.title["en"] ?? ""
        definitionLabel.text = definitionText
        
        let subtitleText = config.subtitle[language] ?? config.subtitle["en"] ?? ""
        subtitleLabel.text = subtitleText
        
        let thankYouMessageText = config.thankYouMessage[language] ?? config.thankYouMessage["en"] ?? ""
        thankYouLabel.text = thankYouMessageText
        
        let sendButtonText = config.sendButtonText[language] ?? config.sendButtonText["en"] ?? ""
        sendButton.setTitle(sendButtonText, for: .normal)
        
        let dontShowAgainText = config.dontShowButtonTitle[language] ?? config.sendButtonText["en"] ?? ""
        let title = dontShowAgainText
        let attributedTitle = NSMutableAttributedString(string: title)
        attributedTitle.addAttribute(.underlineStyle,
                                    value: NSUnderlineStyle.single.rawValue,
                                    range: NSRange(location: 0, length: title.count))
        
        dontShowAgainButton.setAttributedTitle(attributedTitle, for: .normal)
        dontShowAgainButton.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        dontShowAgainButton.setTitleColor(.systemBlue, for: .normal)
        dontShowAgainButton.setTitle(dontShowAgainText, for: .normal)
        print("METİN: \(dontShowAgainText)")
        
        let appName = config.appName
        feedback.appName = appName
        
        let localeIdentifier = Locale.current.identifier
        feedback.locale = localeIdentifier
        feedback.appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
        feedback.deviceModel = UIDevice.current.model
        feedback.osVersion = ProcessInfo.processInfo.operatingSystemVersionString

    }
    
    private func setupChatLayout() {
        
        
        definitionLabel.textColor = .white
        
        view.addSubview(definitionLabel)
        view.addSubview(subtitleLabel)
        
        view.addSubview(dontShowAgainButton)
        view.addSubview(thankYouLabel)
        
        definitionLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        dontShowAgainButton.translatesAutoresizingMaskIntoConstraints = false
        thankYouLabel.translatesAutoresizingMaskIntoConstraints = false
        
        thankYouLabel.isHidden = true
        
        NSLayoutConstraint.activate([
            definitionLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30),
            definitionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            
            subtitleLabel.topAnchor.constraint(equalTo: definitionLabel.bottomAnchor, constant: 18),
            subtitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24)
        ])
        
        feedbackTextView.backgroundColor = .white.withAlphaComponent(0.08)
        feedbackTextView.textColor = .white.withAlphaComponent(0.9)
        feedbackTextView.layer.borderColor = UIColor.white.withAlphaComponent(0.2).cgColor
        feedbackTextView.layer.cornerRadius = 10
        
        view.addSubview(feedbackTextView)
        feedbackTextView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            feedbackTextView.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 30),
            feedbackTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            feedbackTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            feedbackTextView.heightAnchor.constraint(equalToConstant: 100),
            
            thankYouLabel.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 30),
            thankYouLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            thankYouLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            thankYouLabel.heightAnchor.constraint(equalToConstant: 100),
            
            
            dontShowAgainButton.topAnchor.constraint(equalTo: feedbackTextView.bottomAnchor, constant: 50),
            dontShowAgainButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        
        dontShowAgainButton.addTarget(self, action: #selector(didTapDontShowAgain), for: .touchUpInside)
        
        feedbackTextOnSend()
        
    }
    
    private func feedbackTextOnSend() {
        feedbackTextView.onSend = { [weak self] text in
            guard let self else { return }
            feedback.answerType = .chat
            feedback.chatAnswer = text
            feedback.action = .submit
            feedbackTextView.isHidden = true
            thankYouLabel.isHidden = false
            dontShowAgainButton.isHidden = true
            let chatgptManager = ChatGPTManager(apiKey: checkingValue)
            chatgptManager.evaluateFeedback(text) { [weak self] result in
                guard let self else { return }
                switch result {
                case .success(let success):
                    if success {
                        Task {
                            await sendFeedback(with: feedback)
                        }
                    } else {
                        Task {
                            await sendFeedback(with: feedback, false)
                        }
                    }
                case .failure(let failure):
                    print("Kaydedilemez")
                }
            }
        }
    }
    
    private func setupLayout() {

        view.addSubview(definitionLabel)
        view.addSubview(subtitleLabel)
        
        view.addSubview(stackView)
        view.addSubview(dontShowAgainButton)
        
        stackView.addArrangedSubview(slightlyFrowningFaceButton)
        stackView.addArrangedSubview(neutralFaceButton)
        stackView.addArrangedSubview(smilingFaceButton)
        stackView.addArrangedSubview(smilingHeartsFaceButton)
        
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
        dontShowAgainButton.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            definitionLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 35),
            definitionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            definitionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            definitionLabel.heightAnchor.constraint(equalToConstant: 40),
            
            subtitleLabel.topAnchor.constraint(equalTo: definitionLabel.bottomAnchor, constant: 1),
            subtitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            subtitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            
            stackView.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 40),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 34),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -34),
            stackView.heightAnchor.constraint(equalToConstant: 50),
            
            dontShowAgainButton.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 40),
            dontShowAgainButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        
        neutralFaceButton.addTarget(self, action: #selector(didTapNormalButton), for: .touchUpInside)
        smilingHeartsFaceButton.addTarget(self, action: #selector(didTapVeryGood), for: .touchUpInside)
        slightlyFrowningFaceButton.addTarget(self, action: #selector(didTapBad), for: .touchUpInside)
        smilingFaceButton.addTarget(self, action: #selector(didTapGood), for: .touchUpInside)
        dontShowAgainButton.addTarget(self, action: #selector(didTapDontShowAgain), for: .touchUpInside)
        
        
        view.addSubview(sendButton)
        sendButton.isHidden = true
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            sendButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            sendButton.topAnchor.constraint(equalTo: stackView.centerYAnchor, constant: 95),
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
    private func sendFeedback(with feedback: Feedback, _ irrelevantMessage: Bool = false) {
        let database = SupabaseLogService()
        Task {
            await database.sendFeedback(feedback)
            switch feedback.answerType {
            case .rating:
                UserDefaultsManager.shared.isRatingFeedbackProcessCompleted = true
                self.dismiss(animated: true)
            case .chat:
                let message = irrelevantMessage ? "Your message irrelevant": "You received reward"
                delegate?.didSubmitChatText(message: message)
                UserDefaultsManager.shared.isChatFeedbackProcessCompleted = true
                self.dismiss(animated: true)
            }
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
        dontShowAgainButton.isHidden = true
        feedback.rating = Feedback.Rating.normal.rawValue
        feedback.answerType = .rating
        feedback.action = .submit
        updateButtonSelection(neutralFaceButton)
        delegate?.didClickedNormalButton()
    }
    
    @objc private func didTapGood() {
        dontShowAgainButton.isHidden = true
        feedback.rating = Feedback.Rating.good.rawValue
        feedback.answerType = .rating
        feedback.action = .submit
        updateButtonSelection(smilingFaceButton)
        delegate?.didClickedGoodButton()
    }
    
    @objc private func didTapBad() {
        dontShowAgainButton.isHidden = true
        feedback.rating = Feedback.Rating.bad.rawValue
        feedback.answerType = .rating
        feedback.action = .submit
        updateButtonSelection(slightlyFrowningFaceButton)
        delegate?.didClickedBadButton()
    }
    
    @objc private func didTapVeryGood() {
        dontShowAgainButton.isHidden = true
        feedback.rating = Feedback.Rating.veryGood.rawValue
        feedback.answerType = .rating
        feedback.action = .submit
        updateButtonSelection(smilingHeartsFaceButton)
        delegate?.didClickedVeryGoodButton()
    }
    
    @objc private func didTapDontShowAgain() {
        UserDefaultsManager.shared.isRatingFeedbackProcessCompleted = false
        UserDefaultsManager.shared.isChatFeedbackProcessCompleted = false
        feedback.rating = Feedback.Rating.none.rawValue
        #warning("Fix answer type")
        feedback.answerType = .chat
        feedback.action = .dismiss
        sendFeedback(with: feedback)
    }
}




// Move Feedback Helper
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
    var answerType: AnswerType
    var chatAnswer: String
    
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
        case answerType = "answer_type"
        case chatAnswer = "chat_answer"
    }
    
    public init(userId: String, rating: Rating, appVersion: String, appName: String, deviceModel: String, osVersion: String, locale: String, screenName: String, isBugReport: Bool, feedbackType: FeedbackType, action: FeedbackAction, answerType: AnswerType, chatAnswer: String) {
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
        self.answerType  = answerType
        self.chatAnswer = chatAnswer
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
    
    @MainActor
    public enum AnswerType: String, Codable {
        case rating
        case chat
    }
}
