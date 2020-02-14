//
//  PermissionsController.swift
//  RestaurantReviews
//
//  Created by Pasan Premaratne on 5/9/17.
//  Copyright © 2017 Treehouse. All rights reserved.
//

import UIKit
import CoreLocation

class PermissionsController: UIViewController, LocationPermissionsDelegate {
    lazy var locationManager: LocationManager = {
        return LocationManager(delegate: nil, permissionsDelegate: self)
    }()
    
    var isAuthorizedForLocation: Bool
    var delegate: YelpSearchControllerDelegate?
    
    lazy var locationPermissionButton:  UIButton = {
        let title = self.isAuthorizedForLocation ? "Location Permissions Granted" : "Request Location Permissions"
        let button = UIButton(type: .system)
        let controlState = self.isAuthorizedForLocation ? UIControl.State.disabled : UIControl.State.normal
        button.isEnabled = !self.isAuthorizedForLocation
        button.setTitle(title, for: controlState)
        button.addTarget(self, action: #selector(PermissionsController.requestLocationPermissions), for: .touchUpInside)
        
        
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor(red: 62/255.0, green: 71/255.0, blue: 79/255.0, alpha: 1.0)
        button.setTitleColor(UIColor(red: 178/255.0, green: 187/255.0, blue: 185/255.0, alpha: 1.0), for: .disabled)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 5
        button.clipsToBounds = true
        
        return button
    }()
    
    lazy var dismissButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Dismiss", for: .normal)
        button.tintColor = .white
        button.addTarget(self, action: #selector(PermissionsController.dismissPermissions), for: .touchUpInside)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init coder not implemented")
    }
    
    init(isAuthorizedForLocation authorized: Bool, delegate: YelpSearchControllerDelegate?) {
        self.isAuthorizedForLocation = authorized
        self.delegate = delegate
        super.init(nibName: nil, bundle: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 95/255.0, green: 207/255.0, blue: 128/255.0, alpha: 1.0)
    }
    

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        let stackView = UIStackView(arrangedSubviews: [locationPermissionButton])
        stackView.alignment = .center
        stackView.axis = .vertical
        stackView.distribution = .equalSpacing
        stackView.spacing = 16.0
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(stackView)
        view.addSubview(dismissButton)
        
        NSLayoutConstraint.activate([
            locationPermissionButton.heightAnchor.constraint(equalToConstant: 64.0),
            locationPermissionButton.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),
            locationPermissionButton.trailingAnchor.constraint(equalTo: stackView.trailingAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32.0),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32.0),
            dismissButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -16),
            dismissButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    @objc func requestLocationPermissions() {
        do {
            try locationManager.requestLocationAuthorization()
        } catch LocationError.disallowedByUser {
            showLocationPermissionDisallowedAlert()
            print("requestLocationPermissions: .disallowedByUser")
        } catch let error {
            print("Location Authorization Error: \(error.localizedDescription)")
        }
    }
    
    @objc func dismissPermissions() {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Location Permissions Delegate
    func authorizationSucceeded() {
        locationPermissionButton.setTitle("Location Permissions Granted", for: .disabled)
        locationPermissionButton.isEnabled = false
        delegate?.updateAuthorizationStatus()
        dismissAfterDelay(seconds: 2.0)
    }
    
    func dismissAfterDelay(seconds delay: Double) {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func authorizationFailed(_ status: CLAuthorizationStatus) {
        //showLocationPermissionDisallowedAlert()
        print("authorizationFailed()")
    }
    
    func showLocationPermissionDisallowedAlert() {
        let alertController = UIAlertController(title: "Location Sevices Denied!",
            message: "The location permission was not authorized. Please enable it in Settings to continue.",
            preferredStyle: .alert)
     
        let settingsAction = UIAlertAction(title: "Settings", style: .default) { (alertAction) in
     
            // THIS IS WHERE THE MAGIC HAPPENS!!!!
            if let appSettings = NSURL(string: UIApplication.openSettingsURLString) {
                //UIApplication.shared.openURL(appSettings as URL)
                UIApplication.shared.open(appSettings as URL, options: [:], completionHandler: nil)
            }
        }
        alertController.addAction(settingsAction)
     
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
     
        present(alertController, animated: true, completion: nil)
    }

}
