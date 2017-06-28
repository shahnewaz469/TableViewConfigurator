//
//  ModelRowConfigurationSpec.swift
//  TableViewConfigurator
//
//  Created by John Volk on 3/4/16.
//  Copyright © 2016 John Volk. All rights reserved.
//

import Quick
import Nimble
@testable import TableViewConfigurator

class ModelRowConfigurationSpec: QuickSpec {
    
    private static let MODEL_CONFIGURABLE_CELL_REUSE_ID = "modelConfigurableCell"
    private let things = [Thing(name: "Tree"), Thing(name: "Frisbee"), Thing(name: "Hatchback")]
    
    override func spec() {
        describe("a model row configuration") {
            var tableView: UITableViewMock!
            var rowConfiguration: ModelRowConfiguration<ModelConfigurableCell, Thing>!
            var implicitIdRowConfiguration: ModelRowConfiguration<ModelImplicitReuseIdCell, Thing>!
            
            beforeEach {
                tableView = UITableViewMock()
                tableView.register(ModelConfigurableCell.self, forCellReuseIdentifier: ModelRowConfigurationSpec.MODEL_CONFIGURABLE_CELL_REUSE_ID)
                tableView.register(ModelImplicitReuseIdCell.self, forCellReuseIdentifier: ModelImplicitReuseIdCell.buildReuseIdentifier())
                rowConfiguration = ModelRowConfiguration(models: self.things)
                implicitIdRowConfiguration = ModelRowConfiguration(models: self.things)
            }
            
            describe("its cell reuse id") {
                it("is set correctly when explicitly defined") {
                    expect(rowConfiguration.cellReuseId(ModelRowConfigurationSpec.MODEL_CONFIGURABLE_CELL_REUSE_ID).cellReuseId)
                        .to(equal(ModelRowConfigurationSpec.MODEL_CONFIGURABLE_CELL_REUSE_ID))
                }
            }
            
            describe("its produced cell") {
                it("is the correct type when cellReuseId explicitly defined") {
                    let cell = rowConfiguration
                        .cellReuseId(ModelRowConfigurationSpec.MODEL_CONFIGURABLE_CELL_REUSE_ID)
                        .cellFor(row: 0, inTableView: tableView)
                    
                    expect(cell).to(beAnInstanceOf(ModelConfigurableCell.self))
                }
                
                it("is the correct type when cellReuseId implicitly defined") {
                    expect(implicitIdRowConfiguration.cellFor(row: 0, inTableView: tableView)).to(beAnInstanceOf(ModelImplicitReuseIdCell.self))
                }
                
                it("is configured correctly") {
                    let cell = implicitIdRowConfiguration.cellFor(row: 1, inTableView: tableView) as? ModelImplicitReuseIdCell
                    
                    expect(cell).toNot(beNil())
                    expect(cell?.model).toNot(beNil())
                    expect(cell?.model?.name).to(equal("Frisbee"))
                }
                
                it("is configured correctly when model is generated") {
                    let generatedModelRowConfiguration = ModelRowConfiguration<ModelImplicitReuseIdCell, Thing>(modelGenerator: { () -> [Thing] in
                        return self.things
                    })
                    let cell = generatedModelRowConfiguration.cellFor(row: 2, inTableView: tableView) as? ModelImplicitReuseIdCell
                    
                    expect(cell).toNot(beNil())
                    expect(cell?.model).toNot(beNil())
                    expect(cell?.model?.name).to(equal("Hatchback"))
                }
                
                it("is refreshed") {
                    let indexPath = IndexPath(row: 1, section: 0)
                    let cell = implicitIdRowConfiguration.cellFor(row: indexPath.row, inTableView: tableView) as? ModelImplicitReuseIdCell
                    
                    expect(cell?.model).toNot(beNil())
                    
                    cell?.model = nil
                    expect(cell?.model).to(beNil())
                    
                    tableView.storeCell(cell!, forIndexPath: indexPath)
                    implicitIdRowConfiguration.refreshCellFor(row: indexPath.row, withIndexPath: indexPath, inTableView: tableView)
                    expect(cell?.model).toNot(beNil())
                }
            }
            
            describe("its height") {
                it("is set correctly for row") {
                    expect(rowConfiguration.height(100.0).heightFor(row: 0))
                        .to(equal(100.0))
                }
                
                it("is set correctly for height generator") {
                    expect(rowConfiguration.heightGenerator({ (model) -> CGFloat in
                        return 100.0
                    }).heightFor(row: 0))
                        .to(equal(100.0))
                }
            }
            
            describe("its estimated height") {
                it("is set correctly for row") {
                    expect(rowConfiguration.estimatedHeight(200.0).estimatedHeightFor(row: 0))
                        .to(equal(200.0))
                }
                
                it("is set correctly for estimated height generator") {
                    expect(rowConfiguration.estimatedHeightGenerator({ (model) -> CGFloat in
                        return 200.0
                    }).estimatedHeightFor(row: 0))
                        .to(equal(200.0))
                }
            }
            
            describe("its visible row count") {
                context("when visible") {
                    it("is correct") {
                        expect(rowConfiguration.numberOfRows()).to(equal(3))
                    }
                }
                
                context("when hidden") {
                    it("is correct") {
                        expect(rowConfiguration.hideWhen({ return $0 === self.things[0] || $0 === self.things[2] }).numberOfRows()).to(equal(1))
                    }
                }
            }
            
            describe("its selection handler") {
                it("is invoked when selected") {
                    var selectionHandlerInvoked = false
                    
                    rowConfiguration.selectionHandler({ (model) -> Void in
                        selectionHandlerInvoked = true
                    }).didSelect(row: 2)
                    
                    expect(selectionHandlerInvoked).to(beTrue())
                }
            }
            
            describe("its additional config") {
                it("is applied when retrieving a cell") {
                    let cell = implicitIdRowConfiguration
                        .additionalConfig({ (cell, model, index) -> Void in
                            cell.additionallyConfigured = true
                        }).cellFor(row: 2, inTableView: tableView) as? ModelImplicitReuseIdCell
                    
                    expect(cell).toNot(beNil())
                    expect(cell?.additionallyConfigured).to(beTrue())
                }
            }
        }
    }
}
