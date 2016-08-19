//
//  BusData.m
//  TransLock
//
//  Created by Mohab Gabal on 5/31/16.
//  Copyright © 2016 Mohab Gabal. All rights reserved.
//

#import "BusData.h"
#import "SharedMethods.h"

@interface BusData ()

@property (nonatomic, strong) NSMutableArray<BusStop*> * nearbyBusStops;
@property (nonatomic, strong) NSMutableArray<BusStop*> * favoriteStops;
@property (nonatomic, strong) NSMutableDictionary * idToBusNames;

@end


@implementation BusData

-(instancetype)init{
    self = [super init];
    if(self){
        self.nearbyBusStops = [[NSMutableArray alloc] init];
        self.idToBusNames = [[NSMutableDictionary alloc] init];
        self.favoriteStops = [NSKeyedUnarchiver unarchiveObjectWithFile:[SharedMethods getArchivePathUsingString:@"favoriteStops.archive"]];
        
        if(!self.favoriteStops){
            self.favoriteStops = [[NSMutableArray alloc] init];
        }
    }
    return self;
}

-(void)addFavoriteStop:(BusStop *)favoriteStop{
    
    [self.favoriteStops addObject:favoriteStop];
}

-(void)removeFavoriteStop:(BusStop *)favoriteStop{
    
    [self.favoriteStops removeObject:favoriteStop];
}

-(void)setBusName:(NSString *)busName ForBusId:(NSString *)busId{
    
    [self.idToBusNames setObject:busName forKey:busId];
}
-(void)addNearbyBusStop:(BusStop *)busStop{
    
    [self.nearbyBusStops addObject:busStop];
}
-(NSString *)getBusNameForBusId:(NSString *)busId{
    
    return [self.idToBusNames objectForKey:busId];
}

#pragma mark - Getters

-(NSArray<BusStop *> *)getFavoriteStops{
    
    return [NSArray arrayWithArray:self.favoriteStops];
}

-(NSArray<BusStop *> *)getNearbyStops{
    
    return [NSArray arrayWithArray:self.nearbyBusStops];
}

-(NSDictionary *)getIdToBusNames{
    
    return [NSDictionary dictionaryWithDictionary:self.idToBusNames];
}
@end
