//
//  LBSectionTableViewCell.swift
//  Lidderbuch
//
//  Copyright (c) 2015 Fränz Friederes <fraenz@frieder.es>
//  Licensed under the MIT license.
//

import UIKit

class LBCategoryTableViewCell: UITableViewCell
{
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        selectionStyle = .None
    }
    
    var category: String? {
        didSet {
            if let category = self.category {
                titleLabel.text = category
            }
        }
    }
}
