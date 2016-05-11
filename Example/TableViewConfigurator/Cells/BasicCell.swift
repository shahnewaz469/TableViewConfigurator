//
//  BasicCell.swift
//  TableViewConfigurator
//
//  Created by John Volk on 3/2/16.
//  Copyright © 2016 John Volk. All rights reserved.
//

import UIKit
import TableViewConfigurator

class BasicCell: UITableViewCell, ConfigurableTableViewCell {
    
    func configure() {
        self.textLabel?.text = "Basic Cell"
    }
}
