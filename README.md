# OWUProximityManager

A simple interface to abstract away the `CLLocationManagerDelegate`, `CBPeripheralManagerDelegate`, `CBCentralManagerDelegate` and `CBPeripheralDelegate` spaghetti.

## Project Setup

First, create three UUID's using something like `uuidgen` for `OWUProximityManagerDefines.h`.

OWUProximityManager can be configured as a `Client` or `Server`. To get things started as either, just call `[[OWUProximityManager shared] startupClientWithDelegate:delegate]` or [[OWUProximityManager shared] startupServerWithDelegate:delegate]` and implement either or both of `OWUProximityClientDelegate` and `OWUProximityServerDelegate` to be notified of proximity events.

You can use the `desiredProximity` property on the class with a `CLProximity` value. It is currently set to default to `CLProximityNear`.

## TODOs
- More fine tuning of BeaconRegion measured power
- Handle invalidated services in `OWUProximityServer`
- Properly handle return from local notification

## Thoughts For Future
- Maybe a bluetooth REST API?

## License
OWUProximityManager is available under the MIT license. See the LICENSE file for more info.