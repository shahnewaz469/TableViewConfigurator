//
//  ConstantSectionConfiguration.swift
//  Pods
//
//  Created by John Volk on 2/29/16.
//  Copyright © 2016 John Volk. All rights reserved.
//

import UIKit

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
    
    public func headerTitle(headerTitle: String) -> Self {
        self.headerTitle = headerTitle
        return self
    }
    
    public func footerTitle(footerTitle: String) -> Self {
        self.footerTitle = footerTitle
        return self
    }
    
    
    internal func indexSetForRowConfiguration(rowConfiguration: RowConfiguration) -> NSIndexSet {
        let result = NSMutableIndexSet()
        var rowTotal = 0
        
        for candidateConfiguration in self.rowConfigurations {
            let numberOfRows = candidateConfiguration.numberOfRows(false)
            
            if candidateConfiguration === rowConfiguration {
                for i in 0 ..< numberOfRows {
                    result.addIndex(i + rowTotal)
                }
            }
            
            rowTotal += numberOfRows
        }
        
        return result
    }
    
    internal func visibilityMap() -> [[Int: Bool]] {
        var result = [[Int: Bool]]()
        
        for configuration in self.rowConfigurations {
            var visibilityMap = [Int: Bool]()
            let numberOfRows = configuration.numberOfRows(true)
            
            for i in 0 ..< numberOfRows {
                visibilityMap[i] = configuration.rowIsVisible(i)!
            }
            
            result.append(visibilityMap)
        }
        
        return result
    }
    
    internal func refreshAllRowConfigurationsWithSection(section: Int, inTableView tableView: UITableView) {
        for rowConfiguration in self.rowConfigurations {
            refreshRowConfiguration(rowConfiguration, withSection: section, inTableView: tableView)
        }
    }
    
    internal func refreshRowConfiguration(rowConfiguration: RowConfiguration, withSection section: Int, inTableView tableView: UITableView) {
        for index in indexSetForRowConfiguration(rowConfiguration) {
            performRowOperation(index, handler: { (rowConfiguration, localizedRow) -> Void in
                rowConfiguration.refreshCellForRow(localizedRow,
                    withIndexPath: NSIndexPath(forRow: index, inSection: section), inTableView: tableView)
            })
        }
    }
    
    internal func titleForHeader() -> String? {
        return self.headerTitle
    }
    
    internal func titleForFooter() -> String? {
        return self.footerTitle
    }
    
    internal func numberOfRows() -> Int? {
        return self.rowConfigurations.reduce(0) { (totalRows, rowConfiguration) -> Int in
            return totalRows + rowConfiguration.numberOfRows(false)
        }
    }
    
    internal func cellForRow(row: Int, inTableView tableView: UITableView) -> UITableViewCell? {
        return performRowOperation(row, handler: { (rowConfiguration, localizedRow) -> UITableViewCell? in
            return rowConfiguration.cellForRow(localizedRow, inTableView: tableView)
        })
    }
    
    internal func heightForRow(row: Int) -> CGFloat? {
        return performRowOperation(row, handler: { (rowConfiguration, localizedRow) -> CGFloat? in
            return rowConfiguration.heightForRow(localizedRow)
        })
    }
    
    internal func estimatedHeightForRow(row: Int) -> CGFloat? {
        return performRowOperation(row, handler: { (rowConfiguration, localizedRow) -> CGFloat? in
            return rowConfiguration.estimatedHeightForRow(localizedRow)
        })
    }
    
    internal func didSelectRow(row: Int) -> Bool? {
        return performRowOperation(row, handler: { (rowConfiguration, localizedRow) -> Bool? in
            return rowConfiguration.didSelectRow(localizedRow)
        })
    }
    
    private func performRowOperation<T>(row: Int, handler: (rowConfiguration: RowConfiguration, localizedRow: Int) -> T) -> T {
        var rowTotal = 0
        
        for rowConfiguration in self.rowConfigurations {
            let numberOfRows = rowConfiguration.numberOfRows(false)
            
            if row < rowTotal + numberOfRows {
                return handler(rowConfiguration: rowConfiguration, localizedRow: row - rowTotal)
            }
            
            rowTotal += numberOfRows
        }
        
        fatalError("Couldn't resolve RowConfiguration for localized row \(row).")
    }
}
