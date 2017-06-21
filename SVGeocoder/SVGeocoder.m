//
//  SVGeocoder.m
//
//  Created by Sam Vermette on 07.02.11.
//  Copyright 2011 Sam Vermette. All rights reserved.
//

#import "SVGeocoder.h" 
#import <Contacts/Contacts.h>

@implementation SVGeocoder

@synthesize delegate;

#pragma mark -

- (SVGeocoder*)initWithCoordinate:(CLLocationCoordinate2D)coordinate {
	
	NSString *requestString = [NSString stringWithFormat:@"http://maps.googleapis.com/maps/api/geocode/json?latlng=%f,%f&sensor=true", coordinate.latitude, coordinate.longitude];
	NSLog(@"SVGeocoder -> reverse geocoding: %f, %f", coordinate.latitude, coordinate.longitude);
	
	request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:requestString]];
	
	return self;
}

- (SVGeocoder*)initWithAddress:(NSString*)address {
	
	NSString *urlEncodedAddress = (NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)address, NULL, CFSTR("?=&+"), kCFStringEncodingUTF8);
	
	NSString *requestString = [NSString stringWithFormat:@"http://maps.googleapis.com/maps/api/geocode/json?address=%@&sensor=true", urlEncodedAddress];
	[urlEncodedAddress release];
	
	NSLog(@"SVGeocoder -> geocoding: %@", address);
	
	request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:requestString]];

	return self;
}

#pragma mark -

- (void)setDelegate:(id <SVGeocoderDelegate>)newDelegate {
	
	delegate = newDelegate;
}


- (void)startAsynchronous {
	
	responseData = [[NSMutableData alloc] init];
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request
                                                completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
                                      {
                                          // do something with the data 
                                          NSDictionary* responseJSON = [NSJSONSerialization JSONObjectWithData:data options:nil error:&error];
                                          [self jsonExtractor:responseJSON];
//                                          NSArray* latestLoans = [json objectForKey:@"loans"];
                                          
                                          NSLog(@"loans: %@", responseJSON);
                                      }];
    [dataTask resume];
    
}

#pragma mark -
#pragma mark NSURLConnectionDelegate

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	
	[responseData appendData:data];
}


-(void)jsonExtractor:(NSDictionary *)responseDict {
    NSError *jsonError = NULL;
	if(responseDict == nil || [responseDict valueForKey:@"results"] == nil || [[responseDict valueForKey:@"results"] count] == 0) {
		
        [self.delegate geocoder:self didFailWithError:jsonError];
        return;
	}
	
	NSDictionary *addressDict = [[[responseDict valueForKey:@"results"] objectAtIndex:0] valueForKey:@"address_components"];
	NSDictionary *coordinateDict = [[[[responseDict valueForKey:@"results"] objectAtIndex:0] valueForKey:@"geometry"] valueForKey:@"location"];
	
	float lat = [[coordinateDict valueForKey:@"lat"] floatValue];
	float lng = [[coordinateDict valueForKey:@"lng"] floatValue];
	
	NSMutableDictionary *formattedAddressDict = [[NSMutableDictionary alloc] init];
	
	for(NSDictionary *component in addressDict) {
		
		NSArray *types = [component valueForKey:@"types"];
		
		if([types containsObject:@"street_number"])
			[formattedAddressDict setValue:[component valueForKey:@"long_name"] forKey:CNPostalAddressStreetKey];
		
		if([types containsObject:@"route"])
			[formattedAddressDict setValue:[[formattedAddressDict valueForKey:(NSString*)CNPostalAddressStreetKey] stringByAppendingFormat:@" %@",[component valueForKey:@"long_name"]] forKey:(NSString*)CNPostalAddressStreetKey];
		
		if([types containsObject:@"locality"])
			[formattedAddressDict setValue:[component valueForKey:@"long_name"] forKey:(NSString*)CNPostalAddressCityKey];
		
		if([types containsObject:@"administrative_area_level_1"])
			[formattedAddressDict setValue:[component valueForKey:@"long_name"] forKey:(NSString*)CNPostalAddressStateKey];
		
		if([types containsObject:@"postal_code"])
			[formattedAddressDict setValue:[component valueForKey:@"long_name"] forKey:(NSString*)CNPostalAddressPostalCodeKey];
		
		if([types containsObject:@"country"]) {
			[formattedAddressDict setValue:[component valueForKey:@"long_name"] forKey:(NSString*)CNPostalAddressCountryKey];
			[formattedAddressDict setValue:[component valueForKey:@"short_name"] forKey:(NSString*)CNPostalAddressISOCountryCodeKey];
		}
	}
	
	MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:CLLocationCoordinate2DMake(lat, lng) addressDictionary:formattedAddressDict];
	[formattedAddressDict release];
	
	NSLog(@"SVGeocoder -> Found Placemark");
	[self.delegate geocoder:self didFindPlacemark:placemark];
	[placemark release];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
		
	[self.delegate geocoder:self didFailWithError:error];
}

#pragma mark -

- (void)dealloc {
	
	[request release];
	[responseData release];
	[rConnection release];
	
	[super dealloc];
}

@end
