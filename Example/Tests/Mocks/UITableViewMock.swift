//
//  UITableViewMock.swift
//  TableViewConfigurator
//
//  Created by John Volk on 5/11/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import UIKit

class UITableViewMock: UITableView {

    private var cells = [NSIndexPath: UITableViewCell]()
    
    func storeCell(cell: UITableViewCell, forIndexPath indexPath: NSIndexPath) {
        cells[indexPath] = cell
    }
    
    override func cellForRowAtIndexPath(indexPath: NSIndexPath) -> UITableViewCell? {
        return cells[indexPath]
    }
}
