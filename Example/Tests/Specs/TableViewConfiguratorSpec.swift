//
//  TableViewConfiguratorSpec.swift
//  TableViewConfigurator
//
//  Created by John Volk on 3/4/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
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
                tableView.registerClass(ImplicitReuseIdCell.self, forCellReuseIdentifier: ImplicitReuseIdCell.REUSE_ID);
                tableView.registerClass(ModelImplicitReuseIdCell.self, forCellReuseIdentifier: ModelImplicitReuseIdCell.REUSE_ID);
                constantRowConfiguration = ConstantRowConfiguration();
                modelRowConfiguration = ModelRowConfiguration(models: self.things);
                firstSectionConfiguration = SectionConfiguration(rowConfiguration: constantRowConfiguration);
                secondSectionConfiguration = SectionConfiguration(rowConfiguration: modelRowConfiguration);
                configurator = TableViewConfigurator(tableView: tableView, sectionConfigurations: [firstSectionConfiguration, secondSectionConfiguration]);
            }
            
            describe("its index paths result") {
                it("is correct for constant row configuration") {
                    expect(configurator.indexPathsForRowConfiguration(constantRowConfiguration)).to(equal([NSIndexPath(forRow: 0, inSection: 0)]));
                }
                
                it("is correct for model row configuration") {
                    expect(configurator.indexPathsForRowConfiguration(modelRowConfiguration))
                        .to(equal([NSIndexPath(forRow: 0, inSection: 1), NSIndexPath(forRow: 1, inSection: 1), NSIndexPath(forRow: 2, inSection: 1)]));
                }
                
                it("is correct for hidden rows") {
                    var constantHidden = false;
                    var modelHidden = false;
                    
                    constantRowConfiguration.hideWhen({ return constantHidden; });
                    modelRowConfiguration.hideWhen({ (model) -> Bool in
                        return modelHidden;
                    });
                    
                    var constantPaths = configurator.indexPathsForRowConfiguration(constantRowConfiguration);
                    var modelPaths = configurator.indexPathsForRowConfiguration(modelRowConfiguration);
                    
                    expect(constantPaths).toNot(beNil());
                    expect(constantPaths).toNot(beEmpty());
                    expect(modelPaths).toNot(beNil());
                    expect(modelPaths).toNot(beEmpty());
                    
                    constantHidden = true;
                    modelHidden = true;
                    
                    constantPaths = configurator.indexPathsForRowConfiguration(constantRowConfiguration);
                    modelPaths = configurator.indexPathsForRowConfiguration(modelRowConfiguration);
                    
                    expect(constantPaths).toNot(beNil());
                    expect(constantPaths).toNot(beEmpty());
                    expect(modelPaths).toNot(beNil());
                    expect(modelPaths).toNot(beEmpty());
                }
            }
            
            describe("its number of sections") {
                it("is correct") {
                    expect(configurator.numberOfSectionsInTableView(tableView)).to(equal(2));
                }
            }
            
            describe("its number of rows") {
                it("is correct for constant row section") {
                    expect(configurator.tableView(tableView, numberOfRowsInSection: 0)).to(equal(1));
                }
                
                it("is correct for model row section") {
                    expect(configurator.tableView(tableView, numberOfRowsInSection: 1)).to(equal(3));
                }
            }
            
            describe("its produced cell") {
                it("is correct for constant row section") {
                    expect(configurator.tableView(tableView, cellForRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 0))).to(beAnInstanceOf(ImplicitReuseIdCell));
                }
                
                it("is correct for model row section") {
                    expect(configurator.tableView(tableView, cellForRowAtIndexPath: NSIndexPath(forRow: 1, inSection: 1))).to(beAnInstanceOf(ModelImplicitReuseIdCell));
                }
            }
            
            describe("its height") {
                it("is correct for constant row section") {
                    constantRowConfiguration.height(100.0);
                    expect(configurator.tableView(tableView, heightForRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 0))).to(equal(100.0));
                }
                
                it("is correct for model row section") {
                    modelRowConfiguration.height(200.0);
                    expect(configurator.tableView(tableView, heightForRowAtIndexPath: NSIndexPath(forRow: 2, inSection: 1))).to(equal(200.0));
                }
            }
            
            describe("its estimated height") {
                it("is correct for constant row section") {
                    constantRowConfiguration.estimatedHeight(100.0);
                    expect(configurator.tableView(tableView, estimatedHeightForRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 0))).to(equal(100.0));
                }
                
                it("is correct for model row section") {
                    modelRowConfiguration.estimatedHeight(200.0);
                    expect(configurator.tableView(tableView, estimatedHeightForRowAtIndexPath: NSIndexPath(forRow: 2, inSection: 1))).to(equal(200.0));
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
                    configurator.tableView(tableView, didSelectRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 0));
                    expect(constantRowSelected).to(beTrue());
                    expect(modelRowSelected).to(beFalse());
                }
                
                it("is correct for model row section") {
                    configurator.tableView(tableView, didSelectRowAtIndexPath: NSIndexPath(forRow: 2, inSection: 1));
                    expect(constantRowSelected).to(beFalse());
                    expect(modelRowSelected).to(beTrue());
                }
            }
        }
    }
}