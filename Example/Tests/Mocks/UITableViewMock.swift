//
//  UITableViewMock.swift
//  TableViewConfigurator
//
//  Created by John Volk on 5/11/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import UIKit

class UITableViewMock: UITableView {

    private var cells = [IndexPath: UITableViewCell]()
    
    func storeCell(_ cell: UITableViewCell, forIndexPath indexPath: IndexPath) {
        cells[indexPath] = cell
    }
    
    override func cellForRow(at: IndexPath) -> UITableViewCell? {
        return cells[at]
    }
}
