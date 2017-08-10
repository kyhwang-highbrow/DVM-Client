TUTORIAL = {
    INTRO_FIGHT = 'intro',
    COLOSSEUM = 'tutorial_colosseum',
    ANCIENT = 'tutorial_ancient_tower',
}

-------------------------------------
-- class ServerData_Tutorial
-------------------------------------
ServerData_Tutorial = class({
        m_serverData = 'ServerData',
        m_tTutorialClearInfo = 'table',
    })

-------------------------------------
-- function init
-------------------------------------
function ServerData_Tutorial:init(server_data)
    self.m_serverData = server_data
    self.m_tTutorialClearInfo = {}
end

-------------------------------------
-- function checkTutorialDone
-- @brief 해당 튜토리얼 클리어 여부
-------------------------------------
function ServerData_Tutorial:isTutorialDone(tutorial_key, cb_func)
    local is_done = self.m_tTutorialClearInfo[tutorial_key]

    if (is_done == true) then
        -- nothing to do

    elseif (is_done == false) then
        cb_func()

    elseif (is_done == nil) then
        self:request_tutorialInfo(tutorial_key, cb_func)

    end
end

-------------------------------------
-- function request_tutorialInfo
-- @brief 해당 튜토리얼 정보
-------------------------------------
function ServerData_Tutorial:request_tutorialInfo(tutorial_key, finish_cb, fail_cb)
    -- 유저 ID
    local uid = g_userData:get('uid')

    local tutorial_key = tutorial_key

    -- 성공 콜백
    local function success_cb(ret)
        -- 다시 호출하지 않도록 저장해둠
        self.m_tTutorialClearInfo[tutorial_key] = ret['tutorial']

        if finish_cb then
            finish_cb(ret)
        end
    end

    -- 네트워크 통신
    local ui_network = UI_Network()
    ui_network:setUrl('/users/tutorial/info')
    ui_network:setParam('uid', uid)
    ui_network:setParam('tutorial', tutorial_key)
    ui_network:hideLoading()
    ui_network:setSuccessCB(success_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()

    return ui_network
end

-------------------------------------
-- function request_tutorialSave
-- @brief 해당 튜토리얼 클리어 상태 저장
-------------------------------------
function ServerData_Tutorial:request_tutorialSave(tutorial_key, finish_cb)
    -- 유저 ID
    local uid = g_userData:get('uid')

    local tutorial_key = tutorial_key

    -- 성공 콜백
    local function success_cb(ret)
        self.m_tTutorialClearInfo[tutorial_key] = ret['tutorial']

        if (tutorial_key == TUTORIAL.INTRO_FIGHT) then
            -- @analytics
            Analytics:firstTimeExperience('Tutorial_Intro')
        end

        if finish_cb then
            finish_cb(ret)
        end
    end

    -- 네트워크 통신
    local ui_network = UI_Network()
    ui_network:setUrl('/users/tutorial/done')
    ui_network:setParam('uid', uid)
    ui_network:setParam('tutorial', tutorial_key)
    ui_network:hideLoading()
    ui_network:setSuccessCB(success_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()

    return ui_network
end
