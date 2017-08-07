local PARENT = UI_ScenarioPlayer

-------------------------------------
-- class UI_DialoguePlayer
-------------------------------------
UI_DialoguePlayer = class(PARENT,{
        m_nextCallBack = '',
        m_nextEffectName = '',
        m_targetUI = '',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_DialoguePlayer:init(scenario_name, tar_ui)
    self.m_targetUI = tar_ui
end

-------------------------------------
-- function init_player
-------------------------------------
function UI_DialoguePlayer:init_player()
    local vars = self:load_keepZOrder('scenario_talk_new.ui', false)

	UIManager:open(self, UIManager.TUTORIAL_DIALOGUE)
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
        -- 튜토리얼도 같이 종료
        UIManager:releaseTutorial()
    end
end

-------------------------------------
-- function applyEffect
-- @comment https://docs.google.com/spreadsheets/d/1_obKDht0MJRJV2GtO3RCEwxY-8NE4Eb4LR2svlix8BU/edit#gid=0 기능일람과 동기화 해주세요!
-- @brief 튜토리얼 전용 기능들 포함
-------------------------------------
function UI_DialoguePlayer:applyEffect(effect)
    -- UI_ScenarioPlayer_util 에 있다면 굳이 또 통과하지 않는다.
    if (not PARENT.applyEffect(self, effect)) then
        return
    end

    local l_str = TableClass:seperate(effect, ';')
    local effect = l_str[1]
    local val_1 = l_str[2]
    local val_2 = l_str[3]

    local vars = self.vars

    if (effect == 'stencil') then
        self:setStencil(val_1)

    elseif (effect == 'pointing') then
        self:pointingNode(val_1)

    elseif (effect == 'activate') then
        self:activeNode(val_1)

    elseif (effect == 'tutorial') then
        self:tutorialOnOff(val_1)

    else
        cclog('정말 없는 effect : ' .. effect)
    end
end

-------------------------------------
-- function setStencil
-------------------------------------
function UI_DialoguePlayer:setStencil(node_name)
    if (node_name == 'release') then
        UIManager:releaseTutorialStencil()
        return
    end

    local tar_node = self.m_targetUI.vars[node_name]
    if (tar_node) then
        UIManager:setTutorialStencil(tar_node)
    end
end

-------------------------------------
-- function pointingNode
-------------------------------------
function UI_DialoguePlayer:pointingNode(node_name)
    if (node_name == 'release') then

        return
    end

    local tar_node = self.m_targetUI.vars[node_name]
    if (tar_node) then

    end
end

-------------------------------------
-- function activeNode
-------------------------------------
function UI_DialoguePlayer:activeNode(node_name)
    if (node_name == 'release') then
        UIManager:revertNodeAll()
        return
    end

    local tar_node = self.m_targetUI.vars[node_name]
    if (tar_node) then
        UIManager:attachToTutorialNode(tar_node)
        tar_node:addScriptTapHandler(function()
            if (self) then
                self:next()
            end
        end)
    end
end

-------------------------------------
-- function activeNode
-------------------------------------
function UI_DialoguePlayer:tutorialOnOff(cmd)
    local b = (cmd == 'on')
    UIManager:setVisibleTutorial(b)
end