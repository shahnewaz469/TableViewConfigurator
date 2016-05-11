//
//  ConfigurableViewController.swift
//  Pods
//
//  Created by John Volk on 5/10/16.
//
//

private var configuratorAssociationKey: UInt8 = 0

extension UIViewController: UITableViewDataSource, UITableViewDelegate {
    
    public var configurator: TableViewConfigurator? {
        get {
            return objc_getAssociatedObject(self, &configuratorAssociationKey) as? TableViewConfigurator
        }
        
        set(newValue) {
            objc_setAssociatedObject(self, &configuratorAssociationKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        }
    }
    
    public func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if let configurator = self.configurator {
            return configurator.numberOfSectionsInTableView(tableView)
        }
        
        fatalError("The configurator property was not set.")
    }
    
    public func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if let configurator = self.configurator {
            return configurator.tableView(tableView, titleForHeaderInSection: section)
        }
        
        fatalError("The configurator property was not set.")
    }
    
    public func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if let configurator = self.configurator {
            return configurator.tableView(tableView, titleForFooterInSection: section)
        }
        
        fatalError("The configurator property was not set.")
    }
    
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let configurator = self.configurator {
            return configurator.tableView(tableView, numberOfRowsInSection: section)
        }
        
        fatalError("The configurator property was not set.")
    }
    
    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if let configurator = self.configurator {
            return configurator.tableView(tableView, cellForRowAtIndexPath: indexPath)
        }
        
        fatalError("The configurator property was not set.")
    }
    
    public func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if let configurator = self.configurator {
            return configurator.tableView(tableView, heightForRowAtIndexPath: indexPath)
        }
        
        fatalError("The configurator property was not set.")
    }
    
    public func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let configurator = self.configurator {
            return configurator.tableView(tableView, didSelectRowAtIndexPath: indexPath)
        }
        
        fatalError("The configurator property was not set.")
    }
}