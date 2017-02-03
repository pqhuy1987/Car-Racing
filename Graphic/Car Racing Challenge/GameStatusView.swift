//
//  GameStatusView.swift
//  Car Racing Challenge
//
//  Created by Alex Ongarato on 21/03/15.
//  Copyright (c) 2015 Alex Ongarato. All rights reserved.
//

import Foundation
import UIKit
class GameStatusView:AbstractView
{
    private var scoreField:UILabel!;
    private var statusField:UILabel!;
    private var defaultBgColor:UIColor!;
    private var defaultY:CGFloat = 0;
    
    override func didMoveToSuperview()
    {
        super.didMoveToSuperview();
        self.alpha = 0;
        self.height = 20;
        self.defaultY = self.y;
        self.y = self.defaultY - self.height;
        
        if(UICustomDevice.avoidTexture())
        {
            defaultBgColor = Colors.green;
        }
        else
        {
            defaultBgColor = UIColor(patternImage: UIImage(named: ImagesNames.Background)!)//.alpha(0.8);
            
        }
        
        self.backgroundColor = defaultBgColor;
        self.statusField = UILabel();
        self.addSubview(self.statusField);
        self.statusField.y = 5;
        self.statusField.font = Fonts.DefaultFont(FontSize.Small);
        self.statusField.textColor = UIColor.blackColor();
        self.statusField.textAlignment = NSTextAlignment.Center;
        self.layer.borderWidth = 0.5;
        self.layer.borderColor = UIColor.whiteColor().alpha(0.5).CGColor;
    }
    
    func show()
    {
        UIView.animateWithDuration(AnimationTime.VerySlow, delay: AnimationTime.Slow, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
            self.y = self.defaultY;
            self.alpha = 1;
            }, completion: nil);
    }
    
    func hide()
    {
        UIView.animateWithDuration(AnimationTime.Default, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: UIViewAnimationOptions.CurveEaseIn, animations: {
            self.y = self.defaultY - self.height;
            self.alpha = 0;
            }, completion: nil);
    }
    
    func update(level:Int, score:Int, nextScore:Int, lifes:Int, scoreNextLife:Int)
    {
//        self.statusField.text = "LEVEL:\(level)  LIFES:\(lifes)  SCORE:\(score)/\(nextScore * level)";
        self.statusField.text = "LEVEL:\(level)        SCORE:\(score) / \(nextScore * level)";
//        self.statusField.bold("LEVEL:");
//        self.statusField.bold("SCORE:");
//        self.statusField.bold("\(nextScore * level)");
        self.statusField.sizeToFit();
        self.statusField.center.x = self.center.x;
    }
    
    func showSuccessAnimation()
    {
        self.backgroundColor = defaultBgColor;
        
        func completion(animated:Bool)
        {
            UIView.animateWithDuration(AnimationTime.Default, animations: {
                self.backgroundColor = self.defaultBgColor;
            }, completion: nil);
        }
        
        UIView.animateWithDuration(AnimationTime.Default, animations: {
            self.backgroundColor = UIColor.blackColor().alpha(0.2);
        }, completion: completion);
    }
    
    func showErrorAnimation()
    {
        self.backgroundColor = defaultBgColor;
        
        func completion(animated:Bool)
        {
            UIView.animateWithDuration(AnimationTime.Default, animations: {
                self.backgroundColor = self.defaultBgColor;
                }, completion: nil);
        }
        
        UIView.animateWithDuration(AnimationTime.Default, animations: {
            self.backgroundColor = UIColor.blackColor().alpha(0.2);
            }, completion: completion);
    }
}