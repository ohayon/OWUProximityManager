//
//  OWUServerManager.m
//  Beaconing
//
//  Created by David Ohayon on 10/11/13.
//  Copyright (c) 2013 ohwutup software. All rights reserved.
//

#import "OWUServerManager.h"
#import "OWUBBSeriviceManagerDefines.h"

@interface OWUServerManager () {
    // iBeacons
    CBPeripheralManager *_peripheralManager;
    CLBeaconRegion *_beaconRegion;
    
    // CBCentral
    CBCentralManager *_centralManager;
    NSMutableData *_data;
    CBPeripheral *_peripheral;
    CBUUID *_serviceUUID;
    CBUUID *_characteristicUUID;
}

@end

@implementation OWUServerManager

+ (instancetype) sharedServerManager {
    static OWUServerManager *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[OWUServerManager alloc] init];
    });
    
    return _sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _serviceUUID = [CBUUID UUIDWithString:kOWUBluetoothServiceUUID];
        _characteristicUUID = [CBUUID UUIDWithString:kOWUBluetoothCharacteristicUUID];
    }
    return self;
}

- (void) startupServerManager {
    _peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:nil];
    _centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
}

- (void) teardownServerManager {
    _peripheralManager = nil;
    _centralManager = nil;
    _peripheral = nil;
    _beaconRegion = nil;
    _data = nil;
    _serviceUUID = nil;
    _characteristicUUID = nil;
}

#pragma mark - CBPeripheralManagerDelegate

- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral {
    switch (peripheral.state) {
        case CBPeripheralManagerStatePoweredOn:
            [self setupBeaconRegion];
            break;
            
        default:
            break;
    }
}

#pragma mark - CBPeripheralManagerDelegate Helpers

- (void)setupBeaconRegion {
    NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:kOWUBeaconProximityUUID];
    _beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:uuid identifier:kOWUBeaconRegionID];
    NSDictionary *peripheralDataDictionary = [_beaconRegion peripheralDataWithMeasuredPower:@(-40)];
    [_peripheralManager startAdvertising:peripheralDataDictionary];
}

#pragma mark - CBCentralManagerDelegate

- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    switch (central.state) {
        case CBCentralManagerStatePoweredOn:
            // Scans for any peripheral
            [_centralManager scanForPeripheralsWithServices:@[_serviceUUID] options:@{CBCentralManagerScanOptionAllowDuplicatesKey : @YES}];
            break;
            
        default:
            break;
    }
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI {
    // Stops scanning for peripheral
    [_centralManager stopScan];
    
    if (_peripheral != peripheral) {
        _peripheral = peripheral;
        NSLog(@"Connecting to peripheral %@", peripheral);
        // Connects to the discovered peripheral
        [_centralManager connectPeripheral:peripheral options:nil];
    }
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    _data.length = 0;
    _peripheral.delegate = self;
    [_peripheral discoverServices:@[_serviceUUID]];
}

#pragma mark - CBPeripheralDelegate

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    if (error) {
        NSLog(@"Error discovering service: %@", [error localizedDescription]);
        return;
    }
    
    for (CBService *service in peripheral.services) {
        NSLog(@"Service found with UUID: %@", service.UUID);
        if ([service.UUID isEqual:_serviceUUID]) {
            [_peripheral discoverCharacteristics:@[_characteristicUUID] forService:service];
        }
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
    if (error) {
        NSLog(@"Error discovering characteristic: %@", [error localizedDescription]);
        return;
    }
    if ([service.UUID isEqual:_serviceUUID]) {
        for (CBCharacteristic *characteristic in service.characteristics) {
            if ([characteristic.UUID isEqual:_characteristicUUID]) {
                [peripheral setNotifyValue:YES forCharacteristic:characteristic];
            }
        }
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    if (error) {
        NSLog(@"Error changing notification state: %@", error.localizedDescription);
        return;
    }
    if (![characteristic.UUID isEqual:_characteristicUUID]) {
        return;
    }
    if (characteristic.isNotifying) {
        NSLog(@"Notifications started for characteristic: %@", characteristic);
        [peripheral readValueForCharacteristic:characteristic];
    } else {
        NSLog(@"Notification stopped for characteristic: %@", characteristic);
        [_centralManager cancelPeripheralConnection:_peripheral];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    if (characteristic.value) {
        NSDictionary *dataDict = [NSJSONSerialization JSONObjectWithData:characteristic.value
                                                                 options:NSJSONReadingAllowFragments
                                                                   error:nil];
        [self.delegate serverManagerDidReceiveUpdateToCharacteristicValue:dataDict];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didModifyServices:(NSArray *)invalidatedServices {
    // TODO: Handle invalidated service
    // continue scanning for services
}

@end
