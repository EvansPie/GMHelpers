//
//  ViewController.swift
//  GMHelpers
//
//  Created by Evangelos Pittas on 24/06/16.
//

import UIKit
import GoogleMaps

class ViewController: UIViewController, GMSMapViewDelegate {

    @IBOutlet weak var mapView: GMSMapView!
    
    private let parisLocation  = CLLocation(latitude: 48.856813, longitude:  2.352706)
    private let berlinLocation = CLLocation(latitude: 52.519409, longitude: 13.404873)
    private var routePolyline: GMSPolyline?
    private var closestCoordinatePolyline: GMSPolyline?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureMapView()

        self.mapView.animateToLocation(self.parisLocation.coordinate)
        self.mapView.animateToZoom(10.0)
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        let sessionManager = SessionManager()
        sessionManager.requestDirections(originLocation: self.parisLocation, destinationLocation: self.berlinLocation) { (overviewPath, detailedPath, error) in
            
            if error != nil {
                let alert = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .Alert)
                alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
                
            } else {
                
                if detailedPath != nil {
                    self.drawPath(detailedPath!)
                    self.testCoordinatesOnPath(detailedPath!)
                } else if overviewPath != nil {
                    self.drawPath(overviewPath!)
                    self.testCoordinatesOnPath(overviewPath!)
                }
                
            }
            
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    private func configureMapView() {
        self.mapView.delegate = self
        self.mapView.myLocationEnabled = true
    }
    
    private func drawPath(path: GMSPath) {
        self.routePolyline?.map = nil
        self.routePolyline = GMSPolyline(path: path)
        self.routePolyline?.map = self.mapView
        
        self.routePolyline?.strokeColor = UIColor.blueColor()
        self.routePolyline?.strokeWidth = 4.0
        
        let bounds: GMSCoordinateBounds? = GMSCoordinateBounds(path: path)
        var cameraUpdate: GMSCameraUpdate? = nil
        
        cameraUpdate = GMSCameraUpdate.fitBounds(bounds!, withPadding: 25.0)
        if cameraUpdate != nil {
            mapView.animateWithCameraUpdate(cameraUpdate!)
        }
    }
    
    private func testCoordinatesOnPath(path: GMSPath) {
        let franceCoordOnRoute = CLLocationCoordinate2DMake(49.729257, 2.781582)
        let germanyCoordOnRoute = CLLocationCoordinate2DMake(52.272177, 12.395273)
        let germanyCoord100mFromRoute = CLLocationCoordinate2DMake(52.271727, 12.395730)
        
        let franceOnRouteMarker = GMSMarker(position: franceCoordOnRoute)
        franceOnRouteMarker.title = "France"
        franceOnRouteMarker.snippet = "On route"
        let germanyOnRouteMarker = GMSMarker(position: germanyCoordOnRoute)
        germanyOnRouteMarker.title = "Germany"
        germanyOnRouteMarker.snippet = "On route"
        let germany100mFromRouteMarker = GMSMarker(position: germanyCoord100mFromRoute)
        germany100mFromRouteMarker.title = "Germany"
        germany100mFromRouteMarker.snippet = "100m off route"
        
        franceOnRouteMarker.map = self.mapView
        germanyOnRouteMarker.map = self.mapView
        germany100mFromRouteMarker.map = self.mapView
        
        print("\nTEST PATH: FRANCE -> GERMANY")
        print("Contains French point with tolerance   0m: \(path.containsPoint(franceCoordOnRoute, withTolerance: 0.0))")
        print("Contains French point with tolerance   1m: \(path.containsPoint(franceCoordOnRoute, withTolerance: 1.0))")
        print("Contains French point with tolerance   2m: \(path.containsPoint(franceCoordOnRoute, withTolerance: 2.0))")
        print("Contains French point with tolerance   5m: \(path.containsPoint(franceCoordOnRoute, withTolerance: 5.0))")
        print("Contains French point with tolerance  10m: \(path.containsPoint(franceCoordOnRoute, withTolerance: 10.0))")
        print("Contains French point with tolerance  25m: \(path.containsPoint(franceCoordOnRoute, withTolerance: 25.0))")
        print("Contains French point with tolerance  50m: \(path.containsPoint(franceCoordOnRoute, withTolerance: 50.0))")
        print("Contains French point with tolerance 100m: \(path.containsPoint(franceCoordOnRoute, withTolerance: 100.0))")
        print("Contains French point with tolerance 200m: \(path.containsPoint(franceCoordOnRoute, withTolerance: 200.0))")
        print("Contains French point with tolerance 500m: \(path.containsPoint(franceCoordOnRoute, withTolerance: 500.0))")
        print("Contains German point with tolerance   0m: \(path.containsPoint(germanyCoordOnRoute, withTolerance: 0.0))")
        print("Contains German point with tolerance   1m: \(path.containsPoint(germanyCoordOnRoute, withTolerance: 1.0))")
        print("Contains German point with tolerance   2m: \(path.containsPoint(germanyCoordOnRoute, withTolerance: 2.0))")
        print("Contains German point with tolerance  10m: \(path.containsPoint(germanyCoordOnRoute, withTolerance: 10.0))")
        print("Contains German point with tolerance  25m: \(path.containsPoint(germanyCoordOnRoute, withTolerance: 25.0))")
        print("Contains German point with tolerance  50m: \(path.containsPoint(germanyCoordOnRoute, withTolerance: 50.0))")
        print("Contains German point with tolerance 100m: \(path.containsPoint(germanyCoordOnRoute, withTolerance: 100.0))")
        print("Contains German point with tolerance 200m: \(path.containsPoint(germanyCoordOnRoute, withTolerance: 200.0))")
        print("Contains German point with tolerance 500m: \(path.containsPoint(germanyCoordOnRoute, withTolerance: 500.0))")
        print("\nTest point 100m out of the route")
        print("Contains German (100m out of route) point with tolerance   0m: \(path.containsPoint(germanyCoord100mFromRoute, withTolerance: 0.0))")
        print("Contains German (100m out of route) point with tolerance  50m: \(path.containsPoint(germanyCoord100mFromRoute, withTolerance: 50.0))")
        print("Contains German (100m out of route) point with tolerance 100m: \(path.containsPoint(germanyCoord100mFromRoute, withTolerance: 100.0))")
        print("Contains German (100m out of route) point with tolerance 200m: \(path.containsPoint(germanyCoord100mFromRoute, withTolerance: 200.0))")
        
        
        print("\nDEFAULT TOLERANCE: 100m")
        print("Germany relative to France coordinate: \(path.coordinate(germanyCoordOnRoute, relativeToCoordinate: franceCoordOnRoute).description())")
        print("France relative to Germany coordinate: \(path.coordinate(franceCoordOnRoute, relativeToCoordinate: germanyCoordOnRoute).description())")
        print("France relative to France coordinate: \(path.coordinate(franceCoordOnRoute, relativeToCoordinate: franceCoordOnRoute).description())")
        print("France relative to German(100m) coordinate: \(path.coordinate(franceCoordOnRoute, relativeToCoordinate: germanyCoord100mFromRoute).description())")
        print("\nCUSTOM TOLERANCE: 200m")
        print("Germany relative to France coordinate: \(path.coordinate(germanyCoordOnRoute, relativeToCoordinate: franceCoordOnRoute, withPathTolerance: 200).description())")
        print("France relative to Germany coordinate: \(path.coordinate(franceCoordOnRoute, relativeToCoordinate: germanyCoordOnRoute, withPathTolerance: 200).description())")
        print("France relative to France coordinate: \(path.coordinate(franceCoordOnRoute, relativeToCoordinate: franceCoordOnRoute, withPathTolerance: 100000).description())")
        print("France relative to German(100m) coordinate: \(path.coordinate(franceCoordOnRoute, relativeToCoordinate: germanyCoord100mFromRoute, withPathTolerance: 200).description())")
        
        
        let randomCoordinate = CLLocationCoordinate2DMake(48.271727, 5.395730)
        let closestCoordinate = path.closestPathCoordinate(toCoordinate: randomCoordinate)
        
        let closestPath = GMSMutablePath()
        closestPath.addCoordinate(randomCoordinate)
        closestPath.addCoordinate(closestCoordinate!)
        let closestPolyline = GMSPolyline(path: closestPath)
        closestPolyline.strokeColor = UIColor.redColor()
        closestPolyline.strokeWidth = 4.0
        closestPolyline.map = self.mapView
        self.closestCoordinatePolyline = closestPolyline
    }
    
    
    //  MARK: - GOOGLE MAPS DELEGATE
    
    func mapView(mapView: GMSMapView, didTapAtCoordinate coordinate: CLLocationCoordinate2D) {
        if self.closestCoordinatePolyline?.map != nil {
            self.closestCoordinatePolyline?.map = nil
        }
        
        if let closestCoordinate = self.routePolyline?.path?.closestPathCoordinate(toCoordinate: coordinate) {
            let closestPath = GMSMutablePath()
            closestPath.addCoordinate(coordinate)
            closestPath.addCoordinate(closestCoordinate)
            let closestPolyline = GMSPolyline(path: closestPath)
            closestPolyline.strokeColor = UIColor.redColor()
            closestPolyline.strokeWidth = 4.0
            closestPolyline.map = self.mapView
            self.closestCoordinatePolyline = closestPolyline
        }
        
    }
    
}



















