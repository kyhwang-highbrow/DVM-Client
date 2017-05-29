-------------------------------------
-- class UI_ScenarioPlayer_Character
-------------------------------------
UI_ScenarioPlayer_Character = class({
        m_posName = 'string',

        m_charKey = '',
        m_charAnimator = 'Animator',

        m_bCharFlip = '',

        m_charNode = '',

        m_shakeNode = '',
        m_focusNode = '',

        m_posX = '',
        m_posY = '',

        m_bSilhouette = 'boolean',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_ScenarioPlayer_Character:init(pos_name, char_node, name_node, name_label, talk_sprite, talk_label)
    self.m_posName = pos_name

    self.m_charNode = char_node

    self.m_shakeNode = cc.Node:create()
    self.m_charNode:addChild(self.m_shakeNode)

    self.m_focusNode = cc.Node:create()
    self.m_shakeNode:addChild(self.m_focusNode)

    self.m_bCharFlip = false
end

-------------------------------------
-- function setMonoTextNode
-------------------------------------
function UI_ScenarioPlayer_Character:setMonoTextNode(node, label)
end

-------------------------------------
-- function hide
-------------------------------------
function UI_ScenarioPlayer_Character:hide(duration)
    if (not duration) then
        self.m_charNode:setVisible(false)
    end

    if (self.m_charAnimator) then
        self.m_charAnimator:release()    
    end
    self:resetCharacterAnimator()
end

-------------------------------------
-- function show
-------------------------------------
function UI_ScenarioPlayer_Character:show(duration)
    if (not duration) then
        self.m_charNode:setVisible(true)
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
	local res_type = TableScenarioResource:getScenarioResType(key)

    self.m_posX = 0
    self.m_posY = 0

    self.m_charAnimator = MakeAnimator(res)

    if (res_type == 'monster') then
        self.m_charAnimator:setPositionY(200)
	elseif (res_type == 'dragon') then
        self.m_charAnimator:setPositionY(250)
		self.m_charAnimator:setScale(1.5)
    end

    self.m_charAnimator:setAlpha(0)
    self.m_charAnimator:runAction(cc.FadeIn:create(0.3))
    self.m_focusNode:addChild(self.m_charAnimator.m_node)
    self.m_charAnimator:setFlip(self.m_bCharFlip)

    self:show()
end

-------------------------------------
-- function resetCharacterAnimator
-------------------------------------
function UI_ScenarioPlayer_Character:resetCharacterAnimator()
    self.m_charAnimator = nil
    self.m_charKey = nil
    self.m_bSilhouette = false
end

-------------------------------------
-- function applyCharEffect
-------------------------------------
function UI_ScenarioPlayer_Character:applyCharEffect(effect)
    if (effect == 'clear_text') or (effect == 'cleartext') then
        cclog('# warning!! : 더 이상 지원하지 않는 char_effect : ' .. effect)
    end

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

            self:resetCharacterAnimator()
        end

    elseif (effect == 'disappear_side') then
        if (self.m_charAnimator) then
            
            local animator = self.m_charAnimator 
            local function release()
                animator:release()
            end

            local pos = self.m_posName
            local interval = 100

            if (pos == 'left') then
                interval = -interval

            elseif (pos == 'right') then
                interval = interval
            end

            local move_action = cc.Sequence:create(
                cc.MoveBy:create( 0.2, cc.p(interval, 0)), cc.DelayTime:create( 0.5),
                cc.MoveBy:create( 0.2, cc.p(interval, 0)), cc.DelayTime:create( 0.5),
                cc.Spawn:create(cc.MoveBy:create(0.2, cc.p(interval, 0)), cc.FadeOut:create(0.2)))

            local action = cc.Sequence:create(move_action, cc.CallFunc:create(release))
            animator:runAction(action)

            self:resetCharacterAnimator()
        end
        

    elseif (effect == 'silhouette') then
        self:setSilhouette(true)

    elseif (effect == 'clear') then
        self:hide()

    elseif (effect == 'clear_char') or (effect == 'clearchar') then
        if (self.m_charAnimator) then
            self.m_charAnimator:release()
            self:resetCharacterAnimator()
        end
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

-------------------------------------
-- function setCharAni
-------------------------------------
function UI_ScenarioPlayer_Character:setCharAni(ani)
    self.m_charAnimator:changeAni(ani, true)
end


-------------------------------------
-- function setFocus
-------------------------------------
function UI_ScenarioPlayer_Character:setFocus()
    self.m_focusNode:stopAllActions()
    local action = cc.ScaleTo:create(0.2, 1)
    local ease_action = cc.EaseOut:create(action, 0.2)
    self.m_focusNode:runAction(ease_action)

    if self.m_charAnimator and (not self.m_bSilhouette) then
        self.m_charAnimator:runAction(cc.TintTo:create(0.2, 255, 255, 255))
    end
end

-------------------------------------
-- function killFocus
-------------------------------------
function UI_ScenarioPlayer_Character:killFocus()
    self.m_focusNode:stopAllActions()
    local action = cc.ScaleTo:create(0.2, 0.95)
    local ease_action = cc.EaseOut:create(action, 0.2)
    self.m_focusNode:runAction(ease_action)

    if self.m_charAnimator and (not self.m_bSilhouette) then
        self.m_charAnimator:runAction(cc.TintTo:create(0.2, 127, 127, 127))
    end
end

-------------------------------------
-- function setSilhouette
-------------------------------------
function UI_ScenarioPlayer_Character:setSilhouette(silhouette)
    if (self.m_bSilhouette == silhouette) then
        return
    end

    self.m_bSilhouette = silhouette

    if self.m_charAnimator then
        if silhouette then
            self.m_charAnimator:setColor(cc.c3b(0, 0, 0))
        else
            self.m_charAnimator:setColor(cc.c3b(255, 255, 255))
        end
    end
end
