-------------------------------------
-- class PatchChecker
-------------------------------------
PatchChecker = class({
	    m_app_version = '', -- 현재 앱 버전
        m_store_info = '',
    })

-- 업데이트가 필요한 상태
local NEED_UPDATE_STATUS = {
    [-1387] = 'recommend_app_update',
    [-1388] = 'necessary_app_update',
    [-1389] = 'patch_update',
}

-------------------------------------
-- function init
-------------------------------------
function PatchChecker:init()
    self.m_app_version = getAppVer()
    self.m_store_info = {}
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

        -- test (중간에 로컬에 저장된 패치 데이터 넘버 변경한 후 통신)
        -- g_patchData:load()
		t_param['patch_ver'] = g_patchData:get('patch_ver')
    end
end

----------------------------------------
-- function isUpdated
-- @brief 앱 업데이트와 패치 업데이트 검사
-- @breif get_patch_info 에서는 앱 업데이트 검사만
----------------------------------------
function PatchChecker:isUpdated(ret)
    local status = ret['status']
    if (not status) then return false end

    local update = NEED_UPDATE_STATUS[status]
    if (update) then
        if (update == 'recommend_app_update') then
            self:needRecommendAppUpdate()

        elseif (update == 'necessary_app_update') then
            self:needNecessaryAppUpdate()

        elseif (update == 'patch_update') then
            self:needPatchUpdate()

        else
            error('invalid status: '..status)
        end

        return true
    else
        return false
    end
end

----------------------------------------
-- function needRecommendAppUpdate
----------------------------------------
function PatchChecker:needRecommendAppUpdate()
    -- 권장 업데이트
    local msg = Str('새로운 버전의 게임이 업데이트 되었습니다. 스토어를 통해 업데이트를 하기바랍니다.')
    MakeSimplePopup(POPUP_TYPE.YES_NO, msg, function() self:gotoAppStore() end)
end

----------------------------------------
-- function needNecessaryAppUpdate
----------------------------------------
function PatchChecker:needNecessaryAppUpdate()
    -- 필수 업데이트
    local msg = Str('버전이 낮아서 게임에 접속할 수 없습니다. 스토어를 통해 업데이트를 하기바랍니다.')
    MakeSimplePopup(POPUP_TYPE.OK, msg, function() self:gotoAppStore() end)
end

----------------------------------------
-- function needPatchUpdate
----------------------------------------
function PatchChecker:needPatchUpdate()
    local msg = Str('새로운 패치가 있습니다. 게임이 종료됩니다. 자동으로 재시작된 후 패치가 적용됩니다.')
    MakeSimplePopup(POPUP_TYPE.OK, msg, function() restart() end)
end

----------------------------------------
-- function gotoAppStore
----------------------------------------
function PatchChecker:gotoAppStore()
    local market_name = getMarketName()
    local test_url = 'http://play.google.com/store/apps/details?id=com.perplelab.sampl4kakao'
    UI_WebView(test_url)
end