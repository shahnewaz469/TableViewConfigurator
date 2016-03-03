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
    private var hidePeople = false;
    private var hideDisclosure = false;
    
    private let people = [Person(firstName: "John", lastName: "Doe", age: 50),
        Person(firstName: "Alex", lastName: "Great", age: 32),
        Person(firstName: "Napoléon", lastName: "Bonaparte", age: 18)];
    
    private let animals = [[Animal(name: "American Bullfrog", scientificName: "Rana catesbeiana"), Animal(name: "Fire Salamander", scientificName: "Salamandra salamandra")],
        [Animal(name: "Loggerhead Shrike", scientificName: "Lanius ludovicianus"), Animal(name: "Pileated Woodpecker", scientificName: "Dryocopus pileatus")],
        [Animal(name: "Woodchuck", scientificName: "Marmota monax"), Animal(name: "Wolverine", scientificName: "Gulo gulo")]];
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        let basicSection = SectionConfiguration(rowConfiguration:
            ConstantRowConfiguration<BasicCell>()
                .height(44.0));
        
        let peopleRows = ModelRowConfiguration<PersonCell, Person>(models: self.people)
            .hideWhen({ (model) -> Bool in
                return self.hidePeople;
            })
            .height(44.0);
        
        let peopleSection = SectionConfiguration(rowConfigurations:
            [ConstantRowConfiguration<SwitchCell>()
                .additionalConfig({ (cell) -> Void in
                    let hideIndexPaths = self.configurator.indexPathsForRowConfiguration(peopleRows);
                    
                    cell.hideSwitch.on = self.hidePeople;
                    cell.switchChangedHandler = { (on) -> Void in
                        self.hidePeople = on;
                        
                        if let indexPaths = hideIndexPaths {
                            if on {
                                self.tableView.deleteRowsAtIndexPaths(indexPaths, withRowAnimation: .Top);
                            } else {
                                self.tableView.insertRowsAtIndexPaths(indexPaths, withRowAnimation: .Top);
                            }
                        }
                    }
                })
                .height(44.0), peopleRows]);
        
        let disclosureSection = SectionConfiguration(rowConfiguration:
            ConstantRowConfiguration<DisclosureCell>()
                .selectionHandler({ () -> Bool in
                    self.performSegueWithIdentifier("showDetails", sender: self);
                    return true;
                })
                .height(44.0));
        
        var configurations = [basicSection, peopleSection, disclosureSection];

        for animalClass in animals {
            configurations.append(SectionConfiguration(rowConfiguration:
                ModelRowConfiguration<AnimalCell, Animal>(models: animalClass)
                    .selectionHandler({ (model) -> Bool in
                        let alertController = UIAlertController(title: model.name, message: model.scientificName, preferredStyle: .Alert);
                        
                        alertController.addAction(UIAlertAction(title: "Dismiss", style: .Default, handler: nil));
                        self.presentViewController(alertController, animated: true, completion: nil);
                        
                        return true;
                    })
                    .height(44.0)));
        }
        
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
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return self.configurator.tableView(tableView, heightForRowAtIndexPath: indexPath);
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.configurator.tableView(tableView, didSelectRowAtIndexPath: indexPath);
    }
}

