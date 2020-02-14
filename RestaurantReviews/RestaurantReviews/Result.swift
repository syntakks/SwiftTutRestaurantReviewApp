//
//  Result.swift
//  RestaurantReviews
//
//  Created by Stephen Wall on 2/13/20.
//  Copyright © 2020 syntaks.io. All rights reserved.
//

import Foundation

enum Result<T, U> where U: Error {
    case success(T)
    case failure(U)
}
