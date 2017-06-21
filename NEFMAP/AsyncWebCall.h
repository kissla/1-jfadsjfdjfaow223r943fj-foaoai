@interface AsyncWebCall : NSObject 
{
	NSURLConnection *connection;
    NSMutableData *data;
    NSString *resultString;
}

@property (nonatomic, retain) NSString *resultString;
- (void)loadHTMLFromURL:(NSURL*)url;


@end