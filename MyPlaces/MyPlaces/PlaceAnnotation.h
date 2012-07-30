//
//  PlaceAnnotation.h
//  MyPlaces
//
//  Created by Nikolay Kivshanov on 2/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface PlaceAnnotation : NSObject <MKAnnotation> {
    
    NSString *title;
    CLLocationCoordinate2D coordinate;
    
}
@property (nonatomic, copy) NSString *title;
@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;

-(id)initWithTitle:(NSString *)ttle andCoordinate:(CLLocationCoordinate2D)location;

@end
