//
//  ModelRowConfiguration.swift
//  Pods
//
//  Created by John Volk on 3/1/16.
//  Copyright © 2016 John Volk. All rights reserved.
//

import UIKit
import Dwifft

public protocol RowModel: class, Equatable {
    
    var identityTag: String? { get set }
    
}

public func == <T: RowModel>(lhs: T, rhs: T) -> Bool {
    return lhs.identityTag == rhs.identityTag
}

private var identityTagAssociationKey: UInt8 = 0

public extension RowModel {
    
    var identityTag: String? {
        get {
            return objc_getAssociatedObject(self, &identityTagAssociationKey) as? String
        }
        set(value) {
            objc_setAssociatedObject(self, &identityTagAssociationKey, value, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        }
    }
    
}

public class ModelRowConfiguration<CellType, ModelType>: RowConfiguration
    where CellType: UITableViewCell, CellType: ModelConfigurableTableViewCell, ModelType == CellType.ModelType {
    
    private let optimizeModels: Bool
    private var models: [ModelType]?
    private let modelGenerator: (() -> [ModelType]?)?
    private var modelSnapshot = [ModelType]()
    
    private var heightGenerator: ((_ model: ModelType) -> CGFloat)?
    private var estimatedHeightGenerator: ((_ model: ModelType) -> CGFloat)?
    private var additionalConfig: ((_ cell: CellType, _ model: ModelType, _ index: Int) -> Void)?
    private var selectionHandler: ((_ model: ModelType, _ index: Int) -> Void)?
    private var canEditHandler: ((_ model: ModelType, _ index: Int) -> Bool)?
    private var editHandler: ((_ editingStyle: UITableViewCell.EditingStyle, _ model: ModelType, _ index: Int) -> Void)?
    private var hideWhen: ((_ model: ModelType) -> Bool)?
    
    public init(models: [ModelType]) {
        self.optimizeModels = true
        self.models = models
        self.modelGenerator = nil
    }
    
    public init(modelGenerator: @escaping () -> [ModelType]?, optimizeModels: Bool = false) {
        self.optimizeModels = optimizeModels
        self.modelGenerator = modelGenerator
        self.models = modelGenerator()
    }
    
    public func heightGenerator(_ heightGenerator: @escaping (_ model: ModelType) -> CGFloat) -> Self {
        self.heightGenerator = heightGenerator
        return self
    }
    
    public func estimatedHeightGenerator(_ estimatedHeightGenerator: @escaping (_ model: ModelType) -> CGFloat) -> Self {
        self.estimatedHeightGenerator = estimatedHeightGenerator
        return self
    }
    
    public func additionalConfig(_ additionalConfig: @escaping (_ cell: CellType, _ model: ModelType, _ index: Int) -> Void) -> Self {
        self.additionalConfig = additionalConfig
        return self
    }
    
    public func selectionHandler(_ selectionHandler: @escaping (_ model: ModelType, _ index: Int) -> Void) -> Self {
        self.selectionHandler = selectionHandler
        return self
    }
    
    public func canEditHandler(_ canEditHandler: @escaping (_ model: ModelType, _ index: Int) -> Bool) -> Self {
        self.canEditHandler = canEditHandler
        return self
    }
    
    public func editHandler(_ editHandler: @escaping (_ editingStyle: UITableViewCell.EditingStyle, _ model: ModelType, _ index: Int) -> Void) -> Self {
        self.editHandler = editHandler
        return self
    }
    
    public func hideWhen(_ hideWhen: @escaping (_ model: ModelType) -> Bool) -> Self {
        self.hideWhen = hideWhen
        return self
    }
    
    override internal func numberOfRows() -> Int {
        if let models = getModels() {
            if let hideWhen = self.hideWhen {
                return models.reduce(0) { (totalRows, model) -> Int in
                    return totalRows + (hideWhen(model) ? 0 : 1)
                }
            }
        
            return models.count
        }
        
        return 0
    }
    
    override func saveSnapshot() {
        self.modelSnapshot.removeAll(keepingCapacity: true)
        self.refreshModels()
        
        if let models = getModels() {
            for i in 0 ..< models.count {
                let model = models[i]
                
                if model.identityTag == nil {
                    model.identityTag = String(i)
                }
            }
            
            if let hideWhen = self.hideWhen {
                self.modelSnapshot.append(contentsOf: models.filter { !hideWhen($0) })
            } else {
                self.modelSnapshot.append(contentsOf: models)
            }
        }
    }
    
    override func snapshotChangeSet() -> SnapshotChangeSet? {
        let before = self.modelSnapshot
        
        saveSnapshot()
        
        var rowInsertions = [Int]()
        var rowDeletions = [Int]()
        let diff = Dwifft.diff(before, self.modelSnapshot)
        
        for result in diff {
            switch result {
            case let .insert(i, _):
                rowInsertions.append(i)
            case let .delete(i, _):
                rowDeletions.append(i)
            }
        }
        
        return (before.count, rowInsertions, rowDeletions)
    }
    
    override func cellFor(row: Int, inTableView tableView: UITableView) -> UITableViewCell? {
        let reuseId = self.cellReuseId ?? CellType.buildReuseIdentifier()

        if let cell = tableView.dequeueReusableCell(withIdentifier: reuseId) as? CellType {
            return configure(cell: cell, forRow: row)
        }

        return nil
    }
    
    override func refreshCellFor(row: Int, withIndexPath indexPath: IndexPath, inTableView tableView: UITableView) {
        if let cell = tableView.cellForRow(at: indexPath) as? CellType {
            _ = configure(cell: cell, forRow: row)
        }
    }
    
    private func configure(cell: CellType, forRow row: Int) -> CellType {
        if let model = self.selectModelFor(row: row) {
            cell.configure(model: model)
            
            if let additionalConfig = self.additionalConfig {
                additionalConfig(cell, model, originalIndexFor(row: row))
            }
        }
        
        return cell
    }
    
    override func heightFor(row: Int) -> CGFloat? {
        if let heightGenerator = self.heightGenerator, let model = selectModelFor(row: row) {
            return heightGenerator(model)
        }
        
        return super.heightFor(row: row)
    }
    
    override func estimatedHeightFor(row: Int) -> CGFloat? {
        if let estimatedHeightGenerator = self.estimatedHeightGenerator, let model = selectModelFor(row: row) {
            return estimatedHeightGenerator(model)
        }
        
        return super.estimatedHeightFor(row: row)
    }
    
    override internal func didSelect(row: Int) {
        if let model = selectModelFor(row: row) {
            self.selectionHandler?(model, originalIndexFor(row: row))
        }
    }
    
    override func canEdit(row: Int) -> Bool {
        if let model = selectModelFor(row: row) {
            return self.canEditHandler?(model, originalIndexFor(row: row)) ?? false
        }
        return false
    }
    
    override func commit(editingStyle: UITableViewCell.EditingStyle, forRow row: Int) {
        if let model = selectModelFor(row: row) {
            self.editHandler?(editingStyle, model, originalIndexFor(row: row))
        }
    }
    
    private func selectModelFor(row: Int) -> ModelType? {
        if let models = getModels() {
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
        
        return nil
    }
    
    private func originalIndexFor(row: Int) -> Int {
        if let hideWhen = self.hideWhen, let models = getModels() {
            var total = 0
            var unhiddenTotal = 0
            
            for model in models {
                total += 1
                unhiddenTotal += (hideWhen(model) ? 0 : 1)
                
                if unhiddenTotal - 1 == row {
                    return total - 1
                }
            }
        }
        
        return row
    }
    
    private func getModels() -> [ModelType]? {
        if self.optimizeModels {
            return self.models
        } else if let modelGenerator = self.modelGenerator {
            return modelGenerator()
        }
        return nil
    }
    
    private func refreshModels() {
        if self.optimizeModels, let modelGenerator = self.modelGenerator {
            self.models = modelGenerator()
        }
    }
}
