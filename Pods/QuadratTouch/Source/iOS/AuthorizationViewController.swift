//
//  AuthorizationViewController.swift
//  Quadrat
//
//  Created by Constantine Fry on 08/11/14.
//  Copyright (c) 2014 Constantine Fry. All rights reserved.
//

import Foundation
import UIKit

enum AuthorizationViewControllerRequestStatus  {
    case none               // View controller has been initialized.
    case loading            // Web view loading page.
    case loaded             // Page has been loaded successfully.
    case failed(NSError)    // Web view failed to load page with error.
}

/** 
    The class where AuthorizationViewController is pushed. It does nothing.
    You may use this class to apply you application style via UIAppearence.
*/
open class AuthorizationNavigationController: UINavigationController {
    
}

open class AuthorizationViewController : UIViewController, UIWebViewDelegate {
    fileprivate let authorizationURL    : URL
    fileprivate let redirectURL         : URL
    
    /**
        Whether view controller should controll network activity indicator or not.
        Should be set before presenting view controller.
    */
    internal var shouldControllNetworkActivityIndicator = false
    
    fileprivate var networkActivityIndicator    : NetworkActivityIndicatorController?
    fileprivate var activityIdentifier          : Int?
    
    weak internal var authorizationDelegate : AuthorizationDelegate?
    
    @IBOutlet open weak var webView       : UIWebView!
    
    @IBOutlet fileprivate weak var statusLabel  : UILabel!
    @IBOutlet fileprivate weak var indicator    : UIActivityIndicatorView!
    
    fileprivate var status : AuthorizationViewControllerRequestStatus = .none {
        didSet {
            self.updateUI()
        }
    }
    
    // MARK: -
    
    init(authorizationURL: URL, redirectURL: URL, delegate: AuthorizationDelegate) {
        self.authorizationURL = authorizationURL
        self.redirectURL = redirectURL
        self.authorizationDelegate = delegate
        let bundle = Bundle(for: AuthorizationViewController.self)
        super.init(nibName: "AuthorizationViewController", bundle: bundle)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        webView.scrollView.showsVerticalScrollIndicator = false
        
        let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel,
            target: self, action: #selector(AuthorizationViewController.cancelButtonTapped))
        self.navigationItem.leftBarButtonItem = cancelButton
        if shouldControllNetworkActivityIndicator {
            networkActivityIndicator = NetworkActivityIndicatorController()
        }
        self.loadAuthorizationPage()
    }
    
    // MARK: - Actions
    
    @objc func loadAuthorizationPage() {
        self.status = .loading
        let request = URLRequest(url: self.authorizationURL)
        self.webView.loadRequest(request)
    }
    
    @objc func cancelButtonTapped() {
        self.authorizationDelegate?.userDidCancel()
    }
    
    // MARK: - Web view delegate methods
    
    open func webView(_ webView: UIWebView, shouldStartLoadWith
        request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
            if let URLString = request.url?.absoluteString {
                if URLString.hasPrefix(self.redirectURL.absoluteString) {
                    // If we've reached redirect URL we should let know delegate.
                    self.authorizationDelegate?.didReachRedirectURL(request.url!)
                    return false
                }
            }
            return true
    }
    
    open func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        if let error = error {
            if error.domain == "WebKitErrorDomain" && error.code == 102 {
                // URL loading was interrupted. It happens when one taps "download Foursquare to sign up!".
                return
            }
            self.status = .failed(error)
        }
    }
    
    open func webViewDidFinishLoad(_ webView: UIWebView) {
        self.status = .loaded
    }
    
    // MARK: -
    
    /** Updates UI to current status. */
    func updateUI() {
        switch (self.status) {
            
        case .loading:
            // Show activity indicator, hide web view and status label.
            networkActivityIndicator?.endNetworkActivity(activityIdentifier)
            activityIdentifier = networkActivityIndicator?.beginNetworkActivity()
            indicator.startAnimating()
            indicator.alpha = 1.0
            self.webView.alpha = 0.0
            self.statusLabel.isHidden = true
            
        case .loaded:
            // Show web view, hide activity indicator and status label.
            networkActivityIndicator?.endNetworkActivity(activityIdentifier)
            
            self.statusLabel.isHidden = true
            if self.webView.alpha == 0.0 {
                UIView.animate(withDuration: 0.2, animations: {
                    self.indicator.alpha = 0.0
                    self.webView.alpha = 1.0
                    }, completion: { (finished) -> Void in
                        self.indicator.alpha = 1.0
                        self.indicator.stopAnimating()
                })
            }
            
        case .failed(let error):
            // Show refresh button and status label. Hide web view.
            networkActivityIndicator?.endNetworkActivity(activityIdentifier)
            
            self.statusLabel.text = error.localizedDescription
            self.indicator.stopAnimating()
            self.webView.alpha = 0.0
            self.statusLabel.isHidden = false
            
            
        case .none:
            // Hide everynthing.
            networkActivityIndicator?.endNetworkActivity(activityIdentifier)
            
            self.indicator.stopAnimating()
            self.webView.alpha = 0.0
            self.statusLabel.isHidden = true
        }
    }
    
}
