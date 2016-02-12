//
//  SelectTimerDuration_ViewController.swift
//  TimerN
//
//  Created by Xinhu Liu on 27/01/16.
//  Copyright © 2016 Xinhu Liu. All rights reserved.
//

import UIKit

class SelectTimerDuration_ViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        PickerView_timerDuration.dataSource = self
        PickerView_timerDuration.delegate = self
        
        pickerView(PickerView_timerDuration, didSelectRow: 0, inComponent: 0)
        pickerView(PickerView_timerDuration, didSelectRow: 0, inComponent: 1)
        pickerView(PickerView_timerDuration, didSelectRow: 0, inComponent: 2)
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        let selectedRow = PickerView_timerDuration.selectedRowInComponent(1)
        PickerView_timerDuration.selectRow(selectedRow + 10, inComponent: 1, animated: true)
    }
    
    //
    // MARK: Data exchange
    
    func getResult() -> Timer {
        
        return _timer!
    }
    
    //
    // MARK: Property
    
    private var _timer: Timer?
    
    private let _pickerRounds = 20
    
    //
    // MARK: Outlet
    
    @IBOutlet weak var PickerView_timerDuration: UIPickerView!
    
    //
    // MARK: Action
    
    @IBAction func cancel(sender: UIBarButtonItem) {
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    //
    // MARK: - UIPickerViewDataSource, UIPickerViewDelegate
    
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
        
        if component == 0 {
            return
        }
        
        let middleRound = _pickerRounds / 2
        let rowInMiddleRound = middleRound * 60 + row % 60
        
        pickerView.selectRow(rowInMiddleRound, inComponent: component, animated: false)
    }
    
    //
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        let hours = PickerView_timerDuration.selectedRowInComponent(0)
        let minutes = PickerView_timerDuration.selectedRowInComponent(1) % 60
        let seconds = PickerView_timerDuration.selectedRowInComponent(2) % 60
        
        let durationInSecond = hours * 60 * 60 + minutes * 60 + seconds
        _timer = Timer(name: "Timer", durationInSecond: durationInSecond)
        
        if segue.identifier == "saveAndRun" {
            _timer!.run()
        }
    }

}
