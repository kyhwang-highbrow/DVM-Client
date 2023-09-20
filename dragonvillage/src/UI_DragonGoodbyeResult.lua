local PARENT = UI

-------------------------------------
-- class UI_DragonGoodbyeResult
-------------------------------------
UI_DragonGoodbyeResult = class(PARENT,{
        m_dragonData = '',
        m_infoData = '',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_DragonGoodbyeResult:init(dragon_data, info_data)
    local vars = self:load('dragon_goodbye.ui')
    UIManager:open(self, UIManager.POPUP)
    
    self.m_dragonData = dragon_data
    self.m_infoData = info_data

    self:doActionReset()
    self:doAction(nil, false)

    -- backkey 지정
    --g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_DragonGoodbyeResult')
    g_currScene:pushBackKeyListener(self, function() self:click_skipBtn() end, 'UI_DragonGoodbyeResult')
    -- 백키 블럭
    --UIManager:blockBackKey(true)

    self:sceneFadeInAction()

    self:initUI()
    self:initButton()
    self:refresh()

    SoundMgr:playBGM('ui_dragon_farewell', false)
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_DragonGoodbyeResult:initUI()
    local vars = self.vars

    -- 속도 조절용 (사운드가 1배속에 맞춰져있어 수정하지 못함)
    local time_scale = 1

    -- 배경
    do
        local scr_size = cc.Director:getInstance():getWinSize()
        local height_scale = CRITERIA_RESOLUTION_Y / scr_size['height']

        local visual = vars['bg_visual']
        visual:setIgnoreLowEndMode(true) -- 저사양 모드 무시
        visual:setTimeScale(time_scale)
        local move_action = cc.MoveBy:create(1.5 / time_scale, cc.p(0, -800 * height_scale))
        local ease_action = cc.EaseIn:create(move_action, 2)
        visual:runAction(ease_action)
    end

    -- 작별 연출
    do
        local visual = vars['effect_visual']
        visual:setIgnoreLowEndMode(true) -- 저사양 모드 무시
        visual:setTimeScale(time_scale)
        visual:setVisible(true)
        visual:addAniHandler(function() self:showResult() end)

        local move_action = cc.MoveBy:create(1.5 / time_scale, cc.p(0, -800))
        local ease_action = cc.EaseIn:create(move_action, 2)
        visual:runAction(ease_action)
    end    
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_DragonGoodbyeResult:initButton()
    local vars = self.vars
    vars['skipBtn']:registerScriptTapHandler(function() self:click_skipBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_DragonGoodbyeResult:refresh()
end

-------------------------------------
-- function showResult
-------------------------------------
function UI_DragonGoodbyeResult:showResult(is_skip)
    local vars = self.vars
    vars['skipBtn']:setVisible(false)

    local dragon_data = self.m_dragonData
    local info_data = self.m_infoData
    local l_item_list = info_data['items_list']
	if (l_item_list) then
        --local did = dragon_data['did']
        --local name = TableDragon():getDragonName(did)
		
		---- 얻은 인연포인트 텍스트를 만든다.
		--local t_item = l_item_list[1]
		--local goodbye_str_3 = UIHelper:makeGoodbyeStr(t_item, name)

		---- 획득 팝업 출력
		--local ui = UI_ObtainPopup(l_item_list, goodbye_str_3)

		-- 20-11-10 드래곤 레벨업 개편으로 경험치, 인연포인트, 특성재료 중 나옴
		local ui = UI_ObtainPopup(l_item_list, nil, nil, true)
		ui:setCloseCB(function()
            if is_skip ~= true then
                self:fadeOutClose()
            else
                self:close()
            end
        end)
	end

    -- 블럭 해제
    -- UIManager:blockBackKey(false)
end

-------------------------------------
-- function fadeOutClose
-------------------------------------
function UI_DragonGoodbyeResult:fadeOutClose()
    self:sceneFadeOutAction(function()
        SoundMgr:playPrevBGM()
        self:close()
    end)
end

-------------------------------------
-- function click_skipBtn
-------------------------------------
function UI_DragonGoodbyeResult:click_skipBtn()
    local vars = self.vars
    vars['skipBtn']:setEnabled(false)

    -- 페이드인 효과
    self:sceneFadeInAction(nil, nil, 1.0)

    -- 배경
    do
        local scr_size = cc.Director:getInstance():getWinSize()
        local height_scale = CRITERIA_RESOLUTION_Y / scr_size['height']
        local pos_y = 800 - (800 * height_scale)

        local visual = vars['bg_visual']
        visual:stopAllActions()
        visual.m_node:setPositionY(pos_y)
    end

    -- 작별 연출
    do
        local visual = vars['effect_visual']
        visual:addAniHandler(function() end)
        visual:stopAllActions()
        visual.m_node:setPositionY(-200)

        visual:changeAni('result', false)
    end

    self:showResult(true)
end

function UI_DragonGoodbyeResult:click_exitBtn()
    
end

--@CHECK
UI:checkCompileError(UI_DragonGoodbyeResult)