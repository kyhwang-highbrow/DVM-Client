local PARENT = UI_Card

--[[ 
# card_rune.ui 일람
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
		m_itemID = '', -- UI_ItemCard와의 통일

        m_runeData = '',

        m_runeIconRes = 'string',
        m_frameRes = 'string',
        m_levelNumber = 'number',

        m_infoUI = 'UI_ItemInfoPopup',
        m_closeInfoCallback = 'function', -- UI_ItemInfoPopup 닫을 때 callback function
    })

-------------------------------------
-- function init
-------------------------------------
function UI_RuneCard:init(t_rune_data)
    self.ui_res = 'card_rune.ui'
    self:getUIInfo()

    self.m_runeData = t_rune_data
	self.m_itemID = t_rune_data['rid']

    -- 버튼 생성
    self:makeClickBtn()

    -- 드래곤 정보 생성
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

    -- 룬 아이콘
    self:makeIcon()
	self:makeRuneNumberIcon()

    -- 카드 프레임
    self:makeFrame()

    -- 등급 아이콘 생성
    self:refresh_gradeIcon()

    -- 레벨 지정
    self:setLevelText()

    -- 잠금 표시
    self:refresh_lock()

    -- 연마 표시
    self:refresh_grind()

    -- 장착 표시
    self:refresh_equip()

    -- 메모 표시
    self:refresh_memo()
end

-------------------------------------
-- function makeIcon
-- @brief 룬 아이콘 생성
-------------------------------------
function UI_RuneCard:makeIcon()
	local res = self.m_runeData:getRuneRes()
    if (self.m_runeIconRes == res) then
        return
    end
    self.m_runeIconRes = res
    self:makeSprite('runeNode', res, true) -- (lua_name, res, no_use_frames)

	-- 이거 없애려면 50개의 아이콘을 수정해야 함
	if (self.m_runeData['slot'] == 1) then
		self.vars['runeNode']:setPositionY(1)
	end
end

-------------------------------------
-- function makeRuneNumberIcon
-- @brief 룬 숫자 아이콘 생성
-------------------------------------
function UI_RuneCard:makeRuneNumberIcon()
    -- 고대룬은 숫자 아이콘 생성하지 않는다.
    local is_ancient = self.m_runeData:isAncientRune()
    if (is_ancient) then
        return
    end

	local slot = self.m_runeData['slot']
	local res = string.format('res/ui/icons/rune/rune_number_%.2d.png', slot)
    self:makeSprite('runeNumberNode', res, true) -- (lua_name, res, no_use_frames)

	-- 이거 없애려면 50개의 아이콘을 수정해야 함
	if (self.m_runeData['slot'] == 1) then
		self.vars['runeNumberNode']:setPositionY(1)
	end
end

-------------------------------------
-- function makeFrame
-- @brief 프레임 생성
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
-- @brief 등급 아이콘
-------------------------------------
function UI_RuneCard:refresh_gradeIcon()
	local grade = self.m_runeData['grade']
    local res = string.format('card_star_yellow_01%02d.png', grade)
    self:makeSprite('starNode', res)
end

-------------------------------------
-- function setLevelText
-- @brief 레벨 텍스트 지정
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
-- function isRuneLock
-- @brief 잠금 갱신
-------------------------------------
function UI_RuneCard:isRuneLock()
	return self.m_runeData:getLock()
end

-------------------------------------
-- function refresh_lock
-- @brief 잠금 갱신
-------------------------------------
function UI_RuneCard:refresh_lock()
	local is_lock = self.m_runeData:getLock()
	self:setLockSpriteVisible(is_lock)
end

-------------------------------------
-- function setLockSpriteVisible
-- @brief 잠금 표시
-------------------------------------
function UI_RuneCard:setLockSpriteVisible(visible)
    local res = 'card_cha_icon_lock.png'
    local lua_name = 'lockSprite'
    self:setSpriteVisible(lua_name, res, visible)
end

-------------------------------------
-- function refresh_grind
-- @brief 연마 갱신
-------------------------------------
function UI_RuneCard:refresh_grind()
	local is_grind = (self.m_runeData:getGrindedOption() ~= nil)
	self:setGrindSpriteVisible(is_grind)
end

-------------------------------------
-- function setGrindSpriteVisible
-- @brief 연마 표시
-------------------------------------
function UI_RuneCard:setGrindSpriteVisible(visible)
    local res = 'card_rune_grind.png'
    local lua_name = 'grindSprite'
    self:setSpriteVisible(lua_name, res, visible)
end

-------------------------------------
-- function refresh_memo
-- @brief 메모 갱신
-------------------------------------
function UI_RuneCard:refresh_memo()
	local is_memo = (g_runeMemoData:getMemo(self.m_runeData.roid) ~= nil)
	self:setMemoSpriteVisible(is_memo)
end

-------------------------------------
-- function setMemoSpriteVisible
-- @brief 메모 표시
-------------------------------------
function UI_RuneCard:setMemoSpriteVisible(visible)
    local res = 'card_rune_memo.png'
    local lua_name = 'memoSprite'
    self:setSpriteVisible(lua_name, res, visible)
end


-------------------------------------
-- function refresh_equip
-- @brief 장착 갱신
-------------------------------------
function UI_RuneCard:refresh_equip()
	local is_equip = (self.m_runeData['owner_doid'] ~= nil)
	self:setEquipSpriteVisible(is_equip)
end

-------------------------------------
-- function setEquipSpriteVisible
-- @brief 장착 표시
-------------------------------------
function UI_RuneCard:setEquipSpriteVisible(visible)
    local res = 'card_rune_equipment.png'
    local lua_name = 'equipmentSprite'
    self:setSpriteVisible(lua_name, res, visible)
end

-------------------------------------
-- function setNewSpriteVisible
-- @brief 신규 룬 표시
-- @external call
-------------------------------------
function UI_RuneCard:setNewSpriteVisible(visible)
    local res = 'card_cha_new.png'
    local lua_name = 'newSprite'
    self:setSpriteVisible(lua_name, res, visible)
end

-------------------------------------
-- function setHighlightSpriteVisible
-- @brief highlight 표시
-- @external call
-------------------------------------
function UI_RuneCard:setHighlightSpriteVisible(visible)
    local res = 'card_cha_frame_select.png'
    local lua_name = 'selectSprite'

    if self.vars[lua_name] then
        self.vars[lua_name]:setVisible(visible)
    elseif (visible) then
        self:makeSprite(lua_name, res)
        -- 깜빡임 액션
        self.vars[lua_name]:runAction(cca.flash())
    end
end

-------------------------------------
-- function setCheckSpriteVisible
-- @brief 카드 체크 표시
-- @external call
-------------------------------------
function UI_RuneCard:setCheckSpriteVisible(visible)
    local res = 'card_cha_frame_check.png'
    local lua_name = 'checkSprite'
    self:setSpriteVisible(lua_name, res, visible)
end

-------------------------------------
-- function setShadowSpriteVisible
-- @brief 카드 음영 표시
-------------------------------------
function UI_RuneCard:setShadowSpriteVisible(visible)
    local res = 'card_cha_frame_disable.png'
    local lua_name = 'disableSprite'
    self:setSpriteVisible(lua_name, res, visible)
end

-------------------------------------
-- function setBtnEnabled
-- @brief 버튼을 막는다
-------------------------------------
function UI_RuneCard:setBtnEnabled(able)
	self.vars['clickBtn']:setEnabled(able)
end

-------------------------------------
-- function setCloseInfoCallback
-- @brief UI_ItemInfoPopup 닫을 때 불리는 callback function
-------------------------------------
function UI_RuneCard:setCloseInfoCallback(callback)
    self.m_closeInfoCallback = callback
end

-------------------------------------
-- function press_clickBtn
-------------------------------------
function UI_RuneCard:press_clickBtn()
    local item_id = self.m_itemID
    local count = 1
	local t_rune_data = self.m_runeData

    local param = {self.m_runeData:getObjectId()}

    local ui = UI_ItemInfoPopup(item_id, count, t_rune_data)

    -- UI_ItemInfoPopup이 닫힐 때 불리는 callback function
    ui:setCloseCB(function() 
        -- UI_ItemInfoPopup에서 잠금처리 될 경우 UI_RuneCard에도 반영
        self.m_runeData:setLock(ui:isRuneLock())
        self:refresh_lock()
        self:refresh_memo()

        if self.m_closeInfoCallback then
            self.m_closeInfoCallback()
        end
    end)

    self.m_infoUI = ui
end
