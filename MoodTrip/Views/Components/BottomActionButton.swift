// BottomActionButton.swift

import UIKit

// 이넘을 사용하여 버튼의 타입을 정의합니다.
enum BottomActionButtonType {
    case map
    case check
}

class BottomActionButton: UIView {

    private let type: BottomActionButtonType
    private let action: (() -> Void)?

    private let button: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = .appFont(ofSize: 18, weight: .bold) // 적절한 폰트 설정
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 28 // 버튼 높이의 절반
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
    
    private let checkmarkImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(systemName: "checkmark") // 체크마크 이미지
        imageView.tintColor = .white
        imageView.backgroundColor = UIColor(red: 0.2, green: 0.6, blue: 1.0, alpha: 1.0) // 파란색 배경
        imageView.layer.cornerRadius = 28 / 2 // 동그랗게
        imageView.clipsToBounds = true
        imageView.isHidden = true // 초기에는 숨김
        return imageView
    }()

    init(type: BottomActionButtonType, action: (() -> Void)? = nil) {
        self.type = type
        self.action = action
        super.init(frame: .zero)
        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        // 배경색 설정 (사진의 버튼과 유사하게)
        backgroundColor = UIColor.white.withAlphaComponent(0.15) // 반투명 배경
        layer.cornerRadius = 28 // 버튼 높이의 절반
        clipsToBounds = true

        addSubview(button)
        addSubview(checkmarkImageView) // 체크마크 이미지 뷰 추가

        NSLayoutConstraint.activate([
            button.topAnchor.constraint(equalTo: topAnchor),
            button.bottomAnchor.constraint(equalTo: bottomAnchor),
            button.leadingAnchor.constraint(equalTo: leadingAnchor),
            button.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            // 체크마크 이미지 뷰의 제약 조건 (오른쪽 하단에 배치)
            checkmarkImageView.widthAnchor.constraint(equalToConstant: 28),
            checkmarkImageView.heightAnchor.constraint(equalToConstant: 28),
            checkmarkImageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            checkmarkImageView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8)
        ])

        configureButtonContent()
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
    }

    private func configureButtonContent() {
        switch type {
        case .map:
            let mapImage = UIImage(systemName: "map.fill") // 지도 아이콘
            iconImageView.image = mapImage
            button.setTitle(" Map", for: .normal) // 텍스트에 공백 추가
            button.titleLabel?.textAlignment = .center // 텍스트 중앙 정렬
            
            // 아이콘과 텍스트를 스택 뷰로 결합
            let stackView = UIStackView(arrangedSubviews: [iconImageView, button.titleLabel!])
            stackView.axis = .horizontal
            stackView.spacing = 8
            stackView.alignment = .center
            stackView.distribution = .fillProportionally
            stackView.translatesAutoresizingMaskIntoConstraints = false
            
            button.addSubview(stackView) // 버튼에 스택 뷰 추가
            
            NSLayoutConstraint.activate([
                stackView.centerXAnchor.constraint(equalTo: button.centerXAnchor),
                stackView.centerYAnchor.constraint(equalTo: button.centerYAnchor),
                iconImageView.widthAnchor.constraint(equalToConstant: 24), // 아이콘 크기
                iconImageView.heightAnchor.constraint(equalToConstant: 24)
            ])
            
        case .check:
            // 이 버튼은 초기에는 아무 텍스트나 아이콘 없이 둥근 배경만 가집니다.
            // 이후 요구사항에 따라 텍스트 또는 아이콘을 추가할 수 있습니다.
            // 현재 디자인에 따르면 오른쪽 버튼은 체크마크만 있으므로 텍스트는 비워둡니다.
            // '다녀온 여행지를 체크' 기능에 대한 시각적 피드백은 checkmarkImageView를 통해 이루어집니다.
            backgroundColor = .clear // 체크 버튼은 배경이 투명
        }
    }

    @objc private func buttonTapped() {
        action?()
        if type == .check {
            checkmarkImageView.isHidden.toggle() // 체크 버튼 탭 시 체크마크 토글
        }
    }
    
    // 이 함수를 외부에서 호출하여 체크마크 상태를 설정할 수 있습니다.
    func setChecked(_ isChecked: Bool) {
        checkmarkImageView.isHidden = !isChecked
    }
}
