//
//  AnimalCell.swift
//  TableViewConfigurator
//
//  Created by John Volk on 3/1/16.
//  Copyright © 2016 John Volk. All rights reserved.
//

import UIKit
import TableViewConfigurator

class AnimalCell: UITableViewCell, ModelConfigurableTableViewCell {
    
    @IBOutlet var nameLabel: UILabel!;
    @IBOutlet var scientificNameLabel: UILabel!;
    
    func configure(model: Animal) {
        self.nameLabel.text = model.name
        self.scientificNameLabel.text = model.scientificName;
    }
}
