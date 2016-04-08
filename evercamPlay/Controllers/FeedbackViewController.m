//
//  FeedbackViewController.m
//  evercamPlay
//
//  Created by jw on 3/10/15.
//  Copyright (c) 2015 evercom. All rights reserved.
//

#import "FeedbackViewController.h"
#import "SWRevealViewController.h"
#import "AppDelegate.h"
#import <MessageUI/MessageUI.h>
#import "SendGrid.h"
#import "SendGridEmail.h"
#import "NetworkUtil.h"

@interface FeedbackViewController () <MFMailComposeViewControllerDelegate>
{
    UITextField *activeTextField;
    CAGradientLayer *gradient;
}
@end

@implementation FeedbackViewController
@synthesize isFromLiveCameraView;
- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.screenName = @"Feedback Page";
    // Do any additional setup after loading the view from its nib.
    
    gradient = [CAGradientLayer layer];
    gradient.frame = self.contentView.bounds;
    gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor blackColor] CGColor], (id)[[UIColor colorWithRed:39.0/255.0 green:45.0/255.0 blue:51.0/255.0 alpha:1.0] CGColor], nil];
    [self.contentView.layer insertSublayer:gradient atIndex:0];
    
//    self.contentView.backgroundColor = [UIColor colorWithRed:39.0/255.0 green:45.0/255.0 blue:51.0/255.0 alpha:1.0];
    
    if ([self.txt_username respondsToSelector:@selector(setAttributedPlaceholder:)]) {
        UIColor *color = [UIColor lightTextColor];
        self.txt_username.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Username" attributes:@{NSForegroundColorAttributeName: color}];
        self.txt_email.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Email" attributes:@{NSForegroundColorAttributeName: color}];
        self.txt_feedback.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Write your feedback" attributes:@{NSForegroundColorAttributeName: color}];
    } else {
        NSLog(@"Cannot set placeholder text's color, because deployment target is earlier than iOS 6.0");
        // TODO: Add fall-back code to set placeholder color.
    }

    if ([APP_DELEGATE defaultUser]) {
        self.txt_username.text = [NSString stringWithFormat:@"%@ %@", [APP_DELEGATE defaultUser].firstName, [APP_DELEGATE defaultUser].lastName];
        self.txt_email.text = [APP_DELEGATE defaultUser].email;
    }
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    CustomNavigationController* cVC = [APP_DELEGATE viewController];
    [cVC setHasLandscapeMode:YES];
    [UIViewController attemptRotationToDeviceOrientation];
}

-(void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    gradient.frame = self.contentView.bounds;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)BackPressed:(id)sender {
    if (isFromLiveCameraView) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (IBAction)onSend:(id)sender
{
    NSString *feedback = _txt_feedback.text;
    
    if ([feedback stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length <= 0)
    {
        UIAlertView *simpleAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"evercamPlay", nil) message:NSLocalizedString(@"Please provide some feedback to send.", nil) delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        simpleAlert.tag = 101;
        [simpleAlert show];
        return;
    }
    
    NSString *fullName = @"";
    NSString *userEmail = @"";
    AppUser *user = [APP_DELEGATE defaultUser];
    if (user) {
        fullName = [NSString stringWithFormat:@"%@ %@", user.firstName, user.lastName];
        userEmail = user.email;
    }
    
    NSDictionary *infoDictionary = [[NSBundle mainBundle]infoDictionary];
    NSString *version = infoDictionary[(NSString*)@"CFBundleShortVersionString"];
    
    NSString* plistPath = [[NSBundle mainBundle] pathForResource:@"local" ofType:@"plist"];
    if (plistPath != nil) {
        
        NSDictionary *contents = [NSDictionary dictionaryWithContentsOfFile:plistPath];
        NSString *username = [contents valueForKey:@"SendgridUsername"];
        NSString *password = [contents valueForKey:@"SendgridPassword"];
        
        SendGrid *sendgrid = [SendGrid apiUser:username apiKey:password];
        
        SendGridEmail *email = [[SendGridEmail alloc] init];
        email.to = @"play@evercam.io";
        email.from = userEmail;
        email.subject = @"Evercam Play Feedback - iOS";
        email.html = [NSString stringWithFormat:@"%@ says: <br><br>%@<br><br>App Version: %@<br>Device: %@<br>iOS Version: %@<br>Network: %@",
                      fullName,
                      feedback,
                      version,
                      [UIDevice currentDevice].name,
                      [UIDevice currentDevice].systemVersion,
                      [NetworkUtil getNetworkString]];
        if (self.cameraID) {
            email.html = [email.html stringByAppendingFormat:@"<br>Camera ID: %@", self.cameraID];
        }
        
        [sendgrid sendWithWeb:email];
        
        UIAlertView *simpleAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"evercamPlay", nil) message:NSLocalizedString(@"Thanks for the feedback", nil) delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        simpleAlert.tag = 101;
        [simpleAlert show];
    }
}

#pragma mark UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{    
    [textField resignFirstResponder];
    if (textField == self.txt_username)
    {
        [self.txt_email becomeFirstResponder];
    }
    else if (textField == self.txt_email)
    {
        [self.txt_feedback becomeFirstResponder];
    }
    
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    activeTextField = textField;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    activeTextField = nil;
}

#pragma mark - Keyboard Event Functions
- (void)keyboardWillHide:(NSNotification *)notif {
    UIViewAnimationCurve curve = [[[notif userInfo] objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue];
    NSTimeInterval duration = [[[notif userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    [UIView beginAnimations:@"resize" context:nil];
    [UIView setAnimationDuration:duration];
    [UIView setAnimationCurve:curve];
    [UIView setAnimationBeginsFromCurrentState:TRUE];
    
    // Move view
    [_contentView setContentOffset:CGPointZero animated:YES];
    
    [UIView commitAnimations];
}

- (void)keyboardWillShow:(NSNotification *)notif {
    CGRect endFrame = [[[notif userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    UIViewAnimationCurve curve = [[[notif userInfo] objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue];
    NSTimeInterval duration = [[[notif userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    [UIView beginAnimations:@"resize" context:nil];
    [UIView setAnimationDuration:duration];
    [UIView setAnimationCurve:curve];
    [UIView setAnimationBeginsFromCurrentState:TRUE];
    
    if(([[UIDevice currentDevice].systemVersion floatValue] < 8) &&
       UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)) {
        int width = endFrame.size.height;
        endFrame.size.height = endFrame.size.width;
        endFrame.size.width = width;
    }
    
    CGRect frame = self.view.frame;
    frame.size.height -= endFrame.size.height;
    CGPoint fOrigin = activeTextField.frame.origin;
    fOrigin.y -= _contentView.contentOffset.y;
    fOrigin.y += _contentView.frame.origin.y;
    fOrigin.y += activeTextField.frame.size.height;
    if (!CGRectContainsPoint(frame, fOrigin) ) {
        CGPoint scrollPoint = CGPointMake(0.0, activeTextField.frame.origin.y + activeTextField.frame.size.height - frame.size.height + _contentView.frame.origin.y);
        [_contentView setContentOffset:scrollPoint animated:YES];
    }
    
    [UIView commitAnimations];
}

#pragma mark - UIAlertViewDelegate Method
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 101) {
        _txt_feedback.text = @"";
    }
}

@end