import UIKit

class RecommendedPlaceCell: UICollectionViewCell {
    static let reuseIdentifier = "RecommendedPlaceCell"
    
    private let placeImageView = UIImageView()
    private let nameLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let matchingScoreBar = MatchingScoreBarView()
    private let gradientOverlay = UIView()
    
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
        
        // 그라데이션 오버레이
        gradientOverlay.translatesAutoresizingMaskIntoConstraints = false
        placeImageView.addSubview(gradientOverlay)
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [UIColor.clear.cgColor, UIColor.black.withAlphaComponent(0.8).cgColor]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
        gradientOverlay.layer.insertSublayer(gradientLayer, at: 0)
        
        // ✅ 인디케이터를 이미지 위에 올림
        placeImageView.addSubview(matchingScoreBar)
        matchingScoreBar.translatesAutoresizingMaskIntoConstraints = false
        
        // 라벨들
        nameLabel.font = .appFont(ofSize: 18, weight: .bold)
        nameLabel.textColor = .white
        nameLabel.numberOfLines = 1
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(nameLabel)
        
        descriptionLabel.font = .appFont(ofSize: 14)
        descriptionLabel.textColor = .white.withAlphaComponent(0.8)
        descriptionLabel.numberOfLines = 2
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(descriptionLabel)
        
        // 오토레이아웃 제약
        NSLayoutConstraint.activate([
            // 이미지뷰
            placeImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            placeImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            placeImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            placeImageView.heightAnchor.constraint(equalToConstant: 160),
            
            // 그라데이션
            gradientOverlay.leadingAnchor.constraint(equalTo: placeImageView.leadingAnchor),
            gradientOverlay.trailingAnchor.constraint(equalTo: placeImageView.trailingAnchor),
            gradientOverlay.bottomAnchor.constraint(equalTo: placeImageView.bottomAnchor),
            gradientOverlay.heightAnchor.constraint(equalTo: placeImageView.heightAnchor, multiplier: 0.5),
            
            // ✅ 인디케이터 (이미지 우측 하단 정렬)
            matchingScoreBar.trailingAnchor.constraint(equalTo: placeImageView.trailingAnchor, constant: -16),
            matchingScoreBar.bottomAnchor.constraint(equalTo: placeImageView.bottomAnchor, constant: -16),
            matchingScoreBar.widthAnchor.constraint(lessThanOrEqualToConstant: 210),
            matchingScoreBar.heightAnchor.constraint(equalToConstant: 36),
            
            // 이름 라벨
            nameLabel.topAnchor.constraint(equalTo: placeImageView.bottomAnchor, constant: 8),
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            // 설명 라벨
            descriptionLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            descriptionLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor)
        ])
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if let gradientLayer = gradientOverlay.layer.sublayers?.first as? CAGradientLayer {
            gradientLayer.frame = gradientOverlay.bounds
        }
    }
    
    func configure(with place: Place, matchingScore: Int) {
        nameLabel.text = place.name
        descriptionLabel.text = place.description
        matchingScoreBar.score = matchingScore
        
        if let url = URL(string: place.imageURL) {
            URLSession.shared.dataTask(with: url) { data, _, _ in
                if let data = data, let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self.placeImageView.image = image
                    }
                }
            }.resume()
        }
    }
}
