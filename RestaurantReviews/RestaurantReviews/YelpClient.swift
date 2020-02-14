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
    
    /// Returns list of YelpBusiness from search bar requests.
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
    
    /// Returns a new instance of a YelpBusiness
    func businessWithId(_ id: String, completion: @escaping (Result<YelpBusiness, APIError>) -> Void) {
        let endpoint = Yelp.business(id: id)
        let request = endpoint.request
        fetch(with: request, parse: { json -> YelpBusiness? in
            return YelpBusiness(json: json)
        }, completion: completion)
    }
    
    /// Updates an existing instance of YelpBusiness with hours and photos.
    func updateWithHoursAndPhotos(_ business: YelpBusiness,
                                  completion: @escaping (Result<YelpBusiness, APIError>) -> Void) {
        let endpoint = Yelp.business(id: business.id)
        let request = endpoint.request
        
        fetch(with: request, parse: { json -> YelpBusiness? in
            business.updateWithHoursAndPhotos(json: json)
            return business
        }, completion: completion)
    }
    
    /// Returns list of YelpReview for business.
    func reviews(for business: YelpBusiness, completion: @escaping (Result<[YelpReview], APIError>) -> Void) {
        let endpoint = Yelp.reviews(businessId: business.id)
        let request = endpoint.request
        
        fetch(with: request, parse: { json -> [YelpReview] in
            guard let reviews = json["reviews"] as? [[String: Any]] else { return [] }
            return reviews.compactMap { YelpReview(json: $0) }
        }, completion: completion)
    }
    
}
