Pod::Spec.new do |s|
  s.name         = "OWUProximityManager"
  s.version      = "1.0.0"
  s.summary      = "A simple interface to pair a CBPeripheral and CBCentral via iBeacons."
  s.homepage     = "https://github.com/ohwutup/OWUProximityManager"
  s.license      = { :type => 'MIT', :file => 'LICENSE.txt' }
  s.author       = { "David Ohayon" => "ohayon.1@gmail.com" }
  s.platform     = :ios, '7.0'
  s.source       = { :git => "https://github.com/ohwutup/OWUProximityManager.git", :tag => "1.0.0" }
  s.source_files = 'Beaconing/Classes', 'Beaconing/OWUProximityManagerDefines.h'
  s.frameworks   = 'CoreBluetooth', 'CoreLocation'
end
