local PARENT = UI_Card

--[[ 
# card_rune.ui �϶�
    newSprite
    selectSprite
    disableSprite
    checkSprite
    lockSprite

	enhanceNode
    starNode
	runeNumberNode
	runeNode
    frameNode
]]

-------------------------------------
-- class UI_RuneCard
-------------------------------------
UI_RuneCard = class(PARENT, {
		m_itemID = '', -- UI_ItemCard���� ����

        m_runeData = '',

        m_runeIconRes = 'string',
        m_frameRes = 'string',
        m_levelNumber = 'number',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_RuneCard:init(t_rune_data)
    self.ui_res = 'card_rune.ui'
    self:getUIInfo()

    self.m_runeData = t_rune_data
	self.m_itemID = t_rune_data['rid']

    -- ��ư ����
    self:makeClickBtn()

    -- �巡�� ���� ����
    self:refreshInfo()
end

-------------------------------------
-- function makeClickBtn
-------------------------------------
function UI_RuneCard:makeClickBtn()
    local btn = self.vars['clickBtn']

    if (not btn) then
        btn = cc.MenuItemImage:create()
        btn:setDockPoint(CENTER_POINT)
        btn:setAnchorPoint(CENTER_POINT)
        btn:setContentSize(150, 150)
    
        self.vars['clickBtn'] = UIC_Button(btn)
        self.root:addChild(btn, -1)

		btn:registerScriptPressHandler(function() self:press_clickBtn() end)
    end
end

-------------------------------------
-- function refreshInfo
-------------------------------------
function UI_RuneCard:refreshInfo()
    if (not self.m_runeData) then
        return
    end

    -- �� ������
    self:makeIcon()
	self:makeRuneNumberIcon()

    -- ī�� ������
    self:makeFrame()

    -- ��� ������ ����
    self:refresh_gradeIcon()

    -- ���� ����
    self:setLevelText()

    -- ��� ǥ��
    self:refresh_Lock()
end

-------------------------------------
-- function makeIcon
-- @brief �� ������ ����
-------------------------------------
function UI_RuneCard:makeIcon()
	local res = self.m_runeData:getRuneRes()
    if (self.m_runeIconRes == res) then
        return
    end
    self.m_runeIconRes = res
    self:makeSprite('runeNode', res, true) -- (lua_name, res, no_use_frames)

	-- �̰� ���ַ��� 50���� �������� �����ؾ� ��
	if (self.m_runeData['slot'] == 1) then
		self.vars['runeNode']:setPositionY(1)
	end
end

-------------------------------------
-- function makeRuneNumberIcon
-- @brief �� ���� ������ ����
-------------------------------------
function UI_RuneCard:makeRuneNumberIcon()
	local slot = self.m_runeData['slot']
	local res = string.format('res/ui/icons/rune/rune_number_%.2d.png', slot)
    self:makeSprite('runeNumberNode', res, true) -- (lua_name, res, no_use_frames)

	-- �̰� ���ַ��� 50���� �������� �����ؾ� ��
	if (self.m_runeData['slot'] == 1) then
		self.vars['runeNumberNode']:setPositionY(1)
	end
end

-------------------------------------
-- function makeFrame
-- @brief ������ ����
-------------------------------------
function UI_RuneCard:makeFrame()
    local res = self.m_runeData:getRarityFrameRes()
    if (self.m_frameRes == res) then
        return
    end
    self.m_frameRes = res
    self:makeSprite('frameNode', res)
end

-------------------------------------
-- function refresh_gradeIcon
-- @brief ��� ������
-------------------------------------
function UI_RuneCard:refresh_gradeIcon()
	local grade = self.m_runeData['grade']
    local res = string.format('card_star_yellow_01%02d.png', grade)
    self:makeSprite('starNode', res)
end

-------------------------------------
-- function setLevelText
-- @brief ���� �ؽ�Ʈ ����
-------------------------------------
function UI_RuneCard:setLevelText(level)
    local level = self.m_runeData['lv']
    if (self.m_levelNumber == level) then  
        return
    end
    self.m_levelNumber = level

    self:setNumberText(level, true) -- (use_plus)
end

-------------------------------------
-- function refresh_Lock
-- @brief ��� ����
-------------------------------------
function UI_RuneCard:refresh_Lock()
	local is_lock = self.m_runeData:getLock()
	self:setLockSpriteVisible(is_lock)
end

-------------------------------------
-- function setLockSpriteVisible
-- @brief ��� ǥ��
-------------------------------------
function UI_RuneCard:setLockSpriteVisible(visible)
    local res = 'card_cha_icon_lock.png'
    local lua_name = 'lockSprite'
    self:setSpriteVisible(lua_name, res, visible)
end

-------------------------------------
-- function setNewSpriteVisible
-- @brief �ű� �� ǥ��
-- @external call
-------------------------------------
function UI_RuneCard:setNewSpriteVisible(visible)
    local res = 'card_cha_new.png'
    local lua_name = 'newSprite'
    self:setSpriteVisible(lua_name, res, visible)
end

-------------------------------------
-- function setHighlightSpriteVisible
-- @brief highlight ǥ��
-- @external call
-------------------------------------
function UI_RuneCard:setHighlightSpriteVisible(visible)
    local res = 'card_cha_frame_select.png'
    local lua_name = 'selectSprite'

    if self.vars[lua_name] then
        self.vars[lua_name]:setVisible(visible)
    elseif (visible) then
        self:makeSprite(lua_name, res)
        -- ������ �׼�
        self.vars[lua_name]:runAction(cca.flash())
    end
end

-------------------------------------
-- function setCheckSpriteVisible
-- @brief ī�� üũ ǥ��
-- @external call
-------------------------------------
function UI_RuneCard:setCheckSpriteVisible(visible)
    local res = 'card_cha_frame_check.png'
    local lua_name = 'checkSprite'
    self:setSpriteVisible(lua_name, res, visible)
end

-------------------------------------
-- function setShadowSpriteVisible
-- @brief ī�� ���� ǥ��
-------------------------------------
function UI_RuneCard:setShadowSpriteVisible(visible)
    local res = 'card_cha_frame_disable.png'
    local lua_name = 'disableSprite'
    self:setSpriteVisible(lua_name, res, visible)
end

-------------------------------------
-- function setBtnEnabled
-- @brief ��ư�� ���´�
-------------------------------------
function UI_RuneCard:setBtnEnabled(able)
	self.vars['clickBtn']:setEnabled(able)
end

-------------------------------------
-- function press_clickBtn
-------------------------------------
function UI_RuneCard:press_clickBtn()
    local item_id = self.m_itemID
    local count = 1
	local t_rune_data = self.m_runeData

    UI_ItemInfoPopup(item_id, count, t_rune_data)
end
