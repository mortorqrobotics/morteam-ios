//
//  ViewController.swift
//  MorMap
//
//  Created by arvin zadeh on 6/21/16.
//  Copyright © 2016 MorTorq. All rights reserved.
//

import UIKit
import GoogleMaps

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let camera = GMSCameraPosition.cameraWithLatitude(34.06, longitude: -118.41, zoom: 5);
        let mapView = GMSMapView.mapWithFrame(CGRectZero, camera: camera);
        mapView.myLocationEnabled = true;
        self.view = mapView;
        
        let marker = GMSMarker();
        marker.position = CLLocationCoordinate2DMake(34.06, -118.41);
        marker.title = "Team 1515";
        marker.snippet = "MorTorq";
        marker.map = mapView;
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

