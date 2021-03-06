//
//  BusinessHours.swift
//  RestaurantReviews
//
//  Created by Pasan Premaratne on 5/9/17.
//  Copyright © 2017 Treehouse. All rights reserved.
//

import Foundation

struct BusinessHours {
    enum HoursType {
        case regular
        
        init?(string: String) {
            switch string {
            case "REGULAR": self = .regular
            default: return nil
            }
        }
    }
    
    struct Schedule {
        enum Day: Int {
            case monday = 0
            case tuesday
            case wednesday
            case thursday
            case friday
            case saturday
            case sunday
            
            init?(weekday: String) {
                switch weekday {
                case "sunday": self = .sunday
                case "monday": self = .monday
                case "tuesday": self = .tuesday
                case "wednesday": self = .wednesday
                case "thursday": self = .thursday
                case "friday": self = .friday
                case "saturday": self = .saturday
                default: return nil
                }
            }
            
            init?(weekday: Int) {
                switch weekday {
                case 0: self = .monday
                case 1: self = .tuesday
                case 2: self = .wednesday
                case 3: self = .thursday
                case 4: self = .friday
                case 5: self = .saturday
                case 6: self = .sunday
                default: return nil
                }
            }
        }
        
        let isOvernight: Bool
        let start: String
        let end: String
        let day: Day
    }
    
    let schedule: [Schedule]
    let type: HoursType
    let isOpenNow: Bool
}

extension BusinessHours.Schedule: JSONDecodable {
    init?(json: [String : Any]) {
        print(json)
        guard let isOvernight = json["is_overnight"] as? Bool, let start = json["start"] as? String, let end = json["end"] as? String, let dayValue = json["day"] as? Int, let day = BusinessHours.Schedule.Day(rawValue: dayValue) else { return nil }
        
        self.isOvernight = isOvernight
        self.start = start
        self.end = end
        self.day = day
    }
}

extension BusinessHours: JSONDecodable {
    init?(json: [String : Any]) {
        guard let openHours = json["open"] as? [[String: Any]], let hoursTypeString = json["hours_type"] as? String, let hoursType = HoursType(string: hoursTypeString), let isOpenNow = json["is_open_now"] as? Bool else { return  nil }
        
        self.type = hoursType
        self.isOpenNow = isOpenNow
        self.schedule = openHours.compactMap { BusinessHours.Schedule(json: $0) }
    }
}
