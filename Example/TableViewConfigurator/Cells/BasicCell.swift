//
//  BasicCell.swift
//  TableViewConfigurator
//
//  Created by John Volk on 3/2/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import UIKit
import TableViewConfigurator

class BasicCell: UITableViewCell, ConfigurableTableViewCell {

    override class func buildReuseIdentifier() -> String? {
        return "basicCell";
    }
    
    func configure() {
        self.textLabel?.text = "Basic Cell"
    }
}
