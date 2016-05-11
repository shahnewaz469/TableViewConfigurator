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

    private static let BASIC_CELL_REUSE_ID = "basicCell"
    private static let PERSON_CELL_REUSE_ID = "personCell"
    private static let DISCLOSURE_CELL_REUSE_ID = "disclosureCell"
    private static let ANIMAL_CELL_REUSE_ID = "animalCell"
    
    @IBOutlet var tableView: UITableView!
    
    private var hidePeople = false
    private var hideJohns = false
    private var hideDisclosure = false
    
    private let people = [Person(firstName: "John", lastName: "Doe", age: 50),
        Person(firstName: "Alex", lastName: "Great", age: 32),
        Person(firstName: "John", lastName: "Wayne", age: 45),
        Person(firstName: "Napoléon", lastName: "Bonaparte", age: 18)]
    
    private let animals = [(scientificClass: "Amphibians", animals: [Animal(name: "American Bullfrog", scientificName: "Rana catesbeiana"), Animal(name: "Fire Salamander", scientificName: "Salamandra salamandra")]),
        (scientificClass: "Birds", animals: [Animal(name: "Loggerhead Shrike", scientificName: "Lanius ludovicianus"), Animal(name: "Pileated Woodpecker", scientificName: "Dryocopus pileatus")]),
        (scientificClass: "Mammals", animals: [Animal(name: "Woodchuck", scientificName: "Marmota monax"), Animal(name: "Wolverine", scientificName: "Gulo gulo")])]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let basicSection = SectionConfiguration(rowConfiguration:
            ConstantRowConfiguration<BasicCell>()
                .height(44.0)).footerTitle("Basic Footer")
        
        let textRow = ConstantRowConfiguration<TextCell>().height(44.0)
        
        let textSection = SectionConfiguration(rowConfigurations:
            [textRow, ConstantRowConfiguration<BasicCell>()
                .additionalConfig({ (cell) in
                    cell.textLabel!.text = "Reset Text"
                })
                .selectionHandler({ () -> Bool in
                    self.configurator!.refreshRowConfiguration(textRow)
                    return true
                })
                .height(44.0)]).headerTitle("Refreshable UITextField")
        
        let peopleRows = ModelRowConfiguration<PersonCell, Person>(models: self.people)
            .hideWhen({ (model) -> Bool in
                return (self.hideJohns && model.firstName == "John") || self.hidePeople
            })
            .heightGenerator { (model) -> CGFloat in
                return 44.0
        };
        
        let peopleSection = SectionConfiguration(rowConfigurations:
            [ConstantRowConfiguration<SwitchCell>()
                .additionalConfig({ (cell) -> Void in
                    cell.hideLabel.text = "Hide All People"
                    cell.hideSwitch.on = self.hidePeople
                    cell.switchChangedHandler = { (on) -> Void in
                        let changeSet = self.configurator!.indexPathChangeSetAfterPerformingOperation({ self.hidePeople = on; })
                        
                        self.tableView.beginUpdates()
                        self.tableView.insertRowsAtIndexPaths(changeSet.insertions, withRowAnimation: .Top)
                        self.tableView.deleteRowsAtIndexPaths(changeSet.deletions, withRowAnimation: .Top)
                        self.tableView.endUpdates()
                    }
                })
                .height(44.0),
                ConstantRowConfiguration<SwitchCell>()
                    .additionalConfig({ (cell) -> Void in
                        cell.hideLabel.text = "Hide Johns"
                        cell.hideSwitch.on = self.hideJohns
                        cell.switchChangedHandler = { (on) -> Void in
                            let changeSet = self.configurator!.indexPathChangeSetAfterPerformingOperation({ self.hideJohns = on })
                            
                            self.tableView.beginUpdates()
                            self.tableView.insertRowsAtIndexPaths(changeSet.insertions, withRowAnimation: .Top)
                            self.tableView.deleteRowsAtIndexPaths(changeSet.deletions, withRowAnimation: .Top)
                            self.tableView.endUpdates()
                        }
                    })
                    .height(44.0), peopleRows,
                ConstantRowConfiguration<BasicCell>()
                    .additionalConfig({ (cell) in
                        cell.textLabel!.text = "Increment Age"
                    })
                    .selectionHandler({ () -> Bool in
                        self.people.forEach({ $0.incrementAge() })
                        self.tableView.reloadRowsAtIndexPaths(self.configurator!.indexPathsForRowConfiguration(peopleRows),
                            withRowAnimation: .Automatic)
                        
                        return true
                    })
                    .height(44.0)]).headerTitle("People")
        
        let disclosureSection = SectionConfiguration(rowConfiguration:
            ConstantRowConfiguration<DisclosureCell>()
                .selectionHandler({ () -> Bool in
                    self.performSegueWithIdentifier("showDetails", sender: self)
                    return true
                })
                .height(44.0))
        
        var configurations = [basicSection, textSection, peopleSection, disclosureSection]

        for animalTuple in animals {
            configurations.append(SectionConfiguration(rowConfiguration:
                ModelRowConfiguration<AnimalCell, Animal>(modelGenerator: { return animalTuple.animals })
                    .selectionHandler({ (model) -> Bool in
                        let alertController = UIAlertController(title: model.name, message: model.scientificName, preferredStyle: .Alert)
                        
                        alertController.addAction(UIAlertAction(title: "Dismiss", style: .Default, handler: nil))
                        self.presentViewController(alertController, animated: true, completion: nil)
                        
                        return true
                    })
                    .height(44.0)).headerTitle(animalTuple.scientificClass))
        }
        
        self.configurator = TableViewConfigurator(tableView: tableView, sectionConfigurations: configurations)
    }
}

