//
//  ConstantSectionConfiguration.swift
//  Pods
//
//  Created by John Volk on 2/29/16.
//  Copyright © 2016 John Volk. All rights reserved.
//

import UIKit

typealias SnapshotChangeSet = (initialRowCount: Int, rowInsertions: [Int], rowDeletions: [Int])

public class SectionConfiguration {

    private var headerTitle: String?
    private var footerTitle: String?
    private let rowConfigurations: [RowConfiguration]
    
    public init(rowConfigurations: [RowConfiguration]) {
        self.rowConfigurations = rowConfigurations
    }
    
    public init(rowConfiguration: RowConfiguration) {
        self.rowConfigurations = [rowConfiguration]
    }
    
    public func headerTitle(_ headerTitle: String) -> Self {
        self.headerTitle = headerTitle
        return self
    }
    
    public func footerTitle(_ footerTitle: String) -> Self {
        self.footerTitle = footerTitle
        return self
    }
    
    internal func indexSetFor(rowConfiguration: RowConfiguration) -> IndexSet {
        var result = IndexSet()
        var rowTotal = 0
        
        for candidateConfiguration in self.rowConfigurations {
            let numberOfRows = candidateConfiguration.numberOfRows()
            
            if candidateConfiguration === rowConfiguration {
                for i in 0 ..< numberOfRows {
                    result.insert(i + rowTotal)
                }
            }
            
            rowTotal += numberOfRows
        }
        
        return result
    }
    
    internal func saveSnapshot() {
        self.rowConfigurations.forEach { $0.saveSnapshot() }
    }
    
    internal func snapshotChangeSet() -> SnapshotChangeSet {
        var rowInsertions = [Int]()
        var rowDeletions = [Int]()
        var totalRows = 0
        
        for configuration in self.rowConfigurations {
            if let changeSet = configuration.snapshotChangeSet() {
                changeSet.rowInsertions.forEach { rowInsertions.append( $0 + totalRows ) }
                changeSet.rowDeletions.forEach { rowDeletions.append( $0 + totalRows ) }
                totalRows += changeSet.initialRowCount
            }
        }
        
        return (totalRows, rowInsertions, rowDeletions)
    }
    
    internal func refreshAllRowConfigurationsWith(section: Int, inTableView tableView: UITableView) {
        for rowConfiguration in self.rowConfigurations {
            refresh(rowConfiguration: rowConfiguration, withSection: section, inTableView: tableView)
        }
    }
    
    internal func refresh(rowConfiguration: RowConfiguration, withSection section: Int, inTableView tableView: UITableView) {
        for index in indexSetFor(rowConfiguration: rowConfiguration) {
            performOperationFor(row: index, handler: { (rowConfiguration, localizedRow) -> Void in
                rowConfiguration.refreshCellFor(row: localizedRow,
                    withIndexPath: IndexPath(row: index, section: section), inTableView: tableView)
            })
        }
    }
    
    internal func titleForHeader() -> String? {
        return self.headerTitle
    }
    
    internal func titleForFooter() -> String? {
        return self.footerTitle
    }
    
    internal func numberOfRows() -> Int {
        return self.rowConfigurations.reduce(0) { (totalRows, rowConfiguration) -> Int in
            return totalRows + rowConfiguration.numberOfRows()
        }
    }
    
    internal func cellFor(row: Int, inTableView tableView: UITableView) -> UITableViewCell? {
        return performOperationFor(row: row, handler: { (rowConfiguration, localizedRow) -> UITableViewCell? in
            return rowConfiguration.cellFor(row: localizedRow, inTableView: tableView)
        })
    }
    
    internal func heightFor(row: Int) -> CGFloat? {
        return performOperationFor(row: row, handler: { (rowConfiguration, localizedRow) -> CGFloat? in
            return rowConfiguration.heightFor(row: localizedRow)
        })
    }
    
    internal func estimatedHeightFor(row: Int) -> CGFloat? {
        return performOperationFor(row: row, handler: { (rowConfiguration, localizedRow) -> CGFloat? in
            return rowConfiguration.estimatedHeightFor(row: localizedRow)
        })
    }
    
    internal func didSelect(row: Int) {
        return performOperationFor(row: row, handler: { (rowConfiguration, localizedRow) -> Void in
            rowConfiguration.didSelect(row: localizedRow)
        })
    }
    
    private func performOperationFor<T>(row: Int, handler: (RowConfiguration, Int) -> T) -> T {
        var rowTotal = 0
        
        for rowConfiguration in self.rowConfigurations {
            let numberOfRows = rowConfiguration.numberOfRows()
            
            if row < rowTotal + numberOfRows {
                return handler(rowConfiguration, row - rowTotal)
            }
            
            rowTotal += numberOfRows
        }
        
        fatalError("Couldn't resolve RowConfiguration for localized row \(row).")
    }
}
