//
//  ModelRowConfiguration.swift
//  Pods
//
//  Created by John Volk on 3/1/16.
//
//

import UIKit

public class ModelRowConfiguration<CellType: UITableViewCell, ModelType>: RowConfiguration {

    private let models: [ModelType];
    private let cellReuseId: String;
    private let cellConfigurator: ((cell: CellType, model: ModelType) -> Void);
    
    public init(models: [ModelType], cellReuseId: String, cellConfigurator: (cell: CellType, model: ModelType) -> Void) {
        self.models = models
        self.cellReuseId = cellReuseId;
        self.cellConfigurator = cellConfigurator;
    }
    
    public func numberOfRows() -> Int {
        return self.models.count;
    }
    
    public func cellForRow(row: Int, inTableView tableView: UITableView) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCellWithIdentifier(self.cellReuseId) as? CellType {
            self.cellConfigurator(cell: cell, model: self.models[row]);
            return cell;
        }
        
        fatalError("Couldn't dequeue cell for reuse identifier \(self.cellReuseId).");
    }
}
