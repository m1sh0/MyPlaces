//
//  MapViewController.m
//  MyPlaces
//
//  Created by Nikolay Kivshanov on 1/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MapViewController.h"
#import "PlaceCreationViewController.h"
#import "AppDelegate.h"
#import "Place.h"

@implementation MapViewController
@synthesize btnNotif;
@synthesize map,navContr;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

-(void)getLocation {
    MKCoordinateSpan span;
    span.latitudeDelta = .00165; //zoom level
    span.longitudeDelta = .0008436;
    MKCoordinateRegion region;
    region.span = span;
    CLLocationCoordinate2D userLoc;
    userLoc.latitude = map.userLocation.location.coordinate.latitude; //get the user location
    userLoc.longitude = map.userLocation.location.coordinate.longitude;
    region.center=userLoc;
    [map setRegion:region animated:YES];
}

- (NSMutableArray *) getAllPlaces {
    
    AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    NSEntityDescription * entity = [NSEntityDescription entityForName:@"Place" inManagedObjectContext:[delegate managedObjectContext]];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entity];
    
    NSError *error = nil;
    
    return [[[delegate managedObjectContext] executeFetchRequest:request error:&error] mutableCopy];
}

-(void)loadData {
    [placesArray release];
    placesArray = [[self getAllPlaces] retain];
    
    for (Place *place in placesArray) {
        
        CLLocationCoordinate2D placeCoordinate;
        placeCoordinate.longitude = [place.longtitude doubleValue];
        placeCoordinate.latitude = [place.latitude doubleValue];
        
        PlaceAnnotation *dropPin = [[PlaceAnnotation alloc] initWithTitle:place.name andCoordinate:placeCoordinate];
        [self.map addAnnotation:dropPin];
        [dropPin release];
    }
    [map reloadInputViews];
}

- (void) endSplash {
    [splash removeFromParentViewController];
    [splash release];
}

- (void)viewDidLoad
{
    [super viewDidLoad]; 
    splash = [[SplashViewCotroller alloc] initWithNibName:@"SplashViewController" bundle:nil];
    [self presentModalViewController:splash animated:NO];
    manager = [[CLLocationManager alloc] init];
    manager.delegate = (id)self;
    [self.view addSubview:navContr.view];
    [self.map.userLocation addObserver:self  
                            forKeyPath:@"location"  
                               options:(NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld)  
                               context:NULL];
    [self performSelector:@selector(getLocation) withObject:nil afterDelay:0.3]; //zooms to the user location
    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(createPlace:)];
    [self.map addGestureRecognizer:longPressGesture];
    [longPressGesture release];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(loadData)
     name:@"PlaceCreation"
     object:nil ];
    [self loadData];
    
    [self performSelector:@selector(endSplash) withObject:nil afterDelay:2.01];
}
-(void)locationManager:(CLLocationManager *)newManager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    [manager stopUpdatingLocation];
    if(!btnNotif.selected)
        return;
    
    [self performSelector:@selector(placeRemainder) withObject:self afterDelay:120];
}

-(void)placeRemainder {
    CLLocationCoordinate2D currentLoc = map.userLocation.location.coordinate;
    CLRegion *region = [[CLRegion alloc] initCircularRegionWithCenter:currentLoc radius:150 identifier:@"myRegion"];
    for(Place *place in placesArray) {
        CLLocationCoordinate2D temp = CLLocationCoordinate2DMake(place.latitude.doubleValue, place.longtitude.doubleValue);
        if([region containsCoordinate:temp]) {
            UIAlertView *creation = [[UIAlertView alloc]
                                     initWithTitle: @"There is a place around you!"
                                     message: @":)"
                                     delegate:self
                                     cancelButtonTitle:@"OK" 
                                     otherButtonTitles:nil];
            [creation show];
            [creation release];
            break;
        }
           
    }
    [manager startUpdatingLocation];
}

-(void)actualCreate  { //drops the pin and pushes the creation controller
    
    PlaceAnnotation *dropPin = [[PlaceAnnotation alloc] initWithTitle:@"ko staa" andCoordinate:fingerCoordiantes];
    [dropPin release];
    PlaceCreationViewController *vc = [[PlaceCreationViewController alloc] initWithCoordinates:fingerCoordiantes];
    [navContr pushViewController:vc animated:YES];
    [vc release];
    
    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(createPlace:)];
    [self.map addGestureRecognizer:longPressGesture];
    [longPressGesture release];
}

-(void)createPlace:(UIGestureRecognizer *)sender {
    
    [self.map removeGestureRecognizer:sender];
    
    CGPoint point = [sender locationInView:self.map];
    CLLocationCoordinate2D locCoord = [self.map convertPoint:point toCoordinateFromView:self.map];
    fingerCoordiantes = locCoord;
    
    UIAlertView *creation = [[UIAlertView alloc]
                               initWithTitle: @"Create new Place"
                               message: @"Do you want to create a new place"
                               delegate:self
                               cancelButtonTitle:@"OK" 
                               otherButtonTitles:@"Cancel",nil];
    [creation show];
    [creation release];
}



- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if([alertView.title isEqualToString:@"Create new Place"]) {
    if(buttonIndex==0) {
        [self actualCreate]; 
        [alertView dismissWithClickedButtonIndex:buttonIndex animated:NO];
    }
    else {
        [alertView dismissWithClickedButtonIndex:buttonIndex animated:NO];
        UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(createPlace:)];
            [self.map addGestureRecognizer:longPressGesture];
        [longPressGesture release];
    }
    }
}

-(void)viewWillAppear:(BOOL)animated {
    self.map.showsUserLocation = YES;
    self.map.userLocation.title =@"You're here buddy";
}

- (void)observeValueForKeyPath:(NSString *)keyPath  
                      ofObject:(id)object  
                        change:(NSDictionary *)change  
                       context:(void *)context {  
    
    if ([self.map showsUserLocation]) {  
        //[self getLocation];
    }
}- (void)viewDidUnload
{
    [self setMap:nil];
    [self setNavContr:nil];
    [self setBtnNotif:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(IBAction)allPlaces:(id)sender {
    AllPlacesViewController *vc = [[AllPlacesViewController alloc] init];
    [navContr pushViewController:vc animated:YES];
    [vc release];
}

-(IBAction)enableNotif:(UIButton *)sender {
    if(sender.selected) {
        btnNotif.selected = NO;
        [manager stopUpdatingLocation];
        [manager stopUpdatingLocation];
        [manager stopUpdatingLocation];
        [manager stopUpdatingLocation];
        UIAlertView *creation = [[UIAlertView alloc]
                                 initWithTitle: @"Notif Center"
                                 message: @"You have disabled the notification center!"
                                 delegate:self
                                 cancelButtonTitle:@"OK" 
                                 otherButtonTitles:nil];
        [creation show];
        [creation release];
    }
    else {
        btnNotif.selected = YES;
        [manager startUpdatingLocation];
        UIAlertView *creation = [[UIAlertView alloc]
                                 initWithTitle: @"Notif Center"
                                 message: @"You have enabled the notification center!"
                                 delegate:self
                                 cancelButtonTitle:@"OK" 
                                 otherButtonTitles:nil];
        [creation show];
        [creation release];
    }
}

- (void)dealloc {
    [navContr release];
    [map release];
    [btnNotif release];
    [super dealloc];
}
@end
