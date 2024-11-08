import MapKit

struct MapCategory: Equatable
{
    let title: String
    let icon: String
    var fillable: Bool = true
    let color: UIColor
    
    var appleCategories: [MKPointOfInterestCategory]? = nil
    var osmCategories: [OSMPointOfInterestCategory]? = nil
    
    var filledIcon: String { !fillable ? icon : "\(icon).fill"}

    static let allCategories: [MapCategory] =
    [
        MapCategory(title: "Movies", icon: "movieclapper", color: .systemPink,
                    appleCategories: [.movieTheater],
                    osmCategories: [OSMPointOfInterestCategory("amenity", "cinema")]),
        
        MapCategory(title: "Park", icon: "tree", color: .systemGreen,
                    appleCategories: [.park, .nationalPark],
                    osmCategories: [OSMPointOfInterestCategory("leisure", "park")]),
        
        MapCategory(title: "Eat", icon: "fork.knife", fillable: false, color: .systemOrange,
                    appleCategories: [.cafe, .restaurant, .bakery],
                    osmCategories: [
                        OSMPointOfInterestCategory("amenity", "restaurant"),
                        OSMPointOfInterestCategory("amenity", "fast_food"),
                        OSMPointOfInterestCategory("amenity", "cafe"),
                        OSMPointOfInterestCategory("shop", "bakery"),
                        OSMPointOfInterestCategory("shop", "pastry")]),
        
        MapCategory(title: "Sport", icon: "volleyball.fill", color: .systemBlue,
                    appleCategories: [.fitnessCenter, .stadium],
                    osmCategories: [
                        OSMPointOfInterestCategory("sport"),
                        OSMPointOfInterestCategory("leisure", "pitch")]),
        
        MapCategory(title: "Museum", icon: "building.columns", color: .systemPurple,
                    appleCategories: [.museum],
                    osmCategories: [
                        OSMPointOfInterestCategory("tourism", "museum"),
                        OSMPointOfInterestCategory("museum")]),
        
        MapCategory(title: "Zoo", icon: "bird", color: .systemBrown,
                    appleCategories: [.zoo],
                    osmCategories: [
                        OSMPointOfInterestCategory("tourism", "zoo"),
                        OSMPointOfInterestCategory("zoo")]),
        
        MapCategory(title: "Amusement", icon: "laser.burst", fillable: false, color: .systemCyan,
                    appleCategories: [.amusementPark],
                    osmCategories: [
                        OSMPointOfInterestCategory("attraction", "amusement_ride"),
                        OSMPointOfInterestCategory("leisure", "amusement_arcade"),
                        OSMPointOfInterestCategory("leisure", "water_park"),
                        OSMPointOfInterestCategory("tourism", "theme_park")])
    ]
}
