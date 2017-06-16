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
        let changeSets = self.sectionConfigurations.map { $0.snapshotChangeSet() }
        let postOpSectionVisibility = sectionVisibilitySnapshot()
        var insertionSection = 0
        var deletionSection = 0
        
        for changeSet in changeSets {
            let insertions = changeSet.rowInsertions
            let deletions = changeSet.rowDeletions
            let preOpCount = changeSet.initialRowCount
            let postOpCount = preOpCount + insertions.count - deletions.count
            
            if preOpCount > 0 && postOpCount > 0 {
                insertions.forEach { rowInsertions.append(IndexPath(row: $0, section: insertionSection)) }
                deletions.forEach { rowDeletions.append(IndexPath(row: $0, section: deletionSection)) }
            }
            
            deletionSection += preOpCount > 0 ? 1 : 0
            insertionSection += postOpCount > 0 ? 1 : 0
        }
        
        var sectionInsertions = IndexSet()
        var sectionDeletions = IndexSet()
        let sectionDiff = Dwifft.diff(preOpSectionVisibility, postOpSectionVisibility)
        
        for result in sectionDiff {
            switch result {
            case let .insert(i, _):
                sectionInsertions.insert(i)
            case let .delete(i, _):
                sectionDeletions.insert(i)
            }
        }
        
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
    
    public func reloadData() {
        self.sectionConfigurations.forEach { $0.saveSnapshot() }
        self.tableView.reloadData()
    }
    
    public func refreshAllRowConfigurations() {
        self.sectionConfigurations.forEach { $0.saveSnapshot() }
        
        var section = 0
        
        for sectionConfiguration in self.sectionConfigurations {
            if sectionConfiguration.numberOfRows() > 0 {
                sectionConfiguration.refreshAllRowConfigurationsWith(section: section, inTableView: self.tableView)
                section += 1
            }
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
    
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if tableView === self.tableView {
            return performOperationFor(section: section, handler: { (sectionConfiguration) -> UIView? in
                return sectionConfiguration.viewForHeader()
            })
        }
        
        fatalError("Provided tableView doesn't match configured table view.")
    }
    
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if tableView === self.tableView {
            return performOperationFor(section: section, handler: { (sectionConfiguration) -> CGFloat in
                return sectionConfiguration.heightForHeader()
            })
        }
        
        fatalError("Provided tableView doesn't match configured table view.")
    }
    
    public func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if tableView === self.tableView {
            return performOperationFor(section: section, handler: { (sectionConfiguration) -> Void in
                sectionConfiguration.willDisplayHeaderView(view)
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
    
    public func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if tableView === self.tableView {
            return performOperationFor(section: section, handler: { (sectionConfiguration) -> UIView? in
                return sectionConfiguration.viewForFooter()
            })
        }
        
        fatalError("Provided tableView doesn't match configured table view.")
    }
    
    public func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if tableView === self.tableView {
            return performOperationFor(section: section, handler: { (sectionConfiguration) -> CGFloat in
                return sectionConfiguration.heightForFooter()
            })
        }
        
        fatalError("Provided tableView doesn't match configured table view.")
    }
    
    public func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        if tableView === self.tableView {
            return performOperationFor(section: section, handler: { (sectionConfiguration) -> Void in
                sectionConfiguration.willDisplayFooterView(view)
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
            return performOperationFor(section: indexPath.section, handler: { (sectionConfiguration) in
                sectionConfiguration.didSelect(row: indexPath.row)
            })
        }
        
        fatalError("Provided tableView doesn't match configured table view.")
    }
    
    public func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if tableView === self.tableView {
            return performOperationFor(section: indexPath.section, handler: { (sectionConfiguration) -> Bool in
                return sectionConfiguration.canEdit(row: indexPath.row)
            })
        }
        
        fatalError("Provided tableView doesn't match configured table view.")
    }
    
    public func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if tableView === self.tableView {
            return performOperationFor(section: indexPath.section, handler: { (sectionConfiguration) -> Void in
                sectionConfiguration.commit(editingStyle: editingStyle, forRow: indexPath.row)
            })
        }
        
        fatalError("Provided tableView doesn't match configured table view.")
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
