//
//  ConstantRowConfiguration.swift
//  Pods
//
//  Created by John Volk on 2/29/16.
//
//

import UIKit

public class ConstantRowConfiguration<CellType: UITableViewCell>: RowConfiguration {
    
    private let rowSpan: Int;
    private let cellReuseId: String;
    private let cellConfigurator: (cell: CellType) -> Void;
    
    public init(rowSpan: Int, cellReuseId: String, cellConfigurator: (cell: CellType) -> Void) {
        self.rowSpan = rowSpan;
        self.cellReuseId = cellReuseId;
        self.cellConfigurator = cellConfigurator;
    }
    
    public func numberOfRows() -> Int {
        return self.rowSpan;
    }
    
    public func cellForRow(row: Int, inTableView tableView: UITableView) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCellWithIdentifier(self.cellReuseId) as? CellType {
            self.cellConfigurator(cell: cell);
            return cell;
        }
        
        fatalError("Couldn't dequeue cell for reuse identifier \(self.cellReuseId).");
    }
}