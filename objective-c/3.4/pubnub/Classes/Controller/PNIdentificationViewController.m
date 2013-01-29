//
//  PNIdentificationViewController.m
//  pubnub
//
//  This view controller allow to retrieve
//  user identifier if he would like to
//  provide it to the application.
//
//
//  Created by Sergey Mamontov on 12/4/12.
//
//

#import "PNIdentificationViewController.h"
#import "PNDataManager.h"
#import "PNMacro.h"


#pragma mark Private interface methods

@interface PNIdentificationViewController () <UITextFieldDelegate>


#pragma mark - Properties

@property (nonatomic, pn_desired_weak) IBOutlet UIButton *connectButton;

// Stores reference on label which is used to show
// information about current connection progress
// with some piece of internal information
@property (nonatomic, pn_desired_weak) IBOutlet UITextView *connectionProgressLabel;

// Stores reference on text field where user can
// input his identifier
@property (nonatomic, pn_desired_weak) IBOutlet UITextField *clientIdentifier;

// Stores reference on switch which will allow to choose
// whether connection should be established over SSL
// or plain HTTP
@property (nonatomic, pn_desired_weak) IBOutlet UISwitch *sslEnablingSwitch;


#pragma mark - Instance methods

#pragma mark - Interface customization 

- (void)prepareInterface;


#pragma mark - Handler methods

- (IBAction)connectButtonTapped:(id)sender;
- (IBAction)sslModeSwitchChanged:(id)sender;


#pragma mark - Misc methods

- (void)updateConnectionProgressMessage:(NSString *)message;


@end


#pragma mark - Public interface methods

@implementation PNIdentificationViewController


#pragma mark - Instance methods

- (void)viewDidLoad {
    
    // Forward to the super class to complete all intializations
    [super viewDidLoad];
    
    [self prepareInterface];

    PNIdentificationViewController *weakSelf = self;
    [[PNObservationCenter defaultCenter] addClientConnectionStateObserver:self
                                                        withCallbackBlock:^(NSString *origin,
                                                                            BOOL connected,
                                                                            PNError *connectionError) {

                weakSelf.clientIdentifier.text = [PubNub clientIdentifier];

                weakSelf.clientIdentifier.userInteractionEnabled = !connected;
                weakSelf.sslEnablingSwitch.enabled = !connected;
                weakSelf.connectButton.enabled = !connected;
            }];
}

- (BOOL)disablesAutomaticKeyboardDismissal {

    return NO;
}

#pragma mark - Interface customization

- (void)prepareInterface {
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background"]];
    
    UIImage *stretchableButtonBackground = [[UIImage imageNamed:@"red-button.png"] stretchableImageWithLeftCapWidth:5.0f
                                                                                               topCapHeight:5.0f];
    [self.connectButton setBackgroundImage:stretchableButtonBackground forState:UIControlStateNormal];

    self.clientIdentifier.text = [PubNub clientIdentifier];
    self.sslEnablingSwitch.on = [PNDataManager sharedInstance].configuration.shouldUseSecureConnection;
}


#pragma mark - Handler methods

- (IBAction)connectButtonTapped:(id)sender {

    // Disabling controls
    ((UIButton *)sender).enabled = NO;
    self.sslEnablingSwitch.enabled = NO;
    self.clientIdentifier.userInteractionEnabled = NO;

    // Update PubNub client configuration
    [PubNub setConfiguration:[PNDataManager sharedInstance].configuration];


    PNIdentificationViewController *weakSelf = self;
    [PubNub connectWithSuccessBlock:^(NSString *origin) {

        PNLog(PNLogGeneralLevel, self, @"{BLOCK} PubNub client connected to: %@", origin);

        [weakSelf updateConnectionProgressMessage:[NSString stringWithFormat:@"Connected to '%@'",
                                                   [PNDataManager sharedInstance].configuration.origin]];
    }

                         // In case of error you always can pull out error code and
                         // identify what is happened and what you can do
                         // (additional information is stored inside error's
                         // localizedDescription, localizedFailureReason and
                         // localizedRecoverySuggestion)
                         errorBlock:^(PNError *connectionError) {

                             // Enable controls so user will be able to try again
                             ((UIButton *)sender).enabled = YES;
                             weakSelf.sslEnablingSwitch.enabled = YES;
                             weakSelf.clientIdentifier.userInteractionEnabled = YES;

                             [weakSelf updateConnectionProgressMessage:[NSString stringWithFormat:@"Connection to '%@' failed because of error: %@",
                                                                        [PNDataManager sharedInstance].configuration.origin,
                                                                        connectionError]];

                             UIAlertView *connectionErrorAlert = [UIAlertView new];
                             connectionErrorAlert.title = [connectionError localizedDescription];
                             connectionErrorAlert.message = [NSString stringWithFormat:@"Reason:\n%@\n\nSuggestion:\n%@",
                                             [connectionError localizedFailureReason],
                                             [connectionError localizedRecoverySuggestion]];
                             [connectionErrorAlert addButtonWithTitle:@"OK"];

                             [connectionErrorAlert show];
                         }];

    [self updateConnectionProgressMessage:[NSString stringWithFormat:@"Connecting to '%@' as '%@'\nSSL enabled? %@...",
                                                                     [PNDataManager sharedInstance].configuration.origin,
                                                                     [PubNub clientIdentifier],
                                                                     [PNDataManager sharedInstance].configuration.shouldUseSecureConnection ? @"YES" : @"NO"]];
}

- (IBAction)sslModeSwitchChanged:(id)sender {

    [[PNDataManager sharedInstance] updateSSLOption:((UISwitch *)sender).isOn];
}


#pragma mark - Misc methods

- (void)updateConnectionProgressMessage:(NSString *)message {

    self.connectionProgressLabel.text = message;
}


#pragma mark - UITextField delegate methods

- (void)textFieldDidEndEditing:(UITextField *)textField {
    
    NSString *clientIdentifier = [textField.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    if ([clientIdentifier length] == 0) {
        
        clientIdentifier = nil;
    }
    
    [PubNub setClientIdentifier:clientIdentifier];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {

    [self.view endEditing:YES];


    return YES;
}


/**
 * Asking view controller whether interface will be rotated to portrait
 * orientation or not
 */
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    
    BOOL shouldAutorotate = UIInterfaceOrientationIsLandscape(toInterfaceOrientation);
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        
        shouldAutorotate = UIInterfaceOrientationIsPortrait(toInterfaceOrientation);
    }
    
    
    return shouldAutorotate;
}


#pragma mark - Memory management

- (void)dealloc {

    [[PNObservationCenter defaultCenter] removeClientConnectionStateObserver:self];
}

#pragma mark -


@end
