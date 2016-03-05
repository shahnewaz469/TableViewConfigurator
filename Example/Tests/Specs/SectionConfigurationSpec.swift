//
//  SectionConfigurationSpec.swift
//  TableViewConfigurator
//
//  Created by John Volk on 3/4/16.
//  Copyright © 2016 John Volk. All rights reserved.
//

import Quick
import Nimble
@testable import TableViewConfigurator

class SectionConfigurationSpec: QuickSpec {
    
    private static let CONFIGURABLE_CELL_REUSE_ID = "configurableCell";
    private static let MODEL_CONFIGURABLE_CELL_REUSE_ID = "modelConfigurableCell";
    private let things = [Thing(name: "Window"), Thing(name: "Cloud"), Thing(name: "Flower")];
    
    override func spec() {
        describe("a section configuration") {
            var tableView: UITableView!;
            var constantRowConfiguration: ConstantRowConfiguration<ImplicitReuseIdCell>!;
            var modelRowConfiguration: ModelRowConfiguration<ModelImplicitReuseIdCell, Thing>!;
            var sectionConfiguration: SectionConfiguration!;
            
            beforeEach {
                tableView = UITableView();
                tableView.registerClass(ImplicitReuseIdCell.self, forCellReuseIdentifier: ImplicitReuseIdCell.REUSE_ID);
                tableView.registerClass(ModelImplicitReuseIdCell.self, forCellReuseIdentifier: ModelImplicitReuseIdCell.REUSE_ID);
                constantRowConfiguration = ConstantRowConfiguration();
                modelRowConfiguration = ModelRowConfiguration(models: self.things);
            }
            
            describe("its row index set") {
                beforeEach {
                    sectionConfiguration = SectionConfiguration(rowConfigurations: [modelRowConfiguration, constantRowConfiguration]);
                }
                
                it("is correct for constant row configuration") {
                    expect(sectionConfiguration.rowIndexSetForRowConfiguration(constantRowConfiguration)).to(equal(NSIndexSet(index: 3)));
                }
                
                it("is correct for model row configuration") {
                    expect(sectionConfiguration.rowIndexSetForRowConfiguration(modelRowConfiguration)).to(equal(NSIndexSet(indexesInRange: NSMakeRange(0, 3))));
                }
            }
            
            describe("its number of rows") {
                beforeEach {
                    sectionConfiguration = SectionConfiguration(rowConfigurations: [modelRowConfiguration, constantRowConfiguration]);
                }
                
                it("is correct") {
                    expect(sectionConfiguration.numberOfRows()).to(equal(4));
                }
            }
            
            describe("its produced cell") {
                beforeEach {
                    sectionConfiguration = SectionConfiguration(rowConfigurations: [modelRowConfiguration, constantRowConfiguration]);
                }
                
                it("is correct for constant row configuration") {
                    let cell = sectionConfiguration.cellForRow(3, inTableView: tableView) as? ImplicitReuseIdCell;
                    
                    expect(cell).toNot(beNil());
                    expect(cell?.configured).to(beTrue());
                }
                
                it("is correct for model row configuration") {
                    let cell = sectionConfiguration.cellForRow(1, inTableView: tableView) as? ModelImplicitReuseIdCell;
                    
                    expect(cell).toNot(beNil());
                    expect(cell?.model).toNot(beNil());
                    expect(cell?.model?.name).to(equal("Cloud"));
                }
            }
            
            describe("its height") {
                beforeEach {
                    sectionConfiguration = SectionConfiguration(rowConfigurations: [modelRowConfiguration.height(100.0), constantRowConfiguration.height(200.0)]);
                }
                
                it("is correct for constant row configuration") {
                    expect(sectionConfiguration.heightForRow(3)).to(equal(200.0));
                }
                
                it("is correct for model row configuration") {
                    expect(sectionConfiguration.heightForRow(1)).to(equal(100.0));
                }
            }
            
            describe("its estimated height") {
                beforeEach {
                    sectionConfiguration = SectionConfiguration(rowConfigurations: [modelRowConfiguration.estimatedHeight(100.0), constantRowConfiguration.estimatedHeight(200.0)]);
                }
                
                it("is correct for constant row configuration") {
                    expect(sectionConfiguration.estimatedHeightForRow(3)).to(equal(200.0));
                }
                
                it("is correct for model row configuration") {
                    expect(sectionConfiguration.estimatedHeightForRow(1)).to(equal(100.0));
                }
            }
            
            describe("its select row behavior") {
                context("for constant row configuration") {
                    var selectionHandlerInvoked: Bool!;
                    
                    beforeEach {
                        selectionHandlerInvoked = false;
                        sectionConfiguration = SectionConfiguration(rowConfigurations: [modelRowConfiguration, constantRowConfiguration
                            .selectionHandler({ () -> Bool in
                                selectionHandlerInvoked = true; return true;
                            })]);
                    }
                    
                    it("is correct when selected") {
                        sectionConfiguration.didSelectRow(3);
                        expect(selectionHandlerInvoked).to(beTrue());
                    }
                    
                    it("is correct when not selected") {
                        sectionConfiguration.didSelectRow(2);
                        expect(selectionHandlerInvoked).to(beFalse());
                    }
                }
                
                context("for model row configuration") {
                    var selectionHandlerInvoked: Bool!;
                    
                    beforeEach {
                        selectionHandlerInvoked = false;
                        sectionConfiguration = SectionConfiguration(rowConfigurations: [modelRowConfiguration
                            .selectionHandler({ (model) -> Bool in
                                selectionHandlerInvoked = true; return true;
                            }), constantRowConfiguration]);
                    }
                    
                    it("is correct when selected") {
                        sectionConfiguration.didSelectRow(1);
                        expect(selectionHandlerInvoked).to(beTrue());
                    }
                    
                    it("is correct when not selected") {
                        sectionConfiguration.didSelectRow(3);
                        expect(selectionHandlerInvoked).to(beFalse());
                    }
                }
            }
            
            describe("its header title") {
                beforeEach {
                    sectionConfiguration = SectionConfiguration(rowConfigurations: [modelRowConfiguration, constantRowConfiguration]).headerTitle("Foo Header");
                }
                
                it("is correct") {
                    expect(sectionConfiguration.titleForHeader()).to(equal("Foo Header"));
                }
            }
            
            describe("its footer title") {
                beforeEach {
                    sectionConfiguration = SectionConfiguration(rowConfigurations: [modelRowConfiguration, constantRowConfiguration]).footerTitle("Bar Footer");
                }
                
                it("is correct") {
                    expect(sectionConfiguration.titleForFooter()).to(equal("Bar Footer"));
                }
            }
        }
    }
}