//
//  ConstantRowConfiguration.swift
//  Pods
//
//  Created by John Volk on 2/29/16.
//
//

import UIKit

public class ConstantRowConfiguration<CellType: ConfigurableTableViewCell where CellType: UITableViewCell>: RowConfiguration {
    
    private var additionalCellConfig: ((cell: CellType) -> Void)?;
    private var selectionHandler: (() -> Bool)?;
    private var hideWhen: (() -> Bool)?
    
    public override init() { }
    
    public func additionalCellConfig(additionalCellConfig: (cell: CellType) -> Void) -> Self {
        self.additionalCellConfig = additionalCellConfig; return self;
    }
    
    public func selectionHandler(selectionHandler: () -> Bool) -> Self {
        self.selectionHandler = selectionHandler; return self;
    }
    
    public func hideWhen(hideWhen: () -> Bool) -> Self {
        self.hideWhen = hideWhen; return self;
    }
    
    override public func numberOfRows() -> Int {
        if let hideWhen = self.hideWhen {
            return hideWhen() ? 0 : 1;
        }
        
        return 1;
    }
    
    override public func cellForRow(row: Int, inTableView tableView: UITableView) -> UITableViewCell? {
        let reuseId = self.cellReuseId ?? CellType.buildReuseIdentifier();
        
        if let reuseId = reuseId {
            if let cell = tableView.dequeueReusableCellWithIdentifier(reuseId) as? CellType {
                if let additionalCellConfig = self.additionalCellConfig {
                    additionalCellConfig(cell: cell);
                }
                
                cell.configure();
                
                return cell;
            }
        }
        
        return nil;
    }
    
    override public func didSelectRow(row: Int) -> Bool? {
        return self.selectionHandler?();
    }
}