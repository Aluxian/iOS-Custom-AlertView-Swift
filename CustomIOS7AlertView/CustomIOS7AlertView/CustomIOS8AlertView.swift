//
//  CustomIOS8AlertView.swift
//  CustomIOS8AlertView
//  
//  Syntax changes to original file for IOS8
//
//  Created by Alexandru Rosianu on 23/08/14.
//  Modified by Mohammed Javed Jeewa on 06/08/15.
//  Copyright (c) 2014 Alexandru Rosianu. All rights reserved.
//

import UIKit

protocol CustomIOS8AlertViewDelegate: class {
    func customIOS8AlertViewButtonTouchUpInside(alertView: CustomIOS8AlertView, buttonIndex: Int)
}

class CustomIOS8AlertView: UIView {
    
    var buttonHeight: CGFloat = 50
    var buttonsDividerHeight: CGFloat = 1
    var cornerRadius: CGFloat = 7
    
    var useMotionEffects: Bool = true
    var motionEffectExtent: Int = 10
    
    private var alertView: UIView!
    var containerView: UIView!
    
    var buttonTitles: [String]? = ["Close"]
    var buttonColor: UIColor?
    var buttonColorHighlighted: UIColor?
    
    weak var delegate: CustomIOS8AlertViewDelegate?
    var onButtonTouchUpInside: ((alertView: CustomIOS8AlertView, buttonIndex: Int) -> Void)?
    
    init() {
        super.init(frame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.size.width, UIScreen.mainScreen().bounds.size.height))
        setObservers()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setObservers()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setObservers()
    }
    
    // Create the dialog view and animate its opening
    internal override func show() {
        show(nil)
    }
    
    internal func show(completion: ((Bool) -> Void)?) {
        alertView = createAlertView()
        
        self.layer.shouldRasterize = true
        self.layer.rasterizationScale = UIScreen.mainScreen().scale
        
        self.backgroundColor = UIColor(white: 0, alpha: 0)
        self.addSubview(alertView)
        
        // Attach to the top most window
        switch (UIApplication.sharedApplication().statusBarOrientation) {
        case UIInterfaceOrientation.LandscapeLeft:
            self.transform = CGAffineTransformMakeRotation(CGFloat(M_PI * 270 / 180))
            
        case UIInterfaceOrientation.LandscapeRight:
            self.transform = CGAffineTransformMakeRotation(CGFloat(M_PI * 90 / 180))
            
        case UIInterfaceOrientation.PortraitUpsideDown:
            self.transform = CGAffineTransformMakeRotation(CGFloat(M_PI * 180 / 180))
            
        default:
            break
        }
        
        self.frame = CGRectMake(0, 0, self.frame.width, self.frame.height)
        UIApplication.sharedApplication().windows.first?.addSubview(self)
        
        UIView.animateWithDuration(0.2, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
            self.backgroundColor = UIColor(white: 0, alpha: 0.4)
            self.alertView.layer.opacity = 1
            self.alertView.layer.transform = CATransform3DMakeScale(1, 1, 1)
            }, completion: completion)
    }
    
    // Close the alertView, remove views
    internal func close() {
        close(nil)
    }
    
    internal func close(completion: ((Bool) -> Void)?) {
        let currentTransform = alertView.layer.transform
        
        let startRotation = alertView.valueForKeyPath("layer.transform.rotation.z")?.floatValue
        let rotation = CATransform3DMakeRotation(CGFloat(-startRotation!) + CGFloat(M_PI * 270 / 180), 0, 0, 0)
        
        alertView.layer.transform = CATransform3DConcat(rotation, CATransform3DMakeScale(1, 1, 1))
        alertView.layer.opacity = 1
        
        UIView.animateWithDuration(0.2, delay: 0, options: UIViewAnimationOptions.TransitionNone, animations: {
            self.backgroundColor = UIColor(white: 0, alpha: 0)
            self.alertView.layer.transform = CATransform3DConcat(currentTransform, CATransform3DMakeScale(0.6, 0.6, 1))
            self.alertView.layer.opacity = 0
            }, completion: { (finished: Bool) in
                for view in self.subviews {
                    view.removeFromSuperview()
                }
                
                self.removeFromSuperview()
                completion?(finished)
        })
    }
    
    // Enables or disables the specified button
    // Should be used after the alert view is displayed
    internal func setButtonEnabled(enabled: Bool, buttonName: String) {
        for subview in alertView.subviews {
            if subview is UIButton {
                let button = subview as! UIButton
                
                if button.currentTitle == buttonName {
                    button.enabled = enabled
                    break
                }
            }
        }
    }
    
    // Observe orientation and keyboard changes
    private func setObservers() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "deviceOrientationDidChange:", name: UIDeviceOrientationDidChangeNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name:UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name:UIKeyboardWillHideNotification, object: nil)
    }
    
    // Create the containerView
    private func createAlertView() -> UIView {
        if containerView == nil {
            containerView = UIView(frame: CGRectMake(0, 0, 300, 150))
        }
        
        let screenSize = self.calculateScreenSize()
        let dialogSize = self.calculateDialogSize()
        
        let view = UIView(frame: CGRectMake(
            (screenSize.width - dialogSize.width) / 2,
            (screenSize.height - dialogSize.height) / 2,
            dialogSize.width,
            dialogSize.height
            ))
        
        // Style the alertView to match the IOS8 UIAlertView
        view.layer.insertSublayer(generateGradient(view.bounds), atIndex: 0)
        view.layer.cornerRadius = cornerRadius
        
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor(red: 198/255, green: 198/255, blue: 198/255, alpha:1).CGColor!
        
        view.layer.shadowRadius = cornerRadius + 5
        view.layer.shadowOpacity = 0.1
        view.layer.shadowColor = UIColor.blackColor().CGColor!
        view.layer.shadowOffset = CGSizeMake(0 - (cornerRadius + 5) / 2, 0 - (cornerRadius + 5) / 2)
        view.layer.shadowPath = UIBezierPath(roundedRect: view.bounds, cornerRadius: view.layer.cornerRadius).CGPath
        
        view.layer.opacity = 0.5
        view.layer.transform = CATransform3DMakeScale(1.3, 1.3, 1)
        
        view.layer.shouldRasterize = true
        view.layer.rasterizationScale = UIScreen.mainScreen().scale
        
        // Apply motion effects
        if useMotionEffects {
            applyMotionEffects(view)
        }
        
        // Add subviews
        view.addSubview(generateButtonsDivider(view.bounds))
        view.addSubview(containerView)
        self.addButtonsToView(view)
        
        return view
    }
    
    // Generate the view for the buttons divider
    private func generateButtonsDivider(bounds: CGRect) -> UIView {
        let divider = UIView(frame: CGRectMake(
            0,
            bounds.size.height - buttonHeight - buttonsDividerHeight,
            bounds.size.width,
            buttonsDividerHeight
            ))
        
        divider.backgroundColor = UIColor(red: 198/255, green: 198/255, blue: 198/255, alpha: 1)
        
        return divider
    }
    
    // Generate the gradient layer of the alertView
    private func generateGradient(bounds: CGRect) -> CAGradientLayer {
        let gradient = CAGradientLayer()
        
        gradient.frame = bounds
        gradient.cornerRadius = cornerRadius
        
        gradient.colors = [
            UIColor(red: 218/255, green: 218/255, blue: 218/255, alpha:1).CGColor!,
            UIColor(red: 233/255, green: 233/255, blue: 233/255, alpha:1).CGColor!,
            UIColor(red: 218/255, green: 218/255, blue: 218/255, alpha:1).CGColor!
        ]
        
        return gradient
    }
    
    // Add the buttons to the containerView
    private func addButtonsToView(container: UIView) {
        if buttonTitles == nil || buttonTitles?.count == 0 {
            return
        }
        
        let buttonWidth = container.bounds.size.width / CGFloat(buttonTitles!.count)
        
        for buttonIndex in 0...(buttonTitles!.count - 1) {
            let button = UIButton.buttonWithType(UIButtonType.Custom) as! UIButton
            
            button.frame = CGRectMake(
                CGFloat(buttonIndex) * CGFloat(buttonWidth),
                container.bounds.size.height - buttonHeight,
                buttonWidth,
                buttonHeight
            )
            
            button.tag = buttonIndex
            button.addTarget(self, action: "buttonTouchUpInside:", forControlEvents: UIControlEvents.TouchUpInside)
            
            let colorNormal = buttonColor != nil ? buttonColor : button.tintColor
            let colorHighlighted = buttonColorHighlighted != nil ? buttonColorHighlighted : colorNormal!.colorWithAlphaComponent(0.5)
            
            button.setTitle(buttonTitles![buttonIndex], forState: UIControlState.Normal)
            button.setTitleColor(colorNormal, forState: UIControlState.Normal)
            button.setTitleColor(colorHighlighted, forState: UIControlState.Highlighted)
            button.setTitleColor(colorHighlighted, forState: UIControlState.Disabled)
            
            container.addSubview(button)
            
            // Show a divider between buttons
            if buttonIndex > 0 {
                let verticalLineView = UIView(frame: CGRectMake(
                    container.bounds.size.width / CGFloat(buttonTitles!.count) * CGFloat(buttonIndex),
                    container.bounds.size.height - buttonHeight - buttonsDividerHeight,
                    buttonsDividerHeight,
                    buttonHeight
                    ))
                
                verticalLineView.backgroundColor = UIColor(red: 198/255, green: 198/255, blue: 198/255, alpha: 1)
                
                container.addSubview(verticalLineView)
            }
        }
    }
    
    // Calculate the size of the dialog
    private func calculateDialogSize() -> CGSize {
        return CGSizeMake(
            containerView.frame.size.width,
            containerView.frame.size.height + buttonHeight + buttonsDividerHeight
        )
    }
    
    // Calculate the size of the screen
    private func calculateScreenSize() -> CGSize {
        let width = UIScreen.mainScreen().bounds.width
        let height = UIScreen.mainScreen().bounds.height
        
        if orientationIsLandscape() {
            return CGSizeMake(height, width)
        } else {
            return CGSizeMake(width, height)
        }
    }
    
    // Add motion effects
    private func applyMotionEffects(view: UIView) {
        let horizontalEffect = UIInterpolatingMotionEffect(keyPath: "center.x", type: UIInterpolatingMotionEffectType.TiltAlongHorizontalAxis)
        horizontalEffect.minimumRelativeValue = -motionEffectExtent
        horizontalEffect.maximumRelativeValue = +motionEffectExtent
        
        let verticalEffect = UIInterpolatingMotionEffect(keyPath: "center.y", type: UIInterpolatingMotionEffectType.TiltAlongVerticalAxis)
        verticalEffect.minimumRelativeValue = -motionEffectExtent
        verticalEffect.maximumRelativeValue = +motionEffectExtent
        
        let motionEffectGroup = UIMotionEffectGroup()
        motionEffectGroup.motionEffects = [horizontalEffect, verticalEffect]
        
        view.addMotionEffect(motionEffectGroup)
    }
    
    // Whether the UI is in landscape mode
    private func orientationIsLandscape() -> Bool {
        return UIInterfaceOrientationIsLandscape(UIApplication.sharedApplication().statusBarOrientation)
    }
    
    // Call the delegates
    internal func buttonTouchUpInside(sender: UIButton!) {
        delegate?.customIOS8AlertViewButtonTouchUpInside(self, buttonIndex: sender.tag)
        onButtonTouchUpInside?(alertView: self, buttonIndex: sender.tag)
    }
    
    // Handle device orientation changes
    internal func deviceOrientationDidChange(notification: NSNotification) {
        let interfaceOrientation = UIApplication.sharedApplication().statusBarOrientation
        let startRotation = self.valueForKeyPath("layer.transform.rotation.z")?.floatValue
        
        var rotation: CGAffineTransform
        
        switch (interfaceOrientation) {
        case UIInterfaceOrientation.LandscapeLeft:
            rotation = CGAffineTransformMakeRotation(CGFloat(-startRotation!) + CGFloat(M_PI * 270 / 180))
            break
            
        case UIInterfaceOrientation.LandscapeRight:
            rotation = CGAffineTransformMakeRotation(CGFloat(-startRotation!) + CGFloat(M_PI * 90 / 180))
            break
            
        case UIInterfaceOrientation.PortraitUpsideDown:
            rotation = CGAffineTransformMakeRotation(CGFloat(-startRotation!) + CGFloat(M_PI * 180 / 180))
            break
            
        default:
            rotation = CGAffineTransformMakeRotation(CGFloat(-startRotation!) + 0)
            break
        }
        
        UIView.animateWithDuration(0.2, delay: 0, options: UIViewAnimationOptions.TransitionNone, animations: {
            self.alertView.transform = rotation
            }, completion: nil)
        
        // Fix errors caused by being rotated one too many times
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(0.5 * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), {
            let endInterfaceOrientation = UIApplication.sharedApplication().statusBarOrientation
            if interfaceOrientation != endInterfaceOrientation {
                // TODO: user moved phone again before than animation ended: rotation animation can introduce errors here
            }
        })
    }
    
    // Handle keyboard show changes
    internal func keyboardWillShow(notification: NSNotification) {
        let screenSize = self.calculateScreenSize()
        let dialogSize = self.calculateDialogSize()
        
        var keyboardSize = notification.userInfo![UIKeyboardFrameBeginUserInfoKey]!.CGRectValue().size
        
        if orientationIsLandscape() {
            keyboardSize = CGSize(width: keyboardSize.height, height: keyboardSize.width)
        }
        
        UIView.animateWithDuration(0.2, delay: 0, options: UIViewAnimationOptions.TransitionNone, animations: {
            self.alertView.frame = CGRectMake((
                screenSize.width - dialogSize.width) / 2,
                (screenSize.height - keyboardSize.height - dialogSize.height) / 2,
                dialogSize.width,
                dialogSize.height
            )
            }, completion: nil)
    }
    
    // Handle keyboard hide changes
    internal func keyboardWillHide(notification: NSNotification) {
        let screenSize = self.calculateScreenSize()
        let dialogSize = self.calculateDialogSize()
        
        UIView.animateWithDuration(0.2, delay: 0, options: UIViewAnimationOptions.TransitionNone, animations: {
            self.alertView.frame = CGRectMake(
                (screenSize.width - dialogSize.width) / 2,
                (screenSize.height - dialogSize.height) / 2,
                dialogSize.width,
                dialogSize.height
            )
            }, completion: nil)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIDeviceOrientationDidChangeNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
    }
    
}
