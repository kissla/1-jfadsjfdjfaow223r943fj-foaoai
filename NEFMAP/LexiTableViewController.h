#import "DataAccess.h"
#import "MapQueryViewController.h"

@interface LexiTableViewController : UITableViewController 
{
    DataAccess              * dataController;
    
}

@property (nonatomic, retain) DataAccess        * dataController;

@end