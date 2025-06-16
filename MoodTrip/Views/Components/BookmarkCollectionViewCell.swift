// BookmarkCollectionViewCell.swift
import UIKit

class BookmarkCollectionViewCell: UICollectionViewCell {
    static let reuseIdentifier = "BookmarkCollectionViewCell"

    private let imageView = UIImageView()
    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()
    
    // ⭐️ 기존 textOverlayView 대신 그라데이션 레이어를 사용할 것이므로 제거
    // private let textOverlayView = UIView()
    
    // ⭐️ 그라데이션 레이어 추가
    private let gradientLayer = CAGradientLayer()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        // 셀 배경 설정
        contentView.backgroundColor = .clear // 투명 배경
        contentView.layer.cornerRadius = 12
        contentView.clipsToBounds = true // 코너를 둥글게 자르기 위해 필요

        // 이미지 뷰 설정
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(imageView)

        // ⭐️ 그라데이션 레이어 설정 및 이미지 뷰에 추가
        gradientLayer.colors = [
            UIColor.clear.cgColor, // 위쪽은 투명
            UIColor.black.withAlphaComponent(0.8).cgColor // 아래쪽은 반투명 검정 (조절 가능)
        ]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.3) // 그라데이션 시작점 (이미지뷰의 30% 높이에서 시작)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)   // 그라데이션 끝점 (이미지뷰의 하단)
        imageView.layer.addSublayer(gradientLayer) // 이미지 뷰의 서브 레이어로 추가

        // 제목 라벨 설정
        titleLabel.textColor = .white
        titleLabel.font = .appFont(ofSize: 32, weight: .bold)
        titleLabel.numberOfLines = 1
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.minimumScaleFactor = 0.7
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        imageView.addSubview(titleLabel) // ⭐️ 이미지 뷰 위에 직접 추가 (그라데이션 위에)

        // 설명 라벨 설정
        descriptionLabel.textColor = .white.withAlphaComponent(0.8)
        descriptionLabel.font = .appFont(ofSize: 14)
        descriptionLabel.numberOfLines = 2
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        imageView.addSubview(descriptionLabel) // ⭐️ 이미지 뷰 위에 직접 추가 (그라데이션 위에)

        NSLayoutConstraint.activate([
            // 이미지 뷰 제약 조건 (셀 전체를 채움)
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

            // ⭐️ 텍스트 라벨들을 이미지 뷰 하단에 배치
            // 제목 라벨 제약 조건
            titleLabel.leadingAnchor.constraint(equalTo: imageView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: -16),
            titleLabel.bottomAnchor.constraint(equalTo: descriptionLabel.topAnchor, constant: -4), // 설명 라벨 위에 위치

            // 설명 라벨 제약 조건
            descriptionLabel.leadingAnchor.constraint(equalTo: imageView.leadingAnchor, constant: 16),
            descriptionLabel.trailingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: -16),
            descriptionLabel.bottomAnchor.constraint(equalTo: imageView.bottomAnchor, constant: -16) // 이미지 뷰 하단에 여백
        ])
    }

    // ⭐️ 레이아웃이 변경될 때마다 그라데이션 레이어의 프레임을 업데이트해야 합니다.
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = imageView.bounds // 이미지 뷰의 크기에 맞춰 그라데이션 프레임 설정
    }

    func configure(with place: Place) {
        titleLabel.text = place.name
        descriptionLabel.text = place.description

        if let url = URL(string: place.imageURL) {
            URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
                if let data = data, let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.imageView.image = image
                    }
                } else {
                    DispatchQueue.main.async {
                        self?.imageView.image = UIImage(named: "placeholderImage")
                    }
                }
            }.resume()
        } else {
            imageView.image = UIImage(named: "placeholderImage")
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
        titleLabel.text = nil
        descriptionLabel.text = nil
    }
}
