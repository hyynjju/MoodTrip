import UIKit

class ResultViewController: UIViewController {
    var place: Place?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setupUI()
        
        // MARK: - 내비게이션 바 설정 (헤더 배경색 그라데이션 적용)
        // iOS 13 이상에서 사용 가능한 UINavigationBarAppearance 설정
        if #available(iOS 13.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithTransparentBackground() // 투명한 배경으로 시작

            // 그라데이션 이미지 생성
            let gradientImage = generateGradientImage(startColor: UIColor.black.withAlphaComponent(0.7),
                                                      endColor: UIColor.clear,
                                                      size: CGSize(width: UIScreen.main.bounds.width, height: 100)) // 내비게이션 바 높이에 맞춰 조절

            appearance.backgroundImage = gradientImage
            appearance.shadowImage = UIImage() // 내비게이션 바 하단 그림자 제거 (원한다면)

            // 타이틀 텍스트 색상 설정
            appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
            // 큰 타이틀 텍스트 색상 설정 (여기서는 prefersLargeTitles가 false이므로 크게 중요하지 않음)
            appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]

            navigationController?.navigationBar.standardAppearance = appearance
            navigationController?.navigationBar.scrollEdgeAppearance = appearance // 스크롤 시에도 동일하게 적용
            
            // 버튼 아이템 색상 설정
            navigationController?.navigationBar.tintColor = .white
            
        } else {
            // iOS 13 미만 버전에서는 기존 방식 유지 (투명하게 설정)
            navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
            navigationController?.navigationBar.shadowImage = UIImage()
            navigationController?.navigationBar.isTranslucent = true
            navigationController?.navigationBar.tintColor = .white
        }
        
        // 내비게이션 아이템 설정 (이전과 동일)
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "chevron.left"),
            style: .plain,
            target: self,
            action: #selector(backTapped)
        )
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "heart"),
            style: .plain,
            target: self,
            action: #selector(heartTapped)
        )
        // prefersLargeTitles는 appearance에서 관리되므로 이 줄은 제거하거나 그대로 두어도 무방
        navigationController?.navigationBar.prefersLargeTitles = false
    }
    
    // 그라데이션 이미지를 생성하는 헬퍼 함수
    private func generateGradientImage(startColor: UIColor, endColor: UIColor, size: CGSize) -> UIImage? {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = CGRect(origin: .zero, size: size)
        gradientLayer.colors = [startColor.cgColor, endColor.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0) // 상단
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0) // 하단

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

        // 이 gradientOverlay는 이제 내비게이션 바 그라데이션과는 별개입니다.
        // 기존 코드의 그라데이션 오버레이는 이미지 위에 있는 그라데이션이므로 유지합니다.
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
        nameLabel.adjustsFontSizeToFitWidth = true // 너비에 맞춰 폰트 크기 자동 조절
        nameLabel.minimumScaleFactor = 0.7 // 최소 폰트 크기 비율 (원래 크기의 70%까지 줄어듦)
        nameLabel.setContentCompressionResistancePriority(.required, for: .horizontal) // 가로 공간 저항 우선순위 높임
        nameLabel.translatesAutoresizingMaskIntoConstraints = false

        let descriptionLabel = UILabel()
        descriptionLabel.text = place.description
        descriptionLabel.font = .appFont(ofSize: 18)
        descriptionLabel.textColor = .white
        descriptionLabel.numberOfLines = 3
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false

        let nameDescStack = UIStackView(arrangedSubviews: [nameLabel, descriptionLabel])
        nameDescStack.axis = .vertical
        nameDescStack.alignment = .leading
        nameDescStack.spacing = 4
        nameDescStack.translatesAutoresizingMaskIntoConstraints = false

        // MARK: - 매칭 점수 (CircularProgressView 사용)
        let circularProgressView = CircularProgressView() // 새 인스턴스 생성
        circularProgressView.translatesAutoresizingMaskIntoConstraints = false
        circularProgressView.score = matchingScore(for: place)
        circularProgressView.progress = CGFloat(matchingScore(for: place)) / 100.0 // 100점 만점으로 가정
        // `ResultViewController`의 setupUI 내에서 `circularProgressView`를 서브뷰로 추가
        // view.addSubview(circularProgressView) // 이미 infoRowStack에 추가되므로 직접 추가할 필요 없음


        let infoRowStack = UIStackView(arrangedSubviews: [nameDescStack, circularProgressView]) // matchStack 대신 circularProgressView 사용
        infoRowStack.axis = .horizontal
        infoRowStack.distribution = .equalSpacing
        infoRowStack.alignment = .bottom
        infoRowStack.translatesAutoresizingMaskIntoConstraints = false


        let infoBox = InfoBoxView(tripLength: place.recommendedDuration, bestWith: place.bestWith, distance: "12.3 km")
        infoBox.translatesAutoresizingMaskIntoConstraints = false

        // MARK: - 상세 정보 (타이틀 변경 및 섹션 분리)
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

        view.addSubview(tagStack)
        view.addSubview(infoRowStack)
        view.addSubview(infoBox)
        view.addSubview(detailInfoLabel)

        NSLayoutConstraint.activate([
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            blurView.topAnchor.constraint(equalTo: view.topAnchor),
            blurView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            blurView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            blurView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            // 이 gradientOverlay는 내비게이션 바가 아닌 이미지 위에 있는 오버레이입니다.
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

            infoRowStack.topAnchor.constraint(equalTo: tagStack.bottomAnchor, constant: 4),
            infoRowStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            infoRowStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            // CircularProgressView의 크기 제약 추가
            circularProgressView.widthAnchor.constraint(equalToConstant: 120), // 원하는 크기로 설정
            circularProgressView.heightAnchor.constraint(equalToConstant: 120), // 원하는 크기로 설정

            infoBox.topAnchor.constraint(equalTo: infoRowStack.bottomAnchor, constant: 12),
            infoBox.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            infoBox.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            detailInfoLabel.topAnchor.constraint(equalTo: infoBox.bottomAnchor, constant: 16),
            detailInfoLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            detailInfoLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])

        view.layoutIfNeeded()
        gradientLayer.frame = gradientOverlay.bounds
    }

    private func matchingScore(for place: Place) -> Int {
        let total = place.scores.values.reduce(0, +)
        guard place.scores.count > 0 else { return 0 } // 0으로 나누는 오류 방지
        return total / place.scores.count
    }

    @objc private func backTapped() {
        navigationController?.popViewController(animated: true)
    }

    @objc private func heartTapped() {
        print("❤️ 하트 버튼 눌림")
    }
}

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

class InfoBoxView: UIView {
    init(tripLength: String, bestWith: String, distance: String) {
        super.init(frame: .zero)
        backgroundColor = UIColor.white.withAlphaComponent(0.15)
        layer.cornerRadius = 20
        clipsToBounds = true

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
            titleLabel.textAlignment = .center // 추가: 텍스트 중앙 정렬

            let valueLabel = UILabel()
            valueLabel.text = value
            valueLabel.font = .appFont(ofSize: 18, weight: .bold)
            valueLabel.textColor = .white
            valueLabel.textAlignment = .center // 추가: 텍스트 중앙 정렬

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
}



