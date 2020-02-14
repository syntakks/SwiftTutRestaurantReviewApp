//
//  YelpBusinessDetailsOperation.swift
//  RestaurantReviews
//
//  Created by Stephen Wall on 2/14/20.
//  Copyright © 2020 syntaks.io. All rights reserved.
//

import Foundation

/// The objective of this operation is to:
/// 1.) Fetch the details for a given business
/// 2.) Update that instance with new data
/// 3.) Notify when the operation is completed.
class YelpBusinessDetailsOperation: Operation {
    let business: YelpBusiness
    let client: YelpClient
    
    init(business: YelpBusiness, client: YelpClient) {
        self.business = business
        self.client = client
        super.init()
    }
    
    override var isAsynchronous: Bool {
        return true
    }
    
    //KVO - Key Value Observing 
    
    private var _finished = false // Called a backing property. Prevent infinite loop problem.
    // This makes the setter private
    override private(set) var isFinished: Bool {
        get {
            return _finished
        }
        set {
            // Notify any observers about value modification.
            willChangeValue(forKey: "isFinished")
            _finished = newValue
            didChangeValue(forKey: "isFinished")
        }
    }
    
    private var _executing = false // Called a backing property. Prevent infinite loop problem.
    // This makes the setter private
    override private(set) var isExecuting: Bool {
        get {
            return _executing
        }
        set {
            // Notify any observers about value modification.
            willChangeValue(forKey: "isExecuting")
            _executing = newValue
            didChangeValue(forKey: "isExecuting")
        }
    }
    
    // Controls the state and calls main()
    override func start() {
        if isCancelled {
            isFinished = true
            return
        }
        
        isExecuting = true
        
        client.updateWithHoursAndPhotos(self.business) { [unowned self] result in
            switch result {
            case .success(_):
                self.isExecuting = false
                self.isFinished = true
            case .failure(let error):
                print(error)
                self.isExecuting = false
                self.isFinished = true
            }
        }
    }
    
}
