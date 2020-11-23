#include "AppDelegate.h"
#include "CCLuaEngine.h"
#include "SimpleAudioEngine.h"
#include "cocos2d.h"
#include "glfw3native.h"

#include "MakerScene.h"
#include "CSLock.h"

using namespace CocosDenshion;

USING_NS_CC;
using namespace std;

HWND g_SiblingWindow = NULL;

void moveConsoleWindow(GLFWwindow* window)
{
    int xpos, ypos;
    glfwGetWindowPos(window, &xpos, &ypos);

    int width, height;
    glfwGetWindowSize(window, &width, &height);

    RECT rcconsole;
    HWND hConsoleWindow = GetConsoleWindow();
    GetWindowRect(hConsoleWindow, &rcconsole);

    MoveWindow(hConsoleWindow, xpos + width, ypos, rcconsole.right - rcconsole.left, rcconsole.bottom - rcconsole.top, TRUE);
}

void windowPosCallback(GLFWwindow* window, int x, int y)
{
    moveConsoleWindow(window);
}

void windowSizeCallback(GLFWwindow* window, int width, int height)
{
    moveConsoleWindow(window);
}

void windowFocusCallback(GLFWwindow* window, int focused)
{
    if (focused == GL_TRUE && g_SiblingWindow != NULL)
    {
        HWND hWnd = glfwGetWin32Window(window);
        SetWindowPos(g_SiblingWindow, hWnd, 0, 0, 0, 0, SWP_NOMOVE | SWP_NOSIZE | SWP_NOACTIVATE);
    }
}

void windowCloseCallback(GLFWwindow* window)
{
    glfwSetWindowShouldClose(window, GL_FALSE);
}

AppDelegate::AppDelegate(int xpos, int ypos, int width, int height, float scale, int sibling)
{
    _xpos = xpos;
    _ypos = ypos;
    _width = width;
    _height = height;
    _scale = scale;
    _isReopen = true;

    if (sibling != NULL)
    {
        g_SiblingWindow = (HWND)sibling;
        _isReopen = false;
    }
}

AppDelegate::~AppDelegate()
{
    SimpleAudioEngine::end();
}

bool AppDelegate::applicationDidFinishLaunching()
{
    CSLock cs;

    // Initialize director
    auto director = Director::getInstance();
    auto glview = director->getOpenGLView();
    if (!glview)
    {
        char szbuf[256];
        sprintf_s(szbuf, "UI.Maker Viewer - %d x %d (%d%%)", _width, _height, INT(_scale * 100));
               
        glview = GLView::createWithRect(szbuf, Rect(_xpos, _ypos, _width * _scale, _height * _scale));
        director->setOpenGLView(glview);

        if (!_isReopen)
        {
            HWND hWnd = glfwGetWin32Window(glview->getWindow());
            RECT rect1, rect2;
            GetWindowRect((HWND)g_SiblingWindow, &rect1);
            GetWindowRect(hWnd, &rect2);
            int x = rect1.left - (rect2.right - rect2.left);
            int y = rect1.top;
            SetWindowPos(hWnd, NULL, x, y, 0, 0, SWP_NOSIZE | SWP_NOZORDER | SWP_NOACTIVATE);
        }
        else
        {
            director->purgeCachedData();

            glfwSetWindowPos(glview->getWindow(), _xpos, _ypos);
        }
        
        moveConsoleWindow(glview->getWindow());
    }

    glfwSetWindowPosCallback(glview->getWindow(), windowPosCallback);
    glfwSetWindowSizeCallback(glview->getWindow(), windowSizeCallback);
    glfwSetWindowFocusCallback(glview->getWindow(), windowFocusCallback);
    glfwSetWindowCloseCallback(glview->getWindow(), windowCloseCallback);

    glview->setDesignResolutionSize(_width, _height, ResolutionPolicy::NO_BORDER);

    director->setDisplayStats(false);
    director->setAnimationInterval(1.0 / 60);
    director->runWithScene(CMakerScene::create(_scale));

    return true;
}

// This function will be called when the app is inactive. When comes a phone call, it's be invoked too.
void AppDelegate::applicationDidEnterBackground()
{
    CSLock cs;

    Director::getInstance()->stopAnimation();

    SimpleAudioEngine::getInstance()->pauseBackgroundMusic();
}

// This function will be called when the app is active again.
void AppDelegate::applicationWillEnterForeground()
{
    CSLock cs;

    Director::getInstance()->startAnimation();

    SimpleAudioEngine::getInstance()->resumeBackgroundMusic();
}
