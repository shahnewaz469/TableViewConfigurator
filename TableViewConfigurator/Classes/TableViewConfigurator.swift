//
//  TableViewConfigurator.swift
//  Pods
//
//  Created by John Volk on 2/29/16.
//  Copyright © 2016 John Volk. All rights reserved.
//

import UIKit

public typealias TableViewChangeSet = (rowInsertions: [IndexPath], rowDeletions: [IndexPath], sectionInsertions: IndexSet, sectionDeletions: IndexSet)

public class TableViewConfigurator: NSObject, UITableViewDataSource, UITableViewDelegate {

    private var sectionConfigurations: [SectionConfiguration]
    private var tableView: UITableView
    
    public init(tableView: UITableView) {
        self.tableView = tableView
        self.sectionConfigurations = []
    }
    
    public init(tableView: UITableView, sectionConfigurations: [SectionConfiguration]) {
        self.tableView = tableView
        self.sectionConfigurations = sectionConfigurations
    }
    
    public func addConfiguration(sectionConfiguration: SectionConfiguration) {
        self.sectionConfigurations.append(sectionConfiguration)
    }
    
    public func insertConfiguration(sectionConfiguration: SectionConfiguration, atIndex index: Int) {
        self.sectionConfigurations.insert(sectionConfiguration, at: index)
    }
    
    public func removeAllConfigurations() {
        self.sectionConfigurations.removeAll(keepingCapacity: true)
    }
    
    public func indexPathsFor(rowConfiguration: RowConfiguration) -> [IndexPath] {
        var result = [IndexPath]()
        
        for (i, sectionConfiguration) in self.sectionConfigurations.enumerated() {
            let indices = sectionConfiguration.indexSetFor(rowConfiguration: rowConfiguration)
                
            for index in indices {
                result.append(IndexPath(row: index, section: i))
            }
        }
        
        return result
    }
    
    public func changeSetAfterPerformingOperation(_ operation: () -> Void) -> TableViewChangeSet {
        let preVisibilityMap = self.sectionConfigurations.map { (sectionConfiguration) -> [[Int: Bool]] in
            return sectionConfiguration.visibilityMap()
        }
        
        operation()
        
        var rowInsertions = [IndexPath]()
        var rowDeletions = [IndexPath]()
        var sectionInsertions = IndexSet()
        var sectionDeletions = IndexSet()
        
        for (i, sectionConfiguration) in self.sectionConfigurations.enumerated() {
            var deletionIndexOffset = 0
            var insertionIndexOffet = 0
            let preSectionVisibility = preVisibilityMap[i]
            let postSectionVisibility = sectionConfiguration.visibilityMap()
            let preVisible = preSectionVisibility.reduce(false, { (visible, visibilityMap) -> Bool in
                return visible || visibilityMap.values.reduce(false, { return $0 || $1 })
            })
            let postVisible = postSectionVisibility.reduce(false, { (visible, visibilityMap) -> Bool in
                return visible || visibilityMap.values.reduce(false, { return $0 || $1 })
            })
            
            if preVisible && postVisible {
                for (j, preRowConfigVisibility) in preSectionVisibility.enumerated() {
                    let postRowConfigVisibility = postSectionVisibility[j]
                    let indexCount = max(preRowConfigVisibility.count, postRowConfigVisibility.count)
                    
                    for index in 0 ..< indexCount {
                        switch (preRowConfigVisibility[index], postRowConfigVisibility[index]) {
                            
                        case let (.some(pre), .some(post)) where pre == true && post == true:
                            insertionIndexOffet += 1
                            deletionIndexOffset += 1
                            
                        case let (.some(pre), _) where pre == true:
                            rowDeletions.append(IndexPath(row: deletionIndexOffset, section: i))
                            deletionIndexOffset += 1
                            
                        case let (_, .some(post)) where post == true:
                            rowInsertions.append(IndexPath(row: insertionIndexOffet, section: i))
                            insertionIndexOffet += 1
                            
                        default: ()
                            
                        }
                    }
                }
            } else if preVisible {
                sectionDeletions.insert(i)
            } else if postVisible {
                sectionInsertions.insert(i)
            }
        }
        
        return TableViewChangeSet(rowInsertions: rowInsertions, rowDeletions: rowDeletions, sectionInsertions: sectionInsertions, sectionDeletions: sectionDeletions)
    }
    
    public func animate(changeSet: TableViewChangeSet,
                                 insertRowAnimation: UITableViewRowAnimation = .automatic,
                                 deleteRowAnimation: UITableViewRowAnimation = .automatic,
                                 insertSectionAnimation: UITableViewRowAnimation = .automatic,
                                 deleteSectionAnimation: UITableViewRowAnimation = .automatic) {
        self.tableView.beginUpdates()
        self.tableView.insertRows(at: changeSet.rowInsertions, with: insertRowAnimation)
        self.tableView.deleteRows(at: changeSet.rowDeletions, with: deleteRowAnimation)
        self.tableView.insertSections(changeSet.sectionInsertions, with: insertSectionAnimation)
        self.tableView.deleteSections(changeSet.sectionDeletions, with: deleteSectionAnimation)
        self.tableView.endUpdates()
    }
    
    public func refreshAllRowConfigurations() {
        for (i, sectionConfiguration) in self.sectionConfigurations.enumerated() {
            sectionConfiguration.refreshAllRowConfigurationsWith(section: i, inTableView: self.tableView)
        }
    }
    
    public func refresh(rowConfiguration: RowConfiguration) {
        for (i, sectionConfiguration) in self.sectionConfigurations.enumerated() {
            sectionConfiguration.refresh(rowConfiguration: rowConfiguration, withSection: i, inTableView: self.tableView)
        }
    }
    
    public func numberOfSections(in: UITableView) -> Int {
        if tableView === self.tableView {
            let result = self.sectionConfigurations.reduce(0, { (total, sectionConfiguration) -> Int in
                return sectionConfiguration.numberOfRows() > 0 ? total + 1 : total
            })
            return result
        }
        
        fatalError("Provided tableView doesn't match configured table view.")
    }
    
    public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if tableView === self.tableView {
            return performOperationFor(section: section, handler: { (sectionConfiguration) -> String? in
                return sectionConfiguration.titleForHeader()
            })
        }
        
        fatalError("Provided tableView doesn't match configured table view.")
    }
    
    public func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if tableView === self.tableView {
            return performOperationFor(section: section, handler: { (sectionConfiguration) -> String? in
                return sectionConfiguration.titleForFooter()
            })
        }
        
        fatalError("Provided tableView doesn't match configured table view.")
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView === self.tableView {
            return performOperationFor(section: section, handler: { (sectionConfiguration) in
                return sectionConfiguration.numberOfRows()
            })
        }
        
        fatalError("Provided tableView doesn't match configured table view.")
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView === self.tableView {
            return performOperationFor(section: indexPath.section, handler: { (sectionConfiguration) in
                if let cell = sectionConfiguration.cellFor(row: indexPath.row, inTableView: tableView) {
                    return cell
                }
                
                fatalError("Couldn't dequeue cell at indexPath \(indexPath).")
            })
        }
        
        fatalError("Provided tableView doesn't match configured table view.")
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView === self.tableView {
            return performOperationFor(section: indexPath.section, handler: { (sectionConfiguration) -> CGFloat in
                if let height = sectionConfiguration.heightFor(row: indexPath.row) {
                    return height
                }
                
                fatalError("Couldn't calculate height at indexPath \(indexPath).")
            })
        }
        
        fatalError("Provided tableView doesn't match configured table view.")
    }
    
    public func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView === self.tableView {
            return performOperationFor(section: indexPath.section, handler: { (sectionConfiguration) -> CGFloat in
                if let estimatedHeight = sectionConfiguration.estimatedHeightFor(row: indexPath.row) {
                    return estimatedHeight
                }
                
                fatalError("Couldn't calculate estimatedHeight at indexPath \(indexPath).")
            })
        }
        
        fatalError("Provided tableView doesn't match configured table view.")
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView === self.tableView {
            performOperationFor(section: indexPath.section, handler: { (sectionConfiguration) in
                sectionConfiguration.didSelect(row: indexPath.row)
            })
        } else {
            fatalError("Provided tableView doesn't match configured table view.")
        }
    }
    
    private func performOperationFor<T>(section: Int, handler: (SectionConfiguration) -> T) -> T {
        var sectionTotal = 0
        
        for sectionConfiguration in self.sectionConfigurations {
            if sectionConfiguration.numberOfRows() > 0 {
                if section == sectionTotal {
                    return handler(sectionConfiguration)
                }
                
                sectionTotal += 1
            }
        }
        
        fatalError("Couldn't resolve SectionConfiguration for section \(section).")
    }
}
