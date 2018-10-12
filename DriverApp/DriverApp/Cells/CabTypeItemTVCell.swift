//
//  CabTypeItemTVCell.swift
//  DriverApp
//
//  Created by iphone3 on 26/04/18.
//  Copyright © 2018 V3Cube. All rights reserved.
//

import UIKit

class CabTypeItemTVCell: UITableViewCell {
    
    @IBOutlet weak var rentalChkBoxContainerView: UIView!
    @IBOutlet weak var carTypeNameLbl: MyLabel!
    @IBOutlet weak var carTypeChkBox: BEMCheckBox!
    @IBOutlet weak var subTitleLbl: MyLabel!
    @IBOutlet weak var vtypeLbl: MyLabel!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var heightContainerView: NSLayoutConstraint!
    @IBOutlet weak var allowRentalView: UIView!
    @IBOutlet weak var rentalChkBox: BEMCheckBox!
    @IBOutlet weak var allowRentalLbl: MyLabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
