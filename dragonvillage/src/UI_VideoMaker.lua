---------------------------------------------------------------------------------------------
-- 조작 영역
---------------------------------------------------------------------------------------------
local DRAGON_ID = 120801
local BG_NAME = 'map_forest'
local BG_SCALE = 0.8


local DRAGON_POS_Y = { 0, 0, 0 }
local DRAGON_SCALE = { 1, 0.9, 0.8 }

local WAIT_TIME = { 1, 1, 1 }

local DEFAULT_EVOLUTION = 3

local VFX_TIME_SCALE = 1.3

--[[
* 드래곤
썬더볼트(물) : 121122
뇌신 (땅) : 120801


* 배경 정보
map_canyon
map_canyon2
map_dark_castle
map_dark_castle2
map_forest
map_forest2
map_ocean
map_ocean2
map_sky_temple
map_sky_temple2
map_volcano
map_volcano2


]]

---------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------




local PARENT = UI
local THIS

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
            self:stop()
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

    -- 안내 문구 출력
    self:showInfoLabel(true)

    -- 드래곤 초기화
    self.m_dragonAnimator = UIC_DragonAnimator()
    self.m_dragonAnimator:setTalkEnable(false)
    self.m_dragonAnimator:setChangeAniEnable(false)
    vars['dragonNode']:addChild(self.m_dragonAnimator.m_node)

    -- 배경 노드에 업데이트 붙임
    vars['bgNode']:scheduleUpdateWithPriorityLua(function(dt) self:update(dt) end, 0)
    vars['bgNode']:setScale(BG_SCALE)

    self:reset()
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
-------------------------------------
function UI_VideoMaker:refresh()
end

-------------------------------------
-- function reset
-------------------------------------
function UI_VideoMaker:reset()
    self:setDragon(DEFAULT_EVOLUTION)
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

    -- 드래곤 진화도 별로 y좌표와 스케일 조정
    self.vars['dragonNode']:setPositionY(DRAGON_POS_Y[evolution])
    self.vars['dragonNode']:setScale(DRAGON_SCALE[evolution])
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
-- function showInfoLabel
-------------------------------------
function UI_VideoMaker:showInfoLabel(b)
    self.vars['infoLabel']:setVisible(b)
end

-------------------------------------
-- function getStandardShake
-- @brief 표준 쉐이크를 반환
-------------------------------------
local function getStandardShake(x, y, duration, elastic)
    local start_action = cc.MoveTo:create(0, cc.p(x, y))
    local end_action = cc.EaseElasticOut:create(cc.MoveTo:create(duration, cc.p(0, 0)), elastic)
	local sequence_action = cc.Sequence:create(start_action, end_action)
    return cc.RepeatForever:create(sequence_action)
end





-------------------------------------
-- function play
-------------------------------------
function UI_VideoMaker:play()
    if (self.m_coroutineHelper ~= nil) then
        UIManager:toastNotificationGreen('영상을 정지합니다.')
        self:stop()
        return
    end

    local evolve_visual = self.vars['evolveVisual']
    evolve_visual:setTimeScale(VFX_TIME_SCALE)

    -- 안내 문구 숨김
    self:showInfoLabel(false)

    local function coroutine_function(dt)
        local co = CoroutineHelper()
        self.m_coroutineHelper = co

		-- 코루틴 종료 콜백
		local function close_cb()
            self.m_coroutineHelper = nil
            -- 초기화
			self:reset()
            -- 안내 문구 출력
            self:showInfoLabel(true)
		end
		co:setCloseCB(close_cb)


        -- PHASE 1. 해치 .. pose
        do
            cclog('-------------------------------- PHASE 1. SET')

            local phase = 1
            self:setDragon(phase)
            self.m_dragonAnimator.m_animator:changeAni('pose_1', false)
            cclog('pose time .. ' .. self.m_dragonAnimator.m_animator:getDuration())

            -- 1초 대기
            co:waitTime(WAIT_TIME[phase])
        end

        -- PHASE 2. 해치 -> 해츨링 진화
        do
            cclog('-------------------------------- PHASE 2. EVOLVE 1')
            co:work()
        
            local phase = 2
        
            -- 이펙트 (2.16초)
            evolve_visual:setVisible(true)
            evolve_visual:changeAni('top_appear', false, false)
            cclog(evolve_visual:getDuration())
            evolve_visual:addAniHandler(function()
                evolve_visual:setVisible(false)
--                self:setDragon(phase)
                co.NEXT()
            end)

            -- 꿀렁
            local scale = DRAGON_SCALE[phase]
            local delay = cc.DelayTime:create(1.9/VFX_TIME_SCALE)
            local setDragon = cc.CallFunc:create(function() self:setDragon(phase) end)
            local scaleUp = cc.EaseInOut:create(cc.ScaleTo:create(0.3, scale * 1.2), 2)
            local scaleDown = cc.EaseInOut:create(cc.ScaleTo:create(0.3, scale), 2)
            local action = cc.Sequence:create(delay, setDragon, scaleUp, scaleDown)
            self.vars['dragonNode']:runAction(action)

            if co:waitWork() then return end

            -- 대기
            co:waitTime(WAIT_TIME[phase])
        end

        -- PHASE 3. 해츨링 -> 성룡 진화
        do
            cclog('-------------------------------- PHASE 3. EVOLVE 2')
            co:work()

            local phase = 3

            -- 이펙트 (2.16초)
            evolve_visual:setVisible(true)
            evolve_visual:changeAni('top_appear', false, false)
            evolve_visual:addAniHandler(function()
                evolve_visual:setVisible(false)
--                self:setDragon(phase)
                co.NEXT()
            end)

            -- 꿀렁
            local scale = DRAGON_SCALE[phase]
            local delay = cc.DelayTime:create(1.9/VFX_TIME_SCALE)
            local setDragon = cc.CallFunc:create(function() self:setDragon(phase) end)
            local scaleUp = cc.EaseInOut:create(cc.ScaleTo:create(0.3, scale * 1.2), 2)
            local scaleDown = cc.EaseInOut:create(cc.ScaleTo:create(0.3, scale), 2)
            local action = cc.Sequence:create(delay, setDragon, scaleUp, scaleDown)
            self.vars['dragonNode']:runAction(action)

            if co:waitWork() then return end
        
            -- 대기
            co:waitTime(WAIT_TIME[phase])
        end

        -- PHASE 4. 드래곤 pose (화려한 동작) 연출
        do
            cclog('-------------------------------- PHASE 4. POSE')
            co:work()
        
            -- 드래곤 pose
            self.m_dragonAnimator.m_animator:setTimeScale(0.8)
            self.m_dragonAnimator.m_animator:changeAni('pose_1', false)
            cclog('pose time .. ' .. self.m_dragonAnimator.m_animator:getDuration())
            self.m_dragonAnimator.m_animator:addAniHandler(function()
                self.m_dragonAnimator.m_animator:setTimeScale(1)
                self.m_dragonAnimator.m_animator:changeAni('idle', true)
                co.NEXT()
            end)
        
            -- bg shake run
            self.vars['bgNode']:runAction(getStandardShake(20, 6, 0.1, 0.1)) -- (x, y, duration, elastic)

            if co:waitWork() then return end

            cclog('-------------------------------- WAIT')

            -- bg shake stop
            self.vars['bgNode']:stopAllActions()
        
            -- 마지막 대기 .. 영상 편집의 편의를 위해 길게 잡음
            co:waitTime(5)
        end

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

    self.m_coroutineHelper.ESCAPE()
    self.m_coroutineHelper:close()
    
    self.vars['bgNode']:stopAllActions()
    self.vars['dragonNode']:stopAllActions()
    self.vars['evolveVisual']:setVisible(false)
    self.vars['evolveVisual']:unregisterScriptLoopHandler()
end

--@CHECK
UI:checkCompileError(UI_VideoMaker)
