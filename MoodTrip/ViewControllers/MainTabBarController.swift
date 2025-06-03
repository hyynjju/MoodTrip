import UIKit

class MainTabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()

        let mainVC = MainViewController()
        mainVC.tabBarItem = UITabBarItem(title: "Home", image: UIImage(systemName: "house"), tag: 0)

        let mapVC = MapViewController()
        mapVC.tabBarItem = UITabBarItem(title: "Map", image: UIImage(systemName: "map"), tag: 1)

        let savedVC = BookmarkViewController()
        savedVC.tabBarItem = UITabBarItem(title: "Saved", image: UIImage(systemName: "bookmark"), tag: 2)

        let mainNav = UINavigationController(rootViewController: mainVC)
        let mapNav = UINavigationController(rootViewController: mapVC)
        let savedNav = UINavigationController(rootViewController: savedVC)

        viewControllers = [mainNav, mapNav, savedNav]
        tabBar.barTintColor = .black
        tabBar.tintColor = UIColor(named: "PointColor") ?? .systemBlue
    }
}
