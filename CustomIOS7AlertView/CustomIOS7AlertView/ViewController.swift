//
//  ViewController.swift
//  CustomIOS7AlertView
//
//  Created by Alexandru Rosianu on 23/08/14.
//  Copyright (c) 2014 Alexandru Rosianu. All rights reserved.
//

import UIKit

class ViewController: UIViewController, CustomIOS7AlertViewDelegate {
    
    @IBOutlet weak var launchAlertViewButton: UIButton!
    
    // The buttons that will appear in the alertView
    let buttons = [
        "Cancel",
        "OK"
    ]
                            
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Style the 'Launch AlertView' button a but
        launchAlertViewButton.layer.cornerRadius = 5
        launchAlertViewButton.layer.borderWidth = 1
        launchAlertViewButton.layer.borderColor = launchAlertViewButton.tintColor.CGColor!
    }
    
    @IBAction func launchAlertView() {
        // Create a new AlertView instance
        let alertView = CustomIOS7AlertView()
        
        // Set the button titles array
        alertView.buttonTitles = buttons
        
        // Set a custom container view
        alertView.containerView = createContainerView()
        
        // Set self as the delegate
        alertView.delegate = self
        
        // Or, use a closure
        alertView.onButtonTouchUpInside = { (alertView: CustomIOS7AlertView, buttonIndex: Int) -> Void in
            println("CLOSURE: Button '\(self.buttons[buttonIndex])' touched")
        }
        
        // Show time!
        alertView.show()
    }
    
    // Handle button touches
    func customIOS7AlertViewButtonTouchUpInside(alertView: CustomIOS7AlertView, buttonIndex: Int) {
        println("DELEGATE: Button '\(buttons[buttonIndex])' touched")
        alertView.close()
    }
    
    // Create a custom container view
    func createContainerView() -> UIView {
        let containerView = UIView(frame: CGRectMake(0, 0, 290, 150))
        
        let sampleLabel = UILabel(frame: CGRectMake(0, 0, containerView.frame.width, 30))
        sampleLabel.center = CGPoint(x: containerView.frame.width / 2, y: containerView.frame.height / 2)
        sampleLabel.textAlignment = NSTextAlignment.Center
        sampleLabel.text = "Hello, AlertView!"
        
        containerView.addSubview(sampleLabel)
        return containerView
    }

}
