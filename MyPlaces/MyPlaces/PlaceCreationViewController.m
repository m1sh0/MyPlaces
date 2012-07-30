//
//  PlaceCreationViewController.m
//  MyPlaces
//
//  Created by Nikolay Kivshanov on 2/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PlaceCreationViewController.h"
#import "Place.h"
#import "AppDelegate.h"

@implementation PlaceCreationViewController
@synthesize name;



- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        state = create;
    }
    return self;
}

-(id)initWithCoordinates:(CLLocationCoordinate2D)coordinates {
    self = [super init];
    if(self) {
        placeLocation = coordinates;
        state = create;
    }
    return self;
}

-(id)initWithPlace:(Place *) place andState:(enum ControllerState) controllerState {
    self = [super init];
    if(self) {
        viewedPlace = place;
        state = controllerState;
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

- (void) editPlace {
    state = edit;
    [self viewDidLoad];
}

- (void) doneEditPlace {
    
    viewedPlace.name = nameTextField.text;
    viewedPlace.info = infoTextView.text;
    viewedPlace.image = selectedURL;
    viewedPlace.category = [NSNumber numberWithInt:[lastSelectedButton tag]];
    
    AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    [[delegate managedObjectContext] save:nil];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidLoad
{
    [infoTextView setReturnKeyType: UIReturnKeyDone];
    [placeImage setImage:[UIImage imageNamed:@"icon.png"]];
    UITapGestureRecognizer *gRec = [[UITapGestureRecognizer alloc] initWithTarget:placeImage action:@selector(choosePicture:)];
    [placeImage addGestureRecognizer:gRec];
    [gRec release];
    
    name.text = [NSString stringWithFormat:@"latitude %f and longitude %f",placeLocation.latitude , placeLocation.longitude];
    [super viewDidLoad];
    
    switch ([viewedPlace.category intValue]) {
        case 0:
            lastSelectedButton = favourites;
            break;
        case 1:
            lastSelectedButton = family;
            break;
        default:
            lastSelectedButton = friends;
            break;
    }
    [lastSelectedButton setSelected:YES];
    
    [selectImageButton setHidden:NO];
    
    if (state == view) {
        
        nameTextField.text = viewedPlace.name;
        infoTextView.text = viewedPlace.info;
        [nameTextField setEnabled:NO];
        [infoTextView setEditable:NO];
        [selectImageButton setHidden:YES];
        [self imageFromURL:viewedPlace.image andBlock:^(UIImage *image){
             NSLog(@"image %@", image);
            if (image) {
                placeImage.image = image;
            }
        }];
        
        UIBarButtonItem *rightBarButton = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editPlace)] autorelease];
        self.navigationItem.rightBarButtonItem = rightBarButton;
    }
    else {    
        [nameTextField setEnabled:YES];
        [infoTextView setEditable:YES];
    }
    if (state == edit) {
        nameTextField.text = viewedPlace.name;
        infoTextView.text = viewedPlace.info;
        
        [self imageFromURL:viewedPlace.image andBlock:^(UIImage *image){
            NSLog(@"image %@", image);
            if (image) {
                placeImage.image = image;
            }
        }];
        
        UIBarButtonItem *rightBarButton = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneEditPlace)] autorelease];
        self.navigationItem.rightBarButtonItem = rightBarButton;
    }
    
    if (state == create) {
        UIBarButtonItem *rightBarButton = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addPlace)] autorelease];
        self.navigationItem.rightBarButtonItem = rightBarButton;
        [creationDateLable setHidden:YES];
    }
    else {
        NSDateFormatter *dateFormater = [[NSDateFormatter alloc] init];
        [dateFormater setDateFormat:@"dd-MMMM-yyyy"];
        creationDateLable.text = [dateFormater stringFromDate:viewedPlace.creationDate];
        creationDateLable.hidden = NO;
    }
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [self setName:nil];
    [placeImage release];
    placeImage = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}

-(void)imageFromURL:(NSString *)url andBlock:(ImageLoadedBlock)block {
    NSURL *imagePath = [NSURL URLWithString:url];
    ALAssetsLibrary *lib = [[ALAssetsLibrary alloc] init];
    [lib assetForURL:imagePath
         resultBlock:^(ALAsset *asset) {
             if (asset)  {
                 ALAssetRepresentation *assetRep = [asset defaultRepresentation]; 
                 UIImage *image = [UIImage imageWithCGImage:[assetRep fullResolutionImage]];
                 block(image);
             }
             else {
                 block(nil); 
             }
         } 
        failureBlock:^(NSError *error){
            //handle the error
            block(nil);
        }];
    
    [lib release];
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [selectedURL release];
    NSURL *url = [[info objectForKey:UIImagePickerControllerReferenceURL] retain];
    selectedURL = [[NSString stringWithFormat:@"%@",url] retain];
    
    
    [self imageFromURL:selectedURL andBlock:^(UIImage *image){
        placeImage.image = image;
        [picker dismissModalViewControllerAnimated:YES];
    }];
}

-(IBAction)setState:(UIButton *)sender {
    if (state != view) {
        [lastSelectedButton setSelected:NO];
        lastSelectedButton = sender;
        sender.selected = YES;
    }
}

-(IBAction)choosePicture:(UIButton *)sender {
    
    UIAlertView *creation = [[UIAlertView alloc]
                             initWithTitle: @"Select Picture"
                             message: @"Where do you want to select picture from"
                             delegate:self
                             cancelButtonTitle:@"Camera" 
                             otherButtonTitles:@"Directory",nil];
    [creation show];
    [creation release];
    
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    
    if(buttonIndex==0) { 
        UIImagePickerController *vc = [[UIImagePickerController alloc] init];
        vc.delegate = (id)self;
        vc.sourceType = UIImagePickerControllerSourceTypeCamera;
        [self presentModalViewController:vc animated:YES];
        [vc release];

    }
    else {
        UIImagePickerController *vc = [[UIImagePickerController alloc] init];
        vc.delegate = (id)self;
        vc.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [self presentModalViewController:vc animated:YES];
        [vc release];

    }
   
}

-(IBAction)addPlace {
    AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    
    Place *newPlace = (Place *)[NSEntityDescription insertNewObjectForEntityForName:@"Place" inManagedObjectContext:[delegate managedObjectContext]];
    
    newPlace.name = nameTextField.text;
    newPlace.info = infoTextView.text;
    newPlace.longtitude = [NSNumber numberWithDouble:placeLocation.longitude];
    newPlace.latitude = [NSNumber numberWithDouble:placeLocation.latitude];
    newPlace.creationDate = [NSDate date];
    newPlace.image = selectedURL;
    newPlace.category = [NSNumber numberWithInt:[lastSelectedButton tag]];
    
    [[delegate managedObjectContext] save:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"PlaceCreation" object:self];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)dealloc {
    [name release];
    [placeImage release];
    [super dealloc];
}

@end
