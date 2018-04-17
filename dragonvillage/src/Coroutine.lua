-------------------------------------
-- function Coroutine
-------------------------------------
function Coroutine(func, name)
    -- update와 생명주기를 담당할 노드 생성
    local node = cc.Node:create()

    -- error 메세지를 핸들링하기 위해 func2 생성
    local function func2(dt)
        if (CppFunctions:isIos()) then
            func()
        else
            local status, msg = xpcall(func, __G__TRACKBACK__)
            if (not status) then
                cclog('## Coroutine ERROR!!!')
                if name then
                    cclog('===================================================')
                    cclog('## Coroutine 에러 : ' .. name)
                    cclog('===================================================')
                end
                error(msg)
            end
        end
    end

    -- coroutine인스턴스 생성
    local co = coroutine.create(func2)

    -- update함수
    local function update(dt)
        local s, r = coroutine.resume(co, dt)

        -- 코루틴 종료
        if (s == false) then
            -- node 삭제
            node:runAction(cc.RemoveSelf:create())

            if name then
                cclog('===================================================')
                cclog('## Coroutine 종료 : ' .. name)
                cclog('===================================================')
            end
        end
    end

    -- 스케쥴러 등록
    node:scheduleUpdateWithPriorityLua(update, 0)

    -- 현재 scene에 add
    g_currScene.m_scene:addChild(node)

    -- 첫 코루틴 호출
    update(0)

    if name then
        cclog('\n\n')
        cclog('===================================================')
        cclog('## Coroutine 시작 : ' .. name)
        cclog('===================================================')
    end

    return node
end

CoroutineHelper = class({
        m_bWorking = 'boolean',
        m_bEscape = 'boolean',
        m_blockPopup = 'UI_BlockPopup',

        NEXT = 'function',
        ESCAPE = 'function',

        m_closeCB = 'function',
    })

function CoroutineHelper:init()
    self.NEXT = function()
        self.m_bWorking = false
    end

    self.ESCAPE = function()
        self.m_bWorking = false
        self.m_bEscape = true
    end
end

function CoroutineHelper:work(msg)
    self.m_bWorking = true

    if (msg) then
        cclog(msg)
    end
end

function CoroutineHelper:waitWork()
    while (self.m_bWorking) do
        coroutine.yield()
    end

    return self:escape()
end

function CoroutineHelper:yield()
    coroutine.yield()
end

function CoroutineHelper:waitTime(time)
    local timer = 0
    while (timer < time) do
        local dt = coroutine.yield()
        timer = (timer + dt)
    end
end

function CoroutineHelper:escape()
    if self.m_bEscape then
        self:close()
    end
    return self.m_bEscape
end

function CoroutineHelper:setBlockPopup()
    if self.m_blockPopup then
        return
    end

    self.m_blockPopup = UI_BlockPopup()
    coroutine.yield()
end

function CoroutineHelper:setCloseCB(close_cb)
    self.m_closeCB = close_cb
end

function CoroutineHelper:close()
    if self.m_blockPopup then
        self.m_blockPopup:close()
        self.m_blockPopup = nil
    end

    if self.m_closeCB then
        self.m_closeCB()
    end
end