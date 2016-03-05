//
//  ConstantSectionConfiguration.swift
//  Pods
//
//  Created by John Volk on 2/29/16.
//  Copyright © 2016 John Volk. All rights reserved.
//

import UIKit

public class SectionConfiguration {

    private let rowConfigurations: [RowConfiguration];
    private var headerTitle: String?;
    private var footerTitle: String?;
    
    public init(rowConfigurations: [RowConfiguration]) {
        self.rowConfigurations = rowConfigurations;
    }
    
    public init(rowConfiguration: RowConfiguration) {
        self.rowConfigurations = [rowConfiguration];
    }
    
    public func headerTitle(headerTitle: String) -> Self {
        self.headerTitle = headerTitle; return self;
    }
    
    public func footerTitle(footerTitle: String) -> Self {
        self.footerTitle = footerTitle; return self;
    }
    
    public func rowIndexSetForRowConfiguration(rowConfiguration: RowConfiguration) -> NSIndexSet? {
        var currentIndex = 0;
        
        for candidate in self.rowConfigurations {
            let numberOfRows = candidate.numberOfRows();
            
            if rowConfiguration === candidate {
                return NSIndexSet(indexesInRange: NSMakeRange(currentIndex, numberOfRows));
            }
            
            currentIndex += numberOfRows;
        }
        
        return nil;
    }
    
    public func titleForHeader() -> String? {
        return self.headerTitle;
    }
    
    public func titleForFooter() -> String? {
        return self.footerTitle;
    }
    
    public func numberOfRows() -> Int? {
        return self.rowConfigurations.reduce(0) { (totalRows, rowConfiguration) -> Int in
            return totalRows + rowConfiguration.numberOfRows();
        }
    }
    
    public func cellForRow(row: Int, inTableView tableView: UITableView) -> UITableViewCell? {
        return performRowOperation(row, handler: { (rowConfiguration, localizedRow) -> UITableViewCell? in
            return rowConfiguration.cellForRow(localizedRow, inTableView: tableView);
        });
    }
    
    public func heightForRow(row: Int) -> CGFloat? {
        return performRowOperation(row, handler: { (rowConfiguration, localizedRow) -> CGFloat? in
            return rowConfiguration.heightForRow(localizedRow);
        });
    }
    
    public func estimatedHeightForRow(row: Int) -> CGFloat? {
        return performRowOperation(row, handler: { (rowConfiguration, localizedRow) -> CGFloat? in
            return rowConfiguration.estimatedHeightForRow(localizedRow);
        });
    }
    
    public func didSelectRow(row: Int) -> Bool? {
        return performRowOperation(row, handler: { (rowConfiguration, localizedRow) -> Bool? in
            return rowConfiguration.didSelectRow(localizedRow);
        });
    }
    
    private func performRowOperation<T>(row: Int, handler: (rowConfiguration: RowConfiguration, localizedRow: Int) -> T) -> T {
        var rowTotal = 0;
        
        for rowConfiguration in self.rowConfigurations {
            let numberOfRows = rowConfiguration.numberOfRows();
            
            if row < rowTotal + numberOfRows {
                return handler(rowConfiguration: rowConfiguration, localizedRow: row - rowTotal);
            }
            
            rowTotal += numberOfRows;
        }
        
        fatalError("Couldn't resolve RowConfiguration for localized row \(row).");
    }
}
