@interface District : NSObject 
{
    NSString *  district;
    double      latitude;
    double      longitude;
    int         count;
}

@property (nonatomic, retain) NSString *  district;
@property (nonatomic, assign) double      latitude;
@property (nonatomic, assign) double      longitude;
@property (nonatomic, assign) int         count;

@end