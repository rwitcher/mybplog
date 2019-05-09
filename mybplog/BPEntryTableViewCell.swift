//
//  BPEntryTableViewCell.swift
//  mybplog
//
//  Created by Rodney Witcher on 9/16/18.
//  Copyright © 2018 Pluckshot. All rights reserved.
//

import UIKit

class BPEntryTableViewCell: UITableViewCell {

    //MARK: Properties
    @IBOutlet weak var dateTimeLabel: UILabel!
    @IBOutlet weak var bpLabel: UILabel!
    @IBOutlet weak var pulseLabel: UILabel!
    @IBOutlet weak var notesLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
