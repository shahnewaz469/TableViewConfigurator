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
    private var hidePerson = false;
    private var hideDisclosure = false;
    
    private let people = [Person(firstName: "John", lastName: "Doe", age: 50),
        Person(firstName: "Alex", lastName: "Great", age: 32),
        Person(firstName: "Hide", lastName: "Me", age: 26),
        Person(firstName: "Napoléon", lastName: "Bonaparte", age: 18)];
    
    private let animals = [[Animal(name: "American Bullfrog", scientificName: "Rana catesbeiana"), Animal(name: "Fire Salamander", scientificName: "Salamandra salamandra")],
        [Animal(name: "Loggerhead Shrike", scientificName: "Lanius ludovicianus"), Animal(name: "Pileated Woodpecker", scientificName: "Dryocopus pileatus")],
        [Animal(name: "Woodchuck", scientificName: "Marmota monax"), Animal(name: "Wolverine", scientificName: "Gulo gulo")]];
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        // TODO: hideWhen()
        // TODO: height()
        // TODO: measureHeight()
        // TODO: estimatedHeight()
        
        self.configurator = TableViewConfigurator();
        
        self.configurator.addConfiguration(SectionConfiguration(rowConfiguration:
            ConstantRowConfiguration<BasicCell>()));
        
        self.configurator.addConfiguration(SectionConfiguration(rowConfigurations:
            [ConstantRowConfiguration<SwitchCell>()
                .additionalCellConfig({ (cell) -> Void in
                    cell.hideSwitch.on = self.hidePerson;
                    cell.switchChangedHandler = { (on) -> Void in
                        self.hidePerson = on;
                        self.tableView.reloadData();
                    }
                }),
                ModelRowConfiguration<PersonCell, Person>(models: self.people)
                    .hideWhen({ (model) -> Bool in
                        return self.hidePerson && model.firstName == "Hide";
                    })
                    .selectionHandler({ (model) -> Bool in
                        return false;
                    })
            ]));
        
        self.configurator.addConfiguration(SectionConfiguration(rowConfigurations:
            [ConstantRowConfiguration<SwitchCell>()
                .additionalCellConfig({ (cell) -> Void in
                    cell.hideSwitch.on = self.hideDisclosure;
                    cell.switchChangedHandler = { (on) -> Void in
                        self.hideDisclosure = on;
                        self.tableView.reloadData();
                    }
                }),
                ConstantRowConfiguration<DisclosureCell>()
                    .additionalCellConfig({ (cell) -> Void in
                        cell.accessoryType = .DisclosureIndicator;
                    }).hideWhen({ () -> Bool in
                        return self.hideDisclosure;
                    })
            ]));

        for animalClass in animals {
            self.configurator.addConfiguration(SectionConfiguration(rowConfiguration:
                ModelRowConfiguration<AnimalCell, Animal>(models: animalClass)));
        }
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

