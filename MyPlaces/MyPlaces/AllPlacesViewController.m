//
//  AllPlacesViewController.m
//  MyPlaces
//
//  Created by Nikolay Kivshanov on 2/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AllPlacesViewController.h"
#import "AppDelegate.h"
#import "PlaceCreationViewController.h"

@implementation AllPlacesViewController

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

- (void)getPlaces {
    [placesArray release];
    AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    NSEntityDescription * entity = [NSEntityDescription entityForName:@"Place" inManagedObjectContext:[delegate managedObjectContext]];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entity];
    
    NSError *error = nil;
    placesArray = [[[[delegate managedObjectContext] executeFetchRequest:request error:&error] mutableCopy] retain];
    if(!([filterString length]==0)) {
        placesArray = [(NSMutableArray *)[placesArray filteredArrayUsingPredicate:[self getSearchPredicate]] retain];
    }
    [tableView reloadData];
}

- (void) getPlacesWithCategoryNumber: (NSInteger) categoryNumber {
    AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    NSEntityDescription * entity = [NSEntityDescription entityForName:@"Place" inManagedObjectContext:[delegate managedObjectContext]];
    
    NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
    [request setEntity:entity];
    
    // Set example predicate and sort orderings...
    NSPredicate *predicate = [NSPredicate predicateWithFormat:
                              @"category = %d",categoryNumber];
    [request setPredicate:predicate];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc]
                                        initWithKey:@"creationDate" ascending:YES];
    [request setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    [sortDescriptor release];
    
    NSError *error = nil;
    placesArray = [[[[delegate managedObjectContext] executeFetchRequest:request error:&error] mutableCopy] retain];
    if(!([filterString length]==0)) {
        placesArray = [(NSMutableArray *)[placesArray filteredArrayUsingPredicate:[self getSearchPredicate]] retain];
    }
    [tableView reloadData];

}
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self getPlaces];
    [categoryTabBar setSelectedItem:(UITabBarItem *)[categoryTabBar viewWithTag:4]];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [placesArray count];
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString * const kDetailsCellID = @"kCCHAllRequestsCellID";
    UITableViewCell* cell =[tableView dequeueReusableCellWithIdentifier:kDetailsCellID];
    if(nil==cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:kDetailsCellID];
    }
    
    cell.textLabel.text = [[placesArray objectAtIndex:indexPath.row] name];
    
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    PlaceCreationViewController *placeViewController = [[PlaceCreationViewController alloc] initWithPlace:[placesArray objectAtIndex:indexPath.row] andState:view];
    [self.navigationController pushViewController:placeViewController animated:YES];
    [placeViewController release];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    if([searchText length] == 0) {
        [filterString release];
        filterString = [searchText retain];
        [self getPlaces];
        [searchBar resignFirstResponder];
    }
    else {
        [filterString release];
        filterString = [searchText retain];
        [self getPlaces];
    }
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
}

-(NSPredicate *)getSearchPredicate {
    
    NSPredicate *predTitle;
    
    NSPredicate *p1 = [NSPredicate predicateWithFormat:@"name contains[c] $title"];
    predTitle = [[NSCompoundPredicate orPredicateWithSubpredicates:[NSArray arrayWithObjects:p1, nil]] retain];
    
    NSDictionary *variables = [NSDictionary dictionaryWithObjectsAndKeys:filterString, @"title", nil];
    
    NSPredicate *pred = [predTitle predicateWithSubstitutionVariables:variables];
    
    return pred;
}

-(void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item {
    if (item.tag > 2) {
        [self getPlaces];
    }
    else {
        [self getPlacesWithCategoryNumber: item.tag];
    }
}


        
    
    



@end
