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
    
    public init(models: [ModelType], cellReuseId: String, cellConfigurator: (cell: CellType, model: ModelType) -> Void) {
        self.modelSections = [models];
        self.rowConfigurations = [ModelRowConfiguration<CellType, ModelType>(models: models,
            cellReuseId: cellReuseId, cellConfigurator: cellConfigurator)];
    }
    
    public init(modelSections: [[ModelType]], cellReuseId: String, cellConfigurator: (cell: CellType, model: ModelType) -> Void) {
        self.modelSections = modelSections;
        
        var rowConfigurations = [ModelRowConfiguration<CellType, ModelType>]();
        
        for modelSection in modelSections {
            rowConfigurations.append(ModelRowConfiguration<CellType, ModelType>(models: modelSection,
                cellReuseId: cellReuseId, cellConfigurator: cellConfigurator))
        }
        
        self.rowConfigurations = rowConfigurations;
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
}
