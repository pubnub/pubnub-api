//
//  PNMainViewController.m
//  pubnub
//
//  This view controller is responsible for
//  chat interface layout and handling user
//  interaction
//
//
//  Created by Sergey Mamontov on 1/20/13.
//
//

#import "PNMainViewController.h"
#import "PNChannelInformationDelegate.h"
#import "PNChannelCreationDelegate.h"
#import "PNChannelInformationView.h"
#import "PNChannelCreationView.h"
#import "NSString+PNAddition.h"
#import "PNDataManager.h"
#import "PNChannelHistoryView.h"


#pragma mark Private interface methods

@interface PNMainViewController () <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate,
                                    PNChannelCreationDelegate, PNChannelInformationDelegate>


#pragma mark - Properties

// Stores reference on table which will hold list of channels
// to which user subscribed
@property (nonatomic, pn_desired_weak) IBOutlet UITableView *channelsTableView;

// Stores reference on table which will hold list of participants
// at specified channel (which currently opened)
@property (nonatomic, pn_desired_weak) IBOutlet UITableView *channelParticipantsTableView;

// Stores reference on text field inside of which messages and events
// will be shown
@property (nonatomic, pn_desired_weak) IBOutlet UITextView *messageTextView;

// Stores reference on participants section background image
@property (nonatomic, pn_desired_weak) IBOutlet UIImageView *participantsBackgroundImageView;

// Stores reference on channels section background image
@property (nonatomic, pn_desired_weak) IBOutlet UIImageView *channelsBackgroundImageView;

// Stores reference on button which allow to subscribe on new channel
@property (nonatomic, pn_desired_weak) IBOutlet UIButton *addChannelButton;

// Stores reference on button which allow to disconnect client
@property (nonatomic, pn_desired_weak) IBOutlet UIButton *disconnectButton;

// Stores reference on button which allow to see information about client and
// change some of the options
@property (nonatomic, pn_desired_weak) IBOutlet UIButton *clientInformationButton;

// Stores reference on button which allow to retrieve server time from PubNub service
@property (nonatomic, pn_desired_weak) IBOutlet UIButton *serverTimeButton;

@property (nonatomic, pn_desired_weak) IBOutlet UILabel *recentServerTimeLabel;

// Stores reference on channel information holding view
@property (nonatomic, pn_desired_weak) IBOutlet PNChannelInformationView *channelInformationView;

// Stores reference on message sending button
@property (nonatomic, pn_desired_weak) IBOutlet UIButton *sendMessageButton;

// Stores reference on message input text field
@property (nonatomic, pn_desired_weak) IBOutlet UITextField *messageTextField;


#pragma mark - Instance methods

#pragma mark - Interface customization

- (void)prepareInterface;


#pragma mark - Handler methods

- (IBAction)disconnectButtonTapped:(id)sender;
- (IBAction)clientInformationButtonTapper:(id)sender;
- (IBAction)addChannelButtonTapped:(id)sender;
- (IBAction)getServerTimeButtonTapped:(id)sender;
- (IBAction)sendMessageButtonTapped:(id)sender;


#pragma mark - Misc methods

/**
 * Updating message sending interface according to current
 * application state:
 * - enable if client is connected at least to one channel
 *   and inputted message
 * - disable in other case
 */
- (void)updateMessageSendingInterfaceWithMessage:(NSString *)message;


@end


#pragma mark - Public interface methods

@implementation PNMainViewController


#pragma mark - Instance methods

- (void)viewDidLoad {
    
    // Forward to the super class to complete all initializations
    [super viewDidLoad];


    [self prepareInterface];


    PNMainViewController *weakSelf = self;
    [[PNObservationCenter defaultCenter] addTimeTokenReceivingObserver:self
                                                     withCallbackBlock:^(NSNumber *timeToken, PNError *error) {

         NSString *alertMessage = nil;
         if (!error) {

             NSDateFormatter *dateFormatter = [NSDateFormatter new];
             dateFormatter.dateFormat = @"HH:mm:ss MM/dd/yy";
             NSDate *timeTokenDate = [NSDate dateWithTimeIntervalSince1970:PNUnixTimeStampFromTimeToken(timeToken)];

             alertMessage = [NSString stringWithFormat:@"Server time token: %@\nDate: %@",
                                                       timeToken,
                                                       [dateFormatter stringFromDate:timeTokenDate]];
             weakSelf.recentServerTimeLabel.text = [dateFormatter stringFromDate:timeTokenDate];
         }
         else {

             alertMessage = [NSString stringWithFormat:@"Time token request failed with error:\n%@",
                                                       error];
         }


         UIAlertView *timeTokenAlertView = [UIAlertView new];
         timeTokenAlertView.title = @"Server time token";
         timeTokenAlertView.message = alertMessage;
         [timeTokenAlertView addButtonWithTitle:@"OK"];
         [timeTokenAlertView show];

     }];



    [[PNObservationCenter defaultCenter] addChannelParticipantsListProcessingObserver:self
                                                                            withBlock:^(NSArray *participants,
                                                                                        PNChannel *channel,
                                                                                        PNError *fetchError) {

            NSString *alertMessage = nil;
            if (!fetchError) {

                alertMessage = [NSString stringWithFormat:@"%@ participants:\n%@",
                                channel,
                                [participants componentsJoinedByString:@"\n"]];
            }
            else {

                alertMessage = [NSString stringWithFormat:@"Participants list request failed with error: %@",
                                fetchError];
            }

            if (!fetchError) {

                [weakSelf.channelParticipantsTableView reloadData];
            }


            UIAlertView *timeTokenAlertView = [UIAlertView new];
            timeTokenAlertView.title = @"Participants list";
            timeTokenAlertView.message = alertMessage;
            [timeTokenAlertView addButtonWithTitle:@"OK"];
            [timeTokenAlertView show];
        }];


    // Subscribe on data manager properties change
    [[PNDataManager sharedInstance] addObserver:self
                                     forKeyPath:@"currentChannel"
                                        options:NSKeyValueObservingOptionNew
                                        context:nil];
    [[PNDataManager sharedInstance] addObserver:self
                                     forKeyPath:@"subscribedChannelsList"
                                        options:NSKeyValueObservingOptionNew
                                        context:nil];
}

#pragma mark - Interface customization

- (void)prepareInterface {

    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"side-menu-background"]];

    UIImage *leftSectionImage = [UIImage imageNamed:@"left-section-header-background"];
    UIImage *stretchedLeftSectionImage = [leftSectionImage stretchableImageWithLeftCapWidth:10.0f
                                                                               topCapHeight:10.0f];

    UIImage *rightSectionImage = [UIImage imageNamed:@"right-section-header-background"];
    UIImage *stretchedRightSectionImage = [rightSectionImage stretchableImageWithLeftCapWidth:10.0f
                                                                                 topCapHeight:10.0f];

    UIImage *rightSingleEntryImage = [UIImage imageNamed:@"right-single-entry-background.png"];
    UIImage *stretchedRightSingleEntryImage = [rightSingleEntryImage stretchableImageWithLeftCapWidth:10.0f
                                                                                         topCapHeight:10.0f];

    self.participantsBackgroundImageView.image = stretchedLeftSectionImage;
    self.channelsBackgroundImageView.image = stretchedRightSectionImage;



    UIImage *whiteButtonImage = [UIImage imageNamed:@"white-button"];
    UIImage *stretchedWhiteButtonImageImage = [whiteButtonImage stretchableImageWithLeftCapWidth:5.0f
                                                                                    topCapHeight:10.0f];

    [self.addChannelButton setBackgroundImage:stretchedWhiteButtonImageImage forState:UIControlStateNormal];
    [self.serverTimeButton setBackgroundImage:stretchedWhiteButtonImageImage forState:UIControlStateNormal];
    [self.sendMessageButton setBackgroundImage:stretchedWhiteButtonImageImage forState:UIControlStateNormal];
    [self.disconnectButton setBackgroundImage:stretchedRightSingleEntryImage forState:UIControlStateNormal];

    [self.clientInformationButton setBackgroundImage:stretchedRightSingleEntryImage forState:UIControlStateNormal];
    NSString *clientIdentifier = [PubNub clientIdentifier];
    if (!PNIsUserGeneratedUUID(clientIdentifier)) {

        clientIdentifier = @"anonymous";
    }
    [self.clientInformationButton setTitle:clientIdentifier forState:UIControlStateNormal];


    self.channelInformationView.delegate = self;
    [self updateMessageSendingInterfaceWithMessage:nil];
}


#pragma mark - Handler methods

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {

    // Check whether current category changed or not
    if ([keyPath isEqualToString:@"currentChannel"]) {

        [self.channelParticipantsTableView reloadData];
    }
    // Looks like list of channels changed
    else {

        [self.channelsTableView reloadData];
    }

    [self updateMessageSendingInterfaceWithMessage:nil];
}

- (IBAction)disconnectButtonTapped:(id)sender {

    [PubNub disconnect];
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)clientInformationButtonTapper:(id)sender {

}

- (IBAction)addChannelButtonTapped:(id)sender {

    PNChannelCreationView *view = [PNChannelCreationView viewFromNib];
    view.delegate = self;
    CGRect targetFrame = view.frame;
    targetFrame.origin.x = ceilf(self.view.bounds.size.width*0.5f-targetFrame.size.width*0.5f);
    targetFrame.origin.y = ceilf(self.view.bounds.size.height*0.5f-targetFrame.size.height);
    view.frame = targetFrame;

    [self.view addSubview:view];
}

- (IBAction)getServerTimeButtonTapped:(id)sender {

    [PubNub requestServerTimeToken];
}

- (IBAction)sendMessageButtonTapped:(id)sender {

    [PubNub sendMessage:self.messageTextField.text toChannel:[PNDataManager sharedInstance].currentChannel];
    [self.view endEditing:YES];
}


#pragma mark - Misc methods

/**
 * Updating message sending interface according to current
 * application state:
 * - enable if client is connected at least to one channel
 *   and inputted message
 * - disable in other case
 */
- (void)updateMessageSendingInterfaceWithMessage:(NSString *)message {

    BOOL isSubscribed = [[PNDataManager sharedInstance].subscribedChannelsList count] > 0;
    BOOL isChannelSelected = [PNDataManager sharedInstance].currentChannel != nil;
    if (message == nil) {

        message = self.messageTextView.text;
    }

    self.sendMessageButton.enabled = isSubscribed && ![message isEmptyString] && isChannelSelected;
    self.messageTextField.enabled = isSubscribed && isChannelSelected;
}


#pragma mark - Channel subscription delegate methods

- (void)creationView:(PNChannelCreationView*)view subscribeOnChannel:(PNChannel *)channel {

    [PubNub subscribeOnChannel:channel withCompletionHandlingBlock:^(NSArray *channels,
                                                                     BOOL subscribed,
                                                                     PNError *subscriptionError) {

        NSString *alertMessage = [NSString stringWithFormat:@"Subscribed on channel: %@\nTo be able to send messages, select channel from righthand list",
                                                            channel.name];
        if (!subscribed) {

            alertMessage = [NSString stringWithFormat:@"Failed to subscribe on: %@", channel.name];
        }


        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Subscribe"
                                                            message:alertMessage
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [alertView show];
   }];
}


#pragma mark - Channel information delegate

- (void)showHistoryRequestParameters {

    PNChannelHistoryView *view = [PNChannelHistoryView viewFromNib];
    CGRect targetFrame = view.frame;
    targetFrame.origin.x = ceilf(self.view.bounds.size.width*0.5f-targetFrame.size.width*0.5f);
    targetFrame.origin.y = ceilf(self.view.bounds.size.height*0.5f-targetFrame.size.height*0.5f);
    view.frame = targetFrame;

    [self.view addSubview:view];
}


#pragma mark - UITextField delegate methods

- (BOOL)            textField:(UITextField *)textField
shouldChangeCharactersInRange:(NSRange)range
            replacementString:(NSString *)string {

    NSString *inputtedMessage = [textField.text stringByReplacingCharactersInRange:range withString:string];
    [self updateMessageSendingInterfaceWithMessage:inputtedMessage];


    return YES;
}


#pragma mark - UITableView delegate methods

/**
 * Retrieve from delegate title of delete confirmation button from delegate
 * for table at specified index path
 */
- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {

    return @"Unsubscribe";
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    return [self.channelsTableView isEqual:tableView]?indexPath:nil;
}

/**
 * UITableView by calling this method notify delegate about that user selected
 * one of table rows
 */
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    // Check whether user selected item from table with channels list or not
    if ([self.channelsTableView isEqual:tableView]) {

        // Update current channel in data modelmanager
        PNChannel *channel = [[PNDataManager sharedInstance].subscribedChannelsList objectAtIndex:indexPath.row];
        [PNDataManager sharedInstance].currentChannel = channel;
    }
}


#pragma mark UITableView data source delegate methods

/**
 * Retrieve from data source delegate number of rows for table in
 * specified section
 */
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    NSInteger numberOfRows = 0;

    if ([tableView isEqual:self.channelsTableView]) {

        numberOfRows = [[PNDataManager sharedInstance].subscribedChannelsList count];
    }
    else {

        numberOfRows = [[PNDataManager sharedInstance].currentChannel.participants count];
    }

    return numberOfRows;
}

/**
 * Retrieve cached instance or create new cell row instance for data
 * layout at specified index path
 */
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    // Initialize possible cell identifiers
    static NSString *cellIdentifier = @"simpleCell";

    // Try retrieve reference on cached instance
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];

    // Check whether cached instance copy retrieved or not
    if(cell == nil) {

        // Create new cell instance copy
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier: cellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.textLabel.shadowColor = [UIColor blackColor];
        cell.textLabel.shadowOffset = CGSizeMake(0.0f, -1.0f);
    }

    if ([tableView isEqual:self.channelsTableView]) {

        PNChannel *channel = [[PNDataManager sharedInstance].subscribedChannelsList objectAtIndex:indexPath.row];
        cell.textLabel.text = channel.name;
    }
    else {

        NSString *clientIdentifier = [[PNDataManager sharedInstance].currentChannel.participants objectAtIndex:indexPath.row];
        if (!PNIsUserGeneratedUUID(clientIdentifier)) {

            clientIdentifier = @"anonymous";
        }
        cell.textLabel.text = clientIdentifier;
    }

    return cell;
}

/**
 * UITableView by calling this method asks data source delegate
 * whether it allow to edit row at specified index path or not
 */
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {

    return [tableView isEqual:self.channelsTableView];
}

- (void)tableView:(UITableView *)tableView
        commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
        forRowAtIndexPath:(NSIndexPath *)indexPath {

    if (editingStyle == UITableViewCellEditingStyleDelete) {

        PNChannel *channel = [[PNDataManager sharedInstance].subscribedChannelsList objectAtIndex:indexPath.row];
        if ([channel isEqual:[PNDataManager sharedInstance].currentChannel]) {

            [PNDataManager sharedInstance].currentChannel = nil;
        }

        [PubNub unsubscribeFromChannel:channel];
    }
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

    [[PNDataManager sharedInstance] removeObserver:self forKeyPath:@"currentChannel"];
    [[PNDataManager sharedInstance] removeObserver:self forKeyPath:@"subscribedChannelsList"];
}

#pragma mark -


@end
