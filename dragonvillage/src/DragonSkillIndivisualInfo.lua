-------------------------------------
-- class DragonSkillIndivisualInfo
-- @TODO Individual로 수정 예정
-------------------------------------
DragonSkillIndivisualInfo = class({
        m_className = '',
        m_charType = 'string',  -- 캐릭터 타입 'dragon', 'monster'
        
		m_tSkill = 'table',     -- 스킬 테이블
        m_skillID = 'number',   -- 스킬 ID
        m_skillLevel = 'number',
        m_skillType = 'string',
		m_tAddedValue = 'table',

        m_metamorphosisSkillInfo = 'DragonSkillIndivisualInfo',
    })

-------------------------------------
-- function init
-------------------------------------
function DragonSkillIndivisualInfo:init(char_type, skill_type, skill_id, skill_level)
    self.m_className = 'DragonSkillIndivisualInfo'

    self.m_charType = char_type
    self.m_skillType = skill_type
    self.m_skillID = skill_id
    self.m_skillLevel = (skill_level or 1)

	self.m_tAddedValue = nil
    self.m_metamorphosisSkillInfo = nil
end

-------------------------------------
-- function mergeSkillInfo
-- @brief 성룡 강화의 경우 기존 스킬 info를 가져와 레벨업된 부분만 합쳐버린다.
-------------------------------------
function DragonSkillIndivisualInfo:mergeSkillInfo(old_skill_info)
	if not (old_skill_info) then
		return
	end

	if (self:getSkillType() ~= old_skill_info:getSkillType()) then
		error('강화될 스킬과 성룡 강화 스킬의 타입이 다르다.')
	end

	DragonSkillCore.applyModification(self.m_tSkill, old_skill_info:getAddValueTable())
end

-------------------------------------
-- function applySkillLevel
-------------------------------------
function DragonSkillIndivisualInfo:applySkillLevel(old_skill_info)
	local skill_id = self.m_skillID
    local t_skill = GetSkillTable(self.m_charType):get(skill_id)

    if (not t_skill) then
        error('존재하지 않는 skill_id ' .. skill_id)
    end

    -- 값이 변경되므로 복사해서 사용
    self.m_tSkill = clone(t_skill)
	
	-- 필요한 데이터 선언
	local t_skill = self.m_tSkill
	local skill_lv = self.m_skillLevel

	-- 레벨이 반영된 데이터 계산
	local _, t_add_value = DragonSkillCore.applySkillLevel(self.m_charType, t_skill, skill_lv)
	self.m_tAddedValue = t_add_value

    if (old_skill_info) then
        self:mergeSkillInfo(old_skill_info)
    end
end

-------------------------------------
-- function applySkillDesc
-- @brief desc column에서 수정할 column명을 가져와 대체하는 함수를 호출한다.
-------------------------------------
function DragonSkillIndivisualInfo:applySkillDesc()
	DragonSkillCore.substituteSkillDesc(self.m_tSkill)
end

-------------------------------------
-- function getSkillDesc
-- @brief 일반 스킬 설명
-------------------------------------
function DragonSkillIndivisualInfo:getSkillDesc()
    -- 스킬 레벨이 반영되지 않은 테이블로 설명 표시
    if (self.m_charType == 'dragon') then
        local t_skill = clone(GetSkillTable(self.m_charType):get(self.m_skillID))
        DragonSkillCore.substituteSkillDesc(t_skill)
        return DragonSkillCore.getSkillDescPure(t_skill)
    else
        return DragonSkillCore.getSkillDescPure(self.m_tSkill)
    end
end

-------------------------------------
-- function getSkillDescEnhance
-- @brief 스킬 강화 설명
-------------------------------------
function DragonSkillIndivisualInfo:getSkillDescEnhance()
    return DragonSkillCore.getSkillEnhanceDesc(self.m_tSkill)
end

-------------------------------------
-- function getSkillDescMod
-- @brief 레벨업 효과 설명
-------------------------------------
function DragonSkillIndivisualInfo:getSkillDescMod()
	local skill_lv = math_max(self.m_skillLevel, 1)
    local desc = DragonSkillCore.getSkillModDesc(self.m_tSkill, skill_lv)
    return desc
end

-------------------------------------
-- function getSkillID
-------------------------------------
function DragonSkillIndivisualInfo:getSkillID()
    return self.m_skillID
end

-------------------------------------
-- function getSkillName
-------------------------------------
function DragonSkillIndivisualInfo:getSkillName()
    return Str(self.m_tSkill['t_name'])
end

-------------------------------------
-- function getSkillLevel
-------------------------------------
function DragonSkillIndivisualInfo:getSkillLevel()
    return self.m_skillLevel
end

-------------------------------------
-- function getSkillType
-------------------------------------
function DragonSkillIndivisualInfo:getSkillType()
    return self.m_skillType
end

-------------------------------------
-- function getSkillTable
-------------------------------------
function DragonSkillIndivisualInfo:getSkillTable()
    return self.m_tSkill
end

-------------------------------------
-- function getAddValueTable
-------------------------------------
function DragonSkillIndivisualInfo:getAddValueTable()
    return self.m_tAddedValue
end

-------------------------------------
-- function isActivated
-------------------------------------
function DragonSkillIndivisualInfo:isActivated()
    return self.m_skillLevel > 0
end

-------------------------------------
-- function getReqMana
-- @brief 필요 마나 리턴 (active 스킬만 유효한 값을 가짐)
-------------------------------------
function DragonSkillIndivisualInfo:getReqMana()
    local req_mana = self.m_tSkill['req_mana']

    if (not req_mana) or (type(req_mana) == 'string') then
        req_mana = 0
    end

    return req_mana
end

-------------------------------------
-- function getManaIcon
-------------------------------------
function DragonSkillIndivisualInfo:getManaIcon()
    local req_mana = self.m_tSkill['req_mana']

    local res = 'ingame_panel_mana_' .. req_mana .. '.png'
    local icon = IconHelper:createWithSpriteFrameName(res)
    return icon
end

-------------------------------------
-- function getCoolTime
-- @brief 순수한 의미의 쿨타임..
-------------------------------------
function DragonSkillIndivisualInfo:getCoolTime(t_skill)
	local t_skill = t_skill or self.m_tSkill
    local cooltime = t_skill['cooldown'] 
    
    -- 예외처리 추가
    if (t_skill['chance_type'] == 'indie_time' or self.m_skillType == 'indie_time_short') then
        local chance_value = t_skill['chance_value']

        -- indie_time 타입의 경우는 cooldown값과 chance_value값을 비교하여 큰 수를 표시
        if (cooltime ~= '') then
            cooltime = (cooltime > chance_value) and cooltime or chance_value
        else
            cooltime = chance_value
        end
    end

    -- 예외처리
    if (cooltime == '') then
        return nil
    elseif (cooltime == 999) then
        return nil
    elseif (cooltime == 0) then
        return nil
    elseif (cooltime == 1) then
        return nil
    end

    return cooltime
end

-------------------------------------
-- function getCoolTimeDesc
-- @brief 쿨타임 표기용
-------------------------------------
function DragonSkillIndivisualInfo:getCoolTimeDesc()
	-- 수정되지 않은 1레벨 기준의 쿨타임을 가져온다
	local t_skill = GetSkillTable(self.m_charType):get(self.m_skillID)
    local cooltime = self:getCoolTime(t_skill)

    -- 텍스트 처리
    local desc
    if (cooltime) then
        desc = Str('{1}초', cooltime)
    end

    return desc
end

-------------------------------------
-- function getTargetCount
-- @brief 타겟수 
-------------------------------------
function DragonSkillIndivisualInfo:getTargetCount()
    local target_cnt = self.m_tSkill['target_count'] 

    return target_cnt
end

-------------------------------------
-- function getIndicatorType
-- @brief 인디케이터 타입
-------------------------------------
function DragonSkillIndivisualInfo:getIndicatorType()
    local indicator_type = self.m_tSkill['indicator']
    if (indicator_type == '') then
        return nil
    end
    return indicator_type
end

-------------------------------------
-- function getIndicatorIcon
-- @brief 인디케이터 아이콘
-- @brief SpriteFrame을 사용하는 것에 주의
-------------------------------------
function DragonSkillIndivisualInfo:getIndicatorIcon()
    local target_type = self.m_tSkill['target_type']
    local indicator_type = self.m_tSkill['indicator']

    -- 스킬 피아 타입
    local str_target
    if (string.find(target_type, 'enemy')) then
        str_target = 'atk'
    else
        str_target = 'heal'
    end

    -- 스킬 동작 방향을 표현
    local rotate = 0
    if (pl.stringx.endswith(indicator_type, '_right')) then
        indicator_type = string.gsub(indicator_type, '_right', '')
        rotate = 180
    elseif (pl.stringx.endswith(indicator_type, '_top')) then
        indicator_type = string.gsub(indicator_type, '_top', '')
        rotate = 180
    elseif (pl.stringx.endswith(indicator_type, '_touch')) then
        indicator_type = string.gsub(indicator_type, '_touch', '')
    end

    cc.SpriteFrameCache:getInstance():addSpriteFrames('res/ui/a2d/ingame_panel/ingame_panel.plist')
    local res = 'ingame_panel_indicater_' .. str_target .. '_' .. indicator_type .. '.png'
    local icon = IconHelper:createWithSpriteFrameName(res)
    icon:setRotation(rotate)

    return icon
end

-------------------------------------
-- function getIndicatorName
-- @brief 인디케이터 명칭
-------------------------------------
function DragonSkillIndivisualInfo:getIndicatorName()
    local indicator_type = self.m_tSkill['indicator']
    local indicator_name = getIndicatorName(indicator_type)
    local size = self.m_tSkill['skill_size']
    local indicator_size = getIndicatorSizeName(size)
    local full_name = string.format('%s (%s)', indicator_name, indicator_size)
    return full_name
end

-------------------------------------
-- function getSkillTypeForUI
-------------------------------------
function DragonSkillIndivisualInfo:getSkillTypeForUI()
    local t_skill = GetSkillTable(self.m_charType):get(self.m_skillID)

    if (self.m_charType == 'tamer' and t_skill['game_mode'] == 'pvp') then
        return 'colosseum'
    end

    return self.m_skillType
end

-------------------------------------
-- function getMetamorphosisSkillId
-------------------------------------
function DragonSkillIndivisualInfo:getMetamorphosisSkillId()
    local skill_id = self.m_tSkill['metamorphosis']
    if (not skill_id or skill_id == '' or skill_id == 0) then
        return nil
    end

    return skill_id
end

-------------------------------------
-- function hasPerfectBarrier
-- @brief 스킬 상태효과중에 무적 관련 상태효과가 있다면 true 반환
-------------------------------------
function DragonSkillIndivisualInfo:hasPerfectBarrier()
    if (not self.m_tSkill) then
        return false
    end
    
    for i = 1, 5 do
        local add_option_type = self.m_tSkill['add_option_type_' .. i]
        if (add_option_type) then
            if (string.find(add_option_type, 'barrier_protection_time')) then
                return true
            end
        end
    end

    return false
end
