//
//  BusesTVC.m
//  TransLock
//
//  Created by Mohab Gabal on 6/1/16.
//  Copyright © 2016 Mohab Gabal. All rights reserved.
//

#import "BusesTVC.h"
#import "APIHandler.h"
#import "MainVC.h"
#import "BusVehicle.h"

@interface BusesTVC ()


@end

@implementation BusesTVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"ClearTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"ClearCell"];
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    [self.navigationController.navigationBar setTranslucent:YES];
    
    APIHandler * handler = [[APIHandler alloc] init];
    [handler parseJsonWithRequest:[handler createRouteRequest] CompletionBlock:^(NSDictionary * jsonData){
        for(NSDictionary * dictionary in [[jsonData objectForKey:@"data"] objectForKey:@"176"]){
            [self.busData.idToBusNames setObject:[dictionary objectForKey:@"long_name"] forKey:[dictionary objectForKey:@"route_id"]];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [self.busData.idToBusNames count];
}


//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
//    
//    ClearTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"ClearCell" forIndexPath:indexPath];
//    
//    cell.textLabel.text = [[self.busData.idToBusNames allValues ]objectAtIndex:indexPath.row];
//    
//    cell.selectionStyle = UITableViewCellSelectionStyleNone;
//    
//    if([self.busData.allowedBusIDs containsObject:[[self.busData.idToBusNames allKeys] objectAtIndex:indexPath.row]]){
//        [cell setSelected];
//    }
//    
//    return cell;
//}
//-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
//    NSString * busID = [[ self.busData.idToBusNames allKeys]objectAtIndex:indexPath.row];
//    ClearTableViewCell * cell = [self.tableView cellForRowAtIndexPath:indexPath];
//    if([self.busData.allowedBusIDs containsObject:busID]){
//        [self.busData.allowedBusIDs removeObject:busID];
//        [cell setDeSelected];
//    }
//    else{
//        [self.busData.allowedBusIDs addObject:busID];
//        [cell setSelected];
//    }
//}
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    MainVC * mainController = (MainVC *) [segue destinationViewController];
    mainController.busData = self.busData;
}

@end
