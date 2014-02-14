//
//  BTService.m
//  SuperShopper
//
//  Created by Udit on 1/26/14.
//  Copyright (c) 2014 Nagarro. All rights reserved.
//

#import "BTService.h"

@implementation BTService
{
    NSString* _connectedPeerID;
}

+(id)sharedInstance
{
    static BTService *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    
    return sharedInstance;
}

-(id)init
{
    self = [super init];
    return self;
}

-(void)connectToDevice
{
    if (self.session == nil)
    {
        //create peer picker and show picker of connections
        GKPeerPickerController *peerPicker = [[GKPeerPickerController alloc] init];
        peerPicker.delegate = self;
        peerPicker.connectionTypesMask = GKPeerPickerConnectionTypeNearby;
        [peerPicker show];
    }
}

#pragma mark GKPeerPickerControllerDelegate

- (GKSession *)peerPickerController:(GKPeerPickerController *)picker sessionForConnectionType:(GKPeerPickerConnectionType)type
{
    //create ID for session
    NSString *sessionIDString = @"BluetoothSessionID";
    //create GKSession object
    GKSession *session = [[GKSession alloc] initWithSessionID:sessionIDString displayName:nil sessionMode:GKSessionModePeer];
    return session;
}

- (void)peerPickerController:(GKPeerPickerController *)picker didConnectPeer:(NSString *)peerID toSession:(GKSession *)session
{
    //set session delegate and dismiss the picker
    session.delegate = self;
    self.session = session;
    picker.delegate = nil;
    [picker dismiss];
}

- (void)session:(GKSession *)session peer:(NSString *)peerID didChangeState:(GKPeerConnectionState)state
{
    switch (state)
    {
        case GKPeerStateConnected:
            [session setDataReceiveHandler:self withContext:nil];
            _connectedPeerID = peerID;
            break;
            
        case GKPeerStateDisconnected:
            self.session.delegate = nil;
            self.session = nil;
            _connectedPeerID = nil;
            
        default:
            break;
    }
}

-(void)sendData:(NSData*)data
{
    NSError *error = nil;
    BOOL dataSent = NO;
    if (self.session)
    {
        NSArray *peerArray = [NSArray arrayWithObject:_connectedPeerID];
        dataSent = [self.session sendData:data toPeers:peerArray withDataMode:GKSendDataReliable error:&error];
    }
    if (dataSent)
    {
        if ([self.delegate respondsToSelector:@selector(dataSentWithSuccess)])
        {
            [self.delegate performSelector:@selector(dataSentWithSuccess)];
        }
    }
    else
    {
        if ([self.delegate respondsToSelector:@selector(dataSendFailedWithError:)])
        {
            [self.delegate performSelector:@selector(dataSendFailedWithError:) withObject:error];
        }
    }

}

#pragma mark GKSession Data Receive Handler method

- (void)receiveData:(NSData *)data fromPeer:(NSString *)peer inSession:(GKSession *)session context:(void *)context
{
    if (data!=nil && self.delegate!=nil)
    {
        if ([self.delegate respondsToSelector:@selector(handleReceivedDate:)])
        {
            [self.delegate performSelector:@selector(handleReceivedDate:) withObject:data];
        }
    }
}


@end
