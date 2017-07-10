local PARENT = UI_ScenarioPlayer

-------------------------------------
-- class UI_DialoguePlayer
-------------------------------------
UI_DialoguePlayer = class(PARENT,{
        m_nextCallBack = '',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_DialoguePlayer:init(scenario_name)
end

-------------------------------------
-- function init_player
-------------------------------------
function UI_DialoguePlayer:init_player()
    local vars = self:load_keepZOrder('scenario_talk_new.ui', false)

	UIManager:open(self,UIManager.NORMAL)
	vars['skipBtn']:setVisible(false)
	self.m_bSkipEnable = false
end

-------------------------------------
-- function set_nextFunc
-------------------------------------
function UI_DialoguePlayer:set_nextFunc(cb)
    self.m_nextCallBack = cb
end

-------------------------------------
-- function next
-------------------------------------
function UI_DialoguePlayer:next()
    self.m_currPage = self.m_currPage + 1

    if (self.m_currPage <= self.m_maxPage) then
        self:showPage()
        if (self.m_nextCallBack) then
            self.m_nextCallBack()
            self.m_nextCallBack = nil
        end
    else
        self:close()
    end
end