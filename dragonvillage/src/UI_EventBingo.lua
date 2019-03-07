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
-- function existType
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
-- function existType
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
    end 
    
    -- 카드 뒤집는 효과
    local flip_action = cc.ScaleTo:create(action_speed, 0, 1)
    local cb_frunc = cc.CallFunc:create(func_active)
    local flip_action_reverse = cc.ScaleTo:create(action_speed, 1, 1)
	local sequence = cc.Sequence:create(flip_action, cb_frunc, flip_action_reverse)
    cca.runAction(self.root, sequence, nil)
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_EventBingoListItem:initButton()
    local vars = self.vars

    vars['clickBtn']:registerScriptTapHandler(function() self:setActiveNumber() end)   
end