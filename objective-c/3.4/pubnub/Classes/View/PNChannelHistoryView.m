//
//  PNChannelHistoryView.h
// 
//
//  Created by moonlight on 1/21/13.
//
//


#import "PNChannelHistoryView.h"
#import "PNDataManager.h"
#import "PNMessage.h"
#import "PNMessage+Protected.h"


#pragma mark Private interface methods

@interface PNChannelHistoryView () <UITextFieldDelegate, UIPopoverControllerDelegate>


#pragma mark - Properties

// Stores reference on traverse mode switch
@property (nonatomic, pn_desired_weak) IBOutlet UISwitch *traverseSwitch;

// Stores reference on text view which is used to layout list of messages
@property (nonatomic, pn_desired_weak) IBOutlet UITextView *historyTextView;

// Stores reference on text field which is responsible for start
// date input
@property (nonatomic, pn_desired_weak) IBOutlet UITextField *startDateTextField;

// Stores reference on text field which is responsible for end
// date input
@property (nonatomic, pn_desired_weak) IBOutlet UITextField *endDateTextField;

// Stores reference on text field which is responsible for messages limit
// input
@property (nonatomic, pn_desired_weak) IBOutlet UITextField *limitTextField;

@property (nonatomic, pn_desired_weak) IBOutlet UIButton *closeButton;
@property (nonatomic, pn_desired_weak) IBOutlet UIButton *downloadButton;
@property (nonatomic, pn_desired_weak) IBOutlet UIButton *clearButton;

// Stores on whether we are changing start date value or not
@property (nonatomic, assign, getter = isConfiguringStartDate) BOOL configuringStartDate;

// Stores reference on popover controller which is used to show
// time frame selection date picker
@property (nonatomic, strong) UIPopoverController *datePickerPopoverController;

// Stores reference on history time frame dates
@property (nonatomic, strong) NSDate *startDate;
@property (nonatomic, strong) NSDate *endDate;


#pragma mark - Interface customization

- (void)prepareInterface;
- (void)updateInterface;

#pragma mark - Handler methods

- (IBAction)closeButtonTapped:(id)sender;
- (IBAction)clearButtonTapped:(id)sender;
- (IBAction)downloadButtonTapped:(id)sender;
- (void)datePickerChangedValue:(id)sender;


#pragma mark - Misc methods

/**
 * Show date picker for one of time frame selection fields
 */
- (void)showDatePicker;


@end


#pragma mark Public interface methods

@implementation PNChannelHistoryView


#pragma mark - Class methods

+ (id)viewFromNib {

    return [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:nil options:nil] lastObject];
}

#pragma mark - Interface customization

- (void)awakeFromNib {

    // Forward to the super class to complete initialization
    [super awakeFromNib];

    [self prepareInterface];


    [[PNObservationCenter defaultCenter] addMessageHistoryProcessingObserver:self
                                                                   withBlock:^(NSArray *messages,
                                                                               PNChannel *channel,
                                                                               NSDate *startDate,
                                                                               NSDate *endDate,
                                                                               PNError *error) {

               NSString *message = nil;
               if (error == nil) {

                   NSDateFormatter *dateFormatter = [NSDateFormatter new];
                   dateFormatter.dateFormat = @"HH:mm:ss MM/dd/yy";

                   message = [NSString stringWithFormat:@"Downloaded history for: %@\nDownloaded %u messages\nStart date: %@\nEnd date: %@",
                                                        channel.name, [messages count],
                                                        [dateFormatter stringFromDate:startDate],
                                                        [dateFormatter stringFromDate:endDate]];
               }
               else {

                   message = [NSString stringWithFormat:@"History download failed with error: %@\nReason: %@\nSolution: %@",
                                                        error.localizedDescription,
                                                        error.localizedFailureReason,
                                                        error.localizedRecoverySuggestion];
               }


               UIAlertView *alertView = [UIAlertView new];
               alertView.title = @"History";
               alertView.message = message;
               [alertView addButtonWithTitle:@"OK"];
               [alertView show];
           }];
}

- (void)prepareInterface {

    UIImage *redButtonBackground = [UIImage imageNamed:@"red-button.png"];
    UIImage *stretchableButtonBackground = [redButtonBackground stretchableImageWithLeftCapWidth:5.0f
                                                                                    topCapHeight:5.0f];
    UIImage *whiteButtonBackground = [UIImage imageNamed:@"white-button.png"];
    UIImage *stretchableWhiteButtonBackground = [whiteButtonBackground stretchableImageWithLeftCapWidth:5.0f
                                                                                           topCapHeight:5.0f];
    [self.closeButton setBackgroundImage:stretchableButtonBackground forState:UIControlStateNormal];
    [self.downloadButton setBackgroundImage:stretchableButtonBackground forState:UIControlStateNormal];
    [self.clearButton setBackgroundImage:stretchableWhiteButtonBackground forState:UIControlStateNormal];

    self.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background"]];
}

- (void)updateInterface {

    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    dateFormatter.dateFormat = @"HH:mm:ss MM/dd/yy";

    self.startDateTextField.text = [dateFormatter stringFromDate:self.startDate];
    self.endDateTextField.text = [dateFormatter stringFromDate:self.endDate];
}


#pragma mark - Handler methods

- (IBAction)closeButtonTapped:(id)sender {

    [[PNObservationCenter defaultCenter] removeMessageHistoryProcessingObserver:self];
    [self removeFromSuperview];
}

- (IBAction)clearButtonTapped:(id)sender {

    self.startDate = nil;
    self.endDate = nil;

    [self updateInterface];
}

- (IBAction)downloadButtonTapped:(id)sender {

    PNChannelHistoryView *weakSelf = self;
    [PubNub requestHistoryForChannel:[PNDataManager sharedInstance].currentChannel
                                from:self.startDate
                                  to:self.endDate
                               limit:[self.limitTextField.text integerValue]
                 withCompletionBlock:^(NSArray *messages,
                                       PNChannel *channel,
                                       NSDate *startDate,
                                       NSDate *endDate,
                                       PNError *error) {

                     NSMutableString *historyToShow = [NSMutableString string];
                     [messages enumerateObjectsUsingBlock:^(PNMessage *message,
                                                            NSUInteger messageIdx,
                                                            BOOL *messagesEnumerator) {

                         [historyToShow appendFormat:@"> %@\n", message.message];
                     }];
                     weakSelf.historyTextView.text = historyToShow;
                 }];
}

- (void)datePickerChangedValue:(id)sender {

    if (self.isConfiguringStartDate) {

        self.startDate = ((UIDatePicker *)sender).date;
    }
    else {

        self.endDate = ((UIDatePicker *)sender).date;
    }


    [self updateInterface];
}


#pragma mark - Misc methods

- (void)showDatePicker {


    UIDatePicker *datePicker = [[UIDatePicker alloc] init];
    datePicker.datePickerMode = UIDatePickerModeDateAndTime;
    [datePicker addTarget:self action:@selector(datePickerChangedValue:) forControlEvents:UIControlEventValueChanged];


    UIViewController *datePickerViewController = [UIViewController new];
    CGSize sizeInPopover = datePicker.bounds.size;
    sizeInPopover.height -= 44.0f;
    datePickerViewController.view = datePicker;
    datePickerViewController.contentSizeForViewInPopover = sizeInPopover;

    CGRect targetFrame = self.isConfiguringStartDate ? self.startDateTextField.frame : self.endDateTextField.frame;
    self.datePickerPopoverController = [[UIPopoverController alloc] initWithContentViewController:datePickerViewController];
    self.datePickerPopoverController.delegate = self;
    [self.datePickerPopoverController presentPopoverFromRect:targetFrame
                                       inView:self
                     permittedArrowDirections:UIPopoverArrowDirectionUp
                                     animated:YES];
}


#pragma mark - UIPopoverController delegate methods

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController {

    self.datePickerPopoverController = nil;
}


#pragma mark - UITextField delegate methods

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {

    BOOL shouldShowDatePiker = ![textField isEqual:self.limitTextField];
    self.configuringStartDate = [textField isEqual:self.startDateTextField];

    if (shouldShowDatePiker) {

        [self showDatePicker];
    }


    return !shouldShowDatePiker;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {

    [self endEditing:YES];


    return YES;
}

#pragma mark -


@end