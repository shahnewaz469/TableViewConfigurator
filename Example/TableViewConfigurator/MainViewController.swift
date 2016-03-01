//
//  MainViewController.swift
//  TableViewConfigurator
//
//  Created by John Volk on 02/29/2016.
//  Copyright (c) 2016 John Volk. All rights reserved.
//

import UIKit
import TableViewConfigurator

class MainViewController: UIViewController {

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
        
        configurations.append(ConstantSectionConfiguration(rowConfigurations: [ConstantRowConfiguration<UITableViewCell>(rowSpan: 1, cellReuseId: MainViewController.BASIC_CELL_REUSE_ID,
            cellConfigurator: { (cell) -> Void in
                cell.textLabel?.text = "Basic Cell";
        })]));
        
        configurations.append(ModelSectionConfiguration<PersonCell, Person>(models: self.people, cellReuseId: MainViewController.PERSON_CELL_REUSE_ID,
            cellConfigurator: { (cell, model) -> Void in
                cell.configure(model);
        }));
        
        configurations.append(ConstantSectionConfiguration(rowConfigurations: [ConstantRowConfiguration<UITableViewCell>(rowSpan: 1, cellReuseId: MainViewController.DISCLOSURE_CELL_REUSE_ID,
            cellConfigurator: { (cell) -> Void in
                cell.textLabel?.text = "Disclosure Cell";
                cell.accessoryType = .DisclosureIndicator;
        })]));
        
        configurations.append(ModelSectionConfiguration<AnimalCell, Animal>(modelSections: self.animals, cellReuseId: MainViewController.ANIMAL_CELL_REUSE_ID,
            cellConfigurator: { (cell, model) -> Void in
                cell.configure(model);
        }));
        
        self.configurator = TableViewConfigurator(sectionConfigurations: configurations);
        
        self.tableView.dataSource = self.configurator;
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning();
    }
}

