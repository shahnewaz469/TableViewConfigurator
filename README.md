# TableViewConfigurator

[![CI Status](http://img.shields.io/travis/John Volk/TableViewConfigurator.svg?style=flat)](https://travis-ci.org/John Volk/TableViewConfigurator)
[![Version](https://img.shields.io/cocoapods/v/TableViewConfigurator.svg?style=flat)](http://cocoapods.org/pods/TableViewConfigurator)
[![License](https://img.shields.io/cocoapods/l/TableViewConfigurator.svg?style=flat)](http://cocoapods.org/pods/TableViewConfigurator)
[![Platform](https://img.shields.io/cocoapods/p/TableViewConfigurator.svg?style=flat)](http://cocoapods.org/pods/TableViewConfigurator)

A declarative approach to UITableView configuration that enables you to create thinner controllers with less of the error-prone delegate code that typically results from implementing UITableView-based interfaces.

## Installation

TableViewConfigurator is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "TableViewConfigurator"
```

## Usage

DISCUSS MAIN BENEFITS AND SHOW EXAMPLE

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

A `ModelRowConfiguration` represents a group of rows that are defined by an array of some model object.

#### SectionConfiguration

The real power of `TableViewConfigurator` presents itself when you begin combining `RowConfiguration` instances into a `SectionConfiguration`. Instances of `RowConfiguration` can be grouped in any order you want, and `TableViewConfigurator` will make sure the correct results are generated for the parts of `UITableViewDataSource` and `UITableViewDelegate` that it supports.

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

#### Putting it all together with TableViewConfigurator

Blah blah blah...

## Author

John Volk, john.t.volk@gmail.com

## License

TableViewConfigurator is available under the MIT license. See the LICENSE file for more info.
