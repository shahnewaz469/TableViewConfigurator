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
            return self.sectionConfigurations.count;
        }
        
        fatalError("Provided tableView doesn't match configured table view.");
    }
    
    public func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if tableView === self.tableView {
            return performSectionOperation(section, handler: { (sectionConfiguration) -> String? in
                return sectionConfiguration.titleForHeader();
            })
        }
        
        fatalError("Provided tableView doesn't match configured table view.");
    }
    
    public func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if tableView === self.tableView {
            return performSectionOperation(section, handler: { (sectionConfiguration) -> String? in
                return sectionConfiguration.titleForFooter();
            })
        }
        
        fatalError("Provided tableView doesn't match configured table view.");
    }
    
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView === self.tableView {
            return performSectionOperation(section, handler: { (sectionConfiguration) in
                if let numberOfRows = sectionConfiguration.numberOfRows() {
                    return numberOfRows;
                }
                
                fatalError("Could find numberOfRows for section \(section).");
            });
        }
        
        fatalError("Provided tableView doesn't match configured table view.");
    }
    
    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if tableView === self.tableView {
            return performSectionOperation(indexPath.section, handler: { (sectionConfiguration) in
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
            return performSectionOperation(indexPath.section, handler: { (sectionConfiguration) -> CGFloat in
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
            return performSectionOperation(indexPath.section, handler: { (sectionConfiguration) -> CGFloat in
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
            performSectionOperation(indexPath.section, handler: { (sectionConfiguration) in
                if sectionConfiguration.didSelectRow(indexPath.row) ?? true {
                    tableView.deselectRowAtIndexPath(indexPath, animated: true);
                }
            });
        } else {
            fatalError("Provided tableView doesn't match configured table view.");
        }
    }
    
    private func performSectionOperation<T>(section: Int, handler: (sectionConfiguration: SectionConfiguration) -> T) -> T {
        if section < self.sectionConfigurations.count {
            return handler(sectionConfiguration: self.sectionConfigurations[section]);
        }
        
        fatalError("Couldn't resolve SectionConfiguration for section \(section).");
    }
}
