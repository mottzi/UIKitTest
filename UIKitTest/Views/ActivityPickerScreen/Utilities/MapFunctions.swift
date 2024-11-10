import MapKit

extension MapView
{
    func centerMap(on location: CLLocation, radius: CLLocationDistance? = nil, animated: Bool = true)
    {
        ignoreMinimizeSheet = true
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
    
    func togglePitch()
    {
        controls.pitchButton.isSelected.toggle()
        
        let camera = MKMapCamera(
            lookingAtCenter: map.centerCoordinate,
            fromDistance: map.camera.centerCoordinateDistance,
            pitch: controls.pitchButton.isSelected ? 70 : 0,
            heading: map.camera.heading
        )
        
        ignoreMinimizeSheet = true
        map.setCamera(camera, animated: true)
    }
    
    func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool)
    {
        categories.sortAndReset()
        controls.updateLocationButton(isMapCentered: false)
        
        if let ignoreMinimizeSheet, ignoreMinimizeSheet == true
        {
            self.ignoreMinimizeSheet = false
        }
        else
        {
            if sheet.sheetState != .minimized { sheet.animateSheet(to: .minimized) }
        }
    }
    
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
            let allCategories = await self.categories.getSelectedCategories()
            await self.categories.loadApplePOIFromRegion(categories: allCategories)
            await self.categories.loadOSMPOIFromRegion(categories: allCategories)

            await self.sheet.cards.update()
        }
    }
    
    func mapView(_ mapView: MKMapView, didSelect annotation: MKAnnotation)
    {
        guard let annotation = annotation as? MapAnnotation else { return }
        
        guard let index = sheet.cards.annotations.firstIndex(where: { $0.identifier == annotation.identifier }) else { return }
                
        let targetOffset = CGFloat(index) * sheet.cards.collection.bounds.width
        sheet.cards.collection.setContentOffset(CGPoint(x: targetOffset, y: 0), animated: false)
        sheet.cards.lastSelectedAnnotation = annotation
        
        if let ignoreDelegate, ignoreDelegate == true
        {
            self.ignoreDelegate = false
        }
        else
        {
            if sheet.sheetState != .maximized { sheet.animateSheet(to: .maximized) }
        }
    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView)
    {        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2)
        {
            guard mapView.selectedAnnotations.count == 0 else { return }
            if self.sheet.sheetState != .hidden { self.sheet.animateSheet(to: .hidden) }
        }
    }
}

#Preview { MapView() }
