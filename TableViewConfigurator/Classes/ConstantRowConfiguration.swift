//
//  ConstantRowConfiguration.swift
//  Pods
//
//  Created by John Volk on 2/29/16.
//  Copyright © 2016 John Volk. All rights reserved.
//

import UIKit

public class ConstantRowConfiguration<CellType: ConfigurableTableViewCell>: RowConfiguration where CellType: UITableViewCell {
    
    private var snapshotVisibility: Bool = false
    
    private var additionalConfig: ((_ cell: CellType) -> Void)?
    private var selectionHandler: (() -> Void)?
    private var hideWhen: (() -> Bool)?
    
    public override init() { }
    
    public func additionalConfig(_ additionalConfig: @escaping (_ cell: CellType) -> Void) -> Self {
        self.additionalConfig = additionalConfig; return self
    }
    
    public func selectionHandler(_ selectionHandler: @escaping () -> Void) -> Self {
        self.selectionHandler = selectionHandler; return self
    }
    
    public func hideWhen(_ hideWhen: @escaping () -> Bool) -> Self {
        self.hideWhen = hideWhen; return self
    }
    
    override internal func numberOfRows() -> Int {
        if let hideWhen = self.hideWhen {
            return hideWhen() ? 0 : 1
        }
        
        return 1
    }
    
    override func saveSnapshot() {
        self.snapshotVisibility = numberOfRows() == 1
    }
    
    override func snapshotChangeSet() -> SnapshotChangeSet? {
        let before = self.snapshotVisibility
        
        saveSnapshot()
        
        let after = self.snapshotVisibility
        let rowInsertions = !before && after ? [0] : []
        let rowDeletions = before && !after ? [0] : []
        
        return (before ? 1 : 0, rowInsertions, rowDeletions)
    }
    
    override func cellFor(row: Int, inTableView tableView: UITableView) -> UITableViewCell? {
        let reuseId = self.cellReuseId ?? CellType.buildReuseIdentifier()
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: reuseId) as? CellType {
            return configure(cell: cell)
        }
        
        return nil
    }
    
    override func refreshCellFor(row: Int, withIndexPath indexPath: IndexPath, inTableView tableView: UITableView) {
        if let cell = tableView.cellForRow(at: indexPath) as? CellType {
            _ = configure(cell: cell)
        }
    }
    
    private func configure(cell: CellType) -> CellType {
        cell.configure()
        
        if let additionalConfig = self.additionalConfig {
            additionalConfig(cell)
        }
        
        return cell
    }
    
    override internal func didSelect(row: Int) {
        self.selectionHandler?()
    }
}
