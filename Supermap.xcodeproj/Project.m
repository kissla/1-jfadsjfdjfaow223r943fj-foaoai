#import "Project.h"

@implementation Project


- (id)initWithJSONDictionary:(NSDictionary *)jsonDictionary {
    if(self = [self init]) {
        
        _Project_ID = [jsonDictionary objectForKey:@"Project_ID"];
        _ProjectName = [jsonDictionary objectForKey:@"ProjectName"];
        _LimitedPartnershipName = [jsonDictionary objectForKey:@"LimitedPartnershipName"];
        //        _LegalEntityName = [jsonDictionary objectForKey:@"visited"];
        _Address1 = [jsonDictionary objectForKey:@"streetAddress"];
        _city = [jsonDictionary objectForKey:@"city"];
        _zip = [jsonDictionary objectForKey:@"ZipCode"];
        _state = [jsonDictionary objectForKey:@"StateshortName"];
        _TotalUnits = [self validStringCheck:[[jsonDictionary objectForKey:@"UnitCount"] stringValue] ];
        _LIHTCUnits = [self validStringCheck:[[jsonDictionary objectForKey:@"UnitCountLIHTC"] stringValue] ];
        _latitude = [[jsonDictionary objectForKey:@"latitude"] doubleValue];
        _longitude = [[jsonDictionary objectForKey:@"longitude"] doubleValue];
        _PopulationServedTypeListName = [self validStringCheck:[jsonDictionary objectForKey:@"PopulationServedTypeListName"] ];
        _markettype = [self validStringCheck:[jsonDictionary objectForKey:@"MarketType"]];
        _ProjectClosingDate = [jsonDictionary objectForKey:@"ProjectClosingDate"];
        _PropertyManager = [self validStringCheck:[jsonDictionary objectForKey:@"PropertyManager"]];
        _No_of_1BR_Units = [self validStringCheck:[[jsonDictionary objectForKey:@"No_Of_1BR_Units"] stringValue]];
        _No_of_2BR_Units = [self validStringCheck:[[jsonDictionary objectForKey:@"No_Of_2BR_Units"] stringValue]];
        _No_of_3BR_Units = [self validStringCheck:[[jsonDictionary objectForKey:@"No_Of_3BR_Units"] stringValue]];
        _No_of_Other_Units = [self validStringCheck:[[jsonDictionary objectForKey:@"No_of_Other_Units"] stringValue]];
        _JobsCreatedYearOne = [self validStringCheck:[[jsonDictionary objectForKey:@"jobscreatedyearone"] stringValue]];
        _CommunityImpactYearOne = [jsonDictionary objectForKey:@"CommunityImpactYearOne"];
        _JobsCreatedOnGoing = [self validStringCheck:[[jsonDictionary objectForKey:@"jobscreatedongoing"] stringValue]];
        _CommunityImpactOnGoing = [jsonDictionary objectForKey:@"CommunityImpactOngoing"];
        _CongressCode = [self validStringCheck:[jsonDictionary objectForKey:@"CongressionalDistrict"]];
        _projectStageTypeListName = [jsonDictionary objectForKey:@"ProjectStageTypeLisName"];
        _FundNames = [jsonDictionary objectForKey:@"FundNames"];
        _Sponsor = [self validStringCheck:[jsonDictionary objectForKey:@"Sponsor"]];
        _StateshortName = [jsonDictionary objectForKey:@"StateshortName"];
        _DeveloperCost = [jsonDictionary objectForKey:@"DeveloperCost"];
        _PermLoanLender1 = [self validStringCheck:[jsonDictionary objectForKey:@"PermLoanLender1"]];
        _CensusCounty = [self validStringCheck:[jsonDictionary objectForKey:@"CensusCounty"]];
        _CensusTract = [self validStringCheck:[jsonDictionary objectForKey:@"CensusTract"]];
        _ProjectDescription = [self validStringCheck:[jsonDictionary objectForKey:@"projectDescription"] ];
        _ProjectAttributes = [self validStringCheck:[jsonDictionary objectForKey:@"ProjectAttributes"] ];
        _MSA = [self validStringCheck:[jsonDictionary objectForKey:@"MSA"]];
        
    }
    
    return self;
}

-(NSString *)validStringCheck :(NSString *)strpass{
    if ([strpass isEqual:[NSNull null]] || strpass==nil || [strpass isEqualToString:@"<null>"] || [strpass isEqualToString:@"(null)"] || strpass.length==0 || [strpass isEqualToString:@""])
    {
        return @"null";
    }
    return strpass;
}

- (NSComparisonResult) compareProjectNames: (id) object1
{	
    Project * tempProject1 = (Project *) object1;
    Project * tempProject2 = (Project *) self;
    
	NSComparisonResult myResult = [[tempProject2.ProjectName uppercaseString] compare: [tempProject1.ProjectName uppercaseString]];
    
	return myResult;
}

@end
