//
//  Timers_TableViewCell.swift
//  TimerN
//
//  Created by Xinhu Liu on 20.01.16.
//  Copyright © 2016 Xinhu Liu. All rights reserved.
//

import UIKit

class Timers_TableViewCell: UITableViewCell {
    
    // MARK: Properties
    
    private var _timer: Timer?
    
    private var _refreshTimer: NSTimer?
    private let _refreshTimeInterval = 0.3
    
    // MARK: Outlets
    
    @IBOutlet weak var Label_timerName: UILabel!
    @IBOutlet weak var Label_timerStatus: UILabel!
    @IBOutlet weak var Label_timerMiniute: UILabel!
    @IBOutlet weak var Label_timerSecond: UILabel!
    
    // MARK: Methods
    
    func use(timer: Timer) {
        
        _timer = timer
        
        if _refreshTimer == nil {
            _refreshTimer = NSTimer.scheduledTimerWithTimeInterval(_refreshTimeInterval, target: self, selector: Selector("refreshCellContents"), userInfo: nil, repeats: true)
            NSRunLoop.currentRunLoop().addTimer(_refreshTimer!, forMode: NSRunLoopCommonModes)
        }
        
        Label_timerName.text = _timer!.name
        refreshCellContents()
    }
    
    func abondon() {
        
        _timer = nil
        _refreshTimer?.invalidate()
    }
    
    func refreshCellContents() {
        
        let leftSeconds = _timer!.getLeftSeconds()
        let leftMinutesSeconds = Timer.convertSecondsToMinutesSeconds(leftSeconds)
        
        Label_timerMiniute.text = Timer.convertNumberToTwoDigitString(leftMinutesSeconds.minutes)
        Label_timerSecond.text = Timer.convertNumberToTwoDigitString(leftMinutesSeconds.seconds)
        setTimerStatusLabel(_timer!.getStatus(), label: Label_timerStatus)
    }
    
    private func setTimerStatusLabel(status: TimerStatus, label: UILabel) {
        
        label.text = TimerHelper.getTextFromStatus(status)
        label.textColor = TimerHelper.getTextColorFromStatus(status)
    }
    
}
