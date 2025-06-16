import UIKit
import AVFoundation

class MainViewController: UIViewController {

    var player: AVPlayer?
    var playerLayer: AVPlayerLayer?
    
    // 비디오 재생이 끝났다는 알림을 관찰할 옵저버를 저장하기 위한 프로퍼티
    private var playerDidFinishObserver: Any?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black

        setupBackgroundVideo()
        setupUI()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        playerLayer?.frame = view.bounds
    }

    // MARK: - Video Background Setup
    private func setupBackgroundVideo() {
        guard let path = Bundle.main.path(forResource: "sky", ofType: "mp4") else {
            print("Video file not found")
            return
        }
        let videoURL = URL(fileURLWithPath: path)

        player = AVPlayer(url: videoURL)
        // AVPlayer.ActionAtItemEnd.loop 대신 .none을 사용하고, 반복 재생은 알림으로 처리
        player?.actionAtItemEnd = .none // 비디오 끝에서 특별한 동작을 하지 않음 (기본값)

        playerLayer = AVPlayerLayer(player: player)
        playerLayer?.videoGravity = .resizeAspectFill
        playerLayer?.frame = view.bounds

        if let playerLayer = playerLayer {
            view.layer.insertSublayer(playerLayer, at: 0)
        }

        player?.play()

        // 비디오 위에 어둡게 오버레이
        let overlayView = UIView()
        overlayView.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        overlayView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(overlayView)

        NSLayoutConstraint.activate([
            overlayView.topAnchor.constraint(equalTo: view.topAnchor),
            overlayView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            overlayView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            overlayView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        // 비디오 재생이 끝났을 때 알림을 받을 옵저버 추가
        playerDidFinishObserver = NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime, // 비디오 아이템 재생이 끝났을 때 발생하는 알림
            object: player?.currentItem,           // 현재 플레이어 아이템이 해당 알림을 보낼 때만
            queue: .main) { [weak self] _ in
                // 비디오를 처음으로 되감기
                self?.player?.seek(to: CMTime.zero)
                // 다시 재생
                self?.player?.play()
            }

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(toggleVideoPlayPause))
        view.addGestureRecognizer(tapGesture)
    }

    // MARK: - UI Setup (기존 코드)
    private func setupUI() {
        let titleLabel = UILabel()
        titleLabel.text = "Hello,\nlet's find your place"
        titleLabel.textColor = .white
        titleLabel.font = .happyFont(ofSize: 28)
        titleLabel.numberOfLines = 2
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        let startButton = UIButton(type: .system)
        startButton.setTitle("Start Test", for: .normal)
        startButton.titleLabel?.font = UIFont.appFont(ofSize: 20, weight: .bold)
        startButton.setTitleColor(.white, for: .normal)
        startButton.backgroundColor = UIColor(named: "PointColor") ?? UIColor.systemBlue
        startButton.layer.cornerRadius = 10
        startButton.translatesAutoresizingMaskIntoConstraints = false
        startButton.addTarget(self, action: #selector(startSurvey), for: .touchUpInside)

        view.addSubview(titleLabel)
        view.addSubview(startButton)

        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 80),

            startButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            startButton.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 40),
            startButton.widthAnchor.constraint(equalToConstant: 200),
            startButton.heightAnchor.constraint(equalToConstant: 48)
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

    // 뷰가 사라질 때 비디오 재생을 중지하고, 옵저버도 제거하여 메모리 누수 방지
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        player?.pause()
        // 옵저버가 존재하면 제거
        if let observer = playerDidFinishObserver {
            NotificationCenter.default.removeObserver(observer)
            playerDidFinishObserver = nil // nil로 설정하여 더 이상 참조하지 않도록 함
        }
    }
}
