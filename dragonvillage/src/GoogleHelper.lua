-------------------------------------
-- table GoogleHelper
-------------------------------------
GoogleHelper = {}


-------------------------------------
-- function updateAchievement
-- @brief public
-------------------------------------
function GoogleHelper.updateAchievement(t_data)
    if (self.checkAchievementClear(t_data)) then
        self.requestAchievementClear(t_data['achievement_id'])
    end
end

-------------------------------------
-- function checkClear
-------------------------------------
function GoogleHelper.checkAchievementClear(t_data)
    local achv_key = t_data['achv_key']
    local l_achievement = TableGoogleQuest():filterList('clear_type', (achv_key))
    table.sort(l_achievement, function(a, b)

    end)


    for i, t_google in pairs(l_achievement) do
        -- 마스터의 길과 로직 공유
        if (ServerData_MasterRoad.checkClear(t_google['clear_type'], t_google['clear_value'], t_data)) then
            -- id 전달
            t_data['achievement_id'] =  t_google['gqid']

            return true
        end
    end
end

-------------------------------------
-- function requestAchievementClear
-------------------------------------
function GoogleHelper.requestAchievementClear(achievement_id, step)
    -- @achievementId : 업적 아이디
    -- @steps : 달성스텝, 0이면 모든 스텝을 한번에 달성
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
    PerpleSDK:googleShowAchievements(function(ret, info)
        if ret == 'success' then
        elseif ret == 'fail' then
            -- info : {"code":"@code", "msg":"@msg"}
            -- @code 가 '-1210' 일 경우 로그아웃한 것임
        end
    end)
end