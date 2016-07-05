//
//  ConfigurableCell.swift
//  TableViewConfigurator
//
//  Created by John Volk on 3/3/16.
//  Copyright © 2016 John Volk. All rights reserved.
//

import UIKit
import TableViewConfigurator

class ConfigurableCell: UITableViewCell, ConfigurableTableViewCell {

    var configured = false
    var additionallyConfigured = false
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func configure() {
        self.configured = true
    }
}
