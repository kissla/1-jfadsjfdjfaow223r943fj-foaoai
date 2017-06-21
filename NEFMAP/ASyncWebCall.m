#import "AsyncWebCall.h"


@implementation AsyncWebCall
@synthesize resultString;

- (void)loadHTMLFromURL:(NSURL*)url 
{
    if (connection!=nil) 
    { 
        [connection release]; 
    }
    if (data!=nil) 
    { 
        [data release]; 
    }
    NSURLRequest* request = [NSURLRequest requestWithURL:url
											 cachePolicy:NSURLRequestReturnCacheDataElseLoad
										 timeoutInterval:60.0];
    connection = [[NSURLConnection alloc]
				  initWithRequest:request delegate:self];
    //TODO error handling, what if connection is nil?
}

- (void)connection:(NSURLConnection *)theConnection
    didReceiveData:(NSData *)incrementalData 
{
    if (data==nil) 
    {
		data =
		[[NSMutableData alloc] initWithCapacity:2048];
    }
    [data appendData:incrementalData];
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)connectionDidFinishLoading:(NSURLConnection*)theConnection 
{
    [connection release];
    connection=nil;
	
	self.resultString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    [data release];
    data=nil;
    NSLog(@"Result String: %@", resultString);
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"URLFinishedLoading" object:nil ];
}

- (void)dealloc 
{
    [resultString release];
    [connection cancel];
    [connection release];
    [data release];
    [super dealloc];
}

@end