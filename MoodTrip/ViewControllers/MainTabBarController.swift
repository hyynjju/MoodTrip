import UIKit

class MainTabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()

        let mainVC = MainViewController()
        mainVC.tabBarItem = UITabBarItem(title: "Home", image: UIImage(systemName: "house"), tag: 0)

        let savedVC = SavedViewController()
        savedVC.tabBarItem = UITabBarItem(title: "Saved", image: UIImage(systemName: "bookmark"), tag: 2)

        let mainNav = UINavigationController(rootViewController: mainVC)
        let savedNav = UINavigationController(rootViewController: savedVC)
        
        let insightVC = InsightViewController()
        insightVC.tabBarItem = UITabBarItem(title: "Insights", image: UIImage(systemName: "chart.bar"), tag: 3)
        let insightNav = UINavigationController(rootViewController: insightVC)

        viewControllers = [mainNav, savedNav, insightNav]
        tabBar.barTintColor = .black
        tabBar.tintColor = UIColor(named: "PointColor") ?? .systemBlue
    }
}
