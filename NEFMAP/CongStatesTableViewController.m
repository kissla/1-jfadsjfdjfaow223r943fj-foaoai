#import "CongStatesTableViewController.h"

@implementation CongStatesTableViewController

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
    tempStateLabel.text = NSLocalizedString(@"State",@"State");
    
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
	tempRect.origin.x = 0.47 * self.view.frame.size.width;
	tempRect.size.width = 0.38 * self.view.frame.size.width;
    
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
			tempProjectCountLabel.text = [NSString stringWithFormat:@"Total Projects: %d", [dataController.myQueriedProjects count]];
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
    CongDistTableViewController *congDistTableViewController = [[CongDistTableViewController alloc] initWithStyle:UITableViewStylePlain];
    
    [dataController.statesDistrictsTable removeAllObjects];
        
    [dataController.statesDistrictsTable addEntriesFromDictionary: [dataController getStateDistricts:(NSString *) [dataController.statesTableKeysSorted objectAtIndex:indexPath.row]]];
    
    //NSLog(@"Count after: %d", [[dataController getStateDistricts:(NSString *) [dataController.statesTableKeysSorted objectAtIndex:indexPath.row]] count]);

    [dataController.statesDistrictsTableNamesSorted removeAllObjects];
    
    [dataController.statesDistrictsTableNamesSorted addObjectsFromArray:[dataController sortDistrictNames]];
    
    [dataController.myQueriedProjects removeAllObjects];
    
    [dataController.myQueriedProjects addEntriesFromDictionary: [dataController getPropertiesState:(NSString *) [dataController.statesTableKeysSorted objectAtIndex:indexPath.row]]];
    //NSLog(@"Count of myQueriedProjects: %d", [dataController.myQueriedProjects count]);
    
    congDistTableViewController.dataController = dataController;
    congDistTableViewController.title = (NSString *) [dataController.statesTableKeysSorted objectAtIndex:indexPath.row];
    [[self navigationController] pushViewController:congDistTableViewController animated:YES];
    [congDistTableViewController release];
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
			rows = [dataController.statesTable count];
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
    
    [dataController.myQueriedProjects addEntriesFromDictionary: [dataController getPropertiesAllOfThem]];
    
    //NSLog(@"Count of myQueriedProjects: %d", [dataController.myQueriedProjects count]);
    

}

-(void) viewDidLoad
{
    [super viewDidLoad];
 
    UIBarButtonItem * buttonMap = [[UIBarButtonItem alloc] initWithTitle:@"Map" style:UIBarButtonSystemItemAction target:self action:@selector(showMap)];
    
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
	
	UILabel *stateLabel = [[UILabel alloc] initWithFrame: subViewFrame];	
	stateLabel.frame = subViewFrame;
	stateLabel.highlightedTextColor = [UIColor whiteColor];
	stateLabel.font = [UIFont boldSystemFontOfSize:24];
	stateLabel.backgroundColor = [UIColor clearColor];
	stateLabel.textAlignment = UITextAlignmentLeft;
	stateLabel.adjustsFontSizeToFitWidth = YES;
	stateLabel.textColor = [UIColor blackColor];
    
    subViewFrame = cell.contentView.frame;
    
    subViewFrame.origin.x = 0.67 * self.view.frame.size.width;
    subViewFrame.size.width = 0.18 * self.view.frame.size.width;
	
	UILabel *stateCountLabel = [[UILabel alloc] initWithFrame: subViewFrame];	
	stateCountLabel.frame = subViewFrame;
	stateCountLabel.highlightedTextColor = [UIColor whiteColor];
	stateCountLabel.font = [UIFont boldSystemFontOfSize:24];
	stateCountLabel.backgroundColor = [UIColor clearColor];
	stateCountLabel.textAlignment = UITextAlignmentRight;
	stateCountLabel.adjustsFontSizeToFitWidth = YES;
	stateCountLabel.textColor = [UIColor blackColor];
    
    switch (indexPath.section) 
    {
        case 0:
            switch (indexPath.row) 
        {
            default:
                stateLabel.text = (NSString *) [dataController.statesTableKeysSorted objectAtIndex:indexPath.row];
                State * tempState = (State *) [dataController.statesTable objectForKey:stateLabel.text];
                stateCountLabel.text = [NSString stringWithFormat:@"%d", tempState.count];
                break;
        }
            break;
            
        default:
            break;
    }
    
    [cell.contentView addSubview:stateLabel];	
    [cell.contentView addSubview:stateCountLabel];	
	[stateLabel release];
	[stateCountLabel release];
    
    return cell;
}        

@end