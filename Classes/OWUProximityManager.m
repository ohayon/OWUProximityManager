//
//  OWUBlueBeaconServiceManager.m
//  Beaconing
//
//  Created by David Ohayon on 10/11/13.
//  Copyright (c) 2013 ohwutup software. All rights reserved.
//

#import "OWUProximityManager.h"

@implementation OWUProximityManager

+ (instancetype)shared {
    static OWUProximityManager *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[OWUProximityManager alloc] init];
    });
    
    return _sharedInstance;
}

- (void)teardownService {
    [[OWUClientManager shared] teardownClient];
    [[OWUServerManager shared] teardownServer];
}

#pragma mark - OWUClient

- (void)startupClientWithDelegate:(id)delegate {
    self.delegate = delegate;
    [[OWUClientManager shared] startupClient];
    [OWUClientManager shared].delegate = self;
}

- (void)postToServerWithDictionary:(NSDictionary*)dictionary {
    [[OWUClientManager shared] updateCharactaristicValueWithDictionary:dictionary];
}

#pragma mark - OWUServer

- (void)startupServerWithDelegate:(id)delegate {
    self.delegate = delegate;
    [[OWUServerManager shared] startupServer];
    [OWUServerManager shared].delegate = self;
}

#pragma mark - OWUClientManagerDelegate

- (void)clientManagerIsPublishingToCentral {
    [self.delegate proximityClientDidConnectToServer];
}

- (void)clientManagerDidEnterBeaconRegion {
    [self.delegate proximityClientDidEnterRegion];
}

- (void)clientManagerDidExitBeaconRegion {
    [self.delegate proximityClientDidExitRegion];
}

- (void)clientManagerDidRangeBeacon:(CLBeacon*)beacon {
    if (beacon.proximity == CLProximityNear || beacon.proximity == self.desiredProximity) {
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
