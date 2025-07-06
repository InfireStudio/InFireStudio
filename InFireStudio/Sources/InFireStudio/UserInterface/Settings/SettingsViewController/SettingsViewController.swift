//
//  File.swift
//  InFireStudio
//
//  Created by furkan vural on 19.06.2025.
//

import Foundation
import UIKit

internal class SettingsViewController: UIViewController {
    
    var settingsManager: SettingsManager!
    
    private var scrollView: UIScrollView!
    private var contentView: UIView!
    private var stackView: UIStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .label
        setupUI()
        buildSettingsUI()
    }
    
    private func setupUI() {
        guard let config = settingsManager.config else { return }
        
        view.backgroundColor = settingsManager.hexToUIColor(config.settings.appearance.backgroundColor)
        title = settingsManager.getLocalizedString(["en": "Settings", "tr": "Ayarlar"])
        
        scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        
        contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
        
        stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = config.settings.appearance.sectionSpacing
        stackView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
    }
    
    private func buildSettingsUI() {
        guard let config = settingsManager.config else { return }
        view.backgroundColor = config.background == "dark" ? .blue : .green
        
        let premiumView = createPremiumView(config.settings.premiumView)
        stackView.addArrangedSubview(premiumView)
        
        // Sections
        for section in config.settings.sections {
            let sectionView = createSectionView(section)
            stackView.addArrangedSubview(sectionView)
        }
    }
    
    private func createPremiumView(_ premium: PremiumView) -> UIView {
        let button = UIButton(type: .system)
        button.backgroundColor = settingsManager.hexToUIColor(premium.backgroundColor)
        button.layer.cornerRadius = premium.cornerRadius
        button.setTitle(settingsManager.getLocalizedString(premium.title), for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        
        if let systemName = premium.image.systemName {
            button.setImage(UIImage(systemName: systemName), for: .normal)
            button.tintColor = .black
        }
        
        button.addTarget(self, action: #selector(premiumButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.heightAnchor.constraint(equalToConstant: 164).isActive = true
        
        return button
    }
    
    private func createSectionView(_ section: SettingsSection) -> UIView {
        let containerView = UIView()
        
        // Section Title
        let titleLabel = UILabel()
        titleLabel.text = settingsManager.getLocalizedString(section.title)
        titleLabel.font = UIFont.boldSystemFont(ofSize: 16)
        titleLabel.textColor = .label
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(titleLabel)
        
        // Section Content
        let contentView: UIView
        if section.type == "collection" {
            contentView = createCollectionView(section)
        } else {
            contentView = createTableView(section)
        }
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(contentView)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            
            contentView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            contentView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
        
        return containerView
    }
    
    private func createCollectionView(_ section: SettingsSection) -> UIView {
        let containerView = UIView()
        containerView.backgroundColor = .systemBackground
        containerView.layer.cornerRadius = 12
        
        guard let layout = section.layout else { return containerView }
        
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = layout.spacing
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        for item in section.items {
            let appButton = createAppButton(item)
            stackView.addArrangedSubview(appButton)
        }
        
        containerView.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            stackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            stackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -16),
            stackView.heightAnchor.constraint(equalToConstant: layout.height)
        ])
        
        return containerView
    }
    
    private func createAppButton(_ item: SettingsItem) -> UIButton {
        let button = UIButton(type: .system)
        button.backgroundColor = .systemGray5
        button.layer.cornerRadius = 12
        button.tintColor = .label
        
        if let fallbackIcon = item.fallbackIcon {
            button.setImage(UIImage(systemName: fallbackIcon), for: .normal)
        }
        
        button.addTarget(self, action: #selector(appButtonTapped(_:)), for: .touchUpInside)
        button.tag = item.hashValue
        
        return button
    }
    
    private func createTableView(_ section: SettingsSection) -> UIView {
        let containerView = UIView()
        containerView.backgroundColor = .systemBackground
        containerView.layer.cornerRadius = 12
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        for (index, item) in section.items.enumerated() {
            let cellView = createTableCell(item)
            stackView.addArrangedSubview(cellView)
            
            if index < section.items.count - 1 {
                let separatorView = UIView()
                separatorView.backgroundColor = .separator
                separatorView.translatesAutoresizingMaskIntoConstraints = false
                separatorView.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
                stackView.addArrangedSubview(separatorView)
            }
        }
        
        containerView.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: containerView.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
        
        return containerView
    }
    
    private func createTableCell(_ item: SettingsItem) -> UIView {
        let button = UIButton(type: .system)
        button.backgroundColor = .clear
        button.contentHorizontalAlignment = .leading
        
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 12
        stackView.isUserInteractionEnabled = false
        
        // Icon
        if let icon = item.icon {
            let iconImageView = UIImageView(image: UIImage(systemName: icon.systemName))
            iconImageView.tintColor = settingsManager.hexToUIColor(icon.color)
            iconImageView.translatesAutoresizingMaskIntoConstraints = false
            iconImageView.widthAnchor.constraint(equalToConstant: 24).isActive = true
            iconImageView.heightAnchor.constraint(equalToConstant: 24).isActive = true
            stackView.addArrangedSubview(iconImageView)
        }
        
        // Title
        let titleLabel = UILabel()
        titleLabel.text = settingsManager.getLocalizedString(item.title)
        titleLabel.font = UIFont.systemFont(ofSize: 17)
        
        if let textColor = item.textColor {
            titleLabel.textColor = settingsManager.hexToUIColor(textColor)
        } else {
            titleLabel.textColor = .label
        }
        
        stackView.addArrangedSubview(titleLabel)
        
        // Spacer
        let spacer = UIView()
        spacer.setContentHuggingPriority(.init(1), for: .horizontal)
        stackView.addArrangedSubview(spacer)
        
        // Accessory
        if item.accessoryType == "disclosureIndicator" {
            let chevronImageView = UIImageView(image: UIImage(systemName: "chevron.right"))
            chevronImageView.tintColor = .systemGray3
            chevronImageView.translatesAutoresizingMaskIntoConstraints = false
            chevronImageView.widthAnchor.constraint(equalToConstant: 12).isActive = true
            stackView.addArrangedSubview(chevronImageView)
        }
        
        button.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: button.topAnchor, constant: 12),
            stackView.leadingAnchor.constraint(equalTo: button.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: button.trailingAnchor, constant: -16),
            stackView.bottomAnchor.constraint(equalTo: button.bottomAnchor, constant: -12),
            button.heightAnchor.constraint(greaterThanOrEqualToConstant: 48)
        ])
        
        button.addTarget(self, action: #selector(tableItemTapped(_:)), for: .touchUpInside)
        button.tag = item.hashValue
        
        return button
    }
    
    // MARK: - Actions
    @objc private func premiumButtonTapped() {
        guard let config = settingsManager.config else { return }
        settingsManager.delegate?.settingsManager(settingsManager, didTapPremium: config.settings.premiumView.action)
    }
    
    @objc private func appButtonTapped(_ sender: UIButton) {
        guard let config = settingsManager.config else { return }
        
        for section in config.settings.sections {
            if let item = section.items.first(where: { $0.hashValue == sender.tag }) {
                if let urlString = item.appStoreURL, let url = URL(string: urlString) {
                    UIApplication.shared.open(url)
                }
                settingsManager.delegate?.settingsManager(settingsManager, didTapApp: item)
                break
            }
        }
    }
    
    @objc private func tableItemTapped(_ sender: UIButton) {
        guard let config = settingsManager.config else { return }
        
        for section in config.settings.sections {
            if let item = section.items.first(where: { $0.hashValue == sender.tag }) {
                handleTableItemAction(item)
                settingsManager.delegate?.settingsManager(settingsManager, didTapAction: item.action, withItem: item)
                break
            }
        }
    }
    
    private func handleTableItemAction(_ item: SettingsItem) {
        switch item.action {
        case "restorePurchases":
            print("restorePurchases calıstı")
        case "rateApp":
            if let urlString = item.appStoreURL, let url = URL(string: urlString) {
                UIApplication.shared.open(url)
            }
        case "showPrivacyPolicy", "showTermsOfUse":
            if let urlString = item.url, let url = URL(string: urlString) {
                print("showPrivacyPolicy")
            }
        default:
            break
        }
    }
}
