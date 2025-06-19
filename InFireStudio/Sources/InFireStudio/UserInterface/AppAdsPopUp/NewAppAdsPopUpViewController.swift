//
//  File.swift
//  InFireStudio
//
//  Created by furkan vural on 16.06.2025.
//

import UIKit
import AVKit
import AVFoundation

@MainActor
public final class NewAppAdsPopUpViewController: UIViewController {
    
    // MARK: - UI Components
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        return view
    }()
    
    private let newAppImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private let downloadButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("İndir", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor.systemBlue
        button.layer.cornerRadius = 25
        button.layer.masksToBounds = true
        return button
    }()
    
    private let closeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("✕", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        button.layer.cornerRadius = 20
        return button
    }()
    
    private var playerViewController: AVPlayerViewController?
    private var player: AVPlayer?
    
    // MARK: - Properties
    private var adType: AdType = .image
    private var imageURL: String?
    private var videoURL: String?
    private var downloadURL: String?
    
    public enum AdType {
        case image
        case video
    }
    
    // MARK: - Lifecycle
    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupViewController()
        fetchAllData()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Status bar'ı gizle
        setNeedsStatusBarAppearanceUpdate()
    }
    
    public override var prefersStatusBarHidden: Bool {
        return true
    }
    
    public override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .fade
    }
    
    // MARK: - Setup
    private func setupViewController() {
        view.backgroundColor = .black
        modalPresentationStyle = .fullScreen
        modalTransitionStyle = .crossDissolve
    }
    
    // MARK: - Data Fetching
    private func fetchAllData() {
        // API çağrısı simülasyonu - gerçek implementasyonda buraya API çağrınız gelecek
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            // Mock data - gerçek verilerle değiştirin
            self?.adType = .video // veya .video
            self?.imageURL = "https://example.com/ad-image.jpg"
            self?.videoURL = "https://www.w3schools.com/tags/mov_bbb.mp4"
            self?.downloadURL = "https://apps.apple.com/app/example"
            
            self?.createUI()
        }
    }
    
    // MARK: - UI Creation
    private func createUI() {
        view.addSubview(containerView)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: view.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        switch adType {
        case .image:
            configureImageTypeConfiguration()
        case .video:
            configureVideoTypeConfiguration()
        }
        
        setupDownloadButton()
        setupCloseButton()
    }
    
    /// Yeni app reklamını eğer resim ile yapılacaksa ekranı kaplayan resim ve altında indir butonu çıkar.
    private func configureImageTypeConfiguration() {
        containerView.addSubview(newAppImageView)
        newAppImageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            newAppImageView.topAnchor.constraint(equalTo: containerView.topAnchor),
            newAppImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            newAppImageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            newAppImageView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
        
        // Resmi yükle
        loadImage()
    }
    
    /// Yeni app reklamını eğer video ile yapılacaksa tüm ekranı kaplayan video ve altında indir butonu buradan çıkacak.
    private func configureVideoTypeConfiguration() {
        guard let videoURL = videoURL, let url = URL(string: videoURL) else { return }
        
        player = AVPlayer(url: url)
        playerViewController = AVPlayerViewController()
        playerViewController?.player = player
        playerViewController?.showsPlaybackControls = false
        playerViewController?.videoGravity = .resizeAspectFill
        
        guard let playerVC = playerViewController else { return }
        
        addChild(playerVC)
        containerView.addSubview(playerVC.view)
        playerVC.view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            playerVC.view.topAnchor.constraint(equalTo: containerView.topAnchor),
            playerVC.view.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            playerVC.view.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            playerVC.view.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
        
        playerVC.didMove(toParent: self)
        
        // Video'yu otomatik oynat ve loop yap
        player?.play()
        setupVideoLoop()
    }
    
    // MARK: - Button Setup
    private func setupDownloadButton() {
        view.addSubview(downloadButton)
        downloadButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            downloadButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50),
            downloadButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            downloadButton.widthAnchor.constraint(equalToConstant: 200),
            downloadButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        downloadButton.addTarget(self, action: #selector(downloadButtonTapped), for: .touchUpInside)
    }
    
    private func setupCloseButton() {
        view.addSubview(closeButton)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            closeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            closeButton.widthAnchor.constraint(equalToConstant: 40),
            closeButton.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
    }
    
    // MARK: - Image Loading
    private func loadImage() {
        guard let imageURL = imageURL, let url = URL(string: imageURL) else { return }
        
        // URLSession ile resim yükle
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let data = data, let image = UIImage(data: data) else { return }
            
            DispatchQueue.main.async {
                self?.newAppImageView.image = image
            }
        }.resume()
    }
    
    // MARK: - Video Loop
    private func setupVideoLoop() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(videoDidEnd),
            name: .AVPlayerItemDidPlayToEndTime,
            object: player?.currentItem
        )
    }
    
    @objc private func videoDidEnd() {
        player?.seek(to: .zero)
        player?.play()
    }
    
    // MARK: - Actions
    @objc private func downloadButtonTapped() {
        guard let downloadURL = downloadURL, let url = URL(string: downloadURL) else { return }
        
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
        
        // Video'yu durdur ve reklam tıklandıktan sonra kapat
        cleanupPlayer()
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func closeButtonTapped() {
        cleanupPlayer()
        dismiss(animated: true, completion: nil)
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        cleanupPlayer()
    }
    
    private func cleanupPlayer() {
        player?.pause()
        player = nil
    }
    
    // MARK: - Deinitializer
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - SDK Public Interface
extension NewAppAdsPopUpViewController {
    
    /// SDK kullanıcıları için public method
    public func presentFullScreenAd(
        from parentViewController: UIViewController,
        adType: AdType,
        imageURL: String? = nil,
        videoURL: String? = nil,
        downloadURL: String? = nil
    ) {
        let adViewController = NewAppAdsPopUpViewController()
        adViewController.adType = adType
        adViewController.imageURL = imageURL
        adViewController.videoURL = videoURL
        adViewController.downloadURL = downloadURL
        
        parentViewController.present(adViewController, animated: true, completion: nil)
    }
}
