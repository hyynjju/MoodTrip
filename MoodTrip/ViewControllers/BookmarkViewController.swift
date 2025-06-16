import UIKit

class BookmarkViewController: UIViewController {
    
    private var bookmarkedPlaces: [Place] = []
    
    private let stackView = UIStackView()

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
        navigationItem.title = "Saved Items"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadBookmarkedPlaces()
        self.tabBarController?.tabBar.isHidden = false
    }
    
    private func setupUI() {
        let titleLabel = UILabel()
        titleLabel.text = "Saved Items"
        titleLabel.textColor = .white
        titleLabel.font = .appFont(ofSize: 24, weight: .bold)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)
        
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.alignment = .leading
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            stackView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
        ])
    }
    
    private func loadBookmarkedPlaces() {
        bookmarkedPlaces = BookmarkManager.getBookmarkedPlaces()
        updateBookmarksUI()
    }
    
    private func updateBookmarksUI() {
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        if bookmarkedPlaces.isEmpty {
            let noBookmarksLabel = UILabel()
            noBookmarksLabel.text = "No saved places yet."
            noBookmarksLabel.textColor = .white.withAlphaComponent(0.7)
            noBookmarksLabel.font = .appFont(ofSize: 18)
            stackView.addArrangedSubview(noBookmarksLabel)
        } else {
            for place in bookmarkedPlaces {
                let placeLabel = UILabel()
                placeLabel.text = "• \(place.name)"
                placeLabel.textColor = .white
                placeLabel.font = .appFont(ofSize: 18)
                placeLabel.numberOfLines = 0
                stackView.addArrangedSubview(placeLabel)
                
                placeLabel.isUserInteractionEnabled = true
                let tapGesture = UITapGestureRecognizer(target: self, action: #selector(placeLabelTapped(_:)))
                placeLabel.addGestureRecognizer(tapGesture)
                // ⭐️ Place 객체 자체를 탭 제스처의 user info나 다른 방식으로 연결하는 것이 더 안전합니다.
                // 여기서는 간단하게 place.id를 태그로 저장합니다.
                placeLabel.tag = place.id // ⭐️ place.id가 Int 타입이므로 그대로 사용
            }
        }
    }
    
    @objc private func placeLabelTapped(_ sender: UITapGestureRecognizer) {
        // ⭐️ sender.view.tag를 사용하여 place.id를 직접 가져옵니다.
        guard let label = sender.view as? UILabel else { return }
        let tappedPlaceID = label.tag // Place.id가 Int이므로 tag에 바로 저장 가능
        
        // 해당 ID를 가진 Place 객체를 bookmarkedPlaces에서 찾습니다.
        if let selectedPlace = bookmarkedPlaces.first(where: { $0.id == tappedPlaceID }) {
            let vc = ResultViewController()
            vc.place = selectedPlace
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}

// ⭐️ Place Equatable 확장 시 id가 Int 타입이므로 그대로 사용
extension Place: Equatable {
    static func == (lhs: Place, rhs: Place) -> Bool {
        return lhs.id == rhs.id
    }
}
