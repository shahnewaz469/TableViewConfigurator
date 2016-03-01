//
//  TableViewConfigurator.swift
//  Pods
//
//  Created by John Volk on 2/29/16.
//
//

import UIKit

public class TableViewConfigurator: NSObject, UITableViewDataSource, UITableViewDelegate {

    private let sectionConfigurations: [SectionConfiguration];
    
    public init(sectionConfigurations: [SectionConfiguration]) {
        self.sectionConfigurations = sectionConfigurations;
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
            return sectionConfiguration.cellForRowAtIndexPath(NSIndexPath(forRow: indexPath.row, inSection: localizedSection), inTableView: tableView);
        });
    }
    
    public func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        return performSectionOperation(indexPath.section, handler: { (sectionConfiguration, localizedSection) in
            if sectionConfiguration.didSelectRowAtIndexPath(NSIndexPath(forRow: indexPath.row, inSection: localizedSection)) {
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