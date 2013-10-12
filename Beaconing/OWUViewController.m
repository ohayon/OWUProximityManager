//
//  OWUViewController.m
//  Beaconing
//
//  Created by David Ohayon on 10/11/13.
//  Copyright (c) 2013 ohwutup software. All rights reserved.
//

#import "OWUViewController.h"

@interface OWUViewController ()

@property (nonatomic, strong) IBOutlet UITextField *textField;
@property (nonatomic, strong) IBOutlet UIButton *updateButton;
@property (strong, nonatomic) IBOutlet UISwitch *clientSwitch;
@property (strong, nonatomic) IBOutlet UISwitch *serverSwitch;
@property (strong, nonatomic) IBOutlet UILabel *currentLabel;
@property (strong, nonatomic) IBOutlet UILabel *currentValueLabel;
@property (nonatomic, strong) IBOutlet UILabel *clientLabel;
@property (nonatomic, strong) IBOutlet UILabel *serverLabel;

- (IBAction)updateButtonTapped:(id)sender;
- (IBAction)clientSwitchSwitched:(id)sender;
- (IBAction)serverSwitchSwitched:(id)sender;

@end

@implementation OWUViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.clientSwitch.on = NO;
    self.serverSwitch.on = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupUIForClient {
    self.textField.hidden = NO;
    self.updateButton.hidden = NO;
    self.serverSwitch.hidden = YES;
    self.serverLabel.hidden = YES;
}

- (void)setupUIForServer {
    self.currentLabel.hidden = NO;
    self.currentValueLabel.hidden = NO;
    self.clientSwitch.hidden = YES;
    self.clientLabel.hidden = YES;
}

- (IBAction)clientSwitchSwitched:(id)sender {
    UISwitch *theSwitch = (UISwitch*)sender;
    if (theSwitch.isOn) {
        [[OWUProximityController shared] startupClient];
        [OWUProximityController shared].proximityToConnectToServer = CLProximityNear;
        [OWUProximityController shared].delegate = self;
        [self setupUIForClient];
    } else {
        [self killService];
    }
}

- (IBAction)serverSwitchSwitched:(id)sender {
    UISwitch *theSwitch = (UISwitch*)sender;
    if (theSwitch.isOn) {
        [[OWUProximityController shared] startupServer];
        [OWUProximityController shared].delegate = self;
        [self setupUIForServer];
    } else {
        [self killService];
    }
}

- (void)killService {
    [[OWUProximityController shared] teardownService];
    self.textField.hidden = YES;
    self.updateButton.hidden = YES;
    self.currentValueLabel.hidden = YES;
    self.currentLabel.hidden = YES;
    self.serverSwitch.hidden = NO;
    self.clientSwitch.hidden = NO;
    self.serverLabel.hidden = NO;
    self.clientLabel.hidden = NO;
    [self.textField resignFirstResponder];
    self.textField.text = @"";
    self.currentValueLabel.text = @"";
}

- (IBAction)updateButtonTapped:(id)sender {
    [[OWUProximityController shared] postToServerWithDictionary:@{@"key": self.textField.text}];
    [self.textField resignFirstResponder];
}

#pragma mark - OWUBlueBeaconClientDelegate

- (void)proximityClientDidEnterRegion {
    // This will not be called if the app is started while already inside of the region
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Entered Region"
                                                    message:nil
                                                   delegate:self
                                          cancelButtonTitle:@"Okay"
                                          otherButtonTitles:nil, nil];
    [alert show];
}

- (void)proximityClientDidConnectToServer {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Connected To Server"
                                                    message:nil
                                                   delegate:self
                                          cancelButtonTitle:@"Okay"
                                          otherButtonTitles:nil, nil];
    [alert show];
}

- (void)proximityClientDidRangeBeacon:(CLBeacon *)beacon {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ranged Beacon"
                                                    message:nil
                                                   delegate:self
                                          cancelButtonTitle:@"Okay"
                                          otherButtonTitles:nil, nil];
    [alert show];
}

- (void)proximityClientDidExitRegion {
    // This will not get called until about a minute after exiting the region
    // https://devforums.apple.com/message/898335#898335
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Exited Region"
                                                    message:nil
                                                   delegate:self
                                          cancelButtonTitle:@"Okay"
                                          otherButtonTitles:nil, nil];
    [alert show];
}

#pragma mark - OWUBlueBeaconServerDelegate

- (void)proximityServerDidConnectToClient {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Connected To Client"
                                                    message:nil
                                                   delegate:self
                                          cancelButtonTitle:@"Okay"
                                          otherButtonTitles:nil, nil];
    [alert show];
}

- (void)proximityServerDidReceiveNewDictionary:(NSDictionary*)dictionary {
    self.currentValueLabel.text = dictionary[@"key"];
}

@end
