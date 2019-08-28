local PARENT = UI

-------------------------------------
-- class UI_HallOfFame
-------------------------------------
UI_HallOfFame = class(PARENT,{
        m_tRank = 'table', -- 상위 5위 정보
    })

-------------------------------------
-- function init
-------------------------------------
function UI_HallOfFame:init(t_rank)
    local vars = self:load('hall_of_fame_scene.ui')
    UIManager:open(self, UIManager.SCENE)
    self.m_tRank = t_rank

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_HallOfFame')

    -- @UI_ACTION
    self:doActionReset()
    self:doAction(nil, false)

    self:initUI(t_rank)
	self:initButton()
    --self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_HallOfFame:initUI()
    local vars = self.vars
    for idx, data in ipairs(self.m_tRank) do
        local ui = UI_HallOfFameListItem(data)
		vars['itemNode' .. idx]:addChild(ui.root)
    end
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_HallOfFame:initButton()
    local vars = self.vars
    vars['infoBtn']:registerScriptTapHandler(function() self:click_infoBtn() end)
	vars['rankingBtn']:registerScriptTapHandler(function() self:click_rankBtn() end)
	vars['closeBtn']:registerScriptTapHandler(function() self:close() end)
end

-------------------------------------
-- function click_infoBtn
-------------------------------------
function UI_HallOfFame:click_infoBtn()
    UI_HallOfFameHelp()
end

-------------------------------------
-- function click_rankBtn
-------------------------------------
function UI_HallOfFame:click_rankBtn()
    UI_HallOfFameRank()
end

