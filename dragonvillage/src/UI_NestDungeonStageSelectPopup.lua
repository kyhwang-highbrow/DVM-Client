local PARENT = UI

-------------------------------------
-- class UI_NestDungeonStageSelectPopup
-------------------------------------
UI_NestDungeonStageSelectPopup = class(PARENT, ITopUserInfo_EventListener:getCloneTable(), {
})

-------------------------------------
-- function init
-------------------------------------
function UI_NestDungeonStageSelectPopup:init()
    local vars = self:load('stage_select_popup.ui')
    UIManager:open(self, UIManager.POPUP)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:click_exitBtn() end, 'UI_NestDungeonStageSelectPopup')

    -- @UI_ACTION
    --self:addAction(vars['rootNode'], UI_ACTION_TYPE_LEFT, 0, 0.2)
    self:doActionReset()
    self:doAction(nil, false)

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initParentVariable
-- @brief 자식 클래스에서 반드시 구현할 것
-------------------------------------
function UI_NestDungeonStageSelectPopup:initParentVariable()
    -- ITopUserInfo_EventListener의 맴버 변수들 설정
    self.m_uiName = 'UI_NestDungeonStageSelectPopup'
    self.m_bVisible = false
end

-------------------------------------
-- function close
-------------------------------------
function UI_NestDungeonStageSelectPopup:close()
    if not self.enable then return end

    local function finish_cb()
        UI.close(self)
    end

    -- @ui_actions
    self:doActionReverse(finish_cb, 0.5, false)
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_NestDungeonStageSelectPopup:initUI()
    local vars = self.vars

    

    do -- 스테이지 버튼 생성
        local interval_x = 200
        local interval_y = 200
        local button_count = 10
        local count_x = 5
        local count_y = math_floor(button_count/count_x)
        if (button_count%count_x ~= 0) then
            count_y = count_y + 1
        end

        local l_pos_x = getSortPosList(interval_x, count_x)
        local l_pos_y = getSortPosList(-interval_y, count_y)

        for i=1, button_count do
            local button = UI()
            button:load('stage_select_btn.ui')
            button.vars['stageLabel']:setString(tostring(i))
            
            if (i==1) then
                button.vars['stageBtn']:registerScriptTapHandler(function() self:click_dragonDungeonBtn() end)
            else
                button.vars['stageBtn']:registerScriptTapHandler(function() end)
                button.vars['lockSprite']:setVisible(true)
            end

            -- 버튼의 x위치를 계산
            local idx_x = math_floor(i%count_x)
            if (i~=0) and (idx_x==0) then
                idx_x = 5
            end
            local x = l_pos_x[idx_x]

            -- 버튼의 y위치를 계산
            local idx_y = math_floor(i/count_x)
            if (i~=0) and (i%count_x ~= 0) then
                idx_y = idx_y + 1
            end
            local y = l_pos_y[idx_y]

            button.root:setPosition(x, y)
            vars['btnNode']:addChild(button.root)
        end
    end
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_NestDungeonStageSelectPopup:initButton()
    local vars = self.vars
    vars['closeBtn']:registerScriptTapHandler(function() self:click_exitBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_NestDungeonStageSelectPopup:refresh()
end

-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_NestDungeonStageSelectPopup:click_exitBtn()
    self:close()
end

-------------------------------------
-- function click_dragonDungeonBtn
-------------------------------------
function UI_NestDungeonStageSelectPopup:click_dragonDungeonBtn()
    local stage_id = 21010
    local function cb_start_button()
        local stage_name = 'stage_' .. stage_id
        local scene = SceneGame(stage_id, stage_name, false)
        scene:runScene()
    end

    UI_ReadySceneNew(cb_start_button, stage_id)
end

--@CHECK
UI:checkCompileError(UI_NestDungeonStageSelectPopup)
