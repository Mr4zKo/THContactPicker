//
//  ContactTableViewCell.m
//  Skuska
//
//  Created by Michal Mrazik on 13/08/14.
//  Copyright (c) 2014 Michal Mrazik. All rights reserved.
//

#import "THContactTableViewCell.h"

@implementation THContactTableViewCell

- (void)awakeFromNib
{
    // Initialization code
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if(self){
        self.nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 6, 280, 21)];
        self.numberLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 26, 280, 21)];
    
        [self.contentView setFrame:CGRectMake(0, 0, 320, 54)];
        [self.contentView addSubview:self.nameLabel];
        [self.contentView addSubview:self.numberLabel];
    }
    
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
