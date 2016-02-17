//
//  Timers_TableViewController.swift
//  TimerN
//
//  Created by Xinhu Liu on 20.01.16.
//  Copyright © 2016 Xinhu Liu. All rights reserved.
//

import UIKit

class Timers_TableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = editButtonItem()
        
        _timers = TimerHelper.loadTimers()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        updateCellContent()
        
        if tableView.editing == false {
            startUpdateCellContentPeriodically()
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        if tableView.editing == false {
            stopUpdateCellContentPeriodically()
        }
    }
        
    //
    // MARK: Property
    
    private var _timers: [Timer] = []

    private var _updateTimer: NSTimer?

    //
    // MARK: Action
    
    @IBAction func addTimer(sender: AnyObject) {
        
        let vc = UIStoryboard(name: "SelectTimerDuration", bundle: nil).instantiateInitialViewController()!
        presentViewController(vc, animated: true, completion: nil)
    }
    
    @IBAction func unwindFromSelectTimerDuration(sender: UIStoryboardSegue) {
        
        if let sourceVC = sender.sourceViewController as? SelectTimerDuration_ViewController {
            
            let timer = sourceVC.getResult()
            
            let newIndexPath = NSIndexPath(forRow: _timers.count, inSection: 0)
            _timers.append(timer)
            TimerHelper.saveTimers(_timers)
            NotificationHelper.setLocalNotifications(_timers)
            tableView.insertRowsAtIndexPaths([newIndexPath], withRowAnimation: .Bottom)
        }
    }
    
    //
    // MARK: Method
    
    private func startUpdateCellContentPeriodically() {
        
        _updateTimer = NSTimer.scheduledTimerWithTimeInterval(0.3, target: self, selector: Selector("updateCellContent"), userInfo: nil, repeats: true)
        NSRunLoop.currentRunLoop().addTimer(_updateTimer!, forMode: NSRunLoopCommonModes)
    }
    
    private func stopUpdateCellContentPeriodically() {
        
        _updateTimer?.invalidate()
    }
    
    func updateCellContent() {
        
        tableView.reloadData()
    }
    
    //
    // MARK: - Table view data source

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return _timers.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let timer = _timers[indexPath.row]
        
        let cell = tableView.dequeueReusableCellWithIdentifier(Timers_TableViewCell.CellIdentifier, forIndexPath: indexPath) as! Timers_TableViewCell
        cell.prepareUIForTimer(timer)
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let timer = _timers[indexPath.row]
        let timerStatus = timer.getStatus()
        
        let alertController = UIAlertController(title: nil, message: timer.name, preferredStyle: .ActionSheet)
        
        let operateAction = UIAlertAction(title: getOperateActionTitle(timerStatus), style: .Destructive) { (aa: UIAlertAction) -> Void in
            self.operateTimer(timer, originalTimerStatus: timerStatus)
            TimerHelper.saveTimers(self._timers)
            NotificationHelper.setLocalNotifications(self._timers)
        }
        alertController.addAction(operateAction)
        
        let renameAction = UIAlertAction(title: NSLocalizedString("Rename", comment: ""), style: .Default) { (aa: UIAlertAction) -> Void in
            self.showRenameAlertController(timer)
        }
        alertController.addAction(renameAction)
        
        let moreAction = UIAlertAction(title: NSLocalizedString("Details...", comment: ""), style: .Default) { (aa: UIAlertAction) -> Void in
            let vc = UIStoryboard(name: "TimerDetail", bundle: nil).instantiateInitialViewController()! as! TimerDetail_ViewController
            vc.prepare(timer, timers: self._timers)
            self.navigationController?.pushViewController(vc, animated: true)
        }
        alertController.addAction(moreAction)
        
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .Cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    private func getOperateActionTitle(timerStauts: TimerStatus) -> String {
        
        switch timerStauts {
        case .Reset:    return NSLocalizedString("Start", comment: "")
        case .Running:  return NSLocalizedString("Pause", comment: "")
        case .Paused:   return NSLocalizedString("Resume", comment: "")
        case .Finished: return NSLocalizedString("Reset", comment: "")
        }
    }
    
    private func operateTimer(timer: Timer, originalTimerStatus: TimerStatus) {
        
        switch originalTimerStatus {
        case .Reset:
            timer.run()
        case .Running:
            timer.pause()
        case .Paused:
            timer.run()
        case .Finished:
            timer.reset()
        }
    }
    
    private func showRenameAlertController(timer: Timer) {
        
        let renameAC = UIAlertController(title: NSLocalizedString("Rename", comment: "") + " \(timer.name)", message: nil, preferredStyle: .Alert)
        
        var nameTextField: UITextField?
        renameAC.addTextFieldWithConfigurationHandler { (textField: UITextField) -> Void in
            textField.placeholder = timer.name
            nameTextField = textField
        }
        
        let renameAction = UIAlertAction(title: NSLocalizedString("Rename", comment: ""), style: .Default, handler: { (aa: UIAlertAction) -> Void in
            let newName = nameTextField!.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
            if (newName != "") {
                timer.name = nameTextField!.text!
                TimerHelper.saveTimers(self._timers)
                NotificationHelper.setLocalNotifications(self._timers)
            }
        })
        renameAC.addAction(renameAction)
        
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .Cancel, handler: nil)
        renameAC.addAction(cancelAction)
        
        self.presentViewController(renameAC, animated: true, completion: nil)
    }
    
    /* This method disables slide delete. */
    override func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        
        if tableView.editing == true {
            return .Delete
        }
        else {
            return .None
        }
    }

    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        if editingStyle == .Delete {
            _timers.removeAtIndex(indexPath.row);
            TimerHelper.saveTimers(_timers)
            NotificationHelper.setLocalNotifications(_timers)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        }
    }
    
    override func setEditing(editing: Bool, animated: Bool) {
        
        if editing == true {
            stopUpdateCellContentPeriodically()
        }
        else {
            startUpdateCellContentPeriodically()
        }
        
        super.setEditing(editing, animated: animated)
    }
    
}
