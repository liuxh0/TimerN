//
//  NotificationHelper.swift
//  TimerN
//
//  Created by Xinhu Liu on 16.02.16.
//  Copyright © 2016 Xinhu Liu. All rights reserved.
//

import UIKit

class NotificationHelper {
    
    class func setLocalNotifications(timers: [Timer]) {
        
        emptyLocalNotifications()
        
        for timer in timers {
            if timer.getStatus() == .Running {
                addLocalNotification(timer)
            }
        }
    }
    
    private class func emptyLocalNotifications() {
        
        UIApplication.sharedApplication().cancelAllLocalNotifications()
    }
    
    private class func addLocalNotification(timer: Timer) {
        
        let notification = UILocalNotification()
        
        notification.fireDate = NSDate(timeIntervalSinceNow: Double(timer.getLeftSeconds()))
        notification.alertBody = String(format: NSLocalizedString("Timer '%@' runs out!", comment: ""), timer.name)
        notification.soundName = UILocalNotificationDefaultSoundName
        
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
    }

}