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
        
        self.tableView.rowHeight = UITableViewAutomaticDimension;
        
        // TODO: measureHeight()
        
        self.configurator = TableViewConfigurator();
        
        self.configurator.addConfiguration(SectionConfiguration(rowConfiguration:
            ConstantRowConfiguration<BasicCell>()
                .height(44.0)));
        
        self.configurator.addConfiguration(SectionConfiguration(rowConfigurations:
            [ModelRowConfiguration<PersonCell, Person>(models: self.people)
                .selectionHandler({ (model) -> Bool in
                    return true;
                })
                .height(44.0)]));
        
        let disclosureConfig = ConstantRowConfiguration<DisclosureCell>()
            .additionalCellConfig({ (cell) -> Void in
                cell.accessoryType = .DisclosureIndicator;
            })
            .hideWhen({ () -> Bool in
                return self.hideDisclosure;
            })
            .height(44.0);
        
        self.configurator.addConfiguration(SectionConfiguration(rowConfigurations:
            [ConstantRowConfiguration<SwitchCell>()
                .additionalCellConfig({ (cell) -> Void in
                    cell.hideSwitch.on = self.hideDisclosure;
                    cell.switchChangedHandler = { (on) -> Void in
                        self.hideDisclosure = on;
                        
                        if let indexPath = self.configurator.indexPathForRowConfiguration(disclosureConfig) {
                            if on {
                                self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic);
                            } else {
                                self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic);
                            }
                        }
                    }
                })
                .height(44.0), disclosureConfig]));

        for animalClass in animals {
            self.configurator.addConfiguration(SectionConfiguration(rowConfiguration:
                ModelRowConfiguration<AnimalCell, Animal>(models: animalClass)
                    .height(44.0)));
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
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return self.configurator.tableView(tableView, heightForRowAtIndexPath: indexPath);
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.configurator.tableView(tableView, didSelectRowAtIndexPath: indexPath);
    }
}

