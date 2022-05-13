local PARENT = UI_Card

--[[ 
# card_char.ui 일람
    newSprite
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
    checkBoxSprite1
    checkBoxSprite2
    itemCountLabel

    levelNode
	reinforceNode
    masteryNode
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
        m_dragonData = '',

        m_attrBgRes = 'string',
        m_charIconRes = 'string',
        m_attrIconRes = 'string',
		m_reinforceIconRes = 'string',
        m_masteryIconRes = 'string',
        m_starIconRes = 'string',
        m_charFrameRes = 'string',
        m_charLevelNumber = 'number',

        m_tag = '',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_CharacterCard:init(t_dragon_data)
    self.ui_res = 'card_char.ui'
    self:getUIInfo()

    self.m_dragonData = t_dragon_data

    -- 버튼 생성
    self:makeClickBtn()

    -- 드래곤 정보 생성
    self:refreshDragonInfo()
end

-------------------------------------
-- function refreshDragonInfo
-------------------------------------
function UI_CharacterCard:refreshDragonInfo()
    local t_dragon_data = self.m_dragonData

    if (not t_dragon_data) then
        return
    end

    if (not t_dragon_data['did']) or (t_dragon_data['did'] == 0) then
        return
    end

    local did = t_dragon_data['did']
    local attr = t_dragon_data:getAttr()

    -- 속성 따른 배경 이미지
    self:makeBg(attr)

    -- 드래곤 아이콘
    self:makeDragonIcon()

    -- 카드 프레임
    self:makeFrame()

    -- 신화 카드 프레임
    self:makeMythFrame()

    -- 리더 여부
    self:refresh_LeaderIcon()

    -- 속성 아이콘 생성
    self:makeAttrIcon(attr)

    -- 등급 아이콘 생성
    self:refresh_gradeIcon()

	-- 강화 아이콘 생성
	self:refresh_reinforceIcon()

    -- 특성 아이콘 생성
    self:refresh_masteryIcon()

    -- 레벨 지정
    self:setLevelText()
   
    do -- 드래곤들의 덱설정 여부 데이터 갱신
        if t_dragon_data and t_dragon_data['id'] then
            local doid = t_dragon_data['id']
            local deck_name = g_deckData:getSelectedDeckName()
            local is_multi_deck, multi_deck_mgr = CheckMultiDeckWithName(deck_name)

            -- 멀티덱 예외처리
            if (is_multi_deck) then
                local is_setted, num = multi_deck_mgr:isSettedDragon(doid)
                self:setTeamReadySpriteVisible(is_setted, num)
            else
                local is_setted = (g_deckData:isSettedDragon(doid) ~= false)
                self:setReadySpriteVisible(is_setted)
            end
        end
    end

    -- 잠금 표시
    self:refresh_lock()
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
end

-------------------------------------
-- function makeBg
-------------------------------------
function UI_CharacterCard:makeBg(attr)
    local res = 'card_cha_bg_' .. tostring(attr) .. '.png'
    if (self.m_attrBgRes == res) then
        return
    end
    self.m_attrBgRes = res
    self:makeSprite('bgNode', res)
end

-------------------------------------
-- function makeDragonIcon
-- @brief 드래곤 아이콘 생성
-------------------------------------
function UI_CharacterCard:makeDragonIcon()
    local res = self.m_dragonData:getIconRes()
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
-- function makeMythFrame
-- @brief 프레임 생성
-------------------------------------
function UI_CharacterCard:makeMythFrame(res)
    local res = 'myth_grade_frame.png'
    if (self.m_charFrameRes == res) then
        return
    end
    self.m_charFrameRes = res
    self:makeSprite('mythSprite', res)
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
-- function refresh_reinforceIcon
-- @brief 강화 아이콘
-------------------------------------
function UI_CharacterCard:refresh_reinforceIcon()
    local rlv = self.m_dragonData:getRlv()

    -- 강화 단계가 0이더라도 특성 레벨이 1 이상이면 아이콘 출력
    local mastery_lv = self.m_dragonData:getMasteryLevel()
	if (rlv == 0) and (mastery_lv == 0)  then
		return
	end
	local res = string.format('card_cha_reinforce_%d.png', rlv)
    if (self.m_reinforceIconRes == res) then
        return
    end
    self.m_reinforceIconRes = res
    self:makeSprite('reinforceNode', res)
end

-------------------------------------
-- function refresh_masteryIcon
-- @brief 특성 아이콘
-------------------------------------
function UI_CharacterCard:refresh_masteryIcon()
    local mastery_level = self.m_dragonData:getMasteryLevel()
	if (mastery_level == 0) then
		return
	end
	local res = string.format('card_cha_mastery_%.2d.png', mastery_level)
    if (self.m_masteryIconRes == res) then
        return
    end
    self.m_masteryIconRes = res
    self:makeSprite('masteryNode', res)
end


-------------------------------------
-- function setRunesVisible
-- @brief 장착한 룬
-------------------------------------
function UI_CharacterCard:setRunesVisible(is_visible)
    local vars = self.vars
    local rune_list = self.m_dragonData:getRuneObjectList()

    local function findRuneByIndex(list, index)
        for _, data in pairs(list) do
            if data:getSlot() == index then
                return data
            end
        end

        return nil
    end

    for i = 1, 6 do
        local rune = findRuneByIndex(rune_list, i)
        local res

        if rune then
            res = rune:getRuneRes()
        else
            res = 'res/ui/icons/rune/rune_slot_010' .. i .. '.png'
        end        

        self:setSpriteVisible('runeNode' .. i, res, is_visible, true)

        if (is_visible 
                and rune 
                and self.vars['runeNode' .. i])then
            self.vars['runeNode' .. i]:setScale(0.4)
        end
    end
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

    self:setNumberText(level, false)
end

-------------------------------------
-- function setCountText
-- @brief 수량 텍스트 지정
-------------------------------------
function UI_CharacterCard:setCountText(cnt)
    local cnt = tonumber(cnt)
    -- 1 이하는 표시 X
    if (not cnt or cnt <= 1) then
        return
    end
    local vars = self.vars

     -- 폰트 지정
    local font = Translate:getFontPath()

    -- label 생성
    local width = vars['clickBtn']:getContentSize()['width']
    local label = cc.Label:createWithTTF(comma_value(cnt), font, 30, 0)
    label:setAlignment(cc.TEXT_ALIGNMENT_RIGHT, cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
    label:setAnchorPoint(cc.p(1, 0))
    label:setPosition(145, 20)
    label:enableOutline(cc.c4b(0, 0, 0, 255), 3)

    local lua_name = 'itemCountLabel'
    if vars[lua_name] then
        vars[lua_name]:removeFromParent()
        vars[lua_name] = nil
    end

    vars['clickBtn']:addChild(label, 99)
    self:setCardInfo(lua_name, label)
    vars[lua_name] = label
end

-------------------------------------
-- function refresh_lock
-- @brief 잠금 갱신
-------------------------------------
function UI_CharacterCard:refresh_lock()
	local t_dragon_data = self.m_dragonData
	local is_lock = t_dragon_data:getLock()
	self:setLockSpriteVisible(is_lock)
end

-------------------------------------
-- function refresh_LeaderIcon
-- @brief 리더 아이콘 갱신
-------------------------------------
function UI_CharacterCard:refresh_LeaderIcon()
    local t_dragon_data = self.m_dragonData
	local is_leader = t_dragon_data:isLeader()
	self:setLeaderSpriteVisible(is_leader)
end

-- @ visible 관리

-------------------------------------
-- function setLockSpriteVisible
-- @brief 잠금 표시
-------------------------------------
function UI_CharacterCard:setLockSpriteVisible(visible)
    local res = 'card_cha_icon_lock.png'
    local lua_name = 'lockSprite'
    self:setSpriteVisible(lua_name, res, visible)
end

-------------------------------------
-- function setLeaderSpriteVisible
-- @brief 리더 표시
-------------------------------------
function UI_CharacterCard:setLeaderSpriteVisible(visible)
    local res = 'card_cha_icon_leader.png'
    local lua_name = 'leaderSprite'
    self:setSpriteVisible(lua_name, res, visible)
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
-- function setLeaderIconSpriteVisible
-- @brief 리더 표시
-- @brief spriteframe에 없는 아이콘이므로, 이 아이콘만 생성함
-------------------------------------
function UI_CharacterCard:setLeaderIconSpriteVisible(visible)
    -- 리더 아이콘
    local res = 'res/ui/frames/leader_0101.png'
    local leader_icon = IconHelper:getIcon(res)
    
    -- 리더 라벨
    local leader_label = cc.Label:createWithTTF(Str('리더'), 'res/font/common_font_01.ttf', 24, 0)
    leader_label:setColor(cc.c3b(187, 255, 2))
    leader_label:setPosition(35, 15)
    
    leader_icon:addChild(leader_label)
    leader_icon:setPosition(30, 60)
    
    self.vars['clickBtn']:addChild(leader_icon, 99)
end

-------------------------------------
-- function setEventIllusionVisible
-- @brief 환상 드래곤 표시(토큰, 점수), 아이템 카드에 사용
-- @brief spriteframe에 없는 아이콘이므로, 이 아이콘만 생성함
-------------------------------------
function UI_CharacterCard:setEventIllusionVisible(visible, is_bonus)
    local lua_name = 'eventDeungeonVisual'
    local res = 'res/ui/a2d/event_dungeon/event_dungeon.vrp'
    local ani = 'idle'
    if (is_bonus) then
        ani = 'idle_bonus'
    end
    local animator = self:setAnimatorVisible_IgnoreLowMode(lua_name, res, ani, visible)
    animator:setPosition(44, 40)
    animator:setScale(0.5)
end

-------------------------------------
-- function setEventIllusionVisibleForDeck
-- @brief 환상 드래곤 표시(토큰, 점수), 덱에 세팅
-- @brief spriteframe에 없는 아이콘이므로, 이 아이콘만 생성함
-------------------------------------
function UI_CharacterCard:setEventIllusionVisibleForDeck(visible, is_bonus)
    local lua_name = 'eventDeungeonVisual'
    local res = 'res/ui/a2d/event_dungeon/event_dungeon.vrp'
    local ani = 'idle'
    if (is_bonus) then
        ani = 'idle_bonus'
    end
    local animator = self:setAnimatorVisible_IgnoreLowMode(lua_name, res, ani, visible)
    animator:setPosition(78, 78)
    animator:setScale(0.5)
end

-------------------------------------
-- function setEventIllusionFrameVisible
-- @brief 이벤트 표시
-- @brief spriteframe에 없는 아이콘이므로, 이 아이콘만 생성함
-------------------------------------
function UI_CharacterCard:setEventIllusionFrameVisible(visible)
    local lua_name = 'eventDeungeonFrameVisual'
    local res = 'res/ui/a2d/event_dungeon/event_dungeon.vrp'
    local ani = 'card_frame'
    
    local animator_frame = self:setAnimatorVisible_IgnoreLowMode(lua_name, res, ani, visible)
    animator_frame:setScale(1.4)
end


-------------------------------------
-- function setTeamReadySpriteVisible
-- @brief 출전중 표시 (클랜던전 전용 - 1,2 공격대)
-------------------------------------
function UI_CharacterCard:setTeamReadySpriteVisible(visible, num)
    if (not num) then
        return
    end
    local lua_name = 'inuseSprite'
    -- 1, 2 공격대 리소스를 같이쓰므로 항상 재생성 
    if (visible == true) and (self.vars[lua_name]) then
        self.vars[lua_name]:setVisible(false)
        self.vars[lua_name] = nil
    end

    local res = string.format('card_cha_icon_inuse_team_%d.png', num)
    self:setSpriteVisible(lua_name, res, visible)
end

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
-- function setMythSpriteVisible
-- @brief 신화마크 표시
-------------------------------------
function UI_CharacterCard:setMythSpriteVisible(visible)
    local res = 'myth_grade_frame.png'
    local lua_name = 'mythSprite'
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
-- @brief 진화/승급/스킬강화 가능한 드래곤 알림
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
        self.vars[lua_name]:runAction(cca.flash())
    end
end

-------------------------------------
-- function setHighlightSpriteVisibleWithNoAction
-- @brief highlight 표시
-- @external call
-------------------------------------
function UI_CharacterCard:setHighlightSpriteVisibleWithNoAction(visible)
    local res = 'card_cha_frame_select.png'
    local lua_name = 'selectSprite'

    if self.vars[lua_name] then
        self.vars[lua_name]:setVisible(visible)
    elseif (visible) then
        self:makeSprite(lua_name, res)
    end
end

-------------------------------------
-- function setNewSpriteVisible
-- @brief 신규 드래곤 표시
-- @external call
-------------------------------------
function UI_CharacterCard:setNewSpriteVisible(visible)
    local res = 'card_cha_new.png'
    local lua_name = 'newSprite'
    self:setSpriteVisible(lua_name, res, visible)
end

-------------------------------------
-- function setTeamBonusCheckBoxSpriteVisible
-- @brief 보유 드래곤 체크 박스 표시 (팀 보너스 UI에 사용)
-------------------------------------
function UI_CharacterCard:setTeamBonusCheckBoxSpriteVisible(visible)
    local res = 'card_check_0101.png'
    local lua_name = 'checkBoxSprite1'
    self:setSpriteVisible(lua_name, res, visible)
end

-------------------------------------
-- function setTeamBonusCheckSpriteVisible
-- @brief 보유 드래곤 체크 표시 (팀 보너스 UI에 사용)
-------------------------------------
function UI_CharacterCard:setTeamBonusCheckSpriteVisible(visible)
    local res = 'card_check_0102.png'
    local lua_name = 'checkBoxSprite2'
    self:setSpriteVisible(lua_name, res, visible)
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
-- function setClanAttrSynastry
-------------------------------------
function UI_CharacterCard:setClanAttrSynastry(attr_synastry, attr)
    local lua_name = 'clanAttrVisual'
    local res = 'res/ui/a2d/clan_raid_attr_info/clan_raid_attr_info.vrp'
    local ani = 'clan_raid_attr_info_01'
    local visible = (attr_synastry == 1)
    local attr_map = getAttrOrderMap()

    if (attr_synastry ~= 1) then
        return
    end

    if (attr_map[attr]) then
        ani = 'clan_raid_attr_info_0' ..  attr_map[attr]
    end

    self:setAnimatorVisible_IgnoreLowMode(lua_name, res, ani, visible)
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
    local animator = self:setAnimatorVisible(lua_name, res, ani, visible)
    animator:setIgnoreLowEndMode(true) -- 저사양 모드 무시
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
function UI_DragonCard(t_dragon_data, struct_user_info, is_tooltop, click_func)
    if t_dragon_data and (not t_dragon_data.m_objectType) then
        t_dragon_data = StructDragonObject(t_dragon_data)
    end

    local ui = UI_CharacterCard(t_dragon_data)
    local did = t_dragon_data['did']
    local rarity = TableDragon:getValue(did, 'rarity')

    local function func()
        local doid = t_dragon_data['id']
        if doid and (doid ~= '') then
            UI_SimpleDragonInfoPopup(t_dragon_data)
        end
    end

    if (click_func) then
        func = click_func
    end
   
    local function tap_func()
        if (is_tooltop) then
            local str = getDragonToolTipDesc(t_dragon_data['id'])
            local tool_tip = UI_Tooltip_Skill(70, -145, str)

            -- 자동 위치 지정
            tool_tip:autoPositioning(ui.vars['clickBtn'])
        end
    end
    ui.vars['clickBtn']:registerScriptPressHandler(func)
    ui.vars['clickBtn']:registerScriptTapHandler(tap_func)
    
    -- 신화 드래곤 전용 테두리
    local isMythDragon = (rarity == 'myth')
    ui:setMythSpriteVisible(isMythDragon)

    -- 친구 드래곤일 경우 친구 마크 추가
    local doid = t_dragon_data['id']
    if (doid) then
        local is_friend_dragon = g_friendData:checkFriendDragonFromDoid(doid)
        ui:setFriendSpriteVisible(is_friend_dragon)
    end
    
    -- 클릭시 유저 상세 정보 팝업 출력 하는 경우
	-- @mskim 18.1.3 사용하는 곳이 없음!
    if (struct_user_info) then
        ui.vars['clickBtn']:registerScriptTapHandler(function() UI_UserInfoMini:open(struct_user_info) end)
    end

    return ui
end

-------------------------------------
-- function getDragonToolTipDesc
-------------------------------------
function getDragonToolTipDesc(item_id)

    local table_item = TABLE:get('item')
    local t_item = table_item[item_id]
    -- @delete_rune
    if (not t_item) then
        return '{@SKILL_NAME}none'
    end
    local desc = t_item['t_desc']

    -- 설정된 별도의 이름이 있으면 우선 사용
    local name = t_item['t_name']

    local str = Str('{@SKILL_NAME}{1}\n{@DEFAULT}{2}', Str(name), Str(desc))
    return str
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
        local sprite = cc.Sprite:createWithSpriteFrameName('card_cha_frame_disable.png')
        sprite:setDockPoint(CENTER_POINT)
        sprite:setAnchorPoint(CENTER_POINT)
        sprite:setOpacity(150)
        ui.vars['clickBtn']:addChild(sprite, zorder)

        local cool_time = friend_info:getDragonUseCoolText()
        local label = cc.Label:createWithTTF('', Translate:getFontPath(), 25, 2, cc.size(140, 60), cc.TEXT_ALIGNMENT_CENTER, cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
        label:setDockPoint(CENTER_POINT)
        label:setAnchorPoint(CENTER_POINT)
        label:setPosition(0, 0)
        label:setString(cool_time)
        ui.vars['clickBtn']:addChild(label, zorder)
    end

    -- 친구 닉네임 추가 - 하단 중앙
    do
        local label = cc.Label:createWithTTF('', Translate:getFontPath(), 25, 2, cc.size(140, 30), cc.TEXT_ALIGNMENT_CENTER, cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
        label:setDockPoint(cc.p(0.5, 0.0))
        label:setAnchorPoint(cc.p(0.5, 1.0))
        label:setPosition(0, 0)
        label:setString(friend_info:getNickText())
        ui.vars['clickBtn']:addChild(label, 5)
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