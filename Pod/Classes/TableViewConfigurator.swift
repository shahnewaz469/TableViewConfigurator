//
//  TableViewConfigurator.swift
//  Pods
//
//  Created by John Volk on 2/29/16.
//
//

import UIKit

public class TableViewConfigurator: NSObject, UITableViewDataSource {

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
        return calculateSectionValue(section, handler: { (sectionConfiguration, localizedSection) in
            return sectionConfiguration.numberOfRowsInSection(localizedSection);
        });
    }
    
    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return calculateSectionValue(indexPath.section, handler: { (sectionConfiguration, localizedSection) in
            return sectionConfiguration.cellForRowAtIndexPath(NSIndexPath(forRow: indexPath.row, inSection: localizedSection), inTableView: tableView);
        });
    }
    
    private func calculateSectionValue<T>(section: Int, handler: (sectionConfiguration: SectionConfiguration, localizedSection: Int) -> T) -> T {
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
