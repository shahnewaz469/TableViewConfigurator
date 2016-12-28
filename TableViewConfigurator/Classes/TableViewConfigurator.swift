//
//  TableViewConfigurator.swift
//  Pods
//
//  Created by John Volk on 2/29/16.
//  Copyright © 2016 John Volk. All rights reserved.
//

import UIKit
import Dwifft

public typealias TableViewChangeSet = (rowInsertions: [IndexPath], rowDeletions: [IndexPath], sectionInsertions: IndexSet, sectionDeletions: IndexSet)

public class TableViewConfigurator: NSObject, UITableViewDataSource, UITableViewDelegate {

    private var sectionConfigurations: [SectionConfiguration]
    private var tableView: UITableView
    
    public init(tableView: UITableView, sectionConfigurations: [SectionConfiguration]) {
        self.tableView = tableView
        self.sectionConfigurations = sectionConfigurations
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
        let preOpSectionVisibility = sectionVisibilitySnapshot()
        
        self.sectionConfigurations.forEach { $0.saveSnapshot() }
        operation()
        
        var rowInsertions = [IndexPath]()
        var rowDeletions = [IndexPath]()
        let postOpSectionVisibility = sectionVisibilitySnapshot()
        let changeSets = self.sectionConfigurations.map { $0.snapshotChangeSet() }
        
        for (i, changeSet) in changeSets.enumerated() {
            let insertions = changeSet.rowInsertions
            let deletions = changeSet.rowDeletions
            
            if insertions.count > 0 || deletions.count > 0 {
                let preOpCount = changeSet.initialRowCount
                let postOpCount = preOpCount + insertions.count - deletions.count
                
                if preOpCount > 0 && postOpCount > 0 {
                    insertions.forEach { rowInsertions.append(IndexPath(row: $0, section: i)) }
                    deletions.forEach { rowDeletions.append(IndexPath(row: $0, section: i)) }
                }
            }
        }
        
        var sectionInsertions = IndexSet()
        var sectionDeletions = IndexSet()
        let sectionDiff = preOpSectionVisibility.diff(postOpSectionVisibility)
        
        sectionDiff.insertions.forEach { sectionInsertions.insert($0.idx) }
        sectionDiff.deletions.forEach { sectionDeletions.insert($0.idx) }
        
        return TableViewChangeSet(rowInsertions: rowInsertions, rowDeletions: rowDeletions, sectionInsertions: sectionInsertions, sectionDeletions: sectionDeletions)
    }
    
    private func sectionVisibilitySnapshot() -> [Int] {
        var sectionVisibility = [Int]()
        
        for (i, section) in self.sectionConfigurations.enumerated() {
            if section.numberOfRows() > 0 {
                sectionVisibility.append(i)
            }
        }
        
        return sectionVisibility
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
    
    public func numberOfSections(in tableView: UITableView) -> Int {
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
