//
//  ConfigurableTableViewCell.swift
//  Pods
//
//  Created by John Volk on 3/2/16.
//  Copyright © 2016 John Volk. All rights reserved.
//

import UIKit

public protocol ConfigurableTableViewCell {
    
    func configure()
    
}

public protocol ModelConfigurableTableViewCell {

    associatedtype ModelType
    
    func configure(model: ModelType)
    
}

public extension UITableViewCell {
    
    public class func buildReuseIdentifier() -> String? {
        return nil
    }
    
}
