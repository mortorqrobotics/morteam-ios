//
//  MapViewController.swift
//  MorTeam
//
//  Created by arvin zadeh on 6/21/16.
//  Copyright © 2016 MorTorq. All rights reserved.
//

import UIKit
import Foundation
import GoogleMaps

class MapViewController: UIViewController, GMSMapViewDelegate, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var searchResultsTableView: UITableView!
    @IBOutlet var MapUI: GMSMapView!
    var resultsTableData = [Any]();
    let morTeamURL = "http://www.morteam.com"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchResultsTableView.isHidden = true
        
        // Do any additional setup after loading the view, typically from a nib.
        //Set camera
        
        DispatchQueue.main.async(execute: {
            let camera = GMSCameraPosition.camera(withLatitude: 34.06, longitude: -118.41, zoom: 5);
            let mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera);
            mapView.isMyLocationEnabled = true;
            
            //Get locations
            httpRequest(self.morTeamURL+"/js/teamLocations.js", type: "GET") { responseText in
                //Parse response
                let textNoVar = responseText.substring(from: responseText.characters.index(responseText.startIndex, offsetBy: 11))
                let noSemi = textNoVar.substring(to: textNoVar.characters.index(textNoVar.endIndex, offsetBy: -2))
                let teams = parseJSONMap(noSemi)
                //Place markers
                for (team, location) in teams! {
                    let lat = location["latitude"] as! Double
                    let long = location["longitude"] as! Double
                    DispatchQueue.main.async(execute: {
                        let marker = GMSMarker()
                        marker.position = CLLocationCoordinate2DMake(long, lat)//SWITCH THESE WHEN teamLocations.js IS FIXED
                        marker.title = "Team " + team
                        marker.snippet = "View Team Profile >"
                        marker.map = self.MapUI
                        self.MapUI.addSubview(mapView)
                        self.MapUI.delegate = self
                    })
                }
            }
        })
    }
    
    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker){
        let teamNumber = Int((marker.title?.substring(from: marker.title!.characters.index(marker.title!.startIndex, offsetBy: 5)))!)!
        DispatchQueue.main.async(execute: {
            let vc: TeamProfileVC! = self.storyboard!.instantiateViewController(withIdentifier: "TeamProfile") as! TeamProfileVC
            vc.teamNumber = teamNumber
            self.show(vc as UIViewController, sender: vc)
        })
    }
    
    //<Search Bar
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        MapUI.isHidden = true
        searchResultsTableView.isHidden = false
        searchBar.showsCancelButton = true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar){
        MapUI.isHidden = false
        searchResultsTableView.isHidden = true
        searchBar.showsCancelButton = false
        searchBar.text = "";
        clearDataFromTable()
        searchBar.resignFirstResponder()
    }
   
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String){
        //This is where the request will be sent to get search results
        addDataToTable([searchText]) //For testing purposes
    }
    
    func addDataToTable(_ arr: [Any]){
        self.resultsTableData += arr
        DispatchQueue.main.async(execute: {
            self.searchResultsTableView.reloadData()
        })
    }
    
    func clearDataFromTable(){
        self.resultsTableData = [Any]()
        DispatchQueue.main.async(execute: {
            self.searchResultsTableView.reloadData()
        })
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        //Consider hiding search when there are no table elements
        searchBar.resignFirstResponder()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.resultsTableData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = searchResultsTableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let row = (indexPath as NSIndexPath).row
        cell.textLabel?.text = self.resultsTableData[row] as? String //The warning on this line will go away when search is truly implemented
        return cell
    }
    //Search Bar>
    
   
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}


