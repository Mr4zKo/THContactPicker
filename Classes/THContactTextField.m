//
//  THContactTextField.m
//  ContactPicker
//
//  Created by mysteriouss on 14-5-13.
//  Copyright (c) 2014 mysteriouss. All rights reserved.
//

#import "THContactTextField.h"

#define IS_OS_8_OR_LATER    ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)

@implementation THContactTextField

- (id)init {
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldTextDidChange:) name:UITextFieldTextDidChangeNotification object:self];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)deleteBackward {
    BOOL isTextFieldEmpty = (self.text.length == 0);
    if (isTextFieldEmpty){
        if ([self.delegate respondsToSelector:@selector(textFieldDidHitBackspaceWithEmptyText:)]){
            [self.delegate textFieldDidHitBackspaceWithEmptyText:self];
        }
    }
    [super deleteBackward];
}

// warning private
- (BOOL)keyboardInputShouldDelete:(UITextField *)textField {
    BOOL shouldDelete = YES;
    
    if ([UITextField instancesRespondToSelector:_cmd]) {
        BOOL (*keyboardInputShouldDelete)(id, SEL, UITextField *) = (BOOL (*)(id, SEL, UITextField *))[UITextField instanceMethodForSelector:_cmd];
        
        if (keyboardInputShouldDelete) {
            shouldDelete = keyboardInputShouldDelete(self, _cmd, textField);
        }
    }
    
    if (![textField.text length] && IS_OS_8_OR_LATER) {
        [self deleteBackward];
    }
    
    return shouldDelete;
}

- (void)textFieldTextDidChange:(NSNotification *)notification {
    
    if([self.text length]<1){
        if ([self.delegate respondsToSelector:@selector(textFieldDidHitBackspaceWithEmptyText:)]){
            [self.delegate textFieldDidHitBackspaceWithEmptyText:self];
        }
        return;
    }

    if([[self text] isEqualToString:@"  "]){
        [self setText:@" "];
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(textFieldDidChange:)]){
        [self.delegate textFieldDidChange:self];
    }
}

@end
