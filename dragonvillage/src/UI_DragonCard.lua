--[[
local PARENT = UI

-------------------------------------
-- class UI_DragonCard
-------------------------------------
UI_DragonCard = class(PARENT,{
        m_dragonData = 'table',
        m_dragonID = 'number',
        m_funcCheckSettedDragon = 'function', -- 드래곤이 덱에 설정되어있는지 확인하는 함수
    })

-------------------------------------
-- function init
-------------------------------------
function UI_DragonCard:init(t_dragon_data)
    local vars = self:load('dragon_item.ui')

    self.m_dragonData = t_dragon_data
    self.m_dragonID = t_dragon_data['did']

    self:refreshDragonInfo()
end

-------------------------------------
-- function refreshDragonInfo
-------------------------------------
function UI_DragonCard:refreshDragonInfo()
    if (not self.m_dragonData) then
        return
    end

    local vars = self.vars
    local dragon_id = tonumber(self.m_dragonData['did'])

    -- 유저가 보유하고있는 드래곤의 정보
    local t_dragon_data = self.m_dragonData

    -- 테이블에 있는 드래곤의 정보
    local table_dragon = TABLE:get('dragon')
    local t_dragon = table_dragon[dragon_id]

    do -- 배경 프레임
        local res = 'res/ui/dragon_card/list_frame_bg_' .. t_dragon['rarity'] .. '.png'
        local sprite = cc.Sprite:create(res)
        sprite:setAnchorPoint(cc.p(0.5, 0.5))
        sprite:setDockPoint(cc.p(0.5, 0.5))
        vars['rarityNode']:removeAllChildren()
        vars['rarityNode']:addChild(sprite)
    end

    do -- 드래곤 아이콘
        local evolution = t_dragon_data['evolution']
		local attr = t_dragon['attr']
        local sprite = IconHelper:getHeroIcon(t_dragon['icon'], evolution, attr)
        sprite:setAnchorPoint(cc.p(0.5, 0.5))
        sprite:setDockPoint(cc.p(0.5, 0.5))
        vars['iconsNode']:removeAllChildren()
        vars['iconsNode']:addChild(sprite)
    end

    do -- 레벨 표시
        if t_dragon_data['lv'] then
            vars['levelLabel']:setString(Str('{1}', t_dragon_data['lv']))
        else
            vars['levelLabel']:setVisible(false)
        end
    end

    do -- 등급 별
        if t_dragon_data['grade'] then
            local grade_res = 'res/ui/icon/star010' .. t_dragon_data['grade'] .. '.png'
            local sprite = cc.Sprite:create(grade_res)
            sprite:setAnchorPoint(cc.p(0.5, 0.5))
            sprite:setDockPoint(cc.p(0.5, 0.5))
            vars['starNode']:removeAllChildren()
            vars['starNode']:addChild(sprite)
        end
    end

    do -- 속성 아이콘
        local table_dragon = TABLE:get('dragon')
        local t_dragon = table_dragon[dragon_id]
        local attr_str = t_dragon['attr']
        local res = 'res/ui/dragon_card/dc_attr_' .. attr_str .. '.png'
        local icon = cc.Sprite:create(res)
        if icon then
            icon:setDockPoint(cc.p(0.5, 0.5))
            icon:setAnchorPoint(cc.p(0.5, 0.5))
            vars['attrNode']:removeAllChildren()
            vars['attrNode']:addChild(icon)
        end
    end

    do -- 드래곤들의 덱설정 여부 데이터 갱신
        if self.m_dragonData and self.m_dragonData['id'] then
            local doid = self.m_dragonData['id']
            local is_setted = g_deckData:isSettedDragon(doid)
            if is_setted then
                vars['readySprite']:setVisible(true)
            end
        end
    end

end

-------------------------------------
-- function setCheckSettedDragonFunc
-- @brief 덱에 설정되어있는지 여부 리턴
-------------------------------------
function UI_DragonCard:setCheckSettedDragonFunc(func)
    self.m_funcCheckSettedDragon = func
end

-------------------------------------
-- function checkSettedDragon
-- @brief 덱에 설정되어있는지 여부 리턴
-------------------------------------
function UI_DragonCard:checkSettedDragon()
    local doid = self.m_dragonData['id']

    if self.m_funcCheckSettedDragon then
        return self.m_funcCheckSettedDragon(doid)
    end

    local is_setted = g_deckData:isSettedDragon(doid)

    return is_setted
end

-------------------------------------
-- function setReadySpriteVisible
-- @brief
-------------------------------------
function UI_DragonCard:setReadySpriteVisible(visible)
    self.vars['readySprite']:setVisible(visible)
end

-------------------------------------
-- function MakeSimpleDragonCard
-------------------------------------
function MakeSimpleDragonCard(did)
    local t_dragon_data = {}
    t_dragon_data['did'] = did
    t_dragon_data['lv'] = nil
    t_dragon_data['evolution'] = 3
    t_dragon_data['grade'] = nil

    return UI_DragonCard(t_dragon_data)
end
--]]