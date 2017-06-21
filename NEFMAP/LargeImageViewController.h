//#import <UIKit/UIKit.h>
#import "DataAccess.h"

@interface LargeImageViewController : UIViewController
{
    DataAccess              * dataController;
    
    CGFloat                 navigationBarHeight;
    
    UIImageView             * myLargeImageView;
    
}

@property (nonatomic, retain) DataAccess        * dataController;
@property (nonatomic, retain) UIImageView       * myLargeImageView;

@end
