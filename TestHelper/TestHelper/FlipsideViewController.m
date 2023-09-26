//
//  FlipsideViewController.m
//  TestHelper
//
//  Created by Vlad Alexa on 1/30/13.
//  Copyright (c) 2013 Vlad Alexa. All rights reserved.
//

#import "FlipsideViewController.h"

@interface FlipsideViewController ()

@end

@implementation FlipsideViewController

							
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.contentSizeForViewInPopover = CGSizeMake(320.0, 480.0);
        
    defaults  = [NSUbiquitousKeyValueStore defaultStore];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    //automate opening test just completed
    if ([self.title isEqualToString:@"autoShowResult"])
    {
        NSIndexPath *index = [NSIndexPath indexPathForRow:[[defaults objectForKey:@"tests"] count]-1 inSection:0];
        [self performSegueWithIdentifier:@"accessory" sender:index];
        [self setTitle:nil];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Actions

- (IBAction)done:(id)sender
{
    [self.delegate flipsideViewControllerDidFinish:self];
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"accessory"])
    {
        if ([sender isKindOfClass:[NSIndexPath class]]) {
            NSIndexPath *indexPath = sender;
            [[segue destinationViewController] setTitle:[NSString stringWithFormat:@"%i",indexPath.row]];
        }
    }
}


#pragma mark UITableViewDelegate


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dict = [[defaults objectForKey:@"tests"] objectAtIndex:indexPath.row];
    if (dict) {
        [self performSegueWithIdentifier:@"accessory" sender:indexPath];
    }else{
        NSLog(@"No details for %i",indexPath.row);
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        NSMutableArray *tests = [NSMutableArray arrayWithArray:[defaults objectForKey:@"tests"]];
        [tests removeObjectAtIndex:indexPath.row];
        [defaults setObject:tests forKey:@"tests"];
		[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];       
    }
}


#pragma mark UITableViewDatasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[defaults objectForKey:@"tests"] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
	UITableViewCell *cell = nil;
    
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
    NSDictionary *info = [[defaults objectForKey:@"tests"] objectAtIndex:indexPath.row];
    
    cell.textLabel.text = [info objectForKey:@"testName"];
    cell.textLabel.font = [UIFont systemFontOfSize:16];
    cell.textLabel.textColor = [UIColor blackColor];
    cell.textLabel.shadowColor = [UIColor colorWithWhite:1.0 alpha:0.8];
    cell.textLabel.shadowOffset = CGSizeMake(0.0, 0.5);
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    
    cell.detailTextLabel.text = [dateFormatter stringFromDate:[info objectForKey:@"startTime"]];
    cell.detailTextLabel.font = [UIFont systemFontOfSize:10];
    cell.detailTextLabel.textColor = [UIColor darkGrayColor];
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	return cell;
}

@end
