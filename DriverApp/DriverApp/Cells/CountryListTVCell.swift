//
//  CountryListTVCell.swift
//  Admin
//
//  Created by ADMIN on 09/05/17.
//  Copyright © 2017 V3Cube. All rights reserved.
//

import UIKit

class CountryListTVCell: UITableViewCell {

    @IBOutlet weak var countryCodeLbl: MyLabel!
    @IBOutlet weak var countryLabelTxt: MyLabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
