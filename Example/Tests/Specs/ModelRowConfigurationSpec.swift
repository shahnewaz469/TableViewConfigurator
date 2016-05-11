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
    
    private static let MODEL_CONFIGURABLE_CELL_REUSE_ID = "modelConfigurableCell";
    private let things = [Thing(name: "Tree"), Thing(name: "Frisbee"), Thing(name: "Hatchback")];
    
    override func spec() {
        describe("a model row configuration") {
            var tableView: UITableViewMock!;
            var rowConfiguration: ModelRowConfiguration<ModelConfigurableCell, Thing>!;
            var implicitIdRowConfiguration: ModelRowConfiguration<ModelImplicitReuseIdCell, Thing>!;
            
            beforeEach {
                tableView = UITableViewMock();
                tableView.registerClass(ModelConfigurableCell.self, forCellReuseIdentifier: ModelRowConfigurationSpec.MODEL_CONFIGURABLE_CELL_REUSE_ID);
                tableView.registerClass(ModelImplicitReuseIdCell.self, forCellReuseIdentifier: ModelImplicitReuseIdCell.buildReuseIdentifier());
                rowConfiguration = ModelRowConfiguration(models: self.things);
                implicitIdRowConfiguration = ModelRowConfiguration(models: self.things);
            }
            
            describe("its cell reuse id") {
                it("is set correctly when explicitly defined") {
                    expect(rowConfiguration.cellReuseId(ModelRowConfigurationSpec.MODEL_CONFIGURABLE_CELL_REUSE_ID).cellReuseId)
                        .to(equal(ModelRowConfigurationSpec.MODEL_CONFIGURABLE_CELL_REUSE_ID));
                }
            }
            
            describe("its produced cell") {
                it("is the correct type when cellReuseId explicitly defined") {
                    let cell = rowConfiguration
                        .cellReuseId(ModelRowConfigurationSpec.MODEL_CONFIGURABLE_CELL_REUSE_ID)
                        .cellForRow(0, inTableView: tableView);
                    
                    expect(cell).to(beAnInstanceOf(ModelConfigurableCell));
                }
                
                it("is the correct type when cellReuseId implicitly defined") {
                    expect(implicitIdRowConfiguration.cellForRow(0, inTableView: tableView)).to(beAnInstanceOf(ModelImplicitReuseIdCell));
                }
                
                it("is nil when asking for non-existant row") {
                    expect(implicitIdRowConfiguration.cellForRow(3, inTableView: tableView)).to(beNil());
                }
                
                it("is configured correctly") {
                    let cell = implicitIdRowConfiguration.cellForRow(1, inTableView: tableView) as? ModelImplicitReuseIdCell;
                    
                    expect(cell).toNot(beNil());
                    expect(cell?.model).toNot(beNil());
                    expect(cell?.model?.name).to(equal("Frisbee"));
                }
                
                it("is configured correctly when model is generated") {
                    let generatedModelRowConfiguration = ModelRowConfiguration<ModelImplicitReuseIdCell, Thing>(modelGenerator: { () -> [Thing] in
                        return self.things;
                    })
                    let cell = generatedModelRowConfiguration.cellForRow(2, inTableView: tableView) as? ModelImplicitReuseIdCell;
                    
                    expect(cell).toNot(beNil());
                    expect(cell?.model).toNot(beNil());
                    expect(cell?.model?.name).to(equal("Hatchback"));
                }
                
                it("is refreshed") {
                    let indexPath = NSIndexPath(forRow: 1, inSection: 0)
                    let cell = implicitIdRowConfiguration.cellForRow(indexPath.row, inTableView: tableView) as? ModelImplicitReuseIdCell;
                    
                    expect(cell?.model).toNot(beNil());
                    
                    cell?.model = nil
                    expect(cell?.model).to(beNil())
                    
                    tableView.storeCell(cell!, forIndexPath: indexPath)
                    implicitIdRowConfiguration.refreshCellForRow(indexPath.row, withIndexPath: indexPath, inTableView: tableView)
                    expect(cell?.model).toNot(beNil())
                }
            }
            
            describe("its height") {
                it("is set correctly for existant row") {
                    expect(rowConfiguration.height(100.0).heightForRow(0))
                        .to(equal(100.0));
                }
                
                it("is set correctly for height generator") {
                    expect(rowConfiguration.heightGenerator({ (model) -> CGFloat in
                        return 100.0
                    }).heightForRow(0))
                        .to(equal(100.0));
                }
                
                it("is nil when asking for non-existant row") {
                    expect(rowConfiguration.height(100.0).heightForRow(3))
                        .to(beNil());
                }
            }
            
            describe("its estimated height") {
                it("is set correctly for existant row") {
                    expect(rowConfiguration.estimatedHeight(200.0).estimatedHeightForRow(0))
                        .to(equal(200.0));
                }
                
                it("is set correctly for estimated height generator") {
                    expect(rowConfiguration.estimatedHeightGenerator({ (model) -> CGFloat in
                        return 200.0
                    }).estimatedHeightForRow(0))
                        .to(equal(200.0));
                }
                
                it("is nil when asking for non-existant row") {
                    expect(rowConfiguration.estimatedHeight(100.0).estimatedHeightForRow(3))
                        .to(beNil());
                }
            }
            
            describe("its visible row count") {
                context("when visible") {
                    it("is correct") {
                        expect(rowConfiguration.numberOfRows(false)).to(equal(3));
                    }
                }
                
                context("when hidden") {
                    it("is correct") {
                        expect(rowConfiguration.hideWhen({ return $0 === self.things[0] || $0 === self.things[2] }).numberOfRows(false)).to(equal(1));
                    }
                }
            }
            
            describe("its total row count") {
                context("when visible") {
                    it("is correct") {
                        expect(rowConfiguration.numberOfRows(true)).to(equal(3));
                    }
                }
                
                context("when hidden") {
                    it("is correct") {
                        expect(rowConfiguration.hideWhen({ return $0 === self.things[0] || $0 === self.things[2] }).numberOfRows(true)).to(equal(3));
                    }
                }
            }
            
            describe("its row visibility") {
                it("is correct when visible") {
                    expect(rowConfiguration.rowIsVisible(1)).to(beTrue());
                }
                
                it("is correct when hidden") {
                    expect(rowConfiguration.hideWhen({ return $0 === self.things[1] }).rowIsVisible(1)).to(beFalse());
                }
                
                it("is nil when asking for non-existant row") {
                    expect(rowConfiguration.rowIsVisible(3)).to(beNil());
                }
            }
            
            describe("its selection handler") {
                it("is invoked when selected") {
                    var selectionHandlerInvoked = false;
                    
                    rowConfiguration.selectionHandler({ (model) -> Bool in
                        selectionHandlerInvoked = true; return true;
                    }).didSelectRow(2);
                    
                    expect(selectionHandlerInvoked).to(beTrue());
                }
                
                it("is not invoked when selecting non-existant row") {
                    var selectionHandlerInvoked = false;
                    
                    rowConfiguration.selectionHandler({ (model) -> Bool in
                        selectionHandlerInvoked = true; return true;
                    }).didSelectRow(5);
                    
                    expect(selectionHandlerInvoked).to(beFalse());
                }
            }
            
            describe("its additional config") {
                it("is applied when retrieving a cell") {
                    let cell = implicitIdRowConfiguration
                        .additionalConfig({ (cell, model) -> Void in
                            cell.additionallyConfigured = true;
                        }).cellForRow(2, inTableView: tableView) as? ModelImplicitReuseIdCell;
                    
                    expect(cell).toNot(beNil());
                    expect(cell?.additionallyConfigured).to(beTrue());
                }
            }
        }
    }
}
