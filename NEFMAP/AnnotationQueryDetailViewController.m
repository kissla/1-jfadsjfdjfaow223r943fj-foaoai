#import "AnnotationQueryDetailViewController.h"

@implementation AnnotationQueryDetailViewController

@synthesize dataController;
@synthesize myView;
@synthesize myImagePagingScrollView;
@synthesize myProjectHeader;
@synthesize myProjectDetailScroll;
@synthesize myCameraToolBar;

- (void)dealloc
{
    [myView release];
    [myImagePagingScrollView release];
    [myImageData removeAllObjects];
    [myImageData release];
    [recycledPages removeAllObjects];
    [recycledPages release];
    [visiblePages removeAllObjects];
    [visiblePages release];
    [myProjectHeader release];
    [myProjectDetailScroll release];
    [myCameraToolBar release];
        
    [super dealloc];
}

-(void) imageDownloadCompleted : (NSNotification *) myNotification
{
    [myImageData setArray: [self imageData]];
    
    for (ImageScrollView * page in visiblePages) 
    {
        [recycledPages addObject:page];
        [page removeFromSuperview];
    }
    [visiblePages minusSet:recycledPages];
    
    [self reOrient];
}

- (void)tilePages 
{
    // Calculate which pages are visible
    CGRect visibleBounds = myImagePagingScrollView.bounds;
    
    int firstNeededPageIndex = floorf(CGRectGetMinX(visibleBounds) / CGRectGetWidth(visibleBounds));
    int lastNeededPageIndex  = floorf((CGRectGetMaxX(visibleBounds) - 1) / CGRectGetWidth(visibleBounds));
    
    firstNeededPageIndex = MAX(firstNeededPageIndex, 0);
    lastNeededPageIndex  = MIN(lastNeededPageIndex, [myImageData count] - 1);
        
    // Recycle no-longer-visible pages 
    for (ImageScrollView * page in visiblePages) 
    {
        if (page.index < firstNeededPageIndex || page.index > lastNeededPageIndex) 
        {
            //NSLog(@"Recycled page index: %d", page.index);
            [recycledPages addObject:page];
            [page removeFromSuperview];
        }
    }
    [visiblePages minusSet:recycledPages];
    
    // add missing pages
    for (int index = firstNeededPageIndex; index <= lastNeededPageIndex; index++) 
    {
        if (![self isDisplayingPageForIndex:index]) {
            ImageScrollView * page = [self dequeueRecycledPage];
            if (page == nil) {
                page = [[[ImageScrollView alloc] init] autorelease];
            }
            [self configurePage:page forIndex:index];
            [myImagePagingScrollView addSubview:page];
            [visiblePages addObject:page];
            //NSLog(@"Made visible: %d", page.index);
        }
    }    
}

-(void) viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver: self selector:@selector(imageDownloadCompleted:) name:@"ImageDownloaded" object:[AppDelegate sharedAppDelegate]];

    [[AppDelegate sharedAppDelegate] syncImagesSingle: dataController.strProjectID];
    
    dataController.indexOfImage = 0;
    
    navigationBarHeight     = self.navigationController.navigationBar.frame.size.height;
    
    self.title = [NSString stringWithFormat: @"Project ID: %@", dataController.strProjectID];
    
    // build the basic view
    self.view = [[UIView alloc] initWithFrame:CGRectMake(0,
                                                         0, 
                                                         [[UIScreen mainScreen] applicationFrame].size.width,
                                                         [[UIScreen mainScreen] applicationFrame].size.height - navigationBarHeight)];
    
    // build myView on top of basic view
    self.myView = [[UIView alloc] initWithFrame:CGRectMake(0,
                                                           0, 
                                                           self.view.frame.size.width,
                                                           self.view.frame.size.height - navigationBarHeight)];
    
    // build the myPagingScrollView on top of myView
    myImagePagingScrollView = [[UIScrollView alloc] initWithFrame:
                               CGRectMake(-PADDING,
                                          0,
                                          myView.frame.size.width + (2 * PADDING),
                                          kPctOfScreenStartOfScroll * (myView.frame.size.height - navigationBarHeight))];
    
    //NSLog(@"ViewDidLoad frame - x: %f, y: %f, width: %f, height: %f", myImagePagingScrollView.frame.origin.x, myImagePagingScrollView.frame.origin.y,myImagePagingScrollView.frame.size.width,myImagePagingScrollView.frame.size.height);
    //NSLog(@"ViewDidLoad contentoffset - x: %f, y: %f", myImagePagingScrollView.contentOffset.x, myImagePagingScrollView.contentOffset.y);
    
    myImagePagingScrollView.pagingEnabled = YES;
    myImagePagingScrollView.backgroundColor = [UIColor blackColor];
    myImagePagingScrollView.showsVerticalScrollIndicator = NO;
    myImagePagingScrollView.showsHorizontalScrollIndicator = NO;
    myImagePagingScrollView.delegate = self;
    
    // prepare containers for images
    myImageData   = [[NSMutableArray alloc] initWithCapacity:0];
    recycledPages = [[NSMutableSet alloc] initWithCapacity:0];
    visiblePages  = [[NSMutableSet alloc] initWithCapacity:0];
    
    // build the project description header on top of MyView
    myProjectHeader =  [[UILabel alloc] 
                        initWithFrame:CGRectMake(0,
                                                 kPctOfScreenStartOfScroll * (myView.frame.size.height - navigationBarHeight),
                                                 myView.frame.size.width, 
                                                 0)];
    
    myProjectHeader.numberOfLines = 3;
    
    [myProjectHeader setFont:[UIFont fontWithName:@"Arial-BoldItalicMT" size:16]];
    
    // populate the myProjectHeader string
    Project * tempProject = [dataController.myQueriedProjectsFixed objectForKey:(id) dataController.strProjectID];
        
    dataController.myLatitude   = tempProject.latitude;
    dataController.myLongitude  = tempProject.longitude;
    dataController.myAddress    = tempProject.address;
    dataController.myZipCode    = tempProject.zipCode;
    
    myProjectHeader.text = [NSString stringWithFormat: @"%@\n%@\n%@, %@  %@", tempProject.name, tempProject.address, tempProject.city, tempProject.state, tempProject.zipCode];
    
    myProjectHeader.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
    
    [myProjectHeader sizeToFit];
    
    CGRect myCenteringRect = myProjectHeader.frame;
    
    myCenteringRect.origin.x =  (myView.frame.size.width - myCenteringRect.size.width) / 2;
    
    myProjectHeader.frame = myCenteringRect;
    
    // build the project detail description scroll box
    double gap = kPctGapBetweenHeaderDetail * ([[UIScreen mainScreen] applicationFrame].size.height - navigationBarHeight);
    
    myProjectDetailScroll = [[UITextView alloc] 
                             initWithFrame: CGRectMake(0,
                                                       kPctOfScreenStartOfScroll * (myView.frame.size.height - navigationBarHeight) + myProjectHeader.frame.size.height + gap, 
                                                       myView.frame.size.width, 
                                                       myView.frame.size.height - (kPctOfScreenStartOfScroll * (myView.frame.size.height - navigationBarHeight) + myProjectHeader.frame.size.height) - gap)];
    myProjectDetailScroll.editable = NO;
    myProjectDetailScroll.scrollEnabled = YES;
    myProjectDetailScroll.showsVerticalScrollIndicator = YES;
    myProjectDetailScroll.text = [dataController getAddress:dataController.strProjectID];
    
    
    // build the bottom myCameraToolBar
    myCameraToolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0,
                                                                  self.myView.frame.size.height, 
                                                                  self.view.frame.size.width,
                                                                  navigationBarHeight)];
    
    // build the button to activate camera
    UIBarButtonItem * buttonFullScreen = [[UIBarButtonItem alloc] initWithTitle:@"Zoom" style:UIBarButtonItemStyleDone target:self action:@selector(buttonPressedFullScreen:)];
    UIBarButtonItem * buttonDoNothing = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:@selector(buttonPressedDoNothing:)];
    UIBarButtonItem * buttonCamera = [[UIBarButtonItem alloc] initWithTitle:@"Camera" style:UIBarButtonItemStyleDone target:self action:@selector(buttonPressedCamera:)];
    UIBarButtonItem * buttonDoNothing2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:@selector(buttonPressedDoNothing:)];
    UIBarButtonItem * buttonPhotoGallery = [[UIBarButtonItem alloc] initWithTitle:@"Photos" style:UIBarButtonItemStyleDone target:self action:@selector(buttonPressedPhotoGallery:)];
    UIBarButtonItem * buttonDoNothing3 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:@selector(buttonPressedDoNothing:)];
    UIBarButtonItem * buttonGoto = [[UIBarButtonItem alloc] initWithTitle:@"Directions" style:UIBarButtonItemStyleDone
                                                                   target:self action:@selector(directionsToHere)];
    
    buttonCamera.enabled = ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]);
    
    buttonPhotoGallery.enabled = ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum]);
    
    [myCameraToolBar setItems: [NSArray arrayWithObjects: buttonFullScreen, buttonDoNothing, buttonCamera, buttonDoNothing2, buttonPhotoGallery, buttonDoNothing3, buttonGoto, nil]];
    [buttonCamera release];
    [buttonDoNothing release];
    [buttonPhotoGallery release];
    [buttonDoNothing2 release];
    [buttonFullScreen release];
    [buttonDoNothing3 release];
    [buttonGoto release];
    
    // build Goto button on navigation bar
    //self.navigationItem.rightBarButtonItem = rightButton;
    
    //[rightButton release];
    
    [self.myView    addSubview:myImagePagingScrollView];
    [self.myView    addSubview:myProjectHeader];
    [self.myView    addSubview:myProjectDetailScroll];
    [self.view      addSubview:myView];
    [self.view      addSubview:myCameraToolBar];
        
    [myImageData addObjectsFromArray: [self imageData]];
    
    myImagePagingScrollView.contentSize = CGSizeMake(myImagePagingScrollView.bounds.size.width * [myImageData count], myImagePagingScrollView.bounds.size.height);
    //myImagePagingScrollView.contentOffset = CGPointMake(0,0);
    
    //NSLog(@"ViewDidLoad content size - width: %f, height: %f", myImagePagingScrollView.contentSize.width, myImagePagingScrollView.contentSize.height);
    //NSLog(@"ViewDidLoad contentoffset - x: %f, y: %f", myImagePagingScrollView.contentOffset.x, myImagePagingScrollView.contentOffset.y);
    
    
    [self tilePages];
    
}

-(void) reOrient
{
    CGFloat h,w;
    
    navigationBarHeight     = self.navigationController.navigationBar.frame.size.height;
    
    double gap = kPctGapBetweenHeaderDetail * ([[UIScreen mainScreen] applicationFrame].size.height - navigationBarHeight);
    
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
    
    
    // reframe view
    [self.view setFrame:CGRectMake(0, 0, w, h - navigationBarHeight)];
    
    // reframe myView
    [myView setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - navigationBarHeight)];
    
    // reframe myImagePagingScrollView
    // recalculate contentSize based on current orientation
    [myImagePagingScrollView setFrame:
     CGRectMake(-PADDING,
                0,
                myView.frame.size.width + (2 * PADDING),
                kPctOfScreenStartOfScroll * (myView.frame.size.height - navigationBarHeight))];
    
    //NSLog(@"Reorient frame - x: %f, y: %f, width: %f, height: %f", myImagePagingScrollView.frame.origin.x, myImagePagingScrollView.frame.origin.y,myImagePagingScrollView.frame.size.width,myImagePagingScrollView.frame.size.height);
    //NSLog(@"Reorient contentoffset 1 - x: %f, y: %f", myImagePagingScrollView.contentOffset.x,myImagePagingScrollView.contentOffset.y);
    
    myImagePagingScrollView.contentSize = CGSizeMake(myImagePagingScrollView.bounds.size.width * [myImageData count], myImagePagingScrollView.bounds.size.height);
    
    //NSLog(@"Reorient content size - width: %f, height: %f", myImagePagingScrollView.contentSize.width, myImagePagingScrollView.contentSize.height);
    //NSLog(@"Reorient contentoffset 2 - x: %f, y: %f", myImagePagingScrollView.contentOffset.x, myImagePagingScrollView.contentOffset.y);
    
    // adjust frames and configuration of each visible page
    for (ImageScrollView *page in visiblePages) {
        CGPoint restorePoint = [page pointToCenterAfterRotation];
        CGFloat restoreScale = [page scaleToRestoreAfterRotation];
        
        CGRect pagingScrollViewFrame = CGRectMake(myView.frame.size.width * page.index,
                                                  0,
                                                  myView.frame.size.width,
                                                  kPctOfScreenStartOfScroll * (myView.frame.size.height - navigationBarHeight));
        
        page.frame = pagingScrollViewFrame;
        
        [page setMaxMinZoomScalesForCurrentBounds];
        [page restoreCenterPoint:restorePoint scale:restoreScale];
        
    }
    
    // adjust contentOffset to preserve page location based on values collected prior to location
    CGFloat pageWidth = myImagePagingScrollView.bounds.size.width;
    CGFloat newOffset = (dataController.indexOfImage * pageWidth) + (percentScrolledIntoFirstVisiblePage * pageWidth);
    myImagePagingScrollView.contentOffset = CGPointMake(newOffset, 0);
    
    
    
    // reframe myProjectHeader
    [myProjectHeader setFrame:CGRectMake(0, 
                                         kPctOfScreenStartOfScroll * (myView.frame.size.height - navigationBarHeight),
                                         myView.frame.size.width,
                                         myProjectHeader.frame.size.height)];
    
    [myProjectHeader sizeToFit];
    
    CGRect myCenteringRect = myProjectHeader.frame;    
    
    myCenteringRect.origin.x =  (myView.frame.size.width - myCenteringRect.size.width) / 2;
    
    myProjectHeader.frame = myCenteringRect;
    
    // reframe myProjectDetailScroll
    [myProjectDetailScroll setFrame:CGRectMake(0, 
                                               kPctOfScreenStartOfScroll * (myView.frame.size.height - navigationBarHeight) + myProjectHeader.frame.size.height + gap, 
                                               myView.frame.size.width, 
                                               myView.frame.size.height - (kPctOfScreenStartOfScroll * (myView.frame.size.height - navigationBarHeight) + myProjectHeader.frame.size.height) - gap)];
    
    // reframe myCameraToolBar
    [self.myCameraToolBar setFrame:CGRectMake(0, self.myView.frame.size.height, self.view.frame.size.width, navigationBarHeight)];
    
    [self tilePages];
    
    //NSLog(@"End of Reorient contentoffset - x: %f, y: %f", myImagePagingScrollView.contentOffset.x, myImagePagingScrollView.contentOffset.y);
    
    
}

- (CGRect)frameForPageAtIndex:(NSUInteger)index 
{
    // We have to use our paging scroll view's bounds, not frame, to calculate the page placement. When the device is in
    // landscape orientation, the frame will still be in portrait because the pagingScrollView is the root view controller's
    // view, so its frame is in window coordinate space, which is never rotated. Its bounds, however, will be in landscape
    // because it has a rotation transform applied.
    
    CGRect bounds = myImagePagingScrollView.bounds;
    CGRect pageFrame = bounds;
    
    
    pageFrame.size.width -= (2 * PADDING);
    pageFrame.origin.x = (bounds.size.width * index) + PADDING;
    
    return pageFrame;
    
}


- (void)configurePage:(ImageScrollView *) page forIndex:(NSUInteger)index
{
    page.index = index;
    
    page.frame = [self frameForPageAtIndex:index];
    
    // Use tiled images
    
    /*
     [page displayTiledImageNamed:[self imageNameAtIndex:index]
     size:[self imageSizeAtIndex:index]];
     */
    
    // To use full images instead of tiled images, replace the "displayTiledImageNamed:" call
    // above by the following line:
    
    [page displayImage:[self imageAtIndex:index]];
    
    //dataController.myLargeImage = [[self imageAtIndex:index] copy];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    // here, our pagingScrollView bounds have not yet been updated for the new interface orientation. So this is a good
    // place to calculate the content offset that we will need in the new orientation
    dataController.indexOfImage = (int) (myImagePagingScrollView.contentOffset.x / myImagePagingScrollView.frame.size.width);        
    //NSLog(@"Image: %d, offset: %f, width: %f", dataController.indexOfImage, myImagePagingScrollView.contentOffset.x, myImagePagingScrollView.frame.size.width);
    
    CGFloat offset =    myImagePagingScrollView.contentOffset.x;
    CGFloat pageWidth = myImagePagingScrollView.bounds.size.width;
    
    if (offset >= 0) 
    {
        firstVisiblePageIndexBeforeRotation = floorf(offset / pageWidth);
        percentScrolledIntoFirstVisiblePage = (offset - (firstVisiblePageIndexBeforeRotation * pageWidth)) / pageWidth;
    } else 
    {
        firstVisiblePageIndexBeforeRotation = 0;
        percentScrolledIntoFirstVisiblePage = offset / pageWidth;
    }    
}

- (ImageScrollView *)dequeueRecycledPage
{
    ImageScrollView *page = [recycledPages anyObject];
    
    if (page) 
    {
        [[page retain] autorelease];
        [recycledPages removeObject:page];
    }
    
    return page;
}

- (BOOL)isDisplayingPageForIndex:(NSUInteger)index
{
    
    BOOL foundPage = NO;
    
    for (ImageScrollView * page in visiblePages) 
    {
        if (page.index == index) 
        {
            foundPage = YES;
            break;
        }
    }
    return foundPage;
}

-(void) viewWillAppear:(BOOL)animated   
{
    [super viewWillAppear:animated];    
    
    [self reOrient];
    
}

-(void) viewWillDisappear:(BOOL)animated   
{
    
    [super viewWillDisappear:animated];    
    
}

//ok
- (void)buttonPressedFullScreen:(UIButton *)button
{
    LargeImageViewController * largeImageViewController = [[LargeImageViewController alloc] init];
    dataController.indexOfImage = (int) (myImagePagingScrollView.contentOffset.x / myImagePagingScrollView.frame.size.width);
    //NSLog(@"x: %f, width: %f, index; %d", myImagePagingScrollView.contentOffset.x, myImagePagingScrollView.frame.size.width, dataController.indexOfImage);
    dataController.myLargeImage = [self imageAtIndex:dataController.indexOfImage];
    largeImageViewController.dataController = dataController;
    
    [[self navigationController] pushViewController:largeImageViewController animated:YES];
    [largeImageViewController release];
}

//ok
- (void)buttonPressedDoNothing:(UIButton *)button
{
    NSLog(@"Do nothing button");
}

//ok
- (NSMutableArray *) imageData 
{
    NSFileManager * myTempFileManager = [[NSFileManager alloc] init];
    
    // path to image files
    NSString    * path = [NSHomeDirectory() stringByAppendingFormat:@"/Documents/%@/", dataController.strProjectID];
    
    //NSLog(@"Path: %@", path);
    
    NSMutableArray * tempDirectoryFiles = [[[NSMutableArray alloc] initWithArray: [myTempFileManager contentsOfDirectoryAtPath:path error:nil]] autorelease];
    
    if([tempDirectoryFiles count] == 0)
    {
        [tempDirectoryFiles addObjectsFromArray:[myTempFileManager contentsOfDirectoryAtPath:[NSHomeDirectory() stringByAppendingFormat:@"/Documents/Default/"] error:nil]];
    }
    
    /*
    NSLog(@"Count of files: %d", [tempDirectoryFiles count]);
    
    int countOfFiles = [tempDirectoryFiles count];
    
    for (int i = 0; i < countOfFiles; i++)
    {
        UIImage * tempImage = [[UIImage alloc] initWithContentsOfFile:[NSHomeDirectory() stringByAppendingFormat:@"/Documents/%@/%@", dataController.strProjectID, [tempDirectoryFiles objectAtIndex: i]]];
        NSLog(@"File %d: %@", i, [tempDirectoryFiles objectAtIndex: i]);
        NSLog(@"Width: %f, Height: %f", tempImage.size.width, tempImage.size.height);
    }
    */
    
    [myTempFileManager release];
    
    return tempDirectoryFiles;
}

//ok
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self tilePages];
}

//ok
-(BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return (toInterfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

//ok
-(void) willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration  
{
    [self reOrient];
}

//ok
- (NSString *)imageNameAtIndex:(NSUInteger)index 
{
    NSString * name = nil;
    
    if (index < [myImageData count]) 
    {
        // NSString *data = [myImageData objectAtIndex:index];
        name = [myImageData objectAtIndex:index];
    }
    
    return name;
}

//ok
- (UIImage *) imageAtIndex: (NSUInteger) index 
{
    // use "imageWithContentsOfFile:" instead of "imageNamed:" here to avoid caching our images
    NSString * imageName = [self imageNameAtIndex:index];
    
    //NSLog(@"Image name: %@", imageName);
    
    NSString * path;
    if (![[imageName substringToIndex: 7] compare:@"default"])
    {
        path = [NSHomeDirectory() stringByAppendingFormat:@"/Documents/Default/%@", imageName];        
    }
    else
    {
        path = [NSHomeDirectory() stringByAppendingFormat:@"/Documents/%@/%@", dataController.strProjectID, imageName];        
    }
    
    //NSLog(@"Path: %@", path);
    
    return [UIImage imageWithContentsOfFile:path];    
}

//ok
- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
	// Access the uncropped image from info dictionary
	UIImage *image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
    
	// Save image
    UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
    
    PostingPhoto * myPoster = [[PostingPhoto alloc] init];
    [myPoster postPhoto:image withProj: dataController.strProjectID withLat:0.0 withLng:0.0 andCaption:[NSString stringWithFormat: @"ProjectID: %@", dataController.strProjectID]];
    [myPoster release];
    
}

//ok
- (void) alertView:(UIAlertView *)alert clickedButtonAtIndex:(NSInteger)buttonIndex
{
	// After saving iamge, dismiss camera
	[self dismissModalViewControllerAnimated:YES];
}

//ok
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    UIAlertView * alert;
    
	// Unable to save the image  
    if (error)
    {    
        alert = [[UIAlertView alloc] initWithTitle:@"Error" 
                                           message:@"Unable to save image to Photo Album." 
                                          delegate:self cancelButtonTitle:@"Ok" 
                                 otherButtonTitles:nil];
    }
	else 
        // All is well
    {
        alert = [[UIAlertView alloc] initWithTitle:@"Success" 
                                           message:@"Image saved to Photo Album." 
                                          delegate:self cancelButtonTitle:@"Ok" 
                                 otherButtonTitles:nil];
    }
    [alert show];
    [alert release];
}

//ok
- (void)buttonPressedCamera:(UIButton *)button
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        // Create image picker controller
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        
        // Set source to the camera
        imagePicker.sourceType =  UIImagePickerControllerSourceTypeCamera;
        
        //only png and jpeg photos alowed
        //imagePicker.mediaTypes = [[NSArray alloc] initWithObjects: (NSString *) kUTTypePNG, kUTTypeJPEG, nil];
        
        // Delegate is self
        imagePicker.delegate = self;
        
        // Allow editing of image ?
        imagePicker.allowsEditing = NO;
        
        // Show image picker
        [self presentModalViewController:imagePicker animated:YES];	
        
    }
    else
    {
        /*
         //this was just to test the transfer on device without a camera
         UIImage * myImage = [UIImage imageNamed:kImage];
         //NSLog(@"Image width: %f, height: %f", myImage.size.width, myImage.size.height);
         PostingPhoto * myPoster = [[PostingPhoto alloc] init];
         [myPoster postPhoto:myImage withProj: dataController.strProjectID withLat:38.44 withLng:-97.76 andCaption:@"This is a nice photo!"];
         [myPoster release];
         */
    }
}

//ok
- (void)buttonPressedPhotoGallery:(UIButton *)button
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary])
    {
        // Create image picker controller
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        
        // Set source to the camera
        imagePicker.sourceType =  UIImagePickerControllerSourceTypeSavedPhotosAlbum;
        
        //only png and jpeg photos allowed
        //imagePicker.mediaTypes = [[NSArray alloc] initWithObjects: (NSString *) kUTTypePNG, kUTTypeJPEG, nil];
        
        // Delegate is self
        imagePicker.delegate = self;
        
        // Allow editing of image ?
        imagePicker.allowsEditing = NO;
        
        // Show image picker
        [self presentModalViewController:imagePicker animated:YES];	
        
    }
}

//ok
-(void) directionsToHere
{
    //call the dataview for the corresponging id 
    //NSLog(@"strProjectID : %@", dataController.strProjectID );
    //can we add this to a frame?
    
    NSString * start = [[dataController.startAddress stringByAppendingFormat:@", %@", dataController.startZip] stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    NSString * dest  = [[dataController.myAddress stringByAppendingFormat:@", %@", dataController.myZipCode] stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    NSString * urlString = [NSString stringWithFormat: @"http://maps.google.com/maps?saddr=%@&daddr=%@" , start, dest ];
    
    //NSLog(@"Google Map: %@", urlString);
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString: urlString]];
}

@end

