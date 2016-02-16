//
//  TimerHelper.swift
//  TimerN
//
//  Created by Xinhu Liu on 26/01/16.
//  Copyright © 2016 Xinhu Liu. All rights reserved.
//

import UIKit

class TimerHelper {
    
    private static let _archiveURLOfTimers = NSFileManager()
        .URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
        .URLByAppendingPathComponent("timers")

    class func saveTimers(timers: [Timer]) {
        
        NSKeyedArchiver.archiveRootObject(timers, toFile: _archiveURLOfTimers.path!)
    }
    
    class func loadTimers() -> [Timer] {
        
        let timers = NSKeyedUnarchiver.unarchiveObjectWithFile(_archiveURLOfTimers.path!) as? [Timer]
        if timers != nil {
            return timers!
        }
        else {
            return [Timer]()
        }
    }
    
    class func getTextFromStatus(timerStatus: TimerStatus) -> String {
        
        switch timerStatus {
        case .Reset:
            return NSLocalizedString("READY", comment: "")
        case .Running:
            return NSLocalizedString("RUNNING", comment: "")
        case .Paused:
            return NSLocalizedString("PAUSED", comment: "")
        case .Finished:
            return NSLocalizedString("FINISHED", comment: "")
        }
    }
    
    class func getTextColorFromStatus(timerStatus: TimerStatus) -> UIColor {
        
        switch timerStatus {
        case .Reset:
            return UIColor.blueColor()
        case .Running:
            return UIColor.greenColor()
        case .Paused:
            return UIColor.brownColor()
        case .Finished:
            return UIColor.redColor()
        }
    }
    
}