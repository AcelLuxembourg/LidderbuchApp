//
//  LBSectionTableViewCell.swift
//  Lidderbuch
//
//  Created by Fränz Friederes on 04/06/15.
//  Copyright (c) 2015 ACEL. All rights reserved.
//

import UIKit

class LBCategoryTableViewCell: UITableViewCell
{
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        selectionStyle = .None
    }
    
    var category: String? {
        didSet {
            if let category = self.category {
                titleLabel.text = category.uppercaseString
            }
        }
    }
}
