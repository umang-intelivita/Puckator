//
//  FSLocationManager.h
//  MyFutureMOT
//
//  Created by Luke Dixon on 22/02/2017.
//  Copyright © 2017 Luke Dixon. All rights reserved.
//

#import <DOSingleton/DOSingleton.h>
#import <CoreLocation/CoreLocation.h>

typedef void(^FSGeocodeBlock)(CLLocation *location, NSError *error);
typedef void(^FSGetLocationBlock)(CLLocation *location, NSError *error);

@interface FSLocationManager : DOSingleton <CLLocationManagerDelegate>

@property (assign, nonatomic) BOOL isLocationPicked;
@property (assign, nonatomic) CLLocationCoordinate2D locationPicked;

- (void)setup;
- (void)clearLocationPicked;
- (CLLocation *)location;
- (void)locationCompletion:(FSGetLocationBlock)completion;
- (void)locationForSearch:(NSString *)search completion:(FSGeocodeBlock)completion;
- (void)requestAuthorisation;
- (BOOL)locationAuthorised;

@end
