//
//  OWUBeaconManager.h
//  Beaconing
//
//  Created by David Ohayon on 10/11/13.
//  Copyright (c) 2013 ohwutup software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@protocol OWUClientControllerDelegate <NSObject>

- (void)clientManagerIsPublishingToCentral;
- (void)clientManagerDidEnterBeaconRegion;
- (void)clientManagerDidExitRegion;
- (void)clientManagerDidRangeBeacon:(CLBeacon*)beacon;
- (void)clientManagerDidDetermineRegionState:(CLRegionState)state;

@end


@interface OWUClientController : NSObject <CLLocationManagerDelegate, CBPeripheralManagerDelegate, CBPeripheralDelegate>

@property (nonatomic, strong) id delegate;
@property (nonatomic) CLProximity proximityToConnectToServer;

+ (instancetype)shared;
- (void)startupClient;
- (void)teardownClient;
- (void)updateCharactaristicValueWithDictionary:(NSDictionary*)JSONDictionary;

@end
