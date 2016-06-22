//
//  MapViewController.swift
//  MorMap
//
//  Created by arvin zadeh on 6/21/16.
//  Copyright © 2016 MorTorq. All rights reserved.
//

import UIKit
import Foundation
import GoogleMaps

class MapViewController: UIViewController, GMSMapViewDelegate {
    
    @IBOutlet var MapUI: GMSMapView!
    let morTeamURL = "http://www.morteam.com"
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        //Set camera
        let camera = GMSCameraPosition.cameraWithLatitude(34.06, longitude: -118.41, zoom: 5);
        let mapView = GMSMapView.mapWithFrame(CGRectZero, camera: camera);
        mapView.myLocationEnabled = true;
        
        //Get locations
        httpRequest(morTeamURL+"/js/teamLocations.js", type: "GET") { responseText in
            //Parse response
            let textNoVar = responseText.substringFromIndex(responseText.startIndex.advancedBy(11))
            let noSemi = textNoVar.substringToIndex(textNoVar.endIndex.advancedBy(-2))
            let teams = parseJSON(noSemi)
            //Place markers
            for (team, location) in teams! {
                let lat = location["latitude"] as! Double
                let long = location["longitude"] as! Double
                let marker = GMSMarker()
                marker.position = CLLocationCoordinate2DMake(long, lat)//SWITCH THESE WHEN teamLocations.js IS FIXED
                marker.title = "Team " + team
                marker.snippet = "View Team Profile >"
                marker.map = self.MapUI
                dispatch_async(dispatch_get_main_queue(),{
                   self.MapUI.addSubview(mapView)
                   self.MapUI.delegate = self
                })
            }
        }
    }
    
    func mapView(mapView: GMSMapView, didTapInfoWindowOfMarker marker: GMSMarker){
        print();
        let teamNumber = Int((marker.title?.substringFromIndex(marker.title!.startIndex.advancedBy(5)))!)!
        print(teamNumber)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}


