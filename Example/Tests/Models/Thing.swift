//
//  Thing.swift
//  TableViewConfigurator
//
//  Created by John Volk on 3/4/16.
//  Copyright © 2016 John Volk. All rights reserved.
//

import TableViewConfigurator

func ==(lhs: Thing, rhs: Thing) -> Bool {
    return lhs === rhs
}

class Thing: Equatable {
    
    let name: String
    
    init(name: String) {
        self.name = name
    }
}
