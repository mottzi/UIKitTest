import MapKit

extension MapView
{
    func pushNorth(by yDelta: CGFloat, animated: Bool = true)
    {
        var coordinateRegion = map.region
        
        coordinateRegion.center.latitude -= coordinateRegion.span.latitudeDelta * (yDelta / map.bounds.height)
        
        self.ignoreMinimizeSheet = true
        map.setRegion(coordinateRegion, animated: true)
    }
    
    func pushSouth(by yDelta: CGFloat, animated: Bool = true)
    {
        var coordinateRegion = map.region
        
        coordinateRegion.center.latitude += coordinateRegion.span.latitudeDelta * (yDelta / map.bounds.height)
        
        self.ignoreMinimizeSheet = true
        map.setRegion(coordinateRegion, animated: true)
    }
    
    func centerMap(on location: CLLocation, radius: CLLocationDistance? = nil, animated: Bool = true)
    {
        if let radius
        {
            var region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: radius, longitudinalMeters: radius)
            
            region.center.latitude -= region.span.latitudeDelta * (SheetState.minimized.rawValue / map.bounds.height)
            
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
        
        map.setCamera(camera, animated: true)
    }
    
    func handleVisibleAnnotationsChanged()
    {
        let visibleAnnotations = map.annotations(in: map.visibleMapRect).compactMap { $0 as? MapAnnotation }
        //let titles = visibleAnnotations.compactMap { $0.title }.joined(separator: ", ")
        
        sheet.updateSheetAnnotationLabel(count: visibleAnnotations.count)
        
        if !visibleAnnotations.isEmpty
        {
            print("\(visibleAnnotations.count) visible annotations")//: \(titles)")
        }
    }
    
    func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool)
    {
        picker.sortAndReset()
        controls.updateLocationButton(isMapCentered: false)
        
        if let ignoreMinimizeSheet, ignoreMinimizeSheet == true
        {
            self.ignoreMinimizeSheet = false
        }
        else
        {
            sheet.animateSheet(to: .minimized)
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
            let allCategories = await self.picker.getSelectedCategories()
            await self.picker.loadApplePOIFromRegion(categories: allCategories)
            await self.picker.loadOSMPOIFromRegion(categories: allCategories)

            await self.handleVisibleAnnotationsChanged()
        }
    }
}

#Preview { MapView() }
