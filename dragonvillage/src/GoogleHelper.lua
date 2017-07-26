-------------------------------------
-- table GoogleHelper
-------------------------------------
GoogleHelper = {
    isDirty = true
}


-------------------------------------
-- function updateAchievement
-- @brief public
-------------------------------------
function GoogleHelper.updateAchievement(t_data)
    -- 안드로이드만 한다. 구글 로그인인지도 체크해야하나?
    --if (not isAndroid()) then
        --return
    --end

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
        if (ServerData_MasterRoad.checkClear(t_google['clear_type'], t_google['clear_value'], t_data)) then
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
    if (not isAndroid()) then
        return ccdisplay('구글 업적 클리어 테스트 achievement_id : ' .. achievement_id)
    end

    local step = step or 0
    PerpleSDK:googleUpdateAchievements(achievement_id, step, function(ret, info)
        if ret == 'success' then
        elseif ret == 'fail' then
        end
    end)
end

-------------------------------------
-- function showAchievement
-------------------------------------
function GoogleHelper.showAchievement()
    if (not isAndroid()) then
        return ccdisplay('구글 업적 보기 테스트')
    end

    PerpleSDK:googleShowAchievements(function(ret, info)
        if ret == 'success' then
        elseif ret == 'fail' then
            -- info : {"code":"@code", "msg":"@msg"}
            -- @code 가 '-1210' 일 경우 로그아웃한 것임
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
-- function allAcheivementCheck
-- @brief 게스트로 플레이하다가 중간에 로그인한 유저를 위해서
-- 이미 클리어한 업적을 체크한다
-- 다만 서버와 연동없이 가능한 부분만을 체크한다.
-------------------------------------
function GoogleHelper.allAcheivementCheck(t_data)
    local clear_type, is_clear
    for _, t_acheivement in paris(TableGoogleQuest().m_orgTable) do
        clear_type = t_acheivement['clear_type']
        is_clear = false

        if (clear_type == 'clr_stg') then
            is_clear = g_adventureData:isClearStage(stage_id)
        elseif (clear_type == 'u_lv') then
            is_clear = (t_acheivement['clear_value'] < g_userData:get('lv'))
        elseif (clear_type == 't_get') then
            is_clear = (t_acheivement['clear_value'] < g_tamerData:getTamerCount())
        end

        if (is_clear) then
            GoogleHelper.requestAchievementClear(t_acheivement['achievement_id'])
        end
    end
end

-------------------------------------
-- function setDirty
-------------------------------------
function GoogleHelper.setDirty(b)
    GoogleHelper.isDirty = b
end