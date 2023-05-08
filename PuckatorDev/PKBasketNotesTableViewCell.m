//
//  PKBasketNotesTableViewCell.m
//  Puckator
//
//  Created by Luke Dixon on 26/06/2015.
//  Copyright (c) 2015 57Digital Ltd. All rights reserved.
//

#import "PKBasketNotesTableViewCell.h"

@interface PKBasketNotesTableViewCell ()

@property (weak, nonatomic) IBOutlet UITextView *textViewNotes;

@end

@implementation PKBasketNotesTableViewCell

#pragma mark - View Lifecycle

- (void)awakeFromNib {
    [super awakeFromNib];
    [[self textViewNotes] setText:nil];
    [[self textViewNotes] setEditable:NO];
    [[self textViewNotes] setUserInteractionEnabled:NO];
}

#pragma mark - Public Methods

- (void)setupWithNotes:(NSString *)notes {
    [[self textViewNotes] setText:notes];
}

#pragma mark -

@end