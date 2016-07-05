//
//  ConstantRowConfiguration.swift
//  Pods
//
//  Created by John Volk on 2/29/16.
//  Copyright © 2016 John Volk. All rights reserved.
//

import UIKit

public class ConstantRowConfiguration<CellType: ConfigurableTableViewCell where CellType: UITableViewCell>: RowConfiguration {
    
    private var additionalConfig: ((cell: CellType) -> Void)?
    private var selectionHandler: (() -> Bool)?
    private var hideWhen: (() -> Bool)?
    
    public override init() { }
    
    public func additionalConfig(additionalConfig: (cell: CellType) -> Void) -> Self {
        self.additionalConfig = additionalConfig; return self
    }
    
    public func selectionHandler(selectionHandler: () -> Bool) -> Self {
        self.selectionHandler = selectionHandler; return self
    }
    
    public func hideWhen(hideWhen: () -> Bool) -> Self {
        self.hideWhen = hideWhen; return self
    }
    
    override internal func numberOfRows(countHidden: Bool) -> Int {
        if let hideWhen = self.hideWhen where !countHidden {
            return hideWhen() ? 0 : 1
        }
        
        return 1
    }
    
    override func rowIsVisible(row: Int) -> Bool? {
        if row < numberOfRows(true) {
            if let hideWhen = self.hideWhen {
                return !hideWhen()
            }
            
            return true
        }
        
        return nil
    }
    
    override func cellForRow(row: Int, inTableView tableView: UITableView) -> UITableViewCell? {
        if row < numberOfRows(false) {
            let reuseId = self.cellReuseId ?? CellType.buildReuseIdentifier()
            
            if let cell = tableView.dequeueReusableCellWithIdentifier(reuseId) as? CellType {
                return configureCell(cell)
            }
        }
        
        return nil
    }
    
    override func refreshCellForRow(row: Int, withIndexPath indexPath: NSIndexPath, inTableView tableView: UITableView) {
        if row < numberOfRows(false) {
            if let cell = tableView.cellForRowAtIndexPath(indexPath) as? CellType {
                configureCell(cell)
            }
        }
    }
    
    private func configureCell(cell: CellType) -> CellType {
        cell.configure()
        
        if let additionalConfig = self.additionalConfig {
            additionalConfig(cell: cell)
        }
        
        return cell
    }
    
    override internal func didSelectRow(row: Int) -> Bool? {
        if row < numberOfRows(false) {
            return self.selectionHandler?()
        }
        
        return nil
    }
}