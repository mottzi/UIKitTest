import MapKit

struct MapCategory: Equatable
{
    let title: String
    let icon: String
    let color: UIColor
    
    var appleCategories: [MKPointOfInterestCategory]? = nil
    
    static let allCategories: [MapCategory] =
    [
        MapCategory(title: "Movies", icon: "movieclapper", color: .systemPink, appleCategories: [.movieTheater]),
        MapCategory(title: "Park", icon: "tree", color: .systemGreen, appleCategories: [.park, .nationalPark]),
        MapCategory(title: "Eat", icon: "fork.knife", color: .systemOrange, appleCategories: [.cafe, .restaurant, .bakery]),
        MapCategory(title: "Sport", icon: "volleyball", color: .systemBlue, appleCategories: [.fitnessCenter, .stadium]),
        MapCategory(title: "Museum", icon: "building.columns", color: .systemPurple, appleCategories: [.museum]),
        MapCategory(title: "Zoo", icon: "bird", color: .systemBrown, appleCategories: [.zoo]),
        MapCategory(title: "Amusement", icon: "laser.burst", color: .systemCyan, appleCategories: [.amusementPark]),
    ]
}
