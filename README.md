# TableViewConfigurator

[![Version](https://img.shields.io/cocoapods/v/TableViewConfigurator.svg?style=flat)](http://cocoapods.org/pods/TableViewConfigurator)
[![License](https://img.shields.io/cocoapods/l/TableViewConfigurator.svg?style=flat)](http://cocoapods.org/pods/TableViewConfigurator)
[![Platform](https://img.shields.io/cocoapods/p/TableViewConfigurator.svg?style=flat)](http://cocoapods.org/pods/TableViewConfigurator)

When implementing `UITableView` UIs, it is very often the case that you end up with controller objects containing many lines of brittle and error-prone implementations of `UITableViewDataSource` and `UITableViewDelegate`.

For example:

```swift
func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    switch section {
            
    case selectedItemSection:
        return 1
            
    case fooSection:
        return self.showFoo ? 4 : 1
            
    default:
        let thingCount = self.thingCollections[section - 1].things.count
            
        return thingCount == 0 ? 1 : thingCount
            
    }
}
    
func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    switch indexPath.section {
            
    case self.selectedItemSection:
            
        ...
            
    case fooSection:
        switch indexPath.row {
                
        case 0:
              
            ...
                
        case 1:
                
            ...
                
        case 2:
              
            ...
                
        case 3:
                
            ...
                
        default:
                
            break
                
        }
            
    default:
        let things = self.thingCollections[indexPath.section - 1].things
            
        if things.count > 0 {
            ...
        } else {
            ...
        }
    }
}
    
func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    let section = indexPath.section
        
    if section != selectedItemSection || (section == selectedItemSection && self.selectedItem == nil) {
        ...
    } else {
        ...
    }
}
    
func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    switch indexPath.section {
            
    case selectedItemSection:
        break
            
    case fooSection:
        break
            
    default:
        let things = self.thingCollections[indexPath.section - 1].things
            
        if things.count > 0 {
            self.performSegueWithIdentifier("showThings", sender: self)
        }
    }
        
    tableView.deselectRowAtIndexPath(indexPath, animated: true)
}
```

`TableViewConfigurator` was created to eliminate this kind of code and replace it with a more declarative approach.

## Installation

TableViewConfigurator is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "TableViewConfigurator"
```

## Usage

`TableViewConfigurator` is based around the concepts of `RowConfiguration` and `SectionConfiguration`. At the bottom of the conceptual hierachy is the `RowConfiguration`. A `RowConfiguration` allows you to specify individual rows or groups of rows that should appear in your `UITableView`. It currently comes in two flavors: `ConstantRowConfiguration` and `ModelRowConfiguration`.

#### ConstantRowConfiguration

A `ConstantRowConfiguration` represents a single row in your `UITableView`. All it takes to create one is an implementation of the `ConfigurableTableViewCell` protocol that is specified in the constructor of `ConstantRowConfiguration` via a generic type parameter.

```swift
import UIKit
import TableViewConfigurator

class BasicCell: UITableViewCell, ConfigurableTableViewCell {

    func configure() {
        self.textLabel?.text = "Basic Cell"
    }
}
```

`let rowConfiguration = ConstantRowConfiguration<BasicCell>()`

At this point `rowConfiguration` is ready to be used and will have its `configure()` method called when appropriate. But, there are several different configurations that can be applied before use.

##### .cellResuseId()

By default, `TableViewConfigurator` will generate a reuse identifier for your cell class that is equal to the class name. If this isn't the behavior you want, you can either override `buildReuseIdentifier()` in your cell class, or specify the reuse identifier in your controller.

`let rowConfiguration = ConstantRowConfiguration<BasicCell>().cellReuseId("someReuseId")`

##### .height() / .estimatedHeight()

You can specify the height or estimated height of the cell depending on the sizing method you're using.

```swift
let rowConfiguration = ConstantRowConfiguration<BasicCell>().height(44.0)
let anotherConfiguration = ConstantRowConfiguration<BasicCell>().estimatedHeight(44.0)
```

##### .additionalConfig()

You can specify additional configuration that should happen on the cell in your controller context after its `configure()` method has been called.

```swift
let rowConfiguration = ConstantRowConfiguration<BasicCell>()
    .additionalConfig({ (cell) -> Void in
        cell.accessoryType = self.someControllerFlag ? .DisclosureIndicator : .None
    })
```

##### .selectionHandler()

You can specify code that should be called in your controller context when the row in the `ConstantRowConfiguration` is selected.

```swift
let rowConfiguration = ConstantRowConfiguration<BasicCell>()
    .selectionHandler({ self.performSegueWithIdentifier("someSegue", sender: self) })
```

##### .hideWhen()

Finally, you can specify a closure that indicates when the row in the `ConstantRowConfiguration` should be hidden.

```swift
let rowConfiguration = ConstantRowConfiguration<BasicCell>()
    .hideWhen({ () -> Bool in
        return self.shouldHideRow
    })
```

#### ModelRowConfiguration

A `ModelRowConfiguration` represents a group of rows that are defined by an array of some model type. It has all the same configuration options as `ConstantRowConfiguration` but closure callbacks you define will take an additional `model` parameter that represents the model associated with the actual row in question. Additionally, it's constructor requires two generic type parameters. The first is an implementation of `ModelConfigurableTableViewCell` and the second is any Swift type you wish (e.g., a "model" object, a tuple, a `Bool`, etc.). It's constructor can also be passed a function that returns an up-to-date model array. This is useful in dynamic UIs.

```swift
class PersonCell: UITableViewCell, ModelConfigurableTableViewCell {
    
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var ageLabel: UILabel!

    func configure(model: Person) {
        self.nameLabel.text = "\(model.firstName) \(model.lastName)"
        self.ageLabel.text = "Age \(model.age)"
    }
}
```

`let rowConfiguration = ModelRowConfiguration<PersonCell, Person>(models: self.people)`

`ModelRowConfiguration` adds a couple of additional "generator" attributes as well.

##### .heightGenerator()

You can specify a function that returns the most current height for a models row.

##### .estimatedHeightGenerator()

You can specify a function that returns the most current estimatedHeight for a models row.

#### SectionConfiguration

The real power of `TableViewConfigurator` presents itself when you begin combining `RowConfiguration` instances into a `SectionConfiguration`. Instances of `RowConfiguration` can be grouped in any order you want, and `TableViewConfigurator` will generate the correct results for the parts of `UITableViewDataSource` and `UITableViewDelegate` that it supports.

For example, suppose you wanted to create a `UITableView` section that was composed of a range of N elements sandwiched between two constant rows. Normally, this would be both annoying and error-prone. With `TableViewConfigurator`, it's trivial:

```swift
let people = [Person(firstName: "John", lastName: "Doe", age: 50),
    Person(firstName: "Alex", lastName: "Great", age: 32),
    Person(firstName: "Napoléon", lastName: "Bonaparte", age: 18)]
    
let section = SectionConfiguration(rowConfigurations:
    [ConstantRowConfiguration<BasicCell>(),
        ModelRowConfiguration<PersonCell, Person>(models: people),
        ConstantRowConfiguration<BasicCell>()])
```

There are two additional configuration options available for `SectionConfiguration`

##### .headerTitle()

You can specify the String that should be used as the sections header title.

##### .footerTitle()

You can specify the String that should be used as the sections footer title.

#### TableViewConfigurator

Once you've created your `RowConfiguration` and `SectionConfiguration` instances, the final step is to put them together in your `TableViewConfigurator` and delegate to it from your controller where appropriate. `TableViewConfigurator` implements both `UITableViewDataSource` and `UITableViewDelegate` but it's unlikely that it will implement all the pieces you might need, so it's better to only delegate to it where appropriate from your controller.

```swift
override func viewDidLoad() {
    super.viewDidLoad()
        
    let basicSection = SectionConfiguration(rowConfiguration:
        ConstantRowConfiguration<BasicCell>()
            .height(44.0))
        
    let peopleRows = ModelRowConfiguration<PersonCell, Person>(models: self.people)
        .hideWhen({ (model) -> Bool in
            return self.hidePeople
        })
        .height(44.0)
        
    let peopleSection = SectionConfiguration(rowConfigurations:
        [ConstantRowConfiguration<SwitchCell>()
            .additionalConfig({ (cell) -> Void in
                cell.hideLabel.text = "Hide People"
                cell.hideSwitch.on = self.hidePeople
                cell.switchChangedHandler = { (on) -> Void in
                    self.configurator.animateChangeSet(self.configurator.changeSetAfterPerformingOperation({ self.hidePeople = on }))
                }
            })
            .height(44.0), peopleRows, ConstantRowConfiguration<BasicCell>().height(44.0)])
        
    let disclosureSection = SectionConfiguration(rowConfiguration:
        ConstantRowConfiguration<DisclosureCell>()
            .selectionHandler({ () -> Bool in
                self.performSegueWithIdentifier("showDetails", sender: self)
                return true
            })
            .height(44.0))
        
    self.configurator = TableViewConfigurator(tableView: tableView, sectionConfigurations:
        [basicSection, peopleSection, disclosureSection])
}

func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return self.configurator.numberOfSectionsInTableView(tableView)
}

func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    return self.configurator.tableView(tableView, titleForHeaderInSection: section)
}
    
func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String? {
    return self.configurator.tableView(tableView, titleForFooterInSection: section)
}
    
func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return self.configurator.tableView(tableView, numberOfRowsInSection: section)
}
    
func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    return self.configurator.tableView(tableView, cellForRowAtIndexPath: indexPath)
}
    
func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    return self.configurator.tableView(tableView, heightForRowAtIndexPath: indexPath)
}
    
func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    self.configurator.tableView(tableView, didSelectRowAtIndexPath: indexPath)
}
```

As you can see in the above example, `TableViewConfigurator` also supports UITableView row insertion and deletion.

##### .changeSetAfterPerformingOperation() / .animateChangeSet()

In order to support row and section insertion / deletion, all you need to do is setup your cells .hideWhen() handlers appropriately and then call `changeSetAfterPerformingOperation()`. `TableViewConfigurator` will note changes in visibility before and after performing the operation you specify and will return those changes to you in the resulting tuple. All you have to do is pass those changes to `animatedChangeSet()` or your `UITableView` directly and your rows / sections will animated appropriately.

##### .indexPathsForRowConfiguration()

`TableViewConfigurator` also provides the `indexPathsForRowConfiguration()` method so you can access the actual `NSIndexPath` array for a `RowConfiguration`. This is useful for (among other things) calling `reloadRowsAtIndexPaths()` on your `UITableView` to force your cells to reload from their models or constant configuration.

##### .refreshAllRowConfigurations()

Sometimes you may want to refresh the contents of a currently visible cell without forcing a complete reload of the cell. For example, if your cell contained a `UITextField`, performing a reload (which destroys and replaces the existing cell) would cause the text field to lose focus. To address this, `TableViewConfigurator` provides the `refreshAllRowConfigurations()` method which non-destructively refreshes any visible cells from their model or constant configuration. Any offscreen cells will of course be updated when they become visible and `UITableView` queries it's delegate.

## Author

John Volk, john.t.volk@gmail.com

## License

TableViewConfigurator is available under the MIT license. See the LICENSE file for more info.
