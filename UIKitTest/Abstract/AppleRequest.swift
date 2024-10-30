import MapKit

/// A type that represents an Apple Maps map item that has been fetched using a category filter.
struct MKFilteredMapItem: Identifiable
{
    let id = UUID()
    let mapItem: MKMapItem
    let category: MapCategory
}

/// Make local rearch requests to Apple Maps to fetch POI using category and coordinate region filters.
class AppleRequest
{
    var filter: MapCategory
    var region: MKCoordinateRegion
    
    init(with filter: MapCategory, region: MKCoordinateRegion)
    {
        self.filter = filter
        self.region = region
    }
    
    /// Runs the request.
    /// - Returns: Array of ``MKFilteredMapItem`` that contains the POIs that matched at least one of the category filters and the coordinate region filter. If an error occured or no POIs were found, `nil` is returned.
    func start() async -> [MKFilteredMapItem]?
    {
        guard let category = filter.appleCategories else { return nil }
        
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = filter.title
        request.resultTypes = .pointOfInterest
        request.pointOfInterestFilter = MKPointOfInterestFilter(including: category)
        request.region = region
        
        guard let response = try? await MKLocalSearch(request: request).start() else { return nil }
        
        let result = response.mapItems.filter({ region.contains($0.placemark.coordinate) })
        
        let taggedResult = result.map { MKFilteredMapItem(mapItem: $0, category: filter) }
        
        guard !taggedResult.isEmpty else { return nil }
        
        return taggedResult
    }
}

extension MKCoordinateRegion
{
    func contains(_ coordinate: CLLocationCoordinate2D) -> Bool
    {
        let latDelta = self.span.latitudeDelta / 2.0
        let lonDelta = self.span.longitudeDelta / 2.0
        
        let minLat = self.center.latitude - latDelta
        let maxLat = self.center.latitude + latDelta
        let minLon = self.center.longitude - lonDelta
        let maxLon = self.center.longitude + lonDelta
        
        return (minLat...maxLat).contains(coordinate.latitude) && (minLon...maxLon).contains(coordinate.longitude)
    }
}
