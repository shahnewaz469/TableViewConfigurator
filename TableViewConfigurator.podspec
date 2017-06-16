#
# Be sure to run `pod lib lint TableViewConfigurator.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "TableViewConfigurator"
  s.version          = "1.5.0"
  s.summary          = "A declarative approach to UITableView configuration resulting in thinner and more robust controllers."
  s.description      = <<-DESC
                        * More declarative and easier to read approach to UITableView-based UI construction.
                        * Declarative approach allows the construction of smaller and more robust controllers.
                        * Extensive unit testing increases confidence in correctness of UI.
                       DESC
  s.homepage         = "https://github.com/johntvolk/TableViewConfigurator"
  s.license          = 'MIT'
  s.author           = { "John Volk" => "john.t.volk@gmail.com" }
  s.source           = { :git => "https://github.com/johntvolk/TableViewConfigurator.git", :tag => s.version.to_s }
  s.platform     = :ios, '8.0'
  s.requires_arc = true
  s.source_files = 'TableViewConfigurator/Classes/**/*'
  s.dependency 'Dwifft', '~> 0.6'
end
