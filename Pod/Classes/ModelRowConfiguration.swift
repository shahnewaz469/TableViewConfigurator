//
//  ModelRowConfiguration.swift
//  Pods
//
//  Created by John Volk on 3/1/16.
//
//

import UIKit

public class ModelRowConfiguration<CellType: ModelConfigurableTableViewCell, ModelType where CellType: UITableViewCell, CellType.Model == ModelType>: RowConfiguration {

    private let models: [ModelType];
    
    private var additionalCellConfig: ((cell: CellType, model: ModelType) -> Void)?;
    private var selectionHandler: ((model: ModelType) -> Bool)?;
    
    public init(models: [ModelType]) {
        self.models = models;
    }
    
    public func additionalCellConfig(additionalCellConfig: (cell: CellType, model: ModelType) -> Void) -> Self {
        self.additionalCellConfig = additionalCellConfig; return self;
    }
    
    public func selectionHandler(selectionHandler: (model: ModelType) -> Bool) -> Self {
        self.selectionHandler = selectionHandler; return self;
    }
    
    override public func numberOfRows() -> Int {
        return self.models.count;
    }
    
    override public func cellForRow(row: Int, inTableView tableView: UITableView) -> UITableViewCell? {
        let reuseId = self.cellReuseId ?? CellType.buildReuseIdentifier();
        
        if let reuseId = reuseId {
            if let cell = tableView.dequeueReusableCellWithIdentifier(reuseId) as? CellType {
                if let additionalCellConfig = self.additionalCellConfig {
                    additionalCellConfig(cell: cell, model: self.models[row]);
                }
                
                cell.configure(self.models[row]);
                
                return cell;
            }
        }
        
        return nil;
    }
    
    override public func didSelectRow(row: Int) -> Bool? {
        return self.selectionHandler?(model: self.models[row]);
    }
}