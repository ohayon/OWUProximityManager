Pod::Spec.new do |s|
  s.name         = "OWUProximityManager"
  s.version      = "1.0.0"
  s.summary      = "A simple interface to pair a CBPeripheral and CBCentral via iBeacons."

  s.description  = <<-DESC
                   A longer description of OWUProximityManager in Markdown format.

                   * Think: Why did you write this? What is the focus? What does it do?
                   * CocoaPods will be using this to generate tags, and improve search results.
                   * Try to keep it short, snappy and to the point.
                   * Finally, don't worry about the indent, CocoaPods strips it!
                   DESC

  s.homepage     = "https://github.com/ohwutup/OWUProximityManager"
  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.author       = { "David Ohayon" => "ohayon.1@gmail.com" }
  s.platform     = :ios, '7.0'
  s.source       = { :git => "https://github.com/ohwutup/OWUProximityManager.git", :tag => "1.0.0" }
  s.source_files = 'Beaconing/Classes', 'Beaconing/OWUProximityManagerDefines.h'
  s.frameworks   = 'CoreBluetooth', 'CoreLocation'
end
