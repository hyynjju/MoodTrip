import UIKit

class MainTabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()

        let mainVC = MainViewController()
        mainVC.tabBarItem = UITabBarItem(title: nil, image: UIImage(systemName: "house.fill"), selectedImage: UIImage(systemName: "house.fill"))

        let savedVC = SavedViewController()
        savedVC.tabBarItem = UITabBarItem(title: nil, image: UIImage(systemName: "bookmark.fill"), selectedImage: UIImage(systemName: "bookmark.fill"))

        let mainNav = UINavigationController(rootViewController: mainVC)
        let savedNav = UINavigationController(rootViewController: savedVC)
        
        let insightVC = InsightViewController()
        insightVC.tabBarItem = UITabBarItem(title: nil, image: UIImage(systemName: "chart.bar.fill"), selectedImage: UIImage(systemName: "chart.bar.fill"))
        let insightNav = UINavigationController(rootViewController: insightVC)

        viewControllers = [mainNav, savedNav, insightNav]
        tabBar.barTintColor = .black
        tabBar.tintColor = UIColor(red: 0.45, green: 0.76, blue: 1.0, alpha: 1.0) // #73C2FF
        
        for item in tabBar.items ?? [] {
            item.titlePositionAdjustment = UIOffset(horizontal: 0, vertical: 300)
        }
    }
}
