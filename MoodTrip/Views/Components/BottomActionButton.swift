import UIKit

// MARK: - 버튼 타입 정의
enum BottomActionButtonType {
    case map
    case check
}

class BottomActionButton: UIView {
    
    // MARK: - 상수
    private static let cornerRadiusMap: CGFloat = 20.0 // Map 버튼의 코너 래디우스
    // Check 버튼은 높이의 절반으로 설정되므로 별도 상수 불필요 (layoutSubviews에서 계산)
    private static let iconSize: CGFloat = 24.0 // 아이콘 크기
    private static let contentSpacing: CGFloat = 8.0 // 아이콘과 텍스트 사이 간격
    
    // MARK: - 프로퍼티
    private let type: BottomActionButtonType
    private let action: (() -> Void)?
    
    // MARK: - UI 컴포넌트
    private let blurEffectView: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .dark)
        let view = UIVisualEffectView(effect: blurEffect)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.clipsToBounds = true
        return view
    }()
    
    private let backgroundGradientLayer: CAGradientLayer = {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
            UIColor.white.withAlphaComponent(0.1).cgColor,
            UIColor.white.withAlphaComponent(0.3).cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
        return gradientLayer
    }()
    
    private let button: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = .appFont(ofSize: 18, weight: .bold)
        button.setTitleColor(.white, for: .normal)
        button.clipsToBounds = true
        return button
    }()
    
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .white
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .appFont(ofSize: 18, weight: .bold)
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()
    
    private let checkmarkImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(systemName: "checkmark")
        imageView.tintColor = UIColor.white.withAlphaComponent(0.5)
        imageView.isHidden = true
        return imageView
    }()
    
    // MARK: - 초기화
    init(type: BottomActionButtonType, action: (() -> Void)?) {
        self.type = type
        self.action = action
        super.init(frame: .zero)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 뷰 설정
    private func setupView() {
        // 블러 뷰 추가 및 제약 조건 설정
        insertSubview(blurEffectView, at: 0)
        NSLayoutConstraint.activate([
            blurEffectView.topAnchor.constraint(equalTo: topAnchor),
            blurEffectView.bottomAnchor.constraint(equalTo: bottomAnchor),
            blurEffectView.leadingAnchor.constraint(equalTo: leadingAnchor),
            blurEffectView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
        
        // 배경 그라데이션 레이어 추가
        layer.insertSublayer(backgroundGradientLayer, at: 1)
        
        // 보더 그라데이션 설정
        setupBorderGradient()
        
        // 버튼 추가 및 제약 조건 설정
        addSubview(button)
        button.backgroundColor = .clear
        NSLayoutConstraint.activate([
            button.topAnchor.constraint(equalTo: topAnchor),
            button.bottomAnchor.constraint(equalTo: bottomAnchor),
            button.leadingAnchor.constraint(equalTo: leadingAnchor),
            button.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
        
        configureButtonContent()
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
    }
    
    // MARK: - 보더 그라데이션 설정
    private func setupBorderGradient() {
        let borderGradientLayer = CAGradientLayer()
        borderGradientLayer.colors = [
            UIColor.white.withAlphaComponent(1).cgColor,
            UIColor.white.withAlphaComponent(0.35).cgColor,
            UIColor.white.withAlphaComponent(0.1).cgColor
        ]
        borderGradientLayer.locations = [0.0, 0.33, 1.0]
        borderGradientLayer.startPoint = CGPoint(x: 0.2, y: 0.0)
        borderGradientLayer.endPoint = CGPoint(x: 0.4, y: 1.0)
        
        let borderShapeLayer = CAShapeLayer()
        borderShapeLayer.lineWidth = 2
        borderShapeLayer.strokeColor = UIColor.black.cgColor
        borderShapeLayer.fillColor = nil
        
        borderGradientLayer.mask = borderShapeLayer
        layer.addSublayer(borderGradientLayer)
    }
    
    // MARK: - 버튼 콘텐츠 설정
    private func configureButtonContent() {
        let contentStack = UIStackView()
        contentStack.axis = .horizontal
        contentStack.alignment = .center
        contentStack.spacing = Self.contentSpacing
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        
        button.addSubview(contentStack)
        
        NSLayoutConstraint.activate([
            contentStack.centerXAnchor.constraint(equalTo: button.centerXAnchor),
            contentStack.centerYAnchor.constraint(equalTo: button.centerYAnchor)
        ])
        
        switch type {
        case .map:
            iconImageView.image = UIImage(systemName: "map.fill")
            titleLabel.text = "Map"
            contentStack.addArrangedSubview(iconImageView)
            contentStack.addArrangedSubview(titleLabel)
            
            NSLayoutConstraint.activate([
                iconImageView.widthAnchor.constraint(equalToConstant: Self.iconSize),
                iconImageView.heightAnchor.constraint(equalToConstant: Self.iconSize)
            ])
            
        case .check:
            // 체크 버튼은 아이콘만 표시
            contentStack.addArrangedSubview(checkmarkImageView)
            
            NSLayoutConstraint.activate([
                checkmarkImageView.widthAnchor.constraint(equalToConstant: Self.iconSize),
                checkmarkImageView.heightAnchor.constraint(equalToConstant: Self.iconSize)
            ])
        }
    }
    
    // MARK: - 버튼 탭 액션
    @objc private func buttonTapped() {
        action?()
    }
    
    // MARK: - 체크마크 상태 변경
    func setChecked(_ isChecked: Bool) {
        checkmarkImageView.isHidden = !isChecked
        
        // 체크 상태에 따라 체크마크 색상 및 애니메이션 변경
        if isChecked {
            checkmarkImageView.tintColor = .black
        } else {
            checkmarkImageView.tintColor = UIColor.white.withAlphaComponent(0.5)
        }
        
        UIView.animate(withDuration: 0.2) {
            self.checkmarkImageView.transform = isChecked ? CGAffineTransform(scaleX: 1.1, y: 1.1) : .identity
        } completion: { _ in
            UIView.animate(withDuration: 0.1) {
                self.checkmarkImageView.transform = .identity
            }
        }
    }
    
    // MARK: - 레이아웃 업데이트
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // 뷰의 cornerRadius 설정
        if type == .check {
            self.layer.cornerRadius = self.bounds.height / 2 // 원형 버튼
        } else {
            self.layer.cornerRadius = Self.cornerRadiusMap // Map 버튼의 고정된 래디우스
        }
        
        // 하위 뷰/레이어의 cornerRadius 설정 및 프레임 업데이트
        blurEffectView.layer.cornerRadius = self.layer.cornerRadius
        backgroundGradientLayer.frame = bounds
        backgroundGradientLayer.cornerRadius = self.layer.cornerRadius
        button.layer.cornerRadius = self.layer.cornerRadius
        
        // 보더 그라데이션 및 마스크 업데이트
        if let borderGradientLayer = layer.sublayers?.first(where: { $0 is CAGradientLayer && $0.mask != nil }) as? CAGradientLayer,
           let borderShapeLayer = borderGradientLayer.mask as? CAShapeLayer {
            
            borderGradientLayer.frame = bounds
            borderGradientLayer.cornerRadius = self.layer.cornerRadius
            
            let path = UIBezierPath(roundedRect: bounds, cornerRadius: layer.cornerRadius)
            borderShapeLayer.path = path.cgPath
        }
    }
}
