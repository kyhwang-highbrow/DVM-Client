local PARENT = UI
local THIS




local DRAGON_ID = 121122
local BG_NAME = 'map_ocean'
local BG_SCALE = 0.8


local DRAGON_POS_Y_BY_EVOL = { 0, 0, 0 }













-------------------------------------
-- LOCAL function onKeyReleaseListener
-------------------------------------
local function onKeyReleaseListener(key_code, event)
    -- 세팅 팝업
    if (key_code == KEY_Z) then
        THIS:showSettingPanel()
    -- 재생
    elseif (key_code == KEY_A) then
        THIS:play()
    -- 중지 (초기화 함)
    elseif (key_code == KEY_S) then
        THIS:stop()

    -- 16:9 가이드라인
    elseif (key_code == KEY_Q) then
        THIS.vars['guideline169']:setVisible(not THIS.vars['guideline169']:isVisible())

    -- 1:1 가이드라인
    elseif (key_code == KEY_W) then
        THIS.vars['guideline11']:setVisible(not THIS.vars['guideline11']:isVisible())

    -- 4:5 가이드라인
    elseif (key_code == KEY_E) then
        THIS.vars['guideline45']:setVisible(not THIS.vars['guideline45']:isVisible())

    end
end


-------------------------------------
-- class UI_VideoMaker
-------------------------------------
UI_VideoMaker = class(PARENT,{
        m_dragonAnimator = '',
        m_mapManager = 'map ani',
        m_bgName = 'string',

        m_coroutineHelper = 'CoroutineHelper',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_VideoMaker:init()
    self.m_uiName = 'UI_VideoMaker'
    local vars = self:load('video_maker.ui')
    UIManager:open(self, UIManager.SCENE)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, 
        function() 
            self:close()
            UIManager:removeKeyListener()
        end, 'UI_VideoMaker')

    -- @UI_ACTION
    --self:addAction(vars['rootNode'], UI_ACTION_TYPE_LEFT, 0, 0.2)

    -- ReleaseKeyListener 등록
    UIManager:registerKeyListener(onKeyReleaseListener)


--    self:doActionReset()
--    self:doAction(nil, false)

    self.m_bgName = BG_NAME

    self:initUI()
    self:initButton()
    self:refresh()

    THIS = self
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_VideoMaker:initUI()
    local vars = self.vars

    -- 설정 패널 숨김
    vars['settingPanel']:setVisible(false)

    -- 드래곤 초기화
    self.m_dragonAnimator = UIC_DragonAnimator()
    self.m_dragonAnimator:setTalkEnable(false)
    self.m_dragonAnimator:setChangeAniEnable(false)
    vars['dragonNode']:addChild(self.m_dragonAnimator.m_node)

    -- 배경 노드에 업데이트 붙임
    vars['bgNode']:scheduleUpdateWithPriorityLua(function(dt) self:update(dt) end, 0)
    vars['bgNode']:setScale(BG_SCALE)
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_VideoMaker:initButton()
    local vars = self.vars

    vars['dragonBtn']:registerScriptTapHandler(function() self:click_dragonBtn() end)
    vars['bgBtn']:registerScriptTapHandler(function() self:click_bgBtn() end)
end

-------------------------------------
-- function refresh
-- 초기화 기능으로 사용함
-------------------------------------
function UI_VideoMaker:refresh()
    self:setDragon(3)
    self:changeBG()

    -- 애니메이션 리스트 출력
    ccdump(self.m_dragonAnimator.m_animator:getVisualList())
end

-------------------------------------
-- function update
-------------------------------------
function UI_VideoMaker:update(dt)
	if (self.m_mapManager) then
		self.m_mapManager:update(dt)
	end
end


-------------------------------------
-------------------------------------
-- click listener method
-------------------------------------
-------------------------------------

-------------------------------------
-- function click_dragonBtn
-------------------------------------
function UI_VideoMaker:click_dragonBtn()
end

-------------------------------------
-- function click_bgBtn
-------------------------------------
function UI_VideoMaker:click_bgBtn()
end






-------------------------------------
-- function setDragon
-------------------------------------
function UI_VideoMaker:setDragon(evolution)
	self.m_dragonAnimator:setDragonAnimator(DRAGON_ID, evolution)
    self.m_dragonAnimator.m_animator:changeAni('idle', true)

    self.vars['dragonNode']:setPositionY(DRAGON_POS_Y_BY_EVOL[evolution])
end

-------------------------------------
-- function changeBG
-------------------------------------
function UI_VideoMaker:changeBG()
	if self.m_mapManager then 
		self.m_mapManager = nil
	end
	
	self.m_mapManager = ScrollMap(self.vars['bgNode'])
	self.m_mapManager:setBg(self.m_bgName)
	self.m_mapManager:setSpeed(-100)
end

-------------------------------------
-- function showSettingPanel
-------------------------------------
function UI_VideoMaker:showSettingPanel()
    self.vars['settingPanel']:setVisible(not self.vars['settingPanel']:isVisible())
end

-------------------------------------
-- function getStandardShake
-- @brief 표준 쉐이크를 반환
-------------------------------------
local function getStandardShake(x, y, duration, interval)
	-- 1. 변수 설정
    local timeScale = cc.Director:getInstance():getScheduler():getTimeScale()
    local duration = (duration or g_constant:get('INGAME', 'SHAKE_DURATION')) * timeScale
	local is_repeat = is_repeat or false
    local interval =  interval or 0.2

	-- 2. 액션 설정 
    local start_action = cc.MoveTo:create(0, cc.p(x, y))
    local end_action = cc.EaseElasticOut:create(cc.MoveTo:create(duration, cc.p(0, 0)), interval)
	local sequence_action = cc.Sequence:create(start_action, end_action)

    return cc.RepeatForever:create(sequence_action)
end



-------------------------------------
-- function play
-------------------------------------
function UI_VideoMaker:play()
    local evolve_visual = self.vars['evolveVisual']
    evolve_visual:setTimeScale(1)

    local function coroutine_function(dt)
        local co = CoroutineHelper()
        self.m_coroutineHelper = co

		-- 코루틴 종료 콜백
		local function close_cb()
			self.m_coroutineHelper = nil
			self:refresh()
		end
		co:setCloseCB(close_cb)

        -- 1초 대기
        co:waitTime(1)

        -- 해치 -> 해츨링 진화
        cclog('-------------------------------- EVOLVE 1')
        co:work()
        
        -- 이펙트
        evolve_visual:setVisible(true)
        evolve_visual:changeAni('top_appear', false, false)
        evolve_visual:addAniHandler(function()
            evolve_visual:setVisible(false)
            self:setDragon(2)
            self.vars['dragonNode']:setScale(1)
            co.NEXT()
        end)

        -- 꿀렁
        local delay = cc.DelayTime:create(1.7)
        local scaleUp = cc.EaseInOut:create(cc.ScaleTo:create(0.5, 1.4), 2)
        local scaleDown = cc.EaseInOut:create(cc.ScaleTo:create(0.3, 1), 2)
        local action = cc.Sequence:create(delay, scaleUp, scaleDown)
        self.vars['dragonNode']:runAction(action)

        if co:waitWork() then return end

        -- 대기
        co:waitTime(1)

        -- 해츨링 -> 성룡 진화
        cclog('-------------------------------- EVOLVE 2')
        co:work()

        -- 이펙트
        evolve_visual:setVisible(true)
        evolve_visual:changeAni('top_appear', false, false)
        evolve_visual:addAniHandler(function()
            evolve_visual:setVisible(false)
            self:setDragon(3)
            self.vars['dragonNode']:setScale(1)
            co.NEXT()
        end)

        -- 꿀렁
        local delay = cc.DelayTime:create(1.7)
        local scaleUp = cc.EaseInOut:create(cc.ScaleTo:create(0.5, 1.4), 2)
        local scaleDown = cc.EaseInOut:create(cc.ScaleTo:create(0.3, 1), 2)
        local action = cc.Sequence:create(delay, scaleUp, scaleDown)
        self.vars['dragonNode']:runAction(action)

        if co:waitWork() then return end
        
        -- 0대기
        co:waitTime(1)

        -- 드래곤 pose (화려한 동작) 연출
        cclog('-------------------------------- POSE')
        co:work()
        
        -- 드래곤
        self.m_dragonAnimator.m_animator:setTimeScale(0.8)
        self.m_dragonAnimator.m_animator:changeAni('pose_1', false)
        self.m_dragonAnimator.m_animator:addAniHandler(function()
            self.m_dragonAnimator.m_animator:setTimeScale(1)
            self.m_dragonAnimator.m_animator:changeAni('idle', true)
            co.NEXT()
        end)
        
        -- Shake
        self.vars['bgNode']:runAction(getStandardShake(15, 3, 0.1, 0.1))

        if co:waitWork() then return end

        cclog('-------------------------------- WAIT')

        self.vars['bgNode']:stopAllActions()
        -- 대기
        co:waitTime(5)

        cclog('-------------------------------- FINISH')
        -- 끝
        co:close()
    end

    Coroutine(coroutine_function, 'Play')
end

-------------------------------------
-- function stop
-------------------------------------
function UI_VideoMaker:stop()
    if (self.m_coroutineHelper == nil) then
        return
    end

    self.m_coroutineHelper:close()
end

--@CHECK
UI:checkCompileError(UI_VideoMaker)
