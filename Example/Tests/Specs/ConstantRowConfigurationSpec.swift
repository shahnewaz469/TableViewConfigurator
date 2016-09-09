//
//  ConstantRowConfigurationSpec.swift
//  TableViewConfigurator
//
//  Created by John Volk on 3/3/16.
//  Copyright © 2016 John Volk. All rights reserved.
//

import Quick
import Nimble
@testable import TableViewConfigurator

class ConstantRowConfigurationSpec: QuickSpec {
    
    private static let CONFIGURABLE_CELL_REUSE_ID = "configurableCell"
    
    override func spec() {
        describe("a constant row configuration") {
            var tableView: UITableViewMock!
            var rowConfiguration: ConstantRowConfiguration<ConfigurableCell>!
            var implicitIdRowConfiguration: ConstantRowConfiguration<ImplicitReuseIdCell>!
            
            beforeEach {
                tableView = UITableViewMock()
                tableView.register(ConfigurableCell.self, forCellReuseIdentifier: ConstantRowConfigurationSpec.CONFIGURABLE_CELL_REUSE_ID)
                tableView.register(ImplicitReuseIdCell.self, forCellReuseIdentifier: ImplicitReuseIdCell.buildReuseIdentifier())
                rowConfiguration = ConstantRowConfiguration()
                implicitIdRowConfiguration = ConstantRowConfiguration()
            }
            
            describe("its cell reuse id") {
                it("is set correctly when explicitly defined") {
                    expect(rowConfiguration.cellReuseId(ConstantRowConfigurationSpec.CONFIGURABLE_CELL_REUSE_ID).cellReuseId)
                        .to(equal(ConstantRowConfigurationSpec.CONFIGURABLE_CELL_REUSE_ID))
                }
            }
            
            describe("its produced cell") {
                it("is the correct type when cellReuseId explicitly defined") {
                    let cell = rowConfiguration
                        .cellReuseId(ConstantRowConfigurationSpec.CONFIGURABLE_CELL_REUSE_ID)
                        .cellFor(row: 0, inTableView: tableView)
                    
                    expect(cell).to(beAnInstanceOf(ConfigurableCell.self))
                }
                
                it("is the correct type when cellReuseId implicitly defined") {
                    expect(implicitIdRowConfiguration.cellFor(row: 0, inTableView: tableView)).to(beAnInstanceOf(ImplicitReuseIdCell.self))
                }
                
                it("is nil when asking for non-existant row") {
                    expect(implicitIdRowConfiguration.cellFor(row: 1, inTableView: tableView)).to(beNil())
                }
                
                it("is configured") {
                    let cell = implicitIdRowConfiguration.cellFor(row: 0, inTableView: tableView) as? ImplicitReuseIdCell
                    
                    expect(cell).toNot(beNil())
                    expect(cell?.configured).to(beTrue())
                }
                
                it("is refreshed") {
                    let indexPath = IndexPath(row: 0, section: 0)
                    let cell = implicitIdRowConfiguration.cellFor(row: indexPath.row, inTableView: tableView) as? ImplicitReuseIdCell
                    
                    expect(cell?.configured).to(beTrue())
                    
                    cell?.configured = false
                    expect(cell?.configured).to(beFalse())
                    
                    tableView.storeCell(cell!, forIndexPath: indexPath)
                    implicitIdRowConfiguration.refreshCellFor(row: indexPath.row, withIndexPath: indexPath, inTableView: tableView)
                    expect(cell?.configured).to(beTrue())
                }
            }
            
            describe("its height") {
                it("is set correctly for existant row") {
                    expect(rowConfiguration.height(100.0).heightFor(row: 0))
                        .to(equal(100.0))
                }
                
                it("is nil when asking for non-existant row") {
                    expect(rowConfiguration.height(100.0).heightFor(row: 1))
                        .to(beNil())
                }
            }
            
            describe("its estimated height") {
                it("is set correctly for existant row") {
                    expect(rowConfiguration.estimatedHeight(200.0).estimatedHeightFor(row: 0))
                        .to(equal(200.0))
                }
                
                it("is nil when asking for non-existant row") {
                    expect(rowConfiguration.estimatedHeight(100.0).estimatedHeightFor(row: 1))
                        .to(beNil())
                }
            }
            
            describe("its visible row count") {
                it("is correct when visible") {
                    expect(rowConfiguration.numberOfRows(countHidden: false)).to(equal(1))
                }
                
                it("is correct when hidden") {
                    expect(rowConfiguration.hideWhen({ return true }).numberOfRows(countHidden: false)).to(equal(0))
                }
            }
            
            describe("its total row count") {
                it("is correct when visible") {
                    expect(rowConfiguration.numberOfRows(countHidden: true)).to(equal(1))
                }
                
                it("is correct when hidden") {
                    expect(rowConfiguration.hideWhen({ return true }).numberOfRows(countHidden: true)).to(equal(1))
                }
            }
            
            describe("its row visibility") {
                it("is correct when visible") {
                    expect(rowConfiguration.rowIsVisible(row: 0)).to(beTrue())
                }
            
                it("is correct when hidden") {
                    expect(rowConfiguration.hideWhen({ return true }).rowIsVisible(row: 0)).to(beFalse())
                }
                
                it("is nil when asking for non-existant row") {
                    expect(rowConfiguration.rowIsVisible(row: 3)).to(beNil())
                }
            }
            
            describe("its selection handler") {
                it("is invoked when selected") {
                    var selectionHandlerInvoked = false
                    
                    rowConfiguration.selectionHandler({ selectionHandlerInvoked = true }).didSelect(row: 0)
                    expect(selectionHandlerInvoked).to(beTrue())
                }
                
                it("is not invoked when selecting non-existant row") {
                    var selectionHandlerInvoked = false
                    
                    rowConfiguration.selectionHandler({ selectionHandlerInvoked = true }).didSelect(row: 1)
                    expect(selectionHandlerInvoked).to(beFalse())
                }
            }
            
            describe("its additional config") {
                it("is applied when retrieving a cell") {
                    let cell = implicitIdRowConfiguration
                        .additionalConfig({ $0.additionallyConfigured = true })
                        .cellFor(row: 0, inTableView: tableView) as? ImplicitReuseIdCell
                    
                    expect(cell).toNot(beNil())
                    expect(cell?.additionallyConfigured).to(beTrue())
                }
            }
        }
    }
}
