/********* FaceSpoofing.m Cordova Plugin Implementation *******/

#import <Cordova/CDV.h>

@interface FaceSpoofing : CDVPlugin {
  // Member variables go here.
}

- (void)detect:(CDVInvokedUrlCommand*)command;
@end

@implementation FaceSpoofing

- (void)detect:(CDVInvokedUrlCommand*)command
{
    CDVPluginResult* pluginResult = nil;
    NSString* echo = [command.arguments objectAtIndex:0];

    if (echo != nil && [echo length] > 0) {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:echo];
    } else {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
    }

    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

@end
