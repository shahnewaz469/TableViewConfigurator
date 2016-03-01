//
//  ConstantSectionConfiguration.swift
//  Pods
//
//  Created by John Volk on 2/29/16.
//
//

import UIKit

public class ConstantSectionConfiguration: SectionConfiguration {

    private let rowConfigurations: [RowConfiguration];
    
    public init(rowConfigurations: [RowConfiguration]) {
        self.rowConfigurations = rowConfigurations;
    }
    
    public func numberOfSections() -> Int {
        return 1;
    }
    
    public func numberOfRowsInSection(section: Int) -> Int {
        return self.rowConfigurations.reduce(0) { (totalRows, rowConfiguration) -> Int in
            return totalRows + rowConfiguration.numberOfRows();
        }
    }
    
    public func cellForRowAtIndexPath(indexPath: NSIndexPath, inTableView tableView: UITableView) -> UITableViewCell {
        var rowTotal = 0;
        
        for rowConfiguration in self.rowConfigurations {
            let numberOfRows = rowConfiguration.numberOfRows();
            
            if indexPath.row < rowTotal + numberOfRows {
                return rowConfiguration.cellForRow(indexPath.row - rowTotal, inTableView: tableView);
            }
            
            rowTotal += numberOfRows;
        }
        
        fatalError("Couldn't resolve RowConfiguration for localized indexPath \(indexPath).");
    }
}
