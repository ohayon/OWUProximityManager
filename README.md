# OWUProximityManager

Detect and connect to nearby devices with iBeacons and CoreBluetooth.

## Sample Project

To simulate entering a defined region, select Client on one device, **then** select Server on the other. As the devices will likely be next to eachother when the exchange takes place, it's likely that the Client device will enter the region, range the server and establish a connection pretty quickly.

![home](Screenshots/home.png) ![server](Screenshots/server.png) ![client](Screenshots/client.png)

## Usage
Just, create a few UUIDs for `OWUProximityManagerConstants.h`, `#import OWUProximityManager.h`

Setup Sever:
``` objective-c
[[OWUProximityManager shared] startupServerWithDelegate:delegate]
```
Setup Client:
``` objective-c
[[OWUProximityManager shared] startupClientWithDelegate:delegate]
// defaults to CLProximityNear
[OWUProximityManager shared].desiredProximity = CLProximityImmediate
```
Two things:
- `proximityClientDidEnterBeaconRegion` will not be called if the Client starts while already in range of the Server
- `proximityClientDidExitBeaconRegion` will not be called until about a minute after exiting the region ([dev forum link](https://devforums.apple.com/message/898335#898335))

## ToDo's
- More fine tuning of BeaconRegion measured power
- Handle invalidated services in `OWUProximityServer`
- Properly handle return from local notification
- And moar.
- Suggestions, issues and pull requests are more than welcome.

## License
OWUProximityManager is available under the MIT license. See the LICENSE file for more info.
