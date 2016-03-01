//
//  AnimalCell.swift
//  TableViewConfigurator
//
//  Created by John Volk on 3/1/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import UIKit

class AnimalCell: UITableViewCell {

    typealias ModelType = Animal;
    
    @IBOutlet var nameLabel: UILabel!;
    @IBOutlet var scientificNameLabel: UILabel!;
    
    func configure(animal: Animal) {
        self.nameLabel.text = animal.name
        self.scientificNameLabel.text = animal.scientificName;
    }
}
