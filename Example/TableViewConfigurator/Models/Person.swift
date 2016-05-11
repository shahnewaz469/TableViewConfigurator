//
//  Person.swift
//  TableViewConfigurator
//
//  Created by John Volk on 3/1/16.
//  Copyright © 2016 John Volk. All rights reserved.
//

import Foundation

class Person {

    let firstName: String;
    let lastName: String;
    var age: Int;
    
    init(firstName: String, lastName: String, age: Int) {
        self.firstName = firstName;
        self.lastName = lastName;
        self.age = age;
    }
    
    func incrementAge() {
        self.age += 1
    }
}
