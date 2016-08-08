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
    private var hideAnimals = false
    private var configurator: TableViewConfigurator!
    
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
                .selectionHandler({ self.configurator.refreshRowConfiguration(textRow) })
                .height(44.0)]).headerTitle("Refreshable UITextField")
        
        let peopleRows = ModelRowConfiguration<PersonCell, Person>(models: self.people)
            .hideWhen({ (model) -> Bool in
                return (self.hideJohns && model.firstName == "John") || self.hidePeople
            })
            .heightGenerator { (model) -> CGFloat in
                return 44.0
        }
        
        let peopleSection = SectionConfiguration(rowConfigurations:
            [ConstantRowConfiguration<SwitchCell>()
                .additionalConfig({ (cell) -> Void in
                    cell.hideLabel.text = "Hide All People"
                    cell.hideSwitch.on = self.hidePeople
                    cell.switchChangedHandler = { (on) -> Void in
                        let changeSet = self.configurator.indexPathChangeSetAfterPerformingOperation({ self.hidePeople = on })
                        
                        self.tableView.beginUpdates()
                        self.tableView.insertRowsAtIndexPaths(changeSet.rowInsertions, withRowAnimation: .Top)
                        self.tableView.deleteRowsAtIndexPaths(changeSet.rowDeletions, withRowAnimation: .Top)
                        self.tableView.endUpdates()
                    }
                })
                .height(44.0),
                ConstantRowConfiguration<SwitchCell>()
                    .additionalConfig({ (cell) -> Void in
                        cell.hideLabel.text = "Hide Johns"
                        cell.hideSwitch.on = self.hideJohns
                        cell.switchChangedHandler = { (on) -> Void in
                            let changeSet = self.configurator.indexPathChangeSetAfterPerformingOperation({ self.hideJohns = on })
                            
                            self.tableView.beginUpdates()
                            self.tableView.insertRowsAtIndexPaths(changeSet.rowInsertions, withRowAnimation: .Top)
                            self.tableView.deleteRowsAtIndexPaths(changeSet.rowDeletions, withRowAnimation: .Top)
                            self.tableView.endUpdates()
                        }
                    })
                    .height(44.0), peopleRows,
                ConstantRowConfiguration<BasicCell>()
                    .additionalConfig({ (cell) in
                        cell.textLabel!.text = "Increment Age"
                    })
                    .selectionHandler({
                        self.people.forEach({ $0.incrementAge() })
                        self.tableView.reloadRowsAtIndexPaths(self.configurator.indexPathsForRowConfiguration(peopleRows),
                            withRowAnimation: .Automatic)
                    })
                    .height(44.0)]).headerTitle("People")
        
        
        let disclosureSection = SectionConfiguration(rowConfiguration:
            ConstantRowConfiguration<DisclosureCell>()
                .selectionHandler({
                    self.performSegueWithIdentifier("showDetails", sender: self)
                })
                .height(44.0))
        
        var configurations = [basicSection, textSection, peopleSection, disclosureSection]

        for animalTuple in animals {
            configurations.append(SectionConfiguration(rowConfiguration:
                ModelRowConfiguration<AnimalCell, Animal>(modelGenerator: { return animalTuple.animals })
                    .selectionHandler({ (model) -> Void in
                        let alertController = UIAlertController(title: model.name, message: model.scientificName, preferredStyle: .Alert)
                        
                        alertController.addAction(UIAlertAction(title: "Dismiss", style: .Default, handler: nil))
                        self.presentViewController(alertController, animated: true, completion: nil)
                    })
                    .hideWhen({ (model) -> Bool in
                        return self.hideAnimals
                    })
                    .height(44.0)).headerTitle(animalTuple.scientificClass))
        }
        
        configurations.append(SectionConfiguration(rowConfiguration:
            ConstantRowConfiguration<BasicCell>()
                .additionalConfig({ (cell) in
                    cell.textLabel!.text = "Toggle Animal Sections"
                })
                .selectionHandler({
                    self.configurator.animateChangeSet(self.configurator.indexPathChangeSetAfterPerformingOperation({
                        self.hideAnimals = !self.hideAnimals
                    }))
                })
                .height(44.0)))
        
        self.configurator = TableViewConfigurator(tableView: tableView, sectionConfigurations: configurations)
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.configurator.numberOfSectionsInTableView(tableView)
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.configurator.tableView(tableView, titleForHeaderInSection: section)
    }
    
    func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return self.configurator.tableView(tableView, titleForFooterInSection: section)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.configurator.tableView(tableView, numberOfRowsInSection: section)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return self.configurator.tableView(tableView, cellForRowAtIndexPath: indexPath)
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return self.configurator.tableView(tableView, heightForRowAtIndexPath: indexPath)
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        self.configurator.tableView(tableView, didSelectRowAtIndexPath: indexPath)
    }
}

