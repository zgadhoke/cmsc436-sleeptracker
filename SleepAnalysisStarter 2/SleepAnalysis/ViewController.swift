//
//  ViewController.swift
//  SleepAnalysis
//
//  Created by Anushk Mittal on 5/8/16.
//  Copyright © 2016 Anushk Mittal. All rights reserved.
//

import UIKit
import HealthKit


class ViewController: UIViewController {
    
    let healthStore = HKHealthStore()
    
    @IBOutlet var displayTimeLabel: UILabel!
    @IBOutlet weak var summaryButton: UIButton!
    
    var startTime = TimeInterval()
    var timer:Timer = Timer()
    var endTime: NSDate!
    var alarmTime: NSDate!


    override func viewDidLoad() {
        super.viewDidLoad()
        
        //This code will prompt the user to allow or deny the requested permissions
        let read = Set([
            HKObjectType.categoryType(forIdentifier: HKCategoryTypeIdentifier.sleepAnalysis)!
            ])
        
        let share = Set([
            HKObjectType.categoryType(forIdentifier: HKCategoryTypeIdentifier.sleepAnalysis)!
            ])
        
        self.healthStore.requestAuthorization(toShare: share, read: read) { (success, error) -> Void in
            if success == false {
                NSLog("Permission Denied")
            }
        }
    }
    
    
    @IBAction func start() {
        summaryButton.setTitle("", for: .normal)
        alarmTime = NSDate()
        if (!timer.isValid) {
            let aSelector : Selector = #selector(ViewController.updateTime)
            timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: aSelector, userInfo: nil, repeats: true)
            startTime = NSDate.timeIntervalSinceReferenceDate
        }
        
    }
    
    
    @IBAction func stop() {
        endTime = NSDate()
        saveSleep()
        getSleep()
        timer.invalidate()
    }
    
    @objc func updateTime() {
        let currentTime = NSDate.timeIntervalSinceReferenceDate
        
        //Find the difference between current time and start time.
        var elapsedTime: TimeInterval = currentTime - startTime
        
        //calculate the minutes in elapsed time.
        let minutes = UInt8(elapsedTime / 60.0)
        elapsedTime -= (TimeInterval(minutes) * 60)
        
        //calculate the seconds in elapsed time.
        let seconds = UInt8(elapsedTime)
        elapsedTime -= TimeInterval(seconds)
        
        //find out the fraction of milliseconds to be displayed.
        let fraction = UInt8(elapsedTime * 100)
        
        //add the leading zero for minutes, seconds and millseconds and store them as string constants
        
        let strMinutes = String(format: "%02d", minutes)
        let strSeconds = String(format: "%02d", seconds)
        let strFraction = String(format: "%02d", fraction)
        
        //concatenate minuets, seconds and milliseconds as assign it to the UILabel
        displayTimeLabel.text = "\(strMinutes):\(strSeconds):\(strFraction)"
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func saveSleep() {
        // alarmTime and endTime are NSDate objects
        if let sleepType = HKObjectType.categoryType(forIdentifier: HKCategoryTypeIdentifier.sleepAnalysis) {
            
            // we create our new object we want to push in Health app
            let object = HKCategorySample(type:sleepType, value: HKCategoryValueSleepAnalysis.inBed.rawValue, start: self.alarmTime as Date, end: self.endTime as Date)
            
//            let time = self.endTime.timeIntervalSince(self.alarmTime as Date)
//            let hours = Int(time) / 3600
//            let minutes = Int(time) / 60 % 60
//            let seconds = Int(time) % 60
//            let interval = String(format:"%02i:%02i:%02i", hours, minutes, seconds)
            //print("interval: \(interval)" )
            //summaryButton.setTitle("You Slept for \(interval)", for: .normal)
            
            // at the end, we save it
            healthStore.save(object, withCompletion: { (success, error) -> Void in
                
                if error != nil {
                    // something happened
                    return
                }
                
                if success {
                    print("data saved in HealthKit")
                } else {
                }
                
            })
            
            
            let object2 = HKCategorySample(type:sleepType, value: HKCategoryValueSleepAnalysis.asleep.rawValue, start: self.alarmTime as Date, end: self.endTime as Date)
            
            healthStore.save(object2, withCompletion: { (success, error) -> Void in
                if error != nil {
                    // something happened
                    return
                }
                
//                if success {
//                } else {
//                }
//
            })
            
        }
    }
    
    
    func getSleep() {
        
//        var sleepTime = 0.0
        
        
        // definte the object
        if let sleep = HKObjectType.categoryType(forIdentifier: HKCategoryTypeIdentifier.sleepAnalysis) {
            
            // get recent data
            let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
            
            // query data
            let query = HKSampleQuery(sampleType: sleep, predicate: nil, limit: 30, sortDescriptors: [sortDescriptor]) { (query, tmpResult, error) -> Void in
                
                // if error occured - exit
                if error != nil {
                    return
                }
                
                if let result = tmpResult {
                    for item in result {
                        if let sample = item as? HKCategorySample {
                            let value = (sample.value == HKCategoryValueSleepAnalysis.inBed.rawValue) ? "InBed" : "Asleep"
                            print("Healthkit sleep: \(sample.startDate) \(sample.endDate) - value: \(value)")
//                            sleepTime += sample.endDate.timeIntervalSince(sample.startDate)
                        }
                    }
                }
            }
            
            //execute query
            healthStore.execute(query)
        }
        
//        let time = sleepTime/30
//        let hours = Int(time) / 3600
//        let minutes = Int(time) / 60 % 60
//        let seconds = Int(time) % 60
//        let interval = String(format:"%02i:%02i:%02i", hours, minutes, seconds)
//        summaryButton.setTitle("You Slept for \(sleepTime)", for: .normal)
    }
    
    @IBAction func viewData(_ sender: Any) {
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(URL(string: "x-apple-health://")!)
        } else {
        }
    }
    

}

