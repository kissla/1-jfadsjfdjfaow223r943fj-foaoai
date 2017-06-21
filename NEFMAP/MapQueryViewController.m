#import "MapQueryViewController.h"

@implementation MapQueryViewController

@synthesize dataController;
@synthesize myMapView;
@synthesize myToolBarView;
@synthesize myToolBar;
@synthesize locateMe;
@synthesize USAButton;
@synthesize mapResetBtn;
@synthesize satelliteOnButton;
@synthesize satelliteOffButton;
@synthesize mySearchBar;
@synthesize tapInterceptor;
@synthesize reverseGeocoder;



- (BOOL) groupPinsByState
{
    /*
     Are we below minimum span?
     
     If so, show all the pins
     
     If not,
     count the pins in area (of region that fits)
     
     If too many, then show states
     
     If not, then show all the pins
     
     
     So, we only show the states if we are
     1) above the minimum span
     2) above the pin limit (200)
     */
    return (([dataController.myQueriedProjects count] == [dataController.myQueriedProjectsFixed count]) && 
            ([dataController.myQueriedProjectsFixed count] > kMaxPins) &&
            ((myMapView.region.span.latitudeDelta + myMapView.region.span.longitudeDelta) > kSpanTotalThreshold));

}

- (NSString *) getStateNameOfTag: (int) tagOfState
{
    for (State *tempState in [dataController.statesTable allValues])
    {
        if (tempState.tag == tagOfState)
        {
            return tempState.name;
        }
    }
    
    return @"Nothing";
}

- (void) drawMap
{
    double highLatitude = 0.0;
    double lowLatitude = 0.0;
    double highLongitude = 0.0;
    double lowLongitude = 0.0;
    
    NSEnumerator * myQueriedProjectsEnumerator = [dataController.myQueriedProjects objectEnumerator];
    
    id projectObject;
    
    BOOL firstObject = TRUE;
    
    while ((projectObject = [myQueriedProjectsEnumerator nextObject])) 
    {
        Project * tempProject = (Project *) projectObject;
        
        if (firstObject == TRUE)
        {
            highLatitude    = tempProject.latitude;
            lowLatitude     = tempProject.latitude;
            highLongitude   = tempProject.longitude;
            lowLongitude    = tempProject.longitude;
            firstObject = FALSE;
        }
        else
        {
            if (highLatitude < tempProject.latitude)
            {
                highLatitude = tempProject.latitude;
            }
            if (lowLatitude > tempProject.latitude)
            {
                lowLatitude = tempProject.latitude;
            }
            if (highLongitude < tempProject.longitude)
            {
                highLongitude = tempProject.longitude;
            }
            if (lowLongitude > tempProject.longitude)
            {
                lowLongitude = tempProject.longitude;
            }
        }
        
    }
    
    [myMapView removeAnnotations:myMapView.annotations];  // remove any annotations
    
    MKCoordinateRegion newRegion;
    
    
    //need to find the center of the section
    
    newRegion.center.latitude = (highLatitude + lowLatitude) / 2;
    newRegion.center.longitude = (highLongitude + lowLongitude) / 2;
    
    newRegion.span.latitudeDelta = (highLatitude - lowLatitude);  
    if (newRegion.span.latitudeDelta < kSpanLatitudeDelta)
    {
        newRegion.span.latitudeDelta = kSpanLatitudeDelta;
    }
    
    newRegion.span.longitudeDelta = (highLongitude - lowLongitude);
    if (newRegion.span.longitudeDelta < kSpanLongitudeDelta)
    {
        newRegion.span.longitudeDelta = kSpanLongitudeDelta;
    }
    
    [myMapView regionThatFits:newRegion];
    [myMapView setRegion:newRegion animated:YES];

}

//ok
-(void) mapView: (MKMapView *) theMapView regionDidChangeAnimated: (BOOL) animated
{
    double lat = myMapView.region.center.latitude;
    double lon = myMapView.region.center.longitude;
    double latDelta = myMapView.region.span.latitudeDelta;
    double lonDelta = myMapView.region.span.longitudeDelta;
    
    //NSLog(@"Latitude Delta: %f, Longitude Delta: %f", myMapView.region.span.latitudeDelta, myMapView.region.span.longitudeDelta);
    
    [self.myMapView removeAnnotations:self.myMapView.annotations];  // remove any annotations
    
    if ([self groupPinsByState])
    {
        for (State *tempState in [dataController.statesTable allValues])
        {
            if ((tempState.latitude <= lat + latDelta / 2) && (tempState.latitude >= lat - latDelta / 2) &&
                (tempState.longitude <= lon + lonDelta / 2) && (tempState.longitude >= lon - lonDelta / 2))
            {
                //NSLog(@"Latitude: %f, Longitude: %f", tempState.latitude, tempState.longitude);
                
                PropertyAnnotation *p = [[PropertyAnnotation alloc] initWithName:tempState.name Latitude:tempState.latitude Longitude:tempState.longitude ProjectCount:tempState.count ProjectID: @"-1" Tag: tempState.tag Animated:YES];
                
                [self.myMapView addAnnotation:p];
                [p release];
                
            }
        }                
    }
    else
    {
        for (Project *tempProject in [dataController.myQueriedProjectsFixed allValues])
        {
            if ((tempProject.latitude <= lat + latDelta / 2) && (tempProject.latitude >= lat - latDelta / 2) &&
                (tempProject.longitude <= lon + lonDelta / 2) && (tempProject.longitude >= lon - lonDelta / 2))
            {
                //NSLog(@"Latitude: %f, Longitude: %f", tempProject.latitude, tempProject.longitude);
                
                PropertyAnnotation *p = [[PropertyAnnotation alloc] initWithName:tempProject.name Latitude:tempProject.latitude Longitude:tempProject.longitude Address:tempProject.address City:tempProject.city State:tempProject.state ZipCode:tempProject.zipCode ProjectID: [NSString stringWithFormat:@"%d", tempProject.projectID] Animated:YES];
                
                [self.myMapView addAnnotation:p];
                [p release];
                
                
            }
        }        
    }
}

- (MKAnnotationView *)mapView:(MKMapView *)theMapView viewForAnnotation:(PropertyAnnotation *)annotation
{
    // if it's the user location, just return nil...no effect as MKUserLocation is never used
    if ([annotation isKindOfClass:[MKUserLocation class]])
        return nil;
    
    // try to dequeue an existing pin view first
    static NSString* annotationIdentifier = @"annotationIdentifier";
    MKPinAnnotationView* pinView = (MKPinAnnotationView *)
    [theMapView dequeueReusableAnnotationViewWithIdentifier:annotationIdentifier];
    
    if (!pinView)
    {
        // if an existing pin view was not available, create one
        pinView = [[[MKPinAnnotationView alloc]
                    initWithAnnotation:annotation reuseIdentifier:annotationIdentifier] autorelease];
        
        pinView.canShowCallout = YES;
        
        //dataController.myData = [[NSDictionary alloc] initWithObjectsAndKeys: [annotation title], @"Title", [annotation subtitle], @"Subtitle", [annotation description], @"Description" , nil];
    }
    else
    {
        pinView.annotation = annotation;
    }
    pinView.animatesDrop = annotation.animated;
    
    NSNumber *myNumber = [[annotation projectPropertyID] decimalFormatted];
    
    if ([self groupPinsByState])
    {
        pinView.pinColor = MKPinAnnotationColorPurple;
                
        UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
                
        [rightButton addTarget:self action:@selector(infoButtonStatePressed:) forControlEvents:UIControlEventTouchUpInside];
        rightButton.tag = annotation.tag;

        if ([myNumber intValue] == 0)
        {
            pinView.pinColor = MKPinAnnotationColorGreen;
            pinView.rightCalloutAccessoryView = nil;
        }
        else
        {
            pinView.rightCalloutAccessoryView = rightButton;            
        }
    }
    else
    {
        NSSet * tempSet = [[NSSet alloc] initWithArray: [dataController.myQueriedProjects allKeys]];
        //NSLog(@"number = %@", myNumber);
            
        if (myNumber != NULL)
        {
                
            pinView.pinColor = MKPinAnnotationColorPurple;
            NSString * tempID = [NSString stringWithFormat:@"%@", [annotation projectPropertyID]];
            if ([tempSet member:tempID] != nil)
            {
                // if it's in the group that we've queried, make it red
                pinView.pinColor = MKPinAnnotationColorRed;
            }
                
            UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
            rightButton.tag =[myNumber integerValue];
                
            [rightButton addTarget:self action:@selector(infoButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
            if ([myNumber intValue] == 0)
            {
                pinView.pinColor = MKPinAnnotationColorGreen;
                pinView.rightCalloutAccessoryView = nil;
            }
            else
            {
                pinView.rightCalloutAccessoryView = rightButton;            
            }
        }
        [tempSet release];
    }
    
    return pinView;
}
-(void)infoButtonPressed:(id)sender 
{
    // here you can access the object which triggered the method
    // for example you can check the tag value
    //NSLog(@"the tag value is: %d", [sender tag]);
    //NSLog(@"the sender %@", sender);
    
    dataController.strProjectID = [NSString stringWithFormat:@"%d", [sender tag]];
    
    AnnotationQueryDetailViewController * myAnnotationQueryDetailViewController = [[AnnotationQueryDetailViewController alloc] init];
    myAnnotationQueryDetailViewController.dataController = dataController;
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    self.tabBarController.title = @"Complete Map";
    
    [self.navigationController pushViewController:myAnnotationQueryDetailViewController animated:YES];
    [myAnnotationQueryDetailViewController release];
    return;    
}

-(void)infoButtonStatePressed:(id)sender 
{
    UIButton * tempButton = (UIButton *) sender;
    
    NSString * stateName = [self getStateNameOfTag: tempButton.tag];
    
    [dataController.myQueriedProjects removeAllObjects];
    
    [dataController.myQueriedProjects addEntriesFromDictionary: [dataController getPropertiesState:stateName]];

    if ([dataController.myQueriedProjects count] <= kPropertyLexiThreshold)
    {
        ProjectTableViewController *projectTableViewController = [[ProjectTableViewController alloc] initWithStyle:UITableViewStylePlain];
        
        [dataController.projectsTableNamesSorted removeAllObjects];
        
        [dataController.projectsTableNamesSorted addObjectsFromArray: [dataController sortProjectNames]];
        
        projectTableViewController.dataController = dataController;
        projectTableViewController.title = stateName;
        [[self navigationController] pushViewController:projectTableViewController animated:YES];
        [projectTableViewController release];        
    }
    else
    {
        LexiTableViewController *lexiTableViewController = [[LexiTableViewController alloc] initWithStyle:UITableViewStylePlain];        
        [dataController loadProjects];
        
        lexiTableViewController.dataController = dataController;
        lexiTableViewController.title = stateName;
        [[self navigationController] pushViewController:lexiTableViewController animated:YES];
        [lexiTableViewController release];        
    }    
}


- (void)geocoder:(SVGeocoder *)geocoder didFindPlacemark:(MKPlacemark *)placemark 
{
    CLLocationCoordinate2D l = [placemark coordinate];
    MKCoordinateRegion newRegion;
    
    newRegion.center.latitude = l.latitude;
    newRegion.center.longitude = l.longitude;
    newRegion.span.latitudeDelta = kSpanLatitudeDelta;
    newRegion.span.longitudeDelta = kSpanLongitudeDelta;
    
    [myMapView regionThatFits:newRegion];
    
    [myMapView setRegion: newRegion animated:YES];
    //NSLog(@"%@", placemark);
    NSDictionary *d = placemark.addressDictionary;
    
    PropertyAnnotation *p = [[PropertyAnnotation alloc] initWithName: placemark.locality Latitude:l.latitude Longitude:l.longitude Address: [d objectForKey:@"Address"] City:[d objectForKey: @"City"] State:[d objectForKey: @"State"] ZipCode:[d objectForKey: @"ZIP"] ProjectID:[d objectForKey: @"projectID"] Animated:YES];
    [myMapView addAnnotation:p];
    [p release];
}


//ok
- (void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFindPlacemark:(MKPlacemark *)placemark
{
    CLLocationCoordinate2D l = [placemark coordinate];
    MKCoordinateRegion newRegion;
    
    newRegion.center.latitude = l.latitude;
    newRegion.center.longitude = l.longitude;
    newRegion.span.latitudeDelta = kSpanLatitudeDelta;
    newRegion.span.longitudeDelta = kSpanLongitudeDelta;
    
    //[myMapView setRegion:newRegion animated:TRUE];
    [myMapView regionThatFits:newRegion];
    
    [myMapView setRegion: newRegion animated:YES];
    //NSLog(@"%@", placemark);
    NSDictionary *d = placemark.addressDictionary;
    
    //NSLog(@"Address: %@", [d objectForKey:@"Address"]);
    //NSLog(@"projectID: %@", [d objectForKey: @"projectID"]);
    //NSLog(@"Name: %@", placemark.locality);
    
    NSString * tempProjectID;
    if ([d objectForKey:@"projectID"] == NULL)
    {
        tempProjectID = [NSString stringWithFormat:@"0"];
    }
    else
    {
        tempProjectID = [NSString stringWithFormat:@"%@", [d objectForKey: @"projectID"]];
    }
    
    PropertyAnnotation *p = [[PropertyAnnotation alloc] initWithName: [NSString stringWithFormat: @"You are here: %@", placemark.locality] Latitude:l.latitude Longitude:l.longitude Address: [d objectForKey:@"Street"] City:[d objectForKey: @"City"] State:[d objectForKey: @"State"] ZipCode:[d objectForKey: @"ZIP"] ProjectID: tempProjectID Animated:YES];
    [myMapView addAnnotation:p];
    dataController.startAddress = [d objectForKey:@"Street"];
    dataController.startZip = [d objectForKey:@"ZIP"];
    [p release];
}

//ok
-(void)loadView
{
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    
    // this is global so that we can ensure a sufficiently large toolbar
    initialScreenHeight = [[UIScreen mainScreen] applicationFrame].size.height;
    
    CGFloat screenWidth     = [[UIScreen mainScreen] applicationFrame].size.width;
    CGFloat statusBarHeight = [[UIApplication sharedApplication] statusBarFrame].size.height;
    
    navigationBarHeight     = self.navigationController.navigationBar.frame.size.height;

    
    // build the root view
    self.view = [[UIView alloc] initWithFrame:CGRectMake(0,
                                                         statusBarHeight, 
                                                         screenWidth, 
                                                         initialScreenHeight)];
    
    // this allows the search bar's border to look better when placed on view
    self.view.backgroundColor = [UIColor darkGrayColor];
    
    
    // build the top tool bar
    self.myToolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0,
                                                                 0,
                                                                 screenWidth * kPctOfViewForButtons,
                                                                 kPctOfScreenForToolBar * initialScreenHeight)];
    self.locateMe =             [UIBarButtonItem barItemWithImage:@"LocateMe.png" target:self action:@selector(findCurrentPosition)];
    self.USAButton =            [UIBarButtonItem barItemWithImage:@"MiniUSA.png" target:self action:@selector(showUSA)];
    self.satelliteOnButton =    [UIBarButtonItem barItemWithImage:@"Satellite3ON.png" target:self action:@selector(toggleView:)];
    self.satelliteOffButton =   [UIBarButtonItem barItemWithImage:@"Satellite3OFF.png" target:self action:@selector(toggleView:)];
    self.mapResetBtn =          [UIBarButtonItem barItemWithImage:@"refresh.png" target:self action:@selector(ResetMap)];
    
    self.locateMe.enabled = YES;
    self.USAButton.enabled = YES;
    self.satelliteOnButton.enabled = YES;
    self.satelliteOffButton.enabled = YES;
    self.mapResetBtn.enabled = YES;
    
    [myToolBar setItems:[NSArray arrayWithObjects: locateMe, USAButton, mapResetBtn, satelliteOnButton, nil]];
    myToolBar.barStyle = UIBarStyleBlack;
    
    // build the view holding the top tool bar
    self.myToolBarView = [[UIView alloc] initWithFrame:CGRectMake(0, 
                                                                  0, 
                                                                  screenWidth,
                                                                  kPctOfScreenForToolBar * initialScreenHeight)];
    [myToolBarView addSubview:myToolBar];
    
    // build the top Search Bar
    self.mySearchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(screenWidth * kPctOfViewForButtons,
                                                                     kStatusBarBorder,
                                                                     screenWidth * (1 - kPctOfViewForButtons),
                                                                     kPctOfScreenForToolBar * initialScreenHeight)];
    mySearchBar.barStyle = UIBarStyleBlack;
    
    mySearchBar.delegate = self;
    
    [myToolBarView addSubview:mySearchBar];
    
    // add the toolbar view to the main view
    [self.view addSubview:myToolBarView];
    
    
    // build the map view
    self.myMapView = [[MKMapView alloc] 
                      initWithFrame:CGRectMake(0,
                                               kPctOfScreenForToolBar * initialScreenHeight + 1,
                                               screenWidth,
                                               initialScreenHeight * 
                                               (1 - kPctOfScreenForToolBar) - 1)];
    
    
    myMapView.delegate = self;
    
    self.tapInterceptor = [[WildcardGestureRecognizer alloc] init];
    
    tapInterceptor.touchesBeganCallback = ^(NSSet * touches, UIEvent * event) 
    {
        [self reOrient];        
    };
    
    [myMapView addGestureRecognizer:tapInterceptor];
    
    // also MKMapTypeSatellite or MKMapTypeHybrid
    self.myMapView.mapType = MKMapTypeStandard; 
    
    // myMapView.showsUserLocation = YES;

    [self.view addSubview:myMapView];
    
    [self drawMap];
}

//ok
- (void) viewWillAppear:(BOOL)animated
{    
    
    [super viewWillAppear:animated];
    
    if (self.navigationController.topViewController == self)
    {
        [self.navigationController setNavigationBarHidden:NO animated:animated];
    }
    else
    {
        [self.navigationController setNavigationBarHidden:YES animated:animated];        
    }
        
    [self reOrient];
    
}

//ok
-(void) reOrient
{
    
    //NSLog(@"reOrient longitudeDelta = %f", myMapView.region.span.longitudeDelta);
    
    navigationBarHeight     = self.navigationController.navigationBar.frame.size.height;
    
    [mySearchBar resignFirstResponder];
    
    CGFloat h,w;
    
    CGRect bounds = [[UIScreen mainScreen] applicationFrame];
    
    if (self.interfaceOrientation == UIInterfaceOrientationPortrait)
    {
        h = bounds.size.height;
        w = bounds.size.width;
    }
    else
    {
        w = bounds.size.height;
        h = bounds.size.width;
    }
    mySearchBar.frame = CGRectMake(w * kPctOfViewForButtons, kStatusBarBorder, 
                                   w * (1 - kPctOfViewForButtons), 
                                   kPctOfScreenForToolBar * initialScreenHeight);
    myToolBar.frame = CGRectMake(0, 0, w * kPctOfViewForButtons, kPctOfScreenForToolBar * initialScreenHeight);
    myToolBarView.frame = CGRectMake(0, 0, w, kPctOfScreenForToolBar * initialScreenHeight);
    
    
    myMapView.frame = CGRectMake(0, 
                                 kPctOfScreenForToolBar * initialScreenHeight + 1, 
                                 w, 
                                 h - (kPctOfScreenForToolBar * initialScreenHeight + 1));
    
    if (myMapView.mapType == MKMapTypeStandard)
    {
        [myToolBar setItems:[NSArray arrayWithObjects: locateMe, USAButton, mapResetBtn, satelliteOnButton, nil] animated:YES];
    }
    else
    {
        [myToolBar setItems:[NSArray arrayWithObjects: locateMe, USAButton, mapResetBtn, satelliteOffButton, nil] animated:YES];
    }
    
}

// ok
-(void)findCurrentPosition
{
    if ((dataController.myCurrentLocation.latitude == 0.0) && (dataController.myCurrentLocation.longitude == 0.0))
    {
        if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorized)
        {
            UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:[NSString stringWithFormat: @"Location Not Yet Found.\nPlease try later."]
                                                                     delegate:self cancelButtonTitle:nil destructiveButtonTitle:NSLocalizedString(@"Continue", @"Continue") otherButtonTitles: nil];
            actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
            [actionSheet showFromTabBar:self.tabBarController.tabBar];	// show from our table view (pops up in the middle of the table)
            [actionSheet release];            
        }
        else 
        {
            UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:[NSString stringWithFormat: @"Location Services Turned Off.\nUse Settings To Turn On."]
                                                                     delegate:self cancelButtonTitle:nil destructiveButtonTitle:NSLocalizedString(@"Continue", @"Continue") otherButtonTitles: nil];
            actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
            [actionSheet showFromTabBar:self.tabBarController.tabBar];	// show from our table view (pops up in the middle of the table)
            [actionSheet release];            
            
        }
    }
    else
    {
        [self gotoLatitude: [NSNumber numberWithDouble:dataController.myCurrentLocation.latitude] Longitude: [NSNumber numberWithDouble:dataController.myCurrentLocation.longitude]];
        
        [self reverseGeocodeUserCurrentLocation];        
    }
}

// ok
- (void)showUSA
{
    double highLatitude = 0.0;
    double lowLatitude = 0.0;
    double highLongitude = 0.0;
    double lowLongitude = 0.0;
    
    NSEnumerator * myQueriedProjectsEnumerator = [dataController.myQueriedProjectsFixed objectEnumerator];
    
    id projectObject;
    
    BOOL firstObject = TRUE;
    
    while ((projectObject = [myQueriedProjectsEnumerator nextObject])) 
    {
        Project * tempProject = (Project *) projectObject;
        
        if (firstObject == TRUE)
        {
            highLatitude    = tempProject.latitude;
            lowLatitude     = tempProject.latitude;
            highLongitude   = tempProject.longitude;
            lowLongitude    = tempProject.longitude;
            firstObject = FALSE;
        }
        else
        {
            if (highLatitude < tempProject.latitude)
            {
                highLatitude = tempProject.latitude;
            }
            if (lowLatitude > tempProject.latitude)
            {
                lowLatitude = tempProject.latitude;
            }
            if (highLongitude < tempProject.longitude)
            {
                highLongitude = tempProject.longitude;
            }
            if (lowLongitude > tempProject.longitude)
            {
                lowLongitude = tempProject.longitude;
            }
        }
        
    }
    
    [myMapView removeAnnotations:myMapView.annotations];  // remove any annotations
    
    MKCoordinateRegion newRegion;
    
    
    //need to find the center of the section
    
    newRegion.center.latitude = (highLatitude + lowLatitude) / 2;
    newRegion.center.longitude = (highLongitude + lowLongitude) / 2;
    
    newRegion.span.latitudeDelta = (highLatitude - lowLatitude);   
    newRegion.span.longitudeDelta = (highLongitude - lowLongitude);
    
    [myMapView regionThatFits:newRegion];
    [myMapView setRegion:newRegion animated:YES];
    
    [self reOrient];
}

// ok
- (void)toggleView: (id) sender
{
    
    if (myMapView.mapType ==MKMapTypeStandard)
    {
        myMapView.mapType = MKMapTypeHybrid;
        [myToolBar setItems:[NSArray arrayWithObjects: locateMe, USAButton, mapResetBtn, satelliteOffButton, nil] animated:YES];
    }
    else
    {
        myMapView.mapType = MKMapTypeStandard;
        [myToolBar setItems:[NSArray arrayWithObjects: locateMe, USAButton, mapResetBtn, satelliteOnButton, nil] animated:YES];
    }
}  

//ok
- (void)ResetMap
{
    //myState = @"-ALL-";
    MKCoordinateRegion newRegion;
    
    newRegion = myMapView.region;
    
    newRegion.span.longitudeDelta *= kSpanZoomOutFactor;
    newRegion.span.latitudeDelta  *= kSpanZoomOutFactor;

    [myMapView regionThatFits:newRegion];
    
    //NSLog(@"ResetMap longitudeDelta: %f", myMapView.region.span.longitudeDelta);
    //NSLog(@"ResetMap latitudeDelta: %f", myMapView.region.span.latitudeDelta);
    
    [self.myMapView setRegion:newRegion animated:YES];
    
    // made syncImages specific to a projectID, so moved it to AnnotationQueryDetailViewController viewDidLoad
    // self.mapResetBtn.enabled = NO;
    // [[AppDelegate sharedAppDelegate] syncImages];
    // self.mapResetBtn.enabled = YES;    
}

//ok
- (void)gotoLatitude: (NSNumber *)latitude Longitude: (NSNumber *) longitude
{
    MKCoordinateRegion newRegion;
    newRegion.center.latitude = [latitude doubleValue];
    newRegion.center.longitude = [longitude doubleValue];
    newRegion.span.latitudeDelta = kSpanLatitudeDelta;
    newRegion.span.longitudeDelta = kSpanLongitudeDelta;
    
    [myMapView regionThatFits:newRegion];    
    
    [self.myMapView setRegion:newRegion animated:YES];
}

//ok
-(void) reverseGeocodeUserCurrentLocation
{
    self.reverseGeocoder = [[[MKReverseGeocoder alloc] initWithCoordinate:CLLocationCoordinate2DMake(dataController.myCurrentLocation.latitude, dataController.myCurrentLocation.longitude)] autorelease];
    reverseGeocoder.delegate = self;
    [reverseGeocoder start];
}

//ok
- (void)reverseGeocode 
{
	SVGeocoder *geocodeRequest = [[SVGeocoder alloc] initWithCoordinate:CLLocationCoordinate2DMake(dataController.myCurrentLocation.latitude , dataController.myCurrentLocation.longitude)];
    [geocodeRequest setDelegate:self];
	[geocodeRequest startAsynchronous];
}

//ok
- (void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFailWithError:(NSError *)error
{
    NSString *errorMessage = [error localizedDescription];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Cannot obtain address."
														message:errorMessage
													   delegate:nil
											  cancelButtonTitle:@"OK"
											  otherButtonTitles:nil];
    [alertView show];
    [alertView release];
}

//ok
- (void)geocode 
{
	SVGeocoder *geocodeRequest = [[SVGeocoder alloc] initWithAddress:mySearchBar.text];
	[geocodeRequest setDelegate:self];
	[geocodeRequest startAsynchronous];
}

//ok
- (void)geocoder:(SVGeocoder *)geocoder didFailWithError:(NSError *)error 
{
	
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:[error description] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
	[alertView show];
	[alertView release];
	
}

//ok
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar   
{
    CGFloat screenHeight            = [[UIScreen mainScreen] applicationFrame].size.height;
    
    if (self.interfaceOrientation == UIInterfaceOrientationPortrait)
    {
        [searchBar setFrame:CGRectMake(0, 0, [[UIScreen mainScreen] applicationFrame].size.width, kPctOfScreenForToolBar * screenHeight)];
    }
    else
    {
        [searchBar setFrame:CGRectMake(0, 0, [[UIScreen mainScreen] applicationFrame].size.height, kPctOfScreenForToolBar * screenHeight)];
    }
    //[self reOrient];
}

//ok
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self reOrient];
    [self geocode];
}

// ok
-(BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return (toInterfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

// ok
-(void) willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration  
{
    [self reOrient];
}

// ok
- (void)viewDidUnload
{
    self.locateMe = nil;
    self.USAButton = nil;
    self.tapInterceptor = nil;
    //self.myAddress = nil;
    //self.myZip = nil;
    //self.myCongressCode = nil;
    //self.myState = nil;
    self.myMapView = nil;
    self.mySearchBar = nil;
    self.myToolBar = nil;
    self.myToolBarView = nil;
    self.reverseGeocoder = nil;
    self.mapResetBtn = nil;
    
    [super viewDidUnload];
}

// ok
- (void)dealloc
{
    [mapResetBtn release];
    //[myCongressCode release];
    //[myState release];
    [locateMe release];    
    [USAButton release];
    [myToolBarView release];
    [tapInterceptor release];
    //[myAddress release];
    //[myZip release];
    [myMapView release];
    [mySearchBar release];
    [myToolBar release];
    [myToolBarView release];
    [reverseGeocoder release];
    
    [super dealloc];
}


/*
 - (void) propertyAction: (id) sender
 {
     double lat = myMapView.region.center.latitude;
     double lon = myMapView.region.center.longitude;
     double latDelta = myMapView.region.span.latitudeDelta;
     double lonDelta = myMapView.region.span.longitudeDelta;
 
     [self.myMapView removeAnnotations:self.myMapView.annotations];  // remove any annotations
 
     for (Project *tempProject in [dataController.myQueriedProjectsFixed allValues])
     {
         if ((tempProject.latitude <= lat + latDelta / 2) && (tempProject.latitude >= lat - latDelta / 2) &&
             (tempProject.longitude <= lon + lonDelta / 2) && (tempProject.longitude >= lon - lonDelta / 2))
        {
            //NSLog(@"Latitude: %f, Longitude: %f", tempProject.latitude, tempProject.longitude);
 
            PropertyAnnotation *p = [[PropertyAnnotation alloc] initWithName:tempProject.name Latitude:tempProject.latitude Longitude:tempProject.longitude Address:tempProject.address City:tempProject.city State:tempProject.state ZipCode:tempProject.zipCode ProjectID:[NSString stringWithFormat:@"%d", tempProject.projectID] Animated:YES];
 
            [self.myMapView addAnnotation:p];
            [p release];
 
        }
     }
 }

-(BOOL) checkForValue:(NSString *)myString
{
    if(![[myString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]length] == 0)
        return NO;
    else
        return YES;
}

- (void) propertyActionCongress: (id) sender
{
    NSArray *a = [dataController getPropertiesCongress: myState: myCongressCode];
    
    [self.myMapView removeAnnotations:self.myMapView.annotations];  // remove any annotations
    
    for (NSDictionary *d in a)
    {
        NSString *name = [d objectForKey:@"Name"];
        NSNumber *latitude = [d objectForKey:@"Latitude"];
        NSNumber *longitude = [d objectForKey:@"Longitude"];
        NSString *address = [d objectForKey:@"Address"];
        NSString *city = [d objectForKey:@"City"];
		NSString *state = [d objectForKey:@"State"];
		NSString *zipCode = [d objectForKey:@"ZipCode"];
        NSString *projID = [d objectForKey:@"ProjectId"];
        
		PropertyAnnotation *p = [[PropertyAnnotation alloc] initWithName:name Latitude:[latitude doubleValue] Longitude:[longitude doubleValue] Address:address City:city State:state ZipCode:zipCode ProjectID:projID Animated:YES];
        
        [self.myMapView addAnnotation:p];
        [p release];
    }
}

- (void)propertyActionAll:(id)sender
{
    
    NSArray *a = [dataController getPropertiesAll];
    
    [self.myMapView removeAnnotations:self.myMapView.annotations];  // remove any annotations
    for (NSDictionary *d in a)
    {
        NSString *name = [d objectForKey:@"Name"];
        NSNumber *latitude = [d objectForKey:@"Latitude"];
        NSNumber *longitude = [d objectForKey:@"Longitude"];
        NSString *address = nil;
        NSString *city = nil;
		NSString *state = [d objectForKey:@"State"];
		NSString *zipCode = [d objectForKey:@"ZipCode"];
		NSString *projId = @"Projects in :";
        
        
		PropertyAnnotation *p = [[PropertyAnnotation alloc] initWithName:name Latitude:[latitude doubleValue] Longitude:[longitude doubleValue] Address:address City:city State:state ZipCode:zipCode ProjectID:projId Animated:NO];
        [self.myMapView addAnnotation:p];
        [p release];
    }
    //    animateDrop = YES;
}

- (IBAction)USMapAction:(id)sender
{
	[self showUSA];
	[self propertyActionAll:sender];
}

- (NSString *)dataFilePath 
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [[[NSString alloc]initWithString:[paths objectAtIndex:0]] autorelease];
    
    return [documentsDirectory stringByAppendingPathComponent:@"/myData.plist"];
}

*/
 
@end

