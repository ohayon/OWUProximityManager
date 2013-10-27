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

@protocol OWUClientManagerDelegate <NSObject>

- (void)clientManagerIsPublishingToCentral;
- (void)clientManagerDidEnterBeaconRegion;
- (void)clientManagerDidExitBeaconRegion;
- (void)clientManagerDidRangeBeacon:(CLBeacon*)beacon inRegion:(CLBeaconRegion*)region;
- (void)clientManagerDidDetermineRegionState:(CLRegionState)state;

@end


@interface OWUClientManager : NSObject <CLLocationManagerDelegate, CBPeripheralManagerDelegate, CBPeripheralDelegate>

@property (nonatomic, strong) id delegate;

+ (instancetype)shared;
- (void)startupClient;
- (void)teardownClient;
- (void)updateCharactaristicValueWithDictionary:(NSDictionary*)JSONDictionary;
- (void)startupConnectionToServerInRegion:(CLBeaconRegion*)region;
@end
