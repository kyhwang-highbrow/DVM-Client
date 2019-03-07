local PARENT = UI

-------------------------------------
-- class UI_EventBingo
-------------------------------------
UI_EventBingo = class(PARENT,{
        m_tBingoListItem = 'table',
    })

local BINGO_TYPE = {['HORIZONTAL'] = 1, ['VERTICAL'] = 2, ['CROSS_RIGHT_TO_LEFT'] = 3, ['CROSS_LEFT_TO_RIGHT'] = 4}

-------------------------------------
-- function init
-------------------------------------
function UI_EventBingo:init()
    local vars = self:load('event_bingo.ui')
    self.m_tBingoListItem = {}

    self:initUI()
    self:initButton()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_EventBingo:initUI()
    local vars = self.vars
    
    for i = 1, 25 do
        local ui = UI_EventBingoListItem(i, self)
        local node = vars['bingoNode'..i]
        if node then
            node:removeAllChildren()
            node:addChild(ui.root)
            table.insert(self.m_tBingoListItem, ui)
        end
    end

end

-------------------------------------
-- function initButton
-------------------------------------
function UI_EventBingo:initButton()
    local vars = self.vars

    vars['notRewardBtn']:registerScriptTapHandler(function() self:click_infoBtn() end)
    vars['playBtn1']:registerScriptTapHandler(function() self:click_infoBtn() end)
    vars['playBtn2']:registerScriptTapHandler(function() self:click_infoBtn() end)
    vars['infoBtn']:registerScriptTapHandler(function() self:click_infoBtn() end)
end

-------------------------------------
-- function setBingo
-- @brief 빙고가 성립됨
-------------------------------------
function UI_EventBingo:setBingo(bingo_type, line) -- HORIZONTAL, VERTICAL, CROSS
    local vars = self.vars

    -- 보상 버튼 활성화

    -- a2d 애니메이션
    local ani = MakeAnimator('res/ui/a2d/event_bingo/event_bingo/event_bingo.vrp')
    vars['visualNode']:addChild(ani.m_node)
    
    local pos_x, pos_y = self:getLinePos(bingo_type, line)
    ani:setPosition(pos_x, pos_y)

    if (bingo_type == BINGO_TYPE.HORIZONTAL) then
        ani:changeAni('horizontal')
    elseif (bingo_type == BINGO_TYPE.VERTICAL) then
        ani:changeAni('vertical')    
    elseif (bingo_type == BINGO_TYPE.CROSS_RIGHT_TO_LEFT) then
        ani:changeAni('cross_right_to_left')
    else
        ani:changeAni('cross_left_to_right')
    end
end

-------------------------------------
-- function getLinePos
-------------------------------------
function UI_EventBingo:getLinePos(bingo_type, line) -- param 의미 : 가로 3 번 째줄, 세로 1 번 째줄
    local vars = self.vars

    local pos_x, pos_y = 0, 0
    local offset = 40 -- 빙고칸 절반크기 조금 안되는 위치

    if (bingo_type == BINGO_TYPE.HORIZONTAL) then        -- 가로 빙고 : line 첫 칸 - offsetX
        local _line = 1 + (line-1) * 5
        pos_x, pos_y = vars['bingoNode'.._line]:getPosition()
        pos_x = pos_x - offset

    elseif (bingo_type == BINGO_TYPE.VERTICAL) then       -- 세로 빙고 : line 첫 줄 + offsetY
        pos_x, pos_y = vars['bingoNode'..line]:getPosition()
        pos_y = pos_y + offset

    elseif (bingo_type == BINGO_TYPE.CROSS_LEFT_TO_RIGHT) then  -- 대각선 빙고(left_to_right) : 1번 칸 - offsetX + offsetY
        pos_x, pos_y = vars['bingoNode1']:getPosition()
        pos_x = pos_x - offset
        pos_y = pos_y + offset
    elseif (bingo_type == BINGO_TYPE.CROSS_RIGHT_TO_LEFT) then  -- 대각선 빙고(right_to_left) : 1번 칸 + offsetX + offsetY
        pos_x, pos_y = vars['bingoNode5']:getPosition()
        pos_x = pos_x + offset
        pos_y = pos_y + offset
    end

    return pos_x, pos_y
end

-------------------------------------
-- function pickNumberAction
-- @brief 숫자들이 막 바뀌다가 고정되는 액션
-------------------------------------
function UI_EventBingo:pickNumberAction(number)
    local vars = self.vars
    local change_speed = 0.05
    local repeat_cnt = 12
    
    if (not vars['pickAniSprite']) then
        return
    end
    
    vars['pickAniSprite']:setVisible(true)

    local random_frunc = function()
        local num = math_random(24) + 1
        local _num = string.format('%03d', num) --ex) 001, ..023 3자리 형식
        local num_sprite_name = string.format('res/ui/icons/bingo/%s.png', _num)
        vars['pickAniSprite']:setTexture(num_sprite_name)
    end
    
    local end_frunc = function()
        local num = number
        local _num = string.format('%03d', num) --ex) 001, ..023 3자리 형식
        local num_sprite_name = string.format('res/ui/icons/bingo/%s.png', _num)
        vars['pickAniSprite']:setTexture(num_sprite_name)
    end 
    
    -- 랜덤으로 바뀌는 효과
    local random_action = cc.CallFunc:create(random_frunc)
    local delay_action = cc.DelayTime:create(change_speed)
    local repeat_sequence_action = cc.Sequence:create(random_action, delay_action)
    local repeat_action = cc.Repeat:create(repeat_sequence_action, repeat_cnt)
    local end_action = cc.CallFunc:create(end_frunc)
    local sequence_action = cc.Sequence:create(repeat_action, end_action)

    cca.runAction(self.root, sequence_action, nil)
end

-------------------------------------
-- function click_infoBtn
-------------------------------------
function UI_EventBingo:click_infoBtn()

end







local PARENT = UI
-------------------------------------
-- class UI_EventBingoListItem
-------------------------------------
UI_EventBingoListItem = class(PARENT,{
        m_bingoInd = 'number',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_EventBingoListItem:init(number, ui)
    local vars = self:load('event_bingo_item_01.ui')
    self.m_bingoInd = number

    self:initUI()
    self:initButton()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_EventBingoListItem:initUI()
    local vars = self.vars
    
    -- 1~ 25까지 세팅
    local _num = string.format('%03d', self.m_bingoInd) --ex) 001, ..023 3자리 형식
    local num_sprite_name = string.format('res/ui/icons/bingo/%s.png', _num)
    vars['numberSprite']:setTexture(num_sprite_name)
    vars['numberSprite']:setColor(cc.c3b(240,215,159))
end

-------------------------------------
-- function setActiveNumber
-- @brief 빙고 숫자를 활성화(유효하게)
-------------------------------------
function UI_EventBingoListItem:setActiveNumber()
    local vars = self.vars
    local action_speed = 0.1
    
    local func_active = function()
        vars['clearSprite']:setVisible(true)
        vars['numberSprite']:setColor(cc.c3b(72,25,0))
    end 
    
    -- 카드 뒤집는 효과
    local flip_action = cc.ScaleTo:create(action_speed, 0, 1)
    local cb_frunc = cc.CallFunc:create(func_active)
    local flip_action_reverse = cc.ScaleTo:create(action_speed, 1, 1)
	local sequence_action = cc.Sequence:create(flip_action, cb_frunc, flip_action_reverse)
    cca.runAction(self.root, sequence_action, nil)
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_EventBingoListItem:initButton()
    local vars = self.vars

    vars['clickBtn']:registerScriptTapHandler(function() self:setActiveNumber() end)   
end