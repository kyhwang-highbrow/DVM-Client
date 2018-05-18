/****************************************************************************
 Copyright (c) 2010 cocos2d-x.org

 http://www.cocos2d-x.org

 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 ****************************************************************************/

#import "SimulatorApp.h"
#import "WorkSpaceDialogController.h"
#import "NSAppSheetAdditions.h"

#include <sys/stat.h>
#include <stdio.h>
#include <fcntl.h>
#include <string>
#include <vector>

#include "AppDelegate.h"
#include "glfw3.h"
#include "glfw3native.h"
#include "Runtime.h"
#include "ConfigParser.h"

#include "cocos2d.h"

using namespace cocos2d;

bool g_landscape = false;
cocos2d::Size g_screenSize;
GLView* g_eglView = nullptr;

static AppController* g_nsAppDelegate=nullptr;

using namespace std;
using namespace cocos2d;

@implementation AppController

@synthesize menu;

std::string getCurAppPath(void)
{
    return [[[NSBundle mainBundle] bundlePath] UTF8String];
}

-(void) dealloc
{
    Director::getInstance()->end();
    [super dealloc];
}

#pragma mark -
#pragma delegates

- (void) applicationDidFinishLaunching:(NSNotification *)aNotification
{
#if (CC_TARGET_PLATFORM == CC_PLATFORM_MAC)
    CCLOG("%s\n",Configuration::getInstance()->getInfo().c_str());

    if (!ConfigParser::getInstance()->isInit())
    {
        FileUtils::getInstance()->addSearchPath("..");
        ConfigParser::getInstance()->readConfig();
    }

    // create console window **MUST** before create opengl view
    [self openConsoleWindow];

    // create simulator
    [self createSimulator];

#endif
    [self startup];
}

#pragma mark -
#pragma mark functions

- (void) startup
{
    NSArray *args = [[NSProcessInfo processInfo] arguments];

    if (args!=nullptr && [args count]>=2) {
        extern std::string g_resourcePath;
        g_resourcePath = [[args objectAtIndex:1]UTF8String];
        if (g_resourcePath.at(0) != '/') {
            g_resourcePath="";
        }
    }

    g_nsAppDelegate =self;
    AppDelegate app;
    Application::getInstance()->run();
    // After run, application needs to be terminated immediately.
    [NSApp terminate: self];
}

- (void) createSimulator
{
    if (g_eglView)
    {
        return;
    }
    
    std::string title = APP_NAME;
    NSString *appName = [NSString stringWithUTF8String:title.c_str()];
    cocos2d::Size viewSize = ConfigParser::getInstance()->getInitViewSize();
    cocos2d::Rect rect = cocos2d::Rect(0.0f,0.0f,viewSize.width,viewSize.height);
    float frameZoomFactor = 1.0f;

    g_landscape = ConfigParser::getInstance()->isLandscape();
    g_screenSize = viewSize;

    // create opengl view
    g_eglView = GLView::createWithRect([appName cStringUsingEncoding:NSUTF8StringEncoding], rect, frameZoomFactor);

    auto director = Director::getInstance();
    director->setOpenGLView(g_eglView);

    _window = glfwGetCocoaWindow(g_eglView->getWindow());
    [[NSApplication sharedApplication] setDelegate: self];
    [_window center];

    [self createViewMenu];
    [self updateMenu];

//    [_window becomeFirstResponder];
//    [_window makeKeyAndOrderFront:self];
}

- (void) openConsoleWindow
{
    if (!_consoleController)
    {
        _consoleController = [[ConsoleWindowController alloc] initWithWindowNibName:@"ConsoleWindow"];
    }
    [_consoleController.window orderFrontRegardless];

    //set console pipe
    _pipe = [NSPipe pipe] ;
    _pipeReadHandle = [_pipe fileHandleForReading] ;

    int outfd = [[_pipe fileHandleForWriting] fileDescriptor];
    if (dup2(outfd, fileno(stderr)) != fileno(stderr) || dup2(outfd, fileno(stdout)) != fileno(stdout))
    {
        perror("Unable to redirect output");
        //        [self showAlert:@"Unable to redirect output to console!" withTitle:@"player error"];
    }
    else
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNotification:) name:NSFileHandleReadCompletionNotification object:_pipeReadHandle] ;
        [_pipeReadHandle readInBackgroundAndNotify] ;
    }
}

- (void)handleNotification:(NSNotification *)note
{
    //NSLog(@"Received notification: %@", note);
    [_pipeReadHandle readInBackgroundAndNotify] ;
    NSData *data = [[note userInfo] objectForKey:NSFileHandleNotificationDataItem];
    NSString *str = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];

    if (str)
    {
        //show log to console
        [_consoleController trace:str];
        if(_fileHandle!=nil)
        {
            [_fileHandle writeData:[str dataUsingEncoding:NSUTF8StringEncoding]];
        }
    }
}

- (void) createViewMenu
{
    
    NSMenu *submenu = [[[_window menu] itemWithTitle:@"View"] submenu];

    for (int i = ConfigParser::getInstance()->getScreenSizeCount() - 1; i >= 0; --i)
    {
        SimulatorScreenSize size = ConfigParser::getInstance()->getScreenSize(i);
        NSMenuItem *item = [[[NSMenuItem alloc] initWithTitle:[NSString stringWithCString:size.title.c_str() encoding:NSUTF8StringEncoding]
                                                       action:@selector(onViewChangeFrameSize:)
                                                keyEquivalent:@""] autorelease];
        [item setTag:i];
        [submenu insertItem:item atIndex:0];
    }
}


- (void) updateMenu
{

    NSMenu *menuScreen = [[[_window menu] itemWithTitle:@"View"] submenu];
    NSMenuItem *itemPortait = [menuScreen itemWithTitle:@"Portait"];
    NSMenuItem *itemLandscape = [menuScreen itemWithTitle:@"Landscape"];
    if (g_landscape)
    {
        [itemPortait setState:NSOffState];
        [itemLandscape setState:NSOnState];
    }
    else
    {
        [itemPortait setState:NSOnState];
        [itemLandscape setState:NSOffState];
    }

    int scale = g_eglView->getFrameZoomFactor()*100;

    NSMenuItem *itemZoom100 = [menuScreen itemWithTitle:@"Actual (100%)"];
    NSMenuItem *itemZoom75 = [menuScreen itemWithTitle:@"Zoom Out (75%)"];
    NSMenuItem *itemZoom50 = [menuScreen itemWithTitle:@"Zoom Out (50%)"];
    NSMenuItem *itemZoom25 = [menuScreen itemWithTitle:@"Zoom Out (25%)"];
    [itemZoom100 setState:NSOffState];
    [itemZoom75 setState:NSOffState];
    [itemZoom50 setState:NSOffState];
    [itemZoom25 setState:NSOffState];
    if (scale == 100)
    {
        [itemZoom100 setState:NSOnState];
    }
    else if (scale == 75)
    {
        [itemZoom75 setState:NSOnState];
    }
    else if (scale == 50)
    {
        [itemZoom50 setState:NSOnState];
    }
    else if (scale == 25)
    {
        [itemZoom25 setState:NSOnState];
    }

    int width = g_screenSize.width;
    int height = g_screenSize.height;
    if (height > width)
    {
        int w = width;
        width = height;
        height = w;
    }
    
    int count = ConfigParser::getInstance()->getScreenSizeCount();
    for (int i = 0; i < count; ++i)
    {
        bool bSel = false;
        SimulatorScreenSize size = ConfigParser::getInstance()->getScreenSize(i);
        if (size.width == width && size.height == height)
        {
            bSel = true;
        }
        NSMenuItem *itemView = [menuScreen itemWithTitle:[NSString stringWithUTF8String:size.title.c_str()]];
        [itemView setState:(bSel? NSOnState : NSOffState)];
    }
    

    //[window setTitle:[NSString stringWithFormat:@"quick-x-player (%0.0f%%)", projectConfig.getFrameScale() * 100]];
}


- (void) updateView
{
    auto policy = g_eglView->getResolutionPolicy();
    auto designSize = g_eglView->getDesignResolutionSize();
    
    if (g_landscape)
    {
        g_eglView->setFrameSize(g_screenSize.width, g_screenSize.height);
    }
    else
    {
        g_eglView->setFrameSize(g_screenSize.height, g_screenSize.width);
    }
    
    g_eglView->setDesignResolutionSize(designSize.width, designSize.height, policy);
    
    [self updateMenu];
}

- (BOOL) applicationShouldTerminateAfterLastWindowClosed:(NSApplication*)theApplication
{
    return YES;
}

- (BOOL) applicationShouldHandleReopen:(NSApplication *)sender hasVisibleWindows:(BOOL)flag
{
    return NO;
}

- (void) windowWillClose:(NSNotification *)notification
{
    [[NSRunningApplication currentApplication] terminate];
}

- (IBAction) onChangeProject:(id)sender
{
    WorkSpaceDialogController *controller = [[WorkSpaceDialogController alloc] initWithWindowNibName:@"WorkSpaceDialog"];
    [NSApp beginSheet:controller.window modalForWindow:_window didEndBlock:^(NSInteger returnCode) {
        if (returnCode == NSModalResponseStop)
        {
            CCLOG("return code : NSModalResponseStop");
        }
        [controller release];
    }];
}


- (IBAction) onFileClose:(id)sender
{
    [[NSApplication sharedApplication] terminate:self];
}


- (IBAction) onScreenPortait:(id)sender
{
    g_landscape = false;
    [self updateView];

}

- (IBAction) onScreenLandscape:(id)sender
{
    g_landscape = true;
    [self updateView];
}

- (void) launch:(NSArray*)args
{
    NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]];
    NSMutableDictionary *configuration = [NSMutableDictionary dictionaryWithObject:args forKey:NSWorkspaceLaunchConfigurationArguments];
    NSError *error = [[[NSError alloc] init] autorelease];
    [[NSWorkspace sharedWorkspace] launchApplicationAtURL:url
                                                  options:NSWorkspaceLaunchNewInstance
                                            configuration:configuration error:&error];
}

- (void) relaunch:(NSArray*)args
{
    [self launch:args];
    [[NSApplication sharedApplication] terminate:self];
}

- (IBAction) onRelaunch:(id)sender
{
    NSArray* args=[[NSArray alloc] initWithObjects:@" ", nil];
    [self relaunch:args];
}


- (IBAction) onViewChangeFrameSize:(id)sender
{
    NSInteger index = [sender tag];
    if (index >= 0 && index < ConfigParser::getInstance()->getScreenSizeCount())
    {
        SimulatorScreenSize size = ConfigParser::getInstance()->getScreenSize(index);
        g_screenSize.width = size.width;
        g_screenSize.height = size.height;
        [self updateView];
    }
}


- (IBAction) onScreenZoomOut:(id)sender
{
    if ([sender state] == NSOnState) return;
    float scale = (float)[sender tag] / 100.0f;
    g_eglView->setFrameZoomFactor(scale);
    [self updateView];
}

+ (NSString *)getJSONStringFromNSDictionary:(NSDictionary *)obj {
    if (obj != nil) {
        NSError *error;
        NSData *data = [NSJSONSerialization dataWithJSONObject:obj
                                                       options:0
                                                         error:&error];
        if (data != nil) {
            NSString *result = [[NSString alloc] initWithData:data
                                                     encoding:NSUTF8StringEncoding];
            if (result != nil) {
                return result;
            }
        }
    }
    return @"";
}

@end
