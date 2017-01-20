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
    
    var allTeamLocations:[String:AnyObject]? = nil
    
    var allTeams = [String]()
    var showingTeams = [String]()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchResultsTableView.isHidden = true
        
        // Do any additional setup after loading the view, typically from a nib.
        //Set camera
        
        DispatchQueue.main.async(execute: {
            
            
            let camera = GMSCameraPosition.camera(withLatitude: 0, longitude: 0, zoom: 3);
            
            let mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera);
            
            //self.mapView.isMyLocationEnabled = true;
            
            //Get locations
            httpRequest(self.morTeamURL+"/teamLocations.json", type: "GET") { responseText, responseCode in
                //Parse response
                
                self.allTeamLocations = parseJSONMap(responseText)!
                //Place markers
                for (team, location) in self.allTeamLocations! {
                    
                    self.allTeams.append(team)
                    
                    let lat = location["lat"] as! Double
                    let long = location["lng"] as! Double
                    DispatchQueue.main.async(execute: {
                        let marker = GMSMarker()
                        marker.position = CLLocationCoordinate2DMake(lat, long)
                        marker.title = "Team " + team
                        //marker.snippet = "View Team Profile >"
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
        self.showingTeams = self.allTeams.filter() {$0.contains(searchText)}
        DispatchQueue.main.async(execute: {
            self.searchResultsTableView.reloadData()
        })
        
    }
    
    func addDataToTable(_ arr: [Any]){
        self.resultsTableData += arr
        DispatchQueue.main.async(execute: {
            self.searchResultsTableView.reloadData()
        })
    }
    
    func clearDataFromTable(){
        self.showingTeams = []
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
        return self.showingTeams.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = searchResultsTableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let row = (indexPath as NSIndexPath).row
        cell.textLabel?.text = "Team " + (self.showingTeams[row]) //The warning on this line will go away when search is truly implemented
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cell = searchResultsTableView.cellForRow(at: indexPath)
        
        let teamClicked = cell?.textLabel?.text?.substring(from: (cell?.textLabel?.text?.index((cell?.textLabel?.text?.startIndex)!, offsetBy: 5))!)
        
        for (team, location) in self.allTeamLocations! {
            if (team == teamClicked){
                
                (self.MapUI.viewWithTag(0) as! GMSMapView).camera = GMSCameraPosition.camera(withLatitude: location["lat"] as! Double, longitude: location["lng"] as! Double, zoom: 15);
                
                MapUI.isHidden = false
                searchResultsTableView.isHidden = true
                searchBar.showsCancelButton = false
                searchBar.text = "";
                clearDataFromTable()
                searchBar.resignFirstResponder()
            }
        }
        
        
    }
    
    //Search Bar>
    
    override func viewDidDisappear(_ animated: Bool) {
        //Use later?
    }
    
   
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        //Actually use this
        
        // Dispose of any resources that can be recreated.
    }
    
    
}


