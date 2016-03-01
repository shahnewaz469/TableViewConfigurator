//
//  ConstantRowConfiguration.swift
//  Pods
//
//  Created by John Volk on 2/29/16.
//
//

import UIKit

public class ConstantRowConfiguration<CellType: UITableViewCell>: RowConfiguration {
    
    private let cellReuseId: String;
    private let cellConfigurator: ((cell: CellType) -> Void)?;
    private let selectionHandler: (() -> Bool)?;
    
    public init(cellReuseId: String, cellConfigurator: ((cell: CellType) -> Void)?,
        selectionHandler: (() -> Bool)?) {
            self.cellReuseId = cellReuseId;
            self.cellConfigurator = cellConfigurator;
            self.selectionHandler = selectionHandler;
    }
    
    public func numberOfRows() -> Int {
        return 1;
    }
    
    public func cellForRow(row: Int, inTableView tableView: UITableView) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCellWithIdentifier(self.cellReuseId) as? CellType {
            if let cellConfigurator = self.cellConfigurator {
                cellConfigurator(cell: cell);
            }
            
            return cell;
        }
        
        fatalError("Couldn't dequeue cell for reuse identifier \(self.cellReuseId).");
    }
    
    public func didSelectRow(row: Int) -> Bool {
        if let selectionHandler = self.selectionHandler {
            return selectionHandler();
        }
        
        return false;
    }
}