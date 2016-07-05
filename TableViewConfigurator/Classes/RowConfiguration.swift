//
//  RowConfiguration.swift
//  Pods
//
//  Created by John Volk on 2/29/16.
//  Copyright © 2016 John Volk. All rights reserved.
//

import Foundation

public class RowConfiguration {
    
    private var height: CGFloat?
    private var estimatedHeight: CGFloat?
    
    internal var cellReuseId: String?
    
    public func cellReuseId(cellReuseId: String) -> Self {
        self.cellReuseId = cellReuseId
        return self
    }
    
    public func height(height: CGFloat) -> Self {
        self.height = height
        return self
    }
    
    public func estimatedHeight(estimatedHeight: CGFloat) -> Self {
        self.estimatedHeight = estimatedHeight
        return self
    }
    
    internal func numberOfRows(countHidden: Bool) -> Int { return 0 }
    
    internal func rowIsVisible(row: Int) -> Bool? { return true }
    
    internal func cellForRow(row: Int, inTableView tableView: UITableView) -> UITableViewCell? { return nil };
    
    internal func refreshCellForRow(row: Int, withIndexPath indexPath: NSIndexPath, inTableView tableView: UITableView) { }
    
    internal func heightForRow(row: Int) -> CGFloat? {
        if row < numberOfRows(false) {
            return self.height
        }
        
        return nil
    }
    
    internal func estimatedHeightForRow(row: Int) -> CGFloat? {
        if row < numberOfRows(false) {
            return self.estimatedHeight
        }
        
        return nil
    }
    
    internal func didSelectRow(row: Int) -> Bool? { return nil };
}