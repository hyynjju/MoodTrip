import UIKit

class MatchingScoreBarView: UIView {
    
    private let scoreLabel = UILabel()
    private let backgroundBar = UIView()
    private let progressBar = UIView()
    
    var score: Int = 0 {
        didSet {
            updateUI()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        translatesAutoresizingMaskIntoConstraints = false
        clipsToBounds = false
        
        // 라벨
        scoreLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        scoreLabel.textAlignment = .right
        scoreLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(scoreLabel)
        
        // 배경 바
        backgroundBar.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        backgroundBar.layer.cornerRadius = 3
        backgroundBar.translatesAutoresizingMaskIntoConstraints = false
        addSubview(backgroundBar)
        
        // 진행 바
        progressBar.backgroundColor = UIColor(hex: "#73C2FF")
        progressBar.layer.cornerRadius = 3
        progressBar.translatesAutoresizingMaskIntoConstraints = false
        backgroundBar.addSubview(progressBar)
        
        NSLayoutConstraint.activate([
            // 라벨은 상단
            scoreLabel.topAnchor.constraint(equalTo: topAnchor),
            scoreLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            scoreLabel.leadingAnchor.constraint(equalTo: leadingAnchor), // 수정: greaterThanOrEqualTo -> equalTo
            
            // 바는 라벨 아래 - width 제약 추가
            backgroundBar.topAnchor.constraint(equalTo: scoreLabel.bottomAnchor, constant: 4),
            backgroundBar.trailingAnchor.constraint(equalTo: trailingAnchor),
            backgroundBar.leadingAnchor.constraint(equalTo: leadingAnchor), // 수정: greaterThanOrEqualTo -> equalTo
            backgroundBar.widthAnchor.constraint(equalToConstant: 240), // 추가: 고정 width
            backgroundBar.heightAnchor.constraint(equalToConstant: 6),
            backgroundBar.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            // 진행 바
            progressBar.leadingAnchor.constraint(equalTo: backgroundBar.leadingAnchor),
            progressBar.topAnchor.constraint(equalTo: backgroundBar.topAnchor),
            progressBar.bottomAnchor.constraint(equalTo: backgroundBar.bottomAnchor),
        ])
    }
    
    private var progressWidthConstraint: NSLayoutConstraint?
    
    private func updateUI() {
        let progress = max(0, min(CGFloat(score) / 100.0, 1.0))
        scoreLabel.attributedText = makeScoreText(score)
        
        // 기존 width constraint 제거
        progressWidthConstraint?.isActive = false
        progressWidthConstraint = progressBar.widthAnchor.constraint(equalTo: backgroundBar.widthAnchor, multiplier: progress)
        progressWidthConstraint?.isActive = true
        
        layoutIfNeeded()
    }
    
    private func makeScoreText(_ score: Int) -> NSAttributedString {
        let scoreStr = "\(score)%"
        let matchStr = " Match"
        let fullStr = scoreStr + matchStr
        
        let attributed = NSMutableAttributedString(string: fullStr)
        attributed.addAttribute(.foregroundColor, value: UIColor.white, range: NSRange(location: 0, length: scoreStr.count))
        attributed.addAttribute(.foregroundColor, value: UIColor.white.withAlphaComponent(0.7), range: NSRange(location: scoreStr.count, length: matchStr.count))
        
        return attributed
    }
}
