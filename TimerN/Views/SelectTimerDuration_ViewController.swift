//
//  SelectTimerDuration_ViewController.swift
//  TimerN
//
//  Created by Xinhu Liu on 27.01.16.
//  Copyright © 2016 Xinhu Liu. All rights reserved.
//

import UIKit

class SelectTimerDuration_ViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {

    // MARK: Data exchange
    
    func getResult() -> Timer {
        
        return _timer!
    }
    
    // MARK: Properties
    
    private var _timer: Timer?
    
    private let _pickerRounds = 20
    
    // MARK: Outlets
    
    @IBOutlet weak var Button_saveAndRun: UIBarButtonItem!
    @IBOutlet weak var Button_save: UIBarButtonItem!
    @IBOutlet weak var PickerView_timerDuration: UIPickerView!
    
    // MARK: Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        PickerView_timerDuration.dataSource = self
        PickerView_timerDuration.delegate = self
        
        pickerView(PickerView_timerDuration, didSelectRow: 0, inComponent: 0)
        pickerView(PickerView_timerDuration, didSelectRow: 0, inComponent: 1)
        pickerView(PickerView_timerDuration, didSelectRow: 0, inComponent: 2)
    }
    
    // MARK: Actions
    
    @IBAction func cancel(sender: UIBarButtonItem) {
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func addOneMinute(sender: UIButton) {
        
        addMinutesWithAnimation(1)
    }
    
    @IBAction func addThreeMinutes(sender: UIButton) {
        
        addMinutesWithAnimation(3)
    }
    
    @IBAction func addFiveMinutes(sender: UIButton) {
        
        addMinutesWithAnimation(5)
    }
    
    @IBAction func addTenMinutes(sender: UIButton) {
        addMinutesWithAnimation(10)
    }
    
    private func addMinutesWithAnimation(minutes: Int) {
        
        let selectedMinuteRow = PickerView_timerDuration.selectedRowInComponent(1)
        
        let selectedMinutes = selectedMinuteRow % 60
        if selectedMinutes + minutes >= 60 {
            let hoursToAdd = (selectedMinutes + minutes) / 60
            
            let selectedHours = PickerView_timerDuration.selectedRowInComponent(0)
            let maxHours = PickerView_timerDuration.numberOfRowsInComponent(0) - 1
            
            if selectedHours + hoursToAdd > maxHours {
                PickerView_timerDuration.selectRow(maxHours + 1, inComponent: 0, animated: true)
            } else {
                PickerView_timerDuration.selectRow(selectedHours + hoursToAdd, inComponent: 0, animated: true)
            }
        }
        
        PickerView_timerDuration.selectRow(selectedMinuteRow + minutes, inComponent: 1, animated: true)
        
        enableOrDisableSaveButton()
    }
    
    // MARK: Methods
    
    private func enableOrDisableSaveButton() {
        
        let selectedHours = PickerView_timerDuration.selectedRowInComponent(0)
        let selectedMinutes = PickerView_timerDuration.selectedRowInComponent(1) % 60
        let selectedSeconds = PickerView_timerDuration.selectedRowInComponent(2) % 60
        
        if selectedHours == 0 && selectedMinutes == 0 && selectedSeconds == 0 {
            Button_save.enabled = false
            Button_saveAndRun.enabled = false
        } else {
            Button_save.enabled = true
            Button_saveAndRun.enabled = true
        }
    }

    // MARK: UIPickerViewDataSource, UIPickerViewDelegate
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        
        return 3
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        if component == 0 {
            return 24                   // 0 - 23 hours
        }
        else {
            return 60 * _pickerRounds   // 0 - 59 miniutes or seconds
        }
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        if component == 0 {
            return String(row)
        }
        else {
            return String(row % 60)
        }
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        if component != 0 {
            let middleRound = _pickerRounds / 2
            let rowInMiddleRound = middleRound * 60 + row % 60
            
            pickerView.selectRow(rowInMiddleRound, inComponent: component, animated: false)
        }
        
        enableOrDisableSaveButton()
    }
    
    // MARK: Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        let hms = (
            hours: PickerView_timerDuration.selectedRowInComponent(0),
            minutes: PickerView_timerDuration.selectedRowInComponent(1) % 60,
            seconds: PickerView_timerDuration.selectedRowInComponent(2) % 60)
        
        _timer = Timer(name: "Timer", durationInSeconds: Timer.convertHoursMinutesSecondsToSeconds(hms))
        
        if segue.identifier == "saveAndRun" {
            _timer!.run()
        }
    }

}
