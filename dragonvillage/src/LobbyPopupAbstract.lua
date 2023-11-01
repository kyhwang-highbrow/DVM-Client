---------------------------------------------------------------------------------------------------------------
-- @brief 로비 팝업을 조건체크해서 띄우는 시스템
--        개별 안내 항목에 대한 조건 체크, 내용 등을 관리하는 클래스의 추상 클래스
-- @date 2018.05.29 sgkim
---------------------------------------------------------------------------------------------------------------

-------------------------------------
-- class LobbyPopupAbstract
-------------------------------------
LobbyPopupAbstract = class({
        m_tData = 'table',
        m_bActiveGuide = 'boolean',
    })

-------------------------------------
-- function init
-------------------------------------
function LobbyPopupAbstract:init(data)
    self.m_tData = data
    self.m_bActiveGuide = false
end


-------------------------------------
-- function isActiveGuide
-- @brief 이 안내의 활성화 여부를 리턴
-- @return boolean
-------------------------------------
function LobbyPopupAbstract:isActiveGuide()
    return self.m_bActiveGuide
end

-------------------------------------
-- function getGuideTitleStr
-- @brief 이 안내의 제목
-- @return string
-------------------------------------
function LobbyPopupAbstract:getGuideTitleStr()
    return self.m_tData['t_title']
end

-------------------------------------
-- function getGuideSubTitleStr
-- @brief 이 안내의 부 제목
-- @return string
-------------------------------------
function LobbyPopupAbstract:getGuideSubTitleStr()
    return self.m_tData['t_sub_title']
end

-------------------------------------
-- function getPopupKey
-- @brief 팝업 종류
-- @return string or number
-------------------------------------
function LobbyPopupAbstract:getPopupKey()
    return self.m_tData['popup_key']
end

-------------------------------------
-- function startGuide
-- @brief 안내 시작
-------------------------------------
function LobbyPopupAbstract:startGuide()
    self:startCustomGuide()

    local data = self.m_tData

    -- 기간 체크
    local key = data['key']
    local server_time = ServerTime:getInstance():getCurrentTimestampSeconds()
    g_lobbyPopupData:setTimestamp(key, server_time)
end

-------------------------------------
-- function startCustomGuide
-- @brief 안내 시작
-------------------------------------
function LobbyPopupAbstract:startCustomGuide()

end

-------------------------------------
-- function checkCondition
-- @brief 조건 확인
-------------------------------------
function LobbyPopupAbstract:checkCondition()
    self.m_bActiveGuide = false
    local data = self.m_tData

    -- 레벨 체크 (min, max 값까지 모두 포함)
    local lv = g_userData:get('lv')
    local min_lv = tonumber(data['min_lv'])
    local max_lv = tonumber(data['max_lv'])
    if min_lv and (lv < min_lv) then
        return
    end
    if max_lv and (max_lv < lv) then
        return
    end

    -- 요일 조건 체크
	local wday = pl.Date():weekday_name()
	if (data[wday] ~= 'O') then
        return
    end

    -- 기간 체크 (시작, 종료 시간)
    local start_date = data['start_date']
    local end_date = data['end_date']
    local ret_val = CheckValidDateFromTableDataValue(start_date, end_date)
    if (ret_val == false) then
        return
    end

    -- 노출 간격 체크
    local interval = tonumber(data['interval'])
    local key = data['key']
    if interval then
        local term_sec = (interval * 24 * 60 * 60)
        local server_time = ServerTime:getInstance():getCurrentTimestampSeconds()
        local timestamp = g_lobbyPopupData:getTimestamp(key) or (server_time - term_sec)

        local gap = (server_time - timestamp)

        if (gap < term_sec) then
            return
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
function LobbyPopupAbstract:checkCustomCondition()
    return true
end

return LobbyPopupAbstract