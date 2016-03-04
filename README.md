# TableViewConfigurator

[![CI Status](http://img.shields.io/travis/John Volk/TableViewConfigurator.svg?style=flat)](https://travis-ci.org/John Volk/TableViewConfigurator)
[![Version](https://img.shields.io/cocoapods/v/TableViewConfigurator.svg?style=flat)](http://cocoapods.org/pods/TableViewConfigurator)
[![License](https://img.shields.io/cocoapods/l/TableViewConfigurator.svg?style=flat)](http://cocoapods.org/pods/TableViewConfigurator)
[![Platform](https://img.shields.io/cocoapods/p/TableViewConfigurator.svg?style=flat)](http://cocoapods.org/pods/TableViewConfigurator)

When implementing UITableView-based UIs, it is very often the case that you end up with controller objects containing many lines of brittle and error-prone implementations of `UITableViewDataSource` and `UITableViewDelegate`.

For example:

```swift
func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    switch section {
            
    case selectedItemSection:
        return 1;
            
    case fooSection:
        return self.showFoo ? 4 : 1;
            
    default:
        let thingCount = self.thingCollections[section - 1].things.count;
            
        return thingCount == 0 ? 1 : thingCount;
            
    }
}
    
func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    switch indexPath.section {
            
    case self.selectedItemSection:
            
        ...
            
    case scheduleSection:
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
                
            break;
                
        }
            
    default:
        let things = self.thingCollections[indexPath.section - 1].things;
            
        if things.count > 0 {
            ...
        } else {
            ...
        }
    }
}
    
func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    let section = indexPath.section;
        
    if section != selectedItemSection || (section == selectedItemSection && self.selectedItem == nil) {
        ...
    } else {
        ...
    }
}
    
func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    switch indexPath.section {
            
    case selectedItemSection:
        break;
            
    case scheduleSection:
        break;
            
    default:
        let things = self.thingCollections[indexPath.section - 1].things;
            
        if things.count > 0 {
            self.performSegueWithIdentifier("showThings", sender: self);
        }
    }
        
    tableView.deselectRowAtIndexPath(indexPath, animated: true);
}
```

`TableViewConfigurator` was created to eliminate this kind of code and replace it with a more declartive approach.

## Installation

TableViewConfigurator is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "TableViewConfigurator"
```

## Usage

`TableViewConfigurator` is based around the concepts of `RowConfiguration` and `SectionConfiguration`.

At the bottom of the conceptual hierachy is the `RowConfiguration`. A `RowConfiguration` allows you to specify individual rows or groups of rows that should appear in your `UITableView`. The two flavors it currently comes in are `ConstantRowConfiguration` and `ModelRowConfiguration`.

#### ConstantRowConfiguration

A `ConstantRowConfiguration` represents a single row in your `UITableView`. All it takes to create one is an implementation of the `ConfigurableTableViewCell` protocol that is specified in the constructor of `ConstantRowConfiguration` via a generic type parameter.

```swift
import UIKit
import TableViewConfigurator

class BasicCell: UITableViewCell, ConfigurableTableViewCell {

    override class func buildReuseIdentifier() -> String? {
        return "basicCell";
    }
    
    func configure() {
        self.textLabel?.text = "Basic Cell"
    }
}
```

`let rowConfiguration = ConstantRowConfiguration<BasicCell>();`

At this point `rowConfiguration` is ready to be used and will have its `configure()` method called when appropriate. But, there are several different configurations that can be applied before use.

##### .cellResuseId()

You can specify the reuse identifier that should be used for the cell in your controller rather than in your `ConfigurableTableViewCell` implementation.

`let rowConfiguration = ConstantRowConfiguration<BasicCell>().cellReuseId("someReuseId");`

##### .height() / .estimatedHeight()

You can specify the height or estimated height of the cell depending on the sizing method you're using.

```swift
let rowConfiguration = ConstantRowConfiguration<BasicCell>().height(44.0);
let anotherConfiguration = ConstantRowConfiguration<BasicCell>().estimatedHeight(44.0);
```

##### .additionalConfig()

You can specify additional configuration that should happen on the cell in your controller context after its `configure()` method has been called.

```swift
let rowConfiguration = ConstantRowConfiguration<BasicCell>()
    .additionalConfig({ (cell) -> Void in
        cell.accessoryType = self.someControllerFlag ? .DisclosureIndicator : .None;
    });
```

##### .selectionHandler()

You can specify code that should be called in your controller context when the row in the `ConstantRowConfiguration` is selected.

```swift
let rowConfiguration = ConstantRowConfiguration<BasicCell>()
    .selectionHandler({ () -> Bool in
        self.performSegueWithIdentifier("someSegue", sender: self);
        return true;
    });
```

The return value of the selection handler determines whether or not the row is deselected.

##### .hideWhen()

Finally, you can specify a closure that indicates when the row in the `ConstantRowConfiguration` should be hidden.

```swift
let rowConfiguration = ConstantRowConfiguration<BasicCell>()
    .hideWhen({ () -> Bool in
        return self.shouldHideRow;
    });
```

#### ModelRowConfiguration

A `ModelRowConfiguration` represents a group of rows that are defined by an array of some model object. It has all the same configuration options as `ConstantRowConfiguration` but closure callbacks you define will take an additional `model` parameter that represents the model associated with the actual row in question. Additionally, it's constructor requires two generic type parameters. The first is an implementation of `ModelConfigurableTableViewCell` and the second is a plain old Swift model object.

```swift
class PersonCell: UITableViewCell, ModelConfigurableTableViewCell {
    
    @IBOutlet var nameLabel: UILabel!;
    @IBOutlet var ageLabel: UILabel!;
    
    override class func buildReuseIdentifier() -> String? {
        return "personCell";
    }
    
    func configure(model: Person) {
        self.nameLabel.text = "\(model.firstName) \(model.lastName)";
        self.ageLabel.text = "Age \(model.age)";
    }
}
```

`let rowConfiguration = ModelRowConfiguration<PersonCell, Person>(models: self.people);`

#### SectionConfiguration

The real power of `TableViewConfigurator` presents itself when you begin combining `RowConfiguration` instances into a `SectionConfiguration`. Instances of `RowConfiguration` can be grouped in any order you want, and `TableViewConfigurator` will generate the correct results for the parts of `UITableViewDataSource` and `UITableViewDelegate` that it supports.

For example, suppose you wanted to create a `UITableView` section that was composed of a range of N elements sandwiched between two constant rows. Normally, this would be both annoying and error-prone. With `TableViewConfigurator`, it's trivial:

```swift
let people = [Person(firstName: "John", lastName: "Doe", age: 50),
    Person(firstName: "Alex", lastName: "Great", age: 32),
    Person(firstName: "Napoléon", lastName: "Bonaparte", age: 18)];
    
let section = SectionConfiguration(rowConfigurations:
    [ConstantRowConfiguration<BasicCell>(),
        ModelRowConfiguration<PersonCell, Person>(models: people),
        ConstantRowConfiguration<BasicCell>()]);
```

#### TableViewConfigurator

Once you've created your `RowConfiguration` and `SectionConfiguration` instances, the final step is to put them together in your `TableViewConfigurator` and delegate to it from your controller where appropriate. `TableViewConfigurator` implements both `UITableViewDataSource` and `UITableViewDelegate` but it's unlikely that it will implement all the pieces you might need, so it's better to only delegate to it where appropriate from your controller.

```swift
override func viewDidLoad() {
    super.viewDidLoad();
        
    let basicSection = SectionConfiguration(rowConfiguration:
        ConstantRowConfiguration<BasicCell>()
            .height(44.0));
        
    let peopleRows = ModelRowConfiguration<PersonCell, Person>(models: self.people)
        .hideWhen({ (model) -> Bool in
            return self.hidePeople;
        })
        .height(44.0);
        
    let peopleSection = SectionConfiguration(rowConfigurations:
        [ConstantRowConfiguration<SwitchCell>()
            .additionalConfig({ (cell) -> Void in
                let hideIndexPaths = self.configurator.indexPathsForRowConfiguration(peopleRows);
                    
                cell.hideLabel.text = "Hide People";
                cell.hideSwitch.on = self.hidePeople;
                cell.switchChangedHandler = { (on) -> Void in
                    self.hidePeople = on;
                        
                    if let indexPaths = hideIndexPaths {
                        if on {
                            self.tableView.deleteRowsAtIndexPaths(indexPaths, withRowAnimation: .Top);
                        } else {
                            self.tableView.insertRowsAtIndexPaths(indexPaths, withRowAnimation: .Top);
                        }
                    }
                }
            })
            .height(44.0), peopleRows, ConstantRowConfiguration<BasicCell>().height(44.0)]);
        
    let disclosureSection = SectionConfiguration(rowConfiguration:
        ConstantRowConfiguration<DisclosureCell>()
            .selectionHandler({ () -> Bool in
                self.performSegueWithIdentifier("showDetails", sender: self);
                return true;
            })
            .height(44.0));
        
    self.configurator = TableViewConfigurator(tableView: tableView, sectionConfigurations:
        [basicSection, peopleSection, disclosureSection]);
}

func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return self.configurator.numberOfSectionsInTableView(tableView);
}
    
func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return self.configurator.tableView(tableView, numberOfRowsInSection: section);
}
    
func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    return self.configurator.tableView(tableView, cellForRowAtIndexPath: indexPath);
}
    
func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    return self.configurator.tableView(tableView, heightForRowAtIndexPath: indexPath);
}
    
func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    self.configurator.tableView(tableView, didSelectRowAtIndexPath: indexPath);
}
```

## Author

John Volk, john.t.volk@gmail.com

## License

TableViewConfigurator is available under the MIT license. See the LICENSE file for more info.
