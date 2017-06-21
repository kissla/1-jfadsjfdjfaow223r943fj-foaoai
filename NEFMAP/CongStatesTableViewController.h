#import "DataAccess.h"
#import "CongDistTableViewController.h"
#import "MapQueryViewController.h"

@interface CongStatesTableViewController : UITableViewController 
{
    DataAccess              * dataController;
}

@property (nonatomic, retain) DataAccess        * dataController;

@end