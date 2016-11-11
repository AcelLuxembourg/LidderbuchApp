//
//  LBReplaceSegue.swift
//  Lidderbuch
//
//  Copyright (c) 2015 Fränz Friederes <fraenz@frieder.es>
//  Licensed under the MIT license.
//

import UIKit

class LBReplaceSegue: UIStoryboardSegue
{
    override func perform()
    {
        if let navigationController = source.navigationController
        {
            let transition = CATransition()
            transition.duration = 0.2
            transition.type = kCATransitionFade
            transition.subtype = kCATransitionFromTop
            
            navigationController.view.layer.add(transition, forKey: kCATransition)
            navigationController.viewControllers = [destination]
        }
    }
}
