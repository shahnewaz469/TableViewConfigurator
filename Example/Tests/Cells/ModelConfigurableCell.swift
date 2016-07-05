//
//  ModelConfigurableCell.swift
//  TableViewConfigurator
//
//  Created by John Volk on 3/4/16.
//  Copyright © 2016 John Volk. All rights reserved.
//

import UIKit
import TableViewConfigurator

class ModelConfigurableCell: UITableViewCell, ModelConfigurableTableViewCell {

    var model: Thing?
    var additionallyConfigured = false
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func configure(model: Thing) {
        self.model = model
    }
}
