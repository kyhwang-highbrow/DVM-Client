local PARENT = StructUserInfoArenaNew

local L_TIER = {}
L_TIER['beginner'] = 1
L_TIER['bronze']= 2
L_TIER['silver']= 3
L_TIER['gold']= 4 
L_TIER['platinum']= 5 
L_TIER['diamond']= 6 
L_TIER['hero']= 7
L_TIER['master']= 8
L_TIER['legend']= 9

-------------------------------------
-- class StructUserInfoClanWar
-- @instance
-------------------------------------
StructUserInfoClanWar = class(PARENT, {
	m_structMatchItem = 'StructClanWarMatchItem',
	m_lastTier = 'string',
    m_lastRank = 'number',
})

-------------------------------------
-- function setClanWarStructMatchItem
-------------------------------------
function StructUserInfoClanWar:setClanWarStructMatchItem(struct_match_item)
	self.m_structMatchItem = struct_match_item
end

-------------------------------------
-- function getClanWarStructMatchItem
-------------------------------------
function StructUserInfoClanWar:getClanWarStructMatchItem()
	return self.m_structMatchItem
end

-------------------------------------
-- function setLastTier
-------------------------------------
function StructUserInfoClanWar:setLastTier(last_tier)
	self.m_lastTier = last_tier
end

-------------------------------------
-- function setLastRank
-- @brief 콜로세움 지난 시즌 랭킹
-------------------------------------
function StructUserInfoClanWar:setLastRank(last_rank)
	self.m_lastRank = last_rank
end

-------------------------------------
-- function getLastRank
-- @brief 콜로세움 지난 시즌 랭킹
-------------------------------------
function StructUserInfoClanWar:getLastRank()
    -- 값이 없을 경우 우선순위를 낮추기 위해 낮은 숫자로 지정
	if (self.m_lastRank == nil) or (self.m_lastRank <= 0) then
        return 999999
    end

    return self.m_lastRank
end

-------------------------------------
-- function getLastTierIcon
-------------------------------------
function StructUserInfoClanWar:getLastTierIcon(type)
	local tier = self.m_lastTier
    
    local pure_tier, tier_grade = self.perseTier(tier)
    if (not pure_tier) then
        return
    end

    if (type == 'big') then
        res = string.format('res/ui/icons/pvp_tier/pvp_tier_%s.png', pure_tier)
    else
        res = string.format('res/ui/icons/pvp_tier/pvp_tier_s_%s.png', pure_tier)
    end

    local icon = cc.Sprite:create(res)
    if (icon) then
        icon:setDockPoint(cc.p(0.5, 0.5))
        icon:setAnchorPoint(cc.p(0.5, 0.5))
    end
    return icon
end

-------------------------------------
-- function getTierOrder
-------------------------------------
function StructUserInfoClanWar:getTierOrder(_tier)
	local tier = _tier or self.m_lastTier
    
    local pure_tier, tier_grade = self.perseTier(tier)
    if (not pure_tier) then
        return 0
    end

	if (not L_TIER[pure_tier]) then
		return 0
	end

	tier_grade = tier_grade or 0
    
    return tonumber(L_TIER[pure_tier]) * 10 + tonumber(tier_grade)
end

-------------------------------------
-- function perseTier
-- @brief 티어 구분 (bronze_3 -> bronze, 3)
-------------------------------------
function StructUserInfoClanWar.perseTier(tier_str)
    if (not tier_str) then
        return
    end

    local str_list = pl.stringx.split(tier_str, '_')
    local pure_tier = str_list[1]
    local tier_grade = tonumber(str_list[2]) or 0
    return pure_tier, tier_grade
end

-------------------------------------
-- function createUserInfo
-- @brief 콜로세움 유저 인포
-------------------------------------
function StructUserInfoClanWar:createUserInfo(t_data)
    local user_info = StructUserInfoClanWar()
    user_info.m_uid = t_data['uid']
    user_info.m_nickname = t_data['nick']
    user_info.m_lv = t_data['lv']
    user_info.m_rank = t_data['rank']
    user_info.m_rankPercent = t_data['rate']
    user_info.m_tier = t_data['tier']
    if (t_data['debris'] and t_data['debris']['tier']) then user_info.m_tier = t_data['debris']['tier'] end

    local has_last_info = false

    if (t_data['info'] and isNullOrEmpty(t_data['info']['last_tier']) == false) then has_last_info = true end
    user_info.m_lastTier = has_last_info == true and t_data['info']['last_tier'] or 'beginner'

    user_info.m_rp = t_data['rp']

    user_info.m_leaderDragonObject = StructDragonObject(t_data['leader'])
    
    -- 룬 & 드래곤 리스트 저장
    user_info:applyRunesDataList(t_data['runes']) --반드시 드래곤 설정 전에 룬을 설정해야함
    user_info:applyDragonsDataList(t_data['dragons'])
    -- 덱 저장
    user_info:applyPvpDeckData(t_data['deck'])

    return user_info
end

