//
//  ModelImplicitReuseIdCell.swift
//  TableViewConfigurator
//
//  Created by John Volk on 3/4/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import UIKit

class ModelImplicitReuseIdCell: ModelConfigurableCell {

    static let REUSE_ID = "modelImplicitReuseIdCell";
    
    override class func buildReuseIdentifier() -> String? {
        return ModelImplicitReuseIdCell.REUSE_ID;
    }
}
