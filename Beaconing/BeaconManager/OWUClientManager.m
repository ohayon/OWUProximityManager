//
//  OWUBeaconManager.m
//  Beaconing
//
//  Created by David Ohayon on 10/11/13.
//  Copyright (c) 2013 ohwutup software. All rights reserved.
//

#import "OWUClientManager.h"
#import "OWUProximityManagerDefines.h"

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
    BOOL _didAddService;
}

@end

@implementation OWUClientManager

+ (instancetype)shared {
    static OWUClientManager *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[OWUClientManager alloc] init];
    });
    
    return _sharedInstance;
}

- (void)startupClient {
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.delegate = self;
    _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:kOWUBeaconProximityUUID];
    _beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:uuid identifier:kOWUBeaconRegionID];
    [_locationManager startMonitoringForRegion:_beaconRegion];
}

- (void)teardownClient {
    _locationManager = nil;
    _beaconRegion = nil;
    _peripheralManager = nil;
    _peripheral = nil;
    _serviceUUID = nil;
    _service = nil;
    _backgroundTaskIdentifier = 0;
    _characteristic = nil;
    _subscribedCentrals = nil;
    _didAddService = NO;
}


- (void) updateCharactaristicValueWithDictionary:(NSDictionary*)JSONDictionary {
    NSData *data = [NSJSONSerialization dataWithJSONObject:JSONDictionary
                                                   options:NSJSONWritingPrettyPrinted error:nil];
    [_peripheralManager updateValue:data
                  forCharacteristic:_characteristic
               onSubscribedCentrals:_subscribedCentrals];
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
        [_peripheralManager startAdvertising:@{
                                               CBAdvertisementDataLocalNameKey : @"OWUClientManager",
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


- (void) startupPeripheralService {
    if (!_peripheralManager) {
        _didAddService = NO;
        _peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:nil];
        CBUUID *characteristicUUID = [CBUUID UUIDWithString:kOWUBluetoothCharacteristicUUID];
        _characteristic = [[CBMutableCharacteristic alloc] initWithType:characteristicUUID
                                                             properties:CBCharacteristicPropertyNotify
                                                                  value:nil
                                                            permissions:CBAttributePermissionsWriteable];
        _serviceUUID = [CBUUID UUIDWithString:kOWUBluetoothServiceUUID];
        _service = [[CBMutableService alloc] initWithType:_serviceUUID primary:YES];
        [_service setCharacteristics:@[_characteristic]];
    }
    
    if (!_peripheralManager.isAdvertising && !_didAddService) {
        [_peripheralManager addService:_service];
        _didAddService = YES;
    }
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region {
    if ([region isEqual:_beaconRegion]) {
        NSLog(@"Entered Region");
        if ([UIApplication sharedApplication].applicationState == UIApplicationStateBackground) {
            [self showNotification];
        } else {
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
                    [_locationManager stopRangingBeaconsInRegion:region];
                    [self startupPeripheralService];
                }
                [self.delegate clientManagerDidRangeBeacon:beacon];
                NSLog(@"Far");
                break;
            case CLProximityNear:
                if (self.proximityToConnectToServer == CLProximityNear  || !self.proximityToConnectToServer) {
                    [_locationManager stopRangingBeaconsInRegion:region];
                    [self startupPeripheralService];
                }
                [self.delegate clientManagerDidRangeBeacon:beacon];
                NSLog(@"Near");
                break;
            case CLProximityImmediate:
                if (self.proximityToConnectToServer == CLProximityImmediate) {
                    [_locationManager stopRangingBeaconsInRegion:region];                    
                    [self startupPeripheralService];
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

- (void)locationManager:(CLLocationManager *)manager rangingBeaconsDidFailForRegion:(CLBeaconRegion *)region withError:(NSError *)error {
    NSLog(@"Beacon ranging failed with error: %@", [error localizedDescription]);
}

- (void)locationManager:(CLLocationManager *)manager didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region {
    if ([region.identifier isEqual:_beaconRegion.identifier]) {
        switch (state) {
            case CLRegionStateInside:
                [_locationManager stopMonitoringForRegion:_beaconRegion];
                [_locationManager startRangingBeaconsInRegion:_beaconRegion];
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
    _backgroundTaskIdentifier = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        [[UIApplication sharedApplication] endBackgroundTask:_backgroundTaskIdentifier];
        _backgroundTaskIdentifier = UIBackgroundTaskInvalid;
    }];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[UIApplication sharedApplication] cancelAllLocalNotifications];
        UILocalNotification *notification = [[UILocalNotification alloc] init];
        notification.alertBody = @"Entered Region";
        [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
        [[UIApplication sharedApplication] endBackgroundTask:_backgroundTaskIdentifier];
        _backgroundTaskIdentifier = UIBackgroundTaskInvalid;
    });
}

@end
