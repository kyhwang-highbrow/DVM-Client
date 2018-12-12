-------------------------------------
-- class ServerData_ContentLock
-------------------------------------
ServerData_ContentLock = class({
        m_serverData = 'ServerData',
    })

-------------------------------------
-- function init
-------------------------------------
function ServerData_ContentLock:init(server_data)
    self.m_serverData = server_data
end

-------------------------------------
-- function isContentLock
-- @param content_name string
-- table_content_lock.csv 2017-07-06 sgkim
--        adventure      모험
--        exploation	 탐험
--        nest_tree	     [네스트] 거목 던전
--        nest_evo_stone [네스트] 진화재료 던전
--        ancient        고대의 탑
--        attr_tower     시험의 탑
--        colosseum	     콜로세움
--        nest_nightmare [네스트] 악몽 던전
--        ancient_ruin   [네스트] 고대 유적 던전
-------------------------------------
function ServerData_ContentLock:isContentLock(content_name)
    local table_content_lock = TABLE:get('table_content_lock')
    local t_content_lock = table_content_lock[content_name]

    -- 지정되지 않은 콘텐츠 이름일 경우
    if (not t_content_lock) then
        --error('content_name : ' .. content_name)
        return false
    end

    -- 시험의 탑 경우 유저 레벨이 아닌 다른 조건으로 검사
    if (content_name == 'attr_tower') then
        local attr_tower_open = g_attrTowerData:isContentOpen()
        local is_lock = not attr_tower_open
        return is_lock
    end

    -- 클랜던전의 경우 클랜 가입 여부로 검사
    if (content_name == 'clan_raid') then
        local is_guest = g_clanData:isClanGuest()
        return is_guest
    end

    -- 고대 유적 던전의 경우 악몽 던전 클리어 여부로 검사
    if (content_name == 'ancient_ruin') then
        local is_open = g_ancientRuinData:isOpenAncientRuin()
        return (not is_open)
    end

    -- 필요 유저 레벨 지정
    local user_lv = g_userData:get('lv')
    local req_user_lv = t_content_lock['req_user_lv']
    if (user_lv < req_user_lv) then
        return true, req_user_lv
    end

    return false
end

-------------------------------------
-- function isContentBeta
-- @param content_name string
-------------------------------------
function ServerData_ContentLock:isContentBeta(content_name)

    -- 2017-09-15 ios정책에서 게임 내 beta/ demo / test / 체험판 / 타플랫폼 문구가 노출되지 않아야 합니다.
    if isIos() then
        return false
    end

    local table_content_lock = TABLE:get('table_content_lock')
    local t_content_lock = table_content_lock[content_name]

    -- 지정되지 않은 콘텐츠 이름일 경우
    if (not t_content_lock) then
        --error('content_name : ' .. content_name)
        return false
    end

    local beta = t_content_lock['beta']
    if (beta == true) or (beta == 'true') then
        return true
    end

    return false
end

-------------------------------------
-- function checkContentLock
-- @param content_name string
-- @param excute_func function
-------------------------------------
function ServerData_ContentLock:checkContentLock(content_name, excute_func)

    -- 콘텐츠 오픈 여부 받아옴
    local is_content_lock = self:isContentLock(content_name)
    if (not is_content_lock) then
        return true
    end

    local table_content_lock = TABLE:get('table_content_lock')
    local t_content_lock = table_content_lock[content_name]

    -- 잠금 안내
    local user_lv = g_userData:get('lv')
    local req_user_lv = t_content_lock['req_user_lv']
    local desc = t_content_lock['t_desc']
    local msg = Str(desc, req_user_lv) .. '\n' .. Str('{@R}(현재 유저 레벨은 {1}입니다)', user_lv)

    -- 시험의 탑 경우 유저 레벨이 아님, 예외 처리
    if (content_name == 'attr_tower') then
        msg = Str(desc, ATTR_TOWER_OPEN_FLOOR)
    end

    MakeSimplePopup(POPUP_TYPE.OK, msg)

    -- 함수 실행
    if excute_func then
        excute_func()
    end

    return false
end

-------------------------------------
-- function getOpenContentNameWithLv
-------------------------------------
function ServerData_ContentLock:getOpenContentNameWithLv(lv)
    local table_content_lock = TABLE:get('table_content_lock')

    for _, t_content_lock in pairs(table_content_lock) do
        local req_user_lv = t_content_lock['req_user_lv']

		-- 콘텐츠 오픈 팝업 skip항목 필터 (sgkim 2018.12.12 그림자의 신전, 그랜드 콜로세움)
        local skip_popup = toboolean(t_content_lock['skip_popup'])
        if (not skip_popup) and (req_user_lv == lv) then
            return t_content_lock['content_name']
        end
    end

    return nil
end