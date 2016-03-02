//
//  PersonCell.swift
//  TableViewConfigurator
//
//  Created by John Volk on 3/1/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import UIKit
import TableViewConfigurator

class PersonCell: UITableViewCell, ModelConfigurableTableViewCell {
    
    @IBOutlet var nameLabel: UILabel!;
    @IBOutlet var ageLabel: UILabel!;
    
    override class func buildReuseIdentifier() -> String? {
        return "personCell";
    }
    
    func configure(model: Person) {
        self.nameLabel.text = "\(model.firstName) \(model.lastName)";
        self.ageLabel.text = "Age \(model.age)";
    }
}
