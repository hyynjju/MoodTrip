import UIKit

// MARK: - CircularProgressView Class
class CircularProgressView: UIView {
    private let progressLayer = CAShapeLayer()
    private let backgroundLayer = CAShapeLayer()
    private let scoreLabel = UILabel()
    private let matchLabel = UILabel()

    var progress: CGFloat = 0.0 {
        didSet {
            progress = max(0, min(1, progress))
            updateProgress()
        }
    }

    var score: Int = 0 {
        didSet {
            scoreLabel.text = "\(score)"
        }
    }

    var progressColor: UIColor = UIColor(red: 0x73/255.0, green: 0xC2/255.0, blue: 0xFF/255.0, alpha: 1.0) { // 73C2FF
        didSet {
            progressLayer.strokeColor = progressColor.cgColor
        }
    }

    var trackColor: UIColor = UIColor.white.withAlphaComponent(0.2) {
        didSet {
            backgroundLayer.strokeColor = trackColor.cgColor
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayers()
        setupLabels()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupLayers()
        setupLabels()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        // 레이아웃 변경 시 레이어 재설정 및 프로그레스 업데이트
        setupLayers()
        updateProgress()
    }

    private func setupLayers() {
        backgroundLayer.removeFromSuperlayer()
        progressLayer.removeFromSuperlayer()
        
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        // MARK: - 원형 그래프 크기 조절
        // 예를 들어 0.7, 0.6 등으로 변경해보세요.
        let radius = min(bounds.width, bounds.height) / 2 * 0.55
        // 원의 시작점을 12시 방향에서 시작하도록 설정
        let startAngle = -CGFloat.pi / 2
        let endAngle = startAngle + 2 * CGFloat.pi

        let circularPath = UIBezierPath(arcCenter: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)

        backgroundLayer.path = circularPath.cgPath
        backgroundLayer.strokeColor = trackColor.cgColor
        // 원형 선의 두께 조절
        backgroundLayer.lineWidth = 5
        backgroundLayer.fillColor = UIColor.clear.cgColor
        backgroundLayer.lineCap = .round
        layer.addSublayer(backgroundLayer)

        progressLayer.path = circularPath.cgPath
        progressLayer.strokeColor = progressColor.cgColor
        // 원형 선의 두께 조절
        progressLayer.lineWidth = 5
        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.lineCap = .round
        progressLayer.strokeEnd = 0
        layer.addSublayer(progressLayer)
    }

    private func setupLabels() {
        // scoreLabel 폰트 변경: HappyFont 사용
        scoreLabel.textAlignment = .center
        scoreLabel.font = .appFont(ofSize: 24, weight: .bold)
        scoreLabel.textColor = .white
        scoreLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(scoreLabel)

        // matchLabel 폰트 변경: appFont bold 사용
        matchLabel.text = "match"
        matchLabel.textAlignment = .center
        matchLabel.font = .appFont(ofSize: 12, weight: .bold)
        matchLabel.textColor = .white
        matchLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(matchLabel)

        NSLayoutConstraint.activate([
            scoreLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            // MARK: - 스코어 레이블과 매치 레이블 간격 조절
            scoreLabel.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -7),
            
            matchLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            // MARK: - 스코어 레이블과 매치 레이블 간격 조절
            matchLabel.topAnchor.constraint(equalTo: scoreLabel.bottomAnchor, constant: -6)
        ])
    }

    private func updateProgress() {
        progressLayer.strokeEnd = progress
    }
}
