//
//  ModelRowConfiguration.swift
//  Pods
//
//  Created by John Volk on 3/1/16.
//  Copyright © 2016 John Volk. All rights reserved.
//

import UIKit

public class ModelRowConfiguration<CellType: ModelConfigurableTableViewCell, ModelType where CellType: UITableViewCell, CellType.ModelType == ModelType>: RowConfiguration {

    private let models: [ModelType]?
    private let modelGenerator: (() -> [ModelType])?
    
    private var heightGenerator: ((_ model: ModelType) -> CGFloat)?
    private var estimatedHeightGenerator: ((_ model: ModelType) -> CGFloat)?
    private var additionalConfig: ((_ cell: CellType, _ model: ModelType) -> Void)?
    private var selectionHandler: ((_ model: ModelType) -> Void)?
    private var hideWhen: ((_ model: ModelType) -> Bool)?
    
    public init(models: [ModelType]) {
        self.models = models
        self.modelGenerator = nil
    }
    
    public init(modelGenerator: @escaping () -> [ModelType]) {
        self.modelGenerator = modelGenerator
        self.models = nil
    }
    
    public func heightGenerator(_ heightGenerator: @escaping (_ model: ModelType) -> CGFloat) -> Self {
        self.heightGenerator = heightGenerator
        return self
    }
    
    public func estimatedHeightGenerator(_ estimatedHeightGenerator: @escaping (_ model: ModelType) -> CGFloat) -> Self {
        self.estimatedHeightGenerator = estimatedHeightGenerator
        return self
    }
    
    public func additionalConfig(_ additionalConfig: @escaping (_ cell: CellType, _ model: ModelType) -> Void) -> Self {
        self.additionalConfig = additionalConfig
        return self
    }
    
    public func selectionHandler(_ selectionHandler: @escaping (_ model: ModelType) -> Void) -> Self {
        self.selectionHandler = selectionHandler
        return self
    }
    
    public func hideWhen(_ hideWhen: @escaping (_ model: ModelType) -> Bool) -> Self {
        self.hideWhen = hideWhen
        return self
    }
    
    override internal func numberOfRows(countHidden: Bool) -> Int {
        let models = generateModels()
        
        if let hideWhen = self.hideWhen, !countHidden {
            return models.reduce(0) { (totalRows, model) -> Int in
                return totalRows + (hideWhen(model) ? 0 : 1)
            }
        }
        
        return models.count
    }
    
    override func rowIsVisible(row: Int) -> Bool? {
        if row < numberOfRows(countHidden: true) {
            if let hideWhen = self.hideWhen {
                return !hideWhen(generateModels()[row])
            }
            
            return true
        }
        
        return nil
    }
    
    override func cellFor(row: Int, inTableView tableView: UITableView) -> UITableViewCell? {
        if row < numberOfRows(countHidden: false) {
            let reuseId = self.cellReuseId ?? CellType.buildReuseIdentifier()

            if let cell = tableView.dequeueReusableCell(withIdentifier: reuseId) as? CellType {
                return configure(cell: cell, forRow: row)
            }
        }
        
        return nil
    }
    
    override func refreshCellFor(row: Int, withIndexPath indexPath: IndexPath, inTableView tableView: UITableView) {
        if row < numberOfRows(countHidden: false) {
            if let cell = tableView.cellForRow(at: indexPath) as? CellType {
                configure(cell: cell, forRow: row)
            }
        }
    }
    
    private func configure(cell: CellType, forRow row: Int) -> CellType {
        let model = self.selectModelFor(row: row)
        
        cell.configure(model: model)
        
        if let additionalConfig = self.additionalConfig {
            additionalConfig(cell, model)
        }
        
        return cell
    }
    
    override func heightFor(row: Int) -> CGFloat? {
        if let heightGenerator = self.heightGenerator, row < numberOfRows(countHidden: false) {
            return heightGenerator(selectModelFor(row: row))
        }
        
        return super.heightFor(row: row)
    }
    
    override func estimatedHeightFor(row: Int) -> CGFloat? {
        if let estimatedHeightGenerator = self.estimatedHeightGenerator, row < numberOfRows(countHidden: false) {
            return estimatedHeightGenerator(selectModelFor(row: row))
        }
        
        return super.estimatedHeightFor(row: row)
    }
    
    override internal func didSelect(row: Int) {
        if row < numberOfRows(countHidden: false) {
            self.selectionHandler?(selectModelFor(row: row))
        }
    }
    
    private func selectModelFor(row: Int) -> ModelType {
        let models = generateModels()
        
        if let hideWhen = self.hideWhen {
            var unhiddenTotal = 0
            
            for model in models {
                unhiddenTotal += (hideWhen(model) ? 0 : 1)
                
                if unhiddenTotal - 1 == row {
                    return model
                }
            }
        }
        
        return models[row]
    }
    
    private func generateModels() -> [ModelType] {
        if let models = self.models {
            return models
        }
        
        return self.modelGenerator!()
    }
}
