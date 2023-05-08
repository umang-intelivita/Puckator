//
//  FSLocationManager.m
//  MyFutureMOT
//
//  Created by Luke Dixon on 22/02/2017.
//  Copyright © 2017 Luke Dixon. All rights reserved.
//

#import "FSLocationManager.h"
#import "NSError+FS.h"
#import <NSThreadBlocks/NSThread+Blocks.h>

@interface FSLocationManager ()

@property (strong, nonatomic) CLLocationManager *manager;

@end

@implementation FSLocationManager

@synthesize locationPicked = _locationPicked;

- (void)setLocationPicked:(CLLocationCoordinate2D)locationPicked {
    _locationPicked = locationPicked;
    _isLocationPicked = YES;
}

- (void)clearLocationPicked {
    _locationPicked = CLLocationCoordinate2DMake(0, 0);
    _isLocationPicked = NO;
}

- (CLLocationCoordinate2D)locationPicked {
    if (_isLocationPicked) {
        return _locationPicked;
    }
    return [[self manager] location].coordinate;
}

- (void)setup {
    if (![self manager]) {
        [self setManager:[[CLLocationManager alloc] init]];
    }
    
    [[self manager] setDelegate:self];
    [[self manager] requestWhenInUseAuthorization];
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    switch (status) {
        case kCLAuthorizationStatusAuthorizedAlways:
        case kCLAuthorizationStatusAuthorizedWhenInUse: {
            [[self manager] startUpdatingLocation];
            break;
        }
        default:
            break;
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    //NSLog(@"[%@] - Location updated: %f:%f", [self class], [self location].coordinate.latitude, [self location].coordinate.longitude);
}

- (CLLocation *)location {
    return [[self manager] location];
}

- (void)locationCompletion:(FSGetLocationBlock)completion {
    __weak FSLocationManager *weakSelf = self;
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedAlways ||
        [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse) {
        [NSThread performBlockInBackground:^{
            int counter = 0;
            while ([weakSelf location] == nil && counter < 100) {
                NSLog(@"[%@] Waiting for location...", [self class]);
                counter++;
            }
            
            if (completion) {
                [NSThread performBlockOnMainThread:^{
                    if ([weakSelf location] != nil) {
                        completion([weakSelf location], nil);
                    } else {
                        completion(nil, [NSError create:NSLocalizedString(@"We were unable to find your location.\n\nPlease check you've given us access to your location in the settings app.", nil)]);
                    }
                }];
            }
        }];
    } else {
        if (completion) {
            completion(nil, [NSError create:NSLocalizedString(@"We were unable to find your location.\n\nPlease check you've given us access to your location in the settings app.", nil)]);
        }
    }
}

- (void)locationForSearch:(NSString *)search completion:(FSGeocodeBlock)completion {
    CLGeocoder *geo = [[CLGeocoder alloc] init];
    
    [geo geocodeAddressString:search completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        if (completion) {
            if (error) {
                completion(nil, error);
            } else {
                [placemarks enumerateObjectsUsingBlock:^(CLPlacemark * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    NSLog(@"[%@] - Place: %@", [self class], [obj name]);
                }];
                
                if (completion) {
                    CLLocation *location = [[placemarks firstObject] performSelector:@selector(location)];
                    completion(location, nil);
                }
            }
        }
    }];
}

- (void)requestAuthorisation {
    [self setup];
    [[self manager] requestWhenInUseAuthorization];
}

- (BOOL)locationAuthorised {
    return [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedAlways || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse;
}

@end
