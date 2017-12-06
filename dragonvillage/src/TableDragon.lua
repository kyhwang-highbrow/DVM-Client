local PARENT = TableClass

-------------------------------------
-- class TableDragon
-------------------------------------
TableDragon = class(PARENT, {
        m_lIllustratedDragonList = 'list', -- 드래곤 도감 리스트
        m_mIllustratedDragonIdx = 'table',
    })

local THIS = TableDragon

-------------------------------------
-- function init
-------------------------------------
function TableDragon:init()
    self.m_tableName = 'dragon'
    self.m_orgTable = TABLE:get(self.m_tableName)
end

-------------------------------------
-- function getDragonRole
-------------------------------------
function TableDragon:getDragonRole(key)
    local t_skill = self:get(key)
    return t_skill['role']
end

-------------------------------------
-- function isSameDragonType
-------------------------------------
function TableDragon:isSameDragonType(did1, did2)
    local type1 = self:getValue(did1, 'type')
    local type2 = self:getValue(did2, 'type')

    return (type1 == type2), type1, type2
end

-------------------------------------
-- function getSameTypeDragonList
-------------------------------------
function TableDragon:getSameTypeDragonList(did)
	if (self == THIS) then
        self = THIS()
    end

	local d_type = self:getValue(did, 'type')
    local list = self:filterList('type', d_type)
	
	local l_dragon = {}
	for i, v in ipairs(list) do
		if (v['test'] == 1) then
			table.insert(l_dragon, v)
		end
	end

	table.sort(l_dragon, function(a, b)
		return a['did'] < b['did']
	end)

    return list
end

-------------------------------------
-- function initIllustratedDragonList
-- @breif 도감 리스트 초기화
-------------------------------------
function TableDragon:initIllustratedDragonList()
    if (self.m_lIllustratedDragonList and self.m_mIllustratedDragonIdx) then
        return
    end

    -- 드래곤 테이블에서 test값이 1인 드래곤만 추출
    --self.m_lIllustratedDragonList = self:filterList('test', 1)
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
function TableDragon:getIllustratedDragonList()
    self:initIllustratedDragonList()
    return self.m_lIllustratedDragonList
end

-------------------------------------
-- function getIllustratedDragonIdx
-- @breif 도감 리스트
-------------------------------------
function TableDragon:getIllustratedDragonIdx(did)
    self:initIllustratedDragonList()
    return self.m_mIllustratedDragonIdx[did]
end

-------------------------------------
-- function getIllustratedDragon
-- @breif 도감 리스트
-------------------------------------
function TableDragon:getIllustratedDragon(idx)
    local illustrated_dragon_list = self:getIllustratedDragonList()
    return illustrated_dragon_list[idx]
end

-------------------------------------
-- function getRandomRow
-------------------------------------
function TableDragon:getRandomRow()
    --local l_list = self:filterList('test', 1)
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
function TableDragon:getRelationPoint(did)
    if (self == THIS) then
        self = THIS()
    end
    local relation_point = self:getValue(did, 'relation_point')
    return relation_point
end

-------------------------------------
-- function getImplementedDid
-------------------------------------
function TableDragon:getImplementedDid(did)
    -- 기존에 개발 중인 드래곤은 파워드래곤으로 나오게 하던 부분
    -- LIVE 환경으로 변경되면서 제거함
    if true then
        return did
    end

    if (self == THIS) then
        self = THIS()
    end

    local value = self:getValue(did, 'test')
    if (value == 1) then
        return did
    else
        return 120011 -- 파워드래곤
    end
end

-------------------------------------
-- function getDragonType
-------------------------------------
function TableDragon:getDragonType(did)
    if (self == THIS) then
        self = THIS()
    end

    local dragon_type = self:getValue(did, 'type')
    return dragon_type
end

-------------------------------------
-- function getDragonName
-------------------------------------
function TableDragon:getDragonName(did)
    if (self == THIS) then
        self = THIS()
    end

    local dragon_name = self:getValue(did, 't_name')
    return Str(dragon_name)
end

-------------------------------------
-- function getDragonName
-------------------------------------
function TableDragon:getDragonNameWithAttr(did)
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
function TableDragon:getDragonRes(did, evolution)
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
function TableDragon:getDragonAttr(did)
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
function TableDragon:getMaxStatus(did, status_name)
    if (self == THIS) then
        self = THIS()
    end 

    local max_status = self:getValue(did, status_name .. '_max')
    return max_status
end

-------------------------------------
-- function getValue
-------------------------------------
function TableDragon:getValue(primary, column)
    if (self == THIS) then
        self = THIS()
    end

    return PARENT.getValue(self, primary, column)
end

-------------------------------------
-- function getDragonStoryStr
-- @brief 도감에서 드래곤 스토리 출력 시 사용
-------------------------------------
function TableDragon:getDragonStoryStr(did)
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
function TableDragon:isUnderling(did)
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
function TableDragon:getBirthGrade(did)
    if (self == THIS) then
        self = THIS()
    end

    return self:getValue(did, 'birthgrade')
end

local T_RUNE_STAT_NAME
-------------------------------------
-- function getRecommendRune
-- @brief 추천 룬 정보 반환
-------------------------------------
function TableDragon:getRecommendRuneInfo(did)
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
function TableDragon:getDesc_forToolTip(did)
    local t_dragon = self:get(did)
    local str = '{@SKILL_NAME}' .. t_dragon['t_name']
    return str
end

-------------------------------------
-- function getStarAniName
-- @brief 드래곤 등장 등급 애니메이션 구분
-------------------------------------
function TableDragon:getStarAniName(did, evolution)
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
-- function getCharTable
-- @brief 드래곤 테이블 또는 슬라임 테이블 반환
-------------------------------------
function getCharTable(did)
	local char_table
	if (TableSlime:isSlimeID(did)) then
		char_table = TableSlime()
	else
		char_table = TableDragon()
	end
	return char_table
end