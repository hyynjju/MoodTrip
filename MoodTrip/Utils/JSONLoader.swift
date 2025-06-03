import Foundation

/// JSON 파일을 불러오는 유틸리티
class JSONLoader {
    /// 파일명을 통해 [Place] 배열을 반환
    static func loadPlaces(from fileName: String) -> [Place] {
        guard let url = Bundle.main.url(forResource: fileName, withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let places = try? JSONDecoder().decode([Place].self, from: data) else {
            print("❌ JSON 로딩 실패: \(fileName).json")
            return []
        }
        return places
    }
}
