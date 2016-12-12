//
//  TouchAuthorizer.swift
//  Quadrat
//
//  Created by Constantine Fry on 12/11/14.
//  Copyright (c) 2014 Constantine Fry. All rights reserved.
//

import Foundation
import UIKit

class TouchAuthorizer : Authorizer {
    weak var presentingViewController: UIViewController?
    weak var delegate: SessionAuthorizationDelegate?
    var authorizationViewController: AuthorizationViewController?
    
    func authorize(_ viewController: UIViewController, delegate: SessionAuthorizationDelegate?,
        completionHandler: @escaping (String?, NSError?) -> Void) {
        
        authorizationViewController = AuthorizationViewController(authorizationURL: authorizationURL,
            redirectURL: redirectURL, delegate: self)
        authorizationViewController!.shouldControllNetworkActivityIndicator = shouldControllNetworkActivityIndicator

        let navigationController = AuthorizationNavigationController(rootViewController: authorizationViewController!)
        navigationController.modalPresentationStyle = .formSheet
        delegate?.sessionWillPresentAuthorizationViewController?(authorizationViewController!)
        viewController.present(navigationController, animated: true, completion: nil)
        
        self.presentingViewController = viewController
        self.completionHandler = completionHandler
        self.delegate = delegate
    }
    
    override func finilizeAuthorization(_ accessToken: String?, error: NSError?) {
        if authorizationViewController != nil {
            delegate?.sessionWillDismissAuthorizationViewController?(authorizationViewController!)
        }
        presentingViewController?.dismiss(animated: true) {
            self.didDismissViewController(accessToken, error: error)
            self.authorizationViewController = nil
        }
    }
    
    func didDismissViewController(_ accessToken: String?, error: NSError?) {
        super.finilizeAuthorization(accessToken, error: error)
    }
    
}
