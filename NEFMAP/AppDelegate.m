/*
     File: AppDelegate.m
 Abstract: Displays the application window.
 
  Version: 1.2
 
 Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple
 Inc. ("Apple") in consideration of your agreement to the following
 terms, and your use, installation, modification or redistribution of
 this Apple software constitutes acceptance of these terms.  If you do
 not agree with these terms, please do not use, install, modify or
 redistribute this Apple software.
 
 In consideration of your agreement to abide by the following terms, and
 subject to these terms, Apple grants you a personal, non-exclusive
 license, under Apple's copyrights in this original Apple software (the
 "Apple Software"), to use, reproduce, modify and redistribute the Apple
 Software, with or without modifications, in source and/or binary forms;
 provided that if you redistribute the Apple Software in its entirety and
 without modifications, you must retain this notice and the following
 text and disclaimers in all such redistributions of the Apple Software.
 Neither the name, trademarks, service marks or logos of Apple Inc. may
 be used to endorse or promote products derived from the Apple Software
 without specific prior written permission from Apple.  Except as
 expressly stated in this notice, no other rights or licenses, express or
 implied, are granted by Apple herein, including but not limited to any
 patent rights that may be infringed by your derivative works or by other
 works in which the Apple Software may be incorporated.
 
 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
 MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
 THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
 FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
 OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.
 
 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
 OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
 MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
 AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
 STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE.
 
 Copyright (C) 2010 Apple Inc. All Rights Reserved.
 
 */

#import "AppDelegate.h"

@interface AppDelegate ()

@property (nonatomic, assign) NSInteger             networkingCount;

@end

@implementation AppDelegate

@synthesize window;
@synthesize myQueryTableViewController;
@synthesize myMapQueryViewController;
@synthesize myNavController;
@synthesize dataController;
@synthesize myLocation;

@synthesize networkingCount = _networkingCount;
@synthesize connection      = _connection;
@synthesize filePath        = _filePath;
@synthesize fileStream      = _fileStream;


- (void)applicationDidEnterBackground:(UIApplication *)application
{
    [myLocation.locationManager stopMonitoringSignificantLocationChanges];
    [myLocation.locationManager stopUpdatingLocation];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [myLocation.locationManager startMonitoringSignificantLocationChanges];
    [myLocation.locationManager startUpdatingLocation];
}


- (void)applicationWillTerminate:(UIApplication *)application 
{
    [dataController.statesTable release];
    
    [dataController.statesTableKeysSorted release];
    
    [dataController.statesDistrictsTable removeAllObjects];
    [dataController.statesDistrictsTable release];
    
    [dataController.statesDistrictsTableNamesSorted removeAllObjects];
    [dataController.statesDistrictsTableNamesSorted release];
    
    [dataController.sponsorsTable release];
    
    [dataController.sponsorsTableKeysSorted release];

    [dataController.myQueriedProjectsFixed release];

    [dataController.myQueriedProjects removeAllObjects];
    [dataController.myQueriedProjects release];

    [dataController.projectsTableNamesSorted removeAllObjects];
    [dataController.projectsTableNamesSorted release];
    
    [dataController.uaAlphaCurrent release];
    
    [dataController.indexListProjects release];
}
    - (void)locationError:(NSError *)error 
{
    NSLog(@"Location error: %@", [error localizedDescription]);    
}

// delegate callback method called when location has been found
- (void)locationUpdate:(CLLocation *)location 
{
    dataController.myCurrentLocation = [location coordinate];    

    //we are still monitoring significant changes which is turned on (and never turned off) during Location creation (see Location.m)
    [myLocation.locationManager stopUpdatingLocation];    
}

- (void) syncImagesSingle : (NSString *)projectID
{
    NSMutableDictionary * destinationImages = [[NSMutableDictionary alloc] initWithCapacity:0];
    
    NSMutableDictionary * sourceImages      = [[NSMutableDictionary alloc] initWithCapacity:0];
    
    NSFileManager * myFileManager = [[NSFileManager alloc] init];
    
    NSBundle * myBundle = [NSBundle mainBundle];
    
    
    // get local image portfolio (destination)
    NSString    * destDirectoryPath = [NSHomeDirectory() stringByAppendingFormat:@"/Documents"];
    
    NSMutableSet * destDirectories = [[NSMutableSet alloc] initWithArray: [myFileManager contentsOfDirectoryAtPath:destDirectoryPath error:nil]];
    
    NSEnumerator * destDirEnumerator = [destDirectories objectEnumerator];
    
    id dirValue;
    
    while ((dirValue = [destDirEnumerator nextObject])) 
    {
        if ([(NSString *) dirValue compare: kDSStore])
        {
            NSString    * filePath = [NSHomeDirectory() stringByAppendingFormat:@"/Documents/%@", (NSString *) dirValue];
            
            NSMutableSet * tempFiles = [[NSMutableSet alloc] initWithArray: [myFileManager contentsOfDirectoryAtPath:filePath error:nil]];
            
            [destinationImages setObject:tempFiles forKey:dirValue];
            
            [tempFiles release];
            
        }
    }
    
    [destDirectories release];
    /*
    // print the destination image file names
    NSEnumerator * dictionaryEnumerator = [destinationImages keyEnumerator];
    
    while ((dirValue = [dictionaryEnumerator nextObject])) 
    {
        NSSet * mySet = (NSSet *) [destinationImages objectForKey:dirValue]; 
        
        NSEnumerator * fileEnumerator = [mySet objectEnumerator];
        
        id fileValue;
        
        while ((fileValue = [fileEnumerator nextObject])) 
        {
            NSLog(@"Destination Directory: %@, File: %@", (NSString *) dirValue, (NSString *) fileValue);            
        }
    }
    */
    
    // get remote image portfolio (source)
    NSMutableURLRequest * req = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", kServerScriptImagesPath2, projectID]]];
    NSHTTPURLResponse * returnResponse = nil;
    NSError * returnError = nil;
    
    NSString * str;
    
    if ([NSURLConnection canHandleRequest:req] == YES)
    {
        NSData * returnData = [NSURLConnection sendSynchronousRequest:req returningResponse:&returnResponse error:&returnError];        
        
        int statusCode = returnResponse.statusCode;
        
        str = [[[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding] autorelease];
        
        //NSLog(@"PHP Output: %@", str);
        
        if ((statusCode == 200) && (!returnError))
        {
            //NSLog(@"Directory downloaded successfully! Status code: 200");
        }
        else
        {
            NSLog(@"Failed to download directory with error.\nStatus code: %d\nError: %@", statusCode, [returnError localizedDescription]);
        }
    }
    else
    {
        NSLog(@"Website %@ not available.", kServerScriptImagesPath2);
        str = [NSString stringWithFormat:@""];
    }
    
    NSArray * splitImageFiles = [str componentsSeparatedByString:@"\n"];
    
    for (int i = 0; i < [splitImageFiles count]; i++)
    {
        NSString * imageFileString = [NSString stringWithString: (NSString *) [splitImageFiles objectAtIndex:i]];
        NSArray * splitLine = [imageFileString componentsSeparatedByString:@"/"];
        NSString * integrityString = [NSString stringWithString: (NSString *) [splitLine objectAtIndex: 0]];
        
        if (![integrityString compare:kImageFilePrefix])
        {
            NSString * tempDirectory = (NSString *) [splitLine objectAtIndex:1];
            NSString * tempFileName  = (NSString *) [splitLine objectAtIndex:2];
            
            NSMutableSet * tempMutableSet = (NSMutableSet *) [sourceImages objectForKey:(id) tempDirectory];
            
            if (tempMutableSet == nil)
            {
                tempMutableSet = [NSMutableSet setWithCapacity:0];
            }
            [tempMutableSet addObject:(id) tempFileName];
            
            [sourceImages setObject:tempMutableSet forKey: (id) tempDirectory];

        }
    }
    
    // print the source image file names
    
    /*
    dictionaryEnumerator = [sourceImages keyEnumerator];
    
    while ((dirValue = [dictionaryEnumerator nextObject])) 
    {
        NSSet * mySet = (NSSet *) [sourceImages objectForKey:dirValue]; 
        
        NSEnumerator * fileEnumerator = [mySet objectEnumerator];
        
        id fileValue;
        
        while ((fileValue = [fileEnumerator nextObject])) 
        {
            NSLog(@"Source Directory: %@, File: %@", (NSString *) dirValue, (NSString *) fileValue);            
        }
        
    }
    */
    
    
    // get the source and dest directories    
    NSMutableSet * tempSourceKeys = [[NSMutableSet alloc] initWithArray:[sourceImages allKeys]];
    
    NSMutableSet * tempDestKeys   = [[NSMutableSet alloc] initWithArray:[destinationImages allKeys]];
    
    BOOL moreDownloads = YES;
    
    
    // find an intersection download
    NSMutableSet * tempIntersectionDirSet = [[NSMutableSet alloc] initWithSet:tempSourceKeys];
    
    [tempIntersectionDirSet intersectSet:tempDestKeys];
    
    NSEnumerator * tempEnumerator = [tempIntersectionDirSet objectEnumerator];
    
    while ((dirValue = [tempEnumerator nextObject])) 
    {
        //NSLog(@"Intersection set: %@", (NSString *) dirValue);
        
        NSMutableSet * tempSetSource = (NSMutableSet *) [sourceImages objectForKey: (id) dirValue];
        
        NSMutableSet * tempSetDest   = (NSMutableSet *) [destinationImages objectForKey: (id) dirValue];
        
        NSMutableSet * tempAddFileSet = [[NSMutableSet alloc] initWithSet:tempSetSource];
        
        [tempAddFileSet minusSet:tempSetDest];
        
        NSEnumerator * tempSetEnumerator = [tempAddFileSet objectEnumerator];
        
        id fileValue;
        
        while ((fileValue = [tempSetEnumerator nextObject])) 
        {
            if (moreDownloads == YES)
            {                
                NSString * myFile = [NSString stringWithFormat:@"%@", (NSString *) fileValue];
                
                NSArray * splitLine = [myFile componentsSeparatedByString:@"."];
                
                NSString * myBundleFilePath = nil;
                
                if ([splitLine count] == 2)
                {                
                    myBundleFilePath = [myBundle pathForResource:(NSString *) [splitLine objectAtIndex:0] ofType: (NSString *) [splitLine objectAtIndex:1] inDirectory:@"ImagesOfProjects"];
                }
                
                if (myBundleFilePath != nil)
                {
                    NSLog(@"%@ in bundle!!!", (NSString *) fileValue);
                    [myFileManager copyItemAtPath:myBundleFilePath toPath:[NSHomeDirectory() stringByAppendingFormat:@"/Documents/%@/%@", (NSString *) dirValue, (NSString *) fileValue] error:nil];
                }
                else
                {
                    //NSLog(@"Dir: %@, File: %@", (NSString *) dirValue, (NSString *) fileValue);
                    [self _startReceive : (NSString *) dirValue : (NSString *) fileValue];                    
                    moreDownloads = NO;
                }
                
            }
            
        }
        
        [tempAddFileSet release];
        
        NSMutableSet * tempDeleteFileSet = [[NSMutableSet alloc] initWithSet:tempSetDest];
        
        [tempDeleteFileSet minusSet:tempSetSource];
        
        tempSetEnumerator = [tempDeleteFileSet objectEnumerator];
        
        while ((fileValue = [tempSetEnumerator nextObject])) 
        {
            [myFileManager removeItemAtPath:[NSHomeDirectory() stringByAppendingFormat:@"/Documents/%@/%@", (NSString *) dirValue, (NSString *) fileValue] error:nil];
        }
        
        [tempDeleteFileSet release];
    }
    
    [tempIntersectionDirSet release];
    
    // find an add directory download
    NSMutableSet * tempAddDirSet = [[NSMutableSet alloc] initWithSet:tempSourceKeys];
    
    [tempAddDirSet minusSet:tempDestKeys];
    
    tempEnumerator = [tempAddDirSet objectEnumerator];
    
    while ((dirValue = [tempEnumerator nextObject])) 
    {
        //NSLog(@"Add set: %@", (NSString *) dirValue);
        
        NSSet * tempSet = (NSSet *) [sourceImages objectForKey: (id) dirValue];
        
        NSEnumerator * tempSetEnumerator = [tempSet objectEnumerator];
        
        id fileValue;
        
        while ((fileValue = [tempSetEnumerator nextObject])) 
        {
            if (moreDownloads == YES)
            {                
                [myFileManager createDirectoryAtPath:[NSHomeDirectory() stringByAppendingFormat:@"/Documents/%@", (NSString *) dirValue]  withIntermediateDirectories:YES attributes:nil error:nil];
                
                NSString * myFile = [NSString stringWithFormat:@"%@", (NSString *) fileValue];
                
                NSArray * splitLine = [myFile componentsSeparatedByString:@"."];
                
                NSString * myBundleFilePath = nil;
                
                if ([splitLine count] == 2)
                {                
                    myBundleFilePath = [myBundle pathForResource:(NSString *) [splitLine objectAtIndex:0] ofType: (NSString *) [splitLine objectAtIndex:1] inDirectory:@"ImagesOfProjects"];
                }
                
                if (myBundleFilePath != nil)
                {
                    NSLog(@"%@ in bundle!!!", (NSString *) fileValue);
                    [myFileManager copyItemAtPath:myBundleFilePath toPath:[NSHomeDirectory() stringByAppendingFormat:@"/Documents/%@/%@", (NSString *) dirValue, (NSString *) fileValue] error:nil];
                }
                else
                {
                   // NSLog(@"Dir: %@, File: %@", (NSString *) dirValue, (NSString *) fileValue);
                    
                    [self _startReceive : (NSString *) dirValue : (NSString *) fileValue];                    
                    moreDownloads = NO;
                }
            }
            
        }
    }
    
    [tempAddDirSet release];
    
    [tempDestKeys release];
    
    [tempSourceKeys release];
    
    [destinationImages release];
    
    [sourceImages release];
    
    [myFileManager release];
        
}

- (void)applicationDidFinishLaunching:(UIApplication *)application 
{
    DataAccess *controller = [[DataAccess alloc] init];
	self.dataController = controller;
    [controller release];
    
    myLocation = [[Location alloc] init];
    myLocation.delegate = self;
    
    myMapQueryViewController = [[MapQueryViewController alloc] init];
    myMapQueryViewController.dataController = dataController;
    
    myQueryTableViewController = [[QueryTableViewController alloc] initWithStyle:UITableViewStylePlain];
    myQueryTableViewController.dataController = dataController;
    
    UITabBarItem * mapTabBarItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"Complete Map",@"Complete Map") image:nil tag:0];
	UITabBarItem * searchTabBarItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"Search",@"Search") image:nil tag:1];
    
    myMapQueryViewController.tabBarItem = mapTabBarItem;
    myQueryTableViewController.tabBarItem = searchTabBarItem;
    
    [mapTabBarItem release];
    [searchTabBarItem release];
    
	UITabBarController * tabBarController = [[UITabBarController alloc] init];

	tabBarController.viewControllers = [NSArray arrayWithObjects: myMapQueryViewController, myQueryTableViewController, nil];
    
	tabBarController.selectedViewController = myMapQueryViewController;
    
    tabBarController.title = @"Complete Map";
    
    myNavController = [[UINavigationController alloc] initWithRootViewController:tabBarController];
    
    myNavController.navigationBarHidden = YES;
    
    [window addSubview: myNavController.view];
 
    [window makeKeyAndVisible];
    
    [myMapQueryViewController release];
    [myQueryTableViewController release];
    
	[tabBarController release];
    
    // made syncImages specific to a projectID, so moved it to AnnotationQueryDetailViewController viewDidLoad
    //[self syncImages];
    
}


- (void) syncImages
{
    NSMutableDictionary * destinationImages = [[NSMutableDictionary alloc] initWithCapacity:0];
    
    NSMutableDictionary * sourceImages      = [[NSMutableDictionary alloc] initWithCapacity:0];
        
    NSFileManager * myFileManager = [[NSFileManager alloc] init];
        
    NSBundle * myBundle = [NSBundle mainBundle];
        
    
    // get local image portfolio (destination)
    NSString    * destDirectoryPath = [NSHomeDirectory() stringByAppendingFormat:@"/Documents/"];
    
    NSMutableSet * destDirectories = [[NSMutableSet alloc] initWithArray: [myFileManager contentsOfDirectoryAtPath:destDirectoryPath error:nil]];
    
    NSEnumerator * destDirEnumerator = [destDirectories objectEnumerator];
    
    id dirValue;
    
    while ((dirValue = [destDirEnumerator nextObject])) 
    {
        if ([(NSString *) dirValue compare: kDSStore])
        {
            NSString    * filePath = [NSHomeDirectory() stringByAppendingFormat:@"/Documents/%@", (NSString *) dirValue];
            
            NSMutableSet * tempFiles = [[NSMutableSet alloc] initWithArray: [myFileManager contentsOfDirectoryAtPath:filePath error:nil]];
            
            [destinationImages setObject:tempFiles forKey:dirValue];
            
            [tempFiles release];
            
        }
    }
    
    [destDirectories release];
    
    /*
    // print the destination image file names
    NSEnumerator * dictionaryEnumerator = [destinationImages keyEnumerator];
    
    while ((dirValue = [dictionaryEnumerator nextObject])) 
    {
        NSSet * mySet = (NSSet *) [destinationImages objectForKey:dirValue]; 

        NSEnumerator * fileEnumerator = [mySet objectEnumerator];
        
        id fileValue;
        
        while ((fileValue = [fileEnumerator nextObject])) 
        {
            NSLog(@"Destination Directory: %@, File: %@", (NSString *) dirValue, (NSString *) fileValue);            
        }
    }
    */
    
    // get remote image portfolio (source)
    NSMutableURLRequest * req = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:kServerScriptImagesPath]];
    NSHTTPURLResponse * returnResponse = nil;
    NSError * returnError = nil;
    
    NSString * str;
    
    if ([NSURLConnection canHandleRequest:req] == YES)
    {
        NSData * returnData = [NSURLConnection sendSynchronousRequest:req returningResponse:&returnResponse error:&returnError];        

        int statusCode = returnResponse.statusCode;
        
        str = [[[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding] autorelease];
        
        //NSLog(@"PHP Output: %@", str);
        
        if ((statusCode == 200) && (!returnError))
        {
            //NSLog(@"Directory downloaded successfully! Status code: 200");
        }
        else
        {
            NSLog(@"Failed to download directory with error.\nStatus code: %d\nError: %@", statusCode, [returnError localizedDescription]);
        }
    }
    else
    {
        NSLog(@"Website %@ not available.", kServerScriptImagesPath);
        str = [NSString stringWithFormat:@""];
    }
            
    NSArray * splitImageFiles = [str componentsSeparatedByString:@"\n"];
    
    for (int i = 0; i < [splitImageFiles count]; i++)
    {
        NSString * imageFileString = [NSString stringWithString: (NSString *) [splitImageFiles objectAtIndex:i]];
        NSArray * splitLine = [imageFileString componentsSeparatedByString:@"/"];
        NSString * integrityString = [NSString stringWithString: (NSString *) [splitLine objectAtIndex: 0]];
        
        if (![integrityString compare:kImageFilePrefix])
        {
            NSString * tempDirectory = (NSString *) [splitLine objectAtIndex:1];
            NSString * tempFileName  = (NSString *) [splitLine objectAtIndex:2];
            
            NSMutableSet * tempMutableSet = (NSMutableSet *) [sourceImages objectForKey:(id) tempDirectory];
            
            if (tempMutableSet == nil)
            {
                tempMutableSet = [NSMutableSet setWithCapacity:0];
            }
            [tempMutableSet addObject:(id) tempFileName];

            [sourceImages setObject:tempMutableSet forKey: (id) tempDirectory];
        }
    }

    /*
    // print the source image file names
    dictionaryEnumerator = [sourceImages keyEnumerator];
    
    while ((dirValue = [dictionaryEnumerator nextObject])) 
    {
        NSSet * mySet = (NSSet *) [sourceImages objectForKey:dirValue]; 
        
        NSEnumerator * fileEnumerator = [mySet objectEnumerator];
        
        id fileValue;
        
        while ((fileValue = [fileEnumerator nextObject])) 
        {
            NSLog(@"Source Directory: %@, File: %@", (NSString *) dirValue, (NSString *) fileValue);            
        }
        
    }
    */
    
    
    // get the source and dest directories    
    NSMutableSet * tempSourceKeys = [[NSMutableSet alloc] initWithArray:[sourceImages allKeys]];
    
    NSMutableSet * tempDestKeys   = [[NSMutableSet alloc] initWithArray:[destinationImages allKeys]];
    
    BOOL moreDownloads = YES;
    
    
    // find an intersection download
    NSMutableSet * tempIntersectionDirSet = [[NSMutableSet alloc] initWithSet:tempSourceKeys];
    
    [tempIntersectionDirSet intersectSet:tempDestKeys];
    
    NSEnumerator * tempEnumerator = [tempIntersectionDirSet objectEnumerator];
    
    while ((dirValue = [tempEnumerator nextObject])) 
    {
        //NSLog(@"Intersection set: %@", (NSString *) dirValue);
        
        NSMutableSet * tempSetSource = (NSMutableSet *) [sourceImages objectForKey: (id) dirValue];
        
        NSMutableSet * tempSetDest   = (NSMutableSet *) [destinationImages objectForKey: (id) dirValue];
        
        NSMutableSet * tempAddFileSet = [[NSMutableSet alloc] initWithSet:tempSetSource];
        
        [tempAddFileSet minusSet:tempSetDest];
        
        NSEnumerator * tempSetEnumerator = [tempAddFileSet objectEnumerator];
        
        id fileValue;
        
        while ((fileValue = [tempSetEnumerator nextObject])) 
        {
            if (moreDownloads == YES)
            {                
                NSString * myFile = [NSString stringWithFormat:@"%@", (NSString *) fileValue];
                
                NSArray * splitLine = [myFile componentsSeparatedByString:@"."];
                
                NSString * myBundleFilePath = nil;
                
                if ([splitLine count] == 2)
                {                
                    myBundleFilePath = [myBundle pathForResource:(NSString *) [splitLine objectAtIndex:0] ofType: (NSString *) [splitLine objectAtIndex:1] inDirectory:@"ImagesOfProjects"];
                }
                
                if (myBundleFilePath != nil)
                {
                    NSLog(@"%@ in bundle!!!", (NSString *) fileValue);
                    [myFileManager copyItemAtPath:myBundleFilePath toPath:[NSHomeDirectory() stringByAppendingFormat:@"/Documents/%@/%@", (NSString *) dirValue, (NSString *) fileValue] error:nil];
                }
                else
                {
                    //NSLog(@"Dir: %@, File: %@", (NSString *) dirValue, (NSString *) fileValue);
                    [self _startReceive : (NSString *) dirValue : (NSString *) fileValue];                    
                    moreDownloads = NO;
                }
                
            }
            
        }
        
        [tempAddFileSet release];
        
        NSMutableSet * tempDeleteFileSet = [[NSMutableSet alloc] initWithSet:tempSetDest];
        
        [tempDeleteFileSet minusSet:tempSetSource];
        
        tempSetEnumerator = [tempDeleteFileSet objectEnumerator];
        
        while ((fileValue = [tempSetEnumerator nextObject])) 
        {
            [myFileManager removeItemAtPath:[NSHomeDirectory() stringByAppendingFormat:@"/Documents/%@/%@", (NSString *) dirValue, (NSString *) fileValue] error:nil];
        }
        
        [tempDeleteFileSet release];
    }
    
    [tempIntersectionDirSet release];
    
    
    // find an add directory download
    NSMutableSet * tempAddDirSet = [[NSMutableSet alloc] initWithSet:tempSourceKeys];
    
    [tempAddDirSet minusSet:tempDestKeys];
    
    tempEnumerator = [tempAddDirSet objectEnumerator];
    
    while ((dirValue = [tempEnumerator nextObject])) 
    {
        //NSLog(@"Add set: %@", (NSString *) dirValue);
        
        NSSet * tempSet = (NSSet *) [sourceImages objectForKey: (id) dirValue];
        
        NSEnumerator * tempSetEnumerator = [tempSet objectEnumerator];
        
        id fileValue;
        
        while ((fileValue = [tempSetEnumerator nextObject])) 
        {
            if (moreDownloads == YES)
            {                
                [myFileManager createDirectoryAtPath:[NSHomeDirectory() stringByAppendingFormat:@"/Documents/%@", (NSString *) dirValue]  withIntermediateDirectories:YES attributes:nil error:nil];
                
                NSString * myFile = [NSString stringWithFormat:@"%@", (NSString *) fileValue];
                
                NSArray * splitLine = [myFile componentsSeparatedByString:@"."];
                
                NSString * myBundleFilePath = nil;
                
                if ([splitLine count] == 2)
                {                
                    myBundleFilePath = [myBundle pathForResource:(NSString *) [splitLine objectAtIndex:0] ofType: (NSString *) [splitLine objectAtIndex:1] inDirectory:@"ImagesOfProjects"];
                }
                
                if (myBundleFilePath != nil)
                {
                    NSLog(@"%@ in bundle!!!", (NSString *) fileValue);
                    [myFileManager copyItemAtPath:myBundleFilePath toPath:[NSHomeDirectory() stringByAppendingFormat:@"/Documents/%@/%@", (NSString *) dirValue, (NSString *) fileValue] error:nil];
                }
                else
                {
                    //NSLog(@"Dir: %@, File: %@", (NSString *) dirValue, (NSString *) fileValue);
                    
                    [self _startReceive : (NSString *) dirValue : (NSString *) fileValue];                    
                    moreDownloads = NO;
                }
            }

        }
    }
    
    [tempAddDirSet release];
    
    [tempDestKeys release];
    
    [tempSourceKeys release];
    
    [destinationImages release];
    
    [sourceImages release];
    
    [myFileManager release];
    
}

// Starts a connection to download the current URL.
- (void) _startReceive : (NSString *) projectID : (NSString *) fileName
{
    // source url
    NSURL * url = [NSURL URLWithString:[kDownloadTest stringByAppendingFormat:@"%@/%@", projectID, fileName]];
    //NSLog(@"Source url Path: %@", url);

    // open a connection for the url
    NSURLRequest * request = [NSURLRequest requestWithURL:url];
        
    self.connection = [NSURLConnection connectionWithRequest:request delegate:self];
    
    // dest path
    self.filePath = [NSHomeDirectory() stringByAppendingFormat:@"/Documents/%@/%@", projectID, fileName];
    //NSLog(@"Dest File Path: %@", self.filePath);
    
    // open output stream
    self.fileStream = [NSOutputStream outputStreamToFileAtPath:self.filePath append:NO];
    [self.fileStream open];
    
    // Tell the UI we're receiving.    
    [self _receiveDidStart];

}

- (void)_receiveDidStart
{
    //[self.activityIndicator startAnimating];
    [[AppDelegate sharedAppDelegate] didStartNetworking];
}

+ (AppDelegate *)sharedAppDelegate
{
    return (AppDelegate *) [UIApplication sharedApplication].delegate;
}

- (void) didStartNetworking
{
    //self.networkingCount += 1;
    self.networkingCount = 1;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
}

- (void)didStopNetworking
{
    if (self.networkingCount <= 0)
    {
        NSLog(@"Networking count too low:  %d", self.networkingCount);
    }
    else
    {
        self.networkingCount -= 1;
    }
    [UIApplication sharedApplication].networkActivityIndicatorVisible = (self.networkingCount != 0);
    //NSLog(@"Networking Count: %d", self.networkingCount);
    //[self syncImages];
    
    //notify that an image has been downloaded
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ImageDownloaded" object:self];
    [self syncImagesSingle: dataController.strProjectID];
}

- (void)_receiveDidStopWithStatus:(NSString *)statusString
{
    //[self.activityIndicator stopAnimating];
    [[AppDelegate sharedAppDelegate] didStopNetworking];
}


// Shuts down the connection and displays the result (statusString == nil) or the error status (otherwise).
- (void)_stopReceiveWithStatus:(NSString *)statusString
{
    if (self.connection != nil) 
    {
        [self.connection cancel];
        self.connection = nil;
    }
    
    if (self.fileStream != nil) 
    {
        [self.fileStream close];
        self.fileStream = nil;
    }
    
    [self _receiveDidStopWithStatus:statusString];
    self.filePath = nil;
}

// A delegate method called by the NSURLConnection when the request/response 
// exchange is complete.  We look at the response to check that the HTTP 
// status code is 2xx and that the Content-Type is acceptable.  If these checks 
// fail, we give up on the transfer.
- (void)connection:(NSURLConnection *)theConnection didReceiveResponse:(NSURLResponse *)response
{
    #pragma unused(theConnection)
    
    NSHTTPURLResponse * httpResponse;
    NSString *          contentTypeHeader;
    
    httpResponse = (NSHTTPURLResponse *) response;
    
    if ((httpResponse.statusCode / 100) != 2) 
    {
        [self _stopReceiveWithStatus:[NSString stringWithFormat:@"HTTP error %zd", (ssize_t) httpResponse.statusCode]];
    } 
    else 
    {
        contentTypeHeader = [httpResponse.allHeaderFields objectForKey:@"Content-Type"];
        
        if (contentTypeHeader == nil) {
            [self _stopReceiveWithStatus:@"No Content-Type!"];
        } 
        else if (![contentTypeHeader isHTTPContentType:@"image/jpeg"] &&
                 ![contentTypeHeader isHTTPContentType:@"image/png"]  && 
                 ![contentTypeHeader isHTTPContentType:@"image/gif"]) 
        {
            [self _stopReceiveWithStatus:[NSString stringWithFormat:@"Unsupported Content-Type (%@)", contentTypeHeader]];
        } 
        else 
        {
            //self.statusLabel.text = @"Response OK.";
        }
    }    
}


// A delegate method called by the NSURLConnection as data arrives.  We just 
// write the data to the file.
- (void)connection:(NSURLConnection *)theConnection didReceiveData:(NSData *)data
{
    #pragma unused(theConnection)
    NSInteger       dataLength;
    const uint8_t * dataBytes;
    NSInteger       bytesWritten;
    NSInteger       bytesWrittenSoFar;
    
    dataLength = [data length];
    dataBytes  = [data bytes];
    
    bytesWrittenSoFar = 0;
    
    do 
    {
        bytesWritten = [self.fileStream write:&dataBytes[bytesWrittenSoFar] maxLength:dataLength - bytesWrittenSoFar];

        if (bytesWritten == -1) 
        {
            [self _stopReceiveWithStatus:@"File write error"];
            break;
        } 
        else
        {
            bytesWrittenSoFar += bytesWritten;
        }
        
    } while (bytesWrittenSoFar != dataLength);
}


// A delegate method called by the NSURLConnection if the connection fails. 
// We shut down the connection and display the failure.  Production quality code 
// would either display or log the actual error.
- (void)connection:(NSURLConnection *)theConnection didFailWithError:(NSError *)error
{
    #pragma unused(theConnection)
    #pragma unused(error)

    [self _stopReceiveWithStatus:@"Connection failed"];
    
    if (error.code)
    {
        NSLog(@"Failed to download with error: %@", [error localizedDescription]);
    }

}


// A delegate method called by the NSURLConnection when the connection has been 
// done successfully.  We shut down the connection with a nil status, which 
// causes the image to be displayed.
- (void)connectionDidFinishLoading:(NSURLConnection *)theConnection
{
    #pragma unused(theConnection)

    [self _stopReceiveWithStatus:nil];
}

- (void)dealloc
{
    [myNavController release];
    [myLocation release];
    [window release];
    [super dealloc];
}

@end
