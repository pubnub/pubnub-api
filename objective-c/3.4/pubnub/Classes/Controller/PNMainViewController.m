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
#import <CoreGraphics/CoreGraphics.h>
#import <QuartzCore/QuartzCore.h>
#import "PNDataManager.h"
#import "PNMacro.h"


#pragma mark Private interface methods

@interface PNMainViewController () <UITableViewDelegate, UITableViewDataSource>


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

// Stores reference on channels information section background image
@property (nonatomic, pn_desired_weak) IBOutlet UIImageView *channelsInformationBackgroundImageView;

// Stores reference on button which allow to subscribe on new channel
@property (nonatomic, pn_desired_weak) IBOutlet UIButton *addChannelButton;

@property (nonatomic, pn_desired_weak) IBOutlet UIButton *disconnectButton;

@property (nonatomic, pn_desired_weak) IBOutlet UIButton *clientInformationButton;

// Stores reference on utility panel background view
@property (nonatomic, pn_desired_weak) IBOutlet UIView *utilityPanelBackgroundView;

// Stores reference on channel information holding view
@property (nonatomic, pn_desired_weak) IBOutlet UIView *channelInformationView;

// Stores reference on button which allow to configure
// history viewing option
@property (nonatomic, pn_desired_weak) IBOutlet UIButton *channelHistoryButton;


#pragma mark - Instance methods

#pragma mark - Interface customization

- (void)prepareInterface;


#pragma mark - Handler methods

- (IBAction)disconnectButtonTapped:(id)sender;
- (IBAction)clientInformationButtonTapper:(id)sender;
- (IBAction)addChannelButtonTapped:(id)sender;
- (IBAction)channelHistoryButtonTapped:(id)sender;


#pragma mark - Misc methods

- (void)showChannelInformationForChannel:(PNChannel *)channel;
- (void)hideChannelInformation;


@end


#pragma mark - Public interface methods

@implementation PNMainViewController


#pragma mark - Instance methods

- (void)viewDidLoad {
    
    // Forward to the super class to complete all initializations
    [super viewDidLoad];


    [self prepareInterface];


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

    self.channelsInformationBackgroundImageView.image = stretchedRightSectionImage;



    UIImage *whiteButtonImage = [UIImage imageNamed:@"white-button"];
    UIImage *stretchedWhiteButtonImageImage = [whiteButtonImage stretchableImageWithLeftCapWidth:5.0f
                                                                                    topCapHeight:10.0f];

    UIImage *redButtonImage = [UIImage imageNamed:@"red-button"];
    UIImage *stretchedRedButtonImageImage = [whiteButtonImage stretchableImageWithLeftCapWidth:5.0f
                                                                                  topCapHeight:10.0f];

    [self.addChannelButton setBackgroundImage:stretchedWhiteButtonImageImage forState:UIControlStateNormal];
    [self.channelHistoryButton setBackgroundImage:stretchedWhiteButtonImageImage forState:UIControlStateNormal];
    [self.disconnectButton setBackgroundImage:stretchedRightSingleEntryImage forState:UIControlStateNormal];

    [self.clientInformationButton setBackgroundImage:stretchedRightSingleEntryImage forState:UIControlStateNormal];
    [self.clientInformationButton setTitle:[PubNub clientIdentifier] forState:UIControlStateNormal];
}


#pragma mark - Handler methods

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {

    // Check whether current category changed or not
    if ([keyPath isEqualToString:@"currentChannel"]) {

        NSLog(@"UPDATE CHANNEL INFORMATION AND CHAT");
    }
    // Looks like list of channels changed
    else {

        [self.channelsTableView reloadData];
    }
}

- (IBAction)disconnectButtonTapped:(id)sender {

    [PubNub disconnect];
    [self dismissModalViewControllerAnimated:YES];
}
- (IBAction)clientInformationButtonTapper:(id)sender {

}

- (IBAction)addChannelButtonTapped:(id)sender {

}

- (IBAction)channelHistoryButtonTapped:(id)sender {

}


#pragma mark - Misc methods

- (void)showChannelInformationForChannel:(PNChannel *)channel {

}

- (void)hideChannelInformation {

}


#pragma mark - UITableView delegate methods

/**
 * Retrieve from delegate title of delete confirmation button from delegate
 * for table at specified index path
 */
- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {

    return @"Unsubscribe";
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

    return 0;
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
    }

    if ([tableView isEqual:self.channelsTableView]) {

        PNChannel *channel = [[PNDataManager sharedInstance].subscribedChannelsList objectAtIndex:indexPath.row];
        cell.textLabel.text = channel.name;
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


#pragma mark -


@end
