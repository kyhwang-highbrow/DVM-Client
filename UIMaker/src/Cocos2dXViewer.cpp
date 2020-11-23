#include "Cocos2dXViewer.h"
#include "AppDelegate.h"
#include "glfw3native.h"
#include "CSLock.h"

USING_NS_CC;

#if defined(NDEBUG)
#define STEAL_EXCEPTION
#endif

int THREAD::ms_genID = 0;
bool CCocos2dXViewer::ms_crashed = false;

THREAD::THREAD()
{
    m_id = ms_genID++;
}

THREAD::~THREAD()
{
}

void THREAD::open(ViewerInfo* info)
{
    m_thread = std::thread(run, info);
}

void THREAD::close()
{
    auto director = Director::getInstance();
    if (director->getRunningScene())
    {
        director->end();
    }

    m_thread.join();
}

void THREAD::toggleDisplayStats()
{
    CSLock cs;

    bool displayStats = Director::getInstance()->isDisplayStats();
    Director::getInstance()->setDisplayStats(!displayStats);
}

void THREAD::setForeground(int arg)
{
    GLFWwindow* window;
    HWND hWnd, hWndInsertAfter;
    {
        CSLock cs;
        window = Director::getInstance()->getOpenGLView()->getWindow();
        hWnd = glfwGetWin32Window(window);
        hWndInsertAfter = (HWND)arg;
    }
    SetWindowPos(hWnd, hWndInsertAfter, 0, 0, 0, 0, SWP_NOMOVE | SWP_NOSIZE | SWP_NOACTIVATE);
}

static int runCosos2dx(int xpos, int ypos, int width, int hegiht, float scale, int sibling)
{
    // create the application instance
    AppDelegate app(xpos, ypos, width, hegiht, scale, sibling);
    return Application::getInstance()->run();
}

void killSharedApplicationVariable();

//#define USE_WIN32_CONSOLE
LONG WINAPI UnhandledException(LPEXCEPTION_POINTERS exceptionInfo)
{
    MessageBox("An exception occured which wasn't handled!", "Error!");
    return EXCEPTION_EXECUTE_HANDLER;
}

void THREAD::run(ViewerInfo* T)
{
#ifdef USE_WIN32_CONSOLE
    AllocConsole();
    freopen("CONIN$", "r", stdin);
    freopen("CONOUT$", "w", stdout);
    freopen("CONOUT$", "w", stderr);
#endif

#if defined(STEAL_EXCEPTION)
    SetUnhandledExceptionFilter(UnhandledException);
    __try
    {
#endif
        int ret = runCosos2dx(T->xpos, T->ypos, T->width, T->height, T->scale, T->sibling);
#if defined(STEAL_EXCEPTION)
    }
    __except (EXCEPTION_EXECUTE_HANDLER)
    {
        // 일단 다시 창을 띄울 수 있도록 내부의 전역 변수를 초기화하기 위해 아래 코드 실행
        CCocos2dXViewer::ms_crashed = true;
    }
#endif

#ifdef USE_WIN32_CONSOLE
    FreeConsole();
#endif
}


CCocos2dXViewer::CCocos2dXViewer()
{
    m_open = false;

	m_info.width = 640;
	m_info.height = 1138;
    m_info.scale = 1.0f;
    m_info.xpos = 0;
    m_info.ypos = 0;
}

CCocos2dXViewer::~CCocos2dXViewer()
{
}

void CCocos2dXViewer::open(int width, int height, float scale, int sibling)
{
    if (m_open)
    {
        GLFWwindow* window = Director::getInstance()->getOpenGLView()->getWindow();
        if (window) glfwGetWindowPos(window, &m_info.xpos, &m_info.ypos);
        
        close();
    }

    if (width > 0) m_info.width = width;
    if (height > 0) m_info.height = height;
    if (scale > 0.0f) m_info.scale = scale;

    m_info.sibling = sibling;

    m_open = true;
    m_thread.open(&m_info);
}

void CCocos2dXViewer::close()
{
    if (!m_open) return;

    m_thread.close();
    m_open = false;
}

void CCocos2dXViewer::toggleDisplayStats()
{
    m_thread.toggleDisplayStats();
}

void CCocos2dXViewer::setForeground(int arg)
{
    m_thread.setForeground(arg);
}


RenderTexture* createStrokeForSprite(Sprite* sprite, float size, Color3B color)
{
	float sprite_width = sprite->getContentSize().width;
	float sprite_height = sprite->getContentSize().height;
	float sprite_anchor_x = sprite->getAnchorPoint().x;
	float sprite_anchor_y = sprite->getAnchorPoint().y;

	RenderTexture* rt = RenderTexture::create(sprite_width + size * 2, sprite->getContentSize().height + size * 2, Texture2D::PixelFormat::RGBA8888);
	Vec2 originalPos = sprite->getPosition();
	Color3B originalColor = sprite->getColor();
	bool originalVisibility = sprite->isVisible();

	sprite->setColor(color);
	sprite->setVisible(true);

	BlendFunc originalBlend = sprite->getBlendFunc();
	BlendFunc blend;
	blend.src = GL_SRC_ALPHA;
	blend.dst = GL_ONE;
	sprite->setBlendFunc(blend);
	Vec2 bottomLeft = Vec2(sprite_width * sprite_anchor_x + size, sprite_height * sprite_anchor_y + size);
	Vec2 positionOffset = Vec2(sprite_width * sprite_anchor_x - sprite_width / 2, sprite_height * sprite_anchor_y - sprite_height / 2);
	Vec2 position = Vec2(originalPos - positionOffset);

	rt->begin();
	for (int i = 0; i<360; i += 30)
	{
		sprite->setPosition(Vec2(bottomLeft.x + sin(CC_DEGREES_TO_RADIANS(i))*size, bottomLeft.y + cos(CC_DEGREES_TO_RADIANS(i))*size));
		sprite->visit();
	}
	rt->end();

	sprite->setPosition(originalPos);
	sprite->setColor(originalColor);
	sprite->setBlendFunc(originalBlend);
	sprite->setVisible(originalVisibility);
	rt->setPosition(position);

	return rt;
}

