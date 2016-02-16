//
//  TimerTest.swift
//  TimerN
//
//  Created by Xinhu Liu on 16.02.16.
//  Copyright © 2016 Xinhu Liu. All rights reserved.
//

import XCTest
@testable import TimerN

class TimerTest: XCTestCase {
    
    func testConvertHoursMinutesSecondsToSeconds() {
        
        var hms = (hours: 0, minutes:0, seconds: 0)
        assert(Timer.convertHoursMinutesSecondsToSeconds(hms) == 0)
        
        hms = (hours: 0, minutes:0, seconds: 1)
        assert(Timer.convertHoursMinutesSecondsToSeconds(hms) == 1)
        
        hms = (hours: 0, minutes:1, seconds: 0)
        assert(Timer.convertHoursMinutesSecondsToSeconds(hms) == 60)
        
        hms = (hours: 1, minutes:0, seconds: 0)
        assert(Timer.convertHoursMinutesSecondsToSeconds(hms) == 3600)
        
        hms = (hours: 2, minutes:2, seconds: 2)
        assert(Timer.convertHoursMinutesSecondsToSeconds(hms) == 7322)
    }
    
    func testConvertSecondsToMinutesSeconds() {
    
        var ms = Timer.convertSecondsToMinutesSeconds(0)
        assert(ms.minutes == 0 && ms.seconds == 0)
        
        ms = Timer.convertSecondsToMinutesSeconds(60)
        assert(ms.minutes == 1 && ms.seconds == 0)
        
        ms = Timer.convertSecondsToMinutesSeconds(122)
        assert(ms.minutes == 2 && ms.seconds == 2)
    }
    
    func testConvertSecondsToHoursMinutesSeconds() {
        
        var hms = Timer.convertSecondsToHoursMinutesSeconds(0)
        assert(hms.hours == 0 && hms.minutes == 0 && hms.seconds == 0)
        
        hms = Timer.convertSecondsToHoursMinutesSeconds(3600)
        assert(hms.hours == 1 && hms.minutes == 0 && hms.seconds == 0)
        
        hms = Timer.convertSecondsToHoursMinutesSeconds(7322)
        assert(hms.hours == 2 && hms.minutes == 2 && hms.seconds == 2)
    }
    
    func testConvertNumberToTwoDigitString() {
        
        var s = Timer.convertNumberToTwoDigitString(0)
        assert(s == "00")
        
        s = Timer.convertNumberToTwoDigitString(10)
        assert(s == "10")
    }

}
