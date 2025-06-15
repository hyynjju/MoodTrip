import Foundation
import CoreLocation

/// 관광지 정보를 담는 모델
struct Place: Codable {
    let id: Int
    let name: String
    let description: String
    let imageURL: String
    let latitude: Double
    let longitude: Double
    let scores: [String: Int]
    let tags: [String]
    let recommendedDuration: String
    let bestWith: String
    let address: String
    let detailedDescription: String

    /// CLLocationCoordinate2D로 변환된 위치 정보
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}
