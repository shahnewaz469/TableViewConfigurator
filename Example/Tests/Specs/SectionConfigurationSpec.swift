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
    
    private static let CONFIGURABLE_CELL_REUSE_ID = "configurableCell"
    private static let MODEL_CONFIGURABLE_CELL_REUSE_ID = "modelConfigurableCell"
    private let things = [Thing(name: "Window"), Thing(name: "Cloud"), Thing(name: "Flower")]
    
    override func spec() {
        describe("a section configuration") {
            var tableView: UITableViewMock!
            var constantRowConfiguration: ConstantRowConfiguration<ImplicitReuseIdCell>!
            var modelRowConfiguration: ModelRowConfiguration<ModelImplicitReuseIdCell, Thing>!
            var sectionConfiguration: SectionConfiguration!
            
            beforeEach {
                tableView = UITableViewMock()
                tableView.register(ImplicitReuseIdCell.self, forCellReuseIdentifier: ImplicitReuseIdCell.buildReuseIdentifier())
                tableView.register(ModelImplicitReuseIdCell.self, forCellReuseIdentifier: ModelImplicitReuseIdCell.buildReuseIdentifier())
                constantRowConfiguration = ConstantRowConfiguration()
                modelRowConfiguration = ModelRowConfiguration(models: self.things)
                sectionConfiguration = SectionConfiguration(rowConfigurations: [modelRowConfiguration, constantRowConfiguration])
            }
            
            describe("its index set for row configuration") {
                it("is correct") {
                    expect(sectionConfiguration.indexSetFor(rowConfiguration: modelRowConfiguration)).to(equal(IndexSet(integersIn: 0 ..< 3)))
                    expect(sectionConfiguration.indexSetFor(rowConfiguration: constantRowConfiguration)).to(equal(IndexSet(integersIn: 3 ..< 4)))
                    
                    _ = modelRowConfiguration.hideWhen({ $0 === self.things[2] })
                    expect(sectionConfiguration.indexSetFor(rowConfiguration: modelRowConfiguration)).to(equal(IndexSet(integersIn: 0 ..< 2)))
                    expect(sectionConfiguration.indexSetFor(rowConfiguration: constantRowConfiguration)).to(equal(IndexSet(integersIn: 2 ..< 3)))
                    
                    _ = constantRowConfiguration.hideWhen({ return true })
                    expect(sectionConfiguration.indexSetFor(rowConfiguration: constantRowConfiguration)).to(beEmpty())
                }
            }
            
            describe("its number of rows") {
                it("is correct") {
                    expect(sectionConfiguration.numberOfRows()).to(equal(4))
                }
            }
            
            describe("its produced cell") {
                it("is correct for constant row configuration") {
                    let cell = sectionConfiguration.cellFor(row: 3, inTableView: tableView) as? ImplicitReuseIdCell
                    
                    expect(cell).toNot(beNil())
                    expect(cell?.configured).to(beTrue())
                }
                
                it("is correct for model row configuration") {
                    let cell = sectionConfiguration.cellFor(row: 1, inTableView: tableView) as? ModelImplicitReuseIdCell
                    
                    expect(cell).toNot(beNil())
                    expect(cell?.model).toNot(beNil())
                    expect(cell?.model?.name).to(equal("Cloud"))
                }
                
                it("is refreshed for constant row configuration") {
                    let indexPath = IndexPath(row: 3, section: 0)
                    let cell = sectionConfiguration.cellFor(row: indexPath.row, inTableView: tableView) as? ImplicitReuseIdCell
                    
                    expect(cell?.configured).to(beTrue())
                    
                    cell?.configured = false
                    expect(cell?.configured).to(beFalse())
                    
                    tableView.storeCell(cell!, forIndexPath: indexPath)
                    sectionConfiguration.refresh(rowConfiguration: constantRowConfiguration, withSection: indexPath.section, inTableView: tableView)
                    expect(cell?.configured).to(beTrue())
                }
                
                it("is refreshed for model row configuration") {
                    let indexPath = IndexPath(row: 1, section: 0)
                    let cell = sectionConfiguration.cellFor(row: indexPath.row, inTableView: tableView) as? ModelImplicitReuseIdCell
                    
                    expect(cell?.model).toNot(beNil())
                    
                    cell?.model = nil
                    expect(cell?.model).to(beNil())
                    
                    tableView.storeCell(cell!, forIndexPath: indexPath)
                    sectionConfiguration.refresh(rowConfiguration: modelRowConfiguration, withSection: indexPath.section, inTableView: tableView)
                    expect(cell?.model).toNot(beNil())
                }
            }
            
            describe("its height") {
                it("is correct for constant row configuration") {
                    _ = constantRowConfiguration.height(200.0)
                    expect(sectionConfiguration.heightFor(row: 3)).to(equal(200.0))
                }
                
                it("is correct for model row configuration") {
                    _ = modelRowConfiguration.height(100.0)
                    expect(sectionConfiguration.heightFor(row: 1)).to(equal(100.0))
                }
            }
            
            describe("its estimated height") {
                it("is correct for constant row configuration") {
                    _ = constantRowConfiguration.estimatedHeight(200.0)
                    expect(sectionConfiguration.estimatedHeightFor(row: 3)).to(equal(200.0))
                }
                
                it("is correct for model row configuration") {
                    _ = modelRowConfiguration.estimatedHeight(100.0)
                    expect(sectionConfiguration.estimatedHeightFor(row: 1)).to(equal(100.0))
                }
            }
            
            describe("its select row behavior") {
                context("for constant row configuration") {
                    var selectionHandlerInvoked: Bool!
                    
                    beforeEach {
                        selectionHandlerInvoked = false
                        _ = constantRowConfiguration.selectionHandler({ selectionHandlerInvoked = true })
                    }
                    
                    it("is correct when selected") {
                        sectionConfiguration.didSelect(row: 3)
                        expect(selectionHandlerInvoked).to(beTrue())
                    }
                    
                    it("is correct when not selected") {
                        sectionConfiguration.didSelect(row: 2)
                        expect(selectionHandlerInvoked).to(beFalse())
                    }
                }
                
                context("for model row configuration") {
                    var selectionHandlerInvoked: Bool!
                    
                    beforeEach {
                        selectionHandlerInvoked = false
                        _ = modelRowConfiguration.selectionHandler({ (model) -> Void in
                            selectionHandlerInvoked = true
                        })
                    }
                    
                    it("is correct when selected") {
                        sectionConfiguration.didSelect(row: 1)
                        expect(selectionHandlerInvoked).to(beTrue())
                    }
                    
                    it("is correct when not selected") {
                        sectionConfiguration.didSelect(row: 3)
                        expect(selectionHandlerInvoked).to(beFalse())
                    }
                }
            }
            
            describe("its header title") {
                it("is correct") {
                    _ = sectionConfiguration.headerTitle("Foo Header")
                    expect(sectionConfiguration.titleForHeader()).to(equal("Foo Header"))
                }
            }
            
            describe("its footer title") {
                it("is correct") {
                    _ = sectionConfiguration.footerTitle("Bar Footer")
                    expect(sectionConfiguration.titleForFooter()).to(equal("Bar Footer"))
                }
            }
        }
    }
}
