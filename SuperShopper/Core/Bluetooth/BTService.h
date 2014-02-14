//
//  BTService.h
//  SuperShopper
//
//  Created by Udit on 1/26/14.
//  Copyright (c) 2014 Nagarro. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GameKit/GameKit.h>

@protocol BTServiceDelegate <NSObject>

-(void)dataSentWithSuccess;
-(void)dataSendFailedWithError:(NSError*)error;
-(void)handleReceivedDate:(NSData *)data;

@end


@interface BTService : NSObject <GKSessionDelegate, GKPeerPickerControllerDelegate>

@property (strong, nonatomic) id<BTServiceDelegate> delegate;
@property (strong, nonatomic) GKSession *session;

@end
