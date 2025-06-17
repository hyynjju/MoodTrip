import UIKit
import MapKit

class ResultViewController: UIViewController {
    var place: Place?
    var userScores: [String: Int] = [:]
    var recommendedPlaces: [Place] = []
    
    private static let buttonHeight: CGFloat = 50.0
    private static let buttonSpacing: CGFloat = 8.0
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private var recommendationsCollectionView: UICollectionView!
    
    private let topImageView = UIImageView()
    private var topImageViewHeightConstraint: NSLayoutConstraint!
    private let topImageViewGradientMask = CAGradientLayer()
    
    private let maxTopImageViewHeight: CGFloat = 320
    private let minTopImageViewHeight: CGFloat = 120
    private let scrollOffsetToFade: CGFloat = 100
    
    // ⭐️ 즐겨찾기 버튼을 위한 프로퍼티
    private var bookmarkButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        
        loadRecommendedPlaces()
        setupUI()
        
        // ⭐️ 네비게이션 바 설정 및 즐겨찾기 버튼 추가
        setupNavigationBar()
        
        // ⭐️ 현재 장소의 즐겨찾기 상태에 따라 버튼 이미지 초기 설정
        updateBookmarkButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    // ⭐️ 네비게이션 바 설정 함수
    private func setupNavigationBar() {
        if #available(iOS 13.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithTransparentBackground()
            appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
            appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
            
            navigationController?.navigationBar.standardAppearance = appearance
            navigationController?.navigationBar.scrollEdgeAppearance = appearance
        }
        
        navigationController?.navigationBar.tintColor = .white
        
        // ⭐️ 뒤로가기 버튼은 기본으로 제공
        // ⭐️ 즐겨찾기 버튼 추가
        bookmarkButton = UIBarButtonItem(image: UIImage(systemName: "heart"), style: .plain, target: self, action: #selector(bookmarkButtonTapped))
        navigationItem.rightBarButtonItem = bookmarkButton
    }
    
    // ⭐️ 즐겨찾기 버튼 탭 액션
    @objc private func bookmarkButtonTapped() {
        guard let place = place else { return }
        
        if BookmarkManager.isBookmarked(placeID: place.id) {
            BookmarkManager.removeBookmark(placeID: place.id)
        } else {
            BookmarkManager.addBookmark(placeID: place.id)
        }
        updateBookmarkButton()
    }
    
    // ⭐️ 즐겨찾기 버튼 이미지 업데이트
    private func updateBookmarkButton() {
        guard let place = place else { return }
        if BookmarkManager.isBookmarked(placeID: place.id) {
            bookmarkButton.image = UIImage(systemName: "heart.fill")
            bookmarkButton.tintColor = .red // 즐겨찾기 되면 빨간색으로
        } else {
            bookmarkButton.image = UIImage(systemName: "heart")
            bookmarkButton.tintColor = .white // 즐겨찾기 안 되면 흰색으로
        }
    }
    
    private func loadRecommendedPlaces() {
        let allPlaces = JSONLoader.loadPlaces(from: "places")
        
        guard let currentPlaceId = place?.id else {
            recommendedPlaces = Array(allPlaces.prefix(3)) // 현재 place가 없으면 모든 장소 중 3개
            return
        }
        
        let filteredPlaces = allPlaces.filter { $0.id != currentPlaceId }
        let sortedPlaces = filteredPlaces.sorted { calculateMatchingScore(for: $0) > calculateMatchingScore(for: $1) }
        recommendedPlaces = Array(sortedPlaces.prefix(3))
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
        
        topImageView.contentMode = .scaleAspectFill
        topImageView.clipsToBounds = true
        topImageView.layer.cornerRadius = 12
        topImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(topImageView)
        
        topImageViewGradientMask.colors = [UIColor.white.cgColor, UIColor.clear.cgColor]
        topImageViewGradientMask.startPoint = CGPoint(x: 0.5, y: 0.7)
        topImageViewGradientMask.endPoint = CGPoint(x: 0.5, y: 1.0)
        topImageView.layer.mask = topImageViewGradientMask
        
        if let url = URL(string: place.imageURL) {
            URLSession.shared.dataTask(with: url) { data, _, _ in
                if let data = data, let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        backgroundImageView.image = image
                        self.topImageView.image = image
                        self.topImageViewGradientMask.frame = self.topImageView.bounds
                    }
                }
            }.resume()
        }
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.delegate = self
        view.addSubview(scrollView)
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
        
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
        descriptionLabel.numberOfLines = 2
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let nameDescStack = UIStackView(arrangedSubviews: [nameLabel, descriptionLabel])
        nameDescStack.axis = .vertical
        nameDescStack.alignment = .leading
        nameDescStack.spacing = 4
        nameDescStack.translatesAutoresizingMaskIntoConstraints = false
        
        let circularProgressView = CircularProgressView()
        circularProgressView.translatesAutoresizingMaskIntoConstraints = false
        circularProgressView.score = calculateMatchingScore(for: place)
        circularProgressView.progress = CGFloat(calculateMatchingScore(for: place)) / 100.0
        
        let infoRowStack = UIStackView(arrangedSubviews: [nameDescStack, circularProgressView])
        infoRowStack.axis = .horizontal
        infoRowStack.distribution = .equalSpacing
        infoRowStack.alignment = .bottom
        infoRowStack.translatesAutoresizingMaskIntoConstraints = false
        
        let infoBox = InfoBoxView(tripLength: place.recommendedDuration, bestWith: place.bestWith, distance: "12.3 km")
        infoBox.translatesAutoresizingMaskIntoConstraints = false
        
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
        
        let recommendedPlacesTitleLabel = UILabel()
        let recommendedTitleAttributedString = NSMutableAttributedString()
        recommendedTitleAttributedString.append(NSAttributedString(string: "✶ More Recommendations\n", attributes: [.font: UIFont.appFont(ofSize: 20, weight: .bold), .foregroundColor: UIColor.white]))
        recommendedPlacesTitleLabel.attributedText = recommendedTitleAttributedString
        recommendedPlacesTitleLabel.numberOfLines = 0
        recommendedPlacesTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(recommendedPlacesTitleLabel)
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 240, height: 250)
        layout.minimumLineSpacing = 16
        layout.sectionInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        
        recommendationsCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        recommendationsCollectionView.translatesAutoresizingMaskIntoConstraints = false
        recommendationsCollectionView.backgroundColor = .clear
        recommendationsCollectionView.showsHorizontalScrollIndicator = false
        recommendationsCollectionView.dataSource = self
        recommendationsCollectionView.delegate = self
        recommendationsCollectionView.register(RecommendedPlaceCell.self, forCellWithReuseIdentifier: RecommendedPlaceCell.reuseIdentifier)
        contentView.addSubview(recommendationsCollectionView)
        
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
        
        view.addSubview(bottomButtonStack)
        
        contentView.addSubview(tagStack)
        contentView.addSubview(infoRowStack)
        contentView.addSubview(infoBox)
        contentView.addSubview(locationInfoLabel)
        contentView.addSubview(mapView)
        contentView.addSubview(aboutInfoLabel)
        
        view.addSubview(bottomButtonStack)
        
        topImageViewHeightConstraint = topImageView.heightAnchor.constraint(equalToConstant: maxTopImageViewHeight)

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
            topImageViewHeightConstraint,
            
            scrollView.topAnchor.constraint(equalTo: topImageView.bottomAnchor, constant: -70),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),
            
            tagStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0),
            tagStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            tagStack.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -20),
            
            infoRowStack.topAnchor.constraint(equalTo: tagStack.bottomAnchor, constant: -16),
            infoRowStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            infoRowStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            circularProgressView.widthAnchor.constraint(equalToConstant: 120),
            circularProgressView.heightAnchor.constraint(equalToConstant: 120),
            
            infoBox.topAnchor.constraint(equalTo: infoRowStack.bottomAnchor, constant: 12),
            infoBox.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            infoBox.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            locationInfoLabel.topAnchor.constraint(equalTo: infoBox.bottomAnchor, constant: 16),
            locationInfoLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            locationInfoLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            mapView.topAnchor.constraint(equalTo: locationInfoLabel.bottomAnchor, constant: -24),
            mapView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            mapView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            mapView.heightAnchor.constraint(equalToConstant: 160),
            
            aboutInfoLabel.topAnchor.constraint(equalTo: mapView.bottomAnchor, constant: 16),
            aboutInfoLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            aboutInfoLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            recommendedPlacesTitleLabel.topAnchor.constraint(equalTo: aboutInfoLabel.bottomAnchor, constant: 30),
            recommendedPlacesTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            recommendedPlacesTitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            recommendationsCollectionView.topAnchor.constraint(equalTo: recommendedPlacesTitleLabel.bottomAnchor, constant: -10),
            recommendationsCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            recommendationsCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            recommendationsCollectionView.heightAnchor.constraint(equalToConstant: 250),
            
            recommendationsCollectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -100),
            
            bottomButtonStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            bottomButtonStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            bottomButtonStack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0),
            bottomButtonStack.heightAnchor.constraint(equalToConstant: Self.buttonHeight),
            
            checkButton.widthAnchor.constraint(equalToConstant: Self.buttonHeight),
            checkButton.heightAnchor.constraint(equalToConstant: Self.buttonHeight),
            
            mapButton.heightAnchor.constraint(equalToConstant: Self.buttonHeight),
            mapButton.widthAnchor.constraint(equalTo: bottomButtonStack.widthAnchor, multiplier: 1.0, constant: -(Self.buttonHeight + Self.buttonSpacing)),
        ])
        
        view.layoutIfNeeded()
        gradientLayer.frame = gradientOverlay.bounds
        
        view.bringSubviewToFront(bottomButtonStack)
    }
    
    private func calculateMatchingScore(for place: Place) -> Int {
        var rawScore = 0
        let numberOfCategories = userScores.count
        
        guard numberOfCategories > 0 else { return 0 }
        
        for (key, userScore) in userScores {
            let placeScore = place.scores[key] ?? 0
            rawScore += 100 - abs(userScore - placeScore)
        }
        
        let maxPossibleRawScore = numberOfCategories * 100
        let normalizedScore = (Double(rawScore) / Double(maxPossibleRawScore)) * 100.0
        
        return Int(round(normalizedScore))
    }
    
    @objc private func backTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    private func navigateToMap() {
        guard let place = place else { return }
        let mapVC = SavedMapViewController()
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

// MARK: - UICollectionViewDataSource
extension ResultViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return recommendedPlaces.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RecommendedPlaceCell.reuseIdentifier, for: indexPath) as? RecommendedPlaceCell else {
            fatalError("Failed to dequeue RecommendedPlaceCell")
        }
        let place = recommendedPlaces[indexPath.item]
        let score = calculateMatchingScore(for: place)
        cell.configure(with: place, matchingScore: score)
        return cell
    }
}

// MARK: - UICollectionViewDelegate
extension ResultViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedPlace = recommendedPlaces[indexPath.item]
        print("Selected recommended place: \(selectedPlace.name)")
        let vc = ResultViewController()
        vc.place = selectedPlace
        vc.userScores = self.userScores
        navigationController?.pushViewController(vc, animated: true)
    }
}

// MARK: - UIScrollViewDelegate
extension ResultViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let contentOffsetY = scrollView.contentOffset.y
        
        let newHeight = maxTopImageViewHeight - contentOffsetY
        let clampedHeight = max(minTopImageViewHeight, min(maxTopImageViewHeight, newHeight))
        topImageViewHeightConstraint.constant = clampedHeight
        
        topImageViewGradientMask.frame = topImageView.bounds
        
        let alphaProgress = min(1.0, max(0.0, contentOffsetY / scrollOffsetToFade))
        topImageView.alpha = 1.0 - alphaProgress
    }
}

// PaddingLabel, InfoBoxView 클래스는 변경 없음 (이전 코드 유지)
// CircularProgressView, BottomActionButton 등 나머지 UI 컴포넌트도 변경 없음

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
