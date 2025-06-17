// BookmarkCollectionViewCell.swift
import UIKit

class BookmarkCollectionViewCell: UICollectionViewCell {
    static let reuseIdentifier = "BookmarkCollectionViewCell"

    private let imageView = UIImageView()
    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()
    
    private let gradientLayer = CAGradientLayer()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        contentView.backgroundColor = .clear
        contentView.layer.cornerRadius = 12
        contentView.clipsToBounds = true

        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(imageView)

        // Gradient Layer setup (still not added to imageView.layer here)
        gradientLayer.colors = [
            UIColor.clear.cgColor,
            UIColor.black.withAlphaComponent(0.8).cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.3)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
        // **IMPORTANT**: Do not add gradientLayer to imageView.layer here in setupUI.
        // We'll add it in configure to ensure it's on top of image,
        // and then bring text labels to front.

        titleLabel.textColor = .white
        titleLabel.font = .appFont(ofSize: 32, weight: .bold)
        titleLabel.numberOfLines = 1
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.minimumScaleFactor = 0.7
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        imageView.addSubview(titleLabel) // Add labels to imageView

        descriptionLabel.textColor = .white.withAlphaComponent(0.8)
        descriptionLabel.font = .appFont(ofSize: 14)
        descriptionLabel.numberOfLines = 2
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        imageView.addSubview(descriptionLabel) // Add labels to imageView

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

            titleLabel.leadingAnchor.constraint(equalTo: imageView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: -16),
            titleLabel.bottomAnchor.constraint(equalTo: descriptionLabel.topAnchor, constant: -4),

            descriptionLabel.leadingAnchor.constraint(equalTo: imageView.leadingAnchor, constant: 16),
            descriptionLabel.trailingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: -16),
            descriptionLabel.bottomAnchor.constraint(equalTo: imageView.bottomAnchor, constant: -16)
        ])
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = imageView.bounds
    }

    func configure(with place: Place) {
        titleLabel.text = place.name
        descriptionLabel.text = place.description

        imageView.image = nil // 이미지 로드 전에 이미지 nil로 설정하여 깜빡임 방지

        // Ensure gradient is removed before potentially re-adding
        // This is safe even if it's not currently a sublayer.
        gradientLayer.removeFromSuperlayer()
        
        if let url = URL(string: place.imageURL) {
            URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
                guard let self = self else { return }
                if let data = data, let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self.imageView.image = image
                        // ⭐️ 이미지가 로드된 후 그라데이션 레이어를 추가합니다.
                        self.imageView.layer.addSublayer(self.gradientLayer)
                        // ⭐️ 그라데이션 위에 텍스트 라벨들을 올립니다.
                        self.imageView.bringSubviewToFront(self.titleLabel)
                        self.imageView.bringSubviewToFront(self.descriptionLabel)
                        self.setNeedsLayout()
                    }
                } else {
                    DispatchQueue.main.async {
                        self.imageView.image = UIImage(named: "placeholderImage")
                        self.imageView.layer.addSublayer(self.gradientLayer)
                        self.imageView.bringSubviewToFront(self.titleLabel)
                        self.imageView.bringSubviewToFront(self.descriptionLabel)
                        self.setNeedsLayout()
                    }
                }
            }.resume()
        } else {
            imageView.image = UIImage(named: "placeholderImage")
            imageView.layer.addSublayer(gradientLayer) // 플레이스홀더 이미지에도 적용
            imageView.bringSubviewToFront(titleLabel)
            imageView.bringSubviewToFront(descriptionLabel)
            setNeedsLayout()
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
        titleLabel.text = nil
        descriptionLabel.text = nil
        // gradientLayer.removeFromSuperlayer() // This is now done at the start of configure
    }
}
