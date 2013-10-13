//
//  OWUBlueBeaconServiceManager.h
//  Beaconing
//
//  Created by David Ohayon on 10/11/13.
//  Copyright (c) 2013 ohwutup software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import <CoreLocation/CoreLocation.h>

@protocol OWUProximityClientDelegate <NSObject>

- (void)proximityClientDidEnterRegion;
- (void)proximityClientDidConnectToServer;
- (void)proximityClientDidExitRegion;
- (void)proximityClientDidRangeBeacon:(CLBeacon*)beacon;

@end

@protocol OWUProximityServerDelegate <NSObject>

- (void)proximityServerDidConnectToClient;
- (void)proximityServerDidReceiveNewDictionary:(NSDictionary*)dictionary;

@end

@interface OWUProximityManager : NSObject

+ (instancetype)shared;
@property (nonatomic) id delegate;

// Server
- (void)startupServerWithDelegate:(id)delegate;

// Client
- (void)startupClientWithDelegate:(id)delegate;
- (void)postToServerWithDictionary:(NSDictionary*)dictionary;

// By default, the client will pair with the server when it is CLProximityNear
@property (nonatomic) CLProximity desiredProximity;

- (void)teardownService;

@end
