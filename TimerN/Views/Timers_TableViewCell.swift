//
//  Timers_TableViewCell.swift
//  TimerN
//
//  Created by Xinhu Liu on 20/01/16.
//  Copyright © 2016 Xinhu Liu. All rights reserved.
//

import UIKit

class Timers_TableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    // MARK: Property
    
    static let CellIdentifier = "Timers_TableViewCell"
    
    
    // MARK: Outlet
    
    @IBOutlet weak var Label_timerName: UILabel!
    @IBOutlet weak var Label_timerStatus: UILabel!
    @IBOutlet weak var Label_timerMiniute: UILabel!
    @IBOutlet weak var Label_timerSecond: UILabel!
    
    
    // MARK: Method
    
    func prepareUIForTimer(timer: Timer) {
    
        let status = timer.getStatus()
        let leftTime = timer.getLeftMinuteSecondInString()
        
        Label_timerName.text = timer.name
        Label_timerMiniute.text = leftTime.minutes
        Label_timerSecond.text = leftTime.seconds
        setTimerStatusLabel(status, label: Label_timerStatus)
    }
    
    private func setTimerStatusLabel(status: TimerStatus, label: UILabel) {
        
        label.text = TimerUIHelper.getTextFromStatus(status)
        label.textColor = TimerUIHelper.getTextColorFromStatus(status)
    }
}
