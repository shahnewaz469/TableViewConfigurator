//
//  RowConfiguration.swift
//  Pods
//
//  Created by John Volk on 2/29/16.
//  Copyright © 2016 John Volk. All rights reserved.
//

import Foundation
import Dwifft

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
    
    internal func numberOfRows() -> Int { return 0 }
    
    internal func saveSnapshot() { }
    
    internal func snapshotChangeSet() -> SnapshotChangeSet? { return nil }
    
    internal func cellFor(row: Int, inTableView tableView: UITableView) -> UITableViewCell? { return nil };
    
    internal func refreshCellFor(row: Int, withIndexPath indexPath: IndexPath, inTableView tableView: UITableView) { }
    
    internal func heightFor(row: Int) -> CGFloat? {
        return self.height
    }
    
    internal func estimatedHeightFor(row: Int) -> CGFloat? {
        return self.estimatedHeight
    }
    
    internal func didSelect(row: Int) { }
    
    internal func canEdit(row: Int) -> Bool { return false }
    
    internal func commit(editingStyle: UITableViewCellEditingStyle, forRow row: Int) { }
}
