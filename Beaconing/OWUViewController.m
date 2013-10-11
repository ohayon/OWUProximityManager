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
    [OWUBlueBeaconServiceManager shared].delegate = self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)serverButtonTapped:(id)sender {
    self.clientButton.hidden = YES;
    self.statusLabel.text = @"Server";
    self.textField.hidden = NO;
    [[OWUBlueBeaconServiceManager shared] startupServerAndAdvertiseBeaconRegion];
}

- (IBAction)clientButtonTapped:(id)sender {
    self.serverButton.hidden = YES;
    self.statusLabel.text = @"Client";
    self.sendButton.hidden = NO;
    self.textField.hidden = NO;
    [[OWUBlueBeaconServiceManager shared] startupClientToMonitorForBeaconsRegions];
    [OWUBlueBeaconServiceManager shared].proximityToConnectToServer = CLProximityFar;
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
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Entered Region" message:nil delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil];
    [alert show];
}

- (void)blueBeaconClientDidConnectToServer {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Connected To Server" message:nil delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil];
    [alert show];
}

#pragma mark - OWUBlueBeaconServerDelegate

- (void)blueBeaconServerDidReceiveUpdatedValue:(NSDictionary*)dictionary {
    NSString *message = [NSString stringWithFormat:@"%@", dictionary];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Connected To Server" message:message delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil];
    [alert show];
}

@end
