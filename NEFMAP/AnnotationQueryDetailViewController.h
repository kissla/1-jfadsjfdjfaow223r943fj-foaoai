#import "DataAccess.h"
#import "PostingPhoto.h"
#import "ImageScrollView.h"
#import "Constants.h"
#import "LargeImageViewController.h"
#import "AppDelegate.h"

@class PostingPhoto;
@class ImageScrollView;
@class AppDelegate;

@interface AnnotationQueryDetailViewController : UIViewController < 
                                                    UINavigationControllerDelegate, 
                                                    UIImagePickerControllerDelegate, 
                                                    UIScrollViewDelegate
                                                 >
{
    DataAccess              * dataController;
    
    CGFloat                   navigationBarHeight;
    
    UIView                  * myView;
    
    UIScrollView            * myImagePagingScrollView;
    
    NSMutableArray          * myImageData;
    
    NSMutableSet            * recycledPages;
    NSMutableSet            * visiblePages;
    
    UILabel                 * myProjectHeader;
    
    UITextView              * myProjectDetailScroll;
    
    UIToolbar               * myCameraToolBar;
    
    // these values are stored off before we start rotation so we adjust our content offset appropriately during rotation
    int             firstVisiblePageIndexBeforeRotation;
    
    CGFloat         percentScrolledIntoFirstVisiblePage;
    
}

@property (nonatomic, retain) DataAccess        * dataController;
@property (nonatomic, retain) UIView            * myView;
@property (nonatomic, retain) UIScrollView      * myImagePagingScrollView;
@property (nonatomic, retain) UILabel           * myProjectHeader;
@property (nonatomic, retain) UITextView        * myProjectDetailScroll;
@property (nonatomic, retain) UIToolbar         * myCameraToolBar;

- (void) directionsToHere;
- (void) reOrient;
- (void) tilePages;
- (void) configurePage: (ImageScrollView *) page forIndex: (NSUInteger)index;
- (void) imageDownloadCompleted : (NSNotification *) myNotification;
- (BOOL) isDisplayingPageForIndex:(NSUInteger)index;
- (ImageScrollView *) dequeueRecycledPage;


- (UIImage *) imageAtIndex: (NSUInteger) index;

- (NSMutableArray *)           imageData;

- (CGRect)frameForPageAtIndex:(NSUInteger)index;

@end
