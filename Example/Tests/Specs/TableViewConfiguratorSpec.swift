//
//  TableViewConfiguratorSpec.swift
//  TableViewConfigurator
//
//  Created by John Volk on 3/4/16.
//  Copyright © 2016 John Volk. All rights reserved.
//

import Foundation

import Quick
import Nimble
@testable import TableViewConfigurator

class TableViewConfiguratorSpec: QuickSpec {
    
    private static let CONFIGURABLE_CELL_REUSE_ID = "configurableCell"
    private static let MODEL_CONFIGURABLE_CELL_REUSE_ID = "modelConfigurableCell"
    private let things = [Thing(name: "Cup"), Thing(name: "Chair"), Thing(name: "Photo")]
    
    override func spec() {
        describe("a table view configurator") {
            var tableView: UITableViewMock!
            var constantRowConfiguration: ConstantRowConfiguration<ImplicitReuseIdCell>!
            var modelRowConfiguration: ModelRowConfiguration<ModelImplicitReuseIdCell, Thing>!
            var firstSectionConfiguration: SectionConfiguration!
            var secondSectionConfiguration: SectionConfiguration!
            var configurator: TableViewConfigurator!
            
            beforeEach {
                tableView = UITableViewMock()
                tableView.register(ImplicitReuseIdCell.self, forCellReuseIdentifier: ImplicitReuseIdCell.buildReuseIdentifier())
                tableView.register(ModelImplicitReuseIdCell.self, forCellReuseIdentifier: ModelImplicitReuseIdCell.buildReuseIdentifier())
                modelRowConfiguration = ModelRowConfiguration(models: self.things)
                constantRowConfiguration = ConstantRowConfiguration()
                firstSectionConfiguration = SectionConfiguration(rowConfiguration: modelRowConfiguration)
                secondSectionConfiguration = SectionConfiguration(rowConfiguration: constantRowConfiguration)
                configurator = TableViewConfigurator(tableView: tableView, sectionConfigurations: [firstSectionConfiguration, secondSectionConfiguration])
            }
            
            describe("its index paths for row configuration") {
                it("is correct") {
                    expect(configurator.indexPathsFor(rowConfiguration: modelRowConfiguration))
                        .to(equal([IndexPath(row: 0, section: 0), IndexPath(row: 1, section: 0), IndexPath(row: 2, section: 0)]))
                    expect(configurator.indexPathsFor(rowConfiguration: constantRowConfiguration))
                        .to(equal([IndexPath(row: 0, section: 1)]))
                    
                    _ = modelRowConfiguration.hideWhen({ $0 === self.things[2] })
                    expect(configurator.indexPathsFor(rowConfiguration: modelRowConfiguration))
                        .to(equal([IndexPath(row: 0, section: 0), IndexPath(row: 1, section: 0)]))
                    
                    _ = constantRowConfiguration.hideWhen({ return true })
                    expect(configurator.indexPathsFor(rowConfiguration: constantRowConfiguration))
                        .to(beEmpty())
                }
            }
            
            describe("its index path change set") {
                it("is correct") {
                    var hideModels = false
                    var hideConstant = false
                    var changeSet = configurator.changeSetAfterPerformingOperation({ })
                    
                    expect(changeSet.rowInsertions).to(beEmpty())
                    expect(changeSet.rowDeletions).to(beEmpty())
                    expect(changeSet.sectionInsertions).to(equal(IndexSet()))
                    expect(changeSet.sectionDeletions).to(equal(IndexSet()))
                    
                    _ = modelRowConfiguration.hideWhen({ (model) -> Bool in
                        return hideModels && model.name == "Chair"
                    })
                    changeSet = configurator.changeSetAfterPerformingOperation({ hideModels = true })
                    expect(changeSet.rowInsertions).to(beEmpty())
                    expect(changeSet.rowDeletions).to(equal([IndexPath(row: 1, section: 0)]))
                    expect(changeSet.sectionInsertions).to(equal(IndexSet()))
                    expect(changeSet.sectionDeletions).to(equal(IndexSet()))
                    
                    _ = constantRowConfiguration.hideWhen({ return hideConstant })
                    changeSet = configurator.changeSetAfterPerformingOperation({ hideConstant = true })
                    expect(changeSet.rowInsertions).to(beEmpty())
                    expect(changeSet.rowDeletions).to(beEmpty())
                    expect(changeSet.sectionInsertions).to(equal(IndexSet()))
                    expect(changeSet.sectionDeletions).to(equal(IndexSet(integer: 1)))
                    
                    changeSet = configurator.changeSetAfterPerformingOperation({ () -> Void in
                        hideModels = false
                        hideConstant = false
                    })
                    expect(changeSet.rowDeletions).to(beEmpty())
                    expect(changeSet.rowInsertions).to(equal([IndexPath(row: 1, section: 0)]))
                    expect(changeSet.sectionInsertions).to(equal(IndexSet(integer: 1)))
                    expect(changeSet.sectionDeletions).to(equal(IndexSet()))
                }
            }
            
            describe("its number of sections") {
                it("is correct") {
                    expect(configurator.numberOfSections(in: tableView)).to(equal(2))
                }
            }
            
            describe("its number of rows") {
                it("is correct for constant row section") {
                    expect(configurator.tableView(tableView, numberOfRowsInSection: 0)).to(equal(3))
                }
                
                it("is correct for model row section") {
                    expect(configurator.tableView(tableView, numberOfRowsInSection: 1)).to(equal(1))
                }
            }
            
            describe("its produced cell") {
                it("is correct for constant row section") {
                    expect(configurator.tableView(tableView, cellForRowAt: IndexPath(row: 0, section: 1))).to(beAnInstanceOf(ImplicitReuseIdCell.self))
                }
                
                it("is correct for model row section") {
                    expect(configurator.tableView(tableView, cellForRowAt: IndexPath(row: 1, section: 0))).to(beAnInstanceOf(ModelImplicitReuseIdCell.self))
                }
                
                it("is refreshed for constant row section") {
                    let indexPath = IndexPath(row: 0, section: 1)
                    let cell = configurator.tableView(tableView, cellForRowAt: indexPath) as? ImplicitReuseIdCell
                    
                    expect(cell?.configured).to(beTrue())
                    
                    cell?.configured = false
                    expect(cell?.configured).to(beFalse())
                    
                    tableView.storeCell(cell!, forIndexPath: indexPath)
                    configurator.refreshAllRowConfigurations()
                    expect(cell?.configured).to(beTrue())
                }
                
                it("is refreshed for model row section") {
                    let indexPath = IndexPath(row: 1, section: 0)
                    let cell = configurator.tableView(tableView, cellForRowAt: indexPath) as? ModelImplicitReuseIdCell
                    
                    expect(cell?.model).toNot(beNil())
                    
                    cell?.model = nil
                    expect(cell?.model).to(beNil())
                    
                    tableView.storeCell(cell!, forIndexPath: indexPath)
                    configurator.refreshAllRowConfigurations()
                    expect(cell?.model).toNot(beNil())
                }
            }
            
            describe("its height") {
                it("is correct for constant row section") {
                    _ = constantRowConfiguration.height(100.0)
                    expect(configurator.tableView(tableView, heightForRowAt: IndexPath(row: 0, section: 1))).to(equal(100.0))
                }
                
                it("is correct for model row section") {
                    _ = modelRowConfiguration.height(200.0)
                    expect(configurator.tableView(tableView, heightForRowAt: IndexPath(row: 2, section: 0))).to(equal(200.0))
                }
            }
            
            describe("its estimated height") {
                it("is correct for constant row section") {
                    _ = constantRowConfiguration.estimatedHeight(100.0)
                    expect(configurator.tableView(tableView, estimatedHeightForRowAt: IndexPath(row: 0, section: 1))).to(equal(100.0))
                }
                
                it("is correct for model row section") {
                    _ = modelRowConfiguration.estimatedHeight(200.0)
                    expect(configurator.tableView(tableView, estimatedHeightForRowAt: IndexPath(row: 2, section: 0))).to(equal(200.0))
                }
            }
            
            describe("its select row behavior") {
                var constantRowSelected: Bool!
                var modelRowSelected: Bool!
                
                beforeEach {
                    constantRowSelected = false
                    modelRowSelected = false
                    _ = constantRowConfiguration.selectionHandler({ constantRowSelected = true })
                    _ = modelRowConfiguration.selectionHandler({ (model) -> Void in
                        modelRowSelected = true
                    })
                }
                
                it("is correct for constant row section") {
                    configurator.tableView(tableView, didSelectRowAt: IndexPath(row: 0, section: 1))
                    expect(constantRowSelected).to(beTrue())
                    expect(modelRowSelected).to(beFalse())
                }
                
                it("is correct for model row section") {
                    configurator.tableView(tableView, didSelectRowAt: IndexPath(row: 2, section: 0))
                    expect(constantRowSelected).to(beFalse())
                    expect(modelRowSelected).to(beTrue())
                }
            }
        }
    }
}
