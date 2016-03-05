//
//  TableViewConfigurator.swift
//  Pods
//
//  Created by John Volk on 2/29/16.
//  Copyright © 2016 John Volk. All rights reserved.
//

import UIKit

public class TableViewConfigurator: NSObject, UITableViewDataSource, UITableViewDelegate {

    private var sectionConfigurations: [SectionConfiguration];
    private var tableView: UITableView;
    
    public init(tableView: UITableView) {
        self.tableView = tableView;
        self.sectionConfigurations = [];
    }
    
    public init(tableView: UITableView, sectionConfigurations: [SectionConfiguration]) {
        self.tableView = tableView;
        self.sectionConfigurations = sectionConfigurations;
    }
    
    public func addConfiguration(sectionConfiguration: SectionConfiguration) {
        self.sectionConfigurations.append(sectionConfiguration);
    }
    
    public func insertConfiguration(sectionConfiguration: SectionConfiguration, atIndex index: Int) {
        self.sectionConfigurations.insert(sectionConfiguration, atIndex: index);
    }
    
    public func removeAllConfigurations() {
        self.sectionConfigurations.removeAll(keepCapacity: true);
    }
    
    public func indexPathsForRowConfiguration(rowConfiguration: RowConfiguration) -> [NSIndexPath]? {
        for i in 0 ..< self.sectionConfigurations.count {
            if let rowIndices = self.sectionConfigurations[i].rowIndexSetForRowConfiguration(rowConfiguration) {
                var result = [NSIndexPath]();
                
                for index in rowIndices {
                    result.append(NSIndexPath(forRow: index, inSection: i));
                }
                
                return result;
            }
        }
        
        return nil;
    }
    
    public func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if tableView === self.tableView {
            return self.sectionConfigurations.reduce(0) { (totalSections, sectionConfiguration) -> Int in
                return totalSections + sectionConfiguration.numberOfSections();
            }
        }
        
        fatalError("Provided tableView doesn't match configured table view.");
    }
    
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView === self.tableView {
            return performSectionOperation(section, handler: { (sectionConfiguration, localizedSection) in
                if let numberOfRows = sectionConfiguration.numberOfRowsInSection(localizedSection) {
                    return numberOfRows;
                }
                
                fatalError("Could find numberOfRows for section \(section).");
            });
        }
        
        fatalError("Provided tableView doesn't match configured table view.");
    }
    
    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if tableView === self.tableView {
            return performSectionOperation(indexPath.section, handler: { (sectionConfiguration, localizedSection) in
                if let cell = sectionConfiguration.cellForRow(indexPath.row, inTableView: tableView) {
                    return cell;
                }
                
                fatalError("Couldn't dequeue cell at indexPath \(indexPath).");
            });
        }
        
        fatalError("Provided tableView doesn't match configured table view.");
    }
    
    public func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if tableView === self.tableView {
            return performSectionOperation(indexPath.section, handler: { (sectionConfiguration, localizedSection) -> CGFloat in
                if let height = sectionConfiguration.heightForRow(indexPath.row) {
                    return height;
                }
                
                fatalError("Couldn't calculate height at indexPath \(indexPath).");
            });
        }
        
        fatalError("Provided tableView doesn't match configured table view.");
    }
    
    public func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if tableView === self.tableView {
            return performSectionOperation(indexPath.section, handler: { (sectionConfiguration, localizedSection) -> CGFloat in
                if let estimatedHeight = sectionConfiguration.estimatedHeightForRow(indexPath.row) {
                    return estimatedHeight;
                }
                
                fatalError("Couldn't calculate estimatedHeight at indexPath \(indexPath).");
            });
        }
        
        fatalError("Provided tableView doesn't match configured table view.");
    }
    
    public func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if tableView === self.tableView {
            performSectionOperation(indexPath.section, handler: { (sectionConfiguration, localizedSection) in
                if sectionConfiguration.didSelectRow(indexPath.row) ?? true {
                    tableView.deselectRowAtIndexPath(indexPath, animated: true);
                }
            });
        } else {
            fatalError("Provided tableView doesn't match configured table view.");
        }
    }
    
    private func performSectionOperation<T>(section: Int, handler: (sectionConfiguration: SectionConfiguration, localizedSection: Int) -> T) -> T {
        var sectionTotal = 0;
        
        for sectionConfiguration in self.sectionConfigurations {
            let numberOfSections = sectionConfiguration.numberOfSections();
            
            if section < sectionTotal + numberOfSections {
                return handler(sectionConfiguration: sectionConfiguration, localizedSection: section - sectionTotal);
            }
            
            sectionTotal += numberOfSections;
        }
        
        fatalError("Couldn't resolve SectionConfiguration for section \(section).");
    }
}
