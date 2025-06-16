import UIKit

class BookmarkViewController: UIViewController {
    
    private var bookmarkedPlaces: [Place] = []
    
    // ⭐️ UICollectionView로 변경
    private var collectionView: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        
        setupNavigationBar() // ⭐️ 네비게이션 바 설정 함수 호출
        setupCollectionView() // ⭐️ 컬렉션 뷰 설정 함수 호출
        
        // ⭐️ 기존 stackView 관련 코드는 제거합니다.
        // setupUI() 대신 setupCollectionView()를 호출
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadBookmarkedPlaces()
        // 탭바가 항상 보이도록 설정. 만약 다른 뷰에서 탭바를 숨겼다가 여기로 돌아올 경우를 대비
        self.tabBarController?.tabBar.isHidden = false
        collectionView.reloadData() // 데이터 변경 시 컬렉션 뷰 새로고침
    }
    
    // ⭐️ 네비게이션 바 설정 함수 (타이틀 변경)
    private func setupNavigationBar() {
        if #available(iOS 13.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithTransparentBackground()
            appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
            appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white] // Large title도 흰색으로
            
            navigationController?.navigationBar.standardAppearance = appearance
            navigationController?.navigationBar.scrollEdgeAppearance = appearance
        }
        navigationController?.navigationBar.tintColor = .white
        navigationItem.title = "Liked Places" // ⭐️ 타이틀 변경
    }
    
    // ⭐️ UICollectionView 설정 함수
    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical // 수직 스크롤
        layout.minimumLineSpacing = 20 // 셀 간 수직 간격
        layout.minimumInteritemSpacing = 0 // 셀 간 수평 간격 (여기서는 사용되지 않음)
        layout.sectionInset = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20) // 전체 섹션 여백
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear // 배경 투명
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(BookmarkCollectionViewCell.self, forCellWithReuseIdentifier: BookmarkCollectionViewCell.reuseIdentifier)
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor), // 상단 여백
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor) // 하단 탭바를 고려한 safe area
        ])
    }
    
    private func loadBookmarkedPlaces() {
        bookmarkedPlaces = BookmarkManager.getBookmarkedPlaces()
        collectionView.reloadData() // 데이터 로드 후 컬렉션 뷰 새로고침
    }
}

// MARK: - UICollectionViewDataSource
extension BookmarkViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return bookmarkedPlaces.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BookmarkCollectionViewCell.reuseIdentifier, for: indexPath) as? BookmarkCollectionViewCell else {
            fatalError("Failed to dequeue BookmarkCollectionViewCell")
        }
        let place = bookmarkedPlaces[indexPath.item]
        cell.configure(with: place)
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout (셀 크기 조절)
extension BookmarkViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // 스크린샷을 보면 셀 너비는 뷰 전체 너비에서 좌우 여백을 뺀 값입니다.
        // 높이는 대략 220~250 정도로 보입니다.
        let width = collectionView.bounds.width - 20 * 2 // 좌우 여백 20씩
        let height: CGFloat = 220 // 셀의 고정 높이 (스크린샷 기반 추정)
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedPlace = bookmarkedPlaces[indexPath.item]
        print("Selected bookmarked place: \(selectedPlace.name)")
        
        let vc = ResultViewController()
        vc.place = selectedPlace
        // BookmarkViewController에서는 userScores 정보가 없으므로 필요하다면 ResultViewController에서 기본값 처리
        // 또는 앱 전체에서 userScores를 관리하는 ViewModel 등을 고려
        navigationController?.pushViewController(vc, animated: true)
    }
}

// Place Equatable 확장 (기존과 동일)
extension Place: Equatable {
    static func == (lhs: Place, rhs: Place) -> Bool {
        return lhs.id == rhs.id
    }
}
