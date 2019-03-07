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
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_EventBingo:initUI()
    local vars = self.vars
    
    -- ���� ĭ ����
    for i = 1, 25 do
        local ui = _UI_EventBingoListItem(i)
        local node = vars['bingoNode'..i]
        if node then
            node:removeAllChildren()
            node:addChild(ui.root)
            table.insert(self.m_tBingoListItem, ui)
        end
    end

    -- ���� ���� ����
    for i = 1, 12 do
        local ui = _UI_EventBingoRewardListItem(i)
        local node = vars['itemNode'..i]
        if node then
            node:removeAllChildren()
            node:addChild(ui.root)
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
-- function refresh
-------------------------------------
function UI_EventBingo:refresh()
    local vars = self.vars
    
    local temp = '00' -- �ӽ�
    vars['timeLabel']:setString(Str('{1} ����', temp))
    vars['numberLabel1']:setString(Str('{1}��',temp))
    vars['obtainLabel']:setString(Str('���� �ִ� {1}/2,000�� ȹ�� ����', temp))
    vars['rewardLabel']:setString(Str('{1} ���� ����', temp))
    vars['progressLabel']:setString(Str('���൵: {1}/12', temp))
    vars['numberLabel2']:setString(Str('{1}��', temp))
    vars['numberLabel3']:setString(Str('{1}��', temp))   
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
-- function getLinePos
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
-- function pickNumberAction
-- @brief ���ڵ��� �� �ٲ�ٰ� �����Ǵ� �׼�
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
        local _num = string.format('%03d', num) --ex) 001, ..023 3�ڸ� ����
        local num_sprite_name = string.format('res/ui/icons/bingo/%s.png', _num)
        vars['pickAniSprite']:setTexture(num_sprite_name)
    end
    
    local end_frunc = function()
        local num = number
        local _num = string.format('%03d', num) --ex) 001, ..023 3�ڸ� ����
        local num_sprite_name = string.format('res/ui/icons/bingo/%s.png', _num)
        vars['pickAniSprite']:setTexture(num_sprite_name)
    end 
    
    -- �������� �ٲ�� ȿ��
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
    local ui = UI()
    ui:load('event_exchange_info_popup.ui')
    ui.vars['closeBtn']:registerScriptTapHandler(function() ui:close() end)
    g_currScene:pushBackKeyListener(ui, function() ui:close() end, 'event_chuseok_info_popup')
    UIManager:open(ui, UIManager.POPUP)
end







local PARENT = UI
-------------------------------------
-- class _UI_EventBingoListItem
-------------------------------------
_UI_EventBingoListItem = class(PARENT,{
        m_bingoInd = 'number',
    })

-------------------------------------
-- function init
-------------------------------------
function _UI_EventBingoListItem:init(number)
    local vars = self:load('event_bingo_item_01.ui')
    self.m_bingoInd = number

    self:initUI()
    self:initButton()
end

-------------------------------------
-- function initUI
-------------------------------------
function _UI_EventBingoListItem:initUI()
    local vars = self.vars
    
    -- 1~ 25���� ����
    local _num = string.format('%03d', self.m_bingoInd) --ex) 001, ..023 3�ڸ� ����
    local num_sprite_name = string.format('res/ui/icons/bingo/%s.png', _num)
    vars['numberSprite']:setTexture(num_sprite_name)
    vars['numberSprite']:setColor(cc.c3b(240,215,159))
end

-------------------------------------
-- function setActiveNumber
-- @brief ���� ���ڸ� Ȱ��ȭ(��ȿ�ϰ�)
-------------------------------------
function _UI_EventBingoListItem:setActiveNumber()
    local vars = self.vars
    local action_speed = 0.1
    
    local func_active = function()
        vars['clearSprite']:setVisible(true)
        vars['numberSprite']:setColor(cc.c3b(72,25,0))
    end 
    
    -- ī�� ������ ȿ��
    local flip_action = cc.ScaleTo:create(action_speed, 0, 1)
    local cb_frunc = cc.CallFunc:create(func_active)
    local flip_action_reverse = cc.ScaleTo:create(action_speed, 1, 1)
	local sequence_action = cc.Sequence:create(flip_action, cb_frunc, flip_action_reverse)
    cca.runAction(self.root, sequence_action, nil)
end

-------------------------------------
-- function initButton
-------------------------------------
function _UI_EventBingoListItem:initButton()
    local vars = self.vars

    vars['clickBtn']:registerScriptTapHandler(function() self:setActiveNumber() end)
    vars['clickBtn']:setEnabled(false)
end









local PARENT = UI
-------------------------------------
-- class _UI_EventBingoListItem
-------------------------------------
_UI_EventBingoRewardListItem = class(PARENT,{
        m_rewardInd = 'number',
    })

-------------------------------------
-- function init
-------------------------------------
function _UI_EventBingoRewardListItem:init(reward_ind)
    local vars = self:load('event_bingo_item_02.ui')
    self.m_rewardInd = reward_ind

    self:initUI()
    self:initButton()
end

-------------------------------------
-- function initUI
-------------------------------------
function _UI_EventBingoRewardListItem:initUI()
    local vars = self.vars
    local table_bingo_reward = TABLE:get('table_bingo_reward')
    local reward_id = 1000 + self.m_rewardInd
    
    local reward_item_str = table_bingo_reward[reward_id]['reward'] -- 700002;1
    local t_reward = pl.stringx.split(reward_item_str, ';')
    local reward_item_id, reward_item_cnt = tonumber(t_reward[1]), tonumber(t_reward[2])
    
    local reward_card = UI_ItemCard(reward_item_id, reward_item_cnt)
    reward_card.vars['bgSprite']:setVisible(false)
    reward_card.vars['commonSprite']:setVisible(false)
    vars['iconNode']:addChild(reward_card.root)
end
