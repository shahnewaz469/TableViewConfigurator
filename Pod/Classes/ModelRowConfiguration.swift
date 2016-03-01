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
    private let cellConfigurator: ((cell: CellType, model: ModelType) -> Void)?;
    private let selectionHandler: ((model: ModelType) -> Bool)?;
    
    public init(models: [ModelType], cellReuseId: String, cellConfigurator: ((cell: CellType, model: ModelType) -> Void)?,
        selectionHandler: ((model: ModelType) -> Bool)?) {
            self.models = models
            self.cellReuseId = cellReuseId;
            self.cellConfigurator = cellConfigurator;
            self.selectionHandler = selectionHandler;
    }
    
    public func numberOfRows() -> Int {
        return self.models.count;
    }
    
    public func cellForRow(row: Int, inTableView tableView: UITableView) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCellWithIdentifier(self.cellReuseId) as? CellType {
            if let cellConfigurator = self.cellConfigurator {
                cellConfigurator(cell: cell, model: self.models[row]);
            }
            
            return cell;
        }
        
        fatalError("Couldn't dequeue cell for reuse identifier \(self.cellReuseId).");
    }
    
    public func didSelectRow(row: Int) -> Bool {
        if let selectionHandler = self.selectionHandler {
            return selectionHandler(model: self.models[row]);
        } else {
            return false;
        }
    }
}