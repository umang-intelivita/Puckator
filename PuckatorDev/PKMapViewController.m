//
//  PKMapViewViewController.m
//  Puckator
//
//  Created by Luke Dixon on 30/06/2017.
//  Copyright © 2017 57Digital Ltd. All rights reserved.
//

#import "PKMapViewController.h"
#import <MKMapViewZoom/MKMapView+ZoomLevel.h>
#import "FSLocationManager.h"
#import "PKAddress.h"
#import <OCMapView/OCMapView.h>
#import "UIColor+Puckator.h"
#import "UIViewController+HUD.h"
#import "PKAddressAnnotation.h"
#import "PKConstant.h"

@interface PKMapViewController ()

@property int radius; // in miles
@property int limit; // number of pins to show

@property int addressesFound;
@property int addressesDisplayed;

@property NSArray<PKCustomer *> *customers;
@property NSArray<PKAddress *> *addresses;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@end

@implementation PKMapViewController

#pragma mark - Constructor Methods

+ (UIStoryboard *)storyboard {
    return [UIStoryboard storyboardWithName:@"PKMapViewController" bundle:[NSBundle mainBundle]];
}

+ (instancetype)create {
    PKMapViewController *viewController = [[PKMapViewController storyboard] instantiateInitialViewController];
    if (![viewController isKindOfClass:[PKMapViewController class]]) {
        return nil;
    }
    
    return viewController;
}

+ (instancetype)createWithCustomers:(NSArray *)customers {
    PKMapViewController *viewController = [PKMapViewController create];
    [viewController setCustomers:customers];
    return viewController;
}

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setRadius:15];
    [self setLimit:-1];
    
    // Setup the location manager:
    [[FSLocationManager sharedInstance] setup];
    
    // Setup the mapview:
    [[self mapView] setDelegate:self];
//    [[self mapView] setClusterSize:0.3];
//    [[self mapView] setMinimumAnnotationCountPerCluster:10000];
//    [[self mapView] setClusteringMethod:OCClusteringMethodBubble];
//    [[self mapView] setMinLongitudeDeltaToCluster:5];
//    [[self mapView] setClusteringEnabled:NO];
    
    // Add the dismiss button:
    if ([[[self navigationController] viewControllers] count] == 1) {
        UIBarButtonItem *buttonDismiss = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Dismiss", nil) style:UIBarButtonItemStylePlain target:self action:@selector(buttonDismissPressed:)];
        [[self navigationItem] setLeftBarButtonItem:buttonDismiss];
    }
    
    // Zoom to user's current location:
    [[FSLocationManager sharedInstance] locationCompletion:^(CLLocation *location, NSError *error) {
        // Zoom the map:
        [FSThread runOnMain:^{
            [[self mapView] setCenterCoordinate:[location coordinate] zoomLevel:9 animated:YES];
        }];
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    UIBarButtonItem *buttonLocation = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ToolbarLocation"] style:UIBarButtonItemStyleDone target:self action:@selector(buttonLocationPressed:)];
    UIBarButtonItem *buttonSearch = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ToolbarSearch"] style:UIBarButtonItemStyleDone target:self action:@selector(buttonSearchPressed:)];
    
    [[self navigationItem] setRightBarButtonItems:@[buttonLocation, buttonSearch]];
    
    // Fetch the addresses:
    [self fetchAddresses];
}

#pragma mark - Private Methods

- (CGFloat)radiusInMetres {
    return [self radius] * 1609.34;
}

- (void)fetchAddresses {
    // Only load the addresses once:
    if ([[self addresses] count] != 0) {
        return;
    }
    
    // Display HUD:
    [self showHud:NSLocalizedString(@"Loading", nil) animated:NO];

    // Fetch addresses:
    __weak PKMapViewController *weakSelf = self;
    [FSThread runInBackground:^{
        PKFeedConfig *feedConfig = [[PKSession sharedInstance] currentFeedConfig];
        NSString *xmlFile = (NSString *)[[PKFeedConfigMeta feedMetaDataWithFeedConfig:feedConfig group:kPuckatorMetaGroupSqlXmlFiles key:kPuckatorMetaKeySqlXmlCustomerFile] object];        
        NSArray *addresses = [PKAddress findAddressesForXMLFilename:xmlFile defaultAddressesOnly:NO];
        [weakSelf setAddresses:addresses];

        // Hide HUD:
        [FSThread runOnMain:^{
            // Display the first set of data:
            [weakSelf findAndDisplayAddressAroundCoordinate:[[weakSelf mapView] centerCoordinate]];
            [weakSelf hideHudAnimated:NO];
        }];
    }];
}

- (void)findAndDisplayAddressAroundCoordinate:(CLLocationCoordinate2D)coordinate {
    NSArray *nearbyAddresses = [self filterAddresses:[self addresses]
                                   closeToCoordinate:[[self mapView] centerCoordinate]
                                              radius:[self radiusInMetres]
                                               limit:[self limit]];
    [self displayAddresses:nearbyAddresses];
    [self updateOverlays];
}

- (void)displayAddresses:(NSArray *)addresses {
    NSMutableArray *annotationsToRemove = [NSMutableArray array];
    NSMutableArray *addressesToAdd = [addresses mutableCopy];
    NSMutableArray *currentAnnotations = [[[self mapView] annotations] mutableCopy];
    
    [currentAnnotations enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (![obj isKindOfClass:[PKAddressAnnotation class]]) {
            [currentAnnotations removeObject:obj];
        }
    }];
    
    // If the current annotations is empty they add all the addresses:
//    
//    [addresses enumerateObjectsUsingBlock:^(PKAddress *address, NSUInteger idx, BOOL * _Nonnull stop) {
//        
//    }];
    
    if ([currentAnnotations count] == 0) {
        [addressesToAdd addObjectsFromArray:addresses];
    } else {
        // Loop the annotations and decide which to remove:
        [currentAnnotations enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj isKindOfClass:[PKAddressAnnotation class]]) {
                PKAddressAnnotation *annotation = (PKAddressAnnotation *)obj;
                PKAddress *address = [annotation address];
                if (![addresses containsObject:address]) {
                    [annotationsToRemove addObject:annotation];
                } else {
                    // Remove the address from the toAdd array as there is already a pin on display:
                    [addressesToAdd removeObject:address];
                }
            }
        }];
    }
    
    // Remove current annoations:
    [[self mapView] removeAnnotations:annotationsToRemove];
    
    // Loop the addresses and add map pins:
    NSMutableArray *annotations = [NSMutableArray array];
    [addressesToAdd enumerateObjectsUsingBlock:^(PKAddress * _Nonnull address, NSUInteger idx, BOOL * _Nonnull stop) {
        PKAddressAnnotation *annotation = [PKAddressAnnotation createWithAddress:address];
        [annotations addObject:annotation];
    }];
    
    [[self mapView] addAnnotations:annotations];
}

#pragma mark - Address Filter Methods

- (NSArray *)filterAddresses:(NSArray *)addresses closeToCoordinate:(CLLocationCoordinate2D)coordinate radius:(CGFloat)radius limit:(int)limit {
    NSMutableArray *nearestAddresses = [NSMutableArray array];
    CLLocation *location = [[CLLocation alloc] initWithLatitude:coordinate.latitude longitude:coordinate.longitude];
    CLCircularRegion *region = [[CLCircularRegion alloc] initWithCenter:coordinate radius:radius identifier:@"FilterRegion"];
    
    // We will need to enumerate all stores to ensure that there are no more
    // than 25 objects within the defined region.
    //
    // Since there may be thousands of objects and many of them can be
    // out of the defined region, we should perform concurrent enumeration
    // for performance reasons.
    dispatch_semaphore_t s = dispatch_semaphore_create(1);
    [addresses enumerateObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(PKAddress *address, NSUInteger idx, BOOL *stop) {
        if ([region containsCoordinate:[address coordinate]]) {
            dispatch_semaphore_wait(s, DISPATCH_TIME_FOREVER);
            [nearestAddresses addObject:address];
            dispatch_semaphore_signal(s);
        }
    }];
//    dispatch_release(s);
    
    // Limit the addresses array if required:
    if (limit > 0 && [nearestAddresses count] > limit) {
        [nearestAddresses sortWithOptions:NSSortConcurrent usingComparator:^NSComparisonResult(PKAddress *address1, PKAddress *address2) {
             return [location distanceFromLocation:[address1 location]] - [location distanceFromLocation:[address2 location]];
         }];
        
        [self setAddressesFound:(int)[nearestAddresses count]];
        
        // Limit the addresses:
        nearestAddresses = [[nearestAddresses subarrayWithRange:NSMakeRange(0, MIN([nearestAddresses count], limit))] mutableCopy];
        [self setAddressesDisplayed:(int)[nearestAddresses count]];
        
        return nearestAddresses;
    }
    
    // No limit required:
    return nearestAddresses;
}

- (void)displayAddressSearchError {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Search Error", nil) message:NSLocalizedString(@"Sorry, we were unable to find any customers for your search.", nil) preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Dismiss", nil) style:UIAlertActionStyleCancel handler:nil]];
    
    [self presentViewController:alertController animated:YES completion:^{
    }];
}

#pragma mark - Event Methods

- (void)buttonDismissPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (void)buttonSearchPressed:(id)sender {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Search", nil) message:NSLocalizedString(@"Please enter a place name or postcode:", nil) preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        [textField setPlaceholder:NSLocalizedString(@"Enter place name or postcode", nil)];
    }];
    
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Search", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UITextField *textfield = alertController.textFields.firstObject;
        if ([[textfield text] length] != 0) {
            [[FSLocationManager sharedInstance] locationForSearch:[textfield text] completion:^(CLLocation *location, NSError *error) {
                if (location) {
                    [FSThread runOnMain:^{
                        [[self mapView] setCenterCoordinate:[location coordinate] zoomLevel:9 animated:YES];
                    }];
                } else {
                    [self displayAddressSearchError];
                }
            }];
        } else {
            [self displayAddressSearchError];
        }
    }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:nil]];
    
    [self presentViewController:alertController animated:YES completion:^{
    }];
    
    
}

- (void)buttonLocationPressed:(id)sender {
    
    if ([[FSLocationManager sharedInstance] locationAuthorised]) {
        [[FSLocationManager sharedInstance] locationCompletion:^(CLLocation *location, NSError *error) {
            if (location) {
                [FSThread runOnMain:^{
                    [[self mapView] setCenterCoordinate:[location coordinate] zoomLevel:9 animated:YES];
                }];
            }
        }];
    } else {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Not Authorised", nil) message:NSLocalizedString(@"We're not authorised to use your location. Please enable location services in your device settings.", nil) preferredStyle:UIAlertControllerStyleAlert];
        
        [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Dismiss", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
        }]];
        
        [self presentViewController:alertController animated:YES completion:^{
        }];
    }
}

#pragma mark - MKMapViewDelegate Methods

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    // Check for user location:
    if ([annotation isKindOfClass:[MKUserLocation class]]) {
        return nil;
    }
        
    static NSString *annotationViewReuseIdentifier = @"annotationViewReuseIdentifier";
    
    MKPinAnnotationView *annotationView = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:annotationViewReuseIdentifier];
    if (annotationView == nil) {
        annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:annotationViewReuseIdentifier];
    }
    
    if ([annotation isKindOfClass:[PKAddressAnnotation class]]) {
        PKAddressAnnotation *addressAnnotation = (PKAddressAnnotation *)annotation;
        if ([[addressAnnotation address] isDefaultDeliveryAddress]) {
            [annotationView setPinColor:MKPinAnnotationColorGreen];
        } else {
            [annotationView setPinColor:MKPinAnnotationColorRed];
        }
    } else {
        [annotationView setPinColor:MKPinAnnotationColorPurple];
    }
    
    UIButton *detailButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    [detailButton setImage:[UIImage imageNamed:@"ToolbarForward"] forState:UIControlStateNormal];
    annotationView.rightCalloutAccessoryView = detailButton;
    annotationView.animatesDrop = NO;
    annotationView.canShowCallout = YES;
    return annotationView;
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    
}

- (void)mapView:(MKMapView *)mv annotationView:(MKAnnotationView *)pin calloutAccessoryControlTapped:(UIControl *)control {
//    if ([[pin annotation] isKindOfClass:[PKCustomerAnnotation class]]) {
//        PKCustomerAnnotation *annotation = (PKCustomerAnnotation *)[pin annotation];
//        PKCustomer *customer = [annotation customer];
//        if (customer) {
//            PKCustomerViewController *viewController = [PKCustomerViewController createWithCustomer:customer];
//            [[self navigationController] pushViewController:viewController animated:YES];
//        }
//    }
    
    if ([[pin annotation] isKindOfClass:[PKAddressAnnotation class]]) {
        PKAddressAnnotation *annotation = (PKAddressAnnotation *)[pin annotation];
        PKAddress *address = [annotation address];
        PKCustomer *customer = [PKCustomer findCustomerWithId:[address customerId]];
        if (customer) {
            PKCustomerViewController *viewController = [PKCustomerViewController createWithCustomer:customer];
            [[self navigationController] pushViewController:viewController animated:YES];
        }
    }
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    MKMapRect mRect = mapView.visibleMapRect;
    MKMapPoint eastMapPoint = MKMapPointMake(MKMapRectGetMinX(mRect), MKMapRectGetMidY(mRect));
    MKMapPoint westMapPoint = MKMapPointMake(MKMapRectGetMaxX(mRect), MKMapRectGetMidY(mRect));
    
    CLLocationDistance meters = MKMetersBetweenMapPoints(eastMapPoint, westMapPoint);
    double metersPerMile = 0.000621371192;
    double miles = meters * metersPerMile;
    
    NSLog(@"Map showing %.2f miles", miles);
    
    // Calculate a radius:
    if (miles > 25) {
        [self setRadius:25];
    } else {
        [self setRadius:miles];
    }
    
//    [[self navigationItem] setPrompt:[NSString stringWithFormat:@"Searching a %d mile radius", [self radius]]];
    
    // Fetch nearby addresses:
    [self findAndDisplayAddressAroundCoordinate:[mapView centerCoordinate]];
}

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay {
    if ([overlay isKindOfClass:[MKCircle class]]) {
        MKCircle *circle = overlay;
        MKCircleRenderer *circleView = [[MKCircleRenderer alloc] initWithOverlay:overlay];
        //    float alpha = [[circle subtitle] floatValue];
        
        if ([circle.title isEqualToString:@"background"]) {
            circleView.fillColor = [[UIColor puckatorPrimaryColor] colorWithAlphaComponent:0.25f];
        } else if ([circle.title isEqualToString:@"helper"]) {
            circleView.fillColor = [UIColor redColor];
        } else {
            circleView.strokeColor = [[UIColor puckatorPrimaryColor] colorWithAlphaComponent:0.75f];
            circleView.lineWidth = 2;
        }
        
        return circleView;
    } else if ([overlay isKindOfClass:[MKPolyline class]]) {
        MKPolyline *polyline = (MKPolyline *)overlay;
        MKPolylineRenderer *renderer = [[MKPolylineRenderer alloc] initWithPolyline:polyline];
        [renderer setFillColor:[UIColor redColor]];
        [renderer setStrokeColor:[UIColor blueColor]];
        [renderer setLineWidth:4];
        return renderer;
    }
    
    return nil;
}

- (void)updateOverlays {
//    // Remove the old overlays:
    [[self mapView] removeOverlays:[[self mapView] overlays]];
    
//    MKCircle *circle = [[[self mapView] overlays] firstObject];
    if ([[[self mapView] overlays] count] == 0) {
        MKCircle *circle = [MKCircle circleWithCenterCoordinate:[[self mapView] centerCoordinate] radius:[self radiusInMetres]];
        [circle setTitle:@"background"];
        [[self mapView] addOverlay:circle];

        MKCircle *circleLine = [MKCircle circleWithCenterCoordinate:[[self mapView] centerCoordinate] radius:[self radiusInMetres]];
        [circleLine setTitle:@"line"];
        [self.mapView addOverlay:circleLine];
    }
    
    
    
//    // Remove the existing overlays:
//    //[[self mapView] removeOverlays:[[self mapView] overlays]];
//    NSMutableArray *overlays = [NSMutableArray array];
//    [[[self mapView] overlays] enumerateObjectsUsingBlock:^(id<MKOverlay>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//        if ([obj isKindOfClass:[MKCircle class]]) {
//            MKCircle *circle = (MKCircle *)obj;
//            if ([[circle title] isEqualToString:@"background"] || [[circle title] isEqualToString:@"line"]) {
//                [overlays addObject:obj];
//            }
//        }
//    }];
//    [[self mapView] removeOverlays:overlays];
//
//    // Create the new overlays for the OCAnnotations:
//    [[[self mapView] displayedAnnotations] enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//        if ([obj isKindOfClass:[OCAnnotation class]]) {
//            OCAnnotation *annotation = (OCAnnotation *)obj;
//            float alpha = ((float)[[annotation annotationsInCluster] count] / 100);
//            // static circle size of cluster
//            CGFloat delta = MIN(self.mapView.region.span.longitudeDelta, self.mapView.region.span.latitudeDelta);
//            CLLocationDistance clusterRadius = delta * self.mapView.clusterSize * 111000 / 1.0f;
//            clusterRadius = clusterRadius * cos([annotation coordinate].latitude * M_PI / 180.0);
//
//            MKCircle *circle = [MKCircle circleWithCenterCoordinate:annotation.coordinate radius:clusterRadius];
//            [circle setTitle:@"background"];
//            [circle setSubtitle:[NSString stringWithFormat:@"%f", alpha]];
//            [self.mapView addOverlay:circle];
//
//            MKCircle *circleLine = [MKCircle circleWithCenterCoordinate:annotation.coordinate radius:clusterRadius];
//            [circleLine setTitle:@"line"];
//            [self.mapView addOverlay:circleLine];
//        }
//    }];
}

#pragma mark -

@end
