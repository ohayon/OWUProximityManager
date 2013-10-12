# OWUProximityManager

A simple interface to abstract away the `CLLocationManagerDelegate`, `CBPeripheralManagerDelegate`, `CBCentralManagerDelegate` and `CBPeripheralDelegate` spaghetti.

## Sample Project

A few small caveats:
- Two iOS 7 devices are required
- `locationManager:DidEnterRegion:` and therefor `proximityManager:DidEnterBeaconRegion` will not be called if the Client starts while already in range of the Server
- `locationManager:DidExitRegion:` and the resulting `proximityManager:DidExitBeaconRegtion` will not be called until about a minute after exiting the region ([dev forum link](https://devforums.apple.com/message/898335#898335))

## Usage

First, create three UUID's using something like `uuidgen` for `OWUProximityManagerConstants.h`

OWUProximityManager can be configured as a Client or Server. To get things started as either, just call `[[OWUProximityManager shared] startupClientWithDelegate:delegate]` or `[[OWUProximityManager shared] startupServerWithDelegate:delegate]` and implement either or both of `OWUProximityClientDelegate` and `OWUProximityServerDelegate` to be notified of proximity events.

You can use the `desiredProximity` property on the class with a `CLProximity` value. It is currently set to default to `CLProximityNear`.

## ToDo's
- More fine tuning of BeaconRegion measured power
- Handle invalidated services in `OWUProximityServer`
- Properly handle return from local notification

## Thoughts For Future
- Maybe a bluetooth REST API?

## License
OWUProximityManager is available under the MIT license. See the LICENSE.txt file for more info.