//
//  OWUViewController.m
//  Beaconing
//
//  Created by David Ohayon on 10/11/13.
//  Copyright (c) 2013 ohwutup software. All rights reserved.
//

#import "OWUViewController.h"

@interface OWUViewController ()

@property (nonatomic, strong) IBOutlet UIButton *serverButton;
@property (nonatomic, strong) IBOutlet UIButton *clientButton;
@property (strong, nonatomic) IBOutlet UILabel *statusLabel;
@property (nonatomic, strong) IBOutlet UITextField *textField;
@property (nonatomic, strong) IBOutlet UIButton *sendButton;
@property (nonatomic, strong) IBOutlet UIButton *killButton;
@property (strong, nonatomic) IBOutlet UILabel *textLabel;

- (IBAction)killButtonTapped:(id)sender;
- (IBAction)sendButtonTapped:(id)sender;
- (IBAction)serverButtonTapped:(id)sender;
- (IBAction)clientButtonTapped:(id)sender;

@end

@implementation OWUViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.textField.hidden = YES;
    self.sendButton.hidden = YES;
    self.killButton.hidden = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)serverButtonTapped:(id)sender {
    self.clientButton.hidden = YES;
    self.statusLabel.text = @"Server";
    self.killButton.hidden = NO;
    [[OWUBlueBeaconServiceManager shared] startupServerAndAdvertiseBeaconRegion];
    [OWUBlueBeaconServiceManager shared].delegate = self;
}

- (IBAction)clientButtonTapped:(id)sender {
    self.serverButton.hidden = YES;
    self.statusLabel.text = @"Client";
    self.sendButton.hidden = NO;
    self.textField.hidden = NO;
    self.killButton.hidden = NO;
    [[OWUBlueBeaconServiceManager shared] startupClientToMonitorForBeaconsRegions];
    [OWUBlueBeaconServiceManager shared].proximityToConnectToServer = CLProximityNear;
    [OWUBlueBeaconServiceManager shared].delegate = self;
}

- (IBAction)sendButtonTapped:(id)sender {
    [[OWUBlueBeaconServiceManager shared] updateServerWithDictionary:@{@"text": self.textField.text}];
}

- (IBAction)killButtonTapped:(id)sender {
    [[OWUBlueBeaconServiceManager shared] teardownService];
    self.textField.hidden = YES;
    self.sendButton.hidden = YES;
    self.textField.hidden = YES;
    self.killButton.hidden = YES;
}

#pragma mark - OWUBlueBeaconClientDelegate

- (void)blueBeaconClientDidEnterRegion {
    // This will not be called if the app is started while already inside of the region
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Entered Region" message:nil delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil];
    [alert show];
}

- (void)blueBeaconClientDidConnectToServer {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Connected To Server" message:nil delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil];
    [alert show];
}

- (void)blueBeaconClientDidRangeBeacon:(CLBeacon *)beacon {
//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ranged Beacon" message:nil delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil];
//    [alert show];
}

- (void)blueBeaconClientDidExitRegion {
    // This will not get called until about a minute after exiting the region
    // https://devforums.apple.com/message/898335#898335
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Exited Region" message:nil delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil];
    [alert show];
}

#pragma mark - OWUBlueBeaconServerDelegate

- (void)blueBeaconServerDidReceiveUpdatedValue:(NSDictionary*)dictionary {
    NSString *message = [NSString stringWithFormat:@"%@", dictionary];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Update From Server" message:message delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil];
    [alert show];
    self.textLabel.text = dictionary[@"text"];
}

@end
