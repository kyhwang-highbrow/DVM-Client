-------------------------------------
-- function Coroutine
-------------------------------------
function Coroutine(func, name)
    -- update와 생명주기를 담당할 노드 생성
    local node = cc.Node:create()

    -- error 메세지를 핸들링하기 위해 func2 생성
    local function func2(dt)
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
        cclog('===================================================')
        cclog('## Coroutine 시작 : ' .. name)
        cclog('===================================================')
    end

    return node
end