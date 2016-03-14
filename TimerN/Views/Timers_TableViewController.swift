//
//  Timers_TableViewController.swift
//  TimerN
//
//  Created by Xinhu Liu on 20.01.16.
//  Copyright © 2016 Xinhu Liu. All rights reserved.
//

import UIKit

class Timers_TableViewController: UITableViewController {
    
    // MARK: Properties
    
    private let _keyOfNotificationIsRegistered = AppDelegate.keyOfNotificationIsRegistered
    private let _tableViewCellIdentifier = "Timers_TableViewCell"
    
    private var _timers: [Timer] = []
    
    // MARK: Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = editButtonItem()
        _timers = TimerHelper.loadTimers()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if NSUserDefaults.standardUserDefaults().boolForKey(_keyOfNotificationIsRegistered) == false {
            
            let alert = UIAlertController(title: nil, message: NSLocalizedString("We want to inform you when a timer runs out. Please allow our notifications.", comment: ""), preferredStyle: .Alert)
            let okAction = UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .Default) { (_: UIAlertAction) -> Void in
                let notificationSettings = UIUserNotificationSettings(forTypes: [.Alert, .Sound, .Badge], categories: nil)
                UIApplication.sharedApplication().registerUserNotificationSettings(notificationSettings)
                NSUserDefaults.standardUserDefaults().setBool(true, forKey: self._keyOfNotificationIsRegistered)
            }
            alert.addAction(okAction)
            presentViewController(alert, animated: true, completion: nil)
        }
    }

    // MARK: Actions
    
    @IBAction func addTimer(sender: AnyObject) {
        
        let vc = UIStoryboard(name: "SelectTimerDuration", bundle: nil).instantiateInitialViewController()!
        presentViewController(vc, animated: true, completion: nil)
    }
    
    @IBAction func unwindFromSelectTimerDuration(sender: UIStoryboardSegue) {
        
        if let sourceVC = sender.sourceViewController as? SelectTimerDuration_ViewController {
            let timer = sourceVC.getResult()
            
            _timers.append(timer)
            TimerHelper.saveTimers(_timers)
            NotificationHelper.setLocalNotifications(_timers)
            
            let rowIndexPath = NSIndexPath(forRow: _timers.count - 1, inSection: 0)
            tableView.insertRowsAtIndexPaths([rowIndexPath], withRowAnimation: .Bottom)
        }
    }
    
    // MARK: Table view

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return _timers.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier(_tableViewCellIdentifier, forIndexPath: indexPath) as! Timers_TableViewCell
        cell.use(_timers[indexPath.row])
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let timer = _timers[indexPath.row]
        let timerStatus = timer.getStatus()
        
        let alertController = UIAlertController(title: nil, message: timer.name, preferredStyle: .ActionSheet)
        
        let operateAction = UIAlertAction(title: getOperateActionTitle(timerStatus), style: .Destructive) { (_: UIAlertAction) -> Void in
            self.operateTimer(timer, originalTimerStatus: timerStatus)
            TimerHelper.saveTimers(self._timers)
            NotificationHelper.setLocalNotifications(self._timers)
        }
        alertController.addAction(operateAction)
        
        let renameAction = UIAlertAction(title: NSLocalizedString("Rename", comment: ""), style: .Default) { (_: UIAlertAction) -> Void in
            self.showRenameAlertController(timer, indexPath: indexPath)
        }
        alertController.addAction(renameAction)
        
        let showDetailAction = UIAlertAction(title: NSLocalizedString("Details...", comment: ""), style: .Default) { (_: UIAlertAction) -> Void in
            let vc = UIStoryboard(name: "TimerDetail", bundle: nil).instantiateInitialViewController()! as! TimerDetail_ViewController
            vc.prepare(timer, timers: self._timers)
            self.navigationController?.pushViewController(vc, animated: true)
        }
        alertController.addAction(showDetailAction)
        
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .Cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    private func getOperateActionTitle(timerStauts: TimerStatus) -> String {
        
        switch timerStauts {
        case .Reset:    return NSLocalizedString("Start", comment: "")
        case .Running:  return NSLocalizedString("Pause", comment: "")
        case .Paused:   return NSLocalizedString("Resume", comment: "")
        case .Finished: return NSLocalizedString("Start again", comment: "")
        }
    }
    
    private func operateTimer(timer: Timer, originalTimerStatus: TimerStatus) {
        
        switch originalTimerStatus {
        case .Reset:    timer.run()
        case .Running:  timer.pause()
        case .Paused:   timer.run()
        case .Finished: timer.reset(); timer.run()
        }
    }
    
    private func showRenameAlertController(timer: Timer, indexPath: NSIndexPath) {
        
        let renameAC = UIAlertController(title: NSLocalizedString("Rename", comment: "") + " \(timer.name)", message: nil, preferredStyle: .Alert)
        
        var nameTextField: UITextField?
        renameAC.addTextFieldWithConfigurationHandler { (textField: UITextField) -> Void in
            textField.placeholder = timer.name
            nameTextField = textField
        }
        
        let renameAction = UIAlertAction(title: NSLocalizedString("Rename", comment: ""), style: .Default, handler: { (_: UIAlertAction) -> Void in
            let newName = nameTextField!.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
            if (newName != "") {
                timer.name = nameTextField!.text!
                TimerHelper.saveTimers(self._timers)
                NotificationHelper.setLocalNotifications(self._timers)
                
                let tableViewCell = self.tableView.cellForRowAtIndexPath(indexPath) as! Timers_TableViewCell
                tableViewCell.use(timer)
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
            
            let tableViewCell = tableView.cellForRowAtIndexPath(indexPath) as! Timers_TableViewCell
            tableViewCell.abondon()
            
            // The following operation must be after operations above.
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        }
    }
    
    override func tableView(tableView: UITableView, moveRowAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath) {
        
        let timerToMove = _timers[sourceIndexPath.row]
        _timers.removeAtIndex(sourceIndexPath.row)
        _timers.insert(timerToMove, atIndex: destinationIndexPath.row)
        TimerHelper.saveTimers(_timers)
    }
    
}
