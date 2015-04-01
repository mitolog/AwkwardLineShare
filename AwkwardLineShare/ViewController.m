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
    
    [(AwkwardLineView*)self.view initializeWithMode:AwkwardLineViewModeOwner
                                             points:nil];
    [(AwkwardLineView *)self.view addObserver:self
                                  forKeyPath:kObserverKeyPath
                                     options:NSKeyValueObservingOptionNew
                                     context:(__bridge void *)(kObserverContext)];
    
    // Start draw update timer
    NSOperationQueue *queue = [[NSOperationQueue alloc]init];
    [queue addOperationWithBlock:^{
        while (1) {
            NSOperationQueue *mainQueue = [NSOperationQueue mainQueue];
            [mainQueue addOperationWithBlock:^{
                
                // Draw owner's view
                [self.view setNeedsDisplay];

                // Draw member's view
                for(UIView *subView in self.view.subviews){
                    [subView setNeedsDisplay];
                }
            }];
            [NSThread sleepForTimeInterval:0.05];
        }
    }];
    
    // Start Web Socket Connection
    [self connectWs];
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
        NSMutableArray *points = [(AwkwardLineView *)object points];
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
        [aView updatePoints:ary[0]];
    }else{
        aView = [[AwkwardLineView alloc]initWithFrame:self.view.bounds];
        aView.backgroundColor = [UIColor clearColor];
        aView.mode = AwkwardLineViewModeMember;
        [aView initializeWithMode:AwkwardLineViewModeMember
                           points:ary[0]];
        [self.view addSubview:aView];
        
        // Holds other member's view
        self.otherPointViewDic[socketId] = aView;
    }
}


@end
