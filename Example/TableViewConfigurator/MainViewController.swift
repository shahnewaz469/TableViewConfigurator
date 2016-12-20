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
                .selectionHandler({ self.configurator.refresh(rowConfiguration: textRow) })
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
                    cell.hideSwitch.isOn = self.hidePeople
                    cell.switchChangedHandler = { (on) -> Void in
                        self.configurator.animate(changeSet: self.configurator.changeSetAfterPerformingOperation({ self.hidePeople = on }),
                            insertRowAnimation: .top, deleteRowAnimation: .top)
                    }
                })
                .height(44.0),
                ConstantRowConfiguration<SwitchCell>()
                    .additionalConfig({ (cell) -> Void in
                        cell.hideLabel.text = "Hide Johns"
                        cell.hideSwitch.isOn = self.hideJohns
                        cell.switchChangedHandler = { (on) -> Void in
                            self.configurator.animate(changeSet: self.configurator.changeSetAfterPerformingOperation({ self.hideJohns = on }),
                                insertRowAnimation: .top, deleteRowAnimation: .top)
                        }
                    })
                    .height(44.0), peopleRows,
                ConstantRowConfiguration<BasicCell>()
                    .additionalConfig({ (cell) in
                        cell.textLabel!.text = "Increment Age"
                    })
                    .selectionHandler({
                        self.people.forEach({ $0.incrementAge() })
                        self.tableView.reloadRows(at: self.configurator.indexPathsFor(rowConfiguration: peopleRows), with: .automatic)
                    })
                    .height(44.0)]).headerTitle("People")
        
        
        let disclosureSection = SectionConfiguration(rowConfiguration:
            ConstantRowConfiguration<DisclosureCell>()
                .selectionHandler({
                    self.performSegue(withIdentifier: "showDetails", sender: self)
                })
                .height(44.0))
        
        var configurations = [basicSection, textSection, peopleSection, disclosureSection]

        for animalTuple in animals {
            configurations.append(SectionConfiguration(rowConfiguration:
                ModelRowConfiguration<AnimalCell, Animal>(modelGenerator: { return animalTuple.animals })
                    .selectionHandler({ (model, index) -> Void in
                        let alertController = UIAlertController(title: model.name, message: model.scientificName, preferredStyle: .alert)
                        
                        alertController.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
                        self.present(alertController, animated: true, completion: nil)
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
                    self.configurator.animate(changeSet: self.configurator.changeSetAfterPerformingOperation({
                        self.hideAnimals = !self.hideAnimals
                    }))
                })
                .height(44.0)))
        
        self.configurator = TableViewConfigurator(tableView: tableView, sectionConfigurations: configurations)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.configurator.numberOfSections(in: tableView)
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.configurator.tableView(tableView, titleForHeaderInSection: section)
    }
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return self.configurator.tableView(tableView, titleForFooterInSection: section)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.configurator.tableView(tableView, numberOfRowsInSection: section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return self.configurator.tableView(tableView, cellForRowAt: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.configurator.tableView(tableView, heightForRowAt: indexPath)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.configurator.tableView(tableView, didSelectRowAt: indexPath)
    }
}

