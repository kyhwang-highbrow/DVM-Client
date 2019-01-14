-------------------------------------
-- class PatchChecker
-------------------------------------
PatchChecker = class({
	    m_app_version = '', -- 현재 앱 버전
        m_bRecommend = 'boolean',
    })

-- 업데이트가 필요한 상태
local NEED_UPDATE_STATUS = {
    [-1388] = 'necessary_app_update',
    [-1389] = 'patch_update',
}

-------------------------------------
-- function init
-------------------------------------
function PatchChecker:init()
    self.m_app_version = getAppVer()
    self.m_bRecommend = false
end

-------------------------------------
-- function getInstance
-------------------------------------
function PatchChecker:getInstance()
    if (not g_patchChecker) then
        g_patchChecker = PatchChecker()
    end
    
    return g_patchChecker
end

----------------------------------------
-- function addPatchInfo
-- @brief 버전과 패치정보를 삽입
----------------------------------------
function PatchChecker:addPatchInfo(t_param)
    if t_param and g_patchData then
		t_param['app_ver'] = self.m_app_version
		t_param['patch_ver'] = g_patchData:get('patch_ver')

        if (LIVE_SERVER_CONNECT) then
            t_param['app_ver'] = LIVE_SERVER_APP_VER
		    t_param['patch_ver'] = LIVE_SERVER_PATCH_VER
        end
    end
end

----------------------------------------
-- function isUpdated
-- @brief 앱 업데이트와 패치 업데이트 검사
-- @return bool true : 패치나 업데이트가 있음
--              false : 최신 버전의 상태
----------------------------------------
function PatchChecker:isUpdated(ret, pass_func)
    local status = ret['status']
    local recommend = ret['new_version'] -- 권장 업데이트는 에러코드가 아님 (get_patch_info)

    if (not status) then return false end

    if (LIVE_SERVER_CONNECT) then return false end -- 라이브 접속 허용시 업데이트 체크 안함

    local update = NEED_UPDATE_STATUS[status]
    if (update) then
        if (update == 'necessary_app_update') then
            self:needNecessaryAppUpdate()

        elseif (update == 'patch_update') then
            self:needPatchUpdate()

        else
            error('invalid update status: '..status)
        end
        return true

    elseif (recommend) and (not self.m_bRecommend) then
        local function pass_update_func()
            pass_func(ret)
        end
        self.m_bRecommend = true -- 권장 업데이트 팝업은 최초 1회만 띄워줌
        self:needRecommendAppUpdate(pass_update_func)
        return true

    else
        return false
    end
end

----------------------------------------
-- function needRecommendAppUpdate
-- @brief 권장 업데이트
----------------------------------------
function PatchChecker:needRecommendAppUpdate(pass_update_func)
    HideLoading()
    local msg = Str('새로운 버전의 게임이 업데이트 되었습니다.\n스토어를 통해 업데이트를 하기바랍니다.')
    MakeNetworkPopup(POPUP_TYPE.YES_NO, msg, function() self:gotoAppStore() end, function() pass_update_func() end)
end

----------------------------------------
-- function needNecessaryAppUpdate
-- @brief 필수 업데이트
----------------------------------------
function PatchChecker:needNecessaryAppUpdate()
    HideLoading()

    local msg
    -- 엑솔라 빌드
    if (PerpleSdkManager:xsollaIsAvailable()) then
        msg = Str('버전이 낮아서 게임에 접속할 수 없습니다.\n배포 페이지를 통해 업데이트를 하기바랍니다.')
    else
        msg = Str('버전이 낮아서 게임에 접속할 수 없습니다.\n스토어를 통해 업데이트를 하기바랍니다.')
    end
    MakeNetworkPopup(POPUP_TYPE.OK, msg, function() self:gotoAppStore() end)
end

----------------------------------------
-- function needPatchUpdate
-- @brief 패치 업데이트
----------------------------------------
function PatchChecker:needPatchUpdate()
    HideLoading()
    local msg = Str('새로운 패치가 있습니다.\n게임이 종료됩니다.\n자동으로 재시작된 후 패치가 적용됩니다.')
    MakeNetworkPopup(POPUP_TYPE.OK, msg, function() CppFunctions:restart() end)
end

----------------------------------------
-- function gotoAppStore
----------------------------------------
function PatchChecker:gotoAppStore()
    SDKManager:goToAppStore()
    closeApplication()
end