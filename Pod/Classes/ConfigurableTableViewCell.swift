//
//  ConfigurableTableViewCell.swift
//  Pods
//
//  Created by John Volk on 3/2/16.
//
//

import UIKit

public protocol ConfigurableTableViewCell {
    
    func configure();
    
}

public protocol ModelConfigurableTableViewCell {

    typealias Model;
    
    func configure(model: Model);
    
}

public extension UITableViewCell {
    
    public class func buildReuseIdentifier() -> String? {
        return nil;
    }
    
}