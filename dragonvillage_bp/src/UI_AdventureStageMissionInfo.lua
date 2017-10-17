local PARENT = UI

-------------------------------------
-- class UI_AdventureStageMissionInfo
-------------------------------------
UI_AdventureStageMissionInfo = class(PARENT,{
        m_stageID = 'number',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_AdventureStageMissionInfo:init(stage_id)
    self.m_stageID = stage_id

    local vars = self:load('adventure_stage_star_info.ui')
    UIManager:open(self, UIManager.POPUP)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_AdventureStageMissionInfo')

    -- @UI_ACTION
    --self:addAction(vars['rootNode'], UI_ACTION_TYPE_LEFT, 0, 0.2)
    --self:doActionReset()
    --self:doAction(nil, false)

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_AdventureStageMissionInfo:initUI()
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_AdventureStageMissionInfo:initButton()
    local vars = self.vars
    vars['closeBtn']:registerScriptTapHandler(function() self:close() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_AdventureStageMissionInfo:refresh()
    local vars = self.vars
    local stage_id = self.m_stageID

    local stage_info = g_adventureData:getStageInfo(stage_id)
    local num_of_stars = stage_info:getNumberOfStars()

    -- 획득한 별 표시
    for i=1, 3 do
        local visible = stage_info['mission_' .. i]
        vars['starSprite' .. i]:setVisible(visible)
    end

    local desc_list = stage_info:getMissionDescList()
    for i=1, 3 do
        vars['infoLabel' .. i]:setString(desc_list[i])
    end
end

--@CHECK
UI:checkCompileError(UI_AdventureStageMissionInfo)
