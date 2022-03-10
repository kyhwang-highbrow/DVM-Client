-------------------------------------
-- class StructSlimeObject
-- @instance slime_obj
-------------------------------------
StructSlimeObject = class({
        m_objectType = '',
        m_sortData = '',

        id = 'slime_object_id',
        soid = 'slime_object_id',

        slime_id = 'number',
        lv = 'number',
        exp = 'number',
        grade = 'number', -- 승급 단계
        evolution = 'number', -- 진화 단계

		lock = 'boolean',

        updated_at = 'timestamp',
        created_at = 'timestamp',

        -- 지울 것들
        uid = '',

        -- 드래곤인척 하기 위해
        did = '',
    })

-------------------------------------
-- function init
-------------------------------------
function StructSlimeObject:init(data)
    self.m_objectType = 'slime'

    if data then
        self:applyTableData(data)
    end

    self.soid = self.id
    self.did = self.slime_id
end

-------------------------------------
-- function applyTableData
-- @breif 단순 데이터 table에서 struct로 맴버 변수를 설정하는 함수
-------------------------------------
function StructSlimeObject:applyTableData(data)
    -- 서버에서 key값을 줄여서 쓴 경우가 있어서 변환해준다
    local replacement = {}
    --replacement['id'] = 'soid'

    -- 2018.04.11 sgkim
    -- 기존 스킬 슬라임은 등급 구분 없이 129215 아이디로만 개발되어 있었음
    -- 3, 4, 5 태생의 스킬 슬라임을 구분하면서 기존에 1태생으로 되어있는 스킬 슬라임을
    -- 5성으로 취급할 필요가 생김
    if (data['slime_id'] == 129215) then
        if (data['grade'] == 1) then
            data['grade'] = 5
        end
    end

    for i,v in pairs(data) do
        local key = replacement[i] and replacement[i] or i
        self[key] = v
    end
end

-------------------------------------
-- function getFlv
-- @breif 드래곤인척하기위해
-------------------------------------
function StructSlimeObject:getFlv()
    return 0
end

-------------------------------------
-- function getRole
-- @breif
-------------------------------------
function StructSlimeObject:getRole()
    return TableSlime:getValue(self['slime_id'], 'role')
end

-------------------------------------
-- function getAttr
-- @breif
-------------------------------------
function StructSlimeObject:getAttr()
    return TableSlime:getValue(self['slime_id'], 'attr')
end

-------------------------------------
-- function getRarity
-- @breif
-------------------------------------
function StructSlimeObject:getRarity()
    return TableSlime:getValue(self['slime_id'], 'rarity')
end

-------------------------------------
-- function getDragonNameWithEclv
-- @breif
-------------------------------------
function StructSlimeObject:getDragonNameWithEclv()
    local name = TableSlime:getValue(self['slime_id'], 't_name')
    return Str(name)
end

-------------------------------------
-- function getBirthGrade
-- @breif
-------------------------------------
function StructSlimeObject:getBirthGrade()
    return TableSlime:getValue(self['slime_id'], 'birthgrade')
end

-------------------------------------
-- function getEclv
-- @breif
-------------------------------------
function StructSlimeObject:getEclv()
    return 0
end

-------------------------------------
-- function getGrade
-- @breif
-------------------------------------
function StructSlimeObject:getGrade()
    return self['grade']
end

-------------------------------------
-- function getIconRes
-- @breif
-------------------------------------
function StructSlimeObject:getIconRes()
    local table_slime = TableSlime()
    local t_slime = table_slime:get(self['slime_id'])

    local res = t_slime['icon']
    local evolution = self['evolution']
    local attr = t_slime['attr']

    res = string.gsub(res, '#', '0' .. evolution)
    res = string.gsub(res, '@', attr)

    return res
end

-------------------------------------
-- function getGradeRes
-- @breif 등급 별 리소스 생성
-------------------------------------
function StructSlimeObject:getGradeRes()
    local grade = tonumber(self['grade']) or 1
	local color = 'gray'

    -- grade의 0을 넣는 경우도 있다..!
    if (grade <= 0) then
        return
    end

    return string.format('card_star_%s_01%02d.png', color, grade)
end

-------------------------------------
-- function isLeader
-- @breif
-------------------------------------
function StructSlimeObject:isLeader()
    return false
end

-------------------------------------
-- function isNotiDragon
-- @breif
-------------------------------------
function StructSlimeObject:isNotiDragon()
    return false
end

-------------------------------------
-- function isNewDragon
-- @breif
-------------------------------------
function StructSlimeObject:isNewDragon()
    local doid = self['id']

    if (not doid) then
        return
    end

    return g_highlightData:isNewDoid(doid)
end

-------------------------------------
-- function getFriendshipObject
-- @breif
-------------------------------------
function StructSlimeObject:getFriendshipObject()
    return StructFriendshipObject()
end

-------------------------------------
-- function getSlimeDesc
-- @breif
-------------------------------------
function StructSlimeObject:getSlimeDesc()
    local slime_id = self['slime_id']
    return TableSlime:getDesc(slime_id)
end

-------------------------------------
-- function getSlimeType
-- @breif
-------------------------------------
function StructSlimeObject:getSlimeType()
    local slime_id = self['slime_id']
    return TableSlime:getMaterialType(slime_id)
end

-------------------------------------
-- function getObjectId
-- @breif
-------------------------------------
function StructSlimeObject:getObjectId()
    return self['id']
end

-------------------------------------
-- function getObjectType
-- @breif
-------------------------------------
function StructSlimeObject:getObjectType()
    return self['m_objectType']
end

-------------------------------------
-- function makeSlimeSkillIcon
-- @breif
-------------------------------------
function StructSlimeObject:makeSlimeSkillIcon()
    local slime_id = self['slime_id']
    local material_type = TableSlime:getMaterialType(slime_id)

    local res = 'res/ui/icons/skill/slime_' .. material_type .. '.png'
    local icon = cc.Sprite:create(res)
    if (not icon) then
        return nil
    end
    icon:setDockPoint(cc.p(0.5, 0.5))
    icon:setAnchorPoint(cc.p(0.5, 0.5))
    return icon
end

-------------------------------------
-- function makeDragonsSortData
-- @breif
-------------------------------------
function StructSlimeObject:makeDragonsSortData()
    local t_sort_data = {}
    t_sort_data['doid'] = self['id']
    t_sort_data['did'] = self['slime_id']
    t_sort_data['hp'] = 0
    t_sort_data['def'] = 0
    t_sort_data['atk'] = 0
    t_sort_data['attr'] = 0
    t_sort_data['lv'] = self['lv']
    t_sort_data['grade'] = self['grade']
    t_sort_data['evolution'] = self['evolution']
    t_sort_data['rarity'] = dragonRarityStrToNum(self:getRarity())
    t_sort_data['friendship'] = self:getFlv()
    t_sort_data['combat_power'] = 0
    t_sort_data['updated_at'] = self['updated_at']

    return t_sort_data
end

-------------------------------------
-- function getDragonSortData
-- @breif
-------------------------------------
function StructSlimeObject:getDragonSortData()
    if (not self.m_sortData) then
		self.m_sortData = self:makeDragonsSortData()
    end

    return self.m_sortData
end

-------------------------------------
-- function getLock
-- @breif
-------------------------------------
function StructSlimeObject:getLock()
    return self['lock']
end

-------------------------------------
-- function isPossibleTransformChange
-- @breif
-------------------------------------
function StructSlimeObject:isPossibleTransformChange()
    return false
end

-------------------------------------
-- function getGrade
-- @breif
-------------------------------------
function StructSlimeObject:getGrade()
    return self['grade']
end

-------------------------------------
-- function getEvolution
-- @breif
-------------------------------------
function StructSlimeObject:getEvolution()
    return self['evolution']
end

-------------------------------------
-- function getLv
-- @breif
-------------------------------------
function StructSlimeObject:getLv()
    return self['lv']
end

-------------------------------------
-- function getRlv
-- @breif
-------------------------------------
function StructSlimeObject:getRlv()
    return 0
end

-------------------------------------
-- function getRuneObjectList
-- @breif
-------------------------------------
function StructSlimeObject:getRuneObjectList()
    return {}
end

-------------------------------------
-- function getMasteryLevel
-- @breif 특성 레벨
-------------------------------------
function StructSlimeObject:getMasteryLevel()
    return 0
end