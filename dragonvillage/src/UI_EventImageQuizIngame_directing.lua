--------------------------------------------------------------------------
-- Directing
--------------------------------------------------------------------------


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

        -- 버튼은 숨겨놓는다.
        local button_pos_y = 400
        vars['bottomNode']:setPositionY(-button_pos_y)

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
        local fadeOut = cc.FadeOut:create(0.5)
        local next = cc.CallFunc:create(co.NEXT)
        local action = cc.Sequence:create(scaleIn, delay, fadeOut, next)
        co:work('1')
        sprite:runAction(action)

        -- Wait
        if co:waitWork() then return end
        sprite:removeFromParent()

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
        local next = cc.CallFunc:create(co.NEXT)
        local action = cc.Sequence:create(delay, fadeOut, next)
        sprite:runAction(action)
        
        -- 게임은 START 연출과 함께 시작
        directing_cb()

        -- 하단 버튼 등장!
        vars['bottomNode']:runAction(cc.EaseOut:create(cc.MoveBy:create(0.3, cc.p(0, button_pos_y)), 4))

        -- Wait
        if co:waitWork() then return end
        sprite:removeFromParent()

        -- 끝
        co:close()
    end

    Coroutine(coroutine_function, 'directing_startGame')
end

-------------------------------------
-- function directing_finishGame
-- @brief 시작 연출
-------------------------------------
function UI_EventImageQuizIngame:directing_finishGame()
    
end


-------------------------------------
-- function directing_wrongAnswer
-- @brief 시작 연출
-------------------------------------
function UI_EventImageQuizIngame:directing_wrongAnswer()
    local vars = self.vars

    local function coroutine_function(dt)
        local co = CoroutineHelper()
        self.m_coroutineHelper = co

        -- 코루틴 종료 콜백
        co:setCloseCB(function() self.m_coroutineHelper = nil end)

        -- 사운드 재생
        SoundMgr:playEffect('UI', 'ui_dragon_level_up')

        cclog('disable')
        -- 버튼 비활성화
        vars['answerBtn1']:setEnabled(false)
        vars['answerBtn2']:setEnabled(false)
        vars['answerBtn3']:setEnabled(false)

        -- 2초 대기
        co:waitTime(2)

        cclog('enable')
        -- 버튼 활성화
        vars['answerBtn1']:setEnabled(true)
        vars['answerBtn2']:setEnabled(true)
        vars['answerBtn3']:setEnabled(true)

        -- 끝
        co:close()
    end

    Coroutine(coroutine_function, 'DiceEvent Directing')
end
-------------------------------------
-- function spotlightScan
-- @brief 스포트라이트 움직이다 커지는 효과
-------------------------------------
function UI_EventImageQuizIngame:spotlightScan()
    local vars = self.vars
    local duration = 0.5
    local scale = 5
    
    vars['spotlight']:stopAllActions()
    vars['spotlight']:setScale(1)
    vars['spotlight']:setVisible(true)
    local l_location = {}
    for i = 1, 6 do
        table.insert(l_location, math_random(-150, 150))
    end
    local l_action = {}
    for i = 1, 3 do
        table.insert(l_action, cc.Sequence:create(cc.MoveTo:create(duration, cc.p(l_location[i * 2 - 1], l_location[i * 2]))))
    end
    local action_scale = cc.ScaleTo:create(duration, scale)
    local sequence = cc.Sequence:create(l_action[1], l_action[2], l_action[3], action_scale)
    vars['spotlight']:runAction(sequence)
end

-------------------------------------
-- function spotlightScaleUp
-- @brief 스포트라이트 scale up 효과. 중앙에서 커지기만함
-------------------------------------
function UI_EventImageQuizIngame:spotlightScaleUp()
    local vars = self.vars
    local duration = 2
    
    vars['spotlight']:stopAllActions()
    vars['spotlight']:setScale(1)
    vars['spotlight']:setVisible(true)
    vars['spotlight']:setPosition(0, 0)
    local action_scale = cc.ScaleTo:create(duration, 5)

    vars['spotlight']:runAction(action_scale)
end

-------------------------------------
-- function blindTile
-- @brief 타일 블라인드 효과
-------------------------------------
function UI_EventImageQuizIngame:blindTile()
    local vars = self.vars
    local x_interval = 90
    local y_interval = 50
    vars['tempNodeForBlindTile']:stopAllActions()
    vars['blindTileNode']:removeAllChildren()
    self.m_blindTileTable = {}

    for i = 1, 10 do
        for j = 1, 10 do
            local layer = cc.LayerColor:create()
            layer:setAnchorPoint(cc.p(0, 0))
            layer:setDockPoint(cc.p(0, 0))
            layer:setColor(cc.c3b(255,0,0))
            layer:setContentSize(90, 50)
            layer:setPosition(x_interval * (i-1), y_interval * (j-1))
            layer:setOpacity(254)
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
        local node = vars['tempNodeForBlindTile']
        local function removeBlindTileUnit()
            self:removeBlindTileUnit()
        end
        local blind_tile_action = cc.Sequence:create(cc.DelayTime:create(0.015), cc.CallFunc:create(removeBlindTileUnit))
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
    local vars = self.vars
    local to = math_random(2)
    local curtain = vars['curtain']
    curtain:setVisible(true)
    local duration = 2

    local pos_x = 0
    local pos_y = curtain:getPositionY()
    if (to == 1) then
        pos_x = -1000
    else
        pos_x = 1000
    end
    local action = cc.Sequence:create(cc.MoveTo:create(duration, cc.p(pos_x, pos_y)))

    curtain:stopAllActions()
    curtain:runAction(action)
end