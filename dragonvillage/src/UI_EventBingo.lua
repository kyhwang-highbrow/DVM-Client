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
-- @brief ���� ������
-------------------------------------
function UI_EventBingo:setBingo(bingo_type, line) -- HORIZONTAL, VERTICAL, CROSS
    local vars = self.vars

    -- ���� ��ư Ȱ��ȭ

    -- a2d �ִϸ��̼�
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
function UI_EventBingo:getLinePos(bingo_type, line) -- param �ǹ� : ���� 3 �� °��, ���� 1 �� °��
    local vars = self.vars

    local pos_x, pos_y = 0, 0
    local offset = 40 -- ����ĭ ����ũ�� ���� �ȵǴ� ��ġ

    if (bingo_type == BINGO_TYPE.HORIZONTAL) then        -- ���� ���� : line ù ĭ - offsetX
        local _line = 1 + (line-1) * 5
        pos_x, pos_y = vars['bingoNode'.._line]:getPosition()
        pos_x = pos_x - offset

    elseif (bingo_type == BINGO_TYPE.VERTICAL) then       -- ���� ���� : line ù �� + offsetY
        pos_x, pos_y = vars['bingoNode'..line]:getPosition()
        pos_y = pos_y + offset

    elseif (bingo_type == BINGO_TYPE.CROSS_LEFT_TO_RIGHT) then  -- �밢�� ����(left_to_right) : 1�� ĭ - offsetX + offsetY
        pos_x, pos_y = vars['bingoNode1']:getPosition()
        pos_x = pos_x - offset
        pos_y = pos_y + offset
    elseif (bingo_type == BINGO_TYPE.CROSS_RIGHT_TO_LEFT) then  -- �밢�� ����(right_to_left) : 1�� ĭ + offsetX + offsetY
        pos_x, pos_y = vars['bingoNode5']:getPosition()
        pos_x = pos_x + offset
        pos_y = pos_y + offset
    end

    return pos_x, pos_y
end

-------------------------------------
-- function existType
-------------------------------------
function UI_EventBingo:getLinePos(bingo_type, line) -- param �ǹ� : ���� 3 �� °��, ���� 1 �� °��
    local vars = self.vars

    local pos_x, pos_y = 0, 0
    local offset = 40 -- ����ĭ ����ũ�� ���� �ȵǴ� ��ġ

    if (bingo_type == BINGO_TYPE.HORIZONTAL) then        -- ���� ���� : line ù ĭ - offsetX
        local _line = 1 + (line-1) * 5
        pos_x, pos_y = vars['bingoNode'.._line]:getPosition()
        pos_x = pos_x - offset

    elseif (bingo_type == BINGO_TYPE.VERTICAL) then       -- ���� ���� : line ù �� + offsetY
        pos_x, pos_y = vars['bingoNode'..line]:getPosition()
        pos_y = pos_y + offset

    elseif (bingo_type == BINGO_TYPE.CROSS_LEFT_TO_RIGHT) then  -- �밢�� ����(left_to_right) : 1�� ĭ - offsetX + offsetY
        pos_x, pos_y = vars['bingoNode1']:getPosition()
        pos_x = pos_x - offset
        pos_y = pos_y + offset
    elseif (bingo_type == BINGO_TYPE.CROSS_RIGHT_TO_LEFT) then  -- �밢�� ����(right_to_left) : 1�� ĭ + offsetX + offsetY
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
    
    -- 1~ 25���� ����
    local _num = string.format('%03d', self.m_bingoInd) --ex) 001, ..023 3�ڸ� ����
    local num_sprite_name = string.format('res/ui/icons/bingo/%s.png', _num)
    vars['numberSprite']:setTexture(num_sprite_name)
end

-------------------------------------
-- function setActiveNumber
-- @brief ���� ���ڸ� Ȱ��ȭ(��ȿ�ϰ�)
-------------------------------------
function UI_EventBingoListItem:setActiveNumber()
    local vars = self.vars
    local action_speed = 0.1
    
    local func_active = function()
        vars['clearSprite']:setVisible(true)   
    end 
    
    -- ī�� ������ ȿ��
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