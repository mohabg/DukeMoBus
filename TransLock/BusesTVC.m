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

@interface BusesTVC ()

@property (nonatomic, strong) NSMutableDictionary * busIDsToNames;
@property (nonatomic, strong) NSMutableArray * busNames;
@property (nonatomic, strong) NSMutableArray * busIDs;
@property (nonatomic, strong) NSMutableArray * chosenBusIDs;

@end

@implementation BusesTVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    
    self.busNames = [[NSMutableArray alloc] init];
    self.busIDs = [[NSMutableArray alloc] init];
    self.chosenBusIDs = [NSKeyedUnarchiver unarchiveObjectWithFile:[self getArchivePathUsingString:@"chosenBusIDs.archive"]];
    self.busIDsToNames = [NSKeyedUnarchiver unarchiveObjectWithFile:[self getArchivePathUsingString:@"busIDsToNames.archive"]];
    if(!self.chosenBusIDs){
        self.chosenBusIDs = [[NSMutableArray alloc] init];
    }
    if(!self.busIDsToNames){
        self.busIDsToNames = [[NSMutableDictionary alloc] init];
    }
    void (^busesCompletionBlock)(NSDictionary *, int) = ^void(NSDictionary * jsonData, int index){
        for(NSDictionary * dictionary in [[jsonData objectForKey:@"data"] objectForKey:@"176"]){
            [_busNames addObject:[dictionary objectForKey:@"long_name"]];
            [_busIDs addObject:[dictionary objectForKey:@"route_id"]];
            [self.busIDsToNames setObject:[dictionary objectForKey:@"long_name"] forKey:[dictionary objectForKey:@"route_id"]];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    };
    APIHandler * handler = [[APIHandler alloc] init];
    [handler parseJsonWithRequest:[handler createRouteRequest] CompletionBlock:busesCompletionBlock Index:0];
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
    
    return [self.busNames count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    cell.textLabel.text = [self.busNames objectAtIndex:indexPath.row];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if([self.chosenBusIDs containsObject:[self.busIDs objectAtIndex:indexPath.row]]){
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString * currentBusID = [self.busIDs objectAtIndex:indexPath.row];
    UITableViewCell * cell = [self.tableView cellForRowAtIndexPath:indexPath];
    if([self.chosenBusIDs containsObject:currentBusID]){
        [self.chosenBusIDs removeObject:currentBusID];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    else{
        [self.chosenBusIDs addObject:currentBusID];
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
}
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    MainVC * mainController = (MainVC *) [segue destinationViewController];
    mainController.allowedBusIDs = self.chosenBusIDs;
    mainController.busIDsToNames = self.busIDsToNames;
}

-(NSString *)getArchivePathUsingString:(NSString *)path{
    NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    return [[paths objectAtIndex:0] stringByAppendingPathComponent:path];
    
}
@end
