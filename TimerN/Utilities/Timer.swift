//
//  Timer.swift
//  TimerN
//
//  Created by Xinhu Liu on 12.01.16.
//  Copyright © 2016 Xinhu Liu. All rights reserved.
//

import Foundation

public class Timer: NSObject, NSCoding {
    
    // MARK: - Properties
    
    public var name: String
    public private(set) var durationInSeconds: Int
    
    private var _internalStatus: TimerInternalStatus
    private var _startTime: NSDate?
    private var _leftSecondsSincePause: Int
    
    //
    // MARK: - Initializers
    
    public init(name: String, durationInSecond: Int) {
        
        self.name = name
        if durationInSecond >= 0 {
            self.durationInSeconds = durationInSecond
        }
        else {
            self.durationInSeconds = 0
        }
        
        _internalStatus = .Reset
        _startTime = nil
        _leftSecondsSincePause = self.durationInSeconds
    }
    
    //
    // MARK: - Class methods
    
    public class func convertHoursMinutesSecondsToSeconds(hms: (hours: Int, minutes: Int, seconds: Int)) -> Int {
        
        return hms.hours * 60 * 60 + hms.minutes * 60 + hms.seconds
    }
    
    public class func convertSecondsToMinutesSeconds(seconds: Int) -> (minutes: Int, seconds: Int) {
        
        return ((seconds - seconds % 60) / 60, seconds % 60)
    }
    
    public class func convertSecondsToHoursMinutesSeconds(seconds: Int) -> (hours: Int, minutes: Int, seconds: Int) {
        
        let minutesAndSeconds = convertSecondsToMinutesSeconds(seconds)
        let minutes = minutesAndSeconds.minutes
        
        return ((minutes - minutes % 60) / 60, minutes % 60, minutesAndSeconds.seconds)
    }
    
    public class func convertNumberToTwoDigitString(number: Int) -> String {
        
        return number < 10 ? "0\(number)" : "\(number)"
    }
    
    //
    // MARK: - Methods
    
    public func run() {
        
        let currentStatus = getStatus()
        if currentStatus == .Reset || currentStatus == .Paused {
            _internalStatus = .RunningOrFinished
            _startTime = getCurrentTime()
        }
    }
    
    private func getCurrentTime() -> NSDate {
        
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
        _leftSecondsSincePause = durationInSeconds
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
    
    public func getLeftSeconds() -> Int {
        
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
        aCoder.encodeObject(durationInSeconds, forKey: PropertyKey.durationInSecond)
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