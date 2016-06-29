//
//  Created by Evangelos Pittas on 21/06/16.
//


import Foundation
import UIKit
import GoogleMaps


/**
 Relation of two coordinates on the same path.
 
 - Before: The first coordinate is before the second coordinate on the path.
 - Equal: The first and the second coordinate are .
 - After: The first coordinate is after the second coordinate on the path.
 - NotAvailable: One or both coordinates are outside the tolerance of the path.
 */

public enum PathCoordinateRelation {
    case Before, Equal, After, NotAvailable
    
    func description() -> String {
        switch self {
        case .Before:
            return "Before"
            
        case .Equal:
            return "Equal"
            
        case .After:
            return "After"
            
        case .NotAvailable:
            return "NotAvailable"
            
        }
    }
}


extension GMSPath {
    
    /**
     GMSPath extension that decodes the Google Directions encoded string to an array of location objects. Encoding instructions are provided [here](https://developers.google.com/maps/documentation/utilities/polylinealgorithm).

     This Swift approach was based on this [blog](icodeapps.blogspot.gr/2011/04/google-map-directions-api-objective-c.html).
     
     - Returns: Array of CLLocation objects
     */
    
    func decodeEncodedPath() -> [CLLocation] {
        
        var locations: [CLLocation] = []
        
        var index: Int = 0
        var lat: Int = 0x00
        var lng: Int = 0x00
        
        while index < self.encodedPath().length {
            
            var b: Int = 0x00
            var result: Int = 0x00
            var shift: Int = 0
            
            repeat {
                b = Int((self.encodedPath() as NSString).characterAtIndex(index)) - 63
                index += 1
                result |= (b & 0x1f) << shift
                shift += 5
                
            } while b >= 0x20
            
            let dlat: Int = (result & 1 > 0) ? ~(result >> 1) : (result >> 1)
            lat += dlat
            
            shift = 0
            result = 0
            
            repeat {
                b = Int((self.encodedPath() as NSString).characterAtIndex(index)) - 63
                index += 1
                result |= (b & 0x1f) << shift
                shift += 5
                
            } while b >= 0x20
            
            let dlng: Int = (result & 1 > 0) ? ~(result >> 1) : (result >> 1)
            lng += dlng
            
            let latitude  = Double(lat) * 1e-5
            let longitude = Double(lng) * 1e-5
            
            let tmpLocation = CLLocation(latitude: latitude, longitude: longitude)
            locations.append(tmpLocation)
        }
        
        return locations
        
    }
    
    
    /**
     GMSPath extension that extracts the coordinates from the path.
     
     - Returns: Array of CLLocationCoordinate2D objects
     */
    
    func pathCoordinates() -> [CLLocationCoordinate2D] {
        var coordinates: [CLLocationCoordinate2D] = []

        for coordinateIndex in 0 ..< Int(self.count()) {
            coordinates.append(self.coordinateAtIndex(UInt(coordinateIndex)))
        }
        
        return coordinates
    }
    
    
    /**
     GMSPath extension that returns the locations of the waypoints of the path.
     
     - Returns: Array of CLLocation objects
     */
    
    func pathLocations() -> [CLLocation] {
        var locations: [CLLocation] = []
        
        for coordinate in self.pathCoordinates() {
            locations.append(CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude))
        }
        
        return locations
    }
    
    
    /**
     GMSPath extension that checks if the given CLLocationCoordinate2D is on the path.
     
     - Parameter point: The CLLocationCoordinate2D that we want to check if it is on the path.
     
     - Parameter tolerance: How far from the path (in meters) should the *function* check. Its default value is 100m.
     
     - Returns: `true` if the given `point` is on the `path` with the given `tolerance`, `false` otherwise.
     */
    
    func containsPoint(point: CLLocationCoordinate2D, withTolerance tolerance: CLLocationDistance = 100.0) -> Bool {
        //  The function is already provided by the Google Maps SDK. It is rewritten as a GMSPath extension.
        
        if tolerance < 0 {
            return false
        }
        
        return GMSGeometryIsLocationOnPathTolerance(point, self, true, tolerance)
    }
    
    
    /**
     GMSPath extension that checks the relation of two points on a path, i.e. which one is first.
     
     *Note*: If two coordinates' closest coordinate on the path is the same, it returns `Before` for the one closest to this coordinate without taking into account the course of the path.
     
     - Parameter pointA: The first coordinate that we want to compare.
     - Parameter pointB: The second coordinate that we want to compare.
     - Parameter tolerance: How far from the path (in meters) should the *function* check. Its default value is 100m.
     
     - Returns: `PathCoordinateRelation`. `NotAvailable` if any of the two coordinates is outside the tolerance if the path, `Before` if the first coordinate is before the second on the path, `After` if the first coordinate is after the second on the path, `Equal` if the first coordinate and the second coordinate are on the same distance of the same coordinate.
     */
    
    func coordinate(pointA: CLLocationCoordinate2D, relativeToCoordinate pointB: CLLocationCoordinate2D, withPathTolerance tolerance: CLLocationDistance = 100) -> PathCoordinateRelation {
        let pathCoordinates: [CLLocationCoordinate2D] = self.pathCoordinates()
        
        var minDistanceA: CLLocationDistance = 100000000000000000
        var minDistanceIndexA: Int = -1
        
        for (index, coordinate) in pathCoordinates.enumerate() {
            let distance = GMSGeometryDistance(coordinate, pointA)
            
            if distance < minDistanceA {
                minDistanceA = distance
                minDistanceIndexA = index
            }
            
        }
        
        var minDistanceB: CLLocationDistance = 100000000000000000
        var minDistanceIndexB: Int = -1
        
        for (index, coordinate) in pathCoordinates.enumerate() {
            let distance = GMSGeometryDistance(coordinate, pointB)
            
            if distance < minDistanceB {
                minDistanceB = distance
                minDistanceIndexB = index
            }
            
        }
        
        if minDistanceA > tolerance || minDistanceB > tolerance {
            return PathCoordinateRelation.NotAvailable
            
        } else if minDistanceIndexA < minDistanceIndexB {
            return PathCoordinateRelation.Before
            
        } else if minDistanceIndexA == minDistanceIndexB {
            return PathCoordinateRelation.Equal
            
        } else {
            return PathCoordinateRelation.After
            
        }
    }
    
    
    /**
     GMSPath extension that finds the closest path point to a given coordinate.

     - Parameter coordinate: The coordinate that we want to find the path's closest point to it.
     
     - Returns: `CLLocationCoordinate2D` if a coordinate is found, nil otherwise.
     */
    
    func closestPathCoordinate(toCoordinate coordinate: CLLocationCoordinate2D) -> CLLocationCoordinate2D? {
        let pathCoordinates: [CLLocationCoordinate2D] = self.pathCoordinates()
        
        var minDistance: CLLocationDistance = 100000000000000000
        var minDistanceCoordinate: CLLocationCoordinate2D?
        
        for pathCoordinate in pathCoordinates {
            let distance = GMSGeometryDistance(pathCoordinate, coordinate)
            
            if distance < minDistance {
                minDistance = distance
                minDistanceCoordinate = pathCoordinate
            }
            
        }
        
        return minDistanceCoordinate
    }
}

















