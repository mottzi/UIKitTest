import MapKit

struct MapCategory
{
    let title: String
    let icon: String
    
    var appleCategories: [MKPointOfInterestCategory]? = nil
    
    static let allCategories: [MapCategory] =
    [
        MapCategory(title: "Movies", icon: "movieclapper", appleCategories: [.movieTheater]),
        MapCategory(title: "Park", icon: "tree", appleCategories: [.park, .nationalPark]),
        MapCategory(title: "Eat", icon: "fork.knife", appleCategories: [.cafe, .restaurant, .bakery]),
        MapCategory(title: "Sport", icon: "volleyball", appleCategories: [.fitnessCenter, .stadium]),
        MapCategory(title: "Museum", icon: "building.columns", appleCategories: [.museum]),
        MapCategory(title: "Zoo", icon: "bird", appleCategories: [.zoo]),
        MapCategory(title: "Amusement", icon: "laser.burst", appleCategories: [.amusementPark]),
    ]
}
