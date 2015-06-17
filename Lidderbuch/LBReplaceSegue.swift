//
//  LBReplaceSegue.swift
//  Lidderbuch
//
//  Created by Fränz Friederes on 07/06/15.
//  Copyright (c) 2015 ACEL. All rights reserved.
//

import UIKit

class LBReplaceSegue: UIStoryboardSegue
{
    override func perform() {
        if let sourceViewController = sourceViewController as? UIViewController,
            destinationViewController = destinationViewController as? UIViewController,
            navigationController = sourceViewController.navigationController
        {
            let transition = CATransition()
            transition.duration = 0.2
            transition.type = kCATransitionFade
            transition.subtype = kCATransitionFromTop
            
            navigationController.view.layer.addAnimation(transition, forKey: kCATransition)
            navigationController.viewControllers = [destinationViewController]
        }
    }
}