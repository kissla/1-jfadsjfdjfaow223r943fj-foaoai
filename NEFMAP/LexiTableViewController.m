#import "LexiTableViewController.h"

@implementation LexiTableViewController

@synthesize dataController;


-(void) viewWillDisappear:(BOOL)animated   
{
    if ([self.navigationController.topViewController isKindOfClass: [UITabBarController class]])
    {
        [dataController.myQueriedProjects removeAllObjects];
        
        [dataController.myQueriedProjects addEntriesFromDictionary: dataController.myQueriedProjectsFixed];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	CGFloat rowHeight;
	
	switch (indexPath.section)
	{
		default:
			rowHeight = kProjectViewCellHeight;
			break;
	}
	return rowHeight;
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

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    return [dataController.uaAlphaCurrent indexOfObject:title];
}
 

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView 
{
	
	NSMutableArray * tempArray0 = [NSMutableArray arrayWithCapacity:1];	
	NSMutableArray * tempArray1 = [NSMutableArray arrayWithCapacity:1];
	
	NSInteger countOfArrays;
	
    countOfArrays = [dataController.uaAlphaCurrent count];	
    [tempArray1 addObjectsFromArray:dataController.uaAlphaCurrent];

	for (int i=0; i < countOfArrays; i++)
	{
		NSInteger sectionCount = [[dataController.indexListProjects objectAtIndex:i] count];
		if (sectionCount == 0)
		{
			[tempArray0 addObject:[tempArray1 objectAtIndex:i]];
		}
	}
	[tempArray1 removeObjectsInArray:tempArray0];
	
	return (NSArray *) tempArray1;
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
	
	if ([[dataController.indexListProjects objectAtIndex:section] count] > 0) 
	{
		UIView * tempBorderView = [[[UIView alloc] initWithFrame:CGRectMake(0,0,[[UIScreen mainScreen] bounds].size.width,24)] autorelease];
		tempBorderView.backgroundColor = [UIColor lightGrayColor];
		
		UILabel * tempTeamLabel = [[UILabel alloc] initWithFrame: CGRectMake(7,0,[[UIScreen mainScreen] bounds].size.width,22)];
		tempTeamLabel.font = [UIFont boldSystemFontOfSize:18];
        tempTeamLabel.textColor = [UIColor blueColor];
		tempTeamLabel.backgroundColor = [UIColor clearColor];
		tempTeamLabel.shadowOffset = CGSizeMake(0, 1);
		tempTeamLabel.textAlignment = UITextAlignmentLeft;
		
        tempTeamLabel.text = [NSString stringWithFormat:@"%@", [dataController.uaAlphaCurrent objectAtIndex:section]];
        tempTeamLabel.shadowColor = [UIColor colorWithWhite:0 alpha:0.6];
        
		[tempBorderView addSubview:tempTeamLabel];
		[tempTeamLabel release];
        
		return tempBorderView;
	}
	else 
	{
		return nil;
	}
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath: (NSIndexPath *) indexPath
{		
    NSArray * tempArray = [NSArray arrayWithArray:[dataController.indexListProjects objectAtIndex:indexPath.section]];
    
    Project * tempProject = (Project *) [tempArray objectAtIndex:indexPath.row];
    
    dataController.strProjectID = [NSString stringWithFormat:@"%d", tempProject.projectID];
    
    AnnotationQueryDetailViewController * myAnnotationQueryDetailViewController = [[AnnotationQueryDetailViewController alloc] init];
    myAnnotationQueryDetailViewController.dataController = dataController;
    
    [[self navigationController] pushViewController:myAnnotationQueryDetailViewController animated:YES];
    [myAnnotationQueryDetailViewController release];
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView 
{
	return [dataController.indexListProjects count];
}

- (NSInteger) tableView : (UITableView *) tableView numberOfRowsInSection: (NSInteger) section 
{	
	return [[dataController.indexListProjects objectAtIndex:section] count];
}

-(void) viewWillAppear:(BOOL)animated   
{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    self.tabBarController.title = @"Projects";
    
}

-(void) viewDidAppear:(BOOL)animated   
{
    [super viewDidAppear:animated];

    [self.tableView reloadData];
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
    subViewFrame.origin.y = 0.02 * kProjectViewCellHeight;
    subViewFrame.size.width = 0.75 * self.view.frame.size.width;
    subViewFrame.size.height = 0.42 * kProjectViewCellHeight;
	
	UILabel *projectNameLabel = [[UILabel alloc] initWithFrame: subViewFrame];	
	projectNameLabel.frame = subViewFrame;
	projectNameLabel.highlightedTextColor = [UIColor whiteColor];
	projectNameLabel.font = [UIFont boldSystemFontOfSize:24];
	projectNameLabel.backgroundColor = [UIColor clearColor];
	projectNameLabel.textAlignment = UITextAlignmentLeft;
	projectNameLabel.adjustsFontSizeToFitWidth = YES;
	projectNameLabel.textColor = [UIColor blackColor];
    
	subViewFrame = cell.contentView.frame;
    
    subViewFrame.origin.x = 5;
    subViewFrame.origin.y = 0.48 * kProjectViewCellHeight;
    subViewFrame.size.width = 0.75 * self.view.frame.size.width;
    subViewFrame.size.height = 0.23 * kProjectViewCellHeight;
	
	UILabel *projectAddressLabel = [[UILabel alloc] initWithFrame: subViewFrame];	
	projectAddressLabel.frame = subViewFrame;
	projectAddressLabel.highlightedTextColor = [UIColor whiteColor];
	projectAddressLabel.font = [UIFont boldSystemFontOfSize:14];
	projectAddressLabel.backgroundColor = [UIColor clearColor];
	projectAddressLabel.textAlignment = UITextAlignmentLeft;
	projectAddressLabel.adjustsFontSizeToFitWidth = YES;
	projectAddressLabel.textColor = [UIColor darkGrayColor];
	
    subViewFrame = cell.contentView.frame;
    
    subViewFrame.origin.x = 5;
    subViewFrame.origin.y = 0.73 * kProjectViewCellHeight;
    subViewFrame.size.width = 0.75 * self.view.frame.size.width;
    subViewFrame.size.height = 0.23 * kProjectViewCellHeight;
	
	UILabel *projectCityStateLabel = [[UILabel alloc] initWithFrame: subViewFrame];	
	projectCityStateLabel.frame = subViewFrame;
	projectCityStateLabel.highlightedTextColor = [UIColor whiteColor];
	projectCityStateLabel.font = [UIFont boldSystemFontOfSize:14];
	projectCityStateLabel.backgroundColor = [UIColor clearColor];
	projectCityStateLabel.textAlignment = UITextAlignmentLeft;
	projectCityStateLabel.adjustsFontSizeToFitWidth = YES;
	projectCityStateLabel.textColor = [UIColor darkGrayColor];
        
    NSArray * tempArray = [NSArray arrayWithArray:[dataController.indexListProjects objectAtIndex:indexPath.section]];
            
    Project * tempProject = (Project *) [tempArray objectAtIndex:indexPath.row];
    projectNameLabel.text = tempProject.name;
    projectAddressLabel.text = tempProject.address;
    projectCityStateLabel.text = [NSString stringWithFormat: @"%@, %@  %@", tempProject.city, tempProject.state, tempProject.zipCode];
    
    [cell.contentView addSubview:projectNameLabel];	
    [cell.contentView addSubview:projectAddressLabel];	
    [cell.contentView addSubview:projectCityStateLabel];	
	[projectNameLabel release];
    [projectAddressLabel release];
    [projectCityStateLabel release];
    
    return cell;
}        


@end

