#import "LargeImageViewController.h"

@implementation LargeImageViewController

@synthesize dataController;
@synthesize myLargeImageView;

-(void) reOrient
{
    CGFloat h,w;
    
    navigationBarHeight     = self.navigationController.navigationBar.frame.size.height;

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
    myLargeImageView.frame = CGRectMake(0, 0, w, h - navigationBarHeight);

}

-(BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return (toInterfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

-(void) willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration  
{
    [self reOrient];
}

-(void) viewWillAppear:(BOOL)animated   
{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
}

-(void) viewDidLoad
{
    [super viewDidLoad];
    
    navigationBarHeight     = self.navigationController.navigationBar.frame.size.height;
    
    //self.view.backgroundColor = [UIColor blueColor];
    
    CGRect myRect = self.view.frame;
    
    //NSLog(@"x: %f, y: %f, width: %f, height: %f", myRect.origin.x, myRect.origin.y, myRect.size.width, myRect.size.height);
    
    myLargeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0,0, myRect.size.width, myRect.size.height - navigationBarHeight)];
    
    myLargeImageView.backgroundColor = [UIColor blackColor];
    
    myLargeImageView.contentMode = UIViewContentModeScaleAspectFit;
    
    //dataController.myLargeImage = [UIImage imageNamed:@"50.png"];
    
    myLargeImageView.image = dataController.myLargeImage;
    
    [self.view addSubview:myLargeImageView];
    
    [self reOrient];
}

@end

