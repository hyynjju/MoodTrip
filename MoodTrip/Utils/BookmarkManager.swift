// BookmarkManager.swift
import Foundation

class BookmarkManager {
    private static let bookmarkKey = "bookmarkedPlaceIDs"
    
    // 현재 즐겨찾기 된 장소 ID 목록을 가져옵니다.
    static func getBookmarkedPlaceIDs() -> [Int] { // ⭐️ 반환 타입을 [Int]로 변경
        // UserDefaults.standard.array(forKey:)는 Any 배열을 반환하므로 [Int]로 캐스팅해야 합니다.
        return UserDefaults.standard.array(forKey: bookmarkKey) as? [Int] ?? []
    }
    
    // 특정 장소 ID가 즐겨찾기 되어 있는지 확인합니다.
    static func isBookmarked(placeID: Int) -> Bool { // ⭐️ placeID 타입을 Int로 변경
        return getBookmarkedPlaceIDs().contains(placeID)
    }
    
    // 특정 장소를 즐겨찾기에 추가합니다.
    static func addBookmark(placeID: Int) { // ⭐️ placeID 타입을 Int로 변경
        var bookmarkedIDs = getBookmarkedPlaceIDs()
        if !bookmarkedIDs.contains(placeID) {
            bookmarkedIDs.append(placeID)
            UserDefaults.standard.set(bookmarkedIDs, forKey: bookmarkKey)
            print("✅ Added bookmark: \(placeID)")
        }
    }
    
    // 특정 장소를 즐겨찾기에서 제거합니다.
    static func removeBookmark(placeID: Int) { // ⭐️ placeID 타입을 Int로 변경
        var bookmarkedIDs = getBookmarkedPlaceIDs()
        if let index = bookmarkedIDs.firstIndex(of: placeID) {
            bookmarkedIDs.remove(at: index)
            UserDefaults.standard.set(bookmarkedIDs, forKey: bookmarkKey)
            print("❌ Removed bookmark: \(placeID)")
        }
    }
    
    // UserDefaults에 저장된 모든 장소 데이터를 가져옵니다.
    static func getBookmarkedPlaces() -> [Place] {
        let bookmarkedIDs = getBookmarkedPlaceIDs()
        let allPlaces = JSONLoader.loadPlaces(from: "places") // 모든 장소 로드 (JSONLoader가 Place를 반환한다고 가정)
        
        return allPlaces.filter { bookmarkedIDs.contains($0.id) }
    }
}
