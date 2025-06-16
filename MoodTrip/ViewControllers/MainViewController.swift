import UIKit
import AVFoundation

class MainViewController: UIViewController {
    
    var player: AVPlayer?
    var playerLayer: AVPlayerLayer?
    
    private var playerDidFinishObserver: Any?
    
    // 비디오 상단에 추가할 그라데이션 레이어
    private let videoGradientOverlay = CAGradientLayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black // 전체 배경은 검정
        
        setupBackgroundVideo()
        setupUI()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // 1. 비디오 플레이어 레이어 프레임 업데이트
        // 비디오가 배경 상단 0%~70% 부분을 채움
        playerLayer?.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height * 0.7)
        
        // 2. 비디오 그라데이션 오버레이 프레임 및 속성 업데이트
        videoGradientOverlay.frame = playerLayer?.frame ?? .zero // 비디오 레이어와 같은 사이즈
        // 0~50% 위치는 오퍼시티 0, 50%~100% 위치는 오퍼시티 0~1로 진해지는 검정 그라데이션
        videoGradientOverlay.colors = [UIColor.black.withAlphaComponent(0.0).cgColor, UIColor.black.withAlphaComponent(0.0).cgColor, UIColor.black.withAlphaComponent(1.0).cgColor]
        videoGradientOverlay.locations = [0.0, 0.5, 1.0] // 0%~50%는 투명, 50%~100%는 진해지도록
    }
    
    // MARK: - Video Background Setup
    private func setupBackgroundVideo() {
        guard let path = Bundle.main.path(forResource: "sky", ofType: "mp4") else {
            print("Video file not found")
            return
        }
        let videoURL = URL(fileURLWithPath: path)
        
        player = AVPlayer(url: videoURL)
        player?.actionAtItemEnd = .none // 비디오 끝에서 특별한 동작을 하지 않음
        
        playerLayer = AVPlayerLayer(player: player)
        playerLayer?.videoGravity = .resizeAspectFill
        
        if let playerLayer = playerLayer {
            view.layer.insertSublayer(playerLayer, at: 0) // 비디오 레이어를 가장 아래에 추가
        }
        
        player?.play()
        
        // 비디오 그라데이션 오버레이 추가 (비디오 레이어 바로 위에)
        if let playerLayer = playerLayer {
            view.layer.insertSublayer(videoGradientOverlay, above: playerLayer)
        }
        
        playerDidFinishObserver = NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: player?.currentItem,
            queue: .main) { [weak self] _ in
                self?.player?.seek(to: CMTime.zero)
                self?.player?.play()
            }
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(toggleVideoPlayPause))
        view.addGestureRecognizer(tapGesture)
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        // "Hello, let's find your place" 레이블
        let mainTitleLabel = UILabel()
        mainTitleLabel.text = "Hello,\nlet's find your place"
        mainTitleLabel.textColor = .white
        mainTitleLabel.font = .appFont(ofSize: 34, weight: .bold) // 스크린샷과 유사하게 크기 조절
        mainTitleLabel.numberOfLines = 2
        mainTitleLabel.textAlignment = .center
        mainTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(mainTitleLabel)
        
        // "Text text content Text text content." 레이블 (내용)
        let contentLabel = UILabel()
        contentLabel.text = "Answer quick questions to find your perfect match." // 요청하신 문구
        contentLabel.textColor = .white.withAlphaComponent(0.8)
        contentLabel.font = .appFont(ofSize: 18, weight: .regular) // 폰트 크기 조절
        contentLabel.numberOfLines = 0
        contentLabel.textAlignment = .center
        contentLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(contentLabel)
        
        // "Get Started" 버튼
        let getStartedButton = UIButton(type: .system)
        getStartedButton.setTitle("Get Started", for: .normal)
        getStartedButton.titleLabel?.font = UIFont.appFont(ofSize: 16, weight: .bold)
        getStartedButton.setTitleColor(.black, for: .normal)
        getStartedButton.backgroundColor = .white
        getStartedButton.layer.cornerRadius = 24
        getStartedButton.translatesAutoresizingMaskIntoConstraints = false
        getStartedButton.addTarget(self, action: #selector(startSurvey), for: .touchUpInside)
        view.addSubview(getStartedButton)
        
        // 버튼 내 재생 아이콘
        let playIconImageView = UIImageView(image: UIImage(systemName: "play.fill"))
        playIconImageView.tintColor = .black // 아이콘 색상 검정으로 변경
        playIconImageView.translatesAutoresizingMaskIntoConstraints = false
        getStartedButton.addSubview(playIconImageView)
        
        NSLayoutConstraint.activate([
            // Main Title Label
            mainTitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            mainTitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            mainTitleLabel.bottomAnchor.constraint(equalTo: contentLabel.topAnchor, constant: -10), // 내용 레이블 위로 배치
            
            // Content Label
            contentLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            contentLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            contentLabel.bottomAnchor.constraint(equalTo: getStartedButton.topAnchor, constant: -40), // 버튼 위로 배치
            
            // Get Started Button
            getStartedButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            getStartedButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -32), // 하단 여백 조절
            getStartedButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8), // 화면 너비의 80%
            getStartedButton.heightAnchor.constraint(equalToConstant: 48),
            
            // Play Icon in Button
            playIconImageView.centerYAnchor.constraint(equalTo: getStartedButton.centerYAnchor),
            playIconImageView.leadingAnchor.constraint(equalTo: getStartedButton.leadingAnchor, constant: 20),
            playIconImageView.widthAnchor.constraint(equalToConstant: 24),
            playIconImageView.heightAnchor.constraint(equalToConstant: 24)
        ])
    }
    
    // MARK: - Actions
    @objc func startSurvey() {
        let surveyVC = SurveyViewController()
        navigationController?.pushViewController(surveyVC, animated: true)
    }
    
    @objc private func toggleVideoPlayPause() {
        if player?.rate == 0 {
            player?.play()
        } else {
            player?.pause()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        player?.pause()
        if let observer = playerDidFinishObserver {
            NotificationCenter.default.removeObserver(observer)
            playerDidFinishObserver = nil
        }
    }
}
