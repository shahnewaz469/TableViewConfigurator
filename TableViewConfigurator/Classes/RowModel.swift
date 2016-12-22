//
//  RowModel.swift
//  Pods
//
//  Created by John Volk on 12/22/16.
//
//

import UIKit

public func ==(lhs: RowModel, rhs: RowModel) -> Bool {
    return lhs.tag == rhs.tag
}

open class RowModel: Equatable {
    
    internal var tag: Int?
    
    public init(tag: Int? = nil) {
        self.tag = tag
    }

}
