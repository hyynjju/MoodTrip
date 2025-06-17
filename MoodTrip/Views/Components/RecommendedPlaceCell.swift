import UIKit

class RecommendedPlaceCell: UICollectionViewCell {
    static let reuseIdentifier = "RecommendedPlaceCell"
    
    private let placeImageView = UIImageView()
    private let nameLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let matchingScoreBar = MatchingScoreBarView()
    private let gradientOverlay = UIView() // This view will hold the gradient layer
    private let gradientLayer = CAGradientLayer() // The actual gradient layer

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.backgroundColor = .clear
        
        // 이미지뷰
        placeImageView.contentMode = .scaleAspectFill
        placeImageView.clipsToBounds = true
        placeImageView.layer.cornerRadius = 12
        placeImageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(placeImageView)
        
        // 그라데이션 오버레이 (placeImageView의 서브뷰로 추가)
        gradientOverlay.translatesAutoresizingMaskIntoConstraints = false
        placeImageView.addSubview(gradientOverlay)
        
        // 그라데이션 레이어 설정 (gradientOverlay의 레이어로 추가)
        gradientLayer.colors = [UIColor.clear.cgColor, UIColor.black.withAlphaComponent(0.8).cgColor]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
        gradientOverlay.layer.addSublayer(gradientLayer) // Add gradient layer to gradientOverlay's layer
        
        // ✅ 인디케이터 (placeImageView의 서브뷰로 추가)
        matchingScoreBar.translatesAutoresizingMaskIntoConstraints = false
        placeImageView.addSubview(matchingScoreBar)
        
        // 라벨들 (다시 contentView의 서브뷰로 변경하고 원래 제약 조건으로 돌아감)
        nameLabel.font = .appFont(ofSize: 18, weight: .bold)
        nameLabel.textColor = .white
        nameLabel.numberOfLines = 1
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(nameLabel) // <-- Back to contentView
        
        descriptionLabel.font = .appFont(ofSize: 14)
        descriptionLabel.textColor = .white.withAlphaComponent(0.8)
        descriptionLabel.numberOfLines = 2
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(descriptionLabel) // <-- Back to contentView
        
        // 오토레이아웃 제약
        NSLayoutConstraint.activate([
            // 이미지뷰 (contentView를 채움)
            placeImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            placeImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            placeImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            placeImageView.heightAnchor.constraint(equalToConstant: 160),
            
            // 그라데이션 (placeImageView를 채움)
            gradientOverlay.leadingAnchor.constraint(equalTo: placeImageView.leadingAnchor),
            gradientOverlay.trailingAnchor.constraint(equalTo: placeImageView.trailingAnchor),
            gradientOverlay.bottomAnchor.constraint(equalTo: placeImageView.bottomAnchor),
            gradientOverlay.heightAnchor.constraint(equalTo: placeImageView.heightAnchor, multiplier: 0.5),
            
            // ✅ 인디케이터 (placeImageView 우측 하단 정렬, 이미지 위에)
            matchingScoreBar.trailingAnchor.constraint(equalTo: placeImageView.trailingAnchor, constant: -16),
            matchingScoreBar.bottomAnchor.constraint(equalTo: placeImageView.bottomAnchor, constant: -16),
            matchingScoreBar.widthAnchor.constraint(lessThanOrEqualToConstant: 210),
            matchingScoreBar.heightAnchor.constraint(equalToConstant: 36),
            
            // 이름 라벨 (placeImageView 하단에 위치)
            nameLabel.topAnchor.constraint(equalTo: placeImageView.bottomAnchor, constant: 8), // <-- Relative to placeImageView.bottom
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            // 설명 라벨 (이름 라벨 하단에 위치)
            descriptionLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            descriptionLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor)
        ])
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = gradientOverlay.bounds
    }
    
    func configure(with place: Place, matchingScore: Int) {
        nameLabel.text = place.name
        descriptionLabel.text = place.description
        matchingScoreBar.score = matchingScore
        
        placeImageView.image = nil // Reset image to prevent flicker
        
        if let url = URL(string: place.imageURL) {
            URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
                guard let self = self else { return }
                if let data = data, let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self.placeImageView.image = image
                        // 그라데이션 오버레이는 이미지 위에 오도록 유지 (placeImageView의 서브뷰 중 최상단)
                        self.placeImageView.bringSubviewToFront(self.gradientOverlay)
                        // 매칭 스코어 바는 그라데이션 위에 오도록 유지
                        self.placeImageView.bringSubviewToFront(self.matchingScoreBar)
                        self.setNeedsLayout() // 레이아웃 업데이트 요청
                    }
                } else {
                    DispatchQueue.main.async {
                        self.placeImageView.image = UIImage(named: "placeholderImage") // Fallback image
                        self.placeImageView.bringSubviewToFront(self.gradientOverlay)
                        self.placeImageView.bringSubviewToFront(self.matchingScoreBar)
                        self.setNeedsLayout()
                    }
                }
            }.resume()
        } else {
            placeImageView.image = UIImage(named: "placeholderImage") // Fallback image
            self.placeImageView.bringSubviewToFront(self.gradientOverlay)
            self.placeImageView.bringSubviewToFront(self.matchingScoreBar)
            setNeedsLayout()
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        placeImageView.image = nil
        nameLabel.text = nil
        descriptionLabel.text = nil
    }
}
