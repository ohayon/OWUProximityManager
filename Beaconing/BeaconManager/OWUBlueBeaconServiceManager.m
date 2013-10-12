//
//  OWUBlueBeaconServiceManager.m
//  Beaconing
//
//  Created by David Ohayon on 10/11/13.
//  Copyright (c) 2013 ohwutup software. All rights reserved.
//

#import "OWUBlueBeaconServiceManager.h"

@implementation OWUBlueBeaconServiceManager

+ (instancetype)shared {
    static OWUBlueBeaconServiceManager *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[OWUBlueBeaconServiceManager alloc] init];
    });
    
    return _sharedInstance;
}

- (void)teardownService {
    [[OWUClientManager sharedClientManager] teardownClientManager];
    [[OWUServerManager sharedServerManager] teardownServerManager];
}

#pragma mark - OWUClient

- (void)startupClientToMonitorForBeaconsRegions {
    [[OWUClientManager sharedClientManager] startupClientManager];
    [OWUClientManager sharedClientManager].delegate = self;
}

- (void)updateServerWithDictionary:(NSDictionary*)dictionary {
    [[OWUClientManager sharedClientManager] updateCharactaristicValueWithDictionary:dictionary];
}

#pragma mark - OWUServer

- (void)startupServerAndAdvertiseBeaconRegion {
    [[OWUServerManager sharedServerManager] startupServerManager];
    [OWUServerManager sharedServerManager].delegate = self;
}

#pragma mark - OWUClientManagerDelegate

- (void)clientManagerIsPublishingToCentral {
    [self.delegate blueBeaconClientDidConnectToServer];
}

- (void)clientManagerDidEnterBeaconRegion {
    [self.delegate blueBeaconClientDidEnterRegion];
}

- (void)clientManagerDidExitRegion {
    [self.delegate blueBeaconClientDidExitRegion];
}

- (void)clientManagerDidRangeBeacon:(CLBeacon*)beacon {
    if (beacon.proximity == CLProximityNear || beacon.proximity == self.proximityToConnectToServer) {
        [self.delegate blueBeaconClientDidRangeBeacon:beacon];
    }
}

- (void)clientManagerDidDetermineRegionState:(CLRegionState)state {
    
}

#pragma mark - OWUServerManagerDelegate

- (void)serverManagerDidReceiveUpdateToCharacteristicValue:(NSDictionary*)JSONDictionary {
    [self.delegate blueBeaconServerDidReceiveUpdatedValue:JSONDictionary];
}

@end
