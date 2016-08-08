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
                tableView.registerClass(ImplicitReuseIdCell.self, forCellReuseIdentifier: ImplicitReuseIdCell.buildReuseIdentifier())
                tableView.registerClass(ModelImplicitReuseIdCell.self, forCellReuseIdentifier: ModelImplicitReuseIdCell.buildReuseIdentifier())
                constantRowConfiguration = ConstantRowConfiguration()
                modelRowConfiguration = ModelRowConfiguration(models: self.things)
                sectionConfiguration = SectionConfiguration(rowConfigurations: [modelRowConfiguration, constantRowConfiguration])
            }
            
            describe("its index set for row configuration") {
                it("is correct") {
                    expect(sectionConfiguration.indexSetForRowConfiguration(modelRowConfiguration)).to(equal(NSIndexSet(indexesInRange: NSMakeRange(0, 3))))
                    expect(sectionConfiguration.indexSetForRowConfiguration(constantRowConfiguration)).to(equal(NSIndexSet(indexesInRange: NSMakeRange(3, 1))))
                    
                    modelRowConfiguration.hideWhen({ $0 === self.things[2] })
                    expect(sectionConfiguration.indexSetForRowConfiguration(modelRowConfiguration)).to(equal(NSIndexSet(indexesInRange: NSMakeRange(0, 2))))
                    expect(sectionConfiguration.indexSetForRowConfiguration(constantRowConfiguration)).to(equal(NSIndexSet(indexesInRange: NSMakeRange(2, 1))))
                    
                    constantRowConfiguration.hideWhen({ return true })
                    expect(sectionConfiguration.indexSetForRowConfiguration(constantRowConfiguration)).to(beEmpty())
                }
            }
            
            describe("its visibility map") {
                it("is correct") {
                    expect(sectionConfiguration.visibilityMap()).to(equal([[0: true, 1: true, 2: true], [0: true]]))
                    
                    modelRowConfiguration.hideWhen({ $0 === self.things[0] })
                    expect(sectionConfiguration.visibilityMap()).to(equal([[0: false, 1: true, 2: true], [0: true]]))
                    
                    constantRowConfiguration.hideWhen({ return true })
                    expect(sectionConfiguration.visibilityMap()).to(equal([[0: false, 1: true, 2: true], [0: false]]))
                    
                    modelRowConfiguration.hideWhen({ (model) -> Bool in
                        return true
                    })
                    expect(sectionConfiguration.visibilityMap()).to(equal([[0: false, 1: false, 2: false], [0: false]]))
                }
            }
            
            describe("its number of rows") {
                it("is correct") {
                    expect(sectionConfiguration.numberOfRows()).to(equal(4))
                }
            }
            
            describe("its produced cell") {
                it("is correct for constant row configuration") {
                    let cell = sectionConfiguration.cellForRow(3, inTableView: tableView) as? ImplicitReuseIdCell
                    
                    expect(cell).toNot(beNil())
                    expect(cell?.configured).to(beTrue())
                }
                
                it("is correct for model row configuration") {
                    let cell = sectionConfiguration.cellForRow(1, inTableView: tableView) as? ModelImplicitReuseIdCell
                    
                    expect(cell).toNot(beNil())
                    expect(cell?.model).toNot(beNil())
                    expect(cell?.model?.name).to(equal("Cloud"))
                }
                
                it("is refreshed for constant row configuration") {
                    let indexPath = NSIndexPath(forRow: 3, inSection: 0)
                    let cell = sectionConfiguration.cellForRow(indexPath.row, inTableView: tableView) as? ImplicitReuseIdCell
                    
                    expect(cell?.configured).to(beTrue())
                    
                    cell?.configured = false
                    expect(cell?.configured).to(beFalse())
                    
                    tableView.storeCell(cell!, forIndexPath: indexPath)
                    sectionConfiguration.refreshRowConfiguration(constantRowConfiguration, withSection: indexPath.section, inTableView: tableView)
                    expect(cell?.configured).to(beTrue())
                }
                
                it("is refreshed for model row configuration") {
                    let indexPath = NSIndexPath(forRow: 1, inSection: 0)
                    let cell = sectionConfiguration.cellForRow(indexPath.row, inTableView: tableView) as? ModelImplicitReuseIdCell
                    
                    expect(cell?.model).toNot(beNil())
                    
                    cell?.model = nil
                    expect(cell?.model).to(beNil())
                    
                    tableView.storeCell(cell!, forIndexPath: indexPath)
                    sectionConfiguration.refreshRowConfiguration(modelRowConfiguration, withSection: indexPath.section, inTableView: tableView)
                    expect(cell?.model).toNot(beNil())
                }
            }
            
            describe("its height") {
                it("is correct for constant row configuration") {
                    constantRowConfiguration.height(200.0)
                    expect(sectionConfiguration.heightForRow(3)).to(equal(200.0))
                }
                
                it("is correct for model row configuration") {
                    modelRowConfiguration.height(100.0)
                    expect(sectionConfiguration.heightForRow(1)).to(equal(100.0))
                }
            }
            
            describe("its estimated height") {
                it("is correct for constant row configuration") {
                    constantRowConfiguration.estimatedHeight(200.0)
                    expect(sectionConfiguration.estimatedHeightForRow(3)).to(equal(200.0))
                }
                
                it("is correct for model row configuration") {
                    modelRowConfiguration.estimatedHeight(100.0)
                    expect(sectionConfiguration.estimatedHeightForRow(1)).to(equal(100.0))
                }
            }
            
            describe("its select row behavior") {
                context("for constant row configuration") {
                    var selectionHandlerInvoked: Bool!
                    
                    beforeEach {
                        selectionHandlerInvoked = false
                        constantRowConfiguration.selectionHandler({ selectionHandlerInvoked = true })
                    }
                    
                    it("is correct when selected") {
                        sectionConfiguration.didSelectRow(3)
                        expect(selectionHandlerInvoked).to(beTrue())
                    }
                    
                    it("is correct when not selected") {
                        sectionConfiguration.didSelectRow(2)
                        expect(selectionHandlerInvoked).to(beFalse())
                    }
                }
                
                context("for model row configuration") {
                    var selectionHandlerInvoked: Bool!
                    
                    beforeEach {
                        selectionHandlerInvoked = false
                        modelRowConfiguration.selectionHandler({ (model) -> Void in
                            selectionHandlerInvoked = true
                        })
                    }
                    
                    it("is correct when selected") {
                        sectionConfiguration.didSelectRow(1)
                        expect(selectionHandlerInvoked).to(beTrue())
                    }
                    
                    it("is correct when not selected") {
                        sectionConfiguration.didSelectRow(3)
                        expect(selectionHandlerInvoked).to(beFalse())
                    }
                }
            }
            
            describe("its header title") {
                it("is correct") {
                    sectionConfiguration.headerTitle("Foo Header")
                    expect(sectionConfiguration.titleForHeader()).to(equal("Foo Header"))
                }
            }
            
            describe("its footer title") {
                it("is correct") {
                    sectionConfiguration.footerTitle("Bar Footer")
                    expect(sectionConfiguration.titleForFooter()).to(equal("Bar Footer"))
                }
            }
        }
    }
}