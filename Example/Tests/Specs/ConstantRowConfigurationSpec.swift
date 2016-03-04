//
//  ConstantRowConfigurationSpec.swift
//  TableViewConfigurator
//
//  Created by John Volk on 3/3/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import Quick
import Nimble
@testable import TableViewConfigurator

class ConstantRowConfigurationSpec: QuickSpec {
    
    private static let CONFIGURABLE_CELL_REUSE_ID = "configurableCell";
    
    override func spec() {
        describe("a constant row configuration") {
            var tableView: UITableView!;
            var rowConfiguration: ConstantRowConfiguration<ConfigurableCell>!;
            var implicitIdRowConfiguration: ConstantRowConfiguration<ImplicitReuseIdCell>!;
            
            beforeEach {
                tableView = UITableView();
                tableView.registerClass(ConfigurableCell.self, forCellReuseIdentifier: ConstantRowConfigurationSpec.CONFIGURABLE_CELL_REUSE_ID);
                tableView.registerClass(ImplicitReuseIdCell.self, forCellReuseIdentifier: ImplicitReuseIdCell.REUSE_ID);
                rowConfiguration = ConstantRowConfiguration();
                implicitIdRowConfiguration = ConstantRowConfiguration();
            }
            
            describe("its cell reuse id") {
                it("is set correctly when explicitly defined") {
                    expect(rowConfiguration.cellReuseId(ConstantRowConfigurationSpec.CONFIGURABLE_CELL_REUSE_ID).cellReuseId)
                        .to(equal(ConstantRowConfigurationSpec.CONFIGURABLE_CELL_REUSE_ID));
                }
            }
            
            describe("its produced cell") {
                it("is the correct type when cellReuseId explicitly defined") {
                    let cell = rowConfiguration
                        .cellReuseId(ConstantRowConfigurationSpec.CONFIGURABLE_CELL_REUSE_ID)
                        .cellForRow(0, inTableView: tableView);
                    
                    expect(cell).to(beAnInstanceOf(ConfigurableCell));
                }
                
                it("is the correct type when cellReuseId implicitly defined") {
                    expect(implicitIdRowConfiguration.cellForRow(0, inTableView: tableView)).to(beAnInstanceOf(ImplicitReuseIdCell));
                }
                
                it("is nil when asking for non-existant row") {
                    expect(implicitIdRowConfiguration.cellForRow(1, inTableView: tableView)).to(beNil());
                }
                
                it("is configured") {
                    let cell = implicitIdRowConfiguration.cellForRow(0, inTableView: tableView) as? ImplicitReuseIdCell;
                    
                    expect(cell).toNot(beNil());
                    expect(cell?.configured).to(beTrue());
                }
            }
            
            describe("its height") {
                it("is set correctly for existant row") {
                    expect(rowConfiguration.height(100.0).heightForRow(0))
                        .to(equal(100.0));
                }
                
                it("is nil when asking for non-existant row") {
                    expect(rowConfiguration.height(100.0).heightForRow(1))
                        .to(beNil());
                }
            }
            
            describe("its estimated height") {
                it("is set correctly for existant row") {
                    expect(rowConfiguration.estimatedHeight(200.0).estimatedHeightForRow(0))
                        .to(equal(200.0));
                }
                
                it("is nil when asking for non-existant row") {
                    expect(rowConfiguration.estimatedHeight(100.0).estimatedHeightForRow(1))
                        .to(beNil());
                }
            }
            
            describe("its row count") {
                context("when visible") {
                    it("is correct") {
                        expect(rowConfiguration.numberOfRows()).to(equal(1));
                    }
                }
                
                context("when hidden") {
                    it("is correct") {
                        expect(rowConfiguration.hideWhen({ return true; }).numberOfRows()).to(equal(0));
                    }
                }
            }
            
            describe("its selection handler") {
                it("is invoked when selected") {
                    var selectionHandlerInvoked = false;
                    
                    rowConfiguration.selectionHandler({ selectionHandlerInvoked = true; return true; }).didSelectRow(0);
                    
                    expect(selectionHandlerInvoked).to(beTrue());
                }
                
                it("is not invoked when selecting non-existant row") {
                    var selectionHandlerInvoked = false;
                    
                    rowConfiguration.selectionHandler({ selectionHandlerInvoked = true; return true; }).didSelectRow(1);
                    
                    expect(selectionHandlerInvoked).to(beFalse());
                }
            }
            
            describe("its additional config") {
                it("is applied when retrieving a cell") {
                    let cell = implicitIdRowConfiguration
                        .additionalConfig({ $0.additionallyConfigured = true; })
                        .cellForRow(0, inTableView: tableView) as? ImplicitReuseIdCell;
                    
                    expect(cell).toNot(beNil());
                    expect(cell?.additionallyConfigured).to(beTrue());
                }
            }
        }
    }
}