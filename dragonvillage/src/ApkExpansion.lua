local MIN_GUIDE_TIME = 3                  -- 패치 가이드 노출시 최소 노출 시간  
local BYTE_TO_MB = 1024 * 1024
  
-------------------------------------
-- class ApkExpansion
-------------------------------------
ApkExpansion = class({
        m_finishCB = 'function',        -- 패치가 완료되었을 때 콜백 함수

        m_showGuideTime = '',

		m_patchScene = 'ScenePatch',
		m_patchGuideUI = 'UI',

		m_patchLabel = 'cc.Label',
		m_patchGauge = 'cc.ProgressBar',


        m_versionCode = 'number',
        m_fileSize = 'number(byte)',
    })

-------------------------------------
-- function init
-------------------------------------
function ApkExpansion:init(scene, version_code, file_size)
	self.m_patchScene = scene
	self.m_patchGuideUI = nil
	self.m_patchLabel = self.m_patchScene.m_vars['downloadLabel']
	self.m_patchGauge = self.m_patchScene.m_vars['downloadGauge']

    self.m_versionCode = version_code
    self.m_fileSize = file_size
end

-------------------------------------
-- function doStep
-------------------------------------
function ApkExpansion:doStep()

    cclog('## ApkExpansion SDKEvent call!!')

    local param_str = tostring(self.m_versionCode) .. ';' .. tostring(self.m_fileSize)
    local md5 = ''

    cclog('# info_str : ' .. param_str)
    cclog('# md5 : ' .. md5)

    local function callback(ret, info)
        cclog('## ApkExpansion ' .. tostring(ret) .. '!!')
        cclog('info : ' .. info)

        if (ret == 'start') then
            -- 다운로드 시작, 다운로드 진행 표시 UI 열기
            self:show_patch_guide()

        elseif (ret == 'complete') then
            if (info == 'pass') then
                -- 다운로드 불필요, 바로 게임 시작
            elseif (info == 'end') then
                -- 다운로드 완료, 다운로드 진행 표시 UI 닫고 게임 시작
            end

            self:finish()

        elseif (ret == 'progress') then
            -- 다운로드 진행 중
            -- info :{'current':@다운로드받은크기, 'total':@전체크기}
            local info_json = dkjson.decode(info)
            self:refreshProgressInfo_useJson(info_json)

        elseif (ret == 'error') then
            -- info :{'code':@code, 'msg':'@message'}
            -- [오류 처리 가이드]에 따라 처리
            self:apkExpansionErrorHandler(info)
        end
    end

    -- APK 확장 파일 다운로드 체크 및 시작
    if (getAppVerNum() > AppVer_strToNum('1.0.1')) then
        SDKManager:apkExpansionCheck(param_str, md5, function(ret, info)
            if ret == 'download' then
                local function ok_cb()
                    SDKManager:apkExpansionStart(param_str, md5, callback)
                end
                MakeSimplePopup2(POPUP_TYPE.OK, "게임 실행에 필요한 추가 데이터 파일이 손상되었습니다.\n손상된 파일을 다시 설치하기 위해 '사진/미디어/파일 액세스' 접근 권한이 필요합니다.", "권한 요청을 거부할 경우 정상적인 게임 실행이 불가능하며\n앱을 삭제한 후 다시 설치하셔야 합니다.", ok_cb)
            else
                self:finish()
            end
        end)
    else
        SDKManager:apkExpansionStart(param_str, md5, callback)
    end

end

-------------------------------------
-- function update
-------------------------------------
function ApkExpansion:update(dt)
    if self.m_showGuideTime then
        self.m_showGuideTime = self.m_showGuideTime + dt
    end

	-- 패치가이드 있을 시 패치가이드 업데이트
	if (self.m_patchGuideUI) then
		self.m_patchGuideUI:update(dt)
	end
end

-------------------------------------
-- function finish
-------------------------------------
function ApkExpansion:finish()
    if self.m_patchGuideUI then
        self.m_patchGuideUI.root:removeFromParent()
        self.m_patchGuideUI = nil
    end

    if self.m_finishCB then
        self.m_finishCB()
    end
end

-------------------------------------
-- function refreshProgressInfo_useJson
-- @brief 패치 진행 정보 UI에 출력 (json 활용)
-------------------------------------
function ApkExpansion:refreshProgressInfo_useJson(info_json)
    if (not info_json) then
        return
    end

    if (not info_json['current']) then
        return
    end

    if (not info_json['total']) then
        return
    end

    self:refreshProgressInfo(info_json['current'], info_json['total'])
end

-------------------------------------
-- function refreshProgressInfo
-- @brief 패치 진행 정보 UI에 출력
-------------------------------------
function ApkExpansion:refreshProgressInfo(current, total)

    -- 다운로드 사이즈와 퍼센트 계산
	local curr_size = string.format('%.2f', current/BYTE_TO_MB)
	local total_size = string.format('%.2f', total/BYTE_TO_MB)
	local download_percent = current / total * 100
	local download_str = string.format('%.2f', download_percent)

    -- UI 출력 (패치 가이드가 있는 경우 패치가이드의 label과 gauge를 가리킨다)
    if self.m_patchLabel then
	    self.m_patchLabel:setString(curr_size .. 'MB /' .. total_size .. 'MB (' .. download_str .. '%)')
    end

    if self.m_patchGauge then
	    self.m_patchGauge:setPercentage(download_percent)
    end
end

-------------------------------------
-- function show_patch_guide
-- @brief 받을 패치 있으면 패치 가이드 UI 무조건 호출
-------------------------------------
function ApkExpansion:show_patch_guide()
	local vars = self.m_patchScene.m_vars
	local ui = UI_LoadingGuide_Patch()
	vars['patchGuideNode']:addChild(ui.root)

    self.m_showGuideTime = 0
	self.m_patchGuideUI = ui

	-- 가이드 ui의 object 등록
	self.m_patchLabel = ui.vars['loadingLabel']
	self.m_patchGauge = ui.vars['loadingGauge']
    self.m_patchLabel:setString('')
    self.m_patchGauge:setPercentage(0)

	-- 사용하지 않는 object들 off
	vars['animator']:setVisible(false)
	vars['downloadLabel']:setVisible(false)
	vars['downloadGauge']:setVisible(false)
	vars['messageLabel']:setVisible(false)
end

-------------------------------------
-- function close_patch_guide
-- @brief
-------------------------------------
function ApkExpansion:close_patch_guide()
    if (self.m_patchGuideUI) then
        self.m_patchGuideUI.root:removeFromParent()
        self.m_patchGuideUI = nil

        -- 타이틀 UI 다시 보이게 변경
        self.m_patchScene.m_vars['messageLabel']:setVisible(true)
        self.m_patchScene.m_vars['animator']:setVisible(true)
    end

    self.m_patchLabel = nil
    self.m_patchGauge = nil
end

-------------------------------------
-- function apkExpansionErrorHandler
-- @brief
-- @param info_str string "{'code':@code, 'msg':'@message'}"
-------------------------------------
function ApkExpansion:apkExpansionErrorHandler(info_str)
    local msg = Str('추가 데이터 파일 다운로드에 실패하였습니다.\n다시 시도하시겠습니까?')

    if (not info_str) then
        msg = msg .. '\n (info_str is null)'
        return self:errorHandler(msg)
    end

    local info_json = dkjson.decode(info_str)

    if (not info_json) then
        msg = msg .. '\n (info_json is null)'
        return self:errorHandler(msg)
    end

    if (not info_json['code']) then
        msg = msg .. '\n (invalid info_json)'
        return self:errorHandler(msg)
    end

    local code = info_json['code']

    local STATE_PAUSED_NETWORK_UNAVAILABLE  = 6 -- 네트워크가 연결되어 있지 않은 경우
    local STATE_PAUSED_BY_REQUEST  = 7          -- SDKManager:apkExpansionPause() 로 강제로 다운로드 중단시킨 경우
    local STATE_PAUSED_ROAMING = 12             -- 로밍 중, 로밍 중이므로 요금에 대한 경고를 하고 계속 진행/중단 처리한다.
    local STATE_FAILED_UNLICENSED = 15          -- 정식으로 앱을 다운로드 받지 않은 경우, APK를 별도로 설치하여 테스트하는 개발 버전에선 실패 처리하지 않고 그대로 진행시킨다.
    local STATE_FAILED_SDCARD_FULL = 17         -- 외부 저장 장치의 용량이 부족한 경우
    local STATE_FAILED_PERMISSION_DENIED = 19   -- '사진/미디어/파일 액세스' 접근 권한을 거부한 경우

    -- 6 네트워크가 연결되어 있지 않은 경우
    if (code == STATE_PAUSED_NETWORK_UNAVAILABLE) then
        local msg = Str('네트워크 연결을 확인하세요.')
        return self:errorHandler(msg)

    -- 7 SDKManager:apkExpansionPause() 로 강제로 다운로드 중단시킨 경우
    elseif (code == STATE_PAUSED_BY_REQUEST) then
        -- 아직은 별도로 처리하지 않음 (sgkim 2017-07-27)
        return self:errorHandler(msg)

    -- 12 로밍 중, 로밍 중이므로 요금에 대한 경고를 하고 계속 진행/중단 처리한다.
    elseif (code == STATE_PAUSED_ROAMING) then
        local msg = Str('데이터 로밍 시 과다한 요금이 청구될 수 있습니다. 계속 진행하시겠습니까?')
        local function ok_btn_cb()
            -- APK 확장파일 다운로드, 중단된 다운로드를 재개함
            SDKManager:apkExpansionContinue()
        end
        local function cancel_btn_cb()
            self:openFailPopup()
        end
        MakeSimplePopup(POPUP_TYPE.YES_NO, msg, ok_btn_cb, cancel_btn_cb)

    -- 15 정식으로 앱을 다운로드 받지 않은 경우, APK를 별도로 설치하여 테스트하는 개발 버전에선 실패 처리하지 않고 그대로 진행시킨다.
    --elseif (code == STATE_FAILED_UNLICENSED) then -- else에서 공통으로 처리함

    -- 17 외부 저장 장치의 용량이 부족한 경우
    elseif (code == STATE_FAILED_SDCARD_FULL) then
        self:openFailPopup_sdcardFull()

    elseif (code == STATE_FAILED_PERMISSION_DENIED) then
        msg = '파일 설치를 위한 접근 권한 거부로\n추가 데이터 파일의 다운로드 및 설치를\n진행하지 못했습니다.\n다시 시도하시겠습니까?'
        return self:errorHandler(msg)

    else
        if info_str then
            msg = msg .. '\n(' .. info_str .. ')'
        end
        return self:errorHandler(msg)
    end
end

-------------------------------------
-- function errorHandler
-------------------------------------
function ApkExpansion:errorHandler(msg)
    if msg then
        msg = msg
    else
        msg = Str('서버와 연결할 수 없습니다.\n다시 시도하시겠습니까?')
    end

    local function ok_btn_cb()
        self:doStep()
    end

    local function cancel_btn_cb()
        MakeSimplePopup(POPUP_TYPE.OK, '정상적인 시작이 불가능하여 앱을 종료합니다.\n종료 후 다시 실행해 주세요.', function()
            closeApplication()
        end)
    end

    MakeSimplePopup(POPUP_TYPE.YES_NO, msg, ok_btn_cb, cancel_btn_cb)
end

-------------------------------------
-- function setFinishCB
-------------------------------------
function ApkExpansion:setFinishCB(finish_cb)
    self.m_finishCB = finish_cb
end

-------------------------------------
-- function openFailPopup
-------------------------------------
function ApkExpansion:openFailPopup()
    self:close_patch_guide()

    local function ok_btn_cb()
        closeApplication()
    end

    local msg = Str('추가 리소스 다운로드에 실패하여 게임을 시작할 수 없습니다.\n앱을 완전 종료 후 다시 접속해주세요.')
    MakeSimplePopup(POPUP_TYPE.OK, msg, ok_btn_cb)
end

-------------------------------------
-- function openFailPopup_sdcardFull
-------------------------------------
function ApkExpansion:openFailPopup_sdcardFull()
    self:close_patch_guide()

    local function ok_btn_cb()
        closeApplication()
    end

    local msg = Str('저장공간이 부족하여 추가 리소스 다운로드에 실패하였습니다.\n저장공간 확보 후 다시 접속해주세요.')
    MakeSimplePopup(POPUP_TYPE.OK, msg, ok_btn_cb)
end