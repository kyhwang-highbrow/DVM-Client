local PARENT = ITableViewCell:getCloneClass()

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
    cc.SpriteFrameCache:getInstance():addSpriteFrames('res/ui/a2d/character_card/character_card.plist')

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
-- function refreshDragonInfo
-------------------------------------
function UI_CharacterCard:refreshDragonInfo()
    if (not self.m_dragonData) then
        return
    end

    local t_dragon_data = self.m_dragonData
    local did = t_dragon_data['did']
    local attr = t_dragon_data:getAttr()
    local eclv = t_dragon_data:getEclv()
    local rarity = t_dragon_data:getRarity()

    do -- 속성 따른 배경 이미지(버튼)
        local res = 'character_card_bg_' .. attr .. '.png'
        self:makeClickBtn(res)
    end

    do -- 드래곤 아이콘
        self:makeDragonIcon(t_dragon_data, t_dragon)
    end

    do -- 리더 여부
        self:refresh_LeaderIcon()
    end
        
    do -- 속성 아이콘 생성
        local res = 'character_card_attr_' .. attr .. '.png'
        self:makeAttrIcon(res)
    end

    do -- 등급 아이콘 생성
        self:refresh_gradeIcon()
    end

    do -- 레벨 지정
        local lv = t_dragon_data['lv']
        self:setLevelText(lv)
    end    

    do -- 초월 지정
        local eclv = eclv
        self:setEclvText(eclv)
    end

    do -- 카드 프레임
        local res = 'character_card_frame_normal.png'
        self:makeFrame(res)
    end

    do -- 드래곤들의 덱설정 여부 데이터 갱신
        if t_dragon_data and t_dragon_data['id'] then
            local doid = t_dragon_data['id']
            local is_setted = (g_deckData:isSettedDragon(doid) ~= false)
            self:setReadySpriteVisible(is_setted)
        end
    end
end

-------------------------------------
-- function makeClickBtn
-------------------------------------
function UI_CharacterCard:makeClickBtn(res)
    if (self.m_clickBtnRes == res) then
        return
    end
    self.m_clickBtnRes = res

    local btn = self.vars['clickBtn']

    if (not btn) then
        btn = cc.MenuItemImage:create()
        btn:setDockPoint(CENTER_POINT)
        btn:setAnchorPoint(CENTER_POINT)
        self.vars['clickBtn'] = UIC_Button(btn)
        self.root:addChild(btn)
    end

    btn:setNormalSpriteFrame(cc.SpriteFrameCache:getInstance():getSpriteFrame(res))
    --btn:setNormalImage(cc.Sprite:create(res))
        
    return btn
end

-------------------------------------
-- function makeDragonIcon
-- @brief 드래곤 아이콘 생성
-------------------------------------
function UI_CharacterCard:makeDragonIcon(t_dragon_data, t_dragon)
    local res = t_dragon_data:getIconRes()
    if (self.m_charIconRes == res) then
        return
    end
    self.m_charIconRes = res

    local vars = self.vars

    if vars['charIcon'] then
        vars['charIcon']:removeFromParent()
    end
    
    local sprite = cc.Sprite:create(res)
    
    if (not sprite) then
        sprite = cc.Sprite:create('res/ui/icon/cha/developing.png')
    end
    sprite:setDockPoint(CENTER_POINT)
    sprite:setAnchorPoint(CENTER_POINT)
    self.vars['clickBtn']:addChild(sprite, 1)
    vars['charIcon'] = sprite
end

-------------------------------------
-- function refresh_LeaderIcon
-- @brief 리더 아이콘
-------------------------------------
function UI_CharacterCard:refresh_LeaderIcon()
    local vars = self.vars
    local t_dragon_data = self.m_dragonData

    local is_leader = t_dragon_data:isLeader()

    if is_leader then
        if vars['leaderIcon'] then
            vars['leaderIcon']:setVisible(true)
        else
            local sprite = cc.Sprite:createWithSpriteFrameName('character_card_leader_icon.png')
            sprite:setDockPoint(CENTER_POINT)
            sprite:setAnchorPoint(CENTER_POINT)
            self.vars['clickBtn']:addChild(sprite, 2)
            vars['leaderIcon'] = sprite
        end

    else
        if vars['leaderIcon'] then
            vars['leaderIcon']:setVisible(false)
        end
    end
end

-------------------------------------
-- function makeAttrIcon
-- @brief 속성 아이콘 생성
-------------------------------------
function UI_CharacterCard:makeAttrIcon(res)
    if (self.m_attrIconRes == res) then
        return
    end
    self.m_attrIconRes = res

    local vars = self.vars

    if vars['attrIcon'] then
        vars['attrIcon']:removeFromParent()
    end
    
    local sprite = cc.Sprite:createWithSpriteFrameName(res)
    sprite:setDockPoint(CENTER_POINT)
    sprite:setAnchorPoint(CENTER_POINT)
    sprite:setScale(1.1)
    sprite:setPosition(-54, 54)
    self.vars['clickBtn']:addChild(sprite, 3)
    vars['attrIcon'] = sprite
end

-------------------------------------
-- function refresh_gradeIcon
-- @brief 등급 아이콘
-------------------------------------
function UI_CharacterCard:refresh_gradeIcon()
    local t_dragon_data = self.m_dragonData

    local vars = self.vars

    local grade = (t_dragon_data['grade'] or 1)
	grade = tonumber(grade)

	local evolution = t_dragon_data['evolution']
	local color
	do
		if (evolution == 1) then
			if (TableDragon():isUnderling(t_dragon_data['did'])) then
				color = 'gray'
			elseif (t_dragon_data['m_objectType'] == 'slime') then
				color = 'gray'
			else
				color = 'yellow'
			end
		elseif (evolution == 2) then
			color = 'purple'
		elseif (evolution == 3) then
			color = 'red'
		end
	end

    local res = string.format('star_%s_01%02d.png', color, grade)

    if (self.m_starIconRes == res) then
        return
    end
    self.m_starIconRes = res

    if (grade <= 0) then
        return
    end

    if vars['starIcon'] then
        vars['starIcon']:removeFromParent()
        vars['starIcon'] = nil
    end
    
    local sprite = cc.Sprite:createWithSpriteFrameName(res)
    sprite:setDockPoint(CENTER_POINT)
    sprite:setAnchorPoint(CENTER_POINT)
    sprite:setPosition(0, -52)
    self.vars['clickBtn']:addChild(sprite, 4)
    vars['starIcon'] = sprite
end

-------------------------------------
-- function setLevelText
-- @brief 레벨 텍스트 지정
-------------------------------------
function UI_CharacterCard:setLevelText(level)
    if (self.m_charLevelNumber == level) then
        return
    end
    self.m_charLevelNumber = level

    local vars = self.vars

    local lvSprite1 = vars['lvSprite1']
    local lvSprite2 = vars['lvSprite2']
    local lvSprite3 = vars['lvSprite3']

    if (not lvSprite1) then
        lvSprite1 = MakeAnimator('res/ui/a2d/character_card/character_card.vrp')
        lvSprite1:setDockPoint(CENTER_POINT)
        lvSprite1:setAnchorPoint(CENTER_POINT)
        self.vars['clickBtn']:addChild(lvSprite1.m_node, 5)
        vars['lvSprite1'] = lvSprite1
        lvSprite1:changeAni('digit_0')
    end

    if (not lvSprite2) then
        lvSprite2 = MakeAnimator('res/ui/a2d/character_card/character_card.vrp')
        lvSprite2:setDockPoint(CENTER_POINT)
        lvSprite2:setAnchorPoint(CENTER_POINT)
        self.vars['clickBtn']:addChild(lvSprite2.m_node, 5)
        vars['lvSprite2'] = lvSprite2
        lvSprite2:changeAni('digit_5')
    end

    if (not lvSprite3) then
        lvSprite3 = MakeAnimator('res/ui/a2d/character_card/character_card.vrp')
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
-- function setEclvText
-- @brief 초월 텍스트 지정
-------------------------------------
function UI_CharacterCard:setEclvText(eclv)
    if (eclv == 0) then
        return
    end

    if (self.m_charEclvNumber == eclv) then
        return
    end
    self.m_charEclvNumber = eclv
    

    local vars = self.vars

    local pos_x = 60
    local pos_y = 40
    local font_size = 20

    local eclvSprite1 = vars['eclvSprite1']
    local eclvSprite2 = vars['eclvSprite2']

    if (not eclvSprite1) then
        eclvSprite1 = MakeAnimator('res/ui/a2d/character_card/character_card.vrp')
        eclvSprite1:setColor(cc.c3b(255, 225, 18))
        eclvSprite1:setDockPoint(CENTER_POINT)
        eclvSprite1:setAnchorPoint(CENTER_POINT)
        self.vars['clickBtn']:addChild(eclvSprite1.m_node, 5)
        vars['eclvSprite1'] = eclvSprite1
        eclvSprite1:changeAni('digit_0')

        do -- 플러스 아이콘 추가
            local digit_plus = MakeAnimator('res/ui/a2d/character_card/character_card.vrp')
            digit_plus:setColor(cc.c3b(255, 225, 18))
            digit_plus:setDockPoint(CENTER_POINT)
            digit_plus:setAnchorPoint(CENTER_POINT)
            digit_plus:changeAni('digit_plus')
            eclvSprite1:addChild(digit_plus.m_node)
            digit_plus:setPositionX(-font_size)
        end
        
    end

    if (not eclvSprite2) then
        eclvSprite2 = MakeAnimator('res/ui/a2d/character_card/character_card.vrp')
        eclvSprite2:setColor(cc.c3b(255, 225, 18))
        eclvSprite2:setDockPoint(CENTER_POINT)
        eclvSprite2:setAnchorPoint(CENTER_POINT)
        self.vars['clickBtn']:addChild(eclvSprite2.m_node, 5)
        vars['eclvSprite2'] = eclvSprite2
        eclvSprite2:changeAni('digit_5')
    end

    if (eclv < 10) then
        eclvSprite1:setVisible(true)
        eclvSprite1:changeAni('digit_' .. eclv)
        eclvSprite1:setPosition(pos_x - (font_size/2), pos_y)
        eclvSprite2:setVisible(false)
    else
        eclvSprite1:setVisible(true)
        eclvSprite1:changeAni('digit_' ..  math_floor(eclv / 10))
        eclvSprite1:setPosition(pos_x - ((font_size/2) + font_size), pos_y)

        eclvSprite2:setVisible(true)
        eclvSprite2:changeAni('digit_' .. eclv % 10)
        eclvSprite2:setPosition(pos_x - (font_size/2), pos_y)
    end
end

-------------------------------------
-- function setShadowSpriteVisible
-- @brief 카드 음영 표시
-------------------------------------
function UI_CharacterCard:setShadowSpriteVisible(visible)
    if self.vars['shadowSprite'] then
        self.vars['shadowSprite']:setVisible(visible)
    elseif (visible) then
        local sprite = cc.Sprite:createWithSpriteFrameName('character_card_bg.png')
        sprite:setDockPoint(CENTER_POINT)
        sprite:setAnchorPoint(CENTER_POINT)
        sprite:setOpacity(200)
        self.vars['clickBtn']:addChild(sprite, 10)
        self.vars['shadowSprite'] = sprite
    end
end

-------------------------------------
-- function makeFrame
-- @brief 프레임 생성
-------------------------------------
function UI_CharacterCard:makeFrame(res)
    if (self.m_charFrameRes == res) then
        return
    end
    self.m_charFrameRes = res

    local vars = self.vars

    if vars['charFrame'] then
        vars['charFrame']:removeFromParent()
    end
    
    local sprite = cc.Sprite:createWithSpriteFrameName(res)
    sprite:setDockPoint(CENTER_POINT)
    sprite:setAnchorPoint(CENTER_POINT)
    self.vars['clickBtn']:addChild(sprite, 11)
    vars['charFrame'] = sprite
end

-------------------------------------
-- function setReadySpriteVisible
-- @brief 출전준비 표시
-------------------------------------
function UI_CharacterCard:setReadySpriteVisible(visible)
    if self.vars['readySprite'] then
        self.vars['readySprite']:setVisible(visible)
    elseif (visible) then
        local sprite = cc.Sprite:createWithSpriteFrameName('character_card_frame_ready.png')
        sprite:setDockPoint(CENTER_POINT)
        sprite:setAnchorPoint(CENTER_POINT)
        self.vars['clickBtn']:addChild(sprite, 12)
        self.vars['readySprite'] = sprite
    end
end

-------------------------------------
-- function setFriendSpriteVisible
-- @brief 친구마크 표시
-------------------------------------
function UI_CharacterCard:setFriendSpriteVisible(visible)
    if self.vars['friendSprite'] then
        self.vars['friendSprite']:setVisible(visible)
    elseif (visible) then
        local sprite = cc.Sprite:createWithSpriteFrameName('character_card_friend.png')
        sprite:setDockPoint(CENTER_POINT)
        sprite:setAnchorPoint(CENTER_POINT)
        self.vars['clickBtn']:addChild(sprite, 12)
        self.vars['friendSprite'] = sprite
    end
end

-------------------------------------
-- function setSkillSpriteVisible
-- @brief 승급 재료 스킬상승 아이콘 표시
-------------------------------------
function UI_CharacterCard:setSkillSpriteVisible(visible)
    if self.vars['skillSprite'] then
        self.vars['skillSprite']:setVisible(visible)
    elseif (visible) then
        local sprite = cc.Sprite:createWithSpriteFrameName('character_card_frame_skill.png')
        sprite:setDockPoint(CENTER_POINT)
        sprite:setAnchorPoint(CENTER_POINT)
        self.vars['clickBtn']:addChild(sprite, 13)
        self.vars['skillSprite'] = sprite
    end
end

-------------------------------------
-- function setAttrSynastry
-- @brief 속성 상속 아이콘
-- @param type "advantage", "disadvantage", nil
-------------------------------------
function UI_CharacterCard:setAttrSynastry(attr_synastry)
    local animator = self.vars['attrSynastry']
    
    if (not animator) then
        animator = MakeAnimator('res/ui/a2d/character_card/character_card.vrp')
        animator:setDockPoint(CENTER_POINT)
        animator:setAnchorPoint(CENTER_POINT)
        animator:setPosition(-15, 46)
        self.vars['clickBtn']:addChild(animator.m_node, 14)
        self.vars['attrSynastry'] = animator
    end

    if (attr_synastry == 0) then
        animator:setVisible(false)
    else
        animator:setVisible(true)

        if (attr_synastry == 1) then
            animator:changeAni('attr_up', true)

        elseif (attr_synastry == -1) then
            animator:changeAni('attr_down', true)
        end
    end
end

-------------------------------------
-- function setCheckSpriteVisible
-- @brief 카드 체크 표시
-------------------------------------
function UI_CharacterCard:setCheckSpriteVisible(visible)
    if self.vars['checkSprite'] then
        self.vars['checkSprite']:setVisible(visible)
    elseif (visible) then
        local sprite = cc.Sprite:create('res/ui/frame/check.png')
        sprite:setDockPoint(CENTER_POINT)
        sprite:setAnchorPoint(CENTER_POINT)
        self.vars['clickBtn']:addChild(sprite, 15)
        self.vars['checkSprite'] = sprite
    end

    self.m_bCheckVisible = visible
end

-------------------------------------
-- function setMaxLvSpriteVisible
-- @brief max lv 달성 후 보상 완료 표시
-------------------------------------
function UI_CharacterCard:setMaxLvSpriteVisible(visible)
    if self.vars['maxLvSprite'] then
        self.vars['maxLvSprite']:setVisible(visible)
    elseif (visible) then
        local sprite = cc.Sprite:create('res/ui/icon/item/badge.png')
        sprite:setDockPoint(CENTER_POINT)
        sprite:setAnchorPoint(CENTER_POINT)
		sprite:setScale(0.6)
		sprite:setPositionX(-50)
        self.vars['clickBtn']:addChild(sprite, 16)
        self.vars['maxLvSprite'] = sprite
	end
end

-------------------------------------
-- function setHighlightSpriteVisible
-- @brief highlight 표시
-------------------------------------
function UI_CharacterCard:setHighlightSpriteVisible(visible)
    if self.vars['highlightSprite'] then
        self.vars['highlightSprite']:setVisible(visible)
    elseif (visible) then
        local sprite = cc.Sprite:create('res/ui/frame/dragon_select_frame.png')
        sprite:setDockPoint(CENTER_POINT)
        sprite:setAnchorPoint(CENTER_POINT)
        self.vars['clickBtn']:addChild(sprite, 17)
        self.vars['highlightSprite'] = sprite

		-- 깜빡임 액션
        sprite:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.FadeTo:create(0.5, 50), cc.FadeTo:create(0.5, 255))))
    end
end

-------------------------------------
-- function setButtonEnabled
-- @brief
-------------------------------------
function UI_CharacterCard:setButtonEnabled(enable)
    if self.vars['clickBtn'] then
        self.vars['clickBtn']:setEnabled(enable)
    end
end


function UI_DragonCard(t_dragon_data)
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

    -- 새로 획득한 드래곤 뱃지 (임시 코드)
    if t_dragon_data.isNewDragon and t_dragon_data:isNewDragon() then
        local res = 'res/ui/btn/notification.png'
        local sprite = cc.Sprite:create(res)
        sprite:setDockPoint(cc.p(1, 1))
        sprite:setAnchorPoint(cc.p(1, 1))
        sprite:setScale(1.5)
        ui.vars['clickBtn']:addChild(sprite, 100)
    end

    -- 친구 드래곤일 경우 친구 마크 추가
    local is_friend_dragon = g_friendData:checkFriendDragonFromDoid(t_dragon_data['id'])
    ui:setFriendSpriteVisible(is_friend_dragon)

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

        local cool_time = g_friendData:getDragonUseCoolStr(friend_info)
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
        label:setString(friend_info['nick'])
        ui.vars['clickBtn']:addChild(label, 5)
    end
    
    return ui
end


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