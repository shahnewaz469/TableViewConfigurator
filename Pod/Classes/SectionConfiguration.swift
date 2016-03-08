//
//  ConstantSectionConfiguration.swift
//  Pods
//
//  Created by John Volk on 2/29/16.
//
//

import UIKit

public class SectionConfiguration {

    private let rowConfigurations: [RowConfiguration];
    
    public init(rowConfigurations: [RowConfiguration]) {
        self.rowConfigurations = rowConfigurations;
    }
    
    public init(rowConfiguration: RowConfiguration) {
        self.rowConfigurations = [rowConfiguration];
    }
    
    public func visibleIndexSetForRowConfiguration(rowConfiguration: RowConfiguration) -> NSIndexSet? {
        return indexSetForRowConfiguration(rowConfiguration, visible: true);
    }
    
    public func hiddenIndexSetForRowConfiguration(rowConfiguration: RowConfiguration) -> NSIndexSet? {
        return indexSetForRowConfiguration(rowConfiguration, visible: false);
    }
    
    private func indexSetForRowConfiguration(rowConfiguration: RowConfiguration, visible: Bool) -> NSIndexSet? {
        var currentIndex = 0;
        
        for candidate in self.rowConfigurations {
            let numberOfRows = candidate.numberOfRows(visible);
            
            if rowConfiguration === candidate {
                return NSIndexSet(indexesInRange: NSMakeRange(currentIndex, numberOfRows));
            }
            
            currentIndex += numberOfRows;
        }
        
        return nil;
    }
    
    public func numberOfSections() -> Int {
        return 1;
    }
    
    public func numberOfRowsInSection(section: Int) -> Int? {
        if section < numberOfSections() {
            return self.rowConfigurations.reduce(0) { (totalRows, rowConfiguration) -> Int in
                return totalRows + rowConfiguration.numberOfRows(false);
            }
        }
        
        return nil;
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
            let numberOfRows = rowConfiguration.numberOfRows(false);
            
            if row < rowTotal + numberOfRows {
                return handler(rowConfiguration: rowConfiguration, localizedRow: row - rowTotal);
            }
            
            rowTotal += numberOfRows;
        }
        
        fatalError("Couldn't resolve RowConfiguration for localized row \(row).");
    }
}
