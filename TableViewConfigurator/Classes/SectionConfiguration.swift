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
    private var headerViewGenerator: (() -> UIView?)?
    private var headerViewHeight: CGFloat?
    private var displayHeaderHandler: ((UIView) -> Void)?
    
    private var footerTitle: String?
    private var footerViewGenerator: (() -> UIView?)?
    private var footerViewHeight: CGFloat?
    private var displayFooterHandler: ((UIView) -> Void)?
    
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
    
    public func headerViewGenerator(_ headerViewGenerator: @escaping () -> UIView?) -> Self {
        self.headerViewGenerator = headerViewGenerator
        return self
    }
    
    public func headerViewHeight(_ height: CGFloat) -> Self {
        self.headerViewHeight = height
        return self
    }
    
    public func displayHeaderHandler(_ handler: @escaping (UIView) -> Void) -> Self {
        self.displayHeaderHandler = handler
        return self
    }
    
    public func footerTitle(_ footerTitle: String) -> Self {
        self.footerTitle = footerTitle
        return self
    }
    
    public func footerViewGenerator(_ footerViewGenerator: @escaping () -> UIView?) -> Self {
        self.footerViewGenerator = footerViewGenerator
        return self
    }
    
    public func footerViewHeight(_ height: CGFloat) -> Self {
        self.footerViewHeight = height
        return self
    }
    
    public func displayFooterHandler(_ handler: @escaping (UIView) -> Void) -> Self {
        self.displayFooterHandler = handler
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
        var insertionOffset = 0
        var deletionOffset = 0
        
        for configuration in self.rowConfigurations {
            if let changeSet = configuration.snapshotChangeSet() {
                let insertions = changeSet.rowInsertions
                let deletions = changeSet.rowDeletions
                let preOpCount = changeSet.initialRowCount
                let postOpCount = preOpCount + insertions.count - deletions.count
                
                insertions.forEach { rowInsertions.append( $0 + insertionOffset ) }
                deletions.forEach { rowDeletions.append( $0 + deletionOffset ) }
                deletionOffset += preOpCount
                insertionOffset += postOpCount
            }
        }
        
        return (deletionOffset, rowInsertions, rowDeletions)
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
    
    internal func viewForHeader() -> UIView? {
        return self.headerViewGenerator?()
    }
    
    internal func heightForHeader() -> CGFloat {
        return self.headerViewHeight ?? 0
    }
    
    internal func willDisplayHeaderView(_ view: UIView) {
        self.displayHeaderHandler?(view)
    }
    
    internal func titleForFooter() -> String? {
        return self.footerTitle
    }

    internal func viewForFooter() -> UIView? {
        return self.footerViewGenerator?()
    }
    
    internal func heightForFooter() -> CGFloat {
        return self.footerViewHeight ?? 0
    }
    
    internal func willDisplayFooterView(_ view: UIView) {
        self.displayFooterHandler?(view)
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
    
    internal func canEdit(row: Int) -> Bool {
        return performOperationFor(row: row, handler: { (rowConfiguration, localizedRow) -> Bool in
            return rowConfiguration.canEdit(row: localizedRow)
        })
    }
    
    internal func commit(editingStyle: UITableViewCell.EditingStyle, forRow row: Int) {
        performOperationFor(row: row, handler: { (rowConfiguration, localizedRow) -> Void in
            rowConfiguration.commit(editingStyle: editingStyle, forRow: localizedRow)
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
