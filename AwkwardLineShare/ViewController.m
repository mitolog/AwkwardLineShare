//
//  ViewController.m
//  AwkwardLineShare
//
//  Created by YuheiMiyazato on 3/27/15.
//  Copyright (c) 2015 mitolab. All rights reserved.
//

#import "ViewController.h"
#import "PerlinLineView.h"
#import <SIOSocket/SIOSocket.h>
#import "AwkwardLineView.h"
#import "SIOSocket+AddSocketId.h"

@interface ViewController ()
@property (nonatomic) SIOSocket *socket;
@property (nonatomic) NSMutableDictionary *otherPointViewDic;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view, typically from a nib.
    
    self.otherPointViewDic = [@{}mutableCopy];
    
    self.ownerView.mode = AwkwardLineViewModeOwner;
    [self.ownerView pickRandomLineColor];
    
    [self.ownerView addObserver:self
                     forKeyPath:kObserverKeyPath
                        options:NSKeyValueObservingOptionNew
                        context:(__bridge void *)(kObserverContext)];
    
    [NSTimer scheduledTimerWithTimeInterval:0.1
                                     target:self
                                   selector:@selector(removeFirstPoint)
                                   userInfo:nil
                                    repeats:YES];
    
    // Start Web Socket Connection
    [self connectWs];
}

- (AwkwardLineView *)ownerView
{
    return (AwkwardLineView *)self.view;
}

- (void) removeFirstPoint
{
    [self.ownerView removeFirstPoint];
    [self.otherPointViewDic.allValues enumerateObjectsUsingBlock:^(AwkwardLineView* otherView, NSUInteger idx, BOOL *stop){
        [otherView removeFirstPoint];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    NSString *contextMessgae = (__bridge NSString *)context;
    if (!keyPath ||
        ![keyPath isEqualToString:kObserverKeyPath] ||
        ![contextMessgae isEqualToString:kObserverContext] ||
        ![(AwkwardLineView *)object points]
        ) return;
    
    if(self.socket && self.socket.socketId){
        NSArray *points = [(AwkwardLineView *)object points];
        [self.socket emit:@"draw" args:@[points, self.socket.socketId]];
    }
}

- (void)connectWs
{
    // Close existing connection if needed
    if(self.socket){ [self.socket close];}
    
    [SIOSocket socketWithHost: kWebSocketHostName response: ^(SIOSocket *socket){
        
        self.socket = socket;
        
        __weak typeof(self) weakSelf = self;
        self.socket.onConnect = ^()
        {
            [weakSelf.socket emit:@"init"];
        };

        [self.socket on: @"join" callback: ^(SIOParameterArray *args)
         {
             // Store own socket id for the first call
             NSString *socketId = args[0];
             if(socketId &&
                [socket isKindOfClass:[SIOSocket class]] &&
                socketId.length &&
                !weakSelf.socket.socketId)
             {
                 weakSelf.socket.socketId = socketId;
             }
             
         }];

        [self.socket on: @"update" callback: ^(SIOParameterArray *args)
        {
            // Update draw line data
            [self updateDrawLineWithAry:args[0]];
        }];
        
        [self.socket on: @"disappear" callback: ^(SIOParameterArray *args)
        {
             // Remove line from lines
             dispatch_async(dispatch_get_main_queue(), ^{
             });
        }];
    }];
}


- (void)updateDrawLineWithAry:(NSArray*)ary
{
    // ary must be like @[ @[CGPoint's ary], socketid]
    if(!ary ||
       ![ary isKindOfClass:[NSArray class]] ||
       ary.count < 2
       ){
        NSLog(@"%s", __PRETTY_FUNCTION__);
        return;
    }
    
    NSString *socketId = ary[1];
    if(!socketId){return;}
    
    // If own socket, do nothing
    if([self.socket.socketId isEqualToString:socketId]){
        return;
    }
    
    AwkwardLineView *aView = self.otherPointViewDic[socketId];
    if(aView && [aView isKindOfClass:[AwkwardLineView class]]){
        // Replace other member's view
        aView.points = ary[0];
    }else{
        aView = [[AwkwardLineView alloc]initWithFrame:self.view.bounds];
        aView.mode = AwkwardLineViewModeMember;
        aView.points = ary[0];
        [aView pickRandomLineColor];
        [self.view addSubview:aView];
        
        // Holds other member's view
        self.otherPointViewDic[socketId] = aView;
    }
}


@end
