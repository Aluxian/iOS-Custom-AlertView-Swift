//
//  CustomIOS7AlertView.swift
//  CustomIOS7AlertView
//
//  Created by Alexandru Rosianu on 23/08/14.
//  Copyright (c) 2014 Alexandru Rosianu. All rights reserved.
//

import UIKit

protocol CustomIOS7AlertViewDelegate: class {
    func customIOS7AlertViewButtonTouchUpInside(alertView: CustomIOS7AlertView, buttonIndex: Int)
}

class CustomIOS7AlertView: UIView {
    
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
    
    weak var delegate: CustomIOS7AlertViewDelegate?
    var onButtonTouchUpInside: ((_ alertView: CustomIOS7AlertView, _ buttonIndex: Int) -> Void)?
    
    init() {
        super.init(frame: CGRect(x: 0, y: 0,width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height))
        setObservers()
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setObservers()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        setObservers()
    }
    
    // Create the dialog view and animate its opening
    internal func show() {
        show(completion: nil)
    }
    
    internal func show(completion: ((Bool) -> Void)?) {
        alertView = createAlertView()
        
        self.layer.shouldRasterize = true
        self.layer.rasterizationScale = UIScreen.main.scale
        
        self.backgroundColor = UIColor(white: 0, alpha: 0)
        self.addSubview(alertView)
        
        // Attach to the top most window
        switch (UIApplication.shared.statusBarOrientation) {
        case UIInterfaceOrientation.landscapeLeft:
            self.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi * 270 / 180))
            
        case UIInterfaceOrientation.landscapeRight:
            self.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi * 90 / 180))
            
        case UIInterfaceOrientation.portraitUpsideDown:
            self.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi * 180 / 180))
            
        default:
            break
        }
        
        self.frame = CGRect(x:0, y:0, width: self.frame.width, height: self.frame.height)
        UIApplication.shared.windows.first?.addSubview(self)
        
        UIView.animate(withDuration: 0.2, delay: 0, options: UIViewAnimationOptions.curveEaseInOut, animations: {
            self.backgroundColor = UIColor(white: 0, alpha: 0.4)
            self.alertView.layer.opacity = 1
            self.alertView.layer.transform = CATransform3DMakeScale(1, 1, 1)
        }, completion: completion)
    }
    
    // Close the alertView, remove views
    internal func close() {
        close(completion: nil)
    }
    
    internal func close(completion: ((Bool) -> Void)?) {
        let currentTransform = alertView.layer.transform
        
        let startRotation = alertView.value(forKeyPath: "layer.transform.rotation.z") as! Float
        let rotation = CATransform3DMakeRotation(CGFloat(-startRotation) + CGFloat(Double.pi * 270 / 180), 0, 0, 0)
        
        alertView.layer.transform = CATransform3DConcat(rotation, CATransform3DMakeScale(1, 1, 1))
        alertView.layer.opacity = 1
        
        UIView.animate(withDuration: 0.2, delay: 0, options: UIViewAnimationOptions() , animations: {
            self.backgroundColor = UIColor(white: 0, alpha: 0)
            self.alertView.layer.transform = CATransform3DConcat(currentTransform, CATransform3DMakeScale(0.6, 0.6, 1))
            self.alertView.layer.opacity = 0
        }, completion: { (finished: Bool) in
            for view in self.subviews as [UIView] {
                view.removeFromSuperview()
            }
            
            self.removeFromSuperview()
            completion?(finished)
        })
    }
    
    // Enables or disables the specified button
    // Should be used after the alert view is displayed
    internal func setButtonEnabled(enabled: Bool, buttonName: String) {
        for subview in alertView.subviews as [UIView] {
            if subview is UIButton {
                let button = subview as! UIButton
                
                if button.currentTitle == buttonName {
                    button.isEnabled = enabled
                    break
                }
            }
        }
    }
    
    // Observe orientation and keyboard changes
    private func setObservers() {
        NotificationCenter.default.addObserver(self, selector:#selector(deviceOrientationDidChange(notification:)) , name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
        NotificationCenter.default.addObserver(self, selector:#selector(keyboardWillShow(notification:)), name:NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector:#selector(keyboardWillHide(notification:)), name:NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    // Create the containerView
    private func createAlertView() -> UIView {
        if containerView == nil {
            containerView = UIView(frame: CGRect(x: 0, y: 0, width: 300, height: 150))
        }
        
        let screenSize = self.calculateScreenSize()
        let dialogSize = self.calculateDialogSize()
        
        let view = UIView(frame: CGRect(
            x: (screenSize.width - dialogSize.width) / 2,
            y: (screenSize.height - dialogSize.height) / 2,
            width: dialogSize.width,
            height: dialogSize.height ))
        
        // Style the alertView to match the iOS7 UIAlertView
        view.layer.insertSublayer(generateGradient(bounds: view.bounds), at: 0)
        view.layer.cornerRadius = cornerRadius
        
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor(red: 198/255, green: 198/255, blue: 198/255, alpha:1).cgColor
        
        view.layer.shadowRadius = cornerRadius + 5
        view.layer.shadowOpacity = 0.1
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0 - (cornerRadius + 5) / 2, height: 0 - (cornerRadius + 5) / 2)
        view.layer.shadowPath = UIBezierPath(roundedRect: view.bounds, cornerRadius: view.layer.cornerRadius).cgPath
        
        view.layer.opacity = 0.5
        view.layer.transform = CATransform3DMakeScale(1.3, 1.3, 1)
        
        view.layer.shouldRasterize = true
        view.layer.rasterizationScale = UIScreen.main.scale
        
        // Apply motion effects
        if useMotionEffects {
            applyMotionEffects(view: view)
        }
        
        // Add subviews
        view.addSubview(generateButtonsDivider(bounds: view.bounds))
        view.addSubview(containerView)
        self.addButtonsToView(container: view)
        
        return view
    }
    
    // Generate the view for the buttons divider
    private func generateButtonsDivider(bounds: CGRect) -> UIView {
        let divider = UIView(frame: CGRect(
            x: 0,
            y: bounds.size.height - buttonHeight - buttonsDividerHeight,
            width: bounds.size.width,
            height: buttonsDividerHeight
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
            UIColor(red: 218/255, green: 218/255, blue: 218/255, alpha:1).cgColor,
            UIColor(red: 233/255, green: 233/255, blue: 233/255, alpha:1).cgColor,
            UIColor(red: 218/255, green: 218/255, blue: 218/255, alpha:1).cgColor
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
            let button = UIButton(type: UIButtonType.custom) as UIButton
            
            button.frame = CGRect(
                x: CGFloat(buttonIndex) * CGFloat(buttonWidth),
                y: container.bounds.size.height - buttonHeight,
                width: buttonWidth,
                height: buttonHeight
            )
            
            button.tag = buttonIndex
            //            button.addTarget(self, action: Selector(("buttonTouchUpInside:")), for: UIControlEvents.touchUpInside)
            
            button.addTarget(self, action: #selector(buttonTouchUpInside(sender:)), for: UIControlEvents.touchUpInside)
            
            let colorNormal = buttonColor != nil ? buttonColor : button.tintColor
            let colorHighlighted = buttonColorHighlighted != nil ? buttonColorHighlighted : colorNormal?.withAlphaComponent(0.5)
            
            button.setTitle(buttonTitles![buttonIndex], for: UIControlState.normal)
            button.setTitleColor(colorNormal, for: UIControlState.normal)
            button.setTitleColor(colorHighlighted, for: UIControlState.highlighted)
            button.setTitleColor(colorHighlighted, for: UIControlState.disabled)
            
            container.addSubview(button)
            
            // Show a divider between buttons
            if buttonIndex > 0 {
                let verticalLineView = UIView(frame: CGRect(
                    x: container.bounds.size.width / CGFloat(buttonTitles!.count) * CGFloat(buttonIndex),
                    y: container.bounds.size.height - buttonHeight - buttonsDividerHeight,
                    width: buttonsDividerHeight,
                    height: buttonHeight
                ))
                
                verticalLineView.backgroundColor = UIColor(red: 198/255, green: 198/255, blue: 198/255, alpha: 1)
                
                container.addSubview(verticalLineView)
            }
        }
    }
    
    // Calculate the size of the dialog
    private func calculateDialogSize() -> CGSize {
        return CGSize(
            width: containerView.frame.size.width,
            height: containerView.frame.size.height + buttonHeight + buttonsDividerHeight
        )
    }
    
    // Calculate the size of the screen
    private func calculateScreenSize() -> CGSize {
        let width = UIScreen.main.bounds.width
        let height = UIScreen.main.bounds.height
        
        if orientationIsLandscape() {
            return CGSize(width: height, height: width)
        } else {
            return CGSize(width: width, height: height)
        }
    }
    
    // Add motion effects
    private func applyMotionEffects(view: UIView) {
        let horizontalEffect = UIInterpolatingMotionEffect(keyPath: "center.x", type: UIInterpolatingMotionEffectType.tiltAlongHorizontalAxis)
        horizontalEffect.minimumRelativeValue = -motionEffectExtent
        horizontalEffect.maximumRelativeValue = +motionEffectExtent
        
        let verticalEffect = UIInterpolatingMotionEffect(keyPath: "center.y", type: UIInterpolatingMotionEffectType.tiltAlongVerticalAxis)
        verticalEffect.minimumRelativeValue = -motionEffectExtent
        verticalEffect.maximumRelativeValue = +motionEffectExtent
        
        let motionEffectGroup = UIMotionEffectGroup()
        motionEffectGroup.motionEffects = [horizontalEffect, verticalEffect]
        
        view.addMotionEffect(motionEffectGroup)
    }
    
    // Whether the UI is in landscape mode
    private func orientationIsLandscape() -> Bool {
        return UIInterfaceOrientationIsLandscape(UIApplication.shared.statusBarOrientation)
    }
    
    // Call the delegates
    internal func buttonTouchUpInside(sender: UIButton!) {
        delegate?.customIOS7AlertViewButtonTouchUpInside(alertView: self, buttonIndex: sender.tag)
        onButtonTouchUpInside?(self, sender.tag)
    }
    
    // Handle device orientation changes
    internal func deviceOrientationDidChange(notification: NSNotification) {
        let interfaceOrientation = UIApplication.shared.statusBarOrientation
        let startRotation = self.value(forKeyPath: "layer.transform.rotation.z") as! Float
        
        var rotation: CGAffineTransform
        
        switch (interfaceOrientation) {
        case UIInterfaceOrientation.landscapeLeft:
            rotation = CGAffineTransform(rotationAngle: CGFloat(-startRotation) + CGFloat(Double.pi * 270 / 180))
            break
            
        case UIInterfaceOrientation.landscapeRight:
            rotation = CGAffineTransform(rotationAngle: CGFloat(-startRotation) + CGFloat(Double.pi * 90 / 180))
            break
            
        case UIInterfaceOrientation.portraitUpsideDown:
            rotation = CGAffineTransform(rotationAngle: CGFloat(-startRotation) + CGFloat(Double.pi * 180 / 180))
            break
            
        default:
            rotation = CGAffineTransform(rotationAngle: CGFloat(-startRotation) + 0)
            break
        }
        
        //        UIView.animate(withDuration: 0.2, delay: 0, options: UIViewAnimationOptions(), animations: {
        ////            self.alertView.transform = rotation
        //        }, completion: nil)
        
        // Fix errors caused by being rotated one too many times
        //        dispatch_after(dispatch_time(dispatch_time_t(DispatchTime.now()), Int64(0.5 * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), {
        //            let endInterfaceOrientation = UIApplication.sharedApplication.statusBarOrientation
        //            if interfaceOrientation != endInterfaceOrientation {
        //                // TODO: user moved phone again before than animation ended: rotation animation can introduce errors here
        //            }
        //        })
        
        //        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
        //            let endInterfaceOrientation = UIApplication.shared.statusBarOrientation
        //            if interfaceOrientation != endInterfaceOrientation {
        //                // TODO: user moved phone again before than animation ended: rotation animation can introduce errors here
        //            }
        //
        //        }
        
    }
    
    // Handle keyboard show changes
    internal func keyboardWillShow(notification: NSNotification) {
        let screenSize = self.calculateScreenSize()
        let dialogSize = self.calculateDialogSize()
        //[[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
        var keyboardSize = (notification.userInfo![UIKeyboardFrameBeginUserInfoKey] as AnyObject).cgRectValue.size
        
        if orientationIsLandscape() {
            keyboardSize = CGSize(width: keyboardSize.height, height: keyboardSize.width)
        }
        
        UIView.animate(withDuration: 0.2, delay: 0, options: UIViewAnimationOptions(), animations: {
            self.alertView.frame = CGRect(
                x: (screenSize.width - dialogSize.width) / 2,
                y: (screenSize.height - keyboardSize.height - dialogSize.height) / 2,
                width: dialogSize.width,
                height: dialogSize.height
            )
        }, completion: nil)
    }
    
    // Handle keyboard hide changes
    internal func keyboardWillHide(notification: NSNotification) {
        let screenSize = self.calculateScreenSize()
        let dialogSize = self.calculateDialogSize()
        
        UIView.animate(withDuration: 0.2, delay: 0, options: UIViewAnimationOptions(), animations: {
            self.alertView.frame = CGRect(
                x: (screenSize.width - dialogSize.width) / 2,
                y: (screenSize.height - dialogSize.height) / 2,
                width: dialogSize.width,
                height: dialogSize.height
            )
        }, completion: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
    }
    
}
