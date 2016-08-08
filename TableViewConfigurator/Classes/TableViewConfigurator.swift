//
//  TableViewConfigurator.swift
//  Pods
//
//  Created by John Volk on 2/29/16.
//  Copyright © 2016 John Volk. All rights reserved.
//

import UIKit

public class TableViewConfigurator: NSObject, UITableViewDataSource, UITableViewDelegate {

    private var sectionConfigurations: [SectionConfiguration]
    private var tableView: UITableView
    
    public init(tableView: UITableView) {
        self.tableView = tableView
        self.sectionConfigurations = []
    }
    
    public init(tableView: UITableView, sectionConfigurations: [SectionConfiguration]) {
        self.tableView = tableView
        self.sectionConfigurations = sectionConfigurations
    }
    
    public func addConfiguration(sectionConfiguration: SectionConfiguration) {
        self.sectionConfigurations.append(sectionConfiguration)
    }
    
    public func insertConfiguration(sectionConfiguration: SectionConfiguration, atIndex index: Int) {
        self.sectionConfigurations.insert(sectionConfiguration, atIndex: index)
    }
    
    public func removeAllConfigurations() {
        self.sectionConfigurations.removeAll(keepCapacity: true)
    }
    
    public func indexPathsForRowConfiguration(rowConfiguration: RowConfiguration) -> [NSIndexPath] {
        var result = [NSIndexPath]()
        
        for (i, sectionConfiguration) in self.sectionConfigurations.enumerate() {
            let indices = sectionConfiguration.indexSetForRowConfiguration(rowConfiguration)
                
            for index in indices {
                result.append(NSIndexPath(forRow: index, inSection: i))
            }
        }
        
        return result
    }
    
    public func indexPathChangeSetAfterPerformingOperation(operation: () -> Void) ->
        (rowInsertions: [NSIndexPath], rowDeletions: [NSIndexPath], sectionInsertions: NSIndexSet, sectionDeletions: NSIndexSet) {
            let preVisibilityMap = self.sectionConfigurations.map { (sectionConfiguration) -> [[Int: Bool]] in
                return sectionConfiguration.visibilityMap()
            }
            
            operation()
            
            var rowInsertions = [NSIndexPath]()
            var rowDeletions = [NSIndexPath]()
            var sectionInsertions = NSMutableIndexSet()
            var sectionDeletions = NSMutableIndexSet()
            
            for (i, sectionConfiguration) in self.sectionConfigurations.enumerate() {
                var deletionIndexOffset = 0
                var insertionIndexOffet = 0
                let preSectionVisibility = preVisibilityMap[i]
                let postSectionVisibility = sectionConfiguration.visibilityMap()
                let preVisible = preSectionVisibility.reduce(false, combine: { (visible, visibilityMap) -> Bool in
                    return visible || visibilityMap.values.reduce(false, combine: { return $0 || $1 })
                })
                let postVisible = postSectionVisibility.reduce(false, combine: { (visible, visibilityMap) -> Bool in
                    return visible || visibilityMap.values.reduce(false, combine: { return $0 || $1 })
                })
                
                if preVisible && postVisible {
                    for (j, preRowConfigVisibility) in preSectionVisibility.enumerate() {
                        let postRowConfigVisibility = postSectionVisibility[j]
                        let indexCount = max(preRowConfigVisibility.count, postRowConfigVisibility.count)
                        
                        for index in 0 ..< indexCount {
                            switch (preRowConfigVisibility[index], postRowConfigVisibility[index]) {
                                
                            case let (.Some(pre), .Some(post)) where pre == true && post == true:
                                insertionIndexOffet += 1
                                deletionIndexOffset += 1
                                
                            case let (.Some(pre), _) where pre == true:
                                rowDeletions.append(NSIndexPath(forRow: deletionIndexOffset, inSection: i))
                                deletionIndexOffset += 1
                                
                            case let (_, .Some(post)) where post == true:
                                rowInsertions.append(NSIndexPath(forRow: insertionIndexOffet, inSection: i))
                                insertionIndexOffet += 1
                                
                            default: ()
                                
                            }
                        }
                    }
                } else if preVisible {
                    sectionDeletions.addIndex(i)
                } else if postVisible {
                    sectionInsertions.addIndex(i)
                }
            }
            
            return (rowInsertions: rowInsertions, rowDeletions: rowDeletions, sectionInsertions: sectionInsertions, sectionDeletions: sectionDeletions)
    }
    
    public func refreshAllRowConfigurations() {
        for (i, sectionConfiguration) in self.sectionConfigurations.enumerate() {
            sectionConfiguration.refreshAllRowConfigurationsWithSection(i, inTableView: self.tableView)
        }
    }
    
    public func refreshRowConfiguration(rowConfiguration: RowConfiguration) {
        for (i, sectionConfiguration) in self.sectionConfigurations.enumerate() {
            sectionConfiguration.refreshRowConfiguration(rowConfiguration, withSection: i, inTableView: self.tableView)
        }
    }
    
    public func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if tableView === self.tableView {
            let result = self.sectionConfigurations.reduce(0, combine: { (total, sectionConfiguration) -> Int in
                return sectionConfiguration.numberOfRows() > 0 ? total + 1 : total
            })
            return result
        }
        
        fatalError("Provided tableView doesn't match configured table view.")
    }
    
    public func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if tableView === self.tableView {
            return performSectionOperation(section, handler: { (sectionConfiguration) -> String? in
                return sectionConfiguration.titleForHeader()
            })
        }
        
        fatalError("Provided tableView doesn't match configured table view.")
    }
    
    public func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if tableView === self.tableView {
            return performSectionOperation(section, handler: { (sectionConfiguration) -> String? in
                return sectionConfiguration.titleForFooter()
            })
        }
        
        fatalError("Provided tableView doesn't match configured table view.")
    }
    
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView === self.tableView {
            return performSectionOperation(section, handler: { (sectionConfiguration) in
                if let numberOfRows = sectionConfiguration.numberOfRows() {
                    return numberOfRows
                }
                
                fatalError("Could find numberOfRows for section \(section).")
            })
        }
        
        fatalError("Provided tableView doesn't match configured table view.")
    }
    
    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if tableView === self.tableView {
            return performSectionOperation(indexPath.section, handler: { (sectionConfiguration) in
                if let cell = sectionConfiguration.cellForRow(indexPath.row, inTableView: tableView) {
                    return cell
                }
                
                fatalError("Couldn't dequeue cell at indexPath \(indexPath).")
            })
        }
        
        fatalError("Provided tableView doesn't match configured table view.")
    }
    
    public func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if tableView === self.tableView {
            return performSectionOperation(indexPath.section, handler: { (sectionConfiguration) -> CGFloat in
                if let height = sectionConfiguration.heightForRow(indexPath.row) {
                    return height
                }
                
                fatalError("Couldn't calculate height at indexPath \(indexPath).")
            })
        }
        
        fatalError("Provided tableView doesn't match configured table view.")
    }
    
    public func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if tableView === self.tableView {
            return performSectionOperation(indexPath.section, handler: { (sectionConfiguration) -> CGFloat in
                if let estimatedHeight = sectionConfiguration.estimatedHeightForRow(indexPath.row) {
                    return estimatedHeight
                }
                
                fatalError("Couldn't calculate estimatedHeight at indexPath \(indexPath).")
            })
        }
        
        fatalError("Provided tableView doesn't match configured table view.")
    }
    
    public func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if tableView === self.tableView {
            performSectionOperation(indexPath.section, handler: { (sectionConfiguration) in
                if sectionConfiguration.didSelectRow(indexPath.row) ?? true {
                    tableView.deselectRowAtIndexPath(indexPath, animated: true)
                }
            })
        } else {
            fatalError("Provided tableView doesn't match configured table view.")
        }
    }
    
    private func performSectionOperation<T>(section: Int, handler: (sectionConfiguration: SectionConfiguration) -> T) -> T {
        if section < self.sectionConfigurations.count {
            return handler(sectionConfiguration: self.sectionConfigurations[section])
        }
        
        fatalError("Couldn't resolve SectionConfiguration for section \(section).")
    }
}
