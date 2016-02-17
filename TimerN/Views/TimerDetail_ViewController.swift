//
//  TimerDetail_ViewController.swift
//  TimerN
//
//  Created by Xinhu Liu on 26.01.16.
//  Copyright © 2016 Xinhu Liu. All rights reserved.
//

import UIKit

class TimerDetail_ViewController: UIViewController {
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationItem.title = _timer!.name
        updateContent()
        
        _updateTimer = NSTimer.scheduledTimerWithTimeInterval(0.3, target: self, selector: Selector("updateContent"), userInfo: nil, repeats: true)
        NSRunLoop.currentRunLoop().addTimer(_updateTimer!, forMode: NSRunLoopCommonModes)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        _updateTimer?.invalidate()
    }
    
    //
    // MARK: Data exchange
    
    func prepare(timer: Timer, timers: [Timer]) {
        
        _timer = timer
        _timers = timers
    }
    
    //
    // MARK: Property
    
    private var _timer: Timer?
    private var _timers: [Timer]?
    private var _updateTimer: NSTimer?

    //
    // MARK: Outlet
    
    @IBOutlet weak var Label_minute: UILabel!
    @IBOutlet weak var Label_second: UILabel!
    @IBOutlet weak var Label_status: UILabel!
    @IBOutlet weak var Button_left: UIButton!
    @IBOutlet weak var Button_right: UIButton!

    //
    // MARK: Action
    
    @IBAction func rename(sender: UIBarButtonItem) {
        
        let renameAC = UIAlertController(title: NSLocalizedString("Rename", comment: "") + " \(_timer!.name)", message: nil, preferredStyle: .Alert)
        
        var nameTextField: UITextField?
        renameAC.addTextFieldWithConfigurationHandler { (textField: UITextField) -> Void in
            textField.placeholder = self._timer!.name
            nameTextField = textField
        }
        
        let renameAction = UIAlertAction(title: NSLocalizedString("Rename", comment: ""), style: .Default, handler: { (aa: UIAlertAction) -> Void in
            let newName = nameTextField!.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
            if (newName != "") {
                self._timer!.name = nameTextField!.text!
                self.navigationItem.title = self._timer!.name
                TimerHelper.saveTimers(self._timers!)
                NotificationHelper.setLocalNotifications(self._timers!)
            }
        })
        renameAC.addAction(renameAction)
        
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .Cancel, handler: nil)
        renameAC.addAction(cancelAction)
        
        self.presentViewController(renameAC, animated: true, completion: nil)
    }

    
    @IBAction func didTouchLeftButton(sender: UIButton) {
        
        _timer!.reset()
        
        TimerHelper.saveTimers(_timers!)
        NotificationHelper.setLocalNotifications(_timers!)
    }
    
    @IBAction func didTouchRightButton(sender: UIButton) {
        
        let timerStatus = _timer!.getStatus()
        switch timerStatus {
        case .Running:
            _timer!.pause()
        case .Paused, .Reset:
            _timer!.run()
        default: break
        }
        
        TimerHelper.saveTimers(_timers!)
        NotificationHelper.setLocalNotifications(_timers!)
    }
    
    //
    // MARK: Method
    
    func updateContent() {
        
        let leftMinutesSeconds = Timer.convertSecondsToMinutesSeconds(_timer!.getLeftSeconds())
        Label_minute.text = Timer.convertNumberToTwoDigitString(leftMinutesSeconds.minutes)
        Label_second.text = Timer.convertNumberToTwoDigitString(leftMinutesSeconds.seconds)
        
        let timerStatus = _timer!.getStatus()
        Label_status.text = TimerHelper.getTextFromStatus(timerStatus)
        Label_status.textColor = TimerHelper.getTextColorFromStatus(timerStatus)
        
        switch timerStatus {
        case .Running, .Paused, .Finished:
            Button_left.enabled = true
        case .Reset:
            Button_left.enabled = false
        }
        
        switch timerStatus {
        case .Reset:
            Button_right.enabled = true
            Button_right.setTitle(NSLocalizedString("Start", comment: ""), forState: .Normal)
        case .Running:
            Button_right.enabled = true
            Button_right.setTitle(NSLocalizedString("Pause", comment: ""), forState: .Normal)
        case .Paused:
            Button_right.enabled = true
            Button_right.setTitle(NSLocalizedString("Resume", comment: ""), forState: .Normal)
        case .Finished:
            Button_right.enabled = false
            Button_right.setTitle(NSLocalizedString("Start", comment: ""), forState: .Normal)
        }
    }

}
