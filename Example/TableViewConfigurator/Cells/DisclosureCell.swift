//
//  DisclosureCell.swift
//  TableViewConfigurator
//
//  Created by John Volk on 3/2/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import UIKit
import TableViewConfigurator

class DisclosureCell: UITableViewCell, ConfigurableTableViewCell {

    override class func buildReuseIdentifier() -> String? {
        return "disclosureCell";
    }
    
    func configure() {
        self.textLabel?.text = "Disclosure Cell";
    }
}
