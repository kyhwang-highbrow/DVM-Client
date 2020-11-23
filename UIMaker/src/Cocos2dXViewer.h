#pragma once

#include <thread>
#include <future>
#include <queue>
#include <condition_variable>
#include <mutex>
#include <string>

struct ViewerInfo
{
    int xpos;
    int ypos;
    int width;
    int height;
    float scale;
    int sibling;
};

class THREAD
{
public:
    THREAD();
    ~THREAD();

    void open(ViewerInfo* info);
    void close();
    void toggleDisplayStats();
    void setForeground(int arg);

    static void run(ViewerInfo* T);

    inline int getID() const { return m_id; }

private:
    static int ms_genID;
    int m_id;
    std::thread m_thread;
};

class CCocos2dXViewer
{
public:
    CCocos2dXViewer();
    ~CCocos2dXViewer();

    void open(int width = -1, int height = -1, float scale = 1.0f, int sibling = 0);
    void close();
    void toggleDisplayStats();
    void setForeground(int arg);

    static bool isCrashed() { return ms_crashed; }

    inline int getWidth() const { return m_info.width; }
    inline int getHeight() const { return m_info.height; }
    inline float getScale() const { return m_info.scale; }

private:
    static bool ms_crashed;
    THREAD m_thread;
    bool m_open;
    ViewerInfo m_info;

    friend class THREAD;
};
