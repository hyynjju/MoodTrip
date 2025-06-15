import UIKit
import MapKit // MapKit 임포트 추가

class ResultViewController: UIViewController {
    var place: Place? // 장소 데이터를 저장하는 속성
    // 버튼 높이를 위한 상수 선언
    private static let buttonHeight: CGFloat = 50.0
    private static let buttonSpacing: CGFloat = 8.0 // 버튼 간 간격도 상수로 선언
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black // 뷰 배경색 설정
        setupUI() // UI 설정 메서드 호출
        
        // MARK: - Navigation Bar Customization
        if #available(iOS 13.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithTransparentBackground() // 투명한 배경 설정
            appearance.titleTextAttributes = [.foregroundColor: UIColor.white] // 타이틀 색상 흰색
            appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white] // 라지 타이틀 색상 흰색
            
            navigationController?.navigationBar.standardAppearance = appearance
            navigationController?.navigationBar.scrollEdgeAppearance = appearance
        }
        
        navigationController?.navigationBar.tintColor = .white // 네비게이션 아이템 색상 흰색
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true // 탭바 숨기기
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false // 탭바 다시 보이기
    }
    
    // 그라데이션 이미지를 생성하는 헬퍼 함수
    private func generateGradientImage(startColor: UIColor, endColor: UIColor, size: CGSize) -> UIImage? {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = CGRect(origin: .zero, size: size)
        gradientLayer.colors = [startColor.cgColor, endColor.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0) // 상단 시작
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0) // 하단 끝
        
        UIGraphicsBeginImageContext(size)
        gradientLayer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    private func setupUI() {
        guard let place = place else {
            print("❌ 결과 장소가 없음")
            return
        }
        
        // MARK: - Background Image & Blur
        let backgroundImageView = UIImageView()
        backgroundImageView.contentMode = .scaleAspectFill
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        backgroundImageView.clipsToBounds = true
        view.addSubview(backgroundImageView)
        
        let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .dark)) // 블러 효과 뷰
        blurView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(blurView)
        
        // 상단 이미지 오버레이 (네비게이션 바가 아님)
        let gradientOverlay = UIView()
        gradientOverlay.translatesAutoresizingMaskIntoConstraints = false
        view.insertSubview(gradientOverlay, aboveSubview: blurView)
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [UIColor.black.withAlphaComponent(0.7).cgColor, UIColor.clear.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
        gradientOverlay.layer.insertSublayer(gradientLayer, at: 0)
        
        // 상단 이미지 뷰
        let topImageView = UIImageView()
        topImageView.contentMode = .scaleAspectFill
        topImageView.clipsToBounds = true
        topImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(topImageView)
        
        // 이미지 로딩 및 그라데이션 마스크 적용
        if let url = URL(string: place.imageURL) {
            URLSession.shared.dataTask(with: url) { data, _, _ in
                if let data = data, let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        backgroundImageView.image = image
                        topImageView.image = image
                        
                        // 이미지 하단에 투명 그라데이션 마스크 적용
                        let gradientMask = CAGradientLayer()
                        gradientMask.frame = topImageView.bounds
                        gradientMask.colors = [UIColor.white.cgColor, UIColor.clear.cgColor]
                        gradientMask.startPoint = CGPoint(x: 0.5, y: 0.7)
                        gradientMask.endPoint = CGPoint(x: 0.5, y: 1.0)
                        topImageView.layer.mask = gradientMask
                    }
                }
            }.resume()
        }
        
        // MARK: - Tags Section
        let tagStack = UIStackView()
        tagStack.axis = .horizontal
        tagStack.spacing = 8
        tagStack.translatesAutoresizingMaskIntoConstraints = false
        for tag in place.tags {
            let tagLabel = PaddingLabel(padding: UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10))
            tagLabel.text = "#\(tag.capitalized)"
            tagLabel.font = .appFont(ofSize: 14, weight: .bold)
            tagLabel.textColor = .white
            tagLabel.backgroundColor = UIColor.black.withAlphaComponent(0.3)
            tagLabel.layer.cornerRadius = 12
            tagLabel.clipsToBounds = true
            tagLabel.textAlignment = .center
            tagLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
            tagLabel.translatesAutoresizingMaskIntoConstraints = false
            tagLabel.heightAnchor.constraint(equalToConstant: 24).isActive = true
            tagStack.addArrangedSubview(tagLabel)
        }
        
        // MARK: - Name & Description
        let nameLabel = UILabel()
        nameLabel.text = place.name
        nameLabel.font = .happyFont(ofSize: 48)
        nameLabel.textColor = .white
        nameLabel.numberOfLines = 2
        nameLabel.adjustsFontSizeToFitWidth = true // 폰트 크기 자동 조절
        nameLabel.minimumScaleFactor = 0.7 // 최소 폰트 크기 비율
        nameLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let descriptionLabel = UILabel()
        descriptionLabel.text = place.description
        descriptionLabel.font = .appFont(ofSize: 16)
        descriptionLabel.textColor = .white
        descriptionLabel.numberOfLines = 3
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let nameDescStack = UIStackView(arrangedSubviews: [nameLabel, descriptionLabel])
        nameDescStack.axis = .vertical
        nameDescStack.alignment = .leading
        nameDescStack.spacing = 4
        nameDescStack.translatesAutoresizingMaskIntoConstraints = false
        
        // MARK: - Matching Score (CircularProgressView)
        let circularProgressView = CircularProgressView()
        circularProgressView.translatesAutoresizingMaskIntoConstraints = false
        circularProgressView.score = matchingScore(for: place)
        circularProgressView.progress = CGFloat(matchingScore(for: place)) / 100.0 // 0-100점 만점 기준
        
        let infoRowStack = UIStackView(arrangedSubviews: [nameDescStack, circularProgressView])
        infoRowStack.axis = .horizontal
        infoRowStack.distribution = .equalSpacing
        infoRowStack.alignment = .bottom
        infoRowStack.translatesAutoresizingMaskIntoConstraints = false
        
        // MARK: - Info Box View
        let infoBox = InfoBoxView(tripLength: place.recommendedDuration, bestWith: place.bestWith, distance: "12.3 km")
        infoBox.translatesAutoresizingMaskIntoConstraints = false
        
        // MARK: - Detailed Info Section
        let detailInfoLabel = UILabel()
        let attributedString = NSMutableAttributedString()
        
        // Location 섹션
        attributedString.append(NSAttributedString(string: "✶ Location\n", attributes: [.font: UIFont.appFont(ofSize: 20, weight: .bold), .foregroundColor: UIColor.white]))
        attributedString.append(NSAttributedString(string: "\(place.address)\n\n", attributes: [.font: UIFont.appFont(ofSize: 16), .foregroundColor: UIColor.white.withAlphaComponent(0.7)]))
        
        // About 섹션
        attributedString.append(NSAttributedString(string: "✶ About\n", attributes: [.font: UIFont.appFont(ofSize: 20, weight: .bold), .foregroundColor: UIColor.white]))
        attributedString.append(NSAttributedString(string: place.detailedDescription, attributes: [.font: UIFont.appFont(ofSize: 16), .foregroundColor: UIColor.white.withAlphaComponent(0.7)]))
        
        detailInfoLabel.attributedText = attributedString
        detailInfoLabel.numberOfLines = 0
        detailInfoLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // MARK: - Bottom Action Buttons
        // "Map" 버튼
        let mapButton = BottomActionButton(type: .map) { [weak self] in
            self?.navigateToMap()
        }
        mapButton.translatesAutoresizingMaskIntoConstraints = false
        
        // "Check" 버튼 (사진의 오른쪽 체크마크 버튼)
        let checkButton = BottomActionButton(type: .check) { [weak self] in
            self?.toggleCheckmark()
        }
        checkButton.translatesAutoresizingMaskIntoConstraints = false
        
        // 두 버튼을 담을 스택 뷰
        let bottomButtonStack = UIStackView(arrangedSubviews: [mapButton, checkButton])
        bottomButtonStack.axis = .horizontal
        bottomButtonStack.spacing = 8 // 버튼 사이 간격 8픽셀
        bottomButtonStack.distribution = .fill // .fillProportionally 대신 .fill을 사용하여 너비 제약을 더 잘 따르게 합니다.
        bottomButtonStack.alignment = .center
        bottomButtonStack.translatesAutoresizingMaskIntoConstraints = false
        
        // MARK: - Add Subviews and Constraints
        view.addSubview(tagStack)
        view.addSubview(infoRowStack)
        view.addSubview(infoBox)
        view.addSubview(detailInfoLabel)
        view.addSubview(bottomButtonStack) // 하단 버튼 스택 뷰 추가
        
        NSLayoutConstraint.activate([
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            blurView.topAnchor.constraint(equalTo: view.topAnchor),
            blurView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            blurView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            blurView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            gradientOverlay.topAnchor.constraint(equalTo: view.topAnchor),
            gradientOverlay.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            gradientOverlay.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            gradientOverlay.heightAnchor.constraint(equalToConstant: 80),
            
            topImageView.topAnchor.constraint(equalTo: view.topAnchor),
            topImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            topImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            topImageView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.5),
            
            tagStack.topAnchor.constraint(equalTo: topImageView.bottomAnchor, constant: -104),
            tagStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            
            infoRowStack.topAnchor.constraint(equalTo: tagStack.bottomAnchor, constant: -16),
            infoRowStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            infoRowStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            
            // CircularProgressView 크기 제약
            circularProgressView.widthAnchor.constraint(equalToConstant: 120),
            circularProgressView.heightAnchor.constraint(equalToConstant: 120),
            
            infoBox.topAnchor.constraint(equalTo: infoRowStack.bottomAnchor, constant: 12),
            infoBox.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            infoBox.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            detailInfoLabel.topAnchor.constraint(equalTo: infoBox.bottomAnchor, constant: 16),
            detailInfoLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            detailInfoLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            // 하단 버튼 스택 뷰 제약 조건
            bottomButtonStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            bottomButtonStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            bottomButtonStack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            bottomButtonStack.heightAnchor.constraint(equalToConstant: Self.buttonHeight), // 상수 사용
            
            // 오른쪽 체크 버튼은 무조건 정원형 (높이에 맞춰 너비도 설정)
            checkButton.widthAnchor.constraint(equalToConstant: Self.buttonHeight), // 상수 사용
            checkButton.heightAnchor.constraint(equalToConstant: Self.buttonHeight), // 상수 사용
            
            // 왼쪽 맵 버튼의 높이를 오른쪽 체크 버튼과 동일하게
            mapButton.heightAnchor.constraint(equalToConstant: Self.buttonHeight), // 상수 사용
            
            // 왼쪽 맵 버튼의 너비는 남은 공간을 모두 차지하도록 설정
            mapButton.widthAnchor.constraint(equalTo: bottomButtonStack.widthAnchor, multiplier: 1.0, constant: -Self.buttonHeight - Self.buttonSpacing), // 상수 사용
        ])
        
        view.layoutIfNeeded() // 레이아웃 즉시 적용
        gradientLayer.frame = gradientOverlay.bounds // 그라데이션 레이어 프레임 설정
    }
    
    private func matchingScore(for place: Place) -> Int {
        let total = place.scores.values.reduce(0, +)
        guard place.scores.count > 0 else { return 0 } // 0으로 나누기 방지
        return total / place.scores.count
    }
    
    @objc private func backTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func heartTapped() {
        print("❤️ 하트 버튼 눌림")
    }
    
    // MARK: - Button Actions
    private func navigateToMap() {
        guard let place = place else { return }
        let mapVC = MapViewController()
        mapVC.place = place // 지도 뷰 컨트롤러에 장소 데이터 전달
        navigationController?.pushViewController(mapVC, animated: true)
    }
    
    private func toggleCheckmark() {
        print("다녀온 여행지 체크 토글 (추후 기능 추가 예정)")
        // 여기에 다녀온 여행지 상태를 업데이트하는 로직을 추가할 수 있습니다.
        // 예를 들어, CoreData, Realm, UserDefaults 등에 저장하고 버튼의 상태를 업데이트
    }
}

// PaddingLabel 클래스
class PaddingLabel: UILabel {
    var padding: UIEdgeInsets // 패딩 값을 저장
    
    init(padding: UIEdgeInsets) {
        self.padding = padding
        super.init(frame: .zero)
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.padding = .zero
        super.init(coder: aDecoder)
    }
    
    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: padding)) // 패딩 적용하여 텍스트 그리기
    }
    
    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(width: size.width + padding.left + padding.right,
                      height: size.height + padding.top + padding.bottom) // 패딩 포함한 고유 크기 반환
    }
}

// InfoBoxView 클래스
class InfoBoxView: UIView {
    init(tripLength: String, bestWith: String, distance: String) {
        super.init(frame: .zero)
        layer.cornerRadius = 20
        clipsToBounds = true
        
        // MARK: - 배경 그라데이션 레이어
        let backgroundGradientLayer = CAGradientLayer()
        backgroundGradientLayer.colors = [UIColor.white.withAlphaComponent(0.06).cgColor, UIColor.white.withAlphaComponent(0.2).cgColor]
        backgroundGradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0) // 상단
        backgroundGradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0) // 하단
        layer.insertSublayer(backgroundGradientLayer, at: 0) // 가장 아래 레이어로 삽입
        
        // MARK: - 보더 그라데이션 레이어
        let borderGradientLayer = CAGradientLayer()
        borderGradientLayer.colors = [
            UIColor.white.withAlphaComponent(0.35).cgColor,
            UIColor.white.withAlphaComponent(0.35).cgColor, // 33% 지점까지 0.35 유지
            UIColor.white.withAlphaComponent(0.1).cgColor   // 33%부터 0.1로
        ]
        borderGradientLayer.locations = [0.0, 0.33, 1.0] // 색상 위치 설정
        borderGradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0) // 상단
        borderGradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0) // 하단
        
        // 보더 형태를 위한 CAShapeLayer (마스크로 사용)
        let borderShapeLayer = CAShapeLayer()
        borderShapeLayer.lineWidth = 3 // 보더 두께
        borderShapeLayer.strokeColor = UIColor.black.cgColor // 실제 색상은 마스크이므로 중요하지 않음
        borderShapeLayer.fillColor = nil // 내부 채우지 않음
        
        borderGradientLayer.mask = borderShapeLayer // 그라데이션 레이어의 마스크로 설정
        
        layer.addSublayer(borderGradientLayer) // 뷰의 레이어에 보더 그라데이션 레이어 추가
        
        // MARK: - 콘텐츠 스택 뷰
        let labels = [("Trip Length", tripLength), ("Best With", bestWith), ("Distance", distance)]
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        for (title, value) in labels {
            let titleLabel = UILabel()
            titleLabel.text = title
            titleLabel.font = .appFont(ofSize: 14)
            titleLabel.textColor = .white.withAlphaComponent(0.7)
            titleLabel.textAlignment = .center
            
            let valueLabel = UILabel()
            valueLabel.text = value
            valueLabel.font = .appFont(ofSize: 18, weight: .bold)
            valueLabel.textColor = .white
            valueLabel.textAlignment = .center
            
            let verticalStack = UIStackView(arrangedSubviews: [titleLabel, valueLabel])
            verticalStack.axis = .vertical
            verticalStack.alignment = .center
            verticalStack.spacing = 4
            
            stack.addArrangedSubview(verticalStack)
        }
        
        addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // 배경 그라데이션 레이어 프레임 업데이트
        if let backgroundGradientLayer = layer.sublayers?.first(where: { $0 is CAGradientLayer && $0.mask == nil }) {
            backgroundGradientLayer.frame = bounds
        }
        
        // MARK: - 보더 그라데이션 및 마스크 업데이트
        if let borderGradientLayer = layer.sublayers?.first(where: { $0 is CAGradientLayer && $0.mask != nil }) as? CAGradientLayer,
           let borderShapeLayer = borderGradientLayer.mask as? CAShapeLayer {
            
            borderGradientLayer.frame = bounds // 보더 그라데이션 레이어 프레임 설정
            
            // 보더 경로 업데이트 (둥근 모서리 적용)
            let path = UIBezierPath(roundedRect: bounds, cornerRadius: layer.cornerRadius)
            borderShapeLayer.path = path.cgPath
        }
    }
}
