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
                tableView.registerClass(ImplicitReuseIdCell.self, forCellReuseIdentifier: ImplicitReuseIdCell.buildReuseIdentifier());
                tableView.registerClass(ModelImplicitReuseIdCell.self, forCellReuseIdentifier: ModelImplicitReuseIdCell.buildReuseIdentifier());
                constantRowConfiguration = ConstantRowConfiguration();
                modelRowConfiguration = ModelRowConfiguration(models: self.things);
                sectionConfiguration = SectionConfiguration(rowConfigurations: [modelRowConfiguration, constantRowConfiguration]);
            }
            
            describe("its visible index set") {
                it("is correct") {
                    expect(sectionConfiguration.visibleIndexSet()).to(equal(NSIndexSet(indexesInRange: NSMakeRange(0, 4))));
                    
                    modelRowConfiguration.hideWhen({ return $0 === self.things[0] });
                    expect(sectionConfiguration.visibleIndexSet()).to(equal(NSIndexSet(indexesInRange: NSMakeRange(1, 3))));
                    
                    constantRowConfiguration.hideWhen({ return true });
                    expect(sectionConfiguration.visibleIndexSet()).to(equal(NSIndexSet(indexesInRange: NSMakeRange(1, 2))));
                    
                    modelRowConfiguration.hideWhen({ (model) -> Bool in
                        return true;
                    });
                    expect(sectionConfiguration.visibleIndexSet()).to(beEmpty());
                }
            }
            
            describe("its number of rows") {
                it("is correct") {
                    expect(sectionConfiguration.numberOfRows()).to(equal(4));
                }
            }
            
            describe("its produced cell") {
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
                it("is correct for constant row configuration") {
                    constantRowConfiguration.height(200.0);
                    expect(sectionConfiguration.heightForRow(3)).to(equal(200.0));
                }
                
                it("is correct for model row configuration") {
                    modelRowConfiguration.height(100.0)
                    expect(sectionConfiguration.heightForRow(1)).to(equal(100.0));
                }
            }
            
            describe("its estimated height") {
                it("is correct for constant row configuration") {
                    constantRowConfiguration.estimatedHeight(200.0)
                    expect(sectionConfiguration.estimatedHeightForRow(3)).to(equal(200.0));
                }
                
                it("is correct for model row configuration") {
                    modelRowConfiguration.estimatedHeight(100.0)
                    expect(sectionConfiguration.estimatedHeightForRow(1)).to(equal(100.0));
                }
            }
            
            describe("its select row behavior") {
                context("for constant row configuration") {
                    var selectionHandlerInvoked: Bool!;
                    
                    beforeEach {
                        selectionHandlerInvoked = false;
                        constantRowConfiguration.selectionHandler({ () -> Bool in
                            selectionHandlerInvoked = true; return true;
                        });
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
                        modelRowConfiguration.selectionHandler({ (model) -> Bool in
                            selectionHandlerInvoked = true; return true;
                        });
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
                it("is correct") {
                    sectionConfiguration.headerTitle("Foo Header");
                    expect(sectionConfiguration.titleForHeader()).to(equal("Foo Header"));
                }
            }
            
            describe("its footer title") {
                it("is correct") {
                    sectionConfiguration.footerTitle("Bar Footer");
                    expect(sectionConfiguration.titleForFooter()).to(equal("Bar Footer"));
                }
            }
        }
    }
}