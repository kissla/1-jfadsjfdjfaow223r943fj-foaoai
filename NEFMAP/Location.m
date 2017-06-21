//
//  Location.m
//  PropertySeach
//
//  Created by joey on 2/27/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Location.h"

@implementation Location

@synthesize locationManager;
@synthesize delegate;
//@synthesize currentLocation;

- (id) init 
{
    self = [super init];
    if (self != nil) {
        
        self.locationManager = [[[CLLocationManager alloc] init] autorelease];

        self.locationManager.delegate = self; // send loc updates to myself        
                        
    }
    return self;
}

        

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    //NSLog(@"OLD latitude %+.6f, longitude %+.6f, timestamp: %@\n", oldLocation.coordinate.latitude, oldLocation.coordinate.longitude,[oldLocation.timestamp description]);
    
    NSLog(@"NEF latitude %+.6f, longitude %+.6f, timestamp: %@\n",
          newLocation.coordinate.latitude,
          newLocation.coordinate.longitude,
          [newLocation.timestamp description]);
    

    if (oldLocation.timestamp != nil)
    {
        [self.delegate  locationUpdate:newLocation];        
    }
    else
    {
        NSLog(@"Ignore cached location");
    }
    
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
	NSLog(@"Error: %@", [error description]);
    [self.delegate locationError:error];
}

- (void)dealloc 
{
    [self.locationManager release];
    [super dealloc];
}

@end
