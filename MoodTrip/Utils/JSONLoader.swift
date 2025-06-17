import Foundation

/// JSON 파일을 불러오는 유틸리티
class JSONLoader {
    /// 파일명을 통해 [Place] 배열을 반환
    static func loadPlaces(from fileName: String) -> [Place] {
        guard let url = Bundle.main.url(forResource: fileName, withExtension: "json") else {
            print("❌ 파일을 찾을 수 없습니다: \(fileName).json")
            return []
        }
        
        do {
            let data = try Data(contentsOf: url)
            let places = try JSONDecoder().decode([Place].self, from: data)
            return places
        } catch {
            print("❌ JSON 파싱 중 오류 발생: \(error.localizedDescription)")
            return []
        }
    }
}
