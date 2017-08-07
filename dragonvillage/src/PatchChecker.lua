-------------------------------------
-- class PatchChecker
-------------------------------------
PatchChecker = class({
	    m_app_version = '', -- 현재 앱 버전
        m_caching_ret = '',
        m_pass_func = '',
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
    end
end

----------------------------------------
-- function isUpdated
-- @brief 앱 업데이트와 패치 업데이트 검사
----------------------------------------
function PatchChecker:isUpdated(ret, pass_func)
    local status = ret['status']
    local recommend = ret['new_version'] -- 권장 업데이트는 에러코드가 아님 (get_patch_info)

    if (not status) then return false end

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

    elseif (recommend) then
        local function pass_update_func()
            pass_func(ret)
        end

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
    local msg = Str('새로운 버전의 게임이 업데이트 되었습니다.\n스토어를 통해 업데이트를 하기바랍니다.')
    MakeSimplePopup(POPUP_TYPE.YES_NO, msg, function() self:gotoAppStore() end, function() pass_update_func() end)
end

----------------------------------------
-- function needNecessaryAppUpdate
-- @brief 필수 업데이트
----------------------------------------
function PatchChecker:needNecessaryAppUpdate()
    local msg = Str('버전이 낮아서 게임에 접속할 수 없습니다.\n스토어를 통해 업데이트를 하기바랍니다.')
    MakeSimplePopup(POPUP_TYPE.OK, msg, function() self:gotoAppStore() end)
end

----------------------------------------
-- function needPatchUpdate
-- @brief 패치 업데이트
----------------------------------------
function PatchChecker:needPatchUpdate()
    local msg = Str('새로운 패치가 있습니다.\n게임이 종료됩니다.\n자동으로 재시작된 후 패치가 적용됩니다.')
    MakeSimplePopup(POPUP_TYPE.OK, msg, function() restart() end)
end

----------------------------------------
-- function gotoAppStore
----------------------------------------
function PatchChecker:gotoAppStore()
    PerpSocial:SDKEvent('app_gotoStore', '', '')
end