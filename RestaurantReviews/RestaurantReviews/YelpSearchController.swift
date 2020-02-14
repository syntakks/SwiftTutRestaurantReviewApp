//
//  YelpSearchController.swift
//  RestaurantReviews
//
//  Created by Pasan Premaratne on 5/9/17.
//  Copyright © 2017 Treehouse. All rights reserved.
//

import UIKit

/// This will pass back a success status from the initial Permission Controller. Then it kicks off the initial location fix and coordinate and automatic nearby search.
protocol YelpSearchControllerDelegate {
    func updateAuthorizationStatus()
}

class YelpSearchController: UIViewController, YelpSearchControllerDelegate {
    
    // MARK: - Properties
    let searchController = UISearchController(searchResultsController: nil)
    @IBOutlet weak var tableView: UITableView!
    
    let dataSource = YelpSearchResultsDataSource()
    
    lazy var client: YelpClient = {
          return YelpClient()
    }()
    
    let queue = OperationQueue()
    
    lazy var locationManager: LocationManager = {
        return LocationManager(delegate: self, permissionsDelegate: nil)
    }()
    
    var coordinate: Coordinate? {
        didSet {
            if let coordinate = coordinate {
                showNearbyRestaurants(at: coordinate)
            }
        }
    }
    
    var isAuthorized: Bool {
        return LocationManager.isAuthorized
    }
    
    func updateAuthorizationStatus() {
        if LocationManager.isAuthorized {
            locationManager.requestLocation()
        }
    }
// MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSearchBar()
        setupTableView()
        
        addObserver(self, forKeyPath: #keyPath(YelpBusinessDetailsOperation.isFinished), options: [.new, .old], context: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if isAuthorized {
            // Trying to prevent multiple location calls.
            guard let _ = coordinate else {
                locationManager.requestLocation()
                return
            }
        } else {
            checkPermissions()
        }
    }
    
    // MARK: - Table View
    func setupTableView() {
        self.tableView.dataSource = dataSource
        self.tableView.delegate = self
    }
    
    func showNearbyRestaurants(at coordinate: Coordinate) {
        client.search(withTerm: "", at: coordinate) { [weak self] result in
            switch result {
            case .success(let businesses):
                self?.dataSource.update(with: businesses)
                self?.tableView.reloadData()
            case .failure(let error):
                print(error)
            }
        }
    }
    
    // MARK: - Search
    
    func setupSearchBar() {
        self.navigationItem.titleView = searchController.searchBar
        
        searchController.dimsBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchResultsUpdater = self
    }
    
    // MARK: - Permissions
    
    /// Checks (1) if the user is authenticated against the Yelp API and has an OAuth
    /// token and (2) if the user has authorized location access for whenInUse tracking.
    func checkPermissions() {
        let isAuthorizedForLocation = LocationManager.isAuthorized
        let permissionsController = PermissionsController(isAuthorizedForLocation: isAuthorizedForLocation, delegate: self)
        present(permissionsController, animated: true, completion: nil)
    }
}

// MARK: - UITableViewDelegate
extension YelpSearchController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let business = dataSource.object(at: indexPath)
        // Use the operation to update the business object before performing the segue to the business details.
        let operation = YelpBusinessDetailsOperation(business: business, client: self.client)
        operation.completionBlock = {
            DispatchQueue.main.async {
                self.dataSource.update(business, at: indexPath)
                self.performSegue(withIdentifier: "showBusiness", sender: nil)
            }
        }
        queue.addOperation(operation)
    }
}

// MARK: - Search Results
extension YelpSearchController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchTerm = searchController.searchBar.text,
        let coordinate = coordinate else { return }
        print("Search text: \(searchTerm)")
        
        if !searchTerm.isEmpty {
            client.search(withTerm: searchTerm, at: coordinate) { [weak self] result in
                switch result {
                case .success(let businesses):
                    self?.dataSource.update(with: businesses)
                    self?.tableView.reloadData()
                case .failure(let error):
                    print(error)
                }
            }
        }
        
    }
}

// MARK: - Navigation
extension YelpSearchController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showBusiness" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let business = dataSource.object(at: indexPath)
                
                let detailController = segue.destination as! YelpBusinessDetailController
                detailController.business = business
            }
        }
    }
}

// MARK: - Location Manager Delegate
extension YelpSearchController: LocationManagerDelegate {
    func obtainedCoordinates(_ coordinate: Coordinate) {
        self.coordinate = coordinate
        print(coordinate)
    }
    
    func failedWithError(_ error: LocationError) {
        print("Yelp Search Controller: \(error.localizedDescription)")
    }
}

// MARK: - KVO - Key Value Observer
extension YelpSearchController {
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        print("keyPath: \(String(describing: keyPath))")
        print("object: \(String(describing: object))")
        print("change: \(String(describing: change))")
        print("context: \(String(describing: context))")
    }
}
