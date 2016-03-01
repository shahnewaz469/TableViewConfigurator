//
//  MainViewController.swift
//  TableViewConfigurator
//
//  Created by John Volk on 02/29/2016.
//  Copyright (c) 2016 John Volk. All rights reserved.
//

import UIKit
import TableViewConfigurator

class MainViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    private static let BASIC_CELL_REUSE_ID = "basicCell";
    private static let PERSON_CELL_REUSE_ID = "personCell";
    private static let DISCLOSURE_CELL_REUSE_ID = "disclosureCell";
    private static let ANIMAL_CELL_REUSE_ID = "animalCell";
    
    @IBOutlet var tableView: UITableView!;
    
    private var configurator: TableViewConfigurator!;
    
    private let people = [Person(firstName: "John", lastName: "Doe", age: 32),
        Person(firstName: "Alex", lastName: "Great", age: 50),
        Person(firstName: "Napoléon", lastName: "Bonaparte", age: 18)];
    
    private let animals = [[Animal(name: "American Bullfrog", scientificName: "Rana catesbeiana"), Animal(name: "Fire Salamander", scientificName: "Salamandra salamandra")],
        [Animal(name: "Loggerhead Shrike", scientificName: "Lanius ludovicianus"), Animal(name: "Pileated Woodpecker", scientificName: "Dryocopus pileatus")],
        [Animal(name: "Woodchuck", scientificName: "Marmota monax"), Animal(name: "Wolverine", scientificName: "Gulo gulo")]];
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        var configurations = [SectionConfiguration]();
        
        configurations.append(ConstantSectionConfiguration(rowConfigurations: [ConstantRowConfiguration<UITableViewCell>(cellReuseId: MainViewController.BASIC_CELL_REUSE_ID,
            cellConfigurator: { (cell) -> Void in
                cell.textLabel?.text = "Basic Cell";
        }, selectionHandler: nil)]));
        
        configurations.append(ModelSectionConfiguration<PersonCell, Person>(modelSections: [self.people], cellReuseId: MainViewController.PERSON_CELL_REUSE_ID,
            cellConfigurator: { (cell, model) -> Void in
                cell.configure(model);
            }, selectionHandler: { (model) -> Bool in
                print(model);
                return true;
        }));
        
        configurations.append(ConstantSectionConfiguration(rowConfigurations: [ConstantRowConfiguration<UITableViewCell>(cellReuseId: MainViewController.DISCLOSURE_CELL_REUSE_ID,
            cellConfigurator: { (cell) -> Void in
                cell.textLabel?.text = "Disclosure Cell";
                cell.accessoryType = .DisclosureIndicator;
        }, selectionHandler: nil)]));
        
        configurations.append(ModelSectionConfiguration<AnimalCell, Animal>(modelSections: self.animals, cellReuseId: MainViewController.ANIMAL_CELL_REUSE_ID,
            cellConfigurator: { (cell, model) -> Void in
                cell.configure(model);
            }, selectionHandler: { (model) -> Bool in
                print(model);
                return true;
        }));
        
        self.configurator = TableViewConfigurator(sectionConfigurations: configurations);
    }

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.configurator.numberOfSectionsInTableView(tableView);
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.configurator.tableView(tableView, numberOfRowsInSection: section);
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return self.configurator.tableView(tableView, cellForRowAtIndexPath: indexPath);
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.configurator.tableView(tableView, didSelectRowAtIndexPath: indexPath);
    }
}

