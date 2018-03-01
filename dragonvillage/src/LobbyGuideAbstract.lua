---------------------------------------------------------------------------------------------------------------
-- @brief 로비에서 마스터의 길 UI를 활용한 각종 안내를 하는 시스템
--        개별 안내 항목에 대한 조건 체크, 내용 등을 관리하는 클래스의 추상 클래스
-- @date 2018.02.28 sgkim
---------------------------------------------------------------------------------------------------------------

-------------------------------------
-- class LobbyGuideAbstract
-------------------------------------
LobbyGuideAbstract = class({
        m_bActiveGuide = 'boolean',
        m_titleStr = 'string',
        m_subTitleStr = 'string',
    })

-------------------------------------
-- function init
-------------------------------------
function LobbyGuideAbstract:init(title_str, sub_title_str)
    self.m_bActiveGuide = false
    self.m_titleStr = title_str or 'title'
    self.m_subTitleStr = sub_title_str or 'sub title'
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
    return self.m_titleStr
end

-------------------------------------
-- function getGuideSubTitleStr
-- @brief 이 안내의 부 제목
-- @return string
-------------------------------------
function LobbyGuideAbstract:getGuideSubTitleStr()
    return self.m_subTitleStr
end

-------------------------------------
-- function startGuide
-- @brief 안내 시작
-------------------------------------
function LobbyGuideAbstract:startGuide()
    -- 주로 팝업을 띄움
end

-------------------------------------
-- function checkCondition
-- @brief 조건 확인
-------------------------------------
function LobbyGuideAbstract:checkCondition()
end