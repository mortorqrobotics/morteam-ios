//
//  CalendarVC.swift
//  MorTeam
//
//  Created by arvin zadeh on 10/7/16.
//  Copyright © 2016 MorTorq. All rights reserved.
//

import Foundation
import UIKit
import CVCalendar

class CalendarVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    struct Color {
        static let selectedText = UIColor.black
        static let text = UIColor.black
        static let textDisabled = UIColor.gray
        static let selectionBackground = UIColorFromHex("#FFC547")
        static let sundayText = UIColor(red: 1.0, green: 0.2, blue: 0.2, alpha: 1.0)
        static let sundayTextDisabled = UIColor.gray
        static let sundaySelectionBackground = UIColorFromHex("#FFC547")
    }
    
    @IBOutlet weak var calendarView: CVCalendarView!
    @IBOutlet weak var menuView: CVCalendarMenuView!
    @IBOutlet weak var monthLabel: UILabel!
    
    @IBOutlet var eventTableView: UITableView!
    var shouldShowDaysOut = true
    var animationFinished = true
    
    var selectedDay:DayView!
    
    var showingEvents = [Event]()
    
    let morTeamUrl = "http://www.morteam.com:8080/api"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setup()
        monthLabel.text = CVDate(date: Date()).globalDescription
        self.loadEvents(month: CVDate(date: Date()).month, year: CVDate(date: Date()).year)
    }
    
    func setup(){
        self.view.backgroundColor = UIColor.white
        
        self.eventTableView.backgroundColor = UIColor.white
        self.eventTableView.separatorInset = .zero
    }
    
    
    func loadEvents(month: Int, year: Int){
        DispatchQueue.main.async(execute: {
            //For early empty and refresh
            self.showingEvents = []
            self.eventTableView.reloadData()
            if let cc = self.calendarView.contentController as? CVCalendarMonthContentViewController {
                cc.refreshPresentedMonth()
            }
        })
        httpRequest(self.morTeamUrl+"/events/startYear/\(year)/startMonth/\(month-1)/endYear/\(year)/endMonth/\(month-1)", type: "GET"){
            responseText in
            
            let events = parseJSON(responseText)
            self.showingEvents = []
            
            for(_, json):(String, JSON) in events {
                self.showingEvents.append(Event(eventJSON: json))
            }
            DispatchQueue.main.async(execute: {
                self.eventTableView.reloadData()
                if let cc = self.calendarView.contentController as? CVCalendarMonthContentViewController {
                    cc.refreshPresentedMonth()
                }
            })
            
        }
    }

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.showingEvents.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = eventTableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CalendarTableViewCell
        
        let row = (indexPath as NSIndexPath).row
        let event = self.showingEvents[row]
        
        cell.dayView.text = "\(event.day)" //Thanks, type safety
        cell.eventTitleLabel.text = event.name
        cell.eventDescriptionLabel.text = event.description
        
       
        
        return cell
    }
    

    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        calendarView.commitCalendarViewUpdate()
        menuView.commitMenuViewUpdate()
    }
}


extension CalendarVC: CVCalendarViewDelegate, CVCalendarMenuViewDelegate {
    
    func presentationMode() -> CalendarMode {
        return .monthView
    }
    
    func firstWeekday() -> Weekday {
        return .sunday
    }
    
    
    func dayOfWeekTextColor(by weekday: Weekday) -> UIColor {
        return UIColor.black
    }
    
    func shouldShowWeekdaysOut() -> Bool {
        return shouldShowDaysOut
    }
    
    func shouldAnimateResizing() -> Bool {
        return true
    }

    func didSelectDayView(_ dayView: CVCalendarDayView, animationDidFinish: Bool) {
        print("\(dayView.date.commonDescription) is selected!")
        selectedDay = dayView
        
        
        let day = dayView.date.day
        let month = dayView.date.month
        let year = dayView.date.year
        
        
        for (index, event) in self.showingEvents.enumerated() {
            if (event.day == day && event.year == year && event.month == month){
                let indexPath = IndexPath(row: index, section: 0)
                self.eventTableView.scrollToRow(at: indexPath, at: .top, animated: true)
                
            }
        }
        
        
        
        
        
    }
    
    func presentedDateUpdated(_ date: CVDate) {
        
        if monthLabel.text != date.globalDescription && self.animationFinished {
            
            DispatchQueue.main.async(execute: {
                self.loadEvents(month: date.month, year: date.year)
            })
            let updatedMonthLabel = UILabel()
            updatedMonthLabel.textColor = monthLabel.textColor
            updatedMonthLabel.font = monthLabel.font
            updatedMonthLabel.textAlignment = .center
            updatedMonthLabel.text = date.globalDescription
            updatedMonthLabel.sizeToFit()
            updatedMonthLabel.alpha = 0
            updatedMonthLabel.center = self.monthLabel.center
            
            let offset = CGFloat(48)
            updatedMonthLabel.transform = CGAffineTransform(translationX: 0, y: offset)
            updatedMonthLabel.transform = CGAffineTransform(scaleX: 1, y: 0.1)
            
            UIView.animate(withDuration: 0.35, delay: 0, options: UIViewAnimationOptions.curveEaseIn, animations: {
                self.animationFinished = false
                self.monthLabel.transform = CGAffineTransform(translationX: 0, y: -offset)
                self.monthLabel.transform = CGAffineTransform(scaleX: 1, y: 0.1)
                self.monthLabel.alpha = 0
                
                updatedMonthLabel.alpha = 1
                updatedMonthLabel.transform = CGAffineTransform.identity
                
            }) { _ in
                
                self.animationFinished = true
                self.monthLabel.frame = updatedMonthLabel.frame
                self.monthLabel.text = updatedMonthLabel.text
                self.monthLabel.transform = CGAffineTransform.identity
                self.monthLabel.alpha = 1
                updatedMonthLabel.removeFromSuperview()
            }
            
            self.view.insertSubview(updatedMonthLabel, aboveSubview: self.monthLabel)
        }
    }
    
    func topMarker(shouldDisplayOnDayView dayView: CVCalendarDayView) -> Bool {
        return true
    }
    
    func dotMarker(shouldShowOnDayView dayView: CVCalendarDayView) -> Bool {
        let day = dayView.date.day
        let month = dayView.date.month
        for event in self.showingEvents {
            if (day == event.day && month == event.month){
                return true
            }
        }
        return false
    }
    
    func dotMarker(colorOnDayView dayView: CVCalendarDayView) -> [UIColor] {
        return [UIColorFromHex("#FFC547")]
    }
    
    func dotMarker(shouldMoveOnHighlightingOnDayView dayView: CVCalendarDayView) -> Bool {
        return true
    }
    
    func dotMarker(sizeOnDayView dayView: DayView) -> CGFloat {
        return 13
    }
    
    
    func weekdaySymbolType() -> WeekdaySymbolType {
        return .short
    }
    
    func selectionViewPath() -> ((CGRect) -> (UIBezierPath)) {
        return { UIBezierPath(rect: CGRect(x: 0, y: 0, width: $0.width, height: $0.height)) }
    }
    
    func shouldShowCustomSingleSelection() -> Bool {
        return false
    }
    
    func preliminaryView(viewOnDayView dayView: DayView) -> UIView {
        let circleView = CVAuxiliaryView(dayView: dayView, rect: dayView.bounds, shape: CVShape.circle)
        circleView.fillColor = .colorFromCode(0xCCCCCC)
        return circleView
    }
    
    func preliminaryView(shouldDisplayOnDayView dayView: DayView) -> Bool {
        if (dayView.isCurrentDay) {
            return true
        }
        return false
    }
    
    func dayOfWeekTextColor() -> UIColor {
        return UIColor.white
    }
    
    func dayOfWeekBackGroundColor() -> UIColor {
        return UIColorFromHex("#FFC547")
    }
}



extension CalendarVC: CVCalendarViewAppearanceDelegate {
    func dayLabelPresentWeekdayInitallyBold() -> Bool {
        return false
    }
    
    func spaceBetweenDayViews() -> CGFloat {
        return 0.0
    }
    
    func dayLabelFont(by weekDay: Weekday, status: CVStatus, present: CVPresent) -> UIFont { return UIFont.systemFont(ofSize: 14) }
    
    func dayLabelColor(by weekDay: Weekday, status: CVStatus, present: CVPresent) -> UIColor? {
        switch (weekDay, status, present) {
        case (_, .selected, _), (_, .highlighted, _): return Color.selectedText
        case (.sunday, .in, _): return Color.text
        case (.sunday, _, _): return Color.textDisabled
        case (_, .in, _): return Color.text
        default: return Color.textDisabled
        }
    }
    
    func dayLabelBackgroundColor(by weekDay: Weekday, status: CVStatus, present: CVPresent) -> UIColor? {
        switch (weekDay, status, present) {
        case (.sunday, .selected, _), (.sunday, .highlighted, _): return Color.sundaySelectionBackground
        case (_, .selected, _), (_, .highlighted, _): return Color.selectionBackground
        default: return nil
        }
    }
}


extension CalendarVC {

    
    @IBAction func todayMonthView() {
        calendarView.toggleCurrentDayView()
    }
    
}
