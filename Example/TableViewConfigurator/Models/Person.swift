//
//  Person.swift
//  TableViewConfigurator
//
//  Created by John Volk on 3/1/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import Foundation
import TableViewConfigurator

class Person {

    let firstName: String;
    let lastName: String;
    let age: Int;
    
    init(firstName: String, lastName: String, age: Int) {
        self.firstName = firstName;
        self.lastName = lastName;
        self.age = age;
    }
}
