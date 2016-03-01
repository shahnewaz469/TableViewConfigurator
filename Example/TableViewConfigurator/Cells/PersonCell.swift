//
//  PersonCell.swift
//  TableViewConfigurator
//
//  Created by John Volk on 3/1/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import UIKit

class PersonCell: UITableViewCell {
    
    @IBOutlet var nameLabel: UILabel!;
    @IBOutlet var ageLabel: UILabel!;
    
    func configure(person: Person) {
        self.nameLabel.text = "\(person.firstName) \(person.lastName)";
        self.ageLabel.text = "Age \(person.age)";
    }
}
