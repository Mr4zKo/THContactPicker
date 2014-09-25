//
//  THContact.m
//  Pods
//
//  Created by Michal Mrazik on 14/08/14.
//
//

#import "THContact.h"

@interface THContact()

@property(nonatomic, strong) NSString *nameNoDiacritics;

@end

@implementation THContact

-(id)init{
    
    if(self = [super init]){
        self.name = @"";
        self.phoneNumbers = [[NSMutableArray alloc] init];
        self.nameNoDiacritics = @"";
    }
    
    return self;
}

-(void)setName:(NSString *)name{
    _name = name;
    self.nameNoDiacritics = [THContact removeDiacritics:self.name];
}

-(void)addPhoneNumber:(NSString*)number{
    [self.phoneNumbers addObject:number];
}

-(NSString *)phoneNumber{
    if(self.phoneNumbers.count>0){
        return [self.phoneNumbers objectAtIndex:0];
    }
    
    else return @"";
}

-(BOOL)matchesFilterString:(NSString *)filterString{
    
    NSString *trimed = filterString;
    
    if([trimed hasPrefix:@" "]){
        trimed = [trimed substringFromIndex:1];
    }
    
    if([self string:self.nameNoDiacritics containsSubstring:trimed]){
        
        [self generateSpannableStringsForSubstring:trimed];
        
        return YES;
    }
    
    for(int i=0; i<[self.phoneNumbers count]; i++){
        if([self string:[self.phoneNumbers objectAtIndex:i] containsSubstring:trimed]){
            
            [self generateSpannableStringsForSubstring:trimed];
            
            return YES;
        }
    }
    
    return NO;
}

- (BOOL)string:(NSString*)string containsSubstring:(NSString *)substring{
    
    NSString *lowerCaseString = [string lowercaseString];
    NSString *lowerCaseSubstring = [substring lowercaseString];
    
    NSArray *stringArray = [lowerCaseString componentsSeparatedByString:@" "];
    NSArray *substringArray = [lowerCaseSubstring componentsSeparatedByString:@" "];
    
    for(NSString *str in stringArray){
        for(NSString *substr in substringArray){
            if([str hasPrefix:substr]){
                return YES;
            }
        }
    }
    
    return NO;
}

-(void)generateSpannableStringsForSubstring:(NSString *)substring{
    
    UIFont *regularSmallFont = [UIFont systemFontOfSize:UIFont.systemFontSize-2];
    UIFont *boldSmallFont = [UIFont boldSystemFontOfSize:UIFont.systemFontSize-2];
    
    UIFont *regularFont = [UIFont systemFontOfSize:UIFont.systemFontSize];
    UIFont *boldFont = [UIFont boldSystemFontOfSize:UIFont.systemFontSize];
    
    NSDictionary *regSmallAttrs = [NSDictionary dictionaryWithObjectsAndKeys:
                           regularSmallFont, NSFontAttributeName, nil];
    NSDictionary *boldSmallAttrs = [NSDictionary dictionaryWithObjectsAndKeys:
                                   boldSmallFont, NSFontAttributeName, nil];
    NSDictionary *regAttrs = [NSDictionary dictionaryWithObjectsAndKeys:
                                   regularFont, NSFontAttributeName, nil];
    NSDictionary *boldAttrs = [NSDictionary dictionaryWithObjectsAndKeys:
                                   boldFont, NSFontAttributeName, nil];
    
    if([self.phoneNumbers count]>0){
        NSString *phoneNumber = [self.phoneNumbers objectAtIndex:0];
        NSMutableAttributedString *attrNumberString = [[NSMutableAttributedString alloc]
                                                 initWithString:[NSString stringWithFormat:@"%@ %@", self.type, phoneNumber] attributes:regSmallAttrs];
        
        if(![substring isEqualToString:@" "] &&
           [self string:phoneNumber containsSubstring:substring]){
            
            [attrNumberString setAttributes:boldSmallAttrs range:NSMakeRange(0, [self.type length])];
        }
        
        self.attributedNumberLabel = attrNumberString;
    }

    NSMutableAttributedString *attrNameString = [[NSMutableAttributedString alloc]
                                                   initWithString:[NSString stringWithFormat:@"%@", self.name] attributes:regAttrs];
    
    NSArray *nameComponents = [self.name componentsSeparatedByString:@" "];
    NSUInteger lastNameEndPosition = 0;
    for(int i=0; i<nameComponents.count; i++){
        
        NSString *namePart = [nameComponents objectAtIndex:i];
        
        if([self string:namePart containsSubstring:substring]){
               
            [attrNameString setAttributes:boldAttrs range:NSMakeRange(lastNameEndPosition, [namePart length])];
           
        }
        
        lastNameEndPosition = lastNameEndPosition + [namePart length]+1;
    }
    
    self.attributedNameLabel = attrNameString;
}

+(NSString *)removeDiacritics:(NSString *)stringToRemove{
    NSString *newString = [[NSString alloc]
                           initWithData:
                           [stringToRemove dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES]
                           encoding:NSASCIIStringEncoding];

    return newString;
}

@end
