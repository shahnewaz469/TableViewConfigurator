//
//  TableViewConfigurator.swift
//  Pods
//
//  Created by John Volk on 2/29/16.
//
//

import UIKit

public class TableViewConfigurator: NSObject, UITableViewDataSource, UITableViewDelegate {

    private var sectionConfigurations: [SectionConfiguration];
    
    public override init() {
        self.sectionConfigurations = [];
    }
    
    public init(sectionConfigurations: [SectionConfiguration]) {
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
        return self.sectionConfigurations.reduce(0) { (totalSections, sectionConfiguration) -> Int in
            return totalSections + sectionConfiguration.numberOfSections();
        }
    }
    
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return performSectionOperation(section, handler: { (sectionConfiguration, localizedSection) in
            return sectionConfiguration.numberOfRowsInSection(localizedSection);
        });
    }
    
    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return performSectionOperation(indexPath.section, handler: { (sectionConfiguration, localizedSection) in
            if let cell = sectionConfiguration.cellForRow(indexPath.row, inTableView: tableView) {
                return cell;
            }
            
            fatalError("Couldn't dequeue cell at indexPath \(indexPath).");
        });
    }
    
    public func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return performSectionOperation(indexPath.section, handler: { (sectionConfiguration, localizedSection) -> CGFloat in
            if let height = sectionConfiguration.heightForRow(indexPath.row) {
                return height;
            }
            
            fatalError("Couldn't calculate height at indexPath \(indexPath).");
        });
    }
    
    public func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return performSectionOperation(indexPath.section, handler: { (sectionConfiguration, localizedSection) -> CGFloat in
            if let estimatedHeight = sectionConfiguration.estimatedHeightForRow(indexPath.row) {
                return estimatedHeight;
            }
            
            fatalError("Couldn't calculate estimatedHeight at indexPath \(indexPath).");
        });
    }
    
    public func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        return performSectionOperation(indexPath.section, handler: { (sectionConfiguration, localizedSection) in
            if sectionConfiguration.didSelectRow(indexPath.row) ?? true {
                tableView.deselectRowAtIndexPath(indexPath, animated: true);
            }
        })
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
