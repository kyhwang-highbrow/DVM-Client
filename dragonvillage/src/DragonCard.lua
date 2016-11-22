-------------------------------------
-- class DragonCard
-------------------------------------
DragonCard = class({
        m_tDragon = 'table',
        m_tDragonData = 'table',

        m_uiRoot = 'cc.Menu',
        m_uiFrame = 'cc.Sprite',        -- 뒤쪽 프레임
        m_uiBg = 'cc.Sprite',            -- 뒤쪽 배경 (속성(attr)에 따라)
        m_uiDragon = 'Animator',        -- 드래곤 에니메이터
        m_uiFrameFront = 'cc.Sprite',    -- 앞쪽 프레임

        m_uiRoleIcon = 'cc.Sprite',        -- 역할 아이콘 (tanker, dealer, supporter)
        m_uiAttrIcon = 'cc.Sprite',        -- 속성 아이콘
        
        m_uiRarityText = 'cc.Sprite',
        m_uiRarityCIcon = 'cc.Sprite',
        m_uiRarityLTIcon = 'cc.Sprite',
        m_uiStatTypeIcon = 'cc.Sprite',
        
        m_uiGradeIcon = 'cc.Sprite',
        m_uiNameIcon = 'cc.Sprite',
        m_uiLevelNode = 'cc.Node',
    })

-------------------------------------
-- function init
-------------------------------------
function DragonCard:init(t_dragon, t_dragon_data)
    self.m_tDragon = t_dragon
    self.m_tDragonData = t_dragon_data

    self:makeDragonCardUI()
end

-------------------------------------
-- function makeDragonCardUI
-------------------------------------
function DragonCard:makeDragonCardUI()
    if self.m_uiRoot then
        self.m_uiRoot:removeFromParent()
        self.m_uiRoot = nil
    end

    local t_dragon = self.m_tDragon
    local t_dragon_data = self.m_tDragonData

    self.m_uiRoot = cc.Menu:create()
    self.m_uiRoot:setAnchorPoint(cc.p(0.5, 0.5))
    self.m_uiRoot:setDockPoint(cc.p(0.5, 0.5))
    self.m_uiRoot:setPosition(0, 0)

    do -- 뒤쪽 프레임
        self.m_uiFrame = cc.Sprite:create('res/ui/dragon_card/dc_frame.png')
        self.m_uiFrame:setAnchorPoint(cc.p(0.5, 0.5))
        self.m_uiFrame:setDockPoint(cc.p(0.5, 0.5))
        self.m_uiRoot:addChild(self.m_uiFrame)
    end

    self.m_uiRoot:setNormalSize(self.m_uiFrame:getContentSize())

    do -- 속성별 배경
        local res = 'res/ui/dragon_card/dc_bg_' .. t_dragon['attr'] .. '.png'
        self.m_uiBg = cc.Sprite:create(res)
        self.m_uiBg:setAnchorPoint(cc.p(0.5, 0.5))
        self.m_uiBg:setDockPoint(cc.p(0.5, 0.5))
        self.m_uiRoot:addChild(self.m_uiBg)
    end

    do -- 드래곤 에니메이터
        local res = t_dragon['res']
        local evolution = t_dragon_data['evolution']
		local attr = t_dragon['attr']
        self.m_uiDragon = AnimatorHelper:makeDragonAnimator(res, evolution, attr)
        self.m_uiDragon.m_node:setAnchorPoint(cc.p(0.5, 0.5))
        self.m_uiDragon.m_node:setDockPoint(cc.p(0.5, 0.5))
        self.m_uiDragon:setPosition(0, -80)
        self.m_uiRoot:addChild(self.m_uiDragon.m_node)
    end

    do -- 앞쪽 프레임
        self.m_uiFrameFront = cc.Sprite:create('res/ui/dragon_card/dc_frame_front.png')
        self.m_uiFrameFront:setAnchorPoint(cc.p(0.5, 0.5))
        self.m_uiFrameFront:setDockPoint(cc.p(0.5, 0.5))
        self.m_uiRoot:addChild(self.m_uiFrameFront)
    end

    do -- 역할 아이콘
        local res = 'res/ui/dragon_card/dc_role_' .. t_dragon['role'] .. '.png'
        self.m_uiRoleIcon = cc.Sprite:create(res)
        self.m_uiRoleIcon:setAnchorPoint(cc.p(0.5, 0.5))
        self.m_uiRoleIcon:setDockPoint(cc.p(0.5, 0.5))
        self.m_uiRoleIcon:setPosition(0, 250)
        self.m_uiRoot:addChild(self.m_uiRoleIcon)
    end
    
    do -- 속성 아이콘
        local res = 'res/ui/dragon_card/dc_attr_' .. t_dragon['attr'] .. '.png'
        self.m_uiAttrIcon = cc.Sprite:create(res)
        self.m_uiAttrIcon:setAnchorPoint(cc.p(0.5, 0.5))
        self.m_uiAttrIcon:setDockPoint(cc.p(0.5, 0.5))
        self.m_uiAttrIcon:setPosition(140, 200)
        self.m_uiRoot:addChild(self.m_uiAttrIcon)
    end

    do -- 레어도 텍스트
        local res = 'res/ui/dragon_card/dc_rarity_text_' .. t_dragon['rarity'] .. '.png'
        self.m_uiRarityText = cc.Sprite:create(res)
        self.m_uiRarityText:setAnchorPoint(cc.p(0.5, 0.5))
        self.m_uiRarityText:setDockPoint(cc.p(0.5, 0.5))
        self.m_uiRarityText:setPosition(0, 190)
        self.m_uiRoot:addChild(self.m_uiRarityText)
    end

    do -- 레어도 가운데 아이콘
        local res = 'res/ui/dragon_card/dc_rarity_icon_' .. t_dragon['rarity'] .. '.png'
        self.m_uiRarityCIcon = cc.Sprite:create(res)
        self.m_uiRarityCIcon:setAnchorPoint(cc.p(0.5, 0.5))
        self.m_uiRarityCIcon:setDockPoint(cc.p(0.5, 0.5))
        self.m_uiRarityCIcon:setPosition(0, -154)
        self.m_uiRoot:addChild(self.m_uiRarityCIcon)
    end

    do -- 레어도 좌상단 아이콘
        local res = 'res/ui/dragon_card/dc_rarity_lt_icon_' .. t_dragon['rarity'] .. '.png'
        self.m_uiRarityLTIcon = cc.Sprite:create(res)
        self.m_uiRarityLTIcon:setAnchorPoint(cc.p(0.5, 0.5))
        self.m_uiRarityLTIcon:setDockPoint(cc.p(0.5, 0.5))
        self.m_uiRarityLTIcon:setPosition(-140, 200)
        self.m_uiRoot:addChild(self.m_uiRarityLTIcon)
    end

    do -- 메인 능력치
        --local res = 'res/ui/dragon_card/dc_status_' .. t_dragon['stat_type'] .. '.png'
        -- TODO
        local res = 'res/ui/dragon_card/dc_status_dex.png'
        self.m_uiStatTypeIcon = cc.Sprite:create(res)
        self.m_uiStatTypeIcon:setAnchorPoint(cc.p(0.5, 0.5))
        self.m_uiStatTypeIcon:setDockPoint(cc.p(0.5, 0.5))
        self.m_uiStatTypeIcon:setPosition(-140, 200)
        self.m_uiRoot:addChild(self.m_uiStatTypeIcon)
    end

    do -- 등급 아이콘
        local res = 'res/ui/dragon_card/dc_grade_0' .. t_dragon_data['grade'] .. '.png'
        self.m_uiGradeIcon = cc.Sprite:create(res)
        self.m_uiGradeIcon:setAnchorPoint(cc.p(0.5, 0.5))
        self.m_uiGradeIcon:setDockPoint(cc.p(0.5, 0.5))
        self.m_uiGradeIcon:setPosition(0, 160)
        self.m_uiRoot:addChild(self.m_uiGradeIcon)
    end

    do -- 드래곤 이름
        self.m_uiNameIcon = IconHelper:getDragonNamePng(t_dragon['did'])
        self.m_uiNameIcon:setPosition(0, -215)
        self.m_uiRoot:addChild(self.m_uiNameIcon)
    end

    do -- 레벨
        local lv = t_dragon_data['lv']
        self.m_uiLevelNode = cc.Node:create()
        self.m_uiLevelNode:setAnchorPoint(cc.p(0.5, 0.5))
        self.m_uiLevelNode:setDockPoint(cc.p(0.5, 0.5))
        self.m_uiLevelNode:setPosition(0, -260)
        self.m_uiRoot:addChild(self.m_uiLevelNode)

        if (lv < 10) then
            local sprite = cc.Sprite:create('res/ui/dragon_card/dc_number_' .. lv .. '.png')
            sprite:setAnchorPoint(cc.p(0.5, 0.5))
            sprite:setDockPoint(cc.p(0.5, 0.5))
            self.m_uiLevelNode:addChild(sprite)
        else
            local sprite = cc.Sprite:create('res/ui/dragon_card/dc_number_' .. math_floor(lv / 10) .. '.png')
            sprite:setAnchorPoint(cc.p(0.5, 0.5))
            sprite:setDockPoint(cc.p(0.5, 0.5))
            sprite:setPositionX(-12)
            self.m_uiLevelNode:addChild(sprite)

            local sprite2 = cc.Sprite:create('res/ui/dragon_card/dc_number_' .. (lv % 10) .. '.png')
            sprite2:setAnchorPoint(cc.p(0.5, 0.5))
            sprite2:setDockPoint(cc.p(0.5, 0.5))
            sprite2:setPositionX(12)
            self.m_uiLevelNode:addChild(sprite2)
        end
    end
end