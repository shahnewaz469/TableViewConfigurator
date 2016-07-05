//
//  TextCell.swift
//  TableViewConfigurator
//
//  Created by John Volk on 5/11/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import TableViewConfigurator

class TextCell: UITableViewCell, ConfigurableTableViewCell {
    
    @IBOutlet var textField: UITextField!
    
    func configure() {
        self.textField.text = ""
    }
}
