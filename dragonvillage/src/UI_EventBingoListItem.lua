local PARENT = UI


-------------------------------------
-- class UI_EventBingoListItem
-------------------------------------
UI_EventBingoListItem = class(PARENT,{
        m_bingoInd = 'number',
        m_click_cb = 'function',
        m_isPickedNumber = 'boolean',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_EventBingoListItem:init(number, click_cb)
    local vars = self:load('event_bingo_item_01.ui')
    self.m_bingoInd = number
    self.m_click_cb = click_cb
    self.m_isPickedNumber = false

    self:initUI()
    self:initButton()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_EventBingoListItem:initUI()
    local vars = self.vars
    
    -- ������ ���ڷ� ����
    local _num = string.format('%03d', self.m_bingoInd) --ex) 001, ..023 3�ڸ� ����
    local num_sprite_name = string.format('res/ui/icons/bingo/%s.png', _num)
    vars['numberSprite']:setTexture(num_sprite_name)
    vars['numberSprite']:setColor(cc.c3b(240,215,159))
end

-------------------------------------
-- function setActiveNumber
-- @brief ���� ���ڸ� Ȱ��ȭ(��ȿ�ϰ�)
-------------------------------------
function UI_EventBingoListItem:setActiveNumber(is_pick)
    local vars = self.vars
    local action_speed = 0.1

    -- �̹� ���� ��ȣ��� ����
    if (self.m_isPickedNumber) then
        return
    end

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
    self.m_isPickedNumber = true

    -- Ȯ���̱⸦ ����, ������ �� �ݹ� ����
    if (is_pick) then
        self.m_click_cb(self.m_bingoInd)
    end
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_EventBingoListItem:initButton()
    local vars = self.vars

    vars['clickBtn']:registerScriptTapHandler(function() self:setActiveNumber(true) end)
    self:setBtnEnabled(false)
end

-------------------------------------
-- function setBtnEnabled
-- @breif Ȯ�� �̱⸦ ���� ��ư�� turn on/off
-------------------------------------
function UI_EventBingoListItem:setBtnEnabled(is_enabled)
    local vars = self.vars

    -- �̹� ����� ���ڰ� �ƴ� ��쿡�� ��ư on/off
    -- ��ư ���� �� �ִ� ���� = Ȯ�� ��ư ���� ����
    if (not self.m_isPickedNumber) then
        vars['clickBtn']:setEnabled(is_enabled)
        vars['pickSprite']:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.FadeTo:create(0.5, 0), cc.FadeTo:create(0.5, 100))))
        vars['pickSprite']:setVisible(is_enabled)
    end

    -- Ȱ��ȭ �ƴҶ�����, �� �� �ִ� ǥ�� ������ ��
    if (not is_enabled) then
        vars['pickSprite']:setVisible(false)
    end
end

-------------------------------------
-- function setSameNumberAction
-- @brief ���� ��ȣ ����� �� opacity �����ؼ� ���ڱ���
-------------------------------------
function UI_EventBingoListItem:setSameNumberAction()
    local vars = self.vars
    local cb_func = function()
        vars['clearSprite']:setOpacity(255)
    end
    local func_action = cc.CallFunc:create(cb_func)
    vars['clearSprite']:runAction(cc.Repeat:create(cc.Sequence:create(cc.FadeTo:create(0.4, 0), cc.FadeTo:create(0.4, 100), func_action), 2))
end
