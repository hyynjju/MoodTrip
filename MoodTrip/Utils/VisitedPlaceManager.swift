import Foundation

class VisitedPlaceManager {
    private static let visitedKey = "visitedPlaceIDs"
    
    static func getVisitedPlaceIDs() -> [Int] {
        return UserDefaults.standard.array(forKey: visitedKey) as? [Int] ?? []
    }
    
    static func isVisited(placeID: Int) -> Bool {
        return getVisitedPlaceIDs().contains(placeID)
    }
    
    static func addVisited(placeID: Int) {
        var visited = getVisitedPlaceIDs()
        if !visited.contains(placeID) {
            visited.append(placeID)
            UserDefaults.standard.set(visited, forKey: visitedKey)
            print("✅ Visited: \(placeID)")
        }
    }
    
    static func removeVisited(placeID: Int) {
        var visited = getVisitedPlaceIDs()
        if let index = visited.firstIndex(of: placeID) {
            visited.remove(at: index)
            UserDefaults.standard.set(visited, forKey: visitedKey)
            print("❌ Unvisited: \(placeID)")
        }
    }
}
