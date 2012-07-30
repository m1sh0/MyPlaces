//
//  Place.h
//  MyPlaces
//
//  Created by Nikolay Kivshanov on 2/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Place : NSManagedObject

@property (nonatomic, retain) NSDate * creationDate;
@property (nonatomic, retain) NSString * image;
@property (nonatomic, retain) NSString * info;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSNumber * longtitude;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * category;

@end
