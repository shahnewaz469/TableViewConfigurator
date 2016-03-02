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
    
    public func numberOfSections() -> Int {
        return 1;
    }
    
    public func numberOfRowsInSection(section: Int) -> Int {
        return self.rowConfigurations.reduce(0) { (totalRows, rowConfiguration) -> Int in
            return totalRows + rowConfiguration.numberOfRows();
        }
    }
    
    public func cellForRowAtIndexPath(indexPath: NSIndexPath, inTableView tableView: UITableView) -> UITableViewCell? {
        return performRowOperation(indexPath.row, handler: { (rowConfiguration, localizedRow) -> UITableViewCell? in
            return rowConfiguration.cellForRow(localizedRow, inTableView: tableView);
        });
    }
    
    public func didSelectRowAtIndexPath(indexPath: NSIndexPath) -> Bool? {
        return performRowOperation(indexPath.row, handler: { (rowConfiguration, localizedRow) -> Bool? in
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
