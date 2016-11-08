//
//  ViewController.m
//  IconMaker
//
//  Created by Pushkraj-MacMini on 04/04/16.
//  Copyright © 2016 Pushkraj-MacMini. All rights reserved.
//

#import "ViewController.h"

@implementation ViewController
{
	IBOutlet NSImageView *imageViewIcon;
	NSArray * arrayIconSizes;
	NSImage * imageToCrop;
}
- (void)viewDidLoad {
	[super viewDidLoad];

	[self makeDirectory];
	arrayIconSizes = [[NSArray alloc]initWithObjects:@29,@30,@40,@57,@60,@80,@120,@127,@180, nil];
}

- (IBAction)buttonChooseIconClicked:(id)sender {
	NSArray *fileTypes = [NSArray arrayWithObjects:@"jpg",@"png",nil];
	NSOpenPanel * openDlg = [NSOpenPanel openPanel];
	[openDlg setAllowsMultipleSelection:NO];
	[openDlg setCanChooseDirectories:NO];
	[openDlg setCanChooseFiles:YES];
	[openDlg setFloatingPanel:YES];
	[openDlg setAllowedFileTypes:fileTypes];
	[openDlg beginWithCompletionHandler:^(NSInteger result){
		NSData *imgData;
		NSImage *img = [[NSImage alloc]initWithContentsOfURL:openDlg.URL];
		imgData = [NSData dataWithContentsOfURL:openDlg.URL];
		if(img) {
			if(img.size.width == 1024 && img.size.height == 1024) {
				imageViewIcon.image = img;
				imageToCrop = img;
			}
			else {
				[self showValidationAlert];
			}
		}
	}];
}

- (IBAction)buttonCropIconsTapped:(id)sender {
	if (imageToCrop) {
		[self converIconToMultipleSizes:imageToCrop];
	}
	else {
		[self showValidationAlert];
	}
}

-(void) showValidationAlert {
	NSAlert *alert = [[NSAlert alloc] init];
	[alert setMessageText:@"Please select icon of 1024 bi 1024 resolution of type .jpg or .png"];
	[alert addButtonWithTitle:@"Ok"];
	[alert runModal];
}

-(void)converIconToMultipleSizes:(NSImage *) imageToConvert {

	for (int index = 0; index < arrayIconSizes.count; index++) {
		int cell_width, cell_height;
		cell_width = [[arrayIconSizes objectAtIndex:index] floatValue];
		cell_height = [[arrayIconSizes objectAtIndex:index] floatValue];

		if ([imageToConvert isValid]) {
			NSSize imageSize = [imageToConvert size];
			float width  = imageSize.width;
			float height = imageSize.height;
			float targetWidth  = [[arrayIconSizes objectAtIndex:index] floatValue];
			float targetHeight = [[arrayIconSizes objectAtIndex:index] floatValue];
			float scaleFactor  = 0.0;
			float scaledWidth  = targetWidth;
			float scaledHeight = targetHeight;

			NSPoint thumbnailPoint = NSZeroPoint;
			if (!NSEqualSizes(imageSize, CGSizeMake(targetWidth, targetHeight)))
			{
				float widthFactor  = targetWidth / width;
				float heightFactor = targetHeight / height;

				if (widthFactor < heightFactor) {
					scaleFactor = widthFactor;
				}
				else {
					scaleFactor = heightFactor;
				}
				scaledWidth  = width  * scaleFactor;
				scaledHeight = height * scaleFactor;

				if (widthFactor < heightFactor) {
					thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
				}
				else if (widthFactor > heightFactor) {
					thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
				}

				NSImage *newImage = [[NSImage alloc] initWithSize:CGSizeMake(targetWidth, targetHeight)];
				[newImage lockFocus];

				NSRect thumbnailRect;
				thumbnailRect.origin = thumbnailPoint;
				thumbnailRect.size.width = scaledWidth;
				thumbnailRect.size.height = scaledHeight;

				[imageToConvert drawInRect:thumbnailRect
								  fromRect:NSZeroRect
								 operation:NSCompositeSourceOver
								  fraction:1.0];

				[newImage unlockFocus];
				NSData *imageData = [newImage TIFFRepresentation];
				NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
				NSString *documentsDirectory = [paths objectAtIndex:0];
				NSString *myDirectory = [documentsDirectory stringByAppendingPathComponent:@"/IconMakerAssets"];
				[imageData writeToFile:[NSString stringWithFormat:@"%@/%dbi%d.png",myDirectory,[[arrayIconSizes objectAtIndex:index] intValue],[[arrayIconSizes objectAtIndex:index] intValue]] atomically:NO];
			}
		}
	}
}

-(void) makeDirectory {
	NSFileManager *fileManager= [NSFileManager defaultManager];
	BOOL isDirectory;
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *myDirectory = [documentsDirectory stringByAppendingPathComponent:@"/IconMakerAssets"];
	if (![fileManager fileExistsAtPath:myDirectory isDirectory:&isDirectory] || !isDirectory) {
		NSError *error = nil;
		[fileManager createDirectoryAtPath:myDirectory
			   withIntermediateDirectories:YES
								attributes:nil
									 error:&error];
		if (error)
			NSLog(@"Error creating directory path: %@", [error localizedDescription]);
	}
}

- (void)setRepresentedObject:(id)representedObject {
	[super setRepresentedObject:representedObject];

	// Update the view, if already loaded.
}

@end
