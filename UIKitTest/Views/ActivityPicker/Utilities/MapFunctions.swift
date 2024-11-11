import MapKit

extension ActivityPicker
{
    // centers map on the given location
    func centerMap(on location: CLLocation, radius: CLLocationDistance? = nil, animated: Bool = true)
    {
        if let radius
        {
            let region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: radius, longitudinalMeters: radius)
            
            map.setRegion(region, animated: animated)
        }
        else
        {
            map.setCenter(location.coordinate, animated: animated)
        }
        
        controls.updateLocationButton(isMapCentered: true)
    }
    
    // toggles between 2D and 3D map modes
    func togglePitch()
    {
        controls.pitchButton.isSelected.toggle()
        
        let camera = MKMapCamera(
            lookingAtCenter: map.centerCoordinate,
            fromDistance: map.camera.centerCoordinateDistance,
            pitch: controls.pitchButton.isSelected ? 70 : 0,
            heading: map.camera.heading
        )
        
        map.setCamera(camera, animated: true)
    }
}

extension ActivityPicker
{
    // map camera began to move:
    // reset category picker and location button, minimize sheet, deselect annotations
    func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool)
    {
        categoryPicker.reset()
        controls.updateLocationButton(isMapCentered: false)
        
        if sheet.sheetState == .maximized { sheet.animateSheet(to: .minimized) }
        
        map.selectedAnnotations.forEach()
        {
            map.deselectAnnotation($0, animated: true)
        }
    }
    
    // map camara stopped moving:
    // update pitch button, request fresh POI and refresh result picker in bottom sheet
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool)
    {
        let currentPitch = mapView.camera.pitch
        
        if let lastPitch, lastPitch != currentPitch
        {
            controls.updatePitchButton(isPitchActive: currentPitch > 0)
        }
        
        lastPitch = currentPitch
        
        Task.detached()
        {
            let allCategories = await self.categoryPicker.getSelectedCategories()
            
            await self.requestAnnotations(categories: allCategories, from: .apple)
            await self.requestAnnotations(categories: allCategories, from: .osm)

            await self.sheet.resultPicker.refresh()
        }
    }
}

#Preview { ActivityPicker() }
