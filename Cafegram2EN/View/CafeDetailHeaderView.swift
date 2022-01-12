//
//  CafeDetailHeaderView.swift
//  Cafegram2EN
//
//  Created by Ibrahim Mo Gedami on 16/05/2020.
//  Copyright © 2020 Ibrahim Mo Gedami. All rights reserved
//

import UIKit

class CafeDetailHeaderView: UIView {
    
    @IBOutlet var ratingImageView: UIImageView!
    
    @IBOutlet var headerImageView: UIImageView!
    
    @IBOutlet var nameLabel: UILabel! {
        didSet {
            nameLabel.numberOfLines = 0
        }
    }
    
    @IBOutlet var typeLabel: UILabel! {
        didSet {
            typeLabel.layer.cornerRadius = 5.0
            typeLabel.layer.masksToBounds = true
        }
    }

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
