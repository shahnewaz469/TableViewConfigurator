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
    
    private static let CONSTANT_CELL_REUSE_ID = "constantCell";
    
    override func spec() {
        describe("a constant row configuration") {
            var tableView: UITableView!;
            var rowConfiguration: ConstantRowConfiguration<ConstantCell>!;
            var implicitIdRowConfiguration: ConstantRowConfiguration<ImplicitReuseIdCell>!;
            
            beforeEach {
                tableView = UITableView();
                tableView.registerClass(ConstantCell.self, forCellReuseIdentifier: ConstantRowConfigurationSpec.CONSTANT_CELL_REUSE_ID);
                tableView.registerClass(ImplicitReuseIdCell.self, forCellReuseIdentifier: ImplicitReuseIdCell.REUSE_ID);
                rowConfiguration = ConstantRowConfiguration();
                implicitIdRowConfiguration = ConstantRowConfiguration();
            }
            
            describe("its row count") {
                context("when visible") {
                    it("is 1") {
                        expect(rowConfiguration.numberOfRows()).to(equal(1));
                    }
                }
                
                context("when hidden") {
                    it("is 0") {
                        expect(rowConfiguration.hideWhen({ return true; }).numberOfRows()).to(equal(0));
                    }
                }
            }
            
            describe("its produced cell") {
                it("is the correct type when specifying cellReuseId explicitly") {
                    let cell = rowConfiguration
                        .cellReuseId(ConstantRowConfigurationSpec.CONSTANT_CELL_REUSE_ID)
                        .cellForRow(0, inTableView: tableView);
                    
                    expect(cell).to(beAnInstanceOf(ConstantCell));
                }
                
                it("is the correct type when specifying cellReuseId implicitly") {
                    expect(implicitIdRowConfiguration.cellForRow(0, inTableView: tableView)).to(beAnInstanceOf(ImplicitReuseIdCell));
                }
                
                it("is nil when asking for non-existant row") {
                    expect(implicitIdRowConfiguration.cellForRow(1, inTableView: tableView)).to(beNil());
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
                    if let cell = rowConfiguration
                        .cellReuseId(ConstantRowConfigurationSpec.CONSTANT_CELL_REUSE_ID)
                        .additionalConfig({ $0.additionallyConfigured = true; }).cellForRow(0, inTableView: tableView) as? ConstantCell {
                            expect(cell.additionallyConfigured).to(beTrue());
                    }
                }
            }
        }
    }
}
