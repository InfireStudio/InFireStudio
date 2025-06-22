//
//  File.swift
//  InFireStudio
//
//  Created by furkan vural on 22.06.2025.
//

import UIKit

public protocol SplashViewControllerProtocol: AnyObject {
    /// Backend tarafında getirilecek bir data varsa bu fonksiyon altında yap.
    /// Animasyon süresine göre hesaplanması gerekiyor yapılacak işlemlerin
    func handleBackendOperation()
}

@MainActor
public final class SplashViewController: UIViewController {
    
    public var appInformation: AppInformation!
    public weak var delegate: SplashViewControllerProtocol?
    
    private let brandInfoLabel: UILabel = {
        let label = UILabel()
        label.text = "from"
        label.font = .systemFont(ofSize: 16)
        label.textColor = .white.withAlphaComponent(0.9)
        return label
    }()
    
    private let brandLogo: UIImageView = {
        let logo = UIImageView()
        logo.image = InFireAssets.getInFireStudioLogo()
        logo.contentMode = .scaleAspectFit
        return logo
    }()

    private let appLogo: UIImageView = {
        let logo = UIImageView()
        logo.contentMode = .scaleAspectFit
        return logo
    }()
    
    let normalButton = MainButton.gradient(title: "Giriş Yap", primaryColor: .blue)
    
    public init(appInformation: AppInformation) {
        self.appInformation = appInformation
        super.init(nibName: nil, bundle: nil)
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        createUI()
        startSplashSequence()
    }
    
    private func createUI() {
        appLogo.image = appInformation.logoImage
        
        view.addSubview(appLogo)
        view.addSubview(brandInfoLabel)
        view.addSubview(brandLogo)
        view.addSubview(normalButton)
        normalButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            normalButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            normalButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            normalButton.heightAnchor.constraint(equalToConstant: 50),
            normalButton.widthAnchor.constraint(equalToConstant: 100),
            
        ])
        
        appLogo.translatesAutoresizingMaskIntoConstraints = false
        brandInfoLabel.translatesAutoresizingMaskIntoConstraints = false
        brandLogo.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            // App Logo - Merkezde
            appLogo.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            appLogo.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            appLogo.widthAnchor.constraint(lessThanOrEqualToConstant: 200),
            appLogo.heightAnchor.constraint(lessThanOrEqualToConstant: 200),
            
            // Brand Info Label - Alt kısımda
            brandInfoLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            brandInfoLabel.bottomAnchor.constraint(equalTo: brandLogo.topAnchor, constant: -10),
            
            // Brand Logo - En altta
            brandLogo.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            brandLogo.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50),
            brandLogo.widthAnchor.constraint(equalToConstant: 60),
            brandLogo.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    private func startSplashSequence() {
        // Backend operasyonunu başlat
        delegate?.handleBackendOperation()
        
        // Belirtilen süre sonunda splash'i kapat
        DispatchQueue.main.asyncAfter(deadline: .now() + appInformation.logoShowingDuration) {
            self.dismiss(animated: true)
        }
    }
}

@MainActor
public struct AppInformation {
    public let logoImage: UIImage
    public let logoShowingDuration: TimeInterval
    
    public init(logoImage: UIImage, logoShowingDuration: TimeInterval) {
        self.logoImage = logoImage
        self.logoShowingDuration = logoShowingDuration
    }
}
