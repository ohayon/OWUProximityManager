//
//  OWUBlueBeaconServiceManager.m
//  Beaconing
//
//  Created by David Ohayon on 10/11/13.
//  Copyright (c) 2013 ohwutup software. All rights reserved.
//

#import "OWUProximityController.h"

@implementation OWUProximityController

+ (instancetype)shared {
    static OWUProximityController *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[OWUProximityController alloc] init];
    });
    
    return _sharedInstance;
}

- (void)teardownService {
    [[OWUClientController shared] teardownClient];
    [[OWUServerController shared] teardownServer];
}

#pragma mark - OWUClient

- (void)startupClient {
    [[OWUClientController shared] startupClient];
    [OWUClientController shared].delegate = self;
}

- (void)postToServerWithDictionary:(NSDictionary*)dictionary {
    [[OWUClientController shared] updateCharactaristicValueWithDictionary:dictionary];
}

#pragma mark - OWUServer

- (void)startupServer {
    [[OWUServerController shared] startupServer];
    [OWUServerController shared].delegate = self;
}

#pragma mark - OWUClientManagerDelegate

- (void)clientManagerIsPublishingToCentral {
    [self.delegate proximityClientDidConnectToServer];
}

- (void)clientManagerDidEnterBeaconRegion {
    [self.delegate proximityClientDidEnterRegion];
}

- (void)clientManagerDidExitRegion {
    [self.delegate proximityClientDidExitRegion];
}

- (void)clientManagerDidRangeBeacon:(CLBeacon*)beacon {
    if (beacon.proximity == CLProximityNear || beacon.proximity == self.proximityToConnectToServer) {
        [self.delegate proximityClientDidRangeBeacon:beacon];
    }
}

- (void)clientManagerDidDetermineRegionState:(CLRegionState)state {
    
}

#pragma mark - OWUServerManagerDelegate

- (void)serverManagerDidSubscribeToCharacteristic {
    [self.delegate proximityServerDidConnectToClient];
}

- (void)serverManagerDidReceiveUpdateToCharacteristicValue:(NSDictionary*)JSONDictionary {
    [self.delegate proximityServerDidReceiveNewDictionary:JSONDictionary];
}

@end
