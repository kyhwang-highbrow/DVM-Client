local PARENT = UI_ScenarioPlayer

-------------------------------------
-- class UI_DialoguePlayer
-------------------------------------
UI_DialoguePlayer = class(PARENT,{
        m_nextCallBack = '',
        m_nextEffectName = '',
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
function UI_DialoguePlayer:set_nextFunc(cb, effect_name)
    self.m_nextCallBack = cb
    self.m_nextEffectName = effect_name
end

-------------------------------------
-- function next
-------------------------------------
function UI_DialoguePlayer:next(next_effect)
    self.m_currPage = self.m_currPage + 1

    local function excute_next_func()
        if (self.m_nextCallBack) then
            self.m_nextCallBack()
            self.m_nextCallBack = nil
        end
    end

    if (self.m_currPage <= self.m_maxPage) then
        local effect = self.m_nextEffectName
        self:showPage()

        -- 페이지에 해당 이펙트 있을 경우에만 next_func 실행
        if (effect) then
            if (self:isExistEffect(self.m_currPage, effect)) then
                excute_next_func()
                self.m_nextEffectName = nil
            end
        else
            excute_next_func()
        end
    else
        self:close()
    end
end