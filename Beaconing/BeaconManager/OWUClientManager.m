//
//  OWUBeaconManager.m
//  Beaconing
//
//  Created by David Ohayon on 10/11/13.
//  Copyright (c) 2013 ohwutup software. All rights reserved.
//

#import "OWUClientManager.h"
#import "OWUBBSeriviceManagerDefines.h"

@interface OWUClientManager () {
    UIBackgroundTaskIdentifier _backgroundTaskIdentifier;
    CBUUID *_serviceUUID;
    CBMutableService *_service;
    CLBeaconRegion *_beaconRegion;
    CLLocationManager *_locationManager;
    CBPeripheralManager *_peripheralManager;
    CBPeripheral *_peripheral;
    CBMutableCharacteristic *_characteristic;
    NSMutableArray *_subscribedCentrals;
}

@end

@implementation OWUClientManager

+ (instancetype)sharedClientManager {
    static OWUClientManager *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[OWUClientManager alloc] init];
    });
    
    return _sharedInstance;
}

- (void)startupClientManager {
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.delegate = self;
    _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:kOWUBeaconProximityUUID];
    _beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:uuid identifier:kOWUBeaconRegionID];
    [_locationManager startMonitoringForRegion:_beaconRegion];
}

- (void)teardownClientManager {
    _locationManager = nil;
    _beaconRegion = nil;
}


- (void) updateCharactaristicValueWithDictionary:(NSDictionary*)JSONDictionary {
    NSData *data = [NSJSONSerialization dataWithJSONObject:JSONDictionary options:NSJSONWritingPrettyPrinted error:nil];
    [_peripheralManager updateValue:data forCharacteristic:_characteristic onSubscribedCentrals:_subscribedCentrals];
}

#pragma mark - CBPeripheralManagerDelegate

- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral {
    switch (peripheral.state) {
        case CBPeripheralManagerStatePoweredOn:
            break;
            
        default:
            break;
    }
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral didAddService:(CBService *)service error:(NSError *)error {
    if (error == nil) {
        // Starts advertising the service
        [_peripheralManager startAdvertising:@{
                                                   CBAdvertisementDataLocalNameKey : @"OWU",
                                                   CBAdvertisementDataServiceUUIDsKey : @[_serviceUUID]
                                                   }];
    }
}

- (void)peripheralManagerDidStartAdvertising:(CBPeripheralManager *)peripheral error:(NSError *)error {
    if (!error) {
        NSLog(@"Peripheral Manager Did Start Advertising");
    } else {
        NSLog(@"%@", error.localizedDescription);
    }
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveReadRequest:(CBATTRequest *)request {
    NSLog(@"Did Receive Read Request");
}

- (void) peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didSubscribeToCharacteristic:(CBCharacteristic *)characteristic {
    [_subscribedCentrals addObject:central];
    [self.delegate clientManagerIsPublishingToCentral];
    NSLog(@"Publishing Characteristic to Central");
}

#pragma mark - CBPeripheralManagerDelegate Helpers

- (void) setupPeripheralService {
    _peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:nil];
    CBUUID *characteristicUUID = [CBUUID UUIDWithString:kOWUBluetoothCharacteristicUUID];
    _characteristic = [[CBMutableCharacteristic alloc] initWithType:characteristicUUID properties:CBCharacteristicPropertyNotify value:nil permissions:CBAttributePermissionsWriteable];
    _serviceUUID = [CBUUID UUIDWithString:kOWUBluetoothServiceUUID];
    _service = [[CBMutableService alloc] initWithType:_serviceUUID primary:YES];
    [_service setCharacteristics:@[_characteristic]];
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region {
    if ([region isEqual:_beaconRegion]) {
        NSLog(@"entered");
        if ([UIApplication sharedApplication].applicationState == UIApplicationStateBackground) {
            _backgroundTaskIdentifier = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
                [[UIApplication sharedApplication] endBackgroundTask:_backgroundTaskIdentifier];
                _backgroundTaskIdentifier = UIBackgroundTaskInvalid;
            }];
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [self showNotification];
                [[UIApplication sharedApplication] endBackgroundTask:_backgroundTaskIdentifier];
                _backgroundTaskIdentifier = UIBackgroundTaskInvalid;
            });
        } else {
            [_locationManager startRangingBeaconsInRegion:_beaconRegion];
            [self.delegate clientManagerDidEnterBeaconRegion];
        }
    }
}

- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region {
    if ([region isEqual:_beaconRegion]) {
        NSLog(@"Exited Region");
        [self.delegate clientManagerDidExitRegion];
    }
}

- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region {
    if (beacons.count && [region isEqual:_beaconRegion]) {
        CLBeacon *beacon = beacons[0];
        switch (beacon.proximity) {
            case CLProximityFar:
                if (self.proximityToConnectToServer == CLProximityFar) {
                    [self startupPeripheralServiceForRegion:region];
                }
                [self.delegate clientManagerDidRangeBeacon:beacon];
                NSLog(@"Far");
                break;
            case CLProximityNear:
                if (self.proximityToConnectToServer == CLProximityNear  || !self.proximityToConnectToServer) {
                    [self startupPeripheralServiceForRegion:region];
                }
                [self.delegate clientManagerDidRangeBeacon:beacon];
                NSLog(@"Near");
                break;
            case CLProximityImmediate:
                if (self.proximityToConnectToServer == CLProximityImmediate) {
                    [self startupPeripheralServiceForRegion:region];
                }
                [self.delegate clientManagerDidRangeBeacon:beacon];
                NSLog(@"Immediate");
                break;
            case CLProximityUnknown:
                [self.delegate clientManagerDidRangeBeacon:beacon];
                NSLog(@"Unknown");
                break;
            default:
                break;
        }
    }
}

- (void) startupPeripheralServiceForRegion:(CLBeaconRegion*)region {
    [_locationManager stopRangingBeaconsInRegion:region];
    if (!_peripheralManager) {
        [self setupPeripheralService];
    }
    [_peripheralManager addService:_service];
}

- (void)locationManager:(CLLocationManager *)manager rangingBeaconsDidFailForRegion:(CLBeaconRegion *)region withError:(NSError *)error {
    NSLog(@"Beacon ranging failed with error: %@", [error localizedDescription]);
}

- (void)locationManager:(CLLocationManager *)manager didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region {
    if ([region.identifier isEqual:_beaconRegion.identifier]) {
        switch (state) {
            case CLRegionStateInside:
                [_locationManager stopMonitoringForRegion:_beaconRegion];
                [self.delegate clientManagerDidDetermineRegionState:CLRegionStateInside];
                NSLog(@"Inside State");
                break;
            case CLRegionStateOutside:
                [self.delegate clientManagerDidDetermineRegionState:CLRegionStateOutside];
                NSLog(@"Outside State");
                break;
            case CLRegionStateUnknown:
                [self.delegate clientManagerDidDetermineRegionState:CLRegionStateUnknown];
                NSLog(@"Unknown State");
                break;
            default:
                break;
        }
    }
}

- (void)locationManager:(CLLocationManager *)manager monitoringDidFailForRegion:(CLRegion *)region withError:(NSError *)error
{
    NSLog(@"Region monitoring failed with error: %@", [error localizedDescription]);
}

#pragma mark - Local Notification

- (void) showNotification {
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    notification.alertAction = @"Did Enter Region";
    notification.fireDate = [NSDate date];
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
}

@end
