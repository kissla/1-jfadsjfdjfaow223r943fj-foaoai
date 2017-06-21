#import "District.h"

@implementation District

@synthesize district;
@synthesize longitude;
@synthesize latitude;
@synthesize count;

- (NSComparisonResult) compareDistrictNames: (id) object1
{	
    District * tempDistrict1 = (District *) object1;
    District * tempDistrict2 = (District *) self;
    
	NSComparisonResult myResult = [tempDistrict2.district intValue] - [tempDistrict1.district intValue];
    
	return myResult;
}

- (void)dealloc 
{
    [district release];    
    [super dealloc];
}

@end