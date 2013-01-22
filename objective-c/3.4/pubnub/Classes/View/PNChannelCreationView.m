//
//  PNChannelCreationView.h
// 
//
//  Created by moonlight on 1/21/13.
//
//


#import <QuartzCore/QuartzCore.h>
#import "PNChannelCreationView.h"


#pragma mark Private interface methods

@interface PNChannelCreationView () <UITextFieldDelegate>


#pragma mark Properties

// Stores reference on channel name input text field
@property (nonatomic, pn_desired_weak) IBOutlet UITextField *channelName;

// Stores reference on switch which allow to enable
// presence observation for new channel
@property (nonatomic, pn_desired_weak) IBOutlet UISwitch *presenceSwitch;

@property (nonatomic, pn_desired_weak) IBOutlet UIButton *subscribeButton;
@property (nonatomic, pn_desired_weak) IBOutlet UIButton *closeButton;


#pragma mark - Instance methods

#pragma mark - Interface customization

- (void)prepareInterface;


#pragma mark - Handler methods

- (IBAction)subscribeButtonTapped:(id)sender;
- (IBAction)closeButtonTapped:(id)sender;


@end


#pragma mark Public interface methods

@implementation PNChannelCreationView


#pragma mark - Class methods

+ (id)viewFromNib {

    return [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:nil options:nil] lastObject];
}


#pragma mark - Instance methods

- (void)awakeFromNib {

    // Forward to the super class to complete intialization
    [super awakeFromNib];

    [self prepareInterface];
}

#pragma mark - Interface customization

- (void)prepareInterface {

    UIImage *stretchableButtonBackground = [[UIImage imageNamed:@"red-button.png"] stretchableImageWithLeftCapWidth:5.0f
                                                                                               topCapHeight:5.0f];
    [self.subscribeButton setBackgroundImage:stretchableButtonBackground forState:UIControlStateNormal];
    [self.closeButton setBackgroundImage:stretchableButtonBackground forState:UIControlStateNormal];

    self.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background"]];
}


#pragma mark - Handler methods

- (IBAction)subscribeButtonTapped:(id)sender {

    PNChannel *channel = [PNChannel channelWithName:self.channelName.text
                              shouldObservePresence:self.presenceSwitch.isOn];
    [self.delegate creationView:self subscribeOnChannel:channel];
    [self removeFromSuperview];
}

- (IBAction)closeButtonTapped:(id)sender {

    [self removeFromSuperview];
}


#pragma mark - UITextField delegate methods

- (BOOL)            textField:(UITextField *)textField
shouldChangeCharactersInRange:(NSRange)range
            replacementString:(NSString *)string {

    NSString *channelName = [textField.text stringByReplacingCharactersInRange:range withString:string];
    BOOL entered = [[channelName stringByReplacingOccurrencesOfString:@" " withString:@""] length] > 0;
    self.subscribeButton.enabled = entered;


    return YES;
}


#pragma mark -


@end