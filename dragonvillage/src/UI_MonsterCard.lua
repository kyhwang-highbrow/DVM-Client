local PARENT = UI

-------------------------------------
-- class UI_MonsterCard
-------------------------------------
UI_MonsterCard = class(PARENT,{
        m_monsterID = 'number',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_MonsterCard:init(monster_id)
    local vars = self:load('dragon_item.ui')

    self.m_monsterID = monster_id

    self:refresh()

    vars['clickBtn']:registerScriptTapHandler(function() self:click_clickBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_MonsterCard:refresh()
    local vars = self.vars
    local monster_id = self.m_monsterID

    local table_monster = TableMonster()
    local t_monster = table_monster:get(monster_id)
    
    do -- 몬스터 아이콘
        vars['iconsNode']:removeAllChildren()
        local icon = table_monster:getMonsterIcon(monster_id)
        vars['iconsNode']:addChild(icon)
    end

    do -- 배경 프레임
        local res = 'res/ui/dragon_card/list_frame_bg_common.png'
        local sprite = cc.Sprite:create(res)
        sprite:setAnchorPoint(cc.p(0.5, 0.5))
        sprite:setDockPoint(cc.p(0.5, 0.5))
        vars['rarityNode']:removeAllChildren()
        vars['rarityNode']:addChild(sprite)
    end

    do -- 속성 아이콘
        local attr_str = t_monster['attr']
        local res = 'res/ui/dragon_card/dc_attr_' .. attr_str .. '.png'
        local icon = cc.Sprite:create(res)
        if icon then
            icon:setDockPoint(cc.p(0.5, 0.5))
            icon:setAnchorPoint(cc.p(0.5, 0.5))
            vars['attrNode']:removeAllChildren()
            vars['attrNode']:addChild(icon)
        end
    end

    do -- 보스류 프레임 표시
        local rarity = t_monster['rarity']
        if isExistValue(rarity, 'elite', 'subboss', 'boss') then
            vars['enemyBossSprite']:setVisible(true)
        end
    end

    do -- 레벨 표시
        vars['levelLabel']:setVisible(false)
    end
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
-- function click_clickBtn
-------------------------------------
function UI_MonsterCard:click_clickBtn()
    local monster_id = self.m_monsterID
    local str = TableMonster():getDesc_forToolTip(monster_id)

    local tool_tip = UI_Tooltip_Skill(0, 0, str)

    -- 자동 위치 지정
    tool_tip:autoPositioning(self.vars['clickBtn'])
end