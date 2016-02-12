//
//  Timer.swift
//  TimerN
//
//  Created by Xinhu Liu on 12.01.16.
//  Copyright © 2016 Xinhu Liu. All rights reserved.
//

import Foundation

public class Timer: NSObject, NSCoding {
    
    // MARK: Property
    
    public var name: String
    public private(set) var durationInSecond: Int
    
    private var _internalStatus: TimerInternalStatus
    private var _startTime: NSDate?
    private var _leftSecondsSincePause: Int
    
    
    // MARK: Initializer
    
    public init(name: String, durationInSecond: Int) {
        
        self.name = name
        if durationInSecond >= 0 {
            self.durationInSecond = durationInSecond
        }
        else {
            self.durationInSecond = 0
        }
        
        _internalStatus = .Reset
        _startTime = nil
        _leftSecondsSincePause = self.durationInSecond
    }
    
    
    // MARK: Method
    
    public func run() {
        
        let currentStatus = getStatus()
        if currentStatus == .Reset || currentStatus == .Paused {
            _internalStatus = .RunningOrFinished
            _startTime = Timer.getCurrentTime()
        }
    }
    
    private static func getCurrentTime() -> NSDate {
        
        return NSDate(timeIntervalSinceNow: 0)
    }

    public func pause() {
        
        let currentStatus = getStatus()
        if currentStatus == .Running {
            _leftSecondsSincePause = getLeftSeconds()
            
            _internalStatus = .Paused
            _startTime = nil
        }
    }
    
    public func reset() {
        
        _internalStatus = .Reset
        _startTime = nil
        _leftSecondsSincePause = durationInSecond
    }
    
    public func getStatus() -> TimerStatus {
        
        switch _internalStatus {
        case .Reset:
            return .Reset
        case .RunningOrFinished:
            if getLeftSeconds() == 0 {
                return .Finished
            }
            else {
                return .Running
            }
        case .Paused:
            return .Paused
        }
    }
    
    public func getDuration() -> (hours: Int, minutes: Int, seconds: Int) {
        
        let seconds = durationInSecond % 60
        let leftMinutes = (durationInSecond - seconds) / 60
        let minutes = leftMinutes % 60
        let hours = (leftMinutes - minutes) / 60
        
        return (hours, minutes, seconds)
    }
    
    public func getLeftHourMinuteSecondInString() -> (hours: String, minutes: String, seconds: String) {
        
        let leftSeconds = getLeftSeconds()
        
        let seconds = leftSeconds % 60
        var secondString = String(seconds)
        if seconds < 10 {
            secondString = "0" + secondString
        }
        
        let leftMinutes = (leftSeconds - seconds) / 60
        let minutes = (leftMinutes) % 60
        var minuteString = String(minutes)
        if minutes < 10 {
            minuteString = "0" + minuteString
        }
        
        let leftHours = (leftMinutes - minutes) / 60
        let hourString = String(leftHours)
        
        return (hourString, minuteString, secondString)
    }
    
    public func getLeftMinuteSecondInString() -> (minutes: String, seconds: String) {
        
        let leftSeconds = getLeftSeconds()
        
        let seconds = leftSeconds % 60
        var secondString = String(seconds)
        if seconds < 10 {
            secondString = "0" + secondString
        }
        
        let leftMinutes = (leftSeconds - seconds) / 60
        let minuteString = String(leftMinutes)
        
        return (minuteString, secondString)
    }
    
    private func getLeftSeconds() -> Int {
        
        var leftSeconds: Int = 0
        
        if _internalStatus == .Reset || _internalStatus == .Paused {
            leftSeconds = _leftSecondsSincePause
        }
        else if _internalStatus == .RunningOrFinished {
            let elapsedSeconds = -(Int)(_startTime!.timeIntervalSinceNow)
            
            if elapsedSeconds < _leftSecondsSincePause {
                leftSeconds = _leftSecondsSincePause - elapsedSeconds
            }
            else {
                leftSeconds = 0
            }
        }
        
        return leftSeconds
    }
    
    
    // MARK: - NSCoding
    
    private struct PropertyKey {
        
        static let name = "name"
        static let durationInSecond = "durationInSecond"
        static let internalStatus = "internalStatus"
        static let startTime = "startTime"
        static let leftSecondsSincePause = "leftSecondsSincePause"
    }
    
    public func encodeWithCoder(aCoder: NSCoder) {
        
        aCoder.encodeObject(name, forKey: PropertyKey.name)
        aCoder.encodeObject(durationInSecond, forKey: PropertyKey.durationInSecond)
        aCoder.encodeObject(_internalStatus.rawValue, forKey: PropertyKey.internalStatus)
        aCoder.encodeObject(_startTime, forKey: PropertyKey.startTime)
        aCoder.encodeObject(_leftSecondsSincePause, forKey: PropertyKey.leftSecondsSincePause)
    }
    
    required convenience public init?(coder aDecoder: NSCoder) {
        
        let name = aDecoder.decodeObjectForKey(PropertyKey.name) as! String
        let durationInSecond = aDecoder.decodeObjectForKey(PropertyKey.durationInSecond) as! Int
        
        self.init(name: name, durationInSecond: durationInSecond)
                
        self._internalStatus = TimerInternalStatus(rawValue: aDecoder.decodeObjectForKey(PropertyKey.internalStatus) as! Int)!
        self._startTime = aDecoder.decodeObjectForKey(PropertyKey.startTime) as! NSDate?
        self._leftSecondsSincePause = aDecoder.decodeObjectForKey(PropertyKey.leftSecondsSincePause) as! Int
    }
}

public enum TimerStatus {
    case Reset
    case Running
    case Paused
    case Finished
}

private enum TimerInternalStatus: Int {
    case Reset
    case RunningOrFinished
    case Paused
}