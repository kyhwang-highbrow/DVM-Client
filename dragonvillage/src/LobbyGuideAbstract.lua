---------------------------------------------------------------------------------------------------------------
-- @brief 로비에서 마스터의 길 UI를 활용한 각종 안내를 하는 시스템
--        개별 안내 항목에 대한 조건 체크, 내용 등을 관리하는 클래스의 추상 클래스
-- @date 2018.02.28 sgkim
---------------------------------------------------------------------------------------------------------------

-------------------------------------
-- class LobbyGuideAbstract
-------------------------------------
LobbyGuideAbstract = class({
        m_tData = 'table',
        m_bActiveGuide = 'boolean',
    })

-------------------------------------
-- function init
-------------------------------------
function LobbyGuideAbstract:init(data)
    self.m_tData = data
    self.m_bActiveGuide = false
end


-------------------------------------
-- function isActiveGuide
-- @brief 이 안내의 활성화 여부를 리턴
-- @return boolean
-------------------------------------
function LobbyGuideAbstract:isActiveGuide()
    return self.m_bActiveGuide
end

-------------------------------------
-- function getGuideTitleStr
-- @brief 이 안내의 제목
-- @return string
-------------------------------------
function LobbyGuideAbstract:getGuideTitleStr()
    return self.m_tData['t_title']
end

-------------------------------------
-- function getGuideSubTitleStr
-- @brief 이 안내의 부 제목
-- @return string
-------------------------------------
function LobbyGuideAbstract:getGuideSubTitleStr()
    return self.m_tData['t_sub_title']
end

-------------------------------------
-- function startGuide
-- @brief 안내 시작
-------------------------------------
function LobbyGuideAbstract:startGuide()
    self:startCustomGuide()

    local data = self.m_tData

    -- 기간 체크
    local term = data['term']
    local key = data['key']

    -- 일간
    if (term == 'daily') then
        g_lobbyGuideData:setDailySeen(key)

    -- 주간
    elseif (term == 'weekly') then
        g_lobbyGuideData:setWeeklySeen(key)

    -- 월간
    elseif (term == 'monthly') then
        g_lobbyGuideData:setMonthlySeen(key)

    -- 특정 시간
    else
        local term_day = tonumber(term)
        if term_day then
            local server_time = ServerTime:getInstance():getCurrentTimestampSeconds()
            g_lobbyGuideData:setTimestamp(key, server_time)
        end
    end
end

-------------------------------------
-- function startCustomGuide
-- @brief 안내 시작
-------------------------------------
function LobbyGuideAbstract:startCustomGuide()

end

-------------------------------------
-- function checkCondition
-- @brief 조건 확인
-------------------------------------
function LobbyGuideAbstract:checkCondition()
    self.m_bActiveGuide = false
    local data = self.m_tData

    -- 컨텐츠 오픈 체크
    if (g_contentLockData:isContentLock(data['content_name'])) then
        return
    end

    -- 레벨 체크
    local lv = g_userData:get('lv')
    if (lv < data['lv']) then
        return
    end

    -- 요일 조건 체크
	local wday = pl.Date():weekday_name()
	if (data[wday] ~= 'O') then
        return
    end

    -- 기간 체크
    local term = data['term']
    local key = data['key']
    if (term == 'daily') then -- 일간
        if g_lobbyGuideData:getDailySeen(key) then
            return
        end

    elseif (term == 'weekly') then -- 주간
        if g_lobbyGuideData:getWeeklySeen(key) then
            return
        end

    elseif (term == 'monthly') then -- 월간
        if g_lobbyGuideData:getMonthlySeen(key) then
            return
        end

    else -- 특정 시간
        local term_day = tonumber(term)
        if term_day then
            local term_sec = (term_day * 24 * 60 * 60)
            local server_time = ServerTime:getInstance():getCurrentTimestampSeconds()
            local timestamp = g_lobbyGuideData:getTimestamp(key) or (server_time - term_sec)

            local gap = (server_time - timestamp)
            

            if (gap < term_sec) then
                return
            end
        end
    end



    if (not self:checkCustomCondition()) then
        return
    end

    self.m_bActiveGuide = true
end

-------------------------------------
-- function checkCustomCondition
-- @brief 조건 확인
-------------------------------------
function LobbyGuideAbstract:checkCustomCondition()
    return true
end