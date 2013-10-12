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

@protocol OWUServerControllerDelegate <NSObject>

- (void)serverManagerDidSubscribeToCharacteristic;
- (void)serverManagerDidReceiveUpdateToCharacteristicValue:(NSDictionary*)JSONDictionary;

@end

@interface OWUServerController : NSObject <CBPeripheralManagerDelegate, CBCentralManagerDelegate, CBPeripheralDelegate>

@property (nonatomic, strong) id delegate;
+ (instancetype)shared;
- (void)startupServer;
- (void)teardownServer;

@end
