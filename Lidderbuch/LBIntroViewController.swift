//
//  LBIntroViewController.swift
//  Lidderbuch
//
//  Created by Fränz Friederes on 12/11/16.
//  Copyright © 2016 ACEL. All rights reserved.
//

import UIKit

class LBIntroViewController: UIViewController
{
    lazy var backer: LBBacker = {
        return LBBacker()
    }()
    
    @IBOutlet weak var logoView: UIImageView!
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        if let backerImage = backer.randomBackerImage() {
            logoView.image = backerImage
            
            // perform segue to main view in 2s
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.performSegueToMain()
            }
        } else {
            // perform immediate segue to main view
            self.performSegueToMain()
        }
    }
    
    fileprivate func performSegueToMain()
    {
        self.performSegue(withIdentifier: "ShowMain", sender: self)
    }
}
