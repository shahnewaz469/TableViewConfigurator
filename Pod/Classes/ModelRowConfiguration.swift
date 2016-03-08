//
//  ModelRowConfiguration.swift
//  Pods
//
//  Created by John Volk on 3/1/16.
//
//

import UIKit

public class ModelRowConfiguration<CellType: ModelConfigurableTableViewCell, ModelType where CellType: UITableViewCell, CellType.ModelType == ModelType>: RowConfiguration {

    private let models: [ModelType];
    
    private var additionalConfig: ((cell: CellType, model: ModelType) -> Void)?;
    private var selectionHandler: ((model: ModelType) -> Bool)?;
    private var hideWhen: ((model: ModelType) -> Bool)?;
    
    public init(models: [ModelType]) {
        self.models = models;
    }
    
    public func additionalConfig(additionalConfig: (cell: CellType, model: ModelType) -> Void) -> Self {
        self.additionalConfig = additionalConfig; return self;
    }
    
    public func selectionHandler(selectionHandler: (model: ModelType) -> Bool) -> Self {
        self.selectionHandler = selectionHandler; return self;
    }
    
    public func hideWhen(hideWhen: (model: ModelType) -> Bool) -> Self {
        self.hideWhen = hideWhen; return self;
    }
    
    override internal func numberOfRows(countHidden: Bool) -> Int {
        if let hideWhen = self.hideWhen where !countHidden {
            return self.models.reduce(0) { (totalRows, model) -> Int in
                return totalRows + (hideWhen(model: model) ? 0 : 1);
            }
        }
        
        return self.models.count;
    }
    
    override internal func cellForRow(row: Int, inTableView tableView: UITableView) -> UITableViewCell? {
        if row < numberOfRows(false) {
            let reuseId = self.cellReuseId ?? CellType.buildReuseIdentifier();
            
            if let reuseId = reuseId {
                if let cell = tableView.dequeueReusableCellWithIdentifier(reuseId) as? CellType {
                    let model = self.selectModelForRow(row);
                    
                    cell.configure(model);
                    
                    if let additionalConfig = self.additionalConfig {
                        additionalConfig(cell: cell, model: model);
                    }
                    
                    return cell;
                }
            }
        }
        
        return nil;
    }
    
    override internal func didSelectRow(row: Int) -> Bool? {
        if row < numberOfRows(false) {
            return self.selectionHandler?(model: self.models[row]);
        }
        
        return nil;
    }
    
    private func selectModelForRow(row: Int) -> ModelType {
        if let hideWhen = self.hideWhen {
            var unhiddenTotal = 0;
            
            for model in models {
                unhiddenTotal += (hideWhen(model: model) ? 0 : 1);
                
                if unhiddenTotal - 1 == row {
                    return model;
                }
            }
        }
        
        return self.models[row];
    }
}