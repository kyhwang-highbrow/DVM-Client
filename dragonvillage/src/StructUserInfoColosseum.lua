local parent = StructUserInfo

-------------------------------------
-- class StructUserInfoColosseum
-- @instance
-------------------------------------
StructUserInfoColosseum = class(parent, {
        m_winCnt = 'number',
        m_loseCnt = 'number',

        m_rp = 'number',         -- ranking point
        m_rank = 'number',       -- 월드 랭킹
        m_tier = 'string',       -- 티어
        m_straight = 'number',   -- 연승 정보
    })

-------------------------------------
-- function init
-------------------------------------
function StructUserInfoColosseum:init()
end

-------------------------------------
-- function applyTableData
-- @breif 단순 데이터 table에서 struct로 맴버 변수를 설정하는 함수
-------------------------------------
function StructUserInfoColosseum:applyTableData(data)
end