#import "CongDistTableViewController.h"

@implementation CongDistTableViewController

@synthesize dataController;


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	switch (section)
	{
		case 0:
			return kTableViewHeaderHeight;
			break;
			
		default:
			return kTableViewHeaderHeight;
			break;
	}
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    CGFloat w;
    
    CGRect bounds = [[UIScreen mainScreen] applicationFrame];
    
    if (self.interfaceOrientation == UIInterfaceOrientationPortrait)
    {
        w = bounds.size.width;
    }
    else
    {
        w = bounds.size.height;
    }
    
	CGRect tempRect;
	
 	switch (section)
	{
		case 0:
			tempRect = CGRectMake(0,0,w, kTableViewHeaderHeight);
			break;
			
		default:
			tempRect = CGRectMake(0,0,w, kTableViewHeaderHeight);
			break;
			
	}
	
	UIView * tempBorderView = [[[UIView alloc] initWithFrame:tempRect] autorelease];
	tempBorderView.backgroundColor = [UIColor grayColor];
	
	tempRect.origin.y = 1;
	tempRect.size.height = tempRect.size.height - 2;
	UIView * tempBackgroundView = [[UIView alloc] initWithFrame:tempRect];
	tempBackgroundView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.5];
	
	tempRect.size.height = 40;
	tempRect.origin.y = tempBackgroundView.frame.size.height - tempRect.size.height;
	tempRect.origin.x = 5;
    tempRect.size.width = 0.65 * self.view.frame.size.width;
    
	UILabel * tempStateLabel = [[UILabel alloc] initWithFrame: tempRect];
	tempStateLabel.font = [UIFont boldSystemFontOfSize:36];
    tempStateLabel.textColor = [UIColor darkGrayColor];
	tempStateLabel.backgroundColor = [UIColor clearColor];
	tempStateLabel.textAlignment = UITextAlignmentLeft;
    tempStateLabel.text = NSLocalizedString(@"District",@"District");
    
	tempRect.size.height = 30;
	tempRect.origin.y = tempBackgroundView.frame.size.height - tempRect.size.height;
	tempRect.origin.x = 0.67 * self.view.frame.size.width;
	tempRect.size.width = 0.18 * self.view.frame.size.width;
    
	UILabel * tempCountLabel = [[UILabel alloc] initWithFrame: tempRect];
	tempCountLabel.font = [UIFont boldSystemFontOfSize:16];
	tempCountLabel.backgroundColor = [UIColor clearColor];
    tempStateLabel.textColor = [UIColor darkGrayColor];
	tempCountLabel.textAlignment = UITextAlignmentRight;
	tempCountLabel.text = NSLocalizedString(@"Count",@"Count");
    
	tempRect.size.height = 24;
	tempRect.origin.y = 0;
	tempRect.origin.x = 0.37 * self.view.frame.size.width;
	tempRect.size.width = 0.48 * self.view.frame.size.width;
    
	UILabel * tempProjectCountLabel = [[UILabel alloc] initWithFrame: tempRect];
	tempProjectCountLabel.font = [UIFont boldSystemFontOfSize:13];
	tempProjectCountLabel.textColor = [UIColor whiteColor];
	tempProjectCountLabel.backgroundColor = [UIColor clearColor];
	tempProjectCountLabel.shadowColor = [UIColor colorWithWhite:0 alpha:0.6];
	tempProjectCountLabel.shadowOffset = CGSizeMake(0, 1);
	tempProjectCountLabel.textAlignment = UITextAlignmentRight;
	tempProjectCountLabel.adjustsFontSizeToFitWidth = YES;
    
	
	switch (section)
	{
		case 0:
			tempProjectCountLabel.text = [NSString stringWithFormat:@"State Projects: %d", [dataController.myQueriedProjects count]];
			[tempBackgroundView addSubview:tempProjectCountLabel];
			break;
			
		default:
			break;
			
	}
	[tempProjectCountLabel release];
	
	[tempBackgroundView addSubview:tempStateLabel];
	[tempStateLabel release];
	[tempBackgroundView addSubview:tempCountLabel];
	[tempCountLabel release];
	[tempBorderView addSubview:tempBackgroundView];
	[tempBackgroundView release];
	
	return tempBorderView;
	
}

-(void) showMap
{
    MapQueryViewController * myMapQueryViewController = [[MapQueryViewController alloc] init];
    myMapQueryViewController.dataController = dataController;
    myMapQueryViewController.title = @"Map";
    
    [[self navigationController] pushViewController:myMapQueryViewController animated:YES];
    [myMapQueryViewController release];
   
}

-(BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return (toInterfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

-(void) willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration  
{
    [self.tableView reloadData];
}

 - (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath: (NSIndexPath *) indexPath
 {		
     District * tempDistrict = (District *) [dataController.statesDistrictsTableNamesSorted objectAtIndex:indexPath.row];
     
     [dataController.myQueriedProjects removeAllObjects];
     
     [dataController.myQueriedProjects addEntriesFromDictionary: [dataController getPropertiesStateDistrict: self.title : tempDistrict.district]];
 
     if ([dataController.myQueriedProjects count] <= kPropertyLexiThreshold)
     {
         ProjectTableViewController *projectTableViewController = [[ProjectTableViewController alloc] initWithStyle:UITableViewStylePlain];
         
         [dataController.projectsTableNamesSorted removeAllObjects];
         
         [dataController.projectsTableNamesSorted addObjectsFromArray: [dataController sortProjectNames]];
         
         projectTableViewController.dataController = dataController;
         projectTableViewController.title = [NSString stringWithFormat:@"District %@", (NSString *) tempDistrict.district];
         [[self navigationController] pushViewController:projectTableViewController animated:YES];
         [projectTableViewController release];
     }
     else
     {
         LexiTableViewController *lexiTableViewController = [[LexiTableViewController alloc] initWithStyle:UITableViewStylePlain];        
         [dataController loadProjects];
         
         lexiTableViewController.dataController = dataController;
         lexiTableViewController.title = [NSString stringWithFormat:@"District %@", (NSString *) tempDistrict.district];
         [[self navigationController] pushViewController:lexiTableViewController animated:YES];
         [lexiTableViewController release];        
     }    
 }

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView 
{
    return 1;
}

- (NSInteger) tableView : (UITableView *) tableView numberOfRowsInSection: (NSInteger) section 
{	
	
	NSInteger rows;
	
	switch (section)
	{
		case 0:
			rows = [dataController.statesDistrictsTable count];
			break;
            
		default:
			rows = 0;
	}
	
	return rows;
}

-(void) viewWillAppear:(BOOL)animated   
{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    [dataController.myQueriedProjects removeAllObjects];
    
    [dataController.myQueriedProjects addEntriesFromDictionary: [dataController getPropertiesState: self.title]];
    
    //NSLog(@"Count of myQueriedProjects: %d", [dataController.myQueriedProjects count]);
    
}

-(void) viewDidLoad
{
    [super viewDidLoad];
 
    UIBarButtonItem * buttonMap = [[UIBarButtonItem alloc] initWithTitle:@"Map" style:UIBarButtonItemStylePlain target:self action:@selector(showMap)];
    
    self.navigationItem.rightBarButtonItem = buttonMap;
    
    [buttonMap release];
    
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
	static NSString *CellIdentifier = @"CellIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
	if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
	} 
	else 
	{
		NSEnumerator *enumeratorSubviews = [cell.contentView.subviews objectEnumerator];
		id aSubviewObject;		
		while ((aSubviewObject = [enumeratorSubviews nextObject])) 
		{
			[(UIView *) aSubviewObject removeFromSuperview];
		}
	}
	
	CGRect subViewFrame = cell.contentView.frame;
    
    subViewFrame.origin.x = 5;
    subViewFrame.size.width = 0.65 * self.view.frame.size.width;
	
	UILabel *districtLabel = [[UILabel alloc] initWithFrame: subViewFrame];	
	districtLabel.frame = subViewFrame;
	districtLabel.highlightedTextColor = [UIColor whiteColor];
	districtLabel.font = [UIFont boldSystemFontOfSize:24];
	districtLabel.backgroundColor = [UIColor clearColor];
	districtLabel.textAlignment = UITextAlignmentLeft;
	districtLabel.adjustsFontSizeToFitWidth = YES;
	districtLabel.textColor = [UIColor blackColor];
    
    subViewFrame = cell.contentView.frame;
    
    subViewFrame.origin.x = 0.67 * self.view.frame.size.width;
    subViewFrame.size.width = 0.18 * self.view.frame.size.width;
	
	UILabel *districtCountLabel = [[UILabel alloc] initWithFrame: subViewFrame];	
	districtCountLabel.frame = subViewFrame;
	districtCountLabel.highlightedTextColor = [UIColor whiteColor];
	districtCountLabel.font = [UIFont boldSystemFontOfSize:24];
	districtCountLabel.backgroundColor = [UIColor clearColor];
	districtCountLabel.textAlignment = UITextAlignmentRight;
	districtCountLabel.adjustsFontSizeToFitWidth = YES;
	districtCountLabel.textColor = [UIColor blackColor];
    
    District * tempDistrict = (District *) [dataController.statesDistrictsTableNamesSorted objectAtIndex:indexPath.row];
    districtLabel.text = [NSString stringWithFormat:@"District %@", tempDistrict.district]; 
    districtCountLabel.text = [NSString stringWithFormat:@"%d", tempDistrict.count];
    
    [cell.contentView addSubview:districtLabel];	
    [cell.contentView addSubview:districtCountLabel];	
	[districtLabel release];
	[districtCountLabel release];
    
    return cell;
}        

@end