//
//  VendorAndModelViewController.h
//  evercamPlay
//
//  Created by Zulqarnain on 6/8/16.
//  Copyright © 2016 evercom. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Device.h"
@class TPKeyboardAvoidingScrollView;
@interface VendorAndModelViewController : UIViewController{
    NSString *vendorIdentifier;
    Device *scanned_Device;
}
@property (nonatomic,strong) Device *scanned_Device;;
@property (nonatomic,strong) NSString *vendorIdentifier;
@property (weak, nonatomic) IBOutlet UIButton *modelBtn;
@property (weak, nonatomic) IBOutlet UIButton *vendorBtn;
@property (weak, nonatomic) IBOutlet UIImageView *cameraImage;
@property (weak, nonatomic) IBOutlet UIImageView *vendorImageView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loading_ActivityIndicator;
@property (weak, nonatomic) IBOutlet TPKeyboardAvoidingScrollView *contentScrollView;
- (IBAction)vendorAction:(id)sender;
- (IBAction)modelAction:(id)sender;
- (IBAction)backAction:(id)sender;
- (IBAction)reportModel:(id)sender;
- (IBAction)connectCamera:(id)sender;

@end
