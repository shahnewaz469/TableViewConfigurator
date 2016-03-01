//
//  SectionConfiguration.swift
//  Pods
//
//  Created by John Volk on 3/1/16.
//
//

import Foundation

public protocol SectionConfiguration {
    
    func numberOfSections() -> Int;
    func numberOfRowsInSection(section: Int) -> Int;
    func cellForRowAtIndexPath(indexPath: NSIndexPath, inTableView tableView: UITableView) -> UITableViewCell;
    func didSelectRowAtIndexPath(indexPath: NSIndexPath) -> Bool;
    
}