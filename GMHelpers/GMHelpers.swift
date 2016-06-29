//
//  GMHelpers.swift
//  GMHelpers
//
//  Created by Evangelos Pittas on 24/06/16.
//

import Foundation
import GoogleMaps

class GMHelpers {
    
    /**
     Static function that parses the response from Google Directions and returns overview `GMSPath`.
     
     - Parameter data: The `JSON` returned from Google Directions.
     
     - Throws: `NSError` containing info where the parse failed.
     
     - Returns: `GMSPath`
     */
    
    class func overviewPathFromGoogleDirections(data: [String: AnyObject]) throws -> GMSPath {
        guard let routes: [[String: AnyObject]] = data["routes"] as? [[String: AnyObject]] else {
            let e = NSError(domain: "GoogleDirections", code: 200, userInfo: [NSLocalizedDescriptionKey: "Missing: 'routes' key"])
            throw e
        }
        
        if routes.count <= 0 {
            let e = NSError(domain: "GoogleDirections", code: 201, userInfo: [NSLocalizedDescriptionKey: "Invalid: routes count < 0"])
            throw e
        }
        
        guard let route0: [String: AnyObject] = routes[0]  else {
            let e = NSError(domain: "GoogleDirections", code: 200, userInfo: [NSLocalizedDescriptionKey: "Missing: 'routes' array's first object"])
            throw e
        }
        
        guard let overviewPolylineEncodedPoints: String = (route0["overview_polyline"] as? [String: AnyObject])?["points"] as? String else {
            let e = NSError(domain: "GoogleDirections", code: 200, userInfo: [NSLocalizedDescriptionKey: "Missing: 'overview_polyline' key"])
            throw e
        }
        
        if let overviewPath: GMSPath = GMSPath(fromEncodedPath: overviewPolylineEncodedPoints) {
            return overviewPath
        } else {
            let e = NSError(domain: "GoogleDirections", code: 202, userInfo: [NSLocalizedDescriptionKey: "Could not create GMSPath"])
            throw e
        }
    }
    
    
    /**
     Static function that parses the response from Google Directions, and returns a detailed `GMSPath` connecting the waypoints from each step.
     
     - Parameter data: The `JSON` returned from Google Directions.
     
     - Throws: `NSError` containing info where the parse failed.
     
     - Returns: `GMSPath`
     */
    
    class func detailedPathFromGoogleDirections(data: [String: AnyObject]) throws -> GMSPath {
        guard let routes: [[String: AnyObject]] = data["routes"] as? [[String: AnyObject]] else {
            let e = NSError(domain: "GoogleDirections", code: 200, userInfo: [NSLocalizedDescriptionKey: "Missing: 'routes' key"])
            throw e
        }
        
        if routes.count <= 0 {
            let e = NSError(domain: "GoogleDirections", code: 201, userInfo: [NSLocalizedDescriptionKey: "Invalid: routes count < 0"])
            throw e
        }
        
        guard let route0: [String: AnyObject] = routes[0]  else {
            let e = NSError(domain: "GoogleDirections", code: 200, userInfo: [NSLocalizedDescriptionKey: "Missing: 'routes' array's first object"])
            throw e
        }
        
        guard let leg0: [String: AnyObject] = (route0["legs"] as? [[String: AnyObject]])?[0]  else {
            let e = NSError(domain: "GoogleDirections", code: 200, userInfo: [NSLocalizedDescriptionKey: "Missing: 'legs' array's first object"])
            throw e
        }
        
        guard let steps: [[String: AnyObject]] = leg0["steps"] as? [[String: AnyObject]]  else {
            let e = NSError(domain: "GoogleDirections", code: 200, userInfo: [NSLocalizedDescriptionKey: "Missing: 'steps' key"])
            throw e
        }
        
        let mutablePath = GMSMutablePath()
        
        for step in steps {
            //  For each step dictionary get the 'start_location', 'polyline''s 'points' & 'end_location' and add their coordinates in 'mutablePath'
            
            if let startLocation: [String: AnyObject] = step["start_location"] as? [String: AnyObject] {
                if let lat: Double = (startLocation["lat"] as? String)?.toDouble(), let lng: Double = (startLocation["lng"] as? String)?.toDouble() {
                    let startCoordinate = CLLocationCoordinate2D(latitude: lat, longitude: lng)
                    mutablePath.addCoordinate(startCoordinate)
                }
            }
            
            if let stepEncodedPath: String = (step["polyline"] as? [String: AnyObject])?["points"] as? String {
                
                if let stepPath: GMSPath = GMSPath(fromEncodedPath: stepEncodedPath) {
                    let stepPathCoordinates = stepPath.pathCoordinates()
                    
                    for stepPathCoodinate in stepPathCoordinates {
                        mutablePath.addCoordinate(stepPathCoodinate)
                    }
                }
            }
            
            if let endLocation: [String: AnyObject] = step["end_location"] as? [String: AnyObject] {
                if let lat: Double = (endLocation["lat"] as? String)?.toDouble(), let lng: Double = (endLocation["lng"] as? String)?.toDouble() {
                    let endCoordinate = CLLocationCoordinate2D(latitude: lat, longitude: lng)
                    mutablePath.addCoordinate(endCoordinate)
                }
            }
            
        }
        
        if mutablePath.count() > 0 {
            return mutablePath
        } else {
            let e = NSError(domain: "GoogleDirections", code: 256, userInfo: [NSLocalizedDescriptionKey: "GMSPath doesn't contain any coordinates"])
            throw e
        }
    }
    
}
















