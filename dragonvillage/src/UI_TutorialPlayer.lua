local PARENT = UI_ScenarioPlayer

-------------------------------------
-- class UI_TutorialPlayer
-- @brief 사실상 TutorialPlayer
-------------------------------------
UI_TutorialPlayer = class(PARENT,{ 
        m_nextCallBack = '',
        m_nextEffectName = '',
        m_targetUI = 'UI',
        m_pointingHand = 'Animator',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_TutorialPlayer:init(scenario_name, tar_ui)
    self:setTargetUI(tar_ui)
end

-------------------------------------
-- function init_player
-------------------------------------
function UI_TutorialPlayer:init_player()
    local vars = self:load_keepZOrder('scenario_talk.ui', false)

	--UIManager:open(self)
	vars['skipBtn']:setVisible(false)
	self.m_bSkipEnable = false
end

-------------------------------------
-- function close
-------------------------------------
function UI_TutorialPlayer:close()
    -- pointingHand는 retain걸려있는 상태이므로 release해줌
    if (self.m_pointingHand) then
        self.m_pointingHand.m_node:removeFromParent()
        self.m_pointingHand.m_node:release()
        self.m_pointingHand = nil
    end
    -- 콜백 실행
    if (self.m_closeCB) then
        self.m_closeCB()
    end
    -- 튜토리얼 해제
    TutorialManager.getInstance():releaseTutorial()
end

-------------------------------------
-- function setTargetUI
-------------------------------------
function UI_TutorialPlayer:setTargetUI(tar_ui)
    self.m_targetUI = tar_ui
end

-------------------------------------
-- function set_nextFunc
-------------------------------------
function UI_TutorialPlayer:set_nextFunc(cb, effect_name)
    self.m_nextCallBack = cb
    self.m_nextEffectName = effect_name
end

-------------------------------------
-- function next
-------------------------------------
function UI_TutorialPlayer:next(next_effect)
    self.m_currPage = self.m_currPage + 1

    local function excute_next_func()
        if (self.m_nextCallBack) then
            self.m_nextCallBack()
            self.m_nextCallBack = nil
        end
    end

    if (self.m_currPage <= self.m_maxPage) then
        -- traget UI 갱신
        if (self.m_targetUI) then
            TutorialManager.getInstance():refreshTargetUI()
        end

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

-------------------------------------
-- function applyEffect
-- @comment https://docs.google.com/spreadsheets/d/1_obKDht0MJRJV2GtO3RCEwxY-8NE4Eb4LR2svlix8BU/edit#gid=0 기능일람과 동기화 해주세요!
-- @brief 튜토리얼 전용 기능들 포함
-------------------------------------
function UI_TutorialPlayer:applyEffect(effect)
    -- UI_ScenarioPlayer_util 에 있다면 굳이 또 통과하지 않는다.
    if (not PARENT.applyEffect(self, effect)) then
        return
    end

    -- target ui 가 없다면 패스
    if (not self.m_targetUI) then
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

    elseif (effect == 'black_layer') then
        self:blackLayerOnOff(val_1)

    else
        cclog('정말 없는 effect : ' .. effect)
    end
end

-------------------------------------
-- function setStencil
-- @brief 지정된 노드를 스텐실로 만든다.
-------------------------------------
function UI_TutorialPlayer:setStencil(node_name)
    local tutorial_mgr = TutorialManager.getInstance()

    if (node_name == 'release') then
        tutorial_mgr:releaseTutorialStencil()
        return
    end

    local tar_node = self.m_targetUI.vars[node_name]
    if (tar_node) then
        tutorial_mgr:setTutorialStencil(tar_node)
    end
end

-------------------------------------
-- function pointingNode
-- @brief 지정된 노드에 터치 손가락 a2d 붙인다.
-------------------------------------
function UI_TutorialPlayer:pointingNode(node_name)
    if (node_name == 'release') then
        if (self.m_pointingHand) then
            self.m_pointingHand:setVisible(false)
        end
        return
    end

    local tar_node = self.m_targetUI.vars[node_name]
    if (tar_node) then
        if (not self.m_pointingHand) then
            self.m_pointingHand = TutorialManager.getInstance():makePointingHand()
        end
        self.m_pointingHand.m_node:removeFromParent()
        self.m_pointingHand:setVisible(true)
        tar_node:addChild(self.m_pointingHand.m_node, 99)
    end
end

-------------------------------------
-- function activeNode
-- @brief 지정된 노드를 활성화 한다.
-------------------------------------
function UI_TutorialPlayer:activeNode(node_name)
    local tutorial_mgr = TutorialManager.getInstance()
    
    if (node_name == 'release') then
        tutorial_mgr:revertNodeAll()
        return
    end

    local tar_node = self.m_targetUI.vars[node_name]

    if (tar_node) then
        tutorial_mgr:attachToTutorialNode(tar_node)
    end

    -- 버튼이라면 스크립트를 추가한다.
    if (isInstanceOf(tar_node, UIC_Button)) then
        tar_node:addScriptTapHandler(function()
            if (tutorial_mgr:isDoing()) then
                -- 다음페이지
                self:next()
            end
        end)
    end
end

-------------------------------------
-- function blackLayerOnOff
-- @brief 튜토리얼 노드 전체를 on/off
-- @comment 함수명은 사용도에 따른 건데 혹시 필요하다면 정말 마스킹 레이어만 on/off하도록 수정
-------------------------------------
function UI_TutorialPlayer:blackLayerOnOff(cmd)
    local b = (cmd == 'on')
    TutorialManager.getInstance():setVisibleTutorial(b)
end