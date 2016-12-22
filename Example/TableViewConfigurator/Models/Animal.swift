//
//  Animal.swift
//  TableViewConfigurator
//
//  Created by John Volk on 3/1/16.
//  Copyright © 2016 John Volk. All rights reserved.
//

import TableViewConfigurator

func ==(lhs: Animal, rhs: Animal) -> Bool {
    return lhs === rhs
}

class Animal: Equatable {

    let name: String
    let scientificName: String
    
    init(name: String, scientificName: String) {
        self.name = name
        self.scientificName = scientificName
    }
}
