--------------------------------------------------------------------------
-- Directing
--------------------------------------------------------------------------


-------------------------------------
-- function directing_startGame
-- @brief ���� ����
-------------------------------------
function UI_EventImageQuizIngame:directing_startGame(directing_cb)
    local vars = self.vars

    local function coroutine_function(dt)
        local co = CoroutineHelper()
        self.m_coroutineHelper = co

        -- �ڷ�ƾ ���� �ݹ�
        co:setCloseCB(function() self.m_coroutineHelper = nil end)

        -- ��ư�� ���ܳ��´�.
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
        
        -- ������ START ����� �Բ� ����
        directing_cb()

        -- �ϴ� ��ư ����!
        vars['bottomNode']:runAction(cc.EaseOut:create(cc.MoveBy:create(0.3, cc.p(0, button_pos_y)), 4))

        -- Wait
        if co:waitWork() then return end
        sprite:removeFromParent()

        -- ��
        co:close()
    end

    Coroutine(coroutine_function, 'directing_startGame')
end

-------------------------------------
-- function directing_finishGame
-- @brief ���� ����
-------------------------------------
function UI_EventImageQuizIngame:directing_finishGame()
    
end


-------------------------------------
-- function directing_wrongAnswer
-- @brief ���� ����
-------------------------------------
function UI_EventImageQuizIngame:directing_wrongAnswer()
    local vars = self.vars

    local function coroutine_function(dt)
        local co = CoroutineHelper()
        self.m_coroutineHelper = co

        -- �ڷ�ƾ ���� �ݹ�
        co:setCloseCB(function() self.m_coroutineHelper = nil end)

        -- ���� ���
        SoundMgr:playEffect('UI', 'ui_dragon_level_up')

        cclog('disable')
        -- ��ư ��Ȱ��ȭ
        vars['answerBtn1']:setEnabled(false)
        vars['answerBtn2']:setEnabled(false)
        vars['answerBtn3']:setEnabled(false)

        -- 2�� ���
        co:waitTime(2)

        cclog('enable')
        -- ��ư Ȱ��ȭ
        vars['answerBtn1']:setEnabled(true)
        vars['answerBtn2']:setEnabled(true)
        vars['answerBtn3']:setEnabled(true)

        -- ��
        co:close()
    end

    Coroutine(coroutine_function, 'DiceEvent Directing')
end
-------------------------------------
-- function spotlightScan
-- @brief ����Ʈ����Ʈ �����̴� Ŀ���� ȿ��
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
-- @brief ����Ʈ����Ʈ scale up ȿ��. �߾ӿ��� Ŀ���⸸��
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
-- @brief Ÿ�� ����ε� ȿ��
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
-- @brief Ÿ�� �ϳ��� �����
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
-- @brief �巡�� Ȯ��
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
-- @brief ȭ���� ��/��/��/�쿡�� �����ϰ� ��Ÿ��
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
-- @brief Ŀư �̹����� ���� �ִٰ� Ŀư�� ��/��� �����ϰ� �̵��ϸ� ����
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