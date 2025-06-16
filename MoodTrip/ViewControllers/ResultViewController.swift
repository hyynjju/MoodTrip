import UIKit
import MapKit

class ResultViewController: UIViewController {
    var place: Place?
    private static let buttonHeight: CGFloat = 50.0
    private static let buttonSpacing: CGFloat = 8.0
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setupUI()
        
        if #available(iOS 13.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithTransparentBackground()
            appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
            appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
            
            navigationController?.navigationBar.standardAppearance = appearance
            navigationController?.navigationBar.scrollEdgeAppearance = appearance
        }
        
        navigationController?.navigationBar.tintColor = .white
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    private func generateGradientImage(startColor: UIColor, endColor: UIColor, size: CGSize) -> UIImage? {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = CGRect(origin: .zero, size: size)
        gradientLayer.colors = [startColor.cgColor, endColor.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
        
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
        
        // MARK: - Background Image & Blur (기존과 동일)
        let backgroundImageView = UIImageView()
        backgroundImageView.contentMode = .scaleAspectFill
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        backgroundImageView.clipsToBounds = true
        view.addSubview(backgroundImageView)
        
        let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        blurView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(blurView)
        
        let gradientOverlay = UIView()
        gradientOverlay.translatesAutoresizingMaskIntoConstraints = false
        view.insertSubview(gradientOverlay, aboveSubview: blurView)
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [UIColor.black.withAlphaComponent(0.7).cgColor, UIColor.clear.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
        gradientOverlay.layer.insertSublayer(gradientLayer, at: 0)
        
        let topImageView = UIImageView()
        topImageView.contentMode = .scaleAspectFill
        topImageView.clipsToBounds = true
        topImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(topImageView)
        
        if let url = URL(string: place.imageURL) {
            URLSession.shared.dataTask(with: url) { data, _, _ in
                if let data = data, let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        backgroundImageView.image = image
                        topImageView.image = image
                        
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
        
        // MARK: - ScrollView Setup
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView) // 스크롤 뷰를 뷰 컨트롤러의 뷰에 추가
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView) // 컨텐츠 뷰를 스크롤 뷰에 추가
        
        // MARK: - Tags Section (기존과 동일)
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
        
        // MARK: - Name & Description (기존과 동일)
        let nameLabel = UILabel()
        nameLabel.text = place.name
        nameLabel.font = .happyFont(ofSize: 48)
        nameLabel.textColor = .white
        nameLabel.numberOfLines = 2
        nameLabel.adjustsFontSizeToFitWidth = true
        nameLabel.minimumScaleFactor = 0.7
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
        
        // MARK: - Matching Score (CircularProgressView) (기존과 동일)
        let circularProgressView = CircularProgressView()
        circularProgressView.translatesAutoresizingMaskIntoConstraints = false
        circularProgressView.score = matchingScore(for: place)
        circularProgressView.progress = CGFloat(matchingScore(for: place)) / 100.0
        
        let infoRowStack = UIStackView(arrangedSubviews: [nameDescStack, circularProgressView])
        infoRowStack.axis = .horizontal
        infoRowStack.distribution = .equalSpacing
        infoRowStack.alignment = .bottom
        infoRowStack.translatesAutoresizingMaskIntoConstraints = false
        
        // MARK: - Info Box View (기존과 동일)
        let infoBox = InfoBoxView(tripLength: place.recommendedDuration, bestWith: place.bestWith, distance: "12.3 km")
        infoBox.translatesAutoresizingMaskIntoConstraints = false
        
        // MARK: - Detailed Info Section (Location & About) (기존과 동일)
        let locationInfoLabel = UILabel()
        let locationAttributedString = NSMutableAttributedString()
        locationAttributedString.append(NSAttributedString(string: "✶ Location\n", attributes: [.font: UIFont.appFont(ofSize: 20, weight: .bold), .foregroundColor: UIColor.white]))
        locationAttributedString.append(NSAttributedString(string: "\(place.address)\n\n", attributes: [.font: UIFont.appFont(ofSize: 16), .foregroundColor: UIColor.white.withAlphaComponent(0.7)]))
        locationInfoLabel.attributedText = locationAttributedString
        locationInfoLabel.numberOfLines = 0
        locationInfoLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let aboutInfoLabel = UILabel()
        let aboutAttributedString = NSMutableAttributedString()
        aboutAttributedString.append(NSAttributedString(string: "✶ About\n", attributes: [.font: UIFont.appFont(ofSize: 20, weight: .bold), .foregroundColor: UIColor.white]))
        aboutAttributedString.append(NSAttributedString(string: place.detailedDescription, attributes: [.font: UIFont.appFont(ofSize: 16), .foregroundColor: UIColor.white.withAlphaComponent(0.7)]))
        aboutInfoLabel.attributedText = aboutAttributedString
        aboutInfoLabel.numberOfLines = 0
        aboutInfoLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // MARK: - Map View (기존과 동일)
        let mapView = MKMapView()
        mapView.translatesAutoresizingMaskIntoConstraints = false
        mapView.layer.cornerRadius = 12
        mapView.clipsToBounds = true
        mapView.mapType = .standard
        mapView.isScrollEnabled = false
        mapView.isZoomEnabled = false
        mapView.isRotateEnabled = false
        mapView.isPitchEnabled = false
        
        let coordinate = CLLocationCoordinate2D(latitude: place.latitude, longitude: place.longitude)
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = place.name
        mapView.addAnnotation(annotation)
        
        let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 5000, longitudinalMeters: 5000)
        mapView.setRegion(region, animated: false)
        
        // MARK: - Bottom Action Buttons (기존과 동일)
        let mapButton = BottomActionButton(type: .map) { [weak self] in
            self?.navigateToMap()
        }
        mapButton.translatesAutoresizingMaskIntoConstraints = false
        
        let checkButton = BottomActionButton(type: .check) { [weak self] in
            self?.toggleCheckmark()
        }
        checkButton.translatesAutoresizingMaskIntoConstraints = false
        
        let bottomButtonStack = UIStackView(arrangedSubviews: [mapButton, checkButton])
        bottomButtonStack.axis = .horizontal
        bottomButtonStack.spacing = 8
        bottomButtonStack.distribution = .fill
        bottomButtonStack.alignment = .center
        bottomButtonStack.translatesAutoresizingMaskIntoConstraints = false
        
        // MARK: - Add Subviews and Constraints
        contentView.addSubview(tagStack)
        contentView.addSubview(infoRowStack)
        contentView.addSubview(infoBox)
        contentView.addSubview(locationInfoLabel)
        contentView.addSubview(mapView)
        contentView.addSubview(aboutInfoLabel)
        
        view.addSubview(bottomButtonStack) // 하단 버튼 스택 뷰는 스크롤 뷰 위에 고정되게 추가
        
        NSLayoutConstraint.activate([
            // 배경 이미지 (기존과 동일)
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // 블러 뷰 (기존과 동일)
            blurView.topAnchor.constraint(equalTo: view.topAnchor),
            blurView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            blurView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            blurView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // 상단 그라데이션 오버레이 (기존과 동일)
            gradientOverlay.topAnchor.constraint(equalTo: view.topAnchor),
            gradientOverlay.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            gradientOverlay.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            gradientOverlay.heightAnchor.constraint(equalToConstant: 80),
            
            // 상단 이미지 뷰 (기존과 동일)
            topImageView.topAnchor.constraint(equalTo: view.topAnchor),
            topImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            topImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            topImageView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.5),
            
            // 스크롤 뷰 제약 조건:
            // 이제 스크롤 뷰가 화면 하단까지 쭉 내려가도록 합니다.
            scrollView.topAnchor.constraint(equalTo: topImageView.bottomAnchor, constant: -70),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor), // ⭐️ 변경: 화면 하단까지 확장
            
            // 컨텐츠 뷰 제약 조건 (스크롤 뷰 내에서)
            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),
            
            // 태그 스택 (기존과 동일)
            tagStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0),
            tagStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            tagStack.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -20),
            
            // 정보 행 스택 (기존과 동일)
            infoRowStack.topAnchor.constraint(equalTo: tagStack.bottomAnchor, constant: -16),
            infoRowStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            infoRowStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            // CircularProgressView 크기 (기존과 동일)
            circularProgressView.widthAnchor.constraint(equalToConstant: 120),
            circularProgressView.heightAnchor.constraint(equalToConstant: 120),
            
            // 정보 박스 (기존과 동일)
            infoBox.topAnchor.constraint(equalTo: infoRowStack.bottomAnchor, constant: 12),
            infoBox.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            infoBox.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            // Location 정보 레이블 (기존과 동일)
            locationInfoLabel.topAnchor.constraint(equalTo: infoBox.bottomAnchor, constant: 16),
            locationInfoLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            locationInfoLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            // 지도 뷰 (요청하신 constant 변경 적용)
            mapView.topAnchor.constraint(equalTo: locationInfoLabel.bottomAnchor, constant: -24), // ⭐️ 요청하신 constant 변경
            mapView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            mapView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            mapView.heightAnchor.constraint(equalToConstant: 160),
            
            // About 섹션 라벨 (기존과 동일)
            aboutInfoLabel.topAnchor.constraint(equalTo: mapView.bottomAnchor, constant: 16),
            aboutInfoLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            aboutInfoLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            aboutInfoLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -150),
            
            // 하단 버튼 스택 뷰 (기존과 동일)
            bottomButtonStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            bottomButtonStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            bottomButtonStack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0),
            bottomButtonStack.heightAnchor.constraint(equalToConstant: Self.buttonHeight),
            
            // 체크 버튼 너비/높이 (기존과 동일)
            checkButton.widthAnchor.constraint(equalToConstant: Self.buttonHeight),
            checkButton.heightAnchor.constraint(equalToConstant: Self.buttonHeight),
            
            // 맵 버튼 높이 (기존과 동일)
            mapButton.heightAnchor.constraint(equalToConstant: Self.buttonHeight),
            
            // 맵 버튼 너비 (기존과 동일)
            mapButton.widthAnchor.constraint(equalTo: bottomButtonStack.widthAnchor, multiplier: 1.0, constant: -Self.buttonHeight - Self.buttonSpacing),
        ])
        
        view.layoutIfNeeded()
        gradientLayer.frame = gradientOverlay.bounds
        
        // MARK: - 뷰 계층 조정 (버튼이 스크롤뷰 위에 그려지도록)
        // bottomButtonStack이 scrollView보다 나중에 추가되도록 하거나, 명시적으로 위로 올립니다.
        // 현재 코드에서는 view.addSubview(scrollView) 다음에 view.addSubview(bottomButtonStack) 이므로
        // bottomButtonStack이 기본적으로 scrollView 위에 위치합니다.
        // 만약 문제가 있다면 이 코드를 추가하여 확실히 상단으로 올릴 수 있습니다.
        view.bringSubviewToFront(bottomButtonStack)
    }
    
    // ... (matchingScore, backTapped, heartTapped, navigateToMap, toggleCheckmark 메서드, PaddingLabel, InfoBoxView 클래스는 변경 없음)
    private func matchingScore(for place: Place?) -> Int {
        guard let unwrappedPlace = place else { return 0 }
        let total = unwrappedPlace.scores.values.reduce(0, +)
        guard unwrappedPlace.scores.count > 0 else { return 0 }
        return total / unwrappedPlace.scores.count
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
        mapVC.place = place
        navigationController?.pushViewController(mapVC, animated: true)
    }
    
    private func toggleCheckmark() {
        print("다녀온 여행지 체크 토글 (추후 기능 추가 예정)")
        if let checkButton = (self.view.subviews.compactMap { $0 as? UIStackView }.first?.arrangedSubviews.last as? BottomActionButton) {
            checkButton.setChecked(true)
        }
    }
}

// PaddingLabel 클래스 (변경 없음)
class PaddingLabel: UILabel {
    var padding: UIEdgeInsets
    
    init(padding: UIEdgeInsets) {
        self.padding = padding
        super.init(frame: .zero)
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.padding = .zero
        super.init(coder: aDecoder)
    }
    
    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: padding))
    }
    
    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(width: size.width + padding.left + padding.right,
                      height: size.height + padding.top + padding.bottom)
    }
}

// InfoBoxView 클래스 (변경 없음)
class InfoBoxView: UIView {
    init(tripLength: String, bestWith: String, distance: String) {
        super.init(frame: .zero)
        layer.cornerRadius = 20
        clipsToBounds = true
        
        let backgroundGradientLayer = CAGradientLayer()
        backgroundGradientLayer.colors = [UIColor.white.withAlphaComponent(0.06).cgColor, UIColor.white.withAlphaComponent(0.2).cgColor]
        backgroundGradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        backgroundGradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
        layer.insertSublayer(backgroundGradientLayer, at: 0)
        
        let borderGradientLayer = CAGradientLayer()
        borderGradientLayer.colors = [
            UIColor.white.withAlphaComponent(0.35).cgColor,
            UIColor.white.withAlphaComponent(0.35).cgColor,
            UIColor.white.withAlphaComponent(0.1).cgColor
        ]
        borderGradientLayer.locations = [0.0, 0.33, 1.0]
        borderGradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        borderGradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
        
        let borderShapeLayer = CAShapeLayer()
        borderShapeLayer.lineWidth = 3
        borderShapeLayer.strokeColor = UIColor.black.cgColor
        borderShapeLayer.fillColor = nil
        
        borderGradientLayer.mask = borderShapeLayer
        
        layer.addSublayer(borderGradientLayer)
        
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
        
        if let backgroundGradientLayer = layer.sublayers?.first(where: { $0 is CAGradientLayer && $0.mask == nil }) {
            backgroundGradientLayer.frame = bounds
        }
        
        if let borderGradientLayer = layer.sublayers?.first(where: { $0 is CAGradientLayer && $0.mask != nil }) as? CAGradientLayer,
           let borderShapeLayer = borderGradientLayer.mask as? CAShapeLayer {
            
            borderGradientLayer.frame = bounds
            
            let path = UIBezierPath(roundedRect: bounds, cornerRadius: layer.cornerRadius)
            borderShapeLayer.path = path.cgPath
        }
    }
}
