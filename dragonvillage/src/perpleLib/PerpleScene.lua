--g_currScene = nil

-------------------------------------
-- class PerpleScene
-------------------------------------
PerpleScene = class
{
    m_scene = 'cc.Scene',           -- Cocos2d-x의 Scene클래스
    m_lPrepareFunc = 'table',       -- Scene을 준비하는 함수들의 리스트 큐의 형태로 하나씩 수행

    m_bShowPushUI = 'boolean',
    m_bRemoveCache = 'boolean',
    
    m_tBackKeyListener = '',
    m_tTouchEndedListener = '',
    
    m_loadingUI = 'cc.Node',

    m_bBlockBackkey = 'boolean',

    m_tKeyListener = 'table',

    m_timeScale = 'number',
    m_bShowTopUserInfo = 'boolean',
	
	m_sceneName = 'string',

	-- loading guide
    m_bUseLoadingUI = 'boolean',    -- LoadingUI 사용 여부(false일 경우 Prepare가 동작하지 않음)
	m_loadingGuideType = 'string',
    m_loadingUIDuration = 'number', -- LoadingUI가 반드시 보여져야 하는 시간(nil일 경우 무시)
    m_minLoadingTime = 'number', -- nil일 경우 즉시 이동, 숫자가 지정되면 해당 수치까지 대기
}

-------------------------------------
-- function init
-------------------------------------
function PerpleScene:init(param)
    self.m_scene = cc.Scene:create()
    self.m_lPrepareFunc = {}
    self.m_bUseLoadingUI = false
    self.m_loadingUIDuration = nil
    self.m_bShowPushUI = true
    self.m_bRemoveCache = true
    self.m_sceneName = 'PerpleScene'

    self.m_tBackKeyListener = {}
    self.m_tTouchEndedListener = {}
    self.m_loadingUI = nil
    
    self.m_bBlockBackkey = false

    self.m_scene:registerScriptHandler(function(event)
        if event == 'enter' then
            self:onEnter(param)
        elseif event == 'exit' then
            self:onExit()
        end
    end)

    self.m_tKeyListener = {}
    self.m_timeScale = 1
    self.m_bShowTopUserInfo = true
end

-------------------------------------
-- function runScene()
-------------------------------------
function PerpleScene:runScene()
    if cc.Director:getInstance():getRunningScene() then
        if self.m_bUseLoadingUI then
            replaceScene(self)
        else
            
            -- sgkim 2018-03-21
            -- 현재 동작 중인 scene의 모든 node를 pause처리
            -- replaceScene이 진행되는 중간에 node들의 update가 1회 동작되면서 오류를 유발하는 것을 방지
            local function f_pause(node)
                node:pause()
            end
            local _scene = cc.Director:getInstance():getRunningScene()
            doAllChildren(_scene, f_pause)

            -- scene 전환
            cc.Director:getInstance():replaceScene(self.m_scene)
        end
    else
        cc.Director:getInstance():runWithScene(self.m_scene)
        self:prepareDone()
    end
	
	-- @E.T.
	g_errorTracker:set_lastScene(self.m_sceneName)
end

-------------------------------------
-- function prepare
-- @brief addLoading등의 Scene전환 및 로딩을 준비하는 함수
-------------------------------------
function PerpleScene:prepare()
end

-------------------------------------
-- function addLoading
-- @brief prepareRes에서 호출될 prepare_func를 등록
-------------------------------------
function PerpleScene:addLoading(prepare_func)
    table.insert(self.m_lPrepareFunc, prepare_func)
end

-------------------------------------
-- function prepareRes
-- @brief 매 프레임 등록된 prepare_func(준비 함수)를 호출, 종료되면 true를 리턴
-- @return boolean 종료되면 true를 리턴
-------------------------------------
function PerpleScene:prepareRes()
    local prepare_func = self.m_lPrepareFunc[1]
    if prepare_func then
        
        local call_result
        local function func()
            call_result = prepare_func()
        end

        local status, msg = xpcall(func, __G__TRACKBACK__)
        if not status then
            error(msg)
        end

        -- prepare_func()가 리턴값이 없거나 true를 리턴하면 종료 처리
        --local call_result = prepare_func()
        if (call_result==nil) or (call_result==true) then
            table.remove(self.m_lPrepareFunc, 1)
        end

        return false, #self.m_lPrepareFunc
    else
        return true, 0
    end
end

-------------------------------------
-- function prepareAfter
-- @brief Scene전환 시 로딩이 완료된 직후
-------------------------------------
function PerpleScene:prepareAfter()
    return true
end

-------------------------------------
-- function prepareDone
-- @brief Scene전환 시 로딩이 완료된 상태(화면이 밝아지기 전)
-------------------------------------
function PerpleScene:prepareDone()
end


-------------------------------------
-- function appearDone
-- @brief Scene전환 시 로딩이 완료된 상태(화면이 밝아진 후)
-------------------------------------
function PerpleScene:appearDone()
end

-------------------------------------
-- function onKeyReleased
-------------------------------------
function PerpleScene.onKeyReleased(keyCode, event)
    if not g_currScene then 
		return 
	end

    --cclog('keyCode = ' .. keyCode)

    -- KEY_ESCAPE == 6(android 하드웨어 back key에 매핑)
    if (keyCode == KEY_ESCAPE) then
		--cclog('------------------------------------------')
		--for i,v in pairs(g_currScene.m_tBackKeyListener) do
			--cclog(string.format('Back Key Event Listener %d : %s', i, v.name))
		--end
		--cclog('\n\n')

        if g_currScene.m_tBackKeyListener[1] and g_currScene.m_tBackKeyListener[1]['cb'] then
            if not g_currScene.m_bBlockBackkey then
                SoundMgr:playEffect('UI', 'ui_touch')
                g_currScene.m_tBackKeyListener[1]['cb']()
            end
        end
    else
        for i,v in ipairs(g_currScene.m_tKeyListener) do
            v:onKeyReleased(keyCode, event)
        end
    end
end

-------------------------------------
-- function addKeyKeyListener
-------------------------------------
function PerpleScene:addKeyKeyListener(listener)
    table.insert(self.m_tKeyListener, listener)
end

-------------------------------------
-- function pushBackKeyListener
-------------------------------------
function PerpleScene:pushBackKeyListener(obj, cb, name)
    table.insert(self.m_tBackKeyListener, 1, {obj=obj, cb=cb, name=name or 'none'})

    --[[
    cclog('\n\n------------------------------------------')
    for i,v in pairs(self.m_tBackKeyListener) do
        cclog(string.format('Back Key Event Listener %d : %s', i, v.name))
    end
    --]]
end

-------------------------------------
-- function removeBackKeyListener
-------------------------------------
function PerpleScene:removeBackKeyListener(obj)

    for i,v in pairs(self.m_tBackKeyListener) do
        if v['obj'] == obj then
            table.remove(self.m_tBackKeyListener, i)
            break
        end
    end
end

-------------------------------------
-- function pushTouchEndedListener
-------------------------------------
function PerpleScene:pushTouchEndedListener(obj, cb)
    table.insert(self.m_tTouchEndedListener, 1, {obj=obj, cb=cb})
end

-------------------------------------
-- function removeTouchEndedListener
-------------------------------------
function PerpleScene:removeTouchEndedListener(obj)
    for i,v in pairs(self.m_tTouchEndedListener) do
        if v['obj'] == obj then
            table.remove(self.m_tTouchEndedListener, i)
            break
        end
    end
end

-------------------------------------
-- function onEnter
-------------------------------------
function PerpleScene:onEnter()
    
    -- 캐시 메모리 정리
    if self.m_bRemoveCache then
        UILoader.clearCache()
        cc.AzVisual:removeCacheAll()
        cc.AzVRP:removeCacheAll()
        sp.SkeletonAnimation:removeCacheAll()

        if SpineCacheManager then
            SpineCacheManager:getInstance():clean()
        end

        SoundMgr:stopAllEffects()

        cc.Director:getInstance():purgeCachedData()
    end

    collectgarbage('collect')

    g_currScene = self
    
	UIManager:init(self)

    do -- Backkey 입력을 위한 키보드 리스너 등록
        local listener = cc.EventListenerKeyboard:create()
        listener:registerScriptHandler(PerpleScene.onKeyReleased, cc.Handler.EVENT_KEYBOARD_RELEASED)

        local eventDispatcher = self.m_scene:getEventDispatcher()
        eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self.m_scene)
    end


    -- TouchLayer
    --self:makeTouchLayer()

    -- BroadcastMgr
    self:initBroadcast()

    -- Watermark
    --self:makeWatermark()

    -- TimeScale
    cc.Director:getInstance():getScheduler():setTimeScale(1)

    -- SoundMgr
    if SoundMgr then
        SoundMgr:setSlowMode(false)
    end

    -- 플레이 시간 기록
    if (g_accessTimeData) then
        g_accessTimeData:recordTime(self.m_scene)
    end


    if (g_highlightData) then
        g_highlightData:onChangeScene()
    end
end

-------------------------------------
-- function onExit
-------------------------------------
function PerpleScene:onExit()
    UIManager:cleanUp()

    if g_broadcastManager then
        g_broadcastManager:setEnable(false)
        g_broadcastManager:setEnableNotice(false)
    end

    --cclog('PerpleScene:onExit()')
end

-------------------------------------
-- function makeLoadingUI
-- @brief scene전환 중 로딩화면 생성
-------------------------------------
function PerpleScene:makeLoadingUI()
    return UI_LoadingGuide(self)
end

-------------------------------------
-- function makeTouchLayer
-------------------------------------
function PerpleScene:makeTouchLayer()
    -- 터치입력 체크를 위한 레이어 추가
    local touchLayer = cc.Layer:create()
    self.m_scene:addChild(touchLayer, 99999)
    
    local function onTouchBegan(touch, event)
        return true
    end

    local function onTouchMoved(touch, event)
        --cclog('moved!')
    end
    
    -- 터치 종료 시 등록된 콜백함수 호출
    local function onTouchEnded(touch, event)
        --cclog('ended!')
        for i, v in pairs(self.m_tTouchEndedListener) do
            local cbTouchEndedFunc = self.m_tTouchEndedListener[i]['cb']
            if cbTouchEndedFunc then
                cbTouchEndedFunc()
                break
            end
        end
    end

    local listener = cc.EventListenerTouchOneByOne:create()
    listener:setSwallowTouches(false)
    listener:registerScriptHandler(onTouchBegan, cc.Handler.EVENT_TOUCH_BEGAN )
    listener:registerScriptHandler(onTouchMoved, cc.Handler.EVENT_TOUCH_MOVED )
    listener:registerScriptHandler(onTouchEnded, cc.Handler.EVENT_TOUCH_ENDED )
                
    local eventDispatcher = touchLayer:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, touchLayer)
end

-------------------------------------
-- function initBroadcast
-------------------------------------
function PerpleScene:initBroadcast()
    if (not g_broadcastManager) then
        BroadcastMgr:initInstance()
    end

    --g_broadcastManager:setEnable(self.m_bShowPushUI)
    g_broadcastManager:setEnable(true)
    g_broadcastManager:setEnableNotice(true) -- 운영 공지는 항상 활성화
end
--[[
-------------------------------------
-- function makeWatermark
-- @brief 워터마크 표시
-------------------------------------
function PerpleScene:makeWatermark()
    -- 메세지 지정
    local msg = '본 게임은 외부 제작업체 \n\'XXX\'에 제공 된 테스트 버전 입니다.'

    -- 폰트 지정
    local font = Translate:getFontPath()

    -- 위치 지정
    local visibleSize = cc.Director:getInstance():getVisibleSize()
    local pos_x = visibleSize.width * 0.5
    local pos_y = visibleSize.height * 0.15

    -- label 생성
    local label = cc.Label:createWithTTF(msg, font, 30, 0)
    label:setAlignment(cc.TEXT_ALIGNMENT_CENTER, cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
    label:setAnchorPoint(cc.p(0.5, 0.5))
    label:setPosition(pos_x, pos_y)
    label:enableOutline(cc.c4b(0, 0, 0, 255), 3)
    self.m_scene:addChild(label, 99999 + 1)

    -- 1초 후 투명해지도록 액션 실행
    label:runAction(cc.Sequence:create(cc.DelayTime:create(1), cc.FadeTo:create(0.5, 80)))
end
]]
-------------------------------------
-- function blockBackkey
-------------------------------------
function PerpleScene:blockBackkey(flag)
    self.m_bBlockBackkey = flag or false
end

-------------------------------------
-- function replaceScene
-------------------------------------
function replaceScene(target_scene)

    -- Schedule ID
    local schedule_handler_id = nil

    local curr_scene = cc.Director:getInstance():getRunningScene()
    if curr_scene then 
        UIManager:setEnable(false)
        target_scene.m_scene:retain()
    end

    -- replaceScene
    local coroutine_function = coroutine.create(function(dt)
        local co_timer = 0
		local block_ui

        --------------------------------------------------------------------------
        do -- #1 fade out
            if curr_scene then
                -- cur_scene이 있으면 fade out 처리 후 replace scene
                local duraition = 0.3

                local visibleSize = cc.Director:getInstance():getVisibleSize()

                local layer = cc.LayerColor:create()
                layer:setAnchorPoint(cc.p(0, 0))
                layer:setContentSize(visibleSize.width, visibleSize.height)
                curr_scene:addChild(layer, 99999)

                local timer = 0
                while true do
                    if timer >= duraition then break end
                    timer = timer + dt
                    timer = math_min(duraition, timer)
                    local opacity = (timer * 255 / duraition)
                    opacity = math_clamp(opacity, 0, 255)
                    layer:setOpacity(opacity)
                    dt = coroutine.yield()
                end
            end
        end
        --------------------------------------------------------------------------
        
        --------------------------------------------------------------------------
        -- Loading UI 생성
		do
			target_scene.m_loadingUI = target_scene:makeLoadingUI()
            target_scene.m_scene:addChild(target_scene.m_loadingUI.root, 99999)
			target_scene.m_loadingUI:setLoadingGauge(33)
			dt = coroutine.yield()
			co_timer = co_timer + dt
		end
        --------------------------------------------------------------------------

        --------------------------------------------------------------------------
        do -- #2 Scene 변경
            if curr_scene then
                cc.Director:getInstance():replaceScene(target_scene.m_scene)
            else
                cc.Director:getInstance():runWithScene(target_scene.m_scene)
            end
            target_scene.m_scene:release()
			dt = coroutine.yield()
			co_timer = co_timer + dt
        end
        --------------------------------------------------------------------------

        --------------------------------------------------------------------------
        do -- beforePrepare
            local is_break

            repeat
                is_break = target_scene.m_loadingUI:prepare()
                dt = coroutine.yield()
                co_timer = co_timer + dt
            until(is_break)
        end
        --------------------------------------------------------------------------

        --------------------------------------------------------------------------
        do -- prepare
            target_scene:prepare()
			target_scene.m_loadingUI:setLoadingGauge(50)
			
			-- block 처리
			target_scene:blockBackkey(true)
			block_ui = UI_BlockPopup()
			if (g_topUserInfo) then
				g_topUserInfo:setExitEnabled(false)
			end

            dt = coroutine.yield()
            co_timer = co_timer + dt
        end
        --------------------------------------------------------------------------

        --------------------------------------------------------------------------
        do -- prepareRes
			-- 로딩게이지 관련 준비
			local total_cnt = #target_scene.m_lPrepareFunc
			local rest_cnt = 0
			local curr_cnt = 0
			local is_break
			local percent
			local unit_pcnt = math_clamp((100 / (total_cnt + 2)), 1, 23)

			-- prepareRes 시작
            repeat
				is_break, rest_cnt = target_scene:prepareRes()
				curr_cnt = total_cnt - rest_cnt

				if (total_cnt > 0) then
					percent = 75 + (unit_pcnt * curr_cnt)
				else
					percent = 100
				end
				target_scene.m_loadingUI:setLoadingGauge(percent)
                dt = coroutine.yield()
                co_timer = co_timer + dt
            until (is_break)
        end
        --------------------------------------------------------------------------

        --------------------------------------------------------------------------
        -- 로딩 최소 시간 보장
        if target_scene.m_minLoadingTime then
            repeat
                dt = coroutine.yield()
                co_timer = co_timer + dt
            until (target_scene.m_minLoadingTime <= co_timer)
        end
        --------------------------------------------------------------------------

        --------------------------------------------------------------------------
        do -- prepareAfter
            -- 로딩 완료 직후
            local is_break

            repeat
                is_break = target_scene:prepareAfter()
                dt = coroutine.yield()
                co_timer = co_timer + dt
            until (is_break)
        end
        --------------------------------------------------------------------------

        --------------------------------------------------------------------------
        -- 로딩 UI 삭제
        if target_scene.m_loadingUI then
            target_scene.m_loadingUI.root:removeFromParent(true)
            target_scene.m_loadingUI = nil
        end
        --------------------------------------------------------------------------

        --------------------------------------------------------------------------
        do -- prepareDone
            target_scene:prepareDone()
        end
        --------------------------------------------------------------------------
        
        --------------------------------------------------------------------------
        do -- fadein
            local duraition = 0.3

            local visibleSize = cc.Director:getInstance():getVisibleSize()

            local layer = cc.LayerColor:create()--cc.Node:create()
            layer:setAnchorPoint(cc.p(0, 0))
            layer:setContentSize(visibleSize.width, visibleSize.height)
            layer:setColor(cc.c3b(0,0,0))
            target_scene.m_scene:addChild(layer, 99999)

            local timer = 0
            while true do
                
                if timer >= duraition then break end
                timer = timer + dt
                timer = math_min(duraition, timer)

                local opacity = 255 - (timer * 255 / duraition)
                opacity = math_floor(opacity)
                opacity = math_max(opacity, 0)
                opacity = math_min(opacity, 255)

                layer:setOpacity(opacity)
                dt = coroutine.yield()
                co_timer = co_timer + dt
            end
            layer:removeFromParent(true)
            layer = nil
        end
        --------------------------------------------------------------------------

        dt = coroutine.yield()
        co_timer = co_timer + dt

        -- appearDone
        target_scene:appearDone()
					
		-- block 해제
		target_scene:blockBackkey(false)
		block_ui:close()
		if (g_topUserInfo) then
			g_topUserInfo:setExitEnabled(true)
		end
    end)

    -- coroutine Schedule함수, 코루틴이 종료되면 스케쥴도 해지
    local function updateCoroutine(dt)
        local s, r = coroutine.resume(coroutine_function, dt)
        if s == false then
            if (isWin32()) then
                local msg = debug.traceback(coroutine_function, r)
                if (not string.find(msg, 'cannot resume dead coroutine')) then
                    cclog("----------------------------------------")
                    cclog("LUA ERROR in coroutine\n")
                    cclog(msg)
                    cclog("----------------------------------------")
                end
            end

            coroutine_function = nil
            if schedule_handler_id then
                cc.Director:getInstance():getScheduler():unscheduleScriptEntry(schedule_handler_id)
            end
        end
    end

    -- schedule에 등록
    schedule_handler_id = cc.Director:getInstance():getScheduler():scheduleScriptFunc(updateCoroutine, 0, false)
end

-------------------------------------
-- function sceneDidChangeViewSize
-------------------------------------
function PerpleScene:sceneDidChangeViewSize()

end

-------------------------------------
-- function setTimeScale
-------------------------------------
function PerpleScene:setTimeScale(time_scale)
    self.m_timeScale = time_scale
    cc.Director:getInstance():getScheduler():setTimeScale(self.m_timeScale)
end