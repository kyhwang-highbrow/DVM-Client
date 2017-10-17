-------------------------------------
-- class UI_ScenarioPlayer_Character
-------------------------------------
UI_ScenarioPlayer_Character = class({
        m_posName = 'string',

        m_charKey = '',
        m_charAnimator = 'Animator',

        m_charAniKey = '',

        -- left 가 false, right가 true
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
    -- 중복 캐릭터 거름
    if (self.m_charKey == key) then
        return
    end

    self.m_charKey = key
    self.m_charAniKey = nil

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
    cclog('#UI_ScenarioPlayer_Character:applyCharEffect(effect) ' .. effect)

    if (effect == 'shaking') then
        self:doShake()

    elseif (effect == 'appear_side') then
        self:appearSide()

    elseif (effect == 'disappear_down') then
        self:disappearDown()

    elseif (effect == 'disappear_side') then
        self:disappearSide()

    elseif (effect == 'disappear_fadaout') then
        self:disappearFadeOut()

    elseif (effect == 'silhouette') then
        self:setSilhouette(true)

    elseif (effect == 'irregular') then
        self:irregular()

    elseif (effect == 'attack') then
        self:attack()

    elseif (effect == 'walk') then
        self:walk()

    elseif (effect == 'flash') then
        self:flash()

    elseif (effect == 'stop') then
        self:stop()

    elseif (effect == 'hide') then
        self:hide()

    elseif (effect == 'clear') then
        self:clear()

    
    -- 시나리오 테이블 작업 끝난 후 지울것
    elseif (effect == 'clear_char') then
        self:clear()
    elseif (effect == 'clearchar') then
        self:clear()

    else
        cclog('정의되지 않은 이펙트 ' .. effect)

    end
end

-------------------------------------
-- function doShake
-------------------------------------
function UI_ScenarioPlayer_Character:doShake()
    local target = self.m_shakeNode
    if (not target) then
        return
    end

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
    -- 중복애니 거름
    if (self.m_charAniKey == ani) then
        return
    end

    self.m_charAnimator:changeAni(ani, true)
    self.m_charAniKey = ani
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

-------------------------------------
-- function appearSide
-------------------------------------
function UI_ScenarioPlayer_Character:appearSide()
    if (self.m_charAnimator) then
        local animator = self.m_charAnimator 

        local pos_x, pos_y = animator:getPosition()

        local x_factor = self.m_bCharFlip and -1 or 1

        -- 먼저 화면 밖으로 보냄
        animator:setPosition(pos_x - (500 * x_factor), pos_y)
        animator:setAlpha(0)

        -- fadein 하면서 등장
        local action = cc.Sequence:create(
            cc.Spawn:create(cc.MoveTo:create(0.5, cc.p(pos_x, pos_y)), cc.FadeIn:create(0.5))
        )

        animator:runAction(action)
    end
end

-------------------------------------
-- function disappearDown
-------------------------------------
function UI_ScenarioPlayer_Character:disappearDown()
    if (self.m_charAnimator) then
        local animator = self.m_charAnimator 
        local function release()
            animator:release()
        end

        local level = 30
        local move_action = cc.Sequence:create(
            cc.MoveBy:create(0.1, cc.p(-level, 0)),
            cc.MoveBy:create(0.1, cc.p(level, 0))
        )
        local repeat_action = cc.Repeat:create(move_action, 4)
        local spawn = cc.Spawn:create(cc.MoveBy:create(3, cc.p(0, -720)), cc.FadeOut:create(0.6))

        local action = cc.Sequence:create(repeat_action, spawn, cc.CallFunc:create(release))
        animator:runAction(action) 
    end
end

-------------------------------------
-- function disappearSide
-------------------------------------
function UI_ScenarioPlayer_Character:disappearSide()
    if (self.m_charAnimator) then
        local animator = self.m_charAnimator 
        local function release()
            animator:release()
        end

        local interval = self.m_bCharFlip and 100 or -100

        local move_action = cc.Sequence:create(
            cc.Spawn:create(cc.MoveBy:create(0.5, cc.p(interval, 0)), cc.FadeOut:create(0.5))
        )

        local action = cc.Sequence:create(move_action, cc.CallFunc:create(release))
        animator:runAction(action)
    end
end

-------------------------------------
-- function disappearFadeOut
-------------------------------------
function UI_ScenarioPlayer_Character:disappearFadeOut()
    if (self.m_charAnimator) then
        local animator = self.m_charAnimator 
        local function release()
            animator:release()
        end

        local fade_action = cc.Sequence:create(
            cc.FadeOut:create(1.0)
        )

        local action = cc.Sequence:create(fade_action, cc.CallFunc:create(release))
        animator:runAction(action)
    end
end


-------------------------------------
-- function walk
-------------------------------------
function UI_ScenarioPlayer_Character:walk()
    if (self.m_charAnimator) then
        local animator = self.m_charAnimator

        local action = cc.Sequence:create(
            cc.JumpBy:create(1, cc.p(0, 0), 10, 4)
        )

        animator:runAction(action)
    end
end


-------------------------------------
-- function attack
-------------------------------------
function UI_ScenarioPlayer_Character:attack()
    if (self.m_charAnimator) then
        local animator = self.m_charAnimator
        local pos_x, pos_y = animator:getPosition()

        local x_factor = self.m_bCharFlip and -1 or 1

        local action = cc.Sequence:create(
            -- 살짝 후퇴 후
            cc.MoveTo:create(0.3, cc.p(pos_x - (50 * x_factor), pos_y - 20)),

            -- 잠시 대기
            cc.DelayTime:create(0.3),
            
            -- 공격!
            cc.EaseInOut:create(cc.MoveTo:create(0.2, cc.p(pos_x + (700 * x_factor), pos_y)), 2),

            -- 되돌아옴
            cc.MoveTo:create(0.2, cc.p(pos_x, pos_y))
        )

        animator:runAction(action)
    end
end

-------------------------------------
-- function flash
-------------------------------------
function UI_ScenarioPlayer_Character:flash()
    if (self.m_charAnimator) then
        local animator = self.m_charAnimator

        local time = 0.1

        local white_action = cc.CallFunc:create(function()
            local shader = ShaderCache:getShader(SHADER_CHARACTER_DAMAGED)
            animator.m_node:setGLProgram(shader)
        end)

        local delay = cc.DelayTime:create(time)

        local restore_action = cc.CallFunc:create(function()
            local shader = ShaderCache:getShader(cc.SHADER_POSITION_TEXTURE_COLOR)
            animator.m_node:setGLProgram(shader)
        end)

        local action = cc.Sequence:create(
            white_action, delay, 
            restore_action, delay,
            white_action, delay,
            restore_action, delay
        )

        animator:runAction(action)
    end
end

-------------------------------------
-- function irregular
-------------------------------------
function UI_ScenarioPlayer_Character:irregular()
    if (self.m_charAnimator) then
        local animator = self.m_charAnimator

        local scale_x = animator:getScaleX()
        local scale_y = animator:getScaleY()
        
        local time = 0.2

        local scale_action = cc.Sequence:create(
            cc.ScaleTo:create(time, 1.1 * scale_x, 1.1 * scale_y),
            cc.ScaleTo:create(time, 1.0 * scale_x, 1.0 * scale_y),
            cc.ScaleTo:create(time, 1.1 * scale_x, 1.1 * scale_y),
            cc.ScaleTo:create(time, 1.0 * scale_x, 1.0 * scale_y),
            cc.DelayTime:create(time)
        )

        local action = cc.RepeatForever:create(scale_action)
        animator:runAction(action)
    end
end

-------------------------------------
-- function stop
-------------------------------------
function UI_ScenarioPlayer_Character:stop()
    if (self.m_charAnimator) then
        self.m_charAnimator:stopAllActions()
    end
end

-------------------------------------
-- function clear
-------------------------------------
function UI_ScenarioPlayer_Character:clear()
    if (self.m_charAnimator) then
        self.m_charAnimator:release()
        self:resetCharacterAnimator()
    end
end