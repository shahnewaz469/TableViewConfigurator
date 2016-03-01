//
//  ModelSectionConfiguration.swift
//  Pods
//
//  Created by John Volk on 3/1/16.
//
//

import UIKit

public class ModelSectionConfiguration<CellType: UITableViewCell, ModelType>: SectionConfiguration {
    
    private let modelSections: [[ModelType]];
    private let rowConfigurations: [ModelRowConfiguration<CellType, ModelType>];
    
    public init(modelSections: [[ModelType]], cellReuseId: String, cellConfigurator: ((cell: CellType, model: ModelType) -> Void)?,
        selectionHandler: ((model: ModelType) -> Bool)?) {
            self.modelSections = modelSections;
            self.rowConfigurations = modelSections.map({ (modelSection) -> ModelRowConfiguration<CellType, ModelType> in
                return ModelRowConfiguration<CellType, ModelType>(models: modelSection,
                    cellReuseId: cellReuseId, cellConfigurator: cellConfigurator, selectionHandler: selectionHandler);
            })
    }

    public func numberOfSections() -> Int {
        return self.modelSections.count;
    }
    
    public func numberOfRowsInSection(section: Int) -> Int {
        return self.modelSections[section].count;
    }
    
    public func cellForRowAtIndexPath(indexPath: NSIndexPath, inTableView tableView: UITableView) -> UITableViewCell {
        return self.rowConfigurations[indexPath.section].cellForRow(indexPath.row, inTableView: tableView);
    }
    
    public func didSelectRowAtIndexPath(indexPath: NSIndexPath) -> Bool {
        return self.rowConfigurations[indexPath.section].didSelectRow(indexPath.row);
    }
}