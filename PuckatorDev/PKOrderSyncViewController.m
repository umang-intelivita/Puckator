//
//  PKOrderSyncViewController.m
//  PuckatorDev
//
//  Created by Jamie Chapman on 26/05/2015.
//  Copyright (c) 2015 57Digital Ltd. All rights reserved.
//

#import "PKOrderSyncViewController.h"
#import <FCFileManager/FCFileManager.h>
#import "UIFont+Puckator.h"
#import "UIColor+Puckator.h"
#import <UIAlertView-Blocks/UIAlertView+Blocks.h>
#import <MKFoundationKit/MKFoundationKit.h>
#import "PKBasket+Operations.h"
#import "PKOrder.h"
#import "PKConstant.h"

@interface PKOrderSyncViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *imageViewProgress;
@property (weak, nonatomic) IBOutlet UILabel *labelProgress;
@property (weak, nonatomic) IBOutlet UILabel *labelMessage;
@property (nonatomic, strong) NSMutableArray *files;
@property (nonatomic, strong) NSMutableArray *failedUploads;
@property (nonatomic, strong) NSMutableArray *successUploads;
@property (nonatomic, assign) int totalUploads;

@property (strong, nonatomic) NSMutableString *log;

@end

@implementation PKOrderSyncViewController

#pragma mark - Constructor Methods

+ (instancetype)create {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    if (storyboard) {
        return [storyboard instantiateViewControllerWithIdentifier:@"OrderSync"];
    } else {
        return nil;
    }
}

#pragma mark - View Lifecycle Methods

- (void)viewDidLoad {
    [super viewDidLoad];
    [[self navigationItem] setTitle:NSLocalizedString(@"Sync Orders", nil)];
    [[self labelMessage] setText:NSLocalizedString(@"Sending Orders", nil)];
    [self startSync];
}

#pragma mark - Animation Methods

- (void)startAnimating {
    NSMutableArray *images = [[NSMutableArray alloc] init];
    for (int i=0; i <= 19; i++) {
        NSString *imageName = [NSString stringWithFormat:@"loading_%d.gif", i];
        UIImage *image = [UIImage imageNamed:imageName];
        if (image) {
            [images addObject:image];
        }
    }
    
    [[self imageViewProgress] setAnimationImages:images];
    [[self imageViewProgress] setAnimationDuration:1];
    [[self imageViewProgress] startAnimating];
}

- (void)stopAnimating {
    [UIView animateWithDuration:0.3 animations:^{
        [[self imageViewProgress] setTransform:CGAffineTransformMakeScale(0.01, 0.01)];
        [[self imageViewProgress] setAlpha:0.0f];
    } completion:^(BOOL finished) {
        [[self imageViewProgress] stopAnimating];
        
        if ([[self failedUploads] count] >= 1) {
            [[self imageViewProgress] setImage:[UIImage imageNamed:@"PKSyncError.png"]];
        } else {
            [[self imageViewProgress] setImage:[UIImage imageNamed:@"PKSyncSuccess.png"]];
        }
        
        [UIView animateWithDuration:0.3 animations:^{
            [[self imageViewProgress] setTransform:CGAffineTransformIdentity];
            [[self imageViewProgress] setAlpha:1.0f];
        } completion:^(BOOL finished) {
            [self performSelector:@selector(didFinishSync) withObject:nil afterDelay:1.0f];
        }];
    }];
}

#pragma mark - Data Methods

+ (NSMutableArray*) orderFilenames {
    if (kPuckatorDisableOrderSync) {
        return nil;
    }
    
    // Get the path for the order outbox
    NSString *path = [FCFileManager pathForDocumentsDirectoryWithPath:@"order_outbox"];
    NSArray *files = [FCFileManager listFilesInDirectoryAtPath:path withExtension:@"xml"];
    return [NSMutableArray arrayWithArray:files];
}

#pragma mark - Sync Methods

- (void)startSync {
    // Clear the log:
    [self setLog:nil];
    
    // Start the animation:
    [self startAnimating];
    
    // Setup failed and success arrays:
    [self setFailedUploads:[NSMutableArray array]];
    [self setSuccessUploads:[NSMutableArray array]];
    
    // Setup the files queue:
    [self setFiles:[PKOrderSyncViewController orderFilenames]];
    [self setTotalUploads:(int)[[self files] count]];
    
    // Begin uploading the files:
    [self uploadNextFile];
}

- (void)uploadNextFile {
    NSMutableAttributedString *filesText = [[NSMutableAttributedString alloc] init];
    int finishedDownloads = (int)[[self failedUploads] count] + (int)[[self successUploads] count];
    [filesText appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:NSLocalizedString(@"%d of %d", @"How many ($1) of ($2) have been processed so far."), finishedDownloads, [self totalUploads]]
                                                                      attributes:@{NSFontAttributeName:[UIFont puckatorContentTitle], NSForegroundColorAttributeName:[UIColor whiteColor]}]];
    if ([[self failedUploads] count]) {
        [filesText appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"\n(%@)", [NSString stringWithFormat:NSLocalizedString(@"%d failed", @"Used during the order submission process to inform the user how many orders failed to be submitted. E.g. '5 failed'"), [[self failedUploads] count]]]
                                                                          attributes:@{NSFontAttributeName:[UIFont puckatorContentText], NSForegroundColorAttributeName:[UIColor puckatorPink]}]];
    }
    [[self labelProgress] setAttributedText:filesText];
    
    if ([[self files] count] != 0) {
        // Use this error object to track different error situations:
        NSError *error = nil;
        
        // Get the next file to upload
        NSString *path = [[self files] firstObject];
        NSString *filename = [[path componentsSeparatedByString:@"/"] lastObject];
        NSString *orderRef = [filename stringByReplacingOccurrencesOfString:@".xml" withString:@""];
        PKBasket *basket = [PKBasket basketWithOrderRef:orderRef feedNumber:nil context:nil];
        if (![filename containsString:@".xml"]) {
            filename = @"order.xml";
        }
        
        // Check if the file exists at the given path and if not then
        // flag this order as failed:
        if (![FCFileManager isFileItemAtPath:path error:&error]) {
            // Flag as failed:
            [self failedUpload:path basket:basket error:error];
            return;
        }
        
        // Create HTTP request:
        NSString *endpointUri = [NSString stringWithFormat:@"https://puckator-ipad.net/ipad/orders/drop.php?build_version=%@&app_id=%@", [[NSBundle mainBundle] mk_build], [[NSBundle mainBundle] mk_name]];
        NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] multipartFormRequestWithMethod:@"POST" URLString:endpointUri parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
            [formData appendPartWithFileURL:[NSURL fileURLWithPath:path] name:@"orderfile" fileName:filename mimeType:@"text/xml" error:nil];
        } error:&error];
        [request setTimeoutInterval:([[NSUserDefaults standardUserDefaults] boolForKey:@"extend_order_timeout"] == YES ? 200 : 30)];
        
        // Check for an error:
        if (error) {
            // Flag this file as failed:
            [self failedUpload:path basket:basket error:error];
            return;
        }
        
        // Create session:
        AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
        
        // Upload file:
        NSProgress *progress = nil;
        NSURLSessionUploadTask *uploadTask = [manager uploadTaskWithStreamedRequest:request progress:&progress completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
            NSLog(@"\n[%@] \n- Response:\n%@\n- Response Object:\n%@", [self class], response, responseObject);
            
            // Check for an error:
            if (error) {
//                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Debug Error Message"
//                                                                    message:[NSString stringWithFormat:@"Error: %@\n\nResponse: %@", [error localizedDescription], responseObject]
//                                                                   delegate:nil
//                                                          cancelButtonTitle:@"Dismiss"
//                                                          otherButtonTitles:nil];
//                [alertView show];
                
                NSInteger statusCode = [(NSHTTPURLResponse *)[[error userInfo] objectForKey:AFNetworkingOperationFailingURLResponseErrorKey] statusCode];
                if (statusCode == 426) {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Upgrade Required", nil)
                                                                    message:NSLocalizedString(@"The server rejected your order because you are using a version of the Puckator app that is no longer supported.  Please update the app and try again.", nil)
                                                                   delegate:nil
                                                          cancelButtonTitle:NSLocalizedString(@"Dismiss", nil)
                                                          otherButtonTitles:nil];
                    [alert show];
                }
                
                // Flag as failed:
                [self failedUpload:path basket:basket error:error];
            } else {
                // Check for the success flag:
                if ([[responseObject objectForKey:@"success"] boolValue]) {
                    // File upload complete:
                    [self completedUpload:path basket:basket];
                } else {
                    // Flag as failed:
                    [self failedUpload:path basket:basket error:nil];
                }
            }
        }];
        
        // Start the upload:
        [uploadTask resume];
    } else {
        // The files array is now empty therefore stop the animation (which then ends the sync):
        [self stopAnimating];
    }
}

- (void)didFinishSync {
    // Output the log:
    [self outputLog];
    
    // Check if there are any failed upload and if so display an error message
    // to the user and allow them to retry:
    if ([[self failedUploads] count] != 0) {
        // Create the retry button in order to allow the user to retry the upload:
        RIButtonItem *buttonSendLog = nil;
        if ([self log]) {
            buttonSendLog = [RIButtonItem itemWithLabel:NSLocalizedString(@"Send Log", nil) action:^{
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self sendLog];
                });
            }];
        }
        
        // Create the try later button to dismiss the view controller:
        RIButtonItem *buttonCancel = [RIButtonItem itemWithLabel:NSLocalizedString(@"Try Later", nil) action:^{
            [self dismissViewControllerAnimated:YES completion:nil];
        }];
        
        // Create the retry button in order to allow the user to retry the upload:
        RIButtonItem *buttonRetry = [RIButtonItem itemWithLabel:NSLocalizedString(@"Retry", nil) action:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [self startSync];
            });
        }];
        
        // Create the message to be displayed to the user:
        NSMutableString *message = [[NSMutableString alloc] init];
        [message appendString:NSLocalizedString(@"Unfortunately it was not possible to send all your order(s)/quote(s) to the server at this time, please check your Internet connection and try again.", nil)];
        [message appendString:@"\n\n"];
        [message appendString:[NSString stringWithFormat:NSLocalizedString(@"Succeeded: %d order(s)/quote(s)", @"Used during the order/quote submission process to inform the user how many orders/quotes were successful submitted. E.g. 'Succeeded: 5 order(s)/quote(s)'"), [[self successUploads] count]]];
        [message appendString:@"\n"];
        [message appendString:[NSString stringWithFormat:NSLocalizedString(@"Failed: %d order(s)/quote(s)", @"Used during the order/quote submission process to inform the user how many orders/quotes failed to be submitted. E.g. 'Failed: 5 order(s)/quote(s)'"), [[self failedUploads] count]]];
        
        // Show alert to inform of failure:
        NSString *alertTitle = [NSString stringWithFormat:NSLocalizedString(@"Failed: %d order(s)/quote(s)", @"Used during the order/quote submission process to inform the user how many orders/quotes failed to be submitted. E.g. 'Failed: 5 order(s)/quote(s)'"), [[self failedUploads] count]];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:alertTitle
                                                        message:message
                                               cancelButtonItem:buttonCancel
                                               otherButtonItems:buttonRetry, nil];
        
        if (buttonSendLog) {
            [alert addButtonItem:buttonSendLog];
        }
        
        [alert show];
        
        [[self labelProgress] setText:NSLocalizedString(@"Aborted!", nil)];
    } else {
        // Create the dismiss button which dismisses the view controller:
        RIButtonItem *buttonCancel = [RIButtonItem itemWithLabel:NSLocalizedString(@"Dismiss", nil) action:^{
            [self dismissViewControllerAnimated:YES completion:nil];
        }];
        
        // Create the alert message to display to the user:
        NSMutableString *message = [[NSMutableString alloc] init];
        [message appendString:NSLocalizedString(@"Your order(s)/quote(s) have been sent to the server!", nil)];
        [message appendString:@"\n\n"];
        [message appendString:[NSString stringWithFormat:NSLocalizedString(@"Succeeded: %d order(s)/quote(s)", @"Used during the order/quote submission process to inform the user how many orders/quotes were successful submitted. E.g. 'Succeeded: 5 order(s)/quote(s)'"), [[self successUploads] count]]];
        
        // Show alert to inform of success:
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                        message:message
                                               cancelButtonItem:buttonCancel
                                               otherButtonItems:nil];
        [alert show];
    }
}

#pragma mark - Log Methods

- (void)addLogWithPath:(NSString *)path basket:(PKBasket *)basket error:(NSError *)error {
    if (![self log]) {
        [self setLog:[NSMutableString string]];
    }
    
    NSMutableString *log = [NSMutableString string];
    
    NSDate *date = [NSDate date];
    [log appendString:@"\n--------------"];
    [log appendFormat:@"\nLog: %@", [date mk_formattedString]];
    
    [log appendFormat:@"\n\n- ORDER DETAILS -"];
    if (basket) {
        [log appendFormat:@"\nOrder Ref: %@", [[basket order] orderRef]];
        [log appendFormat:@"\nOrder Sent: %@", [[basket wasSent] boolValue] ? @"YES" : @"NO"];
    }
    
    [log appendFormat:@"\n\n- ERROR DETAILS -"];
    if (error) {
        [log appendFormat:@"\nError: %@", [error description]];
    } else {
        [log appendString:@"\nNo error"];
    }
    [log appendString:@"\n--------------"];
    
    [[self log] appendString:log];
}

- (void)outputLog {
    NSLog(@"[%@] - Log: %@", [self class], [self log]);
}

- (void)sendLog {
    if ([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController *controller = [[MFMailComposeViewController alloc] init];
        [controller setMailComposeDelegate:self];
        [controller setSubject:@"PKOrderSyncViewController Log"];
        [controller setMessageBody:[self log] isHTML:NO];
        [controller setToRecipients:@[@"luke.dixon@57digital.co.uk"]];
        [self presentViewController:controller animated:YES completion:^{
        }];
    } else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Log Error"
                                                            message:@"You must have mail enabled on your device in order to send a log"
                                                           delegate:nil
                                                  cancelButtonTitle:@"Dismiss"
                                                  otherButtonTitles:nil];
        [alertView show];
        [self didFinishSync];
    }
}

#pragma mark - MFMailComposeViewControllerDelegate Methods

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    // Clear the log if there is no error:
    if (!error) {
        [self setLog:nil];
    }
    
    // Dismiss the mail view controller:
    [controller dismissViewControllerAnimated:YES completion:^{
        [self didFinishSync];
    }];
}

#pragma mark - Queue Methods (Success/Failure)

- (void)completedUpload:(NSString*)path basket:(PKBasket *)basket {
    // Flag the basket as sent:
    if (basket) {
        // Get if the order was a quote or not:
        BOOL quote = NO;
        NSString *xml = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
        if ([xml length] != 0) {
            quote = ([xml rangeOfString:@"<ORDER_TYPE>QUOTE</ORDER_TYPE>"].location != NSNotFound);
        }
        
        [basket setStatus:quote ? PKBasketStatusQuote : PKBasketStatusComplete shouldSave:NO];
        [basket setWasSent:@(YES)];
        [basket save];
    }
    
    // Add the log:
    [self addLogWithPath:path basket:basket error:nil];
    
    // Remove the file and save the file as sent:
    [self removeFile:path andDelete:YES];
    if (path) {
        [[self successUploads] addObject:path];
    }
    [self uploadNextFile];
}

- (void)failedUpload:(NSString*)path basket:(PKBasket *)basket error:(NSError *)error {
    // Output the error:
    if (error) {
        NSLog(@"[%@] - Error: %@", [self class], [error localizedDescription]);
    }
    
    // Flag the basket as not sent:
    if (basket) {
        // Get if the order was a quote or not:
        BOOL quote = NO;
        NSString *xml = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
        if ([xml length] != 0) {
            quote = ([xml rangeOfString:@"<ORDER_TYPE>QUOTE</ORDER_TYPE>"].location != NSNotFound);
        }
        
        [basket setStatus:quote ? PKBasketStatusQuote : PKBasketStatusComplete shouldSave:NO];
        [basket setWasSent:@(NO)];
        [basket save];
    }
    
    // Add the log:
    [self addLogWithPath:path basket:basket error:error];
    
    // Remove the path:
    [self removeFile:path andDelete:NO];
    if (path) {
        [[self failedUploads] addObject:path];
    }
    [self failAllRemainingFiles];
}

- (void)failAllRemainingFiles {
    // Add all the remaining files from the files array into the failed uploads array:
    [[self failedUploads] addObjectsFromArray:[self files]];
    
    // No remove all the remaining files:
    [[self files] removeAllObjects];
    
    // Continue sync (which will now fail)
    [self uploadNextFile];
}

- (void)removeFile:(NSString*)path andDelete:(BOOL)delete {
    // Loop the files to find the given path:
    [[self files] enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(NSString *obj, NSUInteger idx, BOOL *stop) {
        // Check obj from the loop matches the given path:
        if ([obj isEqualToString:path]) {
            // Delete file:
            if (delete) {
                if ([FCFileManager isFileItemAtPath:path]) {
                    [FCFileManager removeItemAtPath:obj];
                }
            }
            
            // Remove from list of files to process:
            if (idx < [[self files] count]) {
                [[self files] removeObjectAtIndex:idx];
            }
            
            // The file was found and removed therefore stop the loop:
            *stop = YES;
        }
    }];
}

#pragma mark -

@end
