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
        
        searchResultsTableView.hidden = true
        
        // Do any additional setup after loading the view, typically from a nib.
        //Set camera
        
        dispatch_async(dispatch_get_main_queue(), {
            let camera = GMSCameraPosition.cameraWithLatitude(34.06, longitude: -118.41, zoom: 5);
            let mapView = GMSMapView.mapWithFrame(CGRectZero, camera: camera);
            mapView.myLocationEnabled = true;
            
            //Get locations
            httpRequest(self.morTeamURL+"/js/teamLocations.js", type: "GET") { responseText in
                //Parse response
                let textNoVar = responseText.substringFromIndex(responseText.startIndex.advancedBy(11))
                let noSemi = textNoVar.substringToIndex(textNoVar.endIndex.advancedBy(-2))
                let teams = parseJSON(noSemi)
                //Place markers
                for (team, location) in teams! {
                    let lat = location["latitude"] as! Double
                    let long = location["longitude"] as! Double
                    dispatch_async(dispatch_get_main_queue(), {
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
    
    func mapView(mapView: GMSMapView, didTapInfoWindowOfMarker marker: GMSMarker){
        let teamNumber = Int((marker.title?.substringFromIndex(marker.title!.startIndex.advancedBy(5)))!)!
        dispatch_async(dispatch_get_main_queue(),{
            let vc: TeamProfileVC! = self.storyboard!.instantiateViewControllerWithIdentifier("TeamProfile") as! TeamProfileVC
            vc.teamNumber = teamNumber
            self.showViewController(vc as UIViewController, sender: vc)
        })
    }
    
    //<Search Bar
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        MapUI.hidden = true
        searchResultsTableView.hidden = false
        searchBar.showsCancelButton = true
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar){
        MapUI.hidden = false
        searchResultsTableView.hidden = true
        searchBar.showsCancelButton = false
        searchBar.text = "";
        clearDataFromTable()
        searchBar.resignFirstResponder()
    }
   
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String){
        //This is where the request will be sent to get search results
        addDataToTable([searchText]) //For testing purposes
    }
    
    func addDataToTable(arr: [Any]){
        self.resultsTableData += arr
        dispatch_async(dispatch_get_main_queue(),{
            self.searchResultsTableView.reloadData()
        })
    }
    
    func clearDataFromTable(){
        self.resultsTableData = [Any]()
        dispatch_async(dispatch_get_main_queue(),{
            self.searchResultsTableView.reloadData()
        })
    }
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        //Consider hiding search when there are no table elements
        searchBar.resignFirstResponder()
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.resultsTableData.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = searchResultsTableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        let row = indexPath.row
        cell.textLabel?.text = self.resultsTableData[row] as! String //The warning on this line will go away when search is truly implemented
        return cell
    }
    //Search Bar>
    
   
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}


