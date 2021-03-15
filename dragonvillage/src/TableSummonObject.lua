local PARENT = TableClass

-------------------------------------
-- class TableSummonObject
-------------------------------------
TableSummonObject = class(PARENT, {
    })

local THIS = TableSummonObject

-------------------------------------
-- function init
-------------------------------------
function TableSummonObject:init()
    self.m_tableName = 'summon_object'
    self.m_orgTable = TABLE:get(self.m_tableName)
end

-------------------------------------
-- function getDragonRole
-------------------------------------
function TableSummonObject:getDragonRole(key)
    local t_skill = self:get(key)
    return t_skill['role']
end

-------------------------------------
-- function getDragonRarity
-------------------------------------
function TableSummonObject:getDragonRarity(key)
    local t_skill = self:get(key)
    return t_skill['rarity']
end

-------------------------------------
-- function getDragonCartegory
-------------------------------------
function TableSummonObject:getDragonCartegory(key)
    local t_dragon = self:get(key)
    return t_dragon['category']
end

-------------------------------------
-- function isSameDragonType
-------------------------------------
function TableSummonObject:isSameDragonType(did1, did2)
    local type1 = self:getValue(did1, 'type')
    local type2 = self:getValue(did2, 'type')

    return (type1 == type2), type1, type2
end

-------------------------------------
-- function getSameTypeDragonList
-------------------------------------
function TableSummonObject:getSameTypeDragonList(did, map_released)
	if (self == THIS) then
        self = THIS()
    end

    local map_released = map_released or {}
	local d_type = self:getValue(did, 'type')
    local list = self:filterList('type', d_type)
	
	local l_dragon = {}
	for i, v in ipairs(list) do
        local b = false
		
        if (v['test'] == 2) then
			b = true
		elseif (v['test'] == 1 and map_released[tostring(v['did'])]) then
            b = true
        end

        if (b) then
            table.insert(l_dragon, v)
        end
	end

	table.sort(l_dragon, function(a, b)
		return a['did'] < b['did']
	end)

    return l_dragon
end

-------------------------------------
-- function initIllustratedDragonList
-- @breif 도감 리스트 초기화
-------------------------------------
function TableSummonObject:initIllustratedDragonList()
    if (self.m_lIllustratedDragonList and self.m_mIllustratedDragonIdx) then
        return
    end

    self.m_lIllustratedDragonList = self:filterList('none', nil)

    -- did순으로 정렬
    table.sort(self.m_lIllustratedDragonList, function(a, b)
        return a['did'] < b['did']
    end)

    -- 해당 did가 어떤 idx에 있는지 저장
    self.m_mIllustratedDragonIdx = {}
    for i,v in ipairs(self.m_lIllustratedDragonList) do
        self.m_mIllustratedDragonIdx[v['did']] = i
    end
end

-------------------------------------
-- function getIllustratedDragonList
-- @breif 도감 리스트
-------------------------------------
function TableSummonObject:getIllustratedDragonList()
    self:initIllustratedDragonList()
    return self.m_lIllustratedDragonList
end

-------------------------------------
-- function getIllustratedDragonIdx
-- @breif 도감 리스트
-------------------------------------
function TableSummonObject:getIllustratedDragonIdx(did)
    self:initIllustratedDragonList()
    return self.m_mIllustratedDragonIdx[did]
end

-------------------------------------
-- function getIllustratedDragon
-- @breif 도감 리스트
-------------------------------------
function TableSummonObject:getIllustratedDragon(idx)
    local illustrated_dragon_list = self:getIllustratedDragonList()
    return illustrated_dragon_list[idx]
end

-------------------------------------
-- function getRandomRow
-------------------------------------
function TableSummonObject:getRandomRow()
    local l_list = self:filterList('none', nil)

    local cnt = table.count(l_list)
    local rand_num = math_random(1, cnt)

    local idx = 1
    for i,v in pairs(l_list) do
        if (idx == rand_num) then
            return clone(v)
        end

        idx = (idx + 1)
    end
end

-------------------------------------
-- function getRelationPoint
-------------------------------------
function TableSummonObject:getRelationPoint(did)
    if (self == THIS) then
        self = THIS()
    end
    local relation_point = self:getValue(did, 'relation_point')
    return relation_point
end

-------------------------------------
-- function getDragonType
-------------------------------------
function TableSummonObject:getDragonType(did)
    if (self == THIS) then
        self = THIS()
    end

    local dragon_type = self:getValue(did, 'type')
    return dragon_type
end

-------------------------------------
-- function getDragonName
-------------------------------------
function TableSummonObject:getDragonName(did)
    if (self == THIS) then
        self = THIS()
    end

    local dragon_name = self:getValue(did, 't_name')
    return Str(dragon_name)
end

-------------------------------------
-- function getDragonNameWithAttr
-------------------------------------
function TableSummonObject:getDragonNameWithAttr(did)
    if (self == THIS) then
        self = THIS()
    end

    local name = self:getDragonName(did)
	local attr = dragonAttributeName(self:getDragonAttr(did))

    return string.format('%s (%s)', name, attr)
end

-------------------------------------
-- function getDragonRes
-------------------------------------
function TableSummonObject:getDragonRes(did, evolution)
    if (self == THIS) then
        self = THIS()
    end

    local res = self:getValue(did, 'res')
	local attr = self:getValue(did, 'attr')
	local evolution = evolution or 3
    return AnimatorHelper:getDragonResName(res, evolution, attr)
end

-------------------------------------
-- function getDragonAttr
-------------------------------------
function TableSummonObject:getDragonAttr(did)
    if (self == THIS) then
        self = THIS()
    end

    if TableSlime:isSlimeID(did) then
        local table_slime = TableSlime()
        return table_slime:getValue(did, 'attr')
    end

    local dragon_attr = self:getValue(did, 'attr')
    return dragon_attr
end

-------------------------------------
-- function getMaxStatus
-------------------------------------
function TableSummonObject:getMaxStatus(did, status_name)
    if (self == THIS) then
        self = THIS()
    end 

    local max_status = self:getValue(did, status_name .. '_max')
    return max_status
end

-------------------------------------
-- function getValue
-------------------------------------
function TableSummonObject:getValue(primary, column)
    if (self == THIS) then
        self = THIS()
    end

    return PARENT.getValue(self, primary, column)
end

-------------------------------------
-- function getDragonStoryStr
-- @brief 도감에서 드래곤 스토리 출력 시 사용
-------------------------------------
function TableSummonObject:getDragonStoryStr(did)
    if (self == THIS) then
        self = THIS()
    end

    local str = self:getValue(did, 't_desc')
    str = Str(str)

    return str
end

-------------------------------------
-- function isUnderling
-- @brief 자코 여부 확인
-------------------------------------
function TableSummonObject:isUnderling(did)
    if (self == THIS) then
        self = THIS()
    end
    local underling = self:getValue(did, 'underling')
    return (underling == 1)
end

-------------------------------------
-- function getBirthGrade
-- @brief 태생 n성..
-------------------------------------
function TableSummonObject:getBirthGrade(did)
    if (self == THIS) then
        self = THIS()
    end

    return self:getValue(did, 'birthgrade')
end

local T_RUNE_STAT_NAME
-------------------------------------
-- function getRecommendRuneInfo
-- @brief 추천 룬 정보 반환
-------------------------------------
function TableSummonObject:getRecommendRuneInfo(did)
	if (not T_RUNE_STAT_NAME) then
		T_RUNE_STAT_NAME = 
		{
			['yellow'] = Str('체력'),
			['purple'] = Str('치명확률'),
			['green'] = Str('효과적중'),
			['orange'] = Str('방어력'),
			['bluegreen'] = Str('효과저항'),
			['red'] = Str('공격력'),
			['pink'] = Str('치명피해'),
			['blue'] = Str('공격속도'),
		}
	end

    if (self == THIS) then
        self = THIS()
    end

	local rune_color = self:getValue(did, 'rune')
	if (not rune_color) or (rune_color == '') then
		return nil
	end

	local t_rune = {
		['color'] = rune_color,
		['stat'] = T_RUNE_STAT_NAME[rune_color],
		['res'] = string.format('res/ui/icons/rune/set_%s_06.png', rune_color)
	}
	return t_rune
end

-------------------------------------
-- function getDesc_forToolTip
-- @brief 드래곤 툴팁용 설명 리턴
-------------------------------------
function TableSummonObject:getDesc_forToolTip(did)
    local t_dragon = self:get(did)
    local str = '{@SKILL_NAME}' .. Str(t_dragon['t_name'])
    return str
end

-------------------------------------
-- function getStarAniName
-- @brief 드래곤 등장 등급 애니메이션 구분
-------------------------------------
function TableSummonObject:getStarAniName(did, evolution)
    if (TableSlime:isSlimeID(did)) then
	    return 'gray_'

    elseif (self:isUnderling(did)) then
        return 'gray_'

    elseif (evolution == 1) then
        return 'yellow_'

    elseif (evolution == 2) then
        return 'purple_'

    elseif (evolution == 3) then
        return 'red_'

    else
        error('evolution : ' .. evolution)
    end
end

-------------------------------------
-- function getChanceUpDragonName
-------------------------------------
function TableSummonObject:getChanceUpDragonName(did)
    if (self == THIS) then
        self = THIS()
    end

    local attr = self:getDragonAttr(did)
    local name = self:getDragonName(did)
    return string.format('{@%s}%s (%s)', attr, name, dragonAttributeName(attr))
end

-------------------------------------
-- function getChanceUpDragonName2
-------------------------------------
function TableSummonObject:getChanceUpDragonName2(did)
    if (self == THIS) then
        self = THIS()
    end

    local attr = self:getDragonAttr(did)
    local name = self:getDragonName(did)
    return string.format('{@%s}%s\n(%s)', attr, name, dragonAttributeName(attr))
end

-------------------------------------
-- function getChanceUpDragonBgPath
-------------------------------------
function TableSummonObject:getChanceUpDragonBgPath(did)
    if (self == THIS) then
        self = THIS()
    end

    local attr = self:getDragonAttr(did)
    return string.format('res/ui/event/bg_chance_up_%s_0101.png', attr)
end