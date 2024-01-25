local PARENT = Structure

-------------------------------------
-- class StructClan
-------------------------------------
StructClan = class(PARENT, {
        id = 'string',
        
        name = 'string', -- 클랜 이름
        intro = 'string', -- 클랜 설명
        mark = 'string', -- 클랜 문장
        notice = 'string', -- 클랜 공지

        member_cnt = 'number',
        join = 'boolean', -- 자동 가입 여부
        
        last_attd = 'number', -- 전날 출석 유저 수
        curr_attd = 'number', -- 오늘 출석 유저 수

        master = 'string', -- 클랜 마스터 닉네임
        empty = '', -- ??

        timestamp = 'number',
        mcnt = 'number',
        joinlv = 'number', -- 지원 레벨
        category = 'string', -- 필수 참여 컨텐츠 카테고리

        m_structClanMark = 'StructClanMark',
        m_memberList = 'list[StructUserInfoCLan]',
		m_structClanBuff = 'StructClanBuff',

		-- 클랜 컨텐츠 업데이트로 추가
		lv = 'number',
		exp = 'number',
		required_exp = 'number',
		member_max = 'number',

        PCT_PERCENT_DEFAULT = '',
    })

local THIS = StructClan

-------------------------------------
-- function init
-------------------------------------
function StructClan:init(data)
    if (data['mark']) then
        self.mark = data['mark']
        self.m_structClanMark = StructClanMark:create(data['mark'])
    else
        self.m_structClanMark = StructClanMark()
    end
end

-------------------------------------
-- function getClassName
-------------------------------------
function StructClan:getClassName()
    return 'StructClan'
end

-------------------------------------
-- function getThis
-------------------------------------
function StructClan:getThis()
    return THIS
end

-------------------------------------
-- function getClanObjectID
-------------------------------------
function StructClan:getClanObjectID()
    return self['id']
end

-------------------------------------
-- function getClanName
-------------------------------------
function StructClan:getClanName()
    return self['name']
end

-------------------------------------
-- function getClanMark
-------------------------------------
function StructClan:getClanMark()
    return self['mark']
end

-------------------------------------
-- function getClanIntro
-------------------------------------
function StructClan:getClanIntro()
    return self['intro']
end

-------------------------------------
-- function getClanNotice
-------------------------------------
function StructClan:getClanNotice()
    return self['notice']
end

-------------------------------------
-- function setClanNotice
-------------------------------------
function StructClan:setClanNotice(s)
    self['notice'] = s
end

-------------------------------------
-- function getMasterNick
-------------------------------------
function StructClan:getMasterNick()
    return self['master']
end

-------------------------------------
-- function getMemberCnt
-------------------------------------
function StructClan:getMemberCnt()
    return self['member_cnt']
end

-------------------------------------
-- function getJoinLv
-------------------------------------
function StructClan:getJoinLv()
    return self['joinlv'] or 1
end

-------------------------------------
-- function setCurrAttd
-------------------------------------
function StructClan:setCurrAttd(curr_attd)
    self['curr_attd'] = curr_attd
end

-------------------------------------
-- function getCurrAttd
-------------------------------------
function StructClan:getCurrAttd()
    return self['curr_attd'] or 0
end

-------------------------------------
-- function getLastAttd
-------------------------------------
function StructClan:getLastAttd()
    return self['last_attd'] or 0
end

-------------------------------------
-- function getMemberCntText
-------------------------------------
function StructClan:getMemberCntText()
    local max_member_cnt = self['member_max']
    local text = Str('{1}/{2}', self['member_cnt'], max_member_cnt)
    return text
end

-------------------------------------
-- function isAutoJoin
-------------------------------------
function StructClan:isAutoJoin()
    return self['join']
end

-------------------------------------
-- function getClanIntroText
-------------------------------------
function StructClan:getClanIntroText()
    local intro_text = self['intro']

    if (not intro_text) or (intro_text == '') then
        intro_text = Str('클랜 소개가 없습니다.')
    end

    return intro_text
end

-------------------------------------
-- function getClanNoticeText
-------------------------------------
function StructClan:getClanNoticeText()
    local notice_text = self['notice']

    if (not notice_text) or (notice_text == '') then
        notice_text = Str('등록된 공지가 없습니다.')
    end

    return notice_text
end

-------------------------------------
-- function getClanLv
-------------------------------------
function StructClan:getClanLv()
	return self['lv']
end

-------------------------------------
-- function getClanLvWithName
-------------------------------------
function StructClan:getClanLvWithName()
    return string.format('Lv.%d %s', self['lv'], self['name'])
end

-------------------------------------
-- function getClanExp
-------------------------------------
function StructClan:getClanExp()
	return self['exp']
end

-------------------------------------
-- function getClanExpRatio
-------------------------------------
function StructClan:getClanExpRatio()
	if (self['required_exp'] <= 0) then
		return 0
	end

	return (self['exp'] / self['required_exp'])
end

-------------------------------------
-- function getClanMaxMember
-------------------------------------
function StructClan:getClanMaxMember()
	return self['member_max']
end

-------------------------------------
-- function setClanBuffStruct
-------------------------------------
function StructClan:setClanBuffStruct(t_clan_buff)
	if (not self.m_structClanBuff) then
		self.m_structClanBuff = StructClanBuff()
	end
	if (not t_clan_buff) then
		return
	end
	self.m_structClanBuff:applyTableData(t_clan_buff)
end

-------------------------------------
-- function getClanBuffStruct
-------------------------------------
function StructClan:getClanBuffStruct()
	return self.m_structClanBuff
end

-------------------------------------
-- function getClanBuffByType
-------------------------------------
function StructClan:getClanBuffByType(clan_buff_type)
	if (not self.m_structClanBuff) or (not clan_buff_type) then
		return 0
	end
	return self.m_structClanBuff:getClanBuff(clan_buff_type)
end

-------------------------------------
-- function makeClanMarkIcon
-------------------------------------
function StructClan:makeClanMarkIcon()
    local icon = self.m_structClanMark:makeClanMarkIcon()
    return icon
end

-------------------------------------
-- function setMembersData
-- @brief 클랜원 리스트 설정
-------------------------------------
function StructClan:setMembersData(l_member_json)
    self.m_memberList = {}

    for i,v in pairs(l_member_json) do
        local user_info = StructUserInfoClan:create(v)
        local uid = user_info:getUid()
        self.m_memberList[uid] = user_info
    end
end

-------------------------------------
-- function getMemberStruct
-- @brief
-------------------------------------
function StructClan:getMemberStruct(uid)
    if (not self.m_memberList) then
        return nil
    end

    return self.m_memberList[uid]
end


-------------------------------------
-- function removeMember
-- @brief 맴버 삭제
-------------------------------------
function StructClan:removeMember(member_uid)
    if self.m_memberList[member_uid] then

        -- 출석 수 갱신
        if self.m_memberList[member_uid]:isTodayAttendance() then
            self['curr_attd'] = (self['curr_attd'] - 1)
        end
        
        self.m_memberList[member_uid] = nil
    end

    -- 맴버 수 갱신
    self['member_cnt'] = table.count(self.m_memberList)
end

-------------------------------------
-- function applySetting
-------------------------------------
function StructClan:applySetting(t_data)
    if (not t_data) then
        return
    end

    for i,v in pairs(self) do
        if (t_data[i] ~= nil) then
            self[i] = t_data[i]
        end
    end

    if (t_data['mark']) then
        self.m_structClanMark = StructClanMark:create(t_data['mark'])
    else
        self.m_structClanMark = StructClanMark()
    end
end

-------------------------------------
-- function applySimple
-------------------------------------
function StructClan:applySimple(t_data)
    self['name'] = t_data['name']
    if (t_data['mark']) then
        self.m_structClanMark = StructClanMark:create(t_data['mark'])
    else
        self.m_structClanMark = StructClanMark()
    end
end

-------------------------------------
-- function managerCntCalc
-- @brief 부마스터 숫자 리턴
-------------------------------------
function StructClan:managerCntCalc()
    if (not self.m_memberList) then
        return 0
    end

    local cnt = 0
    for i,v in pairs(self.m_memberList) do
        if (v:getMemberType() == 'manager') then
            cnt = (cnt + 1)
        end
    end

    return cnt
end