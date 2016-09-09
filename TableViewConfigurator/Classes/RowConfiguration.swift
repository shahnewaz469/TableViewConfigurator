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
    
    public func cellReuseId(_ cellReuseId: String) -> Self {
        self.cellReuseId = cellReuseId
        return self
    }
    
    public func height(_ height: CGFloat) -> Self {
        self.height = height
        return self
    }
    
    public func estimatedHeight(_ estimatedHeight: CGFloat) -> Self {
        self.estimatedHeight = estimatedHeight
        return self
    }
    
    internal func numberOfRows(countHidden: Bool) -> Int { return 0 }
    
    internal func rowIsVisible(row: Int) -> Bool? { return true }
    
    internal func cellFor(row: Int, inTableView tableView: UITableView) -> UITableViewCell? { return nil };
    
    internal func refreshCellFor(row: Int, withIndexPath indexPath: IndexPath, inTableView tableView: UITableView) { }
    
    internal func heightFor(row: Int) -> CGFloat? {
        if row < numberOfRows(countHidden: false) {
            return self.height
        }
        
        return nil
    }
    
    internal func estimatedHeightFor(row: Int) -> CGFloat? {
        if row < numberOfRows(countHidden: false) {
            return self.estimatedHeight
        }
        
        return nil
    }
    
    internal func didSelect(row: Int) { };
}
