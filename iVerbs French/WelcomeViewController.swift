//
//  WelcomeViewController.swift
//  iVerbs
//
//  Created by Brad Reed on 19/10/2015.
//  Copyright © 2015 Brad Reed. All rights reserved.
//

import UIKit
import TKSubmitTransition

// First view shown to users when the install the app
class WelcomeViewController: UIViewController, UIViewControllerTransitioningDelegate {
    
    // 'Get Started' button
    @IBOutlet weak var btnDownloadLang: TKTransitionSubmitButton!
    
    // Called when the view loads, before it appears on screen
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the corner radius (rounded corners) for the 'Get Started' button
        btnDownloadLang.normalCornerRadius = btnDownloadLang.frame.size.height / 2
        
    }
    
    // MARK: Button
    
    // Prevent the user from tapping the button while it is loaded
    func disableButton() {
        btnDownloadLang.removeTarget(self, action: #selector(WelcomeViewController.didClickGo(_:)), for: .touchUpInside)
    }
    
    // Re-enable the button
    func enableButton() {
        btnDownloadLang.addTarget(self, action: #selector(WelcomeViewController.didClickGo(_:)), for: .touchUpInside)
    }
    
    // Called when the button is tapped
    @IBAction func didClickGo(_ button: TKTransitionSubmitButton) {
        // Prevent double-tapping the button
        disableButton()
        
        // Animate the button
        button.startLoadingAnimation()
        
        // Get available languages from API
        LanguageManager.cacheAvailableLanguages() { error in
            
            // Do UI stuff on main thread
            DispatchQueue.main.async {
                
                // If there was an error we don't animate to the language selection view
                if error != nil {
                    print("Error fetching language list: ", error!)
                    // Show API error to user
                    
                    let title = "API Error"
                    var subTitle = error!.localizedDescription
                    
//                    let recovery = error!.localizedRecoverySuggestion != nil
//                        ? error!.localizedRecoverySuggestion!
//                        : "Please check your Internet connection and try again"
                    let recovery = "Please check your Internet connection and try again"
                    
                    subTitle += "\n" + recovery

                    iVerbs.displayError(title, message: subTitle)
                    
                    // Set the button back to its original state
                    // and re-enable tap events
                    button.setOriginalState()
                    self.enableButton()
                } else {
                    // Transition to language selection view
                    button.startFinishAnimation(0) {
                        
                        // The language list controller is after the navigationcontroller
                        let secondVC = UIStoryboard(name: "FirstLaunch", bundle: nil)
                            .instantiateViewController(withIdentifier: "firstNavigationController") as! UINavigationController
                        
                        // View transition: assign WelcomeViewController
                        // as transitioning delegate for the animation
                        secondVC.transitioningDelegate = self
                        
                        // Transition to new view
                        self.present(secondVC, animated: true, completion: nil)
                    }
                }
            }
        }
    }
    
    // MARK: UIViewControllerTransitioningDelegate
    
    // Get the instance of the animation controller for the transition
    // (Provided by TKFadeInAnimator CocoaPods package - https://github.com/entotsu/TKSubmitTransition
    func animationController(
        forPresented presented: UIViewController,
        presenting: UIViewController,
        source: UIViewController
        ) -> UIViewControllerAnimatedTransitioning? {
            
        return TKFadeInAnimator(
            transitionDuration: 0.5, // How long the transition takes
            startingAlpha: 0.8) // The opacity of the button as it grows into the new view
    }
    
}
