//
//  UIExtensions.swift
//  Car Racing Challenge
//
//  Created by Alex Ongarato on 21/03/15.
//  Copyright (c) 2015 Alex Ongarato. All rights reserved.
//

import Foundation
import UIKit

extension UIImage
{
    var height:CGFloat{get{return self.size.height;}};
    var width:CGFloat{get{return self.size.width;}};
    
    func imageWithHalfSize() -> UIImage
    {
        return self.resizeImage(0.5);
    }
    
    func imageScaled(fitToWidth:CGFloat) -> UIImage
    {
        let scale:CGFloat = fitToWidth / self.width;
        return self.resizeImage(scale);
    }
    
    func imageScaledToFit(sizeToFit:CGSize) -> UIImage
    {
        let scale:CGFloat = (self.width > self.height || (sizeToFit.width < sizeToFit.height && self.width >= self.height))
            ? sizeToFit.width / self.width
            : sizeToFit.height / self.height;
        return self.resizeImage(scale);
    }
    
    func imageScaledToFill(sizeToFill:CGSize) -> UIImage
    {
        let scale:CGFloat = (self.width < self.height || (sizeToFill.width > sizeToFill.height && self.width <= self.height))
            ? sizeToFill.width / self.width
            : sizeToFill.height / self.height;
        return self.resizeImage(scale);
    }
    
    func resizeImage(scale:CGFloat) -> UIImage
    {
        let newSize:CGSize = CGSize(width: Int(self.width * scale), height: Int(self.height * scale));
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0);
        self.drawInRect(CGRectMake(0, 0, newSize.width, newSize.height));
        let newImage:UIImage! = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        return newImage;
    }
}

class AbstractView:UIView
{
    var animationStyle:AnimationStyle = AnimationStyle.SlideUp;
    private var _callback:(()->Void)!;
    
    override func didMoveToSuperview()
    {
        self.inflate(false);
        
        if(self.animationStyle == .Scale)
        {
            self.alpha = 0;
        }
    }
    
    func present(completion:((animated:Bool)->Void)!)
    {
        var vel:NSTimeInterval = 0;
        if(self.animationStyle == .Scale)
        {
            self.layer.transform = CATransform3DMakeScale(0.5, 0.5, 1);
            vel = AnimationTime.Fast;
        }
        else if(self.animationStyle == .SlideUp)
        {
            self.y = self.height;
            vel = AnimationTime.Slow;
        }
        
        UIView.animateWithDuration(vel, delay: 0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
            if(self.animationStyle == .Scale)
            {
                self.layer.transform = CATransform3DMakeScale(1, 1, 1);
                self.alpha = 1;
            }
            else if(self.animationStyle == .SlideUp)
            {
                self.y = 0;
            }
        }, completion: completion);
    }
    
    func dismiss(completion:((animated:Bool)->Void)!)
    {
        var vel:NSTimeInterval = 0;
        if(self.animationStyle == .Scale)
        {
            vel = AnimationTime.Fast;
        }
        else if(self.animationStyle == .SlideUp)
        {
            vel = AnimationTime.Slow;
        }
        
        UIView.animateWithDuration(vel, delay: 0, options: UIViewAnimationOptions.CurveEaseIn, animations: {
            if(self.animationStyle == .Scale)
            {
                self.layer.transform = CATransform3DMakeScale(0.5, 0.5, 1);
                self.alpha = 0;
            }
            else if(self.animationStyle == .SlideUp)
            {
                self.y = self.height;
            }
        }, completion: completion);
    }
}

extension UIView
{
    var y               : CGFloat{ get { return self.frame.origin.y;   } set(val) { self.frame.origin.y = val; } };
    var x               : CGFloat{ get { return self.frame.origin.x;   } set(val) { self.frame.origin.x = val; } };
    var height          : CGFloat{ get { return self.frame.height;     } set(val) { self.frame = CGRect(x: self.x, y: self.y, width: self.width, height: val); } };
    var width           : CGFloat{ get { return self.frame.width;      } set(val) { self.frame = CGRect(x: self.x, y: self.y, width: val, height: self.height); } };
    
    /**
    Auto inflate only the with property and optionaly propagate the changes to superviews recursively.
    */
    func inflate(propagate:Bool)
    {
        inflate(width: -1, height: -1, propagate: propagate);
    }
    
    /**
    Auto Inflate the with property, set the new height property and optionaly propagate the changes to superviews recursively.
    
    @height the desired height or -1 to use the current frame height.
    */
    func inflate(height newHeight:CGFloat, propagate:Bool)
    {
        inflate(width: -1, height: newHeight, propagate: propagate);
    }
    
    /**
    Inflate the with and height properties with the given values and optionaly propagate the changes to superviews recursively.
    
    @width the desired width or -1 to use its superview width property.
    
    @height the desired height or -1 to use the current frame height.
    */
    func inflate(width newWidth:CGFloat, height newHeight:CGFloat, propagate:Bool)
    {
        if(self.superview != nil)
        {
            self.frame = CGRect(x: self.x,
                y: self.y,
                width: newWidth == -1 ? self.width == 0 ? self.superview!.frame.width : self.width : newWidth,
                height: newHeight == -1 ? self.height == 0 ? self.superview!.frame.height : self.height : newHeight);
            
            if(!propagate)
            {
                return;
            }
            
            let superFrame:CGRect = self.superview!.frame;
            
            if(self.y + newHeight + 90 >= superFrame.height)
            {
                if(self.superview!.isKindOfClass(UIScrollView))
                {
                    //print("inflate -> reached the scrollview");
                    
                    let scroll:UIScrollView = self.superview as! UIScrollView;
                    scroll.contentSize = CGSize(width: scroll.frame.width, height: self.y + newHeight + 30);
                }
                else
                {
                    //print("inflate -> propagating (superview:\(self.superview!.description))");
                    
                    self.superview!.inflate(height: self.y + self.frame.height, propagate: true);
                }
            }
        }
        else
        {
            self.frame = CGRect(x: self.x, y: self.y, width: newWidth, height: newHeight);
        }
    }
    
    func addTarget(target:AnyObject, selector:Selector)
    {
        self.userInteractionEnabled = true;
        self.addGestureRecognizer(UITapGestureRecognizer(target: target, action: selector));
    }
    
    func onTouchAnima()
    {
        func completion1(animated:Bool)
        {
            UIView.animateWithDuration(AnimationTime.VeryFast, delay:0, options:UIViewAnimationOptions.CurveEaseIn, animations: {
                self.layer.transform = CATransform3DMakeScale(1, 1, 1);
                }, completion: nil);
        }
        
        UIView.animateWithDuration(AnimationTime.VeryFast, delay:0, options:UIViewAnimationOptions.CurveEaseOut, animations: {
            self.layer.transform = CATransform3DMakeScale(1.1, 1.1, 1);
            }, completion: completion1);
    }
    
    func removeTargets()
    {
        self.gestureRecognizers?.removeAll(keepCapacity: false);
    }
    
    @available(iOS 8.0, *)
    func enableBlur(style:UIBlurEffectStyle)
    {
        //only apply the blur if the user hasn't disabled transparency effects
        if(!UICustomDevice.isIOS8OrHigher())
        {
            self.backgroundColor = UIColor.whiteColor().alpha(0.9);
            return;
        }
        
        let visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: style)) as UIVisualEffectView;
        visualEffectView.frame = self.bounds;
        self.addSubview(visualEffectView)
        visualEffectView.alpha = 0.9;
    }
    
    func enableGaussianBlur()
    {
        if(!UICustomDevice.isIOS8OrHigher())
        {
            self.backgroundColor = UIColor.blackColor().alpha(0.9);
            return;
        }
        
        if !UIAccessibilityIsReduceTransparencyEnabled()
        {
            
        }
        else
        {
            self.backgroundColor = UIColor.blackColor().alpha(0.9);
        }
        
    }
    
    func scale(value:CGFloat)
    {
        self.layer.transform = CATransform3DMakeScale(value, value, 1);
//        self.width = self.width * value;
//        self.height = self.height * value;
    }
    
    func removeAllSubviews()
    {
        for view in self.subviews
        {
            view.removeFromSuperview();
        }
    }
    
    func takeSnapshot() -> UIImage {
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, UIScreen.mainScreen().scale)
        
        drawViewHierarchyInRect(self.bounds, afterScreenUpdates: true)
        
        // old style: layer.renderInContext(UIGraphicsGetCurrentContext())
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}

extension UIColor
{
    func alpha(val:CGFloat) -> UIColor
    {
        return self.colorWithAlphaComponent(val);
    }
    
    var HEXColor : NSString {
        get {
            var str:NSString = "";
            
            let numComponents:Int = CGColorGetNumberOfComponents(self.CGColor);
            
            if (numComponents == 4)
            {
                let components:UnsafePointer<CGFloat> = CGColorGetComponents(self.CGColor);
                str = NSString(format:"#%2X%2X%2X", Int(components[0] * 255), Int(components[1] * 255), Int(components[2] * 255));
                str = str.stringByReplacingOccurrencesOfString(" ", withString: "0");
            }
            
            return str;
        }
    }
}

extension CGSize
{
    var description : NSString { get { return "CGSize(width:\(self.width), height:\(self.height))"; } };
    var doubleValue : CGSize { get { return CGSize(width: self.width * 2, height: self.height * 2); } };
    var halfValue   : CGSize { get { return CGSize(width: self.width * 0.5, height: self.height * 0.5); } };
}

extension CGFloat
{
    var half: CGFloat { get { return self * 0.5; } };
    var intValue: Int { get { return Int(self); } };
    var roundValue: CGFloat { get { return CGFloat(Int(self)); } };
}

extension Int
{
    var floatValue: CGFloat { get { return CGFloat(self); } };
}

extension UILabel
{
    func bold(word:String)
    {
        self.bold(word, color: self.textColor);
    }
    
    func bold(word:String, color:UIColor!)
    {
        let temp:NSMutableAttributedString = self.attributedText as! NSMutableAttributedString;
        let main_string:NSString = temp.string;
        let range:NSRange = (main_string as NSString).rangeOfString(word);
        if(range.length > 0)
        {
            let format:NSDictionary = [NSFontAttributeName : Fonts.BoldFont(self.font.pointSize), NSForegroundColorAttributeName: color];
            temp.addAttributes(format as! [String : AnyObject], range: (main_string as NSString).rangeOfString(word));
            self.attributedText = temp;
        }
    }
}

