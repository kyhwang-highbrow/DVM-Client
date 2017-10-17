local PARENT = class(UI, ITableViewCell:getCloneTable())

-------------------------------------
-- class UI_MonsterCard
-------------------------------------
UI_MonsterCard = class(PARENT,{
        root = '',
        vars = '',

        m_monsterID = 'number',
        m_monsterLv = 'number',

        m_clickBtnRes = 'string',
        m_charIconRes = 'string',
        m_attrIconRes = 'string',
        m_starIconRes = 'string',
        m_charFrameRes = 'string',
        m_charLevelNumber = 'number',

        m_bDragonMonster = 'boolean',
        m_nStageID = 'number',
        m_bBoss = 'boolean',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_MonsterCard:init(monster_id, is_boss)
    cc.SpriteFrameCache:getInstance():addSpriteFrames('res/ui/a2d/character_card/character_card.plist')

    self.root = cc.Menu:create()
    self.root:setNormalSize(150, 150)
    self.root:setDockPoint(CENTER_POINT)
    self.root:setAnchorPoint(CENTER_POINT)
    self.root:setPosition(0, 0)
    self.m_bDragonMonster = false
    self.m_bBoss = is_boss or false

    self.vars = {}
    self.m_monsterID = monster_id

    self:refreshMonsterInfo()
end

-------------------------------------
-- function refreshMonsterInfo
-------------------------------------
function UI_MonsterCard:refreshMonsterInfo()
    local vars = self.vars
    local monster_id = self.m_monsterID

    local table_monster = TableMonster()

    -- 인연 던전, 고대의 탑 경우 드래곤이 몬스터로 출현 
    -- 이 경우 clickBtn, pressBtn 몬스터처리 해야하므로 DragonCard가 아닌 MonsterCard 로 생성
    local t_monster, is_dragon = table_monster:getMonsterInfoWithDragon(monster_id)
    self.m_bDragonMonster = is_dragon

    do -- 속성 따른 배경 이미지(버튼)
        local res = 'character_card_bg_' .. t_monster['attr'] .. '.png'
        self:makeClickBtn(res)
    end

    do -- 몬스터 아이콘
        local icon = (is_dragon) and IconHelper:getDragonIconFromDid(monster_id, 3, 1, 1)
                                 or table_monster:getMonsterIcon(monster_id)
        self.vars['clickBtn']:addChild(icon)
    end

    do -- 속성 아이콘 생성
        local res = 'character_card_attr_' .. t_monster['attr'] .. '.png'
        self:makeAttrIcon(res)
    end

    do -- 보스류 프레임 표시
        local rarity = t_monster['rarity']
        if (isExistValue(rarity, 'elite', 'subboss', 'boss')) or (self.m_bBoss) then
            self:makeFrame('character_card_frame_boss.png')
        else
            local res = 'character_card_frame.png'
            self:makeFrame(res)
        end
    end
end

-------------------------------------
-- function makeClickBtn
-------------------------------------
function UI_MonsterCard:makeClickBtn(res)
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

        btn:registerScriptTapHandler(function() self:click_clickBtn() end)
        btn:registerScriptPressHandler(function() self:press_clickBtn() end)
    end

    btn:setNormalSpriteFrame(cc.SpriteFrameCache:getInstance():getSpriteFrame(res))
        
    return btn
end

-------------------------------------
-- function makeAttrIcon
-- @brief 속성 아이콘 생성
-------------------------------------
function UI_MonsterCard:makeAttrIcon(res)
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
    sprite:setScale(1)
    sprite:setPosition(-51, 51)
    self.vars['clickBtn']:addChild(sprite, 12)
    vars['attrIcon'] = sprite
end

-------------------------------------
-- function makeFrame
-- @brief 프레임 생성
-------------------------------------
function UI_MonsterCard:makeFrame(res)
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
-- function getCardSize
-------------------------------------
function UI_MonsterCard:getCardSize(scale)
    local width = 150
    local height = 150
    local scale = (scale or 1)

    return width * scale, height * scale
end

-------------------------------------
-- function setStageID
-------------------------------------
function UI_MonsterCard:setStageID(stage_id)
    self.m_nStageID = stage_id
end

-------------------------------------
-- function click_clickBtn
-------------------------------------
function UI_MonsterCard:click_clickBtn()
    local monster_id = self.m_monsterID
    local str = (self.m_bDragonMonster) and TableDragon():getDesc_forToolTip(monster_id) 
                                        or TableMonster():getDesc_forToolTip(monster_id)
    local tool_tip = UI_Tooltip_Skill(0, 0, str)

    -- 자동 위치 지정
    tool_tip:autoPositioning(self.vars['clickBtn'])
end

-------------------------------------
-- function press_clickBtn
-------------------------------------
function UI_MonsterCard:press_clickBtn()
    local monster_id = self.m_monsterID

    -- 몬스터의 레벨은 해당 스테이지의 레벨
    local monster_lv = (self.m_nStageID) and TableStageData:getStageLevel(self.m_nStageID) or 1
    UI_SimpleMonsterInfoPopup(monster_id, monster_lv)
end