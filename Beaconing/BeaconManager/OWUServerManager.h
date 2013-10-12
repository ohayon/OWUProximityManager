//
//  OWUServerManager.h
//  Beaconing
//
//  Created by David Ohayon on 10/11/13.
//  Copyright (c) 2013 ohwutup software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import <CoreLocation/CoreLocation.h>

@protocol OWUServerManagerDelegate <NSObject>

- (void)serverManagerDidSubscribeToCharacteristic;
- (void)serverManagerDidReceiveUpdateToCharacteristicValue:(NSDictionary*)JSONDictionary;

@end

@interface OWUServerManager : NSObject <CBPeripheralManagerDelegate, CBCentralManagerDelegate, CBPeripheralDelegate>

@property (nonatomic, strong) id delegate;
+ (instancetype)sharedServerManager;
- (void)startupServerManager;
- (void)teardownServerManager;

@end
