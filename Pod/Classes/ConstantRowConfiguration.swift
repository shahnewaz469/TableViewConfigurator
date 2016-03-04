//
//  ConstantRowConfiguration.swift
//  Pods
//
//  Created by John Volk on 2/29/16.
//
//

import UIKit

public class ConstantRowConfiguration<CellType: ConfigurableTableViewCell where CellType: UITableViewCell>: RowConfiguration {
    
    private var additionalConfig: ((cell: CellType) -> Void)?;
    private var selectionHandler: (() -> Bool)?;
    private var hideWhen: (() -> Bool)?
    
    public override init() { }
    
    public func additionalConfig(additionalConfig: (cell: CellType) -> Void) -> Self {
        self.additionalConfig = additionalConfig; return self;
    }
    
    public func selectionHandler(selectionHandler: () -> Bool) -> Self {
        self.selectionHandler = selectionHandler; return self;
    }
    
    public func hideWhen(hideWhen: () -> Bool) -> Self {
        self.hideWhen = hideWhen; return self;
    }
    
    override internal func numberOfRows() -> Int {
        if let hideWhen = self.hideWhen {
            return hideWhen() ? 0 : 1;
        }
        
        return 1;
    }
    
    override internal func cellForRow(row: Int, inTableView tableView: UITableView) -> UITableViewCell? {
        if row < numberOfRows() {
            let reuseId = self.cellReuseId ?? CellType.buildReuseIdentifier();
            
            if let reuseId = reuseId {
                if let cell = tableView.dequeueReusableCellWithIdentifier(reuseId) as? CellType {
                    if let additionalConfig = self.additionalConfig {
                        additionalConfig(cell: cell);
                    }
                    
                    cell.configure();
                    
                    return cell;
                }
            }
        }
        
        return nil;
    }
    
    override internal func didSelectRow(row: Int) -> Bool? {
        if row < numberOfRows() {
            return self.selectionHandler?();
        }
        
        return nil;
    }
}