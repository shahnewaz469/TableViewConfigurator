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

    typealias ModelType;
    
    func configure(model: ModelType);
    
}

public extension UITableViewCell {
    
    public class func buildReuseIdentifier() -> String? {
        return nil;
    }
    
}
