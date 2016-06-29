//
//  SessionManager.swift
//  GMHelpers
//
//  Created by Evangelos Pittas on 24/06/16.
//

import Foundation
import Alamofire
import GoogleMaps


class SessionManager {
    
    func requestDirections(originAddress originAddress: String, destinationAddress: String, completionHandler: ((overviewPath: GMSPath?, detailedPath: GMSPath?, error: NSError?) -> Void)) {
        let url = "https://maps.googleapis.com/maps/api/directions/json?sensor=true&units=metric&language=en&origin=\(originAddress)&destination=\(destinationAddress)"
        
        self.requestDirectionsWithUrl(url) { (overviewPath, detailedPath, error) in
            completionHandler(overviewPath: overviewPath, detailedPath: detailedPath, error: error)
        }
    }
    
    func requestDirections(originLocation originLocation: CLLocation, destinationLocation: CLLocation, completionHandler: ((overviewPath: GMSPath?, detailedPath: GMSPath?, error: NSError?) -> Void)) {
        let url = "https://maps.googleapis.com/maps/api/directions/json?sensor=true&units=metric&language=en&origin=\(originLocation.coordinate.latitude),\(originLocation.coordinate.longitude)&destination=\(destinationLocation.coordinate.latitude),\(destinationLocation.coordinate.longitude)"
        
        self.requestDirectionsWithUrl(url) { (overviewPath, detailedPath, error) in
            completionHandler(overviewPath: overviewPath, detailedPath: detailedPath, error: error)
        }
    }
    
    private func requestDirectionsWithUrl(url: String, completionHandler: ((overviewPath: GMSPath?, detailedPath: GMSPath?, error: NSError?) -> Void)) {
        
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        
        Alamofire.request(.GET, url.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!).validate().responseJSON { (response) in
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            
            switch response.result {
            case .Success(let response):
                
                if let responseJSON: [String: AnyObject] = response as? [String: AnyObject] {
                    
                    var overviewPath: GMSPath? = nil
                    var detailedPath: GMSPath? = nil
                    
                    do {
                        overviewPath = try GMHelpers.overviewPathFromGoogleDirections(responseJSON)
                        detailedPath = try GMHelpers.detailedPathFromGoogleDirections(responseJSON)
                        
                    } catch let error as NSError {
                        print("\n\(NSStringFromClass(self.dynamicType)).\(#function):\(#line)\nError: \(error)")
                        
                    }
                    
                    if overviewPath == nil && detailedPath == nil {
                        let e = NSError(domain: "LocalDomain", code: 101, userInfo: [NSLocalizedDescriptionKey: "Overview & detailed paths are null"])
                        print("\n\(NSStringFromClass(self.dynamicType)).\(#function):\(#line)\nError: \(e)")
                        completionHandler(overviewPath: nil, detailedPath: nil, error: e)
                        
                    } else {
                        completionHandler(overviewPath: overviewPath, detailedPath: detailedPath, error: nil)
                        
                    }
                    
                } else {
                    print("\n\(NSStringFromClass(self.dynamicType)).\(#function):\(#line)\nResponse is not a valid JSON.")
                    let e = NSError(domain: "LocalDomain", code: 100, userInfo: [NSLocalizedDescriptionKey: "Response is not a valid JSON"])
                    completionHandler(overviewPath: nil, detailedPath: nil, error: e)

                }
                
            case .Failure(let alamofireError):
                print("\(NSStringFromClass(self.dynamicType)).\(#function):\(#line)\nError: \(alamofireError)")
                completionHandler(overviewPath: nil, detailedPath: nil, error: alamofireError)
                
            }
            
        }
    }
}