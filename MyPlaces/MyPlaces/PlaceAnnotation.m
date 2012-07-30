//
//  PlaceAnnotation.m
//  MyPlaces
//
//  Created by Nikolay Kivshanov on 2/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PlaceAnnotation.h"

@implementation PlaceAnnotation
@synthesize coordinate, title;

-(id)initWithTitle:(NSString *)ttle andCoordinate:(CLLocationCoordinate2D)location{
    [super init];
    title = ttle;
    coordinate = location;
    return self;
}

-(void)dealloc {
    [title release];
    [super release];
}

@end
