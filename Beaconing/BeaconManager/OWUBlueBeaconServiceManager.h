//
//  OWUBlueBeaconServiceManager.h
//  Beaconing
//
//  Created by David Ohayon on 10/11/13.
//  Copyright (c) 2013 ohwutup software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OWUClientManager.h"
#import "OWUServerManager.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import <CoreLocation/CoreLocation.h>

@protocol OWUBlueBeaconClientDelegate <NSObject>

- (void)blueBeaconClientDidEnterRegion;
- (void)blueBeaconClientDidConnectToServer;

@optional
- (void)blueBeaconClientDidExitRegion;
- (void)blueBeaconClientDidRangeBeacon:(CLBeacon*)beacon;

@end

@protocol OWUBlueBeaconServerDelegate <NSObject>

- (void)blueBeaconServerDidReceiveUpdatedValue:(NSDictionary*)dictionary;

@end

@interface OWUBlueBeaconServiceManager : NSObject <OWUClientManagerDelegate, OWUServerManagerDelegate>

+ (instancetype)shared;
@property (nonatomic) id delegate;

// Server
- (void)startupServerAndAdvertiseBeaconRegion;

// Client
- (void)startupClientToMonitorForBeaconsRegions;
- (void)updateServerWithDictionary:(NSDictionary*)dictionary;

// By default, the client will pair with the server when it is CLProximityNear
@property (nonatomic) CLProximity proximityToConnectToServer;

- (void)teardownService;

@end
