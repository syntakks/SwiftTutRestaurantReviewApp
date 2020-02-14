//
//  YelpBusinessDetailViewModel.swift
//  RestaurantReviews
//
//  Created by Pasan Premaratne on 5/9/17.
//  Copyright © 2017 Treehouse. All rights reserved.
//

import Foundation

struct YelpBusinessDetailViewModel {
    let restaurantName: String
    let price: String
    let rating: Double
    let ratingsCount: String
    let categories: String
    let hours: String
    let currentStatus: String
}

extension YelpBusinessDetailViewModel {
    init?(business: YelpBusiness) {
        self.restaurantName = business.name
        self.price = business.price
        self.rating = business.rating
        self.ratingsCount = "(\(business.reviewCount.description))"
        
        self.categories = business.categories.map({ $0.title }).joined(separator: ", ")
        
        guard let hours = business.hours else { return nil }
        
//        for day in hours.schedule {
//            print(day.day)
//        }
        
        let currentDayValue = Date.stupidlyIndexedCurrentDate
        
        let today = hours.schedule.first {
            return $0.day.rawValue == currentDayValue
        }
        
        print(today?.start)
        
        let startString: String
        let endString: String
        
        if let today = today {
            startString = DateFormatter.stringFromDateString(today.start, withInputDateFormat: "HHmm")
            endString = DateFormatter.stringFromDateString(today.end, withInputDateFormat: "HHmm")
        } else {
            startString = "--"
            endString = "--"
        }
        
        self.hours = "Hours Today: \(startString) - \(endString)"
        self.currentStatus = hours.isOpenNow ? "Open" : "Closed"
    }
}

extension DateFormatter {
    static func stringFromDateString(_ inputString: String, withInputDateFormat format: String) -> String {
        let formatter = DateFormatter()
        let locale = Locale.current
        formatter.locale = locale
        
        formatter.dateFormat = format
        
        let date = formatter.date(from: inputString)!
        
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        
        return formatter.string(from: date)
    }
}

extension Date {
    static var stupidlyIndexedCurrentDate: Int {
        let date = Date()
        let calendar = Calendar.current
        let day = calendar.component(.weekday, from: date)
        
        let bullshitDayValue: Int
        
        switch day {
        case 1: bullshitDayValue = 7
        case 2: bullshitDayValue = 0
        case 3: bullshitDayValue = 1
        case 4: bullshitDayValue = 2
        case 5: bullshitDayValue = 3
        case 6: bullshitDayValue = 4
        case 7: bullshitDayValue = 5
        default: bullshitDayValue = 0
        }
        return bullshitDayValue
    }
}
