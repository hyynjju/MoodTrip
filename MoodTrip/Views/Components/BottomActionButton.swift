import UIKit

// 이넘을 사용하여 버튼의 타입을 정의합니다.
enum BottomActionButtonType {
    case map
    case check
}

class BottomActionButton: UIView {

    private let type: BottomActionButtonType
    private let action: (() -> Void)?

    private let blurEffectView: UIVisualEffectView = {
            let blurEffect = UIBlurEffect(style: .dark) // 블러 스타일을 .dark로 변경
            let view = UIVisualEffectView(effect: blurEffect)
            view.translatesAutoresizingMaskIntoConstraints = false
            view.clipsToBounds = true // 블러 뷰도 코너 래디우스에 맞춰 잘리도록 설정
            return view
        }()
    
    // 배경 그라데이션 레이어
    private let backgroundGradientLayer: CAGradientLayer = {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
            UIColor.white.withAlphaComponent(0.1).cgColor, // 상단 0.1 투명도 흰색
            UIColor.white.withAlphaComponent(0.3).cgColor  // 하단 0.3 투명도 흰색
        ]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0) // 상단 시작
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)   // 하단 끝
        return gradientLayer
    }()


    private let button: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = .appFont(ofSize: 18, weight: .bold)
        button.setTitleColor(.white, for: .normal)
        button.clipsToBounds = true // 버튼 자체도 코너 래디우스에 맞춰 잘리도록 설정
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
        imageView.isHidden = true // 초기에는 숨김
        return imageView
    }()

    // 초기화 메서드
    init(type: BottomActionButtonType, action: (() -> Void)?) {
        self.type = type
        self.action = action
        super.init(frame: .zero)
        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        // 1. 배경에 블러 뷰 추가 (가장 아래)
        insertSubview(blurEffectView, at: 0)
        
        NSLayoutConstraint.activate([
            blurEffectView.topAnchor.constraint(equalTo: topAnchor),
            blurEffectView.bottomAnchor.constraint(equalTo: bottomAnchor),
            blurEffectView.leadingAnchor.constraint(equalTo: leadingAnchor),
            blurEffectView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])

        // 2. 새로운 배경 그라데이션 레이어 추가 (블러 뷰 바로 위에)
        layer.insertSublayer(backgroundGradientLayer, at: 1)

        // 3. 보더 그라데이션 설정 (가장 위에)
        setupBorderGradient()

        // 4. 버튼 추가 (콘텐츠를 담고 투명하게 유지)
        addSubview(button)
        button.backgroundColor = .clear // 버튼 자체는 투명하게
        
        NSLayoutConstraint.activate([
            button.topAnchor.constraint(equalTo: topAnchor),
            button.bottomAnchor.constraint(equalTo: bottomAnchor),
            button.leadingAnchor.constraint(equalTo: leadingAnchor),
            button.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])

        configureButtonContent()
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
    }
    
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

    private func configureButtonContent() {
        let contentStack = UIStackView()
        contentStack.axis = .horizontal
        contentStack.alignment = .center
        contentStack.spacing = 8 // 아이콘과 텍스트 사이 간격
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
                iconImageView.widthAnchor.constraint(equalToConstant: 24),
                iconImageView.heightAnchor.constraint(equalToConstant: 24)
            ])
            
        case .check:
            // 체크 버튼은 아이콘만 표시
            contentStack.addArrangedSubview(checkmarkImageView)
            
            NSLayoutConstraint.activate([
                checkmarkImageView.widthAnchor.constraint(equalToConstant: 24),
                checkmarkImageView.heightAnchor.constraint(equalToConstant: 24)
            ])
        }
    }

    @objc private func buttonTapped() {
        action?()
    }
    
    // 외부에서 체크마크 상태를 변경할 수 있는 메서드
    func setChecked(_ isChecked: Bool) {
        checkmarkImageView.isHidden = !isChecked
        
        // 체크 상태에 따라 체크마크 색상 변경
        if isChecked {
            checkmarkImageView.tintColor = .black // 체크시 검은색
        } else {
            checkmarkImageView.tintColor = UIColor.white.withAlphaComponent(0.5) // 언체크시 0.5 오퍼시티 흰색
        }
        
        // 애니메이션 효과 추가
        UIView.animate(withDuration: 0.2) {
            self.checkmarkImageView.transform = isChecked ? CGAffineTransform(scaleX: 1.1, y: 1.1) : .identity
        } completion: { _ in
            UIView.animate(withDuration: 0.1) {
                self.checkmarkImageView.transform = .identity
            }
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // 버튼 타입에 따라 cornerRadius 설정
        if type == .check {
            self.layer.cornerRadius = self.bounds.height / 2
        } else {
            self.layer.cornerRadius = 14
        }
        
        // 블러 뷰의 cornerRadius도 상위 뷰와 동일하게 설정하여 잘림
        blurEffectView.layer.cornerRadius = self.layer.cornerRadius

        // 새롭게 추가된 배경 그라데이션 레이어의 프레임과 cornerRadius 업데이트
        backgroundGradientLayer.frame = bounds
        backgroundGradientLayer.cornerRadius = self.layer.cornerRadius

        // 보더 그라데이션 및 마스크 업데이트
        if let borderGradientLayer = layer.sublayers?.first(where: { $0 is CAGradientLayer && $0.mask != nil }) as? CAGradientLayer,
           let borderShapeLayer = borderGradientLayer.mask as? CAShapeLayer {
            
            borderGradientLayer.frame = bounds
            borderGradientLayer.cornerRadius = self.layer.cornerRadius // 보더 그라데이션 레이어도 동일한 cornerRadius 적용
            
            // 보더 경로 업데이트 (둥근 모서리 적용)
            let path = UIBezierPath(roundedRect: bounds, cornerRadius: layer.cornerRadius)
            borderShapeLayer.path = path.cgPath
        }
    }
}
