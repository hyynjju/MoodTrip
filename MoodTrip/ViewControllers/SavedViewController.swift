import UIKit

class SavedViewController: UIViewController {

    private let segmentControl: UISegmentedControl = {
        let sc = UISegmentedControl(items: ["List", "Map"])
        sc.selectedSegmentIndex = 0
        sc.translatesAutoresizingMaskIntoConstraints = false
        return sc
    }()

    private let savedListVC = SavedListViewController()
    private let savedMapVC = SavedMapViewController()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setupSegmentControl()
        setupChildControllers()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }


    private func setupSegmentControl() {
        view.addSubview(segmentControl)
        segmentControl.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
        NSLayoutConstraint.activate([
            segmentControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            segmentControl.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }

    private func setupChildControllers() {
        addChild(savedListVC)
        view.addSubview(savedListVC.view)
        savedListVC.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            savedListVC.view.topAnchor.constraint(equalTo: segmentControl.bottomAnchor, constant: 8),
            savedListVC.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            savedListVC.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            savedListVC.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        savedListVC.didMove(toParent: self)

        addChild(savedMapVC)
        view.addSubview(savedMapVC.view)
        savedMapVC.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            savedMapVC.view.topAnchor.constraint(equalTo: segmentControl.bottomAnchor, constant: 8),
            savedMapVC.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            savedMapVC.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            savedMapVC.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        savedMapVC.didMove(toParent: self)
        savedMapVC.view.isHidden = true
    }

    @objc private func segmentChanged() {
        let isList = segmentControl.selectedSegmentIndex == 0
        savedListVC.view.isHidden = !isList
        savedMapVC.view.isHidden = isList
    }
}
