local PARENT = TableClass

-------------------------------------
-- class TableMonster
-------------------------------------
TableMonster = class(PARENT, {
    })

-------------------------------------
-- function init
-------------------------------------
function TableMonster:init()
    self.m_tableName = 'enemy'
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

    local res_name = string.format('res/ui/icon/mon/%s_%s.png', type, attr)
    local sprite = cc.Sprite:create(res_name)

    if (not sprite) then
        sprite = cc.Sprite:create('res/ui/icon/cha/developing.png')
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
    local str = '{@SKILL_NAME}' .. t_monster['t_name']
    return str
end