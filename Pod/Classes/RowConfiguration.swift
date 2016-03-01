//
//  RowConfiguration.swift
//  Pods
//
//  Created by John Volk on 2/29/16.
//
//

import Foundation

public protocol RowConfiguration {
    
    func numberOfRows() -> Int;
    func cellForRow(row: Int, inTableView tableView: UITableView) -> UITableViewCell;
    
}