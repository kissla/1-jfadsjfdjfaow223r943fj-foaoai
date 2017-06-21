#import "DataAccess.h"
#import "ProjectTableViewController.h"

@interface CongDistTableViewController : UITableViewController 
{
    DataAccess              * dataController;
}

@property (nonatomic, retain) DataAccess        * dataController;

@end