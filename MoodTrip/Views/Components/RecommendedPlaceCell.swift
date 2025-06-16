import UIKit

class RecommendedPlaceCell: UICollectionViewCell {
    static let reuseIdentifier = "RecommendedPlaceCell"
    
    private let placeImageView = UIImageView()
    private let nameLabel = UILabel()
    private let scoreLabel = UILabel()
    private let gradientOverlay = UIView() // 이미지 하단 그라데이션 오버레이
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.backgroundColor = .clear // 셀 배경 투명
        
        // 이미지 뷰 설정
        placeImageView.contentMode = .scaleAspectFill
        placeImageView.clipsToBounds = true
        placeImageView.layer.cornerRadius = 12 // ⭐️ 이미지 뷰 모서리 둥글게
        placeImageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(placeImageView)
        
        // 이미지 하단 그라데이션 오버레이 설정
        gradientOverlay.translatesAutoresizingMaskIntoConstraints = false
        placeImageView.addSubview(gradientOverlay) // 이미지 뷰 위에 추가
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [UIColor.clear.cgColor, UIColor.black.withAlphaComponent(0.6).cgColor]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
        gradientOverlay.layer.insertSublayer(gradientLayer, at: 0)
        
        // 이름 라벨 설정
        nameLabel.font = .appFont(ofSize: 18, weight: .bold)
        nameLabel.textColor = .white
        nameLabel.numberOfLines = 1
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(nameLabel)
        
        // 점수 라벨 설정
        scoreLabel.font = .appFont(ofSize: 14)
        scoreLabel.textColor = .white.withAlphaComponent(0.8)
        scoreLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(scoreLabel)
        
        // 제약 조건 설정
        NSLayoutConstraint.activate([
            // 이미지 뷰
            placeImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            placeImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            placeImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            placeImageView.heightAnchor.constraint(equalToConstant: 160), // ⭐️ 이미지 뷰 높이 160
            
            // 그라데이션 오버레이
            gradientOverlay.leadingAnchor.constraint(equalTo: placeImageView.leadingAnchor),
            gradientOverlay.trailingAnchor.constraint(equalTo: placeImageView.trailingAnchor),
            gradientOverlay.bottomAnchor.constraint(equalTo: placeImageView.bottomAnchor),
            gradientOverlay.heightAnchor.constraint(equalTo: placeImageView.heightAnchor, multiplier: 0.5),
            
            // 이름 라벨
            nameLabel.topAnchor.constraint(equalTo: placeImageView.bottomAnchor, constant: 8),
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            // 점수 라벨
            scoreLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            scoreLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            scoreLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            scoreLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor)
        ])
    }
    
    // 레이아웃 업데이트 시 그라데이션 레이어 프레임도 업데이트
    override func layoutSubviews() {
        super.layoutSubviews()
        if let gradientLayer = gradientOverlay.layer.sublayers?.first as? CAGradientLayer {
            gradientLayer.frame = gradientOverlay.bounds
        }
    }
    
    func configure(with place: Place, matchingScore: Int) {
        nameLabel.text = place.name
        scoreLabel.text = "Matching Score: \(matchingScore)%"
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
