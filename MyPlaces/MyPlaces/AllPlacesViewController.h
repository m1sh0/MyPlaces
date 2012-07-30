//
//  AllPlacesViewController.h
//  MyPlaces
//
//  Created by Nikolay Kivshanov on 2/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AllPlacesViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UITabBarDelegate> {
    NSMutableArray *placesArray;
    IBOutlet UITableView *tableView;
    NSString *filterString;
    IBOutlet UITabBar *categoryTabBar;
}
-(NSPredicate *)getSearchPredicate;

@end
