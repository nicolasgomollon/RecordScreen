//
//  RecordingsViewController.m
//  RecordScreen
//
//  Created by Nicolas Gomollon on 1/4/13.
//  Copyright (c) 2013 Techno-Magic. All rights reserved.
//

#import "RecordingsViewController.h"

@implementation RecordingsViewController


- (id)init {
	self = [super init];
	if (self) {
		// Custom initialization
		[self setTitle:@"Recordings"];
		[self.tabBarItem setImage:[UIImage imageNamed:@"TabBar-Recordings.png"]];
	}
	return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];
 
	// Uncomment the following line to display an Edit button in the navigation bar for this view controller.
	// self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}


#pragma mark -
#pragma mark NSFileManager Methods

- (NSString *)inDocumentsDirectory:(NSString *)path {
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	return [documentsDirectory stringByAppendingPathComponent:path];
}

- (NSArray *)contentsOfDocumentsDirectory {
	NSError *error = nil;
	NSArray *filesArray = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[self inDocumentsDirectory:@""] error:&error];
	if (error != nil) {
		NSLog(@"Error reading files: %@", [error localizedDescription]);
		return nil;
	}
	
	// Sort by creation date.
	NSMutableArray *filesAndProperties = [NSMutableArray arrayWithCapacity:[filesArray count]];
	for (NSString *file in filesArray) {
		NSString *filePath = [self inDocumentsDirectory:file];
		
		NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:&error];
		NSDate *lastModifiedDate = [fileAttributes objectForKey:NSFileModificationDate];
		
		if (error == nil)
			[filesAndProperties addObject:@{@"path" : file, NSFileModificationDate : lastModifiedDate}];
	}
	
	// Sort using a block.
	// (Order reversed as we want latest date first.)
	NSArray *sortedFiles = [filesAndProperties sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
		// Compare
		NSComparisonResult comparison = [obj1[NSFileModificationDate] compare:obj2[NSFileModificationDate]];
		
		// Reverse order
		if (comparison == NSOrderedDescending) {
			comparison = NSOrderedAscending;
		} else if (comparison == NSOrderedAscending) {
			comparison = NSOrderedDescending;
		}
		
		return comparison;
	}];
	
	return sortedFiles;
}

- (NSString *)formattedFileSize:(unsigned long long)size {
	NSString *formattedStr = nil;
	if (size == 0)
		formattedStr = @"Empty";
	else
		if (size > 0 && size < 1024)
			formattedStr = [NSString stringWithFormat:@"%qu bytes", size];
		else
			if (size >= 1024 && size < pow(1024, 2))
				formattedStr = [NSString stringWithFormat:@"%.1f KB", (size / 1024.)];
			else
				if (size >= pow(1024, 2) && size < pow(1024, 3))
					formattedStr = [NSString stringWithFormat:@"%.2f MB", (size / pow(1024, 2))];
				else
					if (size >= pow(1024, 3))
						formattedStr = [NSString stringWithFormat:@"%.3f GB", (size / pow(1024, 3))];
	
	return formattedStr;
}

- (unsigned long long int)folderSize:(NSString *)folderPath {
	NSArray *filesArray = [[NSFileManager defaultManager] subpathsOfDirectoryAtPath:folderPath error:nil];
	NSEnumerator *filesEnumerator = [filesArray objectEnumerator];
	NSString *fileName;
	unsigned long long int fileSize = 0;
	
	while (fileName = [filesEnumerator nextObject]) {
		NSDictionary *fileDictionary = [[NSFileManager defaultManager] attributesOfItemAtPath:[folderPath stringByAppendingPathComponent:fileName] error:nil];
		fileSize += [fileDictionary fileSize];
	}
	
	return fileSize;
}

- (NSString *)formattedLastModifiedDate:(NSDate *)lastModifiedDate {
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateStyle:NSDateFormatterMediumStyle];
	[dateFormatter setTimeStyle:NSDateFormatterShortStyle];
	
	NSString *lastModifiedString = [dateFormatter stringFromDate:lastModifiedDate];
	return lastModifiedString;
}


#pragma mark -
#pragma mark UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	// Return the number of sections.
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	// Return the number of rows in the section.
	return [[self contentsOfDocumentsDirectory] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *CellIdentifier = @"Cell";
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil)
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
	
	// Configure the cell...
	[cell setAccessoryType:UITableViewCellAccessoryDetailDisclosureButton];
	
	NSArray *contentsOfDocumentsDirectory = [self contentsOfDocumentsDirectory];
	NSDictionary *file = contentsOfDocumentsDirectory[indexPath.row];
	NSString *filePath = file[@"path"];
	
	NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil];
	NSInteger fileSize = [[fileAttributes objectForKey:NSFileSize] intValue];
	NSDate *lastModifiedDate = [fileAttributes objectForKey:NSFileModificationDate];
	
	NSString *detailText = [NSString stringWithFormat:@"%@\t%@", [self formattedLastModifiedDate:lastModifiedDate], [self formattedFileSize:fileSize]];
	
	[cell.textLabel setText:[filePath lastPathComponent]];
	[cell.detailTextLabel setText:detailText];
	
	UILabel *footerLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 44.0f)];
	[footerLabel setBackgroundColor:[UIColor clearColor]];
	[footerLabel setFont:[UIFont systemFontOfSize:20.0f]];
	[footerLabel setTextAlignment:UITextAlignmentCenter];
	[footerLabel setTextColor:[UIColor grayColor]];
	[footerLabel setText:[NSString stringWithFormat:@"%i Recordings - %@", [contentsOfDocumentsDirectory count], [self formattedFileSize:[self folderSize:[self inDocumentsDirectory:@""]]]]];
	[tableView setTableFooterView:footerLabel];
	
	return cell;
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
	// Return NO if you do not want the specified item to be editable.
	return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	if (editingStyle == UITableViewCellEditingStyleDelete) {
		// Delete the row from the data source
		NSArray *contentsOfDocumentsDirectory = [self contentsOfDocumentsDirectory];
		NSDictionary *file = contentsOfDocumentsDirectory[indexPath.row];
		NSString *filePath = file[@"path"];
		
		NSError *error = nil;
		[[NSFileManager defaultManager] removeItemAtPath:filePath error:&error];
		
		if (error == nil)
			[tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationRight];
		else
			NSLog(@"Error removing item: %@", [error localizedDescription]);
	}
}


#pragma mark -
#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	// Navigation logic may go here. Create and push another view controller.
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
// TODO: Make sure to pass the selected recording.
	MPMoviePlayerViewController *moviePlayerController = [[MPMoviePlayerViewController alloc] initWithContentURL:[NSURL fileURLWithPath:[self inDocumentsDirectory:@"video.mp4"]]];
	[moviePlayerController.moviePlayer prepareToPlay];
	[self presentMoviePlayerViewControllerAnimated:moviePlayerController];
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
// TODO: Make sure to pass the selected recording.
	UIDocumentInteractionController *interactionController = [UIDocumentInteractionController interactionControllerWithURL:[NSURL fileURLWithPath:[self inDocumentsDirectory:@"video.mp4"]]];
	[interactionController presentOptionsMenuFromRect:[tableView cellForRowAtIndexPath:indexPath].frame inView:self.view animated:YES];
}

@end
