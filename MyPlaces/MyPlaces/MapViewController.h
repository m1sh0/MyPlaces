//
//  MapViewController.h
//  MyPlaces
//
//  Created by Nikolay Kivshanov on 1/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "AllPlacesViewController.h"
#import "PlaceAnnotation.h"
#import "SplashViewCotroller.h"

@interface MapViewController : UIViewController <CLLocationManagerDelegate, UIAlertViewDelegate> {
    CLLocationCoordinate2D fingerCoordiantes;
    NSMutableArray *placesArray;
    CLLocationManager *manager;
    IBOutlet UISwitch *switchButton;
    SplashViewCotroller *splash;
}

@property (retain, nonatomic) IBOutlet UIButton *btnNotif;
@property (retain, nonatomic) IBOutlet MKMapView *map;
@property (retain, nonatomic) IBOutlet UINavigationController *navContr;


-(void)getLocation;
-(IBAction)allPlaces:(id)sender;
-(IBAction)enableNotif:(UIButton *)sender;

@end
