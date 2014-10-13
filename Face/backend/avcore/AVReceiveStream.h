#include <Foundation/Foundation.h>
#import "AVTransport.h"

@interface AVReceiveStream : NSObject {
    
}
@property (weak, nonatomic) UIView *render;
@property (weak, nonatomic) id<VoiceTransport> voiceTransport;
@property (weak, nonatomic) id<VideoTransport> videoTransport;
@property(assign, nonatomic)int voiceChannel;
@property(assign, nonatomic)int videoChannel;
@property (assign) uint64_t uid;

@property (assign, nonatomic) BOOL isHeadphone;
@property (assign, nonatomic) BOOL isLoudspeaker;


-(void)start;
-(void)stop;
@end

