-------------------------------------
-- class UI_ScenarioPlayer_Character
-------------------------------------
UI_ScenarioPlayer_Character = class({
        m_posName = 'string',

        m_charKey = '',
        m_charAnimator = 'Animator',

        m_bCharFlip = '',

        m_charNode = '',
        m_charNameNode = '',
        m_charNameLabel = '',
        m_charTalkSprite = '',
        m_charTalkLabel = '',

        m_shakeNode = '',

        m_posX = '',
        m_posY = '',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_ScenarioPlayer_Character:init(pos_name, char_node, name_node, name_label, talk_sprite, talk_label)
    self.m_posName = pos_name

    self.m_charNode = char_node
    self.m_charNameNode = name_node
    self.m_charNameLabel = name_label
    self.m_charTalkSprite = talk_sprite
    self.m_charTalkLabel = talk_label

    self.m_shakeNode = cc.Node:create()
    self.m_charNode:addChild(self.m_shakeNode)

    self.m_bCharFlip = false
end

-------------------------------------
-- function hide
-------------------------------------
function UI_ScenarioPlayer_Character:hide(duration)
    if (not duration) then
        self.m_charNode:setVisible(false)
        self.m_charNameNode:setVisible(false)
        self.m_charNameLabel:setVisible(false)
        self.m_charTalkSprite:setVisible(false)
        self.m_charTalkLabel:setVisible(false)
    end

    if (self.m_charAnimator) then
        self.m_charAnimator:release()
        self.m_charAnimator = nil
        self.m_charKey = nil
    end
end

-------------------------------------
-- function show
-------------------------------------
function UI_ScenarioPlayer_Character:show(duration)
    if (not duration) then
        self.m_charNode:setVisible(true)
        self.m_charNameNode:setVisible(true)
        self.m_charNameLabel:setVisible(true)
        self.m_charTalkSprite:setVisible(true)
        self.m_charTalkLabel:setVisible(true)
    end
end

-------------------------------------
-- function getCharacterResType
-------------------------------------
function UI_ScenarioPlayer_Character:getCharacterResType(key)
    
end

-------------------------------------
-- function setCharacter
-------------------------------------
function UI_ScenarioPlayer_Character:setCharacter(key)
    if (self.m_charKey == key) then
        return
    end

    self.m_charKey = key

    if (self.m_charAnimator) then
        self.m_charAnimator:release()
    end


    local res = TableScenarioResource:getScenarioRes(key)
    local type = TableScenarioResource:getScenarioResType(key)

     self.m_posX = 0
     self.m_posY = 0

    if type and (type == 'monster') then
        self.m_charAnimator = MakeAnimator(res)
        self.m_posY = 200
        self.m_charAnimator:setPositionY(200)
    else
        self.m_charAnimator = MakeAnimator(res) 
    end

    self.m_charAnimator:setAlpha(0)
    self.m_charAnimator:runAction(cc.FadeIn:create(0.3))
    self.m_shakeNode:addChild(self.m_charAnimator.m_node)
    self.m_charAnimator:setFlip(self.m_bCharFlip)

    self:show()
end

-------------------------------------
-- function setCharText
-------------------------------------
function UI_ScenarioPlayer_Character:setCharText(text)
    self.m_charTalkSprite:setVisible(true)
    self.m_charTalkSprite:stopAllActions()
    cca.uiReaction(self.m_charTalkSprite)
    self.m_charTalkLabel:setVisible(true)
    self.m_charTalkLabel:setString(text)
end

-------------------------------------
-- function hideCharText
-------------------------------------
function UI_ScenarioPlayer_Character:hideCharText()
    self.m_charTalkSprite:setVisible(false)
    self.m_charTalkLabel:setVisible(false)
end

-------------------------------------
-- function setCharName
-------------------------------------
function UI_ScenarioPlayer_Character:setCharName(name)
    self.m_charNameLabel:setString(name)
end


-------------------------------------
-- function applyCharEffect
-------------------------------------
function UI_ScenarioPlayer_Character:applyCharEffect(effect)

    if (effect == 'shaking') then
        if (self.m_shakeNode) then
            self:doShake(self.m_shakeNode)
        end

    elseif (effect == 'disappear_down') then
        if (self.m_charAnimator) then
            
            local animator = self.m_charAnimator 
            local function release()
                animator:release()
            end

            local level = 30
            local move_action = cc.Sequence:create(cc.MoveBy:create( 0.1, cc.p(-level, 0) ), cc.MoveBy:create( 0.1, cc.p(level, 0) ))
            local repeat_action = cc.Repeat:create(move_action, 4)

            local spawn = cc.Spawn:create(cc.MoveBy:create(3, cc.p(0, -720)), cc.FadeOut:create(0.6))

            local action = cc.Sequence:create(repeat_action, spawn, cc.CallFunc:create(release))
            animator:runAction(action)

            self.m_charAnimator = nil
            self.m_charKey = nil
        end

    elseif (effect == 'silhouette') then
        self.m_charAnimator:setColor(cc.c3b(0, 0, 0))

    elseif (effect == 'clear') then
        self:hide()

    elseif (effect == 'clear_char') or (effect == 'clearchar') then
        if (self.m_charAnimator) then
            self.m_charAnimator:release()
            self.m_charAnimator = nil
            self.m_charKey = nil
        end

    elseif (effect == 'clear_text') or (effect == 'cleartext') then
        self:hideCharText()
    end
end

-------------------------------------
-- function doShake
-------------------------------------
function UI_ScenarioPlayer_Character:doShake(target)
	-- 1. 변수 설정
    local duration = duration or 0.5
	local is_repeat = is_repeat or false
    local interval =  interval or 0.2
    local x, y = 30, 30

	-- 2. 기존에 있던 액션 중지
    target:stopAllActions()

	-- 3. 새로운 액션 설정 
    local start_action = cc.MoveTo:create(0, cc.p(x, y))
    local end_action = cc.EaseElasticOut:create(cc.MoveTo:create(duration, cc.p(0, 0)), interval)
	local sequence_action = cc.Sequence:create(start_action, end_action)

    target:runAction(sequence_action)
end