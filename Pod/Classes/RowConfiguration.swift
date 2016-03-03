//
//  RowConfiguration.swift
//  Pods
//
//  Created by John Volk on 2/29/16.
//
//

import Foundation

public class RowConfiguration {
    
    private var height: CGFloat?;
    private var estimatedHeight: CGFloat?;
    
    internal var cellReuseId: String?;
    
    public func cellReuseId(cellReuseId: String) -> Self {
        self.cellReuseId = cellReuseId; return self;
    }
    
    public func height(height: CGFloat) -> Self {
        self.height = height; return self;
    }
    
    public func estimatedHeight(estimatedHeight: CGFloat) -> Self {
        self.estimatedHeight = estimatedHeight; return self;
    }
    
    internal func numberOfRows() -> Int { return 0; }
    internal func cellForRow(row: Int, inTableView tableView: UITableView) -> UITableViewCell? { return nil };
    internal func heightForRow(row: Int) -> CGFloat? { return self.height }
    internal func estimatedHeightForRow(row: Int) -> CGFloat? { return self.estimatedHeight }
    internal func didSelectRow(row: Int) -> Bool? { return nil };
    
}