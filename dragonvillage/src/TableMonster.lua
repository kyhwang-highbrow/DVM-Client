local PARENT = TableClass

-------------------------------------
-- class TableMonster
-------------------------------------
TableMonster = class(PARENT, {
    })

local THIS = TableMonster

-------------------------------------
-- function init
-------------------------------------
function TableMonster:init()
    self.m_tableName = 'monster'
    self.m_orgTable = TABLE:get(self.m_tableName)
end

-------------------------------------
-- function getMonsterIcon
-- @brief 몬스터 아이콘을 리턴
-------------------------------------
function TableMonster:getMonsterIcon(monster_id)
    local t_monster = self:get(monster_id)

    local type = t_monster['type']
    local attr = t_monster['attr']
    local icon_path = t_monster['icon']

    local res_name = string.format('res/ui/icons/mon/%s_%s.png', type, attr)

    if (icon_path == '') or (icon_path == nil) then
        res_name = string.format('res/ui/icons/mon/%s_%s.png', type, attr)
    else
        res_name = string.gsub(icon_path, '@', attr)
    end
    local sprite = cc.Sprite:create(res_name)

    if (not sprite) then
        sprite = cc.Sprite:create('res/ui/icons/cha/developing.png')
    end

    sprite:setDockPoint(cc.p(0.5, 0.5))
    sprite:setAnchorPoint(cc.p(0.5, 0.5))

    return sprite
end

-------------------------------------
-- function getDesc_forToolTip
-- @brief 몬스터 툴팁용 설명 리턴
-------------------------------------
function TableMonster:getDesc_forToolTip(monster_id)
    local t_monster = self:get(monster_id)
    local str = '{@SKILL_NAME}' .. Str(t_monster['t_name'])
    return str
end

-------------------------------------
-- function isBossMonster
-- @brief 보스 몬스터인지 여부
-------------------------------------
function TableMonster:isBossMonster(monster_id)
    if (self == THIS) then
        self = THIS()
    end

    local rarity = self:getValue(monster_id, 'rarity')
    if (rarity == 'boss') then
        return true
    else
        return false
    end
end

-------------------------------------
-- function getMonsterName
-------------------------------------
function TableMonster:getMonsterName(mid)
    if (self == THIS) then
        self = THIS()
    end

    local monster_name = self:getValue(mid, 't_name')
    return Str(monster_name)
end

-------------------------------------
-- function getMonsterRes
-- @brief
-------------------------------------
function TableMonster:getMonsterRes(monster_id)
    if (self == THIS) then
        self = THIS()
    end

    local res = self:getValue(monster_id, 'res')
    local attr = self:getValue(monster_id, 'attr')
    local evolution = 3
    return res, attr, evolution
end


-------------------------------------
-- function getMonsterScale
-- @brief
-------------------------------------
function TableMonster:getMonsterScale(monster_id)
    if (self == THIS) then
        self = THIS()
    end

    local scale = self:getValue(monster_id, 'scale')
    return scale
end



-------------------------------------
-- function getMonsterInfoWithDragon
-- @brief 몬스터 테이블에 없는 경우 드래곤 테이블까지 검사 
-------------------------------------
function TableMonster:getMonsterInfoWithDragon(monster_id)
    if (self == THIS) then
        self = THIS()
    end

    local is_dragon_monster = false
    local t_monster = self:get(monster_id)
    
    if (t_monster) then
        is_dragon_monster = false
    else
        is_dragon_monster = true
        t_monster = TableDragon():get(monster_id)
    end

    -- 드래곤인지 여부 체크 (monster_id의 식별자로 확인)
    local identifier = getDigit(monster_id, 10000, 2)
    if (identifier == 12) then
        is_dragon_monster = true
    end

    return t_monster, is_dragon_monster
end

-------------------------------------
-- function getValue
-- @brief
-------------------------------------
function TableMonster:getValue(primary, column)
    local t_data = PARENT.get(self, primary)
    if t_data then
        return PARENT.getValue(self, primary, column)
    end

    local primary = (primary - 20000)
    local table_dragon = TableDragon()
    return table_dragon:getValue(primary, column)
end

-------------------------------------
-- function getMonsterAttr
-------------------------------------
function TableMonster:getMonsterAttr(mid)
    if (self == THIS) then
        self = THIS()
    end

    local attr = self:getValue(mid, 'attr')
    return attr
end