//
//  SchoolTableViewCell.swift
//  2018-02-08-CN-NYCSchools
//
//  Created by Christopher Nelson on 2/8/18.
//  Copyright © 2018 Odeon Software Inc. All rights reserved.
//

import UIKit

class SchoolTableViewCell: UITableViewCell {

    @IBOutlet weak var schoolLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var cityStZipLabel: UILabel!
    @IBOutlet weak var boroughLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
