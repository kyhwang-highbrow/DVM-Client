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

    self:sceneFadeInAction()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_HallOfFame:initUI()
    local vars = self.vars
    for idx = 1, 5 do
        if (self.m_tRank[idx]) then
            if (vars['itemNode' .. idx]) then
                local ui = UI_HallOfFameListItem(self.m_tRank[idx])
		        vars['itemNode' .. idx]:addChild(ui.root)
            end
        else
            -- 랭킹 정보가 없다면 없다는 표시를 출력
            local ui = UI_HallOfFameListItem(nil)
        end
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

