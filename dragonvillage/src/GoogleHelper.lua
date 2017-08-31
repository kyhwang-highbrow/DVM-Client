-------------------------------------
-- table GoogleHelper
-------------------------------------
GoogleHelper = {
    isDirty = true
}


-------------------------------------
-- function isAvailable
-------------------------------------
function GoogleHelper.isAvailable()
    -- 안드로이드 인지 체크
    if (not CppFunctions:isAndroid()) then
        return false
    end
    -- 구글 로그인 상태인지 체크
    if (not g_localData:isGooglePlayConnected()) then
        return false
    end

    return true
end

-------------------------------------
-- function updateAchievement
-- @brief public
-------------------------------------
function GoogleHelper.updateAchievement(t_data)
    if (not GoogleHelper.isAvailable()) then
        return
    end

    if (GoogleHelper.checkAchievementClear(t_data)) then
        GoogleHelper.requestAchievementClear(t_data['achievement_id'])
    end
end

-------------------------------------
-- function checkClear
-------------------------------------
function GoogleHelper.checkAchievementClear(t_data)
    -- 업적의 키를 구해온다.
    local achv_key = GoogleHelper.makeIngameModeKey(t_data)

    -- 업적 리스트를 가져온다.
    local l_achievement = TableGoogleQuest():filterList('clear_type', achv_key)
    table.sort(l_achievement, function(a, b)
        return a['gqid'] < b['gqid']
    end)

    -- 업적을 클리어 여부 파악
    for i, t_google in pairs(l_achievement) do
        -- 마스터의 길과 로직 공유
        if (ServerData_MasterRoad.checkClear(t_google['clear_type'], t_google['clear_value'], t_data, {'raw_data'})) then
            -- id 전달
            t_data['achievement_id'] =  t_google['achievement_id']
            return true
        end
    end
end

-------------------------------------
-- function requestAchievementClear
-- @param achievementId : 업적 아이디
-- @param steps : 달성스텝, 0이면 모든 스텝을 한번에 달성
-------------------------------------
function GoogleHelper.requestAchievementClear(achievement_id, step)
    local step = step or 0
    local function cb_func(ret, info)
        if ret == 'success' then
        elseif ret == 'fail' then
        end
    end

    PerpleSDK:googleUpdateAchievements(achievement_id, step, cb_func)
end

-------------------------------------
-- function showAchievement
-------------------------------------
function GoogleHelper.showAchievement()
    PerpleSDK:googleShowAchievements(function(ret, info)
        if ret == 'success' then
        elseif ret == 'fail' then
            -- info : {"code":"@code", "msg":"@msg"}
            -- @code 가 '-1210' 일 경우 로그아웃한 것임
            local t_info = dkjson.decode(info)
            if t_info.code == '-1210' then
                g_localData:applyLocalData('off', 'local', 'googleplay_connected')
                GoogleHelper.setDirty(true)
            end
        end
    end)
end

-------------------------------------
-- function checkClear
-------------------------------------
function GoogleHelper.makeIngameModeKey(t_data)
    local achv_key = t_data['clear_key']
    
    if (achv_key) then
        return achv_key
    else
        local game_mode = t_data['game_mode']
        local dungeon_mode = t_data['dungeon_mode']
        if (game_mode == GAME_MODE_ANCIENT_TOWER) then
            return 'ply_tower'
        elseif (game_mode == GAME_MODE_COLOSSEUM) then
            return 'ply_clsm'
        elseif (dungeon_mode == NEST_DUNGEON_EVO_STONE) then
            return 'ply_ev'
        elseif (dungeon_mode == NEST_DUNGEON_TREE) then
            return 'ply_tree'
        elseif (dungeon_mode == NEST_DUNGEON_NIGHTMARE) then
            return 'ply_nm'
        else
            return 'clr_stg'
        end
    end
end

-------------------------------------
-- function allAchievementCheck
-- @brief 게스트로 플레이하다가 중간에 로그인한 유저를 위해서
-- 이미 클리어한 업적을 체크한다
-- 다만 서버와 연동없이 가능한 부분만을 체크한다.
-- @comment 타이틀에서 한번 업적을 체크하는데 사용한다.
-------------------------------------
function GoogleHelper.allAchievementCheck(finish_cb)
    if (not GoogleHelper.isAvailable()) then
        if (finish_cb) then
            finish_cb()
        end
        return
    end

    local clear_type, clear_value, is_clear
    for _, t_acheivement in pairs(TableGoogleQuest().m_orgTable) do
        clear_type = t_acheivement['clear_type']
        clear_value = t_acheivement['clear_value']
        is_clear = false

        -- 스테이지 클리어 체크
        if (clear_type == 'clr_stg') then
            local list = plSplit(clear_value, '-')
            local stage_id = makeAdventureID(1, list[1], list[2])
            is_clear = g_adventureData:isClearStage(stage_id)

        -- 레벨 달성 체크
        elseif (clear_type == 'u_lv') then
            is_clear = (clear_value < g_userData:get('lv'))

        -- 테이머 획득 체크
        elseif (clear_type == 't_get') then
            is_clear = (clear_value < g_tamerData:getTamerCount())

        end

        if (is_clear) then
            GoogleHelper.requestAchievementClear(t_acheivement['achievement_id'])
        end
    end

    if (finish_cb) then
        finish_cb()
    end
end

-------------------------------------
-- function setDirty
-------------------------------------
function GoogleHelper.setDirty(b)
    GoogleHelper.isDirty = b
end