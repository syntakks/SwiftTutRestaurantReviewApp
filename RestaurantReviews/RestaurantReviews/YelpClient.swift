//
//  YelpClient.swift
//  RestaurantReviews
//
//  Created by Stephen Wall on 2/13/20.
//  Copyright © 2020 syntaks.io. All rights reserved.
//

import Foundation

class YelpClient: APIClient {
    let session: URLSession
    
    init(configuration: URLSessionConfiguration) {
        self.session = URLSession(configuration: configuration)
    }
    
    convenience init() {
        self.init(configuration: .default)
    }
    
    func search(withTerm term: String,
                at coordinate: Coordinate,
                categories: [YelpCategory] = [],
                radius: Int? = nil, limit: Int = 50,
                sortBy sortType: Yelp.YelpSortType = .rating,
                completion: @escaping (Result<[YelpBusiness], APIError>) -> Void) {
        
        let endpoint = Yelp.search(term: term, coordinate: coordinate, radius: radius, categories: categories, limit: limit, sortBy: sortType)
        
        let request = endpoint.request
        
        fetch(with: request, parse: { json -> [YelpBusiness] in
            guard let businesses = json["businesses"] as? [[String: Any]] else { return [] }
            return businesses.compactMap { YelpBusiness(json: $0) }
        }, completion: completion)
    }
    
}
