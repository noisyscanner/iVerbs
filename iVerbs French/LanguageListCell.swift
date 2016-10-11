//
//  LanguageListCell.swift
//  iVerbs
//
//  Created by Brad Reed on 28/01/2016.
//  Copyright © 2016 Brad Reed. All rights reserved.
//

import UIKit
import NightNight

/**
 * Table View Cell in the Language List
 */
class LanguageListCell: iVerbsTintedCell {
    
    // The state of the cell
    enum State {
        
        // Empty cell (default case for cells that fail to initialise properly)
        case empty
        
        // Language not installed.
        // Display an update button and no update label
        case notInstalled

        // Language is installed, but has no update.
        // Show no update button or update label
        case installed
        
        // Language is installed and there is an update available
        // Show 'update available' label and an update button
        case hasUpdate
    }
    
    @IBOutlet weak var lblLanguage: UILabel! // Label displaying language name
    @IBOutlet weak var lblUpdate: UILabel! // Label displaying the 'update available' notification, or nothing
    @IBOutlet weak var btnUpdate: UIButton! // Update/Download button
    
    override func awakeFromNib() {
        lblLanguage.mixedTextColor = MixedColor(normal: UIColor.darkText, night: UIColor.white)
    }
    
    // Language instance, or nil or the cell has not been initialised yet
    var language: Language? {
        didSet {
            self.lblLanguage.text = language!.label // Language and emoji flag
            if !language!.installed {
                self.selectedBackgroundView?.backgroundColor = UIColor.white
                self.textLabel?.highlightedTextColor = UIColor.black
            }
            updateCell()
        }
    }
    
    // Getter for the state for the cell
    var state: State {
        if language != nil {
            // Cell is initialised
            
            if language!.installed {
                // Language is installed
                // If it has an update, return .HasUpdate, otherwise .Installed
                return language!.hasUpdate ? .hasUpdate : .installed
            } else {
                // Language not installed
                return .notInstalled
            }
            
        } else {
            // language is nil, cell not initialised yet
            return .empty
        }
    }
    
    func updateCell() {
        // If language is installed:
        //   If language has update:
        //     Show update button and label
        //   Else:
        //     Hide update button and label
        // Else:
        //   Show download button, hide label
        
        
        switch state {
        case .hasUpdate:
            // Get date from Unix timestamp
            let date = Date(timeIntervalSince1970: Double(language!.latestVersion))

            // Format date as string using NSDateFormatter
            let formatter = DateFormatter()
            formatter.dateFormat = "dd/MM/yy"
            let dateString = formatter.string(from: date)
            
            // Set button and label text
            lblUpdate?.text = "Update Available: " + dateString
            btnUpdate.setTitle("⬆️", for: UIControlState())
            
            // Show the button and update label
            btnUpdate.showView()
            lblUpdate.showView()
            
        case .installed, .empty:
            // Hide the update button and label
            btnUpdate.hideView()
            lblUpdate.hideView()
            
        case .notInstalled:
            // Language not installed.
            // It is available for download
            
            // Set button title
            btnUpdate.setTitle("⬇️", for: UIControlState())
            
            // Show the update button but hide the update label
            btnUpdate.showView()
            lblUpdate.hideView()
        }
    }
    
    // Start the loading indicator for the cell
    func startAnimatingRow() {
        // Update UI on main thread
        DispatchQueue.main.async {
            let loadingIndicator = UIActivityIndicatorView()
            loadingIndicator.hidesWhenStopped = true
            loadingIndicator.activityIndicatorViewStyle = .gray
            loadingIndicator.startAnimating()
            
            self.accessoryView = loadingIndicator
        }
    }
    
    // Stop the loading indicator for the cell
    func stopAnimatingRow() {
        // Update UI on main thread
        DispatchQueue.main.async {
            self.accessoryView = nil
            self.accessoryType = .none
        }
    }
}
