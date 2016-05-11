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
    
    private static let CONFIGURABLE_CELL_REUSE_ID = "configurableCell";
    private static let MODEL_CONFIGURABLE_CELL_REUSE_ID = "modelConfigurableCell";
    private let things = [Thing(name: "Cup"), Thing(name: "Chair"), Thing(name: "Photo")];
    
    override func spec() {
        describe("a table view configurator") {
            var tableView: UITableView!;
            var constantRowConfiguration: ConstantRowConfiguration<ImplicitReuseIdCell>!;
            var modelRowConfiguration: ModelRowConfiguration<ModelImplicitReuseIdCell, Thing>!;
            var firstSectionConfiguration: SectionConfiguration!;
            var secondSectionConfiguration: SectionConfiguration!;
            var configurator: TableViewConfigurator!;
            
            beforeEach {
                tableView = UITableView();
                tableView.registerClass(ImplicitReuseIdCell.self, forCellReuseIdentifier: ImplicitReuseIdCell.buildReuseIdentifier());
                tableView.registerClass(ModelImplicitReuseIdCell.self, forCellReuseIdentifier: ModelImplicitReuseIdCell.buildReuseIdentifier());
                modelRowConfiguration = ModelRowConfiguration(models: self.things);
                constantRowConfiguration = ConstantRowConfiguration();
                firstSectionConfiguration = SectionConfiguration(rowConfiguration: modelRowConfiguration);
                secondSectionConfiguration = SectionConfiguration(rowConfiguration: constantRowConfiguration);
                configurator = TableViewConfigurator(tableView: tableView, sectionConfigurations: [firstSectionConfiguration, secondSectionConfiguration]);
            }
            
            describe("its index path change set") {
                it("is correct") {
                    var hideModels = false;
                    var hideConstant = false;
                    var changeSet = configurator.indexPathChangeSetAfterPerformingOperation({ });
                    
                    expect(changeSet.insertions).to(beEmpty());
                    expect(changeSet.deletions).to(beEmpty());
                    
                    modelRowConfiguration.hideWhen({ (model) -> Bool in
                        return hideModels;
                    });
                    changeSet = configurator.indexPathChangeSetAfterPerformingOperation({ hideModels = true });
                    expect(changeSet.insertions).to(beEmpty());
                    expect(changeSet.deletions).to(equal([NSIndexPath(forRow: 0, inSection: 0), NSIndexPath(forRow: 1, inSection: 0), NSIndexPath(forRow: 2, inSection: 0)]));
                    
                    constantRowConfiguration.hideWhen({ return hideConstant });
                    changeSet = configurator.indexPathChangeSetAfterPerformingOperation({ hideConstant = true });
                    expect(changeSet.insertions).to(beEmpty());
                    expect(changeSet.deletions).to(equal([NSIndexPath(forRow: 0, inSection: 1)]));
                    
                    changeSet = configurator.indexPathChangeSetAfterPerformingOperation({ () -> Void in
                        hideModels = false;
                        hideConstant = false;
                    });
                    expect(changeSet.deletions).to(beEmpty());
                    expect(changeSet.insertions).to(equal([NSIndexPath(forRow: 0, inSection: 0), NSIndexPath(forRow: 1, inSection: 0), NSIndexPath(forRow: 2, inSection: 0),
                        NSIndexPath(forRow: 0, inSection: 1)]));
                }
            }
            
            describe("its number of sections") {
                it("is correct") {
                    expect(configurator.numberOfSectionsInTableView(tableView)).to(equal(2));
                }
            }
            
            describe("its number of rows") {
                it("is correct for constant row section") {
                    expect(configurator.tableView(tableView, numberOfRowsInSection: 0)).to(equal(3));
                }
                
                it("is correct for model row section") {
                    expect(configurator.tableView(tableView, numberOfRowsInSection: 1)).to(equal(1));
                }
            }
            
            describe("its produced cell") {
                it("is correct for constant row section") {
                    expect(configurator.tableView(tableView, cellForRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 1))).to(beAnInstanceOf(ImplicitReuseIdCell));
                }
                
                it("is correct for model row section") {
                    expect(configurator.tableView(tableView, cellForRowAtIndexPath: NSIndexPath(forRow: 1, inSection: 0))).to(beAnInstanceOf(ModelImplicitReuseIdCell));
                }
            }
            
            describe("its height") {
                it("is correct for constant row section") {
                    constantRowConfiguration.height(100.0);
                    expect(configurator.tableView(tableView, heightForRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 1))).to(equal(100.0));
                }
                
                it("is correct for model row section") {
                    modelRowConfiguration.height(200.0);
                    expect(configurator.tableView(tableView, heightForRowAtIndexPath: NSIndexPath(forRow: 2, inSection: 0))).to(equal(200.0));
                }
            }
            
            describe("its estimated height") {
                it("is correct for constant row section") {
                    constantRowConfiguration.estimatedHeight(100.0);
                    expect(configurator.tableView(tableView, estimatedHeightForRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 1))).to(equal(100.0));
                }
                
                it("is correct for model row section") {
                    modelRowConfiguration.estimatedHeight(200.0);
                    expect(configurator.tableView(tableView, estimatedHeightForRowAtIndexPath: NSIndexPath(forRow: 2, inSection: 0))).to(equal(200.0));
                }
            }
            
            describe("its select row behavior") {
                var constantRowSelected: Bool!;
                var modelRowSelected: Bool!;
                
                beforeEach {
                    constantRowSelected = false;
                    modelRowSelected = false;
                    constantRowConfiguration.selectionHandler({ constantRowSelected = true; return true; });
                    modelRowConfiguration.selectionHandler({ (model) -> Bool in
                        modelRowSelected = true; return true;
                    });
                }
                
                it("is correct for constant row section") {
                    configurator.tableView(tableView, didSelectRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 1));
                    expect(constantRowSelected).to(beTrue());
                    expect(modelRowSelected).to(beFalse());
                }
                
                it("is correct for model row section") {
                    configurator.tableView(tableView, didSelectRowAtIndexPath: NSIndexPath(forRow: 2, inSection: 0));
                    expect(constantRowSelected).to(beFalse());
                    expect(modelRowSelected).to(beTrue());
                }
            }
        }
    }
}