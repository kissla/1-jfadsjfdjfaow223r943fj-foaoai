//
//  Location.h
//  PropertySeach
//
//  Created by joey on 2/27/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@protocol LocationDelegate 

@required
- (void)locationUpdate:(CLLocation *)location;
- (void)locationError:(NSError *)error;
@end

@interface Location : NSObject <CLLocationManagerDelegate, UIActionSheetDelegate> 
{
	CLLocationManager * locationManager;
    id                  delegate;
}

@property (nonatomic, retain) CLLocationManager * locationManager;  
@property (nonatomic, assign) id                  delegate;

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation;

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error;

@end

