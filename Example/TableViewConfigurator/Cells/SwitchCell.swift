//
//  SwitchCell.swift
//  TableViewConfigurator
//
//  Created by John Volk on 3/2/16.
//  Copyright © 2016 John Volk. All rights reserved.
//

import UIKit
import TableViewConfigurator

class SwitchCell: UITableViewCell, ConfigurableTableViewCell {

    @IBOutlet var hideLabel: UILabel!
    @IBOutlet var hideSwitch: UISwitch!
    
    var switchChangedHandler: ((_ on: Bool) -> Void)!
    
    func configure() {
        self.hideLabel.text = "Hide"
    }
    
    @IBAction func switchValueChanged(_ sender: AnyObject) {
        self.switchChangedHandler(self.hideSwitch.isOn)
    }
}
