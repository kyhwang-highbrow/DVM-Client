local PARENT = ITableViewCell:getCloneClass()

local CARD_UI = nil
--[[ 
# card_char.ui 일람
    bookRewardVisual    
    notiSprite
    arrowVisual
    selectSprite
    disableSprite
    checkSprite
    expSprite
    friendSprite
    leaderSprite
    lockSprite
    levelNode
    starNode
    attrNode
    inuseSprite
    frameNode
    chaNode
    bgNode
]]

-------------------------------------
-- class UI_CharacterCard
-------------------------------------
UI_CharacterCard = class(PARENT, {
        root = '',
        vars = '',

        m_dragonData = '',

        m_clickBtnRes = 'string',
        m_charIconRes = 'string',
        m_attrIconRes = 'string',
        m_starIconRes = 'string',
        m_charFrameRes = 'string',
        m_charLevelNumber = 'number',
        m_charEclvNumber = 'number',
        m_attrSynastry = 'Animator', -- 속성 상성 이펙트

        m_bCheckVisible = 'boolean',

        m_tag = '',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_CharacterCard:init(t_dragon_data)
    if (CARD_UI == nil) then
        self:getUIInfo('card_char.ui')
    end

    cc.SpriteFrameCache:getInstance():addSpriteFrames('res/ui/a2d/card/card.plist')

    self.root = cc.Menu:create()
    self.root:setNormalSize(150, 150)
    self.root:setDockPoint(CENTER_POINT)
    self.root:setAnchorPoint(CENTER_POINT)
    self.root:setPosition(0, 0)

    self.vars = {}
    self.m_dragonData = t_dragon_data
    self.m_bCheckVisible = false

    self:refreshDragonInfo()
end

-------------------------------------
-- function getUIInfo
-------------------------------------
function UI_CharacterCard:getUIInfo(res)
    CARD_UI = {}
    local ui = UI()
    local vars = ui:load_keepZOrder(res)
    
    local pos_x, pos_y, width, height
    local t_data

    for lua_name, node in pairs(vars) do
        pos_x, pos_y = node:getPosition()

        t_data = {
            ['pos'] = {['x'] = pos_x, ['y'] = pos_y},
            ['anchor'] = node:getAnchorPoint(),
            ['dock'] = node:getDockPoint(),
            ['scale'] = node:getScale(),
            ['z_order'] = node:getLocalZOrder(),
            ['lua_name'] = lua_name,
        }
        CARD_UI[lua_name] = t_data
    end
end

-------------------------------------
-- local function setCardInfo
-------------------------------------
local function setCardInfo(lua_name, node)
    local t_info = CARD_UI[lua_name]
    --cclog(lua_name, t_info['z_order'])
    
    if (not t_info) then
        return
    end

    node:setAnchorPoint(t_info['anchor'])
    node:setDockPoint(t_info['dock'])
    
    node:setPosition(t_info['pos']['x'], t_info['pos']['y'])
    
    node:setScale(t_info['scale'])
    node:setLocalZOrder(t_info['z_order'])
end

-------------------------------------
-- function makeSprite
-- @brief 카드에 사용되는 sprite는 모두 이 로직으로 생성
-------------------------------------
function UI_CharacterCard:makeSprite(lua_name, res, no_use_frames)
    local vars = self.vars

    if vars[lua_name] then
        vars[lua_name]:removeFromParent()
        vars[lua_name] = nil
    end
    
    local sprite
    if (no_use_frames) then
        sprite = IconHelper:getIcon(res)
    else
        sprite = IconHelper:createWithSpriteFrameName(res)
    end
    vars['clickBtn']:addChild(sprite)
    setCardInfo(lua_name, sprite)
    vars[lua_name] = sprite
end

-------------------------------------
-- function setSpriteVisible
-- @brief visible 관리하고 없다면 만든다.
-------------------------------------
function UI_CharacterCard:setSpriteVisible(lua_name, res, visible)
    if self.vars[lua_name] then
        self.vars[lua_name]:setVisible(visible)
    elseif (visible) then
        self:makeSprite(lua_name, res)
    end
end

-------------------------------------
-- function makeAnimator
-- @brief animator사용
-- @comment 여기 res는 사실상 필요없는데...
-------------------------------------
function UI_CharacterCard:makeVisual(lua_name, res, ani)
    local vars = self.vars

    if vars[lua_name] then
        vars[lua_name]:removeFromParent()
        vars[lua_name] = nil
    end
    
    local animator = MakeAnimator(res)
    animator:changeAni(ani, true)
    vars['clickBtn']:addChild(animator.m_node)
    setCardInfo(lua_name, animator)
    vars[lua_name] = animator
end

-------------------------------------
-- function setAnimatorVisible
-- @brief visible 관리하고 없다면 만든다.
-------------------------------------
function UI_CharacterCard:setAnimatorVisible(lua_name, res, ani, visible)
    if self.vars[lua_name] then
        self.vars[lua_name]:setVisible(visible)
    elseif (visible) then
        self:makeVisual(lua_name, res, ani)
    end
end









-------------------------------------
-- function refreshDragonInfo
-------------------------------------
function UI_CharacterCard:refreshDragonInfo()
    if (not self.m_dragonData) then
        return
    end

    local t_dragon_data = self.m_dragonData
    local did = t_dragon_data['did']
    local attr = t_dragon_data:getAttr()
    local rarity = t_dragon_data:getRarity()

    -- 버튼 생성과 배경 이미지 생성
    self:makeClickBtn()

    -- 드래곤 아이콘
    self:makeDragonIcon(t_dragon_data)

    -- 속성 따른 배경 이미지
    self:makeBg(attr)

    -- 카드 프레임
    self:makeFrame()

    -- 리더 여부
    self:refresh_LeaderIcon()

    -- 속성 아이콘 생성
    self:makeAttrIcon(attr)

    -- 등급 아이콘 생성
    self:refresh_gradeIcon()

    -- 레벨 지정
    self:setLevelText()
   
    do -- 드래곤들의 덱설정 여부 데이터 갱신
        if t_dragon_data and t_dragon_data['id'] then
            local doid = t_dragon_data['id']
            local is_setted = (g_deckData:isSettedDragon(doid) ~= false)
            self:setReadySpriteVisible(is_setted)
        end
    end

    -- 잠금 표시
    self:refresh_Lock()
end

-------------------------------------
-- function makeClickBtn
-------------------------------------
function UI_CharacterCard:makeClickBtn()
    local btn = self.vars['clickBtn']

    if (not btn) then
        btn = cc.MenuItemImage:create()
        btn:setDockPoint(CENTER_POINT)
        btn:setAnchorPoint(CENTER_POINT)
        btn:setContentSize(150, 150)
    
        self.vars['clickBtn'] = UIC_Button(btn)
        self.root:addChild(btn, -1)
    end

    return btn
end

-------------------------------------
-- function makeBg
-------------------------------------
function UI_CharacterCard:makeBg(attr)
    local res = 'card_cha_bg_' .. attr .. '.png'
    if (self.m_clickBtnRes == res) then
        return
    end
    self.m_clickBtnRes = res
    self:makeSprite('bgNode', res)
end

-------------------------------------
-- function makeDragonIcon
-- @brief 드래곤 아이콘 생성
-------------------------------------
function UI_CharacterCard:makeDragonIcon(t_dragon_data)
    local res = t_dragon_data:getIconRes()
    if (self.m_charIconRes == res) then
        return
    end
    self.m_charIconRes = res
    self:makeSprite('chaNode', res, true) -- (lua_name, res, no_use_frames)
end

-------------------------------------
-- function makeFrame
-- @brief 프레임 생성
-------------------------------------
function UI_CharacterCard:makeFrame(res)
    local res = 'card_cha_frame.png'
    if (self.m_charFrameRes == res) then
        return
    end
    self.m_charFrameRes = res
    self:makeSprite('frameNode', res)
end

-------------------------------------
-- function refresh_LeaderIcon
-- @brief 리더 아이콘 갱신
-------------------------------------
function UI_CharacterCard:refresh_LeaderIcon()
    local t_dragon_data = self.m_dragonData
	local is_leader = t_dragon_data:isLeader()
	self:setLeaderSprit(is_leader)
end

-------------------------------------
-- function setLeaderSprit
-- @brief 리더 표시
-------------------------------------
function UI_CharacterCard:setLeaderSprit(visible)
    local res = 'card_cha_icon_leader.png'
    local lua_name = 'leaderSprite'
    self:setSpriteVisible(lua_name, res, visible)
end

-------------------------------------
-- function makeAttrIcon
-- @brief 속성 아이콘 생성
-------------------------------------
function UI_CharacterCard:makeAttrIcon(attr)
    local res = 'card_cha_attr_' .. attr .. '.png'
    if (self.m_attrIconRes == res) then
        return
    end
    self.m_attrIconRes = res
    self:makeSprite('attrNode', res)
end

-------------------------------------
-- function refresh_gradeIcon
-- @brief 등급 아이콘
-------------------------------------
function UI_CharacterCard:refresh_gradeIcon()
    local res = self.m_dragonData:getGradeRes()
    if (self.m_starIconRes == res) then
        return
    end
    self.m_starIconRes = res
    self:makeSprite('starNode', res)
end

-------------------------------------
-- function setLevelText
-- @brief 레벨 텍스트 지정
-------------------------------------
function UI_CharacterCard:setLevelText(level)
    local level = self.m_dragonData['lv']
    if (self.m_charLevelNumber == level) then
        return
    end
    self.m_charLevelNumber = level

    local vars = self.vars

    local lvSprite1 = vars['lvSprite1']
    local lvSprite2 = vars['lvSprite2']
    local lvSprite3 = vars['lvSprite3']

    if (not lvSprite1) then
        lvSprite1 = MakeAnimator('res/ui/a2d/card/card.vrp')
        lvSprite1:setDockPoint(CENTER_POINT)
        lvSprite1:setAnchorPoint(CENTER_POINT)
        self.vars['clickBtn']:addChild(lvSprite1.m_node, 5)
        vars['lvSprite1'] = lvSprite1
        lvSprite1:changeAni('digit_0')
    end

    if (not lvSprite2) then
        lvSprite2 = MakeAnimator('res/ui/a2d/card/card.vrp')
        lvSprite2:setDockPoint(CENTER_POINT)
        lvSprite2:setAnchorPoint(CENTER_POINT)
        self.vars['clickBtn']:addChild(lvSprite2.m_node, 5)
        vars['lvSprite2'] = lvSprite2
        lvSprite2:changeAni('digit_5')
    end

    if (not lvSprite3) then
        lvSprite3 = MakeAnimator('res/ui/a2d/card/card.vrp')
        lvSprite3:setDockPoint(CENTER_POINT)
        lvSprite3:setAnchorPoint(CENTER_POINT)
        self.vars['clickBtn']:addChild(lvSprite3.m_node, 5)
        vars['lvSprite3'] = lvSprite3
        lvSprite3:changeAni('digit_5')
    end

    local pos_x = -60
    local pos_y = -27
    local font_size = 20
    if (level <= 0) then
        lvSprite1:setVisible(false)
        lvSprite2:setVisible(false)
        lvSprite3:setVisible(false)
    elseif (level < 10) then
        lvSprite1:setVisible(true)
        lvSprite1:changeAni('digit_' .. level)
        lvSprite1:setPosition(pos_x + (font_size/2), pos_y)
        lvSprite2:setVisible(false)
        lvSprite3:setVisible(false)
    elseif (level < 100) then
        lvSprite1:setVisible(true)
        lvSprite1:changeAni('digit_' ..  math_floor(level / 10))
        lvSprite1:setPosition(pos_x + (font_size/2), pos_y)

        lvSprite2:setVisible(true)
        lvSprite2:changeAni('digit_' .. level % 10)
        lvSprite2:setPosition(pos_x + (font_size/2) + font_size, pos_y)
        lvSprite3:setVisible(false)
    else
        lvSprite1:setVisible(true)
        lvSprite1:changeAni('digit_' ..  math_floor(level / 100))
        lvSprite1:setPosition(pos_x + (font_size/2), pos_y)

        lvSprite2:setVisible(true)
        lvSprite2:changeAni('digit_' .. math_floor(level % 100 / 10))
        lvSprite2:setPosition(pos_x + (font_size/2) + font_size, pos_y)
        
        lvSprite3:setVisible(true)
        lvSprite3:changeAni('digit_' .. math_floor(level % 10))
        lvSprite3:setPosition(pos_x + (font_size/2) + font_size + font_size, pos_y)
    end
end

-------------------------------------
-- function setReadySpriteVisible
-- @brief 출전중 표시
-------------------------------------
function UI_CharacterCard:setReadySpriteVisible(visible)
    local res = 'card_cha_icon_inuse.png'
    local lua_name = 'inuseSprite'
    self:setSpriteVisible(lua_name, res, visible)
end

-------------------------------------
-- function setLockSprit
-- @brief 잠금 표시
-------------------------------------
function UI_CharacterCard:setLockSprit(visible)
    local res = 'card_cha_icon_lock.png'
    local lua_name = 'lockSprite'
    self:setSpriteVisible(lua_name, res, visible)
end

-------------------------------------
-- function refresh_Lock
-- @brief 잠금 갱신
-------------------------------------
function UI_CharacterCard:refresh_Lock()
	local t_dragon_data = self.m_dragonData
	local is_lock = t_dragon_data:getLock()
	self:setLockSprit(is_lock)
end


-- @ visible 관리

-------------------------------------
-- function setShadowSpriteVisible
-- @brief 카드 음영 표시
-------------------------------------
function UI_CharacterCard:setShadowSpriteVisible(visible)
    local res = 'card_cha_frame_disable.png'
    local lua_name = 'disableSprite'
    self:setSpriteVisible(lua_name, res, visible)
end

-------------------------------------
-- function setFriendSpriteVisible
-- @brief 친구마크 표시
-------------------------------------
function UI_CharacterCard:setFriendSpriteVisible(visible)
    local res = 'card_cha_icon_friend.png'
    local lua_name = 'friendSprite'
    self:setSpriteVisible(lua_name, res, visible)
end

-------------------------------------
-- function setCheckSpriteVisible
-- @brief 카드 체크 표시
-- @external call
-------------------------------------
function UI_CharacterCard:setCheckSpriteVisible(visible)
    local res = 'card_cha_frame_check.png'
    local lua_name = 'checkSprite'
    self:setSpriteVisible(lua_name, res, visible)
    
    self.m_bCheckVisible = visible
end

-------------------------------------
-- function setExpSpriteVisible
-- @brief 경험치 추가 표시
-- @external call
-------------------------------------
function UI_CharacterCard:setExpSpriteVisible(visible)
    local res = 'card_cha_icon_exp.png'
    local lua_name = 'expSprite'
    self:setSpriteVisible(lua_name, res, visible)
end

-------------------------------------
-- function setNotiSpriteVisible
-- @brief 신규 드래곤 표시
-- @external call
-------------------------------------
function UI_CharacterCard:setNotiSpriteVisible(visible)
    local res = 'card_cha_icon_noti.png'
    local lua_name = 'notiSprite'
    self:setSpriteVisible(lua_name, res, visible)
end

-------------------------------------
-- function setHighlightSpriteVisible
-- @brief highlight 표시
-- @external call
-------------------------------------
function UI_CharacterCard:setHighlightSpriteVisible(visible)
    local res = 'card_cha_frame_select.png'
    local lua_name = 'selectSprite'

    if self.vars[lua_name] then
        self.vars[lua_name]:setVisible(visible)
    elseif (visible) then
        self:makeSprite(lua_name, res)
        -- 깜빡임 액션
        sprite:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.FadeTo:create(0.5, 50), cc.FadeTo:create(0.5, 255))))
    end
end


-- @ Animator 사용

-------------------------------------
-- function setAttrSynastry
-- @brief 속성 상속 아이콘
-- @param type "advantage", "disadvantage", nil
-- @external call
-------------------------------------
function UI_CharacterCard:setAttrSynastry(attr_synastry)
    local lua_name = 'arrowVisual'
    local res = 'res/ui/a2d/card/card.vrp'
    local ani
    local visible = (attr_synastry ~= 0)

    if (attr_synastry == 1) then
        ani = 'attr_up'
    elseif (attr_synastry == -1) then
        ani = 'attr_down'
    end

    self:setAnimatorVisible(lua_name, res, ani, visible)
end

-------------------------------------
-- function setBookRewardVisual
-- @brief 도감 보상 표시
-- @external call
-------------------------------------
function UI_CharacterCard:setBookRewardVisual(visible)
    local lua_name = 'bookRewardVisual'
    local res = 'res/ui/a2d/card/card.vrp'
    local ani = 'book_reward'
    self:setAnimatorVisible(lua_name, res, ani, visible)
end

-------------------------------------
-- function setButtonEnabled
-- @brief
-- @external call
-------------------------------------
function UI_CharacterCard:setButtonEnabled(enable)
    if self.vars['clickBtn'] then
        self.vars['clickBtn']:setEnabled(enable)
    end
end



























-- @ create public func

-------------------------------------
-- function UI_DragonCard
-------------------------------------
function UI_DragonCard(t_dragon_data, struct_user_info)
    if t_dragon_data and (not t_dragon_data.m_objectType) then
        t_dragon_data = StructDragonObject(t_dragon_data)
    end

    local ui = UI_CharacterCard(t_dragon_data)
    local function func()
        local doid = t_dragon_data['id']
        if doid and (doid ~= '') then
            UI_SimpleDragonInfoPopup(t_dragon_data)
        end
    end
    ui.vars['clickBtn']:registerScriptPressHandler(func)

    -- 새로 획득한 드래곤 뱃지
    local is_new_dragon = t_dragon_data:isNewDragon()
    ui:setNotiSpriteVisible(is_new_dragon)

    -- 친구 드래곤일 경우 친구 마크 추가
    local is_friend_dragon = g_friendData:checkFriendDragonFromDoid(t_dragon_data['id'])
    ui:setFriendSpriteVisible(is_friend_dragon)

    -- 클릭시 유저 상세 정보 팝업 출력 하는 경우
    if (struct_user_info) then
        ui.vars['clickBtn']:registerScriptTapHandler(function() UI_UserInfoMini:open(struct_user_info) end)
    end

    return ui
end


-------------------------------------
-- function UI_FriendDragonCard
-------------------------------------
function UI_FriendDragonCard(t_dragon_data)
    if t_dragon_data and (not t_dragon_data.m_objectType) then
        t_dragon_data = StructDragonObject(t_dragon_data)
    end

    local ui = UI_CharacterCard(t_dragon_data)
    local function func()
        local doid = t_dragon_data['id']
        if doid and (doid ~= '') then
            UI_SimpleDragonInfoPopup(t_dragon_data)
        end
    end

    ui.vars['clickBtn']:registerScriptPressHandler(func)
    
    local doid = t_dragon_data['id']
    local friend_info = g_friendData:getFriendInfoFromDoid(doid)
    local zorder = 99

    -- 친구 마크 추가
    ui:setFriendSpriteVisible(true)
    
    local use_enable = g_friendData:checkUseEnableDragon(doid)

    -- 쿨타임 추가 - 중앙
    if (not use_enable) then
        local sprite = cc.Sprite:createWithSpriteFrameName('character_card_bg.png')
        sprite:setDockPoint(CENTER_POINT)
        sprite:setAnchorPoint(CENTER_POINT)
        sprite:setOpacity(150)
        ui.vars['clickBtn']:addChild(sprite, zorder)

        local cool_time = friend_info:getDragonUseCoolText()
        local label = cc.Label:createWithTTF('', 'res/font/common_font_01.ttf', 25, 2, cc.size(140, 60), cc.TEXT_ALIGNMENT_CENTER, cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
        label:setDockPoint(CENTER_POINT)
        label:setAnchorPoint(CENTER_POINT)
        label:setPosition(0, 0)
        label:setString(cool_time)
        ui.vars['clickBtn']:addChild(label, zorder)
    end

    -- 친구 닉네임 추가 - 하단 중앙
    do
        local label = cc.Label:createWithTTF('', 'res/font/common_font_01.ttf', 25, 2, cc.size(140, 30), cc.TEXT_ALIGNMENT_CENTER, cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
        label:setDockPoint(cc.p(0.5, 0.0))
        label:setAnchorPoint(cc.p(0.5, 1.0))
        label:setPosition(0, 0)
        label:setString(friend_info:getNickText())
        ui.vars['clickBtn']:addChild(label, 5)
    end
    
    return ui
end

------------------------------------
-- function UI_RelationCard
-- @brief 인연 포인트 카드
-------------------------------------
function UI_RelationCard(t_dragon_data)
    local ui = UI_CharacterCard(t_dragon_data)
    
    -- 프레임 변경
    do
        ui:makeFrame('character_card_frame_rp.png')
    end

    -- 인연포인트
    do
        local label = cc.Label:createWithTTF('', 'res/font/common_font_01.ttf', 40, 2, cc.size(100, 30), 2, 1)
        label:setDockPoint(CENTER_POINT)
        label:setAnchorPoint(CENTER_POINT)
        label:setPosition(15, -20)
        ui.vars['clickBtn']:addChild(label, 5)

        ui.vars['numberLabel'] = label
    end

    return ui
end

------------------------------------
-- function UI_BookDragonCard
-- @brief 도감 전용 카드
-------------------------------------
function UI_BookDragonCard(t_dragon)
	local did = t_dragon['did']
    local t_dragon_data = {}
	t_dragon_data['did'] = did
	t_dragon_data['evolution'] = t_dragon['evolution']
	t_dragon_data['grade'] = t_dragon['grade']

	local struct_data
	if (TableSlime:isSlimeID(did)) then
		t_dragon_data['slime_id'] = did
		struct_data = StructSlimeObject(t_dragon_data)
	else
		struct_data = StructDragonObject(t_dragon_data)
	end

    return UI_DragonCard(struct_data)
end

-------------------------------------
-- function MakeSimpleDragonCard
-------------------------------------
function MakeSimpleDragonCard(did, t_data)
    local t_dragon_data = {}
	t_dragon_data['did'] = did
    t_dragon_data['lv'] = nil
    t_dragon_data['evolution'] = 3
    t_dragon_data['grade'] = nil

    if t_data then
        for key,value in pairs(t_data) do
            t_dragon_data[key] = value
        end
    end

	local struct_data
	if (TableSlime:isSlimeID(did)) then
		t_dragon_data['slime_id'] = did
		struct_data = StructSlimeObject(t_dragon_data)
	else
		struct_data = StructDragonObject(t_dragon_data)
	end

    return UI_DragonCard(struct_data)
end

-------------------------------------
-- function MakeBirthDragonCard
-- @brief 태생 드래곤 카드
-------------------------------------
function MakeBirthDragonCard(did)
    local table_dragon = TableDragon()
    local t_dragon = table_dragon:get(did)
    
    local t_data = {}
    t_data['did'] = t_dragon['did']
    t_data['grade'] = t_dragon['birthgrade']
    local struct_dragon_object = StructDragonObject(t_data)

    local dragon_card = UI_DragonCard(struct_dragon_object)
    return dragon_card
end