//
//  RowConfiguration.swift
//  Pods
//
//  Created by John Volk on 2/29/16.
//
//

import Foundation

public class RowConfiguration {
    
    internal var cellReuseId: String?;
    
    public func cellReuseId(cellReuseId: String) -> Self {
        self.cellReuseId = cellReuseId; return self;
    }
    
    public func numberOfRows() -> Int { return 0; }
    public func cellForRow(row: Int, inTableView tableView: UITableView) -> UITableViewCell? { return nil };
    public func didSelectRow(row: Int) -> Bool? { return nil };
    
}