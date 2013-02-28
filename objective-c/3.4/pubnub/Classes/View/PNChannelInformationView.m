//
//  PNChannelInformationView.h
// 
//
//  Created by moonlight on 1/21/13.
//
//


#import "PNChannelInformationView.h"
#import "PNDataManager.h"


#pragma mark Private interface methods

@interface PNChannelInformationView ()


#pragma mark - Properties

// Stores reference on channels information section background image
@property (nonatomic, pn_desired_weak) IBOutlet UIImageView *channelsInformationBackgroundImageView;

@property (nonatomic, pn_desired_weak) IBOutlet UILabel *channelPresenceUpdateDateLabel;
@property (nonatomic, pn_desired_weak) IBOutlet UILabel *channelParticipantsCountLabel;
@property (nonatomic, pn_desired_weak) IBOutlet UILabel *channelNameLabel;

// Stores reference on button which allow to configure
// history viewing option
@property (nonatomic, pn_desired_weak) IBOutlet UIButton *channelHistoryButton;

// Stores reference on original view frame
// (hidden under chat)
@property (nonatomic, assign) CGRect originalViewFrame;


#pragma mark - Instance methods

#pragma mark - Interface customization methods

- (void)prepareInterface;

/**
 * Help to present view and hide it
 */
- (void)showAnimated:(BOOL)animated;
- (void)hideAnimated:(BOOL)animated;


#pragma mark - Handler methods

- (IBAction)historyButtonTapped:(id)sender;


#pragma mark - Misc methods

- (void)updateLayoutForChannel:(PNChannel *)channel;


@end


#pragma mark - Public interface methods

@implementation PNChannelInformationView


#pragma mark - Instance methods

- (void)awakeFromNib {

    // Forward to the super class
    [super awakeFromNib];


    // Loading view elements from NIB
    NSArray *elements = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:self options:nil];
    for (UIView *subview in elements) {

        [self addSubview:subview];
    }


    [self prepareInterface];
    [self hideAnimated:NO];

    // Subscribe for selected channel observing
    [[PNDataManager sharedInstance] addObserver:self
                                     forKeyPath:@"currentChannel"
                                        options:(NSKeyValueObservingOptionNew)
                                        context:nil];

    [[PNObservationCenter defaultCenter] addChannelParticipantsListProcessingObserver:self
                                                                                withBlock:^(NSArray *participants,
                                                                                            PNChannel *channel,
                                                                                            PNError *fetchError) {

                                [self updateLayoutForChannel:channel];
                            }];
}


#pragma mark - Interface customization methods

- (void)prepareInterface {

    UIImage *rightSectionImage = [UIImage imageNamed:@"right-section-header-background"];
    UIImage *stretchedRightSectionImage = [rightSectionImage stretchableImageWithLeftCapWidth:10.0f
                                                                                 topCapHeight:10.0f];
    UIImage *whiteButtonImage = [UIImage imageNamed:@"white-button"];
    UIImage *stretchedWhiteButtonImageImage = [whiteButtonImage stretchableImageWithLeftCapWidth:5.0f
                                                                                    topCapHeight:10.0f];

    self.channelsInformationBackgroundImageView.image = stretchedRightSectionImage;
    [self.channelHistoryButton setBackgroundImage:stretchedWhiteButtonImageImage forState:UIControlStateNormal];

    self.originalViewFrame = self.frame;
}

- (void)showAnimated:(BOOL)animated {

    [UIView animateWithDuration:animated ? 0.3f : 0.0f
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{

                         self.frame = self.originalViewFrame;
                     }
                     completion:NULL];
}

- (void)hideAnimated:(BOOL)animated {

    CGRect targetFrame = CGRectFromString(NSStringFromCGRect(self.originalViewFrame));
    targetFrame.origin.x -= targetFrame.size.width;

    [UIView animateWithDuration:animated ? 0.3f : 0.0f
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{

                         self.frame = targetFrame;
                     }
                     completion:NULL];
}


#pragma mark - Handler methods

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {

    id currentChannel = [change valueForKey:NSKeyValueChangeNewKey];
    if(![currentChannel isKindOfClass:[NSNull class]]) {

        [self updateLayoutForChannel:currentChannel];
        [self showAnimated:YES];
    }
    else {

        [self hideAnimated:YES];
    }
}

- (IBAction)historyButtonTapped:(id)sender {

    [self.delegate showHistoryRequestParameters];
}


#pragma mark - Misc methods

- (void)updateLayoutForChannel:(PNChannel *)channel {

    self.channelNameLabel.text = channel.name;
    self.channelParticipantsCountLabel.text = [NSString stringWithFormat:@"%u", channel.participantsCount];

    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    [dateFormatter setDateFormat:@"hh:mm:ss MM/dd/yy"];

    if (channel.presenceUpdateDate) {

        self.channelPresenceUpdateDateLabel.text = [dateFormatter stringFromDate:channel.presenceUpdateDate];
    }
    else {

        self.channelPresenceUpdateDateLabel.text = @"no updates";
    }
}


#pragma mark - Memory management

- (void)dealloc {

    [[PNObservationCenter defaultCenter] removeChannelParticipantsListProcessingObserver:self];
    [[PNDataManager sharedInstance] removeObserver:self forKeyPath:@"currentChannel"];
}

#pragma mark -


@end