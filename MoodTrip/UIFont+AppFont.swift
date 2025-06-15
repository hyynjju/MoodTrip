import UIKit

extension UIFont {
    /// 앱 전용 기본 폰트 설정
    static func appFont(ofSize size: CGFloat, weight: UIFont.Weight = .regular) -> UIFont {
        let name: String
        switch weight {
        case .bold:
            name = "PPMori-SemiBold"
        default:
            name = "PPMori-Regular"
        }
        return UIFont(name: name, size: size) ?? UIFont.systemFont(ofSize: size, weight: weight)
    }

    /// 해피타임 폰트 별도 접근용
    static func happyFont(ofSize size: CGFloat) -> UIFont {
        return UIFont(name: "HappyTimeThree", size: size) ?? UIFont.systemFont(ofSize: size)
    }
}
