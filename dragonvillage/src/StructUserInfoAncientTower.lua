local PARENT = StructUserInfo

-------------------------------------
-- class StructUserInfoAncientTower
-- @instance
-------------------------------------
StructUserInfoAncientTower = class(PARENT, {

        --------------------------------------
        --------------------------------------
        -- StructUserInfo의 변수들 참고용 (2017-06-30)
        m_bStruct = 'boolean',

        m_uid = 'number',
        m_lv = 'number',
        m_nickname = 'string',
        m_leaderDragonObject = '',

        m_winCnt = 'number',
        m_loseCnt = 'number',

        m_score = 'number',      -- score
        m_rank = 'number',       -- 월드 랭킹
        m_rankPercent = 'float', -- 월드 랭킹 퍼센트
    })

-------------------------------------
-- function create_forRanking
-- @brief 랭킹 유저 정보
-------------------------------------
function StructUserInfoAncientTower:create_forRanking(t_data)
    local user_info = StructUserInfoAncientTower()

    user_info.m_uid = t_data['uid']
    user_info.m_nickname = t_data['nick']
    user_info.m_lv = t_data['lv']
    user_info.m_rank = t_data['rank']
    user_info.m_rankPercent = t_data['rate']
    user_info.m_score = t_data['score']
    user_info.m_profileFrame = t_data['profile_frame']
    user_info.m_profileFrameExpiredAt = t_data['profile_frame_expired_at']

    user_info.m_leaderDragonObject = StructDragonObject(t_data['leader'])

    -- 드래곤 룬 세팅
    user_info.m_leaderDragonObject:setRuneObjects(t_data['runes'])

    -- 클랜
    if (t_data['clan_info']) then
        local struct_clan = StructClan({})
        struct_clan:applySimple(t_data['clan_info'])
        user_info:setStructClan(struct_clan)
    end
    
    return user_info
end

-------------------------------------
-- function init
-------------------------------------
function StructUserInfoAncientTower:init()
        self.m_winCnt = 0
        self.m_loseCnt = 0

        self.m_score = 0
        self.m_rank = 0
        self.m_rankPercent = nil
end

-------------------------------------
-- function applyTableData
-- @breif 단순 데이터 table에서 struct로 맴버 변수를 설정하는 함수
-------------------------------------
function StructUserInfoAncientTower:applyTableData(data)
end

-------------------------------------
-- function getUserText
-- @brief
-------------------------------------
function StructUserInfoAncientTower:getUserText()
    local str = Str('Lv.{1} {2}', self.m_lv, self.m_nickname)
    return str
end

-------------------------------------
-- function getRankText
-- @brief
-------------------------------------
function StructUserInfoAncientTower:getRankText(detail)
    if (not self.m_rank) or (self.m_rank <= 0) then
        return Str('순위\n없음')
    end

    return Str('{1}위', comma_value(self.m_rank))

    -- @jhakim 190426 퍼센트를 기준으로 보상을 주지 않기 때문에 순위만 표시
    --[[
    -- 자세히 출력 (순위와 퍼센트)
    if detail then
        if (not self.m_rankPercent) then
            return Str('{1}위', comma_value(self.m_rank))
        else
            local percent_text = string.format('%.2f', self.m_rankPercent * 100)
            local text = Str('{1}위 ({2}%)', comma_value(self.m_rank), percent_text)
            return text
        end
    else
        -- 100위 이상은 퍼센트로 표시
        if self.m_rankPercent and (100 < self.m_rank) then
            return string.format('%.2f%%', self.m_rankPercent * 100)
        else
            return Str('{1}위', comma_value(self.m_rank))
        end
    end
    --]]
end

-------------------------------------
-- function getRankText2
-- @brief
-------------------------------------
function StructUserInfoAncientTower:getRankText2()
    if (not self.m_rank) or (self.m_rank <= 0) then
        return Str('순위\n없음')
    end

    if (not self.m_rankPercent) then
        return Str('{1}위', comma_value(self.m_rank))
    else
        local percent_text = string.format('%.2f', self.m_rankPercent * 100)
        local text = Str('{1}위', comma_value(self.m_rank)) .. '\n(' .. percent_text .. '%)'
        return text
    end

    return Str('순위\n없음')
end

-------------------------------------
-- function getScoreText
-- @brief
-------------------------------------
function StructUserInfoAncientTower:getScoreText()
    -- 서버에서 스코어 없을때 -1로 옴
    local score = math_max(self.m_score, 0)
    local text = Str('{1}점', comma_value(score))
    return text
end







