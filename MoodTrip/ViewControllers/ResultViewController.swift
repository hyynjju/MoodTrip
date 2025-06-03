import UIKit

class ResultViewController: UIViewController {
    var place: Place?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setupUI()
        // 내비게이션 바 설정
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

        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.prefersLargeTitles = false

    }

    private func setupUI() {
        guard let place = place else {
            print("\u{274C} 결과 장소가 없음")
            return
        }

        // MARK: - 배경 이미지 (블러용)
        let backgroundImageView = UIImageView()
        backgroundImageView.contentMode = .scaleAspectFill
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        backgroundImageView.clipsToBounds = true
        view.addSubview(backgroundImageView)

        // MARK: - 블러 처리
        let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        blurView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(blurView)

        // MARK: - 상단 선명 이미지
        let topImageView = UIImageView()
        topImageView.contentMode = .scaleAspectFill
        topImageView.clipsToBounds = true
        topImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(topImageView)

        // 이미지 로딩 완료 후 그라데이션 마스크 적용
        if let url = URL(string: place.imageURL) {
            URLSession.shared.dataTask(with: url) { data, _, _ in
                if let data = data, let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        backgroundImageView.image = image
                        topImageView.image = image

                        // ⬇️ 그라데이션 마스크 추가
                        let gradientMask = CAGradientLayer()
                        gradientMask.frame = topImageView.bounds
                        gradientMask.colors = [UIColor.white.cgColor, UIColor.clear.cgColor]
                        gradientMask.startPoint = CGPoint(x: 0.5, y: 0.7) // 70% 지점부터
                        gradientMask.endPoint = CGPoint(x: 0.5, y: 1.0)   // 아래로 갈수록 투명
                        topImageView.layer.mask = gradientMask
                    }
                }
            }.resume()
        }

        // MARK: - 정보 영역
        let nameLabel = UILabel()
        nameLabel.text = place.name
        nameLabel.font = .boldSystemFont(ofSize: 48)
        nameLabel.textColor = .white
        nameLabel.numberOfLines = 2
        nameLabel.translatesAutoresizingMaskIntoConstraints = false

        let descriptionLabel = UILabel()
        descriptionLabel.text = place.description
        descriptionLabel.font = .systemFont(ofSize: 18)
        descriptionLabel.textColor = .white
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false

        let matchLabel = UILabel()
        matchLabel.text = "Match"
        matchLabel.font = .boldSystemFont(ofSize: 20)
        matchLabel.textColor = .white
        matchLabel.translatesAutoresizingMaskIntoConstraints = false

        let scoreLabel = UILabel()
        scoreLabel.text = "\(matchingScore(for: place))"
        scoreLabel.font = .systemFont(ofSize: 32)
        scoreLabel.textColor = .white
        scoreLabel.translatesAutoresizingMaskIntoConstraints = false

        let infoStack = UIStackView(arrangedSubviews: [nameLabel, descriptionLabel])
        infoStack.axis = .vertical
        infoStack.alignment = .leading
        infoStack.spacing = 8
        infoStack.translatesAutoresizingMaskIntoConstraints = false

        let scoreStack = UIStackView(arrangedSubviews: [scoreLabel, matchLabel])
        scoreStack.axis = .vertical
        scoreStack.alignment = .trailing
        scoreStack.spacing = 4
        scoreStack.translatesAutoresizingMaskIntoConstraints = false

        let combinedStack = UIStackView(arrangedSubviews: [infoStack, scoreStack])
        combinedStack.axis = .horizontal
        combinedStack.alignment = .bottom
        combinedStack.distribution = .equalSpacing
        combinedStack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(combinedStack)

        // MARK: - 제약 설정
        NSLayoutConstraint.activate([
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            blurView.topAnchor.constraint(equalTo: view.topAnchor),
            blurView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            blurView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            blurView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            topImageView.topAnchor.constraint(equalTo: view.topAnchor),
            topImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            topImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            topImageView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.5),

            combinedStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            combinedStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            combinedStack.bottomAnchor.constraint(equalTo: topImageView.bottomAnchor, constant: -20)
        ])
    }

    private func matchingScore(for place: Place) -> Int {
        let total = place.scores.values.reduce(0, +)
        return total / place.scores.count
    }

    @objc private func backTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func heartTapped() {
        print("❤️ 하트 버튼 눌림")
        // 즐겨찾기 기능 구현 예정
    }
}

