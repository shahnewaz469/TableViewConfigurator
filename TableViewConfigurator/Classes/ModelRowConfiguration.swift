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
    
    var rowTag: String? { get set }
    
}

public func == <T: RowModel>(lhs: T, rhs: T) -> Bool {
    return lhs.rowTag == rhs.rowTag
}

private var rowTagAssociationKey: UInt8 = 0

public extension RowModel {
    
    var rowTag: String? {
        get {
            return objc_getAssociatedObject(self, &rowTagAssociationKey) as? String
        }
        set(value) {
            objc_setAssociatedObject(self, &rowTagAssociationKey, value, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        }
    }
    
}

public class ModelRowConfiguration<CellType, ModelType>: RowConfiguration
    where CellType: UITableViewCell, CellType: ModelConfigurableTableViewCell, ModelType == CellType.ModelType {
    
    private let models: [ModelType]?
    private let modelGenerator: (() -> [ModelType]?)?
    private var modelSnapshot = [ModelType]()
    
    private var heightGenerator: ((_ model: ModelType) -> CGFloat)?
    private var estimatedHeightGenerator: ((_ model: ModelType) -> CGFloat)?
    private var additionalConfig: ((_ cell: CellType, _ model: ModelType) -> Void)?
    private var selectionHandler: ((_ model: ModelType, _ index: Int) -> Void)?
    private var hideWhen: ((_ model: ModelType) -> Bool)?
    
    public init(models: [ModelType], ignoreEquatable: Bool = false) {
        self.models = models
        self.modelGenerator = nil
    }
    
    public init(modelGenerator: @escaping () -> [ModelType]?, overrideEquatable: Bool = false) {
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
    
    public func selectionHandler(_ selectionHandler: @escaping (_ model: ModelType, _ index: Int) -> Void) -> Self {
        self.selectionHandler = selectionHandler
        return self
    }
    
    public func hideWhen(_ hideWhen: @escaping (_ model: ModelType) -> Bool) -> Self {
        self.hideWhen = hideWhen
        return self
    }
    
    override internal func numberOfRows() -> Int {
        if let models = generateModels() {
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
        
        if let models = generateModels() {
            for i in 0 ..< models.count {
                var model = models[i]
                
                if model.rowTag == nil {
                    model.rowTag = String(i)
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
        let diff = before.diff(self.modelSnapshot)
        
        diff.insertions.forEach { rowInsertions.append($0.idx) }
        diff.deletions.forEach { rowDeletions.append($0.idx) }
        
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
                additionalConfig(cell, model)
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
    
    private func selectModelFor(row: Int) -> ModelType? {
        if let models = generateModels() {
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
        if let hideWhen = self.hideWhen, let models = generateModels() {
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
    
    private func generateModels() -> [ModelType]? {
        return self.models != nil ? self.models : self.modelGenerator?()
    }
}
