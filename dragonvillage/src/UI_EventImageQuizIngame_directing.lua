--------------------------------------------------------------------------
-- UI_EventImageQuizIngame Directing partial class
-- @brief 드래곤 이미지 퀴즈 이벤트
--------------------------------------------------------------------------

local MAIN_NODE_WIDTH
local MAIN_NODE_HEIGHT
local DRAGON_SCALE
-------------------------------------
-- function initDirectingInfo
-- @brief 기본 정보 설정
-------------------------------------
function UI_EventImageQuizIngame:initDirectingInfo()
    local size = self.vars['clippingNode']:getContentSize()
    MAIN_NODE_WIDTH = size['width']
    MAIN_NODE_HEIGHT = size['height']

    DRAGON_SCALE = self.vars['dragonNode']:getScale()
end

-------------------------------------
-- function directing_startGame
-- @brief 시작 연출
-------------------------------------
function UI_EventImageQuizIngame:directing_startGame(directing_cb)
    local vars = self.vars

    local function coroutine_function(dt)
        local co = CoroutineHelper()
        self.m_coroutineHelper = co

        -- 코루틴 종료 콜백
        co:setCloseCB(function() self.m_coroutineHelper = nil end)

        -- READY
        local sprite = cc.Sprite:create('res/font/image_quiz/image_quiz_ready_0101.png')
        sprite:setAnchorPoint(CENTER_POINT)
        sprite:setDockPoint(CENTER_POINT)
        sprite:setPosition(ZERO_POINT)
        sprite:setScale(0)
        self.m_directingNode:addChild(sprite)

        -- Action READY
        local scaleIn = cc.EaseInOut:create(cc.ScaleTo:create(0.3, 1), 2)
        local delay = cc.DelayTime:create(0.5)
        local fadeOut = cc.FadeOut:create(0.4)
        local remove = cc.RemoveSelf:create()
        local next = cc.CallFunc:create(co.NEXT)
        local action = cc.Sequence:create(scaleIn, delay, fadeOut, remove, next)
        co:work('1')
        sprite:runAction(action)

        -- Wait
        if co:waitWork() then return end

        -- START
        local sprite = cc.Sprite:create('res/font/image_quiz/image_quiz_start_0101.png')
        sprite:setAnchorPoint(CENTER_POINT)
        sprite:setDockPoint(CENTER_POINT)
        sprite:setPosition(ZERO_POINT)
        sprite:setScale(1.5)
        self.m_directingNode:addChild(sprite)
        
        -- Action START
        co:work('2')
--        local scaleIn = cc.EaseInOut:create(cc.ScaleTo:create(0.01, 1.3), 2)
        local delay = cc.DelayTime:create(0.2)
        local fadeOut = cc.FadeOut:create(0.4)
        local remove = cc.RemoveSelf:create()
        local next = cc.CallFunc:create(co.NEXT)
        local action = cc.Sequence:create(delay, fadeOut, remove, next)
        sprite:runAction(action)
        
        -- 게임은 START 연출과 함께 시작
        directing_cb()

        -- 사운드 재생
        SoundMgr:playEffect('SFX', 'fever')

        -- Wait
        if co:waitWork() then return end

        -- 끝
        co:close()
    end

    Coroutine(coroutine_function, 'directing_startGame')
end

-------------------------------------
-- function directing_finishGame
-- @brief 시작 연출
-------------------------------------
function UI_EventImageQuizIngame:directing_finishGame(is_time_up, directing_cb)
    local vars = self.vars

    local function coroutine_function(dt)
        local co = CoroutineHelper()
        self.m_coroutineHelper = co

        -- 코루틴 종료 콜백
        co:setCloseCB(function() self.m_coroutineHelper = nil end)
        
        -- 사운드 재생
--        SoundMgr:playEffect('BGM', 'bgm_dungeon_victory')

        -- FINISH
        local sprite = cc.Sprite:create(is_time_up and 'res/font/image_quiz/image_quiz_timeup_0101.png' or 'res/font/image_quiz/image_quiz_gameover_0101.png')
        sprite:setAnchorPoint(CENTER_POINT)
        sprite:setDockPoint(CENTER_POINT)
        sprite:setPosition(ZERO_POINT)
        sprite:setScale(0)
        self.m_directingNode:addChild(sprite)
        
        -- Action START
        co:work('1')
        local scaleIn = cc.EaseInOut:create(cc.ScaleTo:create(0.3, 1.0), 2)
        local delay = cc.DelayTime:create(0.8)
        local fadeOut = cc.FadeOut:create(0.3)
        local remove = cc.RemoveSelf:create()
        local next = cc.CallFunc:create(co.NEXT)
        local action = cc.Sequence:create(scaleIn, delay, fadeOut, remove, next)
        sprite:runAction(action)

        -- Wait
        if co:waitWork() then return end

        -- 연출 완료 후 후속 처리 (확인 팝업)
        directing_cb()

        -- 끝
        co:close()
    end

    Coroutine(coroutine_function, 'directing_finishGame')
end

-------------------------------------
-- function directing_goodAnswer
-- @brief 시작 연출
-------------------------------------
function UI_EventImageQuizIngame:directing_goodAnswer()
    local vars = self.vars

    local function coroutine_function(dt)
        local co = CoroutineHelper()
        self.m_coroutineHelper = co

        -- 코루틴 종료 콜백
        co:setCloseCB(function() self.m_coroutineHelper = nil end)
        
        -- 사운드 재생
--        SoundMgr:playEffect('EFFECT', 'dragon_levelup')

        -- GOOD
        local sprite = cc.Sprite:create('res/font/image_quiz/image_quiz_good_0101.png')
        sprite:setAnchorPoint(CENTER_POINT)
        sprite:setDockPoint(CENTER_POINT)
        sprite:setPosition(cc.p(math_random(-300, 300), math_random(0, 200)))
        sprite:setScale(1)
        self.m_directingNode:addChild(sprite)
        
        -- Action GOOD
        co:work('1')
        local time = 0.5
        local scaleIn = cc.EaseInOut:create(cc.ScaleTo:create(time, 1.2), 2)
        local fadeOut = cc.FadeOut:create(time)
        local action1 = cc.Spawn:create(scaleIn, fadeOut)
        
        local remove = cc.RemoveSelf:create()
        local next = cc.CallFunc:create(co.NEXT)
        local action2 = cc.Sequence:create(action1, remove, next)
        sprite:runAction(action2)

        -- Wait
        if co:waitWork() then return end

        -- 끝
        co:close()
    end

    Coroutine(coroutine_function, 'directing_goodAnswer')
end

-------------------------------------
-- function directing_badAnswer
-- @brief 시작 연출
-------------------------------------
function UI_EventImageQuizIngame:directing_badAnswer()
    local vars = self.vars

    local function coroutine_function(dt)
        local co = CoroutineHelper()
        self.m_coroutineHelper = co
        
        -- 사운드 재생
        SoundMgr:playEffect('UI', 'ui_dragon_level_up')

        -- 버튼 비활성화
        vars['answerBtn1']:setEnabled(false)
        vars['answerBtn2']:setEnabled(false)
        vars['answerBtn3']:setEnabled(false)

        -- BAD
        local sprite = cc.Sprite:create('res/font/image_quiz/image_quiz_bad_0101.png')
        sprite:setAnchorPoint(CENTER_POINT)
        sprite:setDockPoint(CENTER_POINT)
        sprite:setPosition(cc.p(0, 200))
        sprite:setScale(0)
        self.m_directingNode:addChild(sprite)
        
        -- Action BAD 2초
        co:work('1')
        local scaleIn = cc.EaseInOut:create(cc.ScaleTo:create(0.4, 1.0), 2)
        local delay = cc.DelayTime:create(1.6)
        local remove = cc.RemoveSelf:create()
        local next = cc.CallFunc:create(co.NEXT)
        local action = cc.Sequence:create(scaleIn, delay, remove, next)
        sprite:runAction(action)
        sprite:runAction(cca.getBrrrAction(10))

        -- Wait
        if co:waitWork() then return end

        -- 버튼 활성화
        vars['answerBtn1']:setEnabled(true)
        vars['answerBtn2']:setEnabled(true)
        vars['answerBtn3']:setEnabled(true)

        -- 끝
        co:close()
    end

    Coroutine(coroutine_function, 'DiceEvent directing_badAnswer')
end

-------------------------------------
-- function directing_levelUp
-- @brief 시작 연출
-------------------------------------
function UI_EventImageQuizIngame:directing_levelUp()
    local vars = self.vars

    local function coroutine_function(dt)
        local co = CoroutineHelper()
        self.m_coroutineHelper = co
        
        -- 사운드 재생
        SoundMgr:playEffect('SFX', 'sfx_buff_get_1')

        -- LEVEL UP
        local sprite = cc.Sprite:create('res/font/image_quiz/image_quiz_levelup_0101.png')
        sprite:setAnchorPoint(CENTER_POINT)
        sprite:setDockPoint(CENTER_POINT)
        sprite:setPosition(cc.p(0, 500))
        sprite:setScale(1)
        self.m_directingNode:addChild(sprite)
        
        -- Action BAD
        co:work('1')
        cca.actGetObject(sprite, 300, cc.p(0, 1000), co.NEXT)

        -- Wait
        if co:waitWork() then return end

        -- 끝
        co:close()
    end

    Coroutine(coroutine_function, 'DiceEvent directing_levelUp')
end




-------------------------------------
-- function cleanImageQuizEffect
-- @brief 이미지 퀴즈 효과 정리
-------------------------------------
function UI_EventImageQuizIngame:cleanImageQuizEffect(pre_vfx, next_vfx)
    local vars = self.vars

    vars['actionNode']:stopAllActions()
    vars['blindTileNode']:removeAllChildren()
    vars['dragonNode']:stopAllActions()
    vars['dragonNode']:setPosition(0, 0)
    vars['dragonNode']:setScale(DRAGON_SCALE)

    -- 이전 vfx는 stencil을 조작하는 효과였으나 다음 vfx는 stencil을 조작하지 않는 경우 정상화
    cclog('ImageQuizEvent : VFX', pre_vfx, next_vfx)
    if (startsWith(pre_vfx, 'spotlight') and not startsWith(next_vfx, 'spotlight')) then
		local stencil = vars['clippingNode'].m_node:getStencil()
        stencil:removeAllChildren()

        -- @mskim drawpolygon 사용하고 싶었으나 안됨. 
        -- 원인 찾을 시간이 없어 스프라이트 기반의 사각형 스텐실 생성
        local stencil_sprite = cc.Sprite:create('res/ui/event/bd_challenge_mode_0102.png')
        if stencil_sprite then
            stencil_sprite:setAnchorPoint(CENTER_POINT)
            stencil_sprite:setPosition(MAIN_NODE_WIDTH/2, MAIN_NODE_HEIGHT/2)
            stencil_sprite:setScaleX(MAIN_NODE_WIDTH/930)
            stencil_sprite:setScaleY(MAIN_NODE_HEIGHT/640)
            stencil:addChild(stencil_sprite)
        end
    end
end

-------------------------------------
-- function spotlightScan
-- @brief 스포트라이트 움직이다 커지는 효과
-------------------------------------
function UI_EventImageQuizIngame:spotlightScan()
    local vars = self.vars

    -- stencil 비우기
    local stencil = vars['clippingNode'].m_node:getStencil()
    stencil:removeAllChildren()
    stencil:clear()

    vars['clippingNode'].m_node:setAlphaThreshold(0.5)

    -- 원형 스텐실 추가
    local stencil_sprite = cc.Sprite:create('res/ui/icons/friendship/friendship_level_0101.png')
    if stencil_sprite then
        stencil_sprite:setAnchorPoint(CENTER_POINT)
        stencil_sprite:setPosition(MAIN_NODE_WIDTH/2, MAIN_NODE_HEIGHT/2)
        stencil_sprite:setScale(1)
        stencil:addChild(stencil_sprite)
    end

    -- 액션 : 무작위 이동, 리스트 생성
    local l_action = {}
    for i = 1, 3 do
        table.insert(l_action, 
            cc.MoveTo:create(
                0.5, cc.p(
                    math_random(MAIN_NODE_WIDTH/2 - 150, MAIN_NODE_WIDTH/2 + 150), 
                    math_random(MAIN_NODE_HEIGHT/2 - 150, MAIN_NODE_HEIGHT/2 + 150)
                )
            )
        )
    end
    -- 액션 : 마지막 이동
    local last_move = cc.MoveTo:create(0.5, cc.p(MAIN_NODE_WIDTH/2, MAIN_NODE_HEIGHT/2))
    -- 액션 : 스케일업
    local action_scale = cc.ScaleTo:create(1, 10)
    local sequence = cc.Sequence:create(l_action[1], l_action[2], l_action[3], last_move, action_scale)
    stencil_sprite:runAction(sequence)
end

-------------------------------------
-- function spotlightScaleUp
-- @brief 스포트라이트 scale up 효과. 중앙에서 커지기만함
-------------------------------------
function UI_EventImageQuizIngame:spotlightScaleUp()
    local vars = self.vars
    local duration = 4
    
    -- stencil 비우기
    local stencil = vars['clippingNode'].m_node:getStencil()
    stencil:removeAllChildren()
    stencil:clear()

    vars['clippingNode'].m_node:setAlphaThreshold(0.5)

    -- 원형 스텐실 추가
    local stencil_sprite = cc.Sprite:create('res/ui/icons/friendship/friendship_level_0101.png')
    if stencil_sprite then
        stencil_sprite:setAnchorPoint(CENTER_POINT)
        stencil_sprite:setDockPoint(CENTER_POINT)
        stencil_sprite:setPosition(MAIN_NODE_WIDTH/2, MAIN_NODE_HEIGHT/2)
        stencil_sprite:setScale(0)
        stencil:addChild(stencil_sprite)
    end

    -- 스텐실 키우기
    local action_scale = cc.ScaleTo:create(duration, 10)
    stencil_sprite:runAction(action_scale)
end

-------------------------------------
-- function blindTile
-- @brief 타일 블라인드 효과
-------------------------------------
function UI_EventImageQuizIngame:blindTile()
    local vars = self.vars
    local x_interval = MAIN_NODE_WIDTH/20
    local y_interval = MAIN_NODE_HEIGHT/10
    vars['actionNode']:stopAllActions()
    vars['blindTileNode']:removeAllChildren()
    self.m_blindTileTable = {}

    for i = 1, 12 do
        for j = 1, 10 do
            local layer = cc.Sprite:create('res/ui/frames/base_frame_0203.png')
            layer:setAnchorPoint(cc.p(0, 0))
            layer:setDockPoint(cc.p(0, 0))
--            layer:setContentSize(x_interval, y_interval)
            layer:setScaleX(x_interval/40)
            layer:setScaleY(y_interval/40)
            layer:setPosition(x_interval*4 + x_interval * (i-1), y_interval * (j-1))
            layer:setOpacity(255)
            table.insert(self.m_blindTileTable, layer)
            vars['blindTileNode']:addChild(layer, 99999)
        end
    end
    self:removeBlindTileUnit()
end

-------------------------------------
-- function removeBlindTileUnit
-- @brief 타일 하나씩 지우기
-------------------------------------
function UI_EventImageQuizIngame:removeBlindTileUnit()
    local vars = self.vars
    local remained_tile_number = table.count(self.m_blindTileTable)
    local target_tile_number = math_random(remained_tile_number)
    local target_tile = self.m_blindTileTable[target_tile_number]
    if target_tile then
        target_tile:removeFromParent(true)
    end
    table.remove(self.m_blindTileTable, target_tile_number)

    if (table.count(self.m_blindTileTable) > 0) then
        local node = vars['actionNode']
        local function removeBlindTileUnit()
            self:removeBlindTileUnit()
        end
        local blind_tile_action = cc.Sequence:create(cc.DelayTime:create(0.02), cc.CallFunc:create(removeBlindTileUnit))
        node:runAction(blind_tile_action)
    end
end

-------------------------------------
-- function dragonScaleUp
-- @brief 드래곤 확대
-------------------------------------
function UI_EventImageQuizIngame:dragonScaleUp(from)
    local vars = self.vars
    local from = from or 0.1
    vars['dragonNode']:setScale(from)

    local scale = 1
    local duration = 2
    local zoom_action = cc.ScaleTo:create(duration, scale)
    local ease_action = cc.EaseIn:create(zoom_action, 2)

    vars['dragonNode']:stopAllActions()
    vars['dragonNode']:runAction(ease_action)
end

-------------------------------------
-- function dragonSlide
-- @brief 화면의 상/하/좌/우에서 랜덤하게 나타남
-------------------------------------
function UI_EventImageQuizIngame:dragonSlide()
    local vars = self.vars
    local from = math_random(4)
    local dragon_node = vars['dragonNode']
    local interval = 500
    
    local dragon_node_x = dragon_node:getPositionX()
    local dragon_node_y = dragon_node:getPositionY()
    local duration = 2

    local pos_x = 0
    local pos_y = 0
    if (from == 1) then
        pos_x = dragon_node_x
        pos_y = dragon_node_y + interval
    elseif (from == 2) then
        pos_x = dragon_node_x
        pos_y = dragon_node_y - interval
    elseif (from == 3) then
        pos_x = dragon_node_x - interval
        pos_y = dragon_node_y
    else
        pos_x = dragon_node_x + interval
        pos_y = dragon_node_y
    end
    
    dragon_node:setPositionX(pos_x)
    dragon_node:setPositionY(pos_y)
    local action = cc.Sequence:create(cc.MoveTo:create(duration, cc.p(dragon_node_x, dragon_node_y)))

    vars['dragonNode']:stopAllActions()
    vars['dragonNode']:runAction(action)
end

-------------------------------------
-- function blindImage
-- @brief 커튼 이미지에 가려 있다가 커튼이 좌/우로 랜덤하게 이동하며 등장
-------------------------------------
function UI_EventImageQuizIngame:blindImage()
    -- LEFT blind
    do
        local sprite = cc.Sprite:create('res/font/image_quiz/image_quiz_timeup_0101.png')
        sprite:setAnchorPoint(cc.p(1, 0.5))
        sprite:setDockPoint(CENTER_POINT)
        sprite:setPosition(ZERO_POINT)
        sprite:setScale(10)
        self.m_directingNode:addChild(sprite)
        
        -- Action
        local moveOut = cc.EaseOut:create(cc.MoveBy:create(2, cc.p(-100, 0)), 2)
        local remove = cc.RemoveSelf:create()
        local action = cc.Sequence:create(moveOut, remove)
        sprite:runAction(action)
    end

    -- RIGHT blind
    do
        local sprite = cc.Sprite:create('res/font/image_quiz/image_quiz_timeup_0101.png')
        sprite:setAnchorPoint(cc.p(1, 0.5))
        sprite:setDockPoint(CENTER_POINT)
        sprite:setPosition(ZERO_POINT)
        sprite:setScale(10)
        self.m_directingNode:addChild(sprite)
        
        -- Action
        local moveOut = cc.EaseOut:create(cc.MoveBy:create(2, cc.p(100, 0)), 2)
        local remove = cc.RemoveSelf:create()
        local action = cc.Sequence:create(moveOut, remove)
        sprite:runAction(action)
    end
end