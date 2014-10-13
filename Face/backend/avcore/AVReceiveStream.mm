#import "AVReceiveStream.h"
#import "WebRTC.h"
#include "webrtc/voice_engine/include/voe_base.h"
#include "webrtc/common_types.h"
#include "webrtc/system_wrappers/interface/constructor_magic.h"
#include "webrtc/video_engine/include/vie_base.h"
#include "webrtc/video_engine/include/vie_capture.h"
#include "webrtc/video_engine/include/vie_codec.h"
//#include "webrtc/video_engine/include/vie_encryption.h"
#include "webrtc/video_engine/include/vie_image_process.h"
#include "webrtc/video_engine/include/vie_network.h"
#include "webrtc/video_engine/include/vie_render.h"
#include "webrtc/video_engine/include/vie_rtp_rtcp.h"
#include "webrtc/video_engine/vie_defines.h"
#include "webrtc/video_engine/include/vie_errors.h"
#include "webrtc/video_engine/include/vie_render.h"

#include "webrtc/voice_engine/include/voe_network.h"
#include "webrtc/voice_engine/include/voe_base.h"
#include "webrtc/voice_engine/include/voe_audio_processing.h"
#include "webrtc/voice_engine/include/voe_dtmf.h"
#include "webrtc/voice_engine/include/voe_codec.h"
#include "webrtc/voice_engine/include/voe_errors.h"
#include "webrtc/voice_engine/include/voe_neteq_stats.h"
#include "webrtc/voice_engine/include/voe_file.h"
#include "webrtc/voice_engine/include/voe_rtp_rtcp.h"
#include "webrtc/voice_engine/include/voe_hardware.h"


#include "webrtc/engine_configurations.h"
#include "webrtc/modules/video_render/include/video_render_defines.h"
#include "webrtc/modules/video_render/include/video_render.h"
#include "webrtc/modules/video_capture/include/video_capture_factory.h"
#include "webrtc/system_wrappers/interface/tick_util.h"
//#include "channel_transport.h"
#include "ChannelTransport.h"

#define EXPECT_EQ(a, b) do {if ((a)!=(b)) assert(0);} while(0)
#define EXPECT_TRUE(a) do {BOOL c = (a); assert(c);} while(0)
#define EXPECT_NE(a, b) do {if ((a)==(b)) assert(0);} while(0)

@interface AVReceiveStream()
@property(assign, nonatomic)VideoChannelTransport *channelTransport;
@property(assign, nonatomic)VoiceChannelTransport *voiceChannelTransport;

@end

@implementation AVReceiveStream

- (void)dealloc {
    NSAssert(self.channelTransport == NULL &&
             self.voiceChannelTransport == NULL, @"");
}

- (void)startSend
{
    //WebRTC *rtc = [WebRTC sharedWebRTC];
    //EXPECT_EQ(0, rtc.base->StartSend(self.videoChannel));
    //rtc.voe_base->StartSend(self.voiceChannel);
}

- (void)startReceive
{
    WebRTC *rtc = [WebRTC sharedWebRTC];
    EXPECT_EQ(0, rtc.base->StartReceive(self.videoChannel));
    rtc.voe_base->StartReceive(self.voiceChannel);
   
}

-(void)start
{
    WebRTC *rtc = [WebRTC sharedWebRTC];
    
    self.voiceChannel = rtc.voe_base->CreateChannel();
    
    self.voiceChannelTransport = new VoiceChannelTransport(rtc.voe_network, self.voiceChannel, self.voiceTransport, NO);
    
    int error;
    int audio_playback_device_index = 0;
    error = rtc.voe_hardware->SetPlayoutDevice(audio_playback_device_index);
 
    rtc.voe_apm->SetAgcStatus(true);
    rtc.voe_apm->SetNsStatus(true);
    if (!self.isHeadphone) {
        rtc.voe_apm->SetEcStatus(true);
    }
    int videoChannel;
    EXPECT_EQ(0, rtc.base->CreateChannel(videoChannel));
    self.videoChannel = videoChannel;
    
    rtc.base->ConnectAudioChannel(self.videoChannel, self.voiceChannel);
    
    
    self.channelTransport = new VideoChannelTransport(rtc.network, videoChannel, self.videoTransport, NO);
    
    rtc.rtp_rtcp->SetRTCPStatus(videoChannel,
                                webrtc::kRtcpCompound_RFC4585);
    rtc.rtp_rtcp->SetKeyFrameRequestMethod(videoChannel,
                                           webrtc::kViEKeyFrameRequestPliRtcp);
    
    
    void *window = (__bridge void*)self.render;
    EXPECT_EQ(0, rtc.render->AddRenderer(self.videoChannel,
                                         window, 1, 0.0, 0.0, 1.0, 1.0));
    
    
    [self startReceive];
    //[self startSend];
    
    rtc.voe_base->StartPlayout(self.voiceChannel);
    EXPECT_EQ(0, rtc.render->StartRender(self.videoChannel));
    if (self.isLoudspeaker) {
        error = rtc.voe_hardware->SetLoudspeakerStatus(true);
        EXPECT_EQ(0, error);
    }
}

- (void)stop {
    WebRTC *rtc = [WebRTC sharedWebRTC];
    

    rtc.voe_base->StopReceive(self.voiceChannel);
    rtc.voe_base->StopSend(self.voiceChannel);
    rtc.voe_base->StopPlayout(self.voiceChannel);
    rtc.voe_base->DeleteChannel(self.voiceChannel);
    rtc.base->DisconnectAudioChannel(self.voiceChannel);
    delete self.voiceChannelTransport;
    self.voiceChannelTransport = NULL;
    
  
    rtc.base->StopReceive(self.videoChannel);
    rtc.base->StopSend(self.videoChannel);

    rtc.render->StopRender(self.videoChannel);
    rtc.render->RemoveRenderer(self.videoChannel);
    
    EXPECT_EQ(0, rtc.base->DeleteChannel(self.videoChannel));
    delete self.channelTransport;
    self.channelTransport = NULL;
}
@end
