//
//  PlaceCreationViewController.h
//  MyPlaces
//
//  Created by Nikolay Kivshanov on 2/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "Place.h"

typedef void (^ImageLoadedBlock)(UIImage *image);
enum ControllerState {
    view,
    create,
    edit
};

@interface PlaceCreationViewController : UIViewController<UITextFieldDelegate,UIImagePickerControllerDelegate> {
    CLLocationCoordinate2D placeLocation;
    IBOutlet UITextView *infoTextView;
    IBOutlet UITextField *nameTextField;
    Place *viewedPlace;
    IBOutlet UIImageView *placeImage;
    enum ControllerState state;
    IBOutlet UIButton *favourites;
    IBOutlet UIButton *family;
    IBOutlet UIButton *friends;
    NSString *selectedURL;
    UIButton *lastSelectedButton;
    IBOutlet UILabel *creationDateLable;
    IBOutlet UIButton *selectImageButton;
}
@property (retain, nonatomic) IBOutlet UILabel *name;

-(void)imageFromURL:(NSString *)url andBlock:(ImageLoadedBlock)block;
-(id)initWithCoordinates:(CLLocationCoordinate2D)coordinates; //other  stuff will be added
-(id)initWithPlace:(Place *) place andState:(enum ControllerState) controllerState;
-(IBAction)choosePicture:(UIButton *)sender;
-(IBAction)addPlace;
-(IBAction)setState:(UIButton *)sender;

@end
