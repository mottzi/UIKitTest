import Foundation

struct MapCategory
{
    let title: String
    let icon: String
    
    static let allCategories: [MapCategory] =
    [
        MapCategory(title: "Movies", icon: "movieclapper"),
        MapCategory(title: "Park", icon: "tree"),
        MapCategory(title: "Eat", icon: "fork.knife"),
        MapCategory(title: "Sport", icon: "volleyball"),
        MapCategory(title: "Museum", icon: "building.columns"),
        MapCategory(title: "Zoo", icon: "bird"),
        MapCategory(title: "Amusement", icon: "laser.burst")
    ]
}
