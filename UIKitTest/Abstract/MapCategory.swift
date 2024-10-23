import Foundation

struct MapCategory
{
    let title: String
    let icon: String
    
    static let allCategories: [MapCategory] =
    [
        MapCategory(title: "Movies", icon: "film"),
        MapCategory(title: "Park", icon: "leaf"),
        MapCategory(title: "Eat", icon: "fork.knife"),
        MapCategory(title: "Sport", icon: "sportscourt"),
        MapCategory(title: "Museum", icon: "building.columns"),
        MapCategory(title: "Zoo", icon: "tortoise"),
        MapCategory(title: "Amusement", icon: "sparkles")
    ]
}
