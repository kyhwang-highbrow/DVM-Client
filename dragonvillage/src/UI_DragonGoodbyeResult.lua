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
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_DragonGoodbyeResult')
    -- 백키 블럭
    UIManager:blockBackKey(true)

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

    -- 결과 팝업
    local function show_popup()
        local dragon_data = self.m_dragonData
        local info_data = self.m_infoData
        local l_item_list = info_data['items_list']
	    if (l_item_list) then
            local did = dragon_data['did']
            local name = TableDragon():getDragonName(did)

		    -- 얻은 인연포인트 텍스트를 만든다.
		    local t_item = l_item_list[1]
		    local goodbye_str_3 = UIHelper:makeGoodbyeStr(t_item, name)

		    -- 획득 팝업 출력
		    local ui = UI_ObtainPopup(l_item_list, goodbye_str_3)
            ui:setCloseCB(function() self:fadeOutClose() end)
	    end

        -- 블럭 해제
        UIManager:blockBackKey(false)
    end

    -- 배경
    do
        local visual = vars['bg_visual']
        local move_action = cc.MoveBy:create(1.5, cc.p(0, -800))
        local ease_action = cc.EaseIn:create(move_action, 2)
        visual:runAction(ease_action)
    end

    -- 작별 연출
    do
        local visual = vars['effect_visual']
        visual:setVisible(true)
        visual:addAniHandler(function() show_popup() end)

        local move_action = cc.MoveBy:create(1.5, cc.p(0, -800))
        local ease_action = cc.EaseIn:create(move_action, 2)
        visual:runAction(ease_action)
    end    
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_DragonGoodbyeResult:initButton()
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_DragonGoodbyeResult:refresh()
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

--@CHECK
UI:checkCompileError(UI_DragonGoodbyeResult)
