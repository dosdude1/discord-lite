//
//  DLMessageEditor.h
//  Discord Lite
//
//  Created by Collin Mistr on 11/28/21.
//  Copyright (c) 2021 dosdude1. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DLMessage.h"

#define kTagAttribute "tagged"

@protocol DLMessageEditorDelegate <NSObject>
@optional
-(void)editorContentDidUpdateWithAttributedString:(NSAttributedString *)as;
@end

@interface DLMessageEditor : NSObject {
    NSMutableArray *mentionedUsers;
    NSMutableArray *attachments;
    NSString *userContent;
    id<DLMessageEditorDelegate> delegate;
}

-(id)init;
-(void)setDelegate:(id<DLMessageEditorDelegate>)inDelegate;

-(void)setContent:(NSString *)inContent;
-(void)addMentionedUser:(DLUser *)u byReplacingStringInRange:(NSRange)range;
-(void)addAttachment:(DLAttachment *)a;
-(void)removeMentionedUserAtStringIndex:(NSInteger)sIndex;
-(void)removeAttachment:(DLAttachment *)a;

-(DLMessage *)finalizedMessage;

-(void)clear;
@end
