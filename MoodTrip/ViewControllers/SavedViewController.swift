import UIKit

class SavedViewController: UIViewController {

    private let segmentControl: UISegmentedControl = {
        let sc = UISegmentedControl(items: ["List", "Map"])
        sc.selectedSegmentIndex = 0
        sc.translatesAutoresizingMaskIntoConstraints = false
        
        // 커스텀 다크모드 캡슐형 스타일
        sc.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        sc.selectedSegmentTintColor = UIColor(red: 0x73/255.0, green: 0xC2/255.0, blue: 0xFF/255.0, alpha: 0.4)
        
        // unselected 상태 텍스트
        sc.setTitleTextAttributes([
            .foregroundColor: UIColor.white.withAlphaComponent(0.3),
            .font: UIFont.systemFont(ofSize: 16, weight: .medium)
        ], for: .normal)
        
        // selected 상태 텍스트
        sc.setTitleTextAttributes([
            .foregroundColor: UIColor(red: 0x73/255.0, green: 0xC2/255.0, blue: 0xFF/255.0, alpha: 1.0),
            .font: UIFont.systemFont(ofSize: 16, weight: .semibold)
        ], for: .selected)
        
        // 캡슐형 둥근 모서리와 그림자
        sc.layer.cornerRadius = 32
        sc.layer.masksToBounds = true
        sc.layer.shadowOffset = CGSize(width: 0, height: 4)
        sc.layer.shadowRadius = 8
        sc.layer.shadowOpacity = 0.3
        
        // selected 상태의 보더 라인 설정
        sc.layer.borderWidth = 2
        sc.layer.borderColor = UIColor(red: 0x73/255.0, green: 0xC2/255.0, blue: 0xFF/255.0, alpha: 0.1).cgColor
        
        return sc
    }()
    
    // 선택 표시용 원형 인디케이터
    private let selectionIndicator: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(red: 0x73/255.0, green: 0xC2/255.0, blue: 0xFF/255.0, alpha: 1.0)
        view.layer.cornerRadius = 3
        view.isHidden = false
        return view
    }()

    private let savedListVC = SavedListViewController()
    private let savedMapVC = SavedMapViewController()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0)
        setupUI()
        setupChildControllers()
        setupGestureRecognizers()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        
        // 진입 애니메이션
        animateViewAppearance()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    private func setupUI() {
        view.addSubview(segmentControl)
        view.addSubview(selectionIndicator)
        
        segmentControl.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
        
        NSLayoutConstraint.activate([
            segmentControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            segmentControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            segmentControl.widthAnchor.constraint(equalToConstant: 220),
            segmentControl.heightAnchor.constraint(equalToConstant: 32),
            
            // 선택 인디케이터 위치 (List 탭 위치에 초기 설정)
            selectionIndicator.widthAnchor.constraint(equalToConstant: 6),
            selectionIndicator.heightAnchor.constraint(equalToConstant: 6),
            selectionIndicator.centerYAnchor.constraint(equalTo: segmentControl.centerYAnchor, constant: 0),
            selectionIndicator.leadingAnchor.constraint(equalTo: segmentControl.leadingAnchor, constant: 30)
        ])
    }

    private func setupChildControllers() {
        // SavedListViewController 설정
        addChild(savedListVC)
        view.addSubview(savedListVC.view)
        savedListVC.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            savedListVC.view.topAnchor.constraint(equalTo: segmentControl.bottomAnchor, constant: 20),
            savedListVC.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            savedListVC.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            savedListVC.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        savedListVC.didMove(toParent: self)

        // SavedMapViewController 설정
        addChild(savedMapVC)
        view.addSubview(savedMapVC.view)
        savedMapVC.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            savedMapVC.view.topAnchor.constraint(equalTo: segmentControl.bottomAnchor, constant: 20),
            savedMapVC.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            savedMapVC.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            savedMapVC.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        savedMapVC.didMove(toParent: self)
        
        // 초기 상태 설정
        savedMapVC.view.alpha = 0
        savedMapVC.view.transform = CGAffineTransform(translationX: 50, y: 0)
    }
    
    private func setupGestureRecognizers() {
        // 스와이프 제스처로 탭 전환
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeLeft))
        leftSwipe.direction = .left
        view.addGestureRecognizer(leftSwipe)
        
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeRight))
        rightSwipe.direction = .right
        view.addGestureRecognizer(rightSwipe)
    }
    
    @objc private func handleSwipeLeft() {
        if segmentControl.selectedSegmentIndex == 0 {
            segmentControl.selectedSegmentIndex = 1
            segmentChanged()
        }
    }
    
    @objc private func handleSwipeRight() {
        if segmentControl.selectedSegmentIndex == 1 {
            segmentControl.selectedSegmentIndex = 0
            segmentChanged()
        }
    }

    @objc private func segmentChanged() {
        let isList = segmentControl.selectedSegmentIndex == 0
        
        // 햅틱 피드백
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
        
        // 세그먼트 컨트롤 애니메이션
        UIView.animate(withDuration: 0.1, animations: {
            self.segmentControl.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.segmentControl.transform = .identity
            }
        }
        
        // 선택 인디케이터 애니메이션
        animateSelectionIndicator(isList: isList)
        
        // 뷰 전환 애니메이션
        if isList {
            animateToListView()
        } else {
            animateToMapView()
        }
    }
    
    private func animateSelectionIndicator(isList: Bool) {
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: [.curveEaseInOut], animations: {
            if isList {
                // List 탭 선택 시 왼쪽으로 이동
                self.selectionIndicator.transform = CGAffineTransform(translationX: 0, y: 0)
            } else {
                // Map 탭 선택 시 오른쪽으로 이동 (대략 110px)
                self.selectionIndicator.transform = CGAffineTransform(translationX: 110, y: 0)
            }
        })
    }
    
    private func animateToListView() {
        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, options: [.curveEaseInOut], animations: {
            // Map view 사라지는 애니메이션
            self.savedMapVC.view.alpha = 0
            self.savedMapVC.view.transform = CGAffineTransform(translationX: 50, y: 0)
            
            // List view 나타나는 애니메이션
            self.savedListVC.view.alpha = 1
            self.savedListVC.view.transform = .identity
        })
    }
    
    private func animateToMapView() {
        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, options: [.curveEaseInOut], animations: {
            // List view 사라지는 애니메이션
            self.savedListVC.view.alpha = 0
            self.savedListVC.view.transform = CGAffineTransform(translationX: -50, y: 0)
            
            // Map view 나타나는 애니메이션
            self.savedMapVC.view.alpha = 1
            self.savedMapVC.view.transform = .identity
        })
    }
    
    private func animateViewAppearance() {
        // 초기 상태 설정
        segmentControl.alpha = 0
        segmentControl.transform = CGAffineTransform(translationX: 0, y: -20)
        selectionIndicator.alpha = 0
        selectionIndicator.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        savedListVC.view.alpha = 0
        savedListVC.view.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        
        // 진입 애니메이션
        UIView.animate(withDuration: 0.6, delay: 0.1, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.3, options: [.curveEaseOut], animations: {
            self.segmentControl.alpha = 1
            self.segmentControl.transform = .identity
        })
        
        UIView.animate(withDuration: 0.5, delay: 0.2, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: [.curveEaseOut], animations: {
            self.selectionIndicator.alpha = 1
            self.selectionIndicator.transform = .identity
        })
        
        UIView.animate(withDuration: 0.7, delay: 0.3, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.3, options: [.curveEaseOut], animations: {
            self.savedListVC.view.alpha = 1
            self.savedListVC.view.transform = .identity
        })
    }
}

// MARK: - 추가 익스텐션으로 더 나은 사용자 경험 제공
extension SavedViewController {
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        // 다크모드/라이트모드 전환 시 그림자 업데이트
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            updateShadowForCurrentStyle()
        }
    }
    
    private func updateShadowForCurrentStyle() {
        // 다크모드 고정이므로 항상 다크 스타일 그림자 유지
        segmentControl.layer.shadowOpacity = 0.3
        segmentControl.layer.shadowColor = UIColor.black.cgColor
    }
}
