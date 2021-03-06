//
//  AllDevicesViewController.m
//  evercamPlay
//
//  Created by Zulqarnain on 6/2/16.
//  Copyright © 2016 evercom. All rights reserved.
//

#import "AllDevicesViewController.h"
#import "AllDevicesCell.h"
#import "GlobalSettings.h"
#import "Device.h"
#import "ReportCameraViewController.h"
@interface AllDevicesViewController ()

@end

@implementation AllDevicesViewController
@synthesize devicesArray;
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self.deviceTable registerNib:[UINib nibWithNibName:([GlobalSettings sharedInstance].isPhone)?@"AllDevicesCell":@"AllDevicesCell_iPad" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"Cell"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.devicesArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    tableView.backgroundColor  = [UIColor clearColor];
    AllDevicesCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    if (cell == nil) {
        cell = [[AllDevicesCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    }
    cell.backgroundColor        = [UIColor clearColor];
    Device *device              = [self.devicesArray objectAtIndex:indexPath.row];
    cell.ipAddress_Lbl.text     = device.address;
    cell.macAddress_Lbl.text    = device.mac_Address;
    cell.deviceName_Lbl.text    = device.name;
    cell.reportBtn.tag          = indexPath.row + 100;
    [cell.reportBtn addTarget:self action:@selector(reportACamera:) forControlEvents:UIControlEventTouchUpInside];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(void)reportACamera:(UIButton *)button{
    
    ReportCameraViewController *aVC = [[ReportCameraViewController alloc] initWithNibName:([GlobalSettings sharedInstance].isPhone)?@"ReportCameraViewController":@"ReportCameraViewController_iPad" bundle:[NSBundle mainBundle]];
    if (![GlobalSettings sharedInstance].isPhone) {
        aVC.modalPresentationStyle = UIModalPresentationFormSheet;
    }
    ([GlobalSettings sharedInstance].isPhone)? [self.navigationController pushViewController:aVC animated:YES]:[self presentViewController:aVC animated:YES completion:NULL];
}

- (IBAction)backAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
@end
