-- @TODO : UI 연동하는 부분 관련해서 리스너(콜백 함수들)을 구현해야한다.
-- @TODO : web_path = 'http://test.perplelab.com/dv_test/'가 하드코딩되어있는데 적절한 위치로 이동해야 한다.

local PATCH_STATE = {}
PATCH_STATE.request_patch_info = 1  -- 패치 정보를 요청
PATCH_STATE.download_patch_file = 2 -- 패치 파일 다운로드
PATCH_STATE.decompression = 3       -- 패치 파일 압축 해제
PATCH_STATE.finish = 10             -- 종료

MIN_GUIDE_TIME = 3                  -- 패치 가이드 노출시 최소 노출 시간 
 
BYTE_TO_MB = 1024 * 1024
  
-------------------------------------
-- class PatchCore
-------------------------------------
PatchCore = class({
        m_type = 'string',              -- 'res'(추가 리소스), 'patch'(패치)
        m_state = 'PATCH_STATE',        -- 패치 코어의 상태
        m_finishCB = 'function',        -- 패치가 완료되었을 때 콜백 함수

        m_appVer = 'string',            -- 앱 버전(0.0.0은 추가리소스)
        m_currPatchVer = 'number',      -- 현재 패치 버전

        m_latestPatchVer = 'number',    -- 최신 패치 번호
        m_lDownloadRes = 'list',        -- 다운받아야 할 리소스 리스트
        
		m_downloadedSize = 'num',		-- 다운 받은 데이터양
		m_totalSize = 'number',         -- 다운받아야 할 총 데이터양

        m_currDownloadRes = 'table',    -- 현재 다운받고 있는 리소스 데이터

        m_showGuideTime = '',

        m_doStepReady = 'boolean',

		m_patchScene = 'ScenePatch',
		m_patchGuideUI = 'UI',

		m_patchLabel = 'cc.Label',
		m_patchGauge = 'cc.ProgressBar',
    })

-------------------------------------
-- function init
-------------------------------------
function PatchCore:init(scene, type, app_ver)
	self.m_patchScene = scene
	self.m_patchGuideUI = nil
    self.m_type = type
    
	local patch_data = PatchData:getInstance()

    -- 추가 리소스 다운로드
    if (type == 'res') then
        self.m_currPatchVer = patch_data:get('res_ver')
    elseif (type == 'patch') then
        self.m_currPatchVer = patch_data:get('patch_ver')
    else
        error('type : ' .. type)
    end

    self.m_appVer = app_ver
    self.m_state = PATCH_STATE.request_patch_info
	self.m_downloadedSize = 0
	self.m_totalSize = 0
    self.m_doStepReady = false

	self.m_patchLabel = self.m_patchScene.m_vars['downloadLabel']
	self.m_patchGauge = self.m_patchScene.m_vars['downloadGauge']
end

-------------------------------------
-- function doStep
-------------------------------------
function PatchCore:doStep()
    self.m_doStepReady = true
end

-------------------------------------
-- function doStep_
-------------------------------------
function PatchCore:doStep_()

    if (not self.m_doStepReady) then
        return
    end
    self.m_doStepReady = false
    
    -- 패치 정보 요청
    if (self.m_state == PATCH_STATE.request_patch_info) then
        cclog('## PatchCore : request_patch_info')
        self:st_requestPatchInfo()

    -- 개별 패치 파일 다운로드
    elseif (self.m_state == PATCH_STATE.download_patch_file) then
        cclog('## PatchCore : download_patch_file')
        self:st_downloadPatchFile()

    -- 개별 패치 파일 압축 해제
    elseif (self.m_state == PATCH_STATE.decompression) then
        cclog('## PatchCore : decompression')
        self:st_decompression()

    -- 패치 종료
    elseif (self.m_state == PATCH_STATE.finish) then
        if (not self:checkGuideTime()) then self:doStep() return end
        cclog('## PatchCore : finish')
        self:finish()
    end
end

-------------------------------------
-- function update
-------------------------------------
function PatchCore:update(dt)
    if self.m_doStepReady then
        self:doStep_()
    end

    if self.m_showGuideTime then
        self.m_showGuideTime = self.m_showGuideTime + dt
    end

	-- 다운로드 시작전 텍스트 안 보이게 함
	if (self.m_totalSize <= 0) or (self.m_downloadedSize <= 0) then
        if self.m_patchLabel then
            self.m_patchLabel:setString('')
        end
        return
    end

	-- 다운로드 사이즈와 퍼센트 계산
	local curr_size = string.format('%.2f', self.m_downloadedSize/BYTE_TO_MB)
	local total_size = string.format('%.2f', self.m_totalSize/BYTE_TO_MB)
	local download_percent = curr_size / total_size * 100
	local download_str = string.format('%.2f', download_percent)

	-- UI 출력 (패치 가이드가 있는 경우 패치가이드의 label과 gauge를 가리킨다)
    if self.m_patchLabel then
	    self.m_patchLabel:setString(curr_size .. 'MB /' .. total_size .. 'MB (' .. download_str .. '%)')
    end

    if self.m_patchGauge then
	    self.m_patchGauge:setPercentage(download_percent)
    end

	-- 패치가이드 있을 시 패치가이드 업데이트
	if (self.m_patchGuideUI) then
		self.m_patchGuideUI:update(dt)
	end
end

-------------------------------------
-- function finish
-------------------------------------
function PatchCore:finish()
    self:close_patch_guide()

    if self.m_finishCB then
        self.m_finishCB()
    end
end

-------------------------------------
-- function errorHandler
-------------------------------------
function PatchCore:errorHandler(msg)
    if msg then
        msg = msg
    else
        msg = Str('서버와 연결할 수 없습니다.\n다시 시도하시겠습니까?')
    end

    local function ok_btn_cb()
        self.m_state = PATCH_STATE.request_patch_info
        self:doStep()
    end

    local function cancel_btn_cb()
        self:finish()
    end

    MakeSimplePopup(POPUP_TYPE.OK, msg, ok_btn_cb, cancel_btn_cb)
end

-------------------------------------
-- function getDownloadPath
-- @brief 패치 파일을 다운받을 경로
-------------------------------------
function PatchCore:getDownloadPath()
    local path = cc.FileUtils:getInstance():getWritablePath()
    local dir = 'patch_' .. replace(self.m_appVer, '.', '_') .. '/'
    return path .. dir
end

-------------------------------------
-- function st_requestPatchInfo
-- @brief 패치 파일 정보 요청
-------------------------------------
function PatchCore:st_requestPatchInfo()
    -- 통신 성공 콜백
    local success_cb = function(ret)

        -- apk 확장 파일 정보 저장
        local patch_data = PatchData:getInstance()
        patch_data:setApkExtensionInfo(ret['apk_expantion'])
        patch_data:save()

        self:st_requestPatchInfo_successCB(ret)
    end

    -- 통신 실패 콜백
    local fail_cb = function()
        self:errorHandler()
    end

    -- API 호출
    Network_get_patch_info(self.m_appVer, success_cb, fail_cb)
end

-------------------------------------
-- function st_requestPatchInfo_successCB
-- @brief 패치 파일 요청 성공 콜백
-------------------------------------
function PatchCore:st_requestPatchInfo_successCB(ret)
    if (not ret) or (not ret['cur_patch_ver']) or (not ret['list']) then
        self:errorHandler(Str('패치 정보 오류\n다시 시도하시겠습니까?'))
        return
    end

    -- 최신패치버전 정보 및 패치 파일 리스트 셋팅
    self.m_latestPatchVer = ret['cur_patch_ver']
    self.m_lDownloadRes = {}
    self.m_totalSize = 0
    for i,v in ipairs(ret['list']) do
        local version = v['version']
        local size = v['size']
        if (self.m_currPatchVer < version) and (version <= self.m_latestPatchVer) then
            self.m_lDownloadRes[version] = v
            self.m_totalSize = self.m_totalSize + size
        end
    end

	cclog('## TOTAL PATCH SIZE ' .. self.m_totalSize)

	-- 다음 스텝으로 이동
	local function do_next_step()
		self.m_state = PATCH_STATE.download_patch_file 
		self:doStep()
	end

    -- 받을 패치 있으면 패치 가이드 UI 무조건 호출로 변경
	local function show_patch_guide()
		local vars = self.m_patchScene.m_vars
		local ui = UI_LoadingGuide_Patch()
		vars['patchGuideNode']:addChild(ui.root)

        self.m_showGuideTime = 0
		self.m_patchGuideUI = ui

		-- 가이드 ui의 object 등록
		self.m_patchLabel = ui.vars['loadingLabel']
		self.m_patchGauge = ui.vars['loadingGauge']

		-- 사용하지 않는 object들 off
		vars['animator']:setVisible(false)
		vars['downloadLabel']:setVisible(false)
		vars['downloadGauge']:setVisible(false)
		vars['messageLabel']:setVisible(false)
	end

	-- 50MB 보다 클 경우 확인 메세지 출력
	local std_size = 50 * BYTE_TO_MB
    if (std_size < self.m_totalSize) then
        -- 메가바이트로 크기 환산
        local size_mb = string.format('%.2f', self.m_totalSize / BYTE_TO_MB)
		local patch_str = Str('추가 데이터가 다운로드 됩니다.({1}MB).\n다운로드 하시겠습니까?\n[WIFI 연결을 권장하며 3G/LTE을 사용할 경우 과도한 요금이 부과 될 수 있습니다.]', size_mb)

        -- 수락 -> 다운로드 시작 및 패치 가이드 UI 호출
        local function ok_func()
            do_next_step()
            show_patch_guide()
        end
		
		-- 거절 -> 앱 종료!
		local function cancel_func()
			local function close_cb()
				cc.Director:getInstance():endToLua()
			end
			MakeSimplePopup(POPUP_TYPE.OK, Str('앱을 종료합니다.'), close_cb)
		end

		MakeSimplePopup(POPUP_TYPE.YES_NO, patch_str, ok_func, cancel_func)

    elseif (0 < self.m_totalSize) then
        do_next_step()
        show_patch_guide()

	else
		do_next_step()
    end
end

-------------------------------------
-- function st_downloadPatchFile
-- @brief 다운로드 요청
-------------------------------------
function PatchCore:st_downloadPatchFile(ret)
    
    -- false를 리턴하면 다운받을 패치파일이 없다는 뜻
    if (false == self:st_downloadPatchFile_setCurrDownloadRes()) then
        -- 다음 스텝으로 이동
        self.m_state = PATCH_STATE.finish 
        self:doStep()
        return
    end

    local t_download_res = self.m_currDownloadRes

    -- zip파일이 이미 다운로드 되어있다면..
    if self:st_downloadPatchFile_checkExist(t_download_res) then
        -- 다음 스텝으로 이동
        self.m_state = PATCH_STATE.decompression 
        self:doStep()
        return
    end
 
    do -- 다운로드 진행
        -- @analytics
        Analytics:firstTimeExperience('PatchDownload')

        local local_path = t_download_res['local_path']
        local web_path = t_download_res['web_path']

        -- 다운 성공 콜백
        local function success_cb()
            -- 다음 스텝으로 이동
            self.m_state = PATCH_STATE.decompression 
            self:doStep()
        end

        -- 다운 실패 콜백
        local function fail_cb(error_msg)
            os.remove(local_path)
            local msg = Str('패치 파일 다운로드 실패.')
            if error_msg and (error_msg ~= '') then
                msg = msg .. '\n(' .. error_msg .. ')'
            end
            msg = msg .. '\n' .. Str('다시 시도하시겠습니까?')
            self:errorHandler(msg)
        end

        -- 진행 정도 콜백
        local function progress(size)
            cclog('## PatchCore : size ' .. size)
			self.m_downloadedSize = self.m_downloadedSize + size
        end

        -- 다운로드 요청
        Network:download(web_path, local_path, success_cb, fail_cb, progress)
    end
end

-------------------------------------
-- function st_downloadPatchFile_setCurrDownloadRes
-- @brief m_lDownloadRes리스트 중 다음순서로 다운받을 zip파일 데이터를 지정함
-- @return boolean true리턴 시 현재 다운받을 파일이 있다는 뜻
-------------------------------------
function PatchCore:st_downloadPatchFile_setCurrDownloadRes()
    if self.m_currDownloadRes then
        return true
    end

    -- self.m_currPatchVer 증가
    while true do
        self.m_currPatchVer = (self.m_currPatchVer + 1)
        
        if self.m_lDownloadRes[self.m_currPatchVer] then
            break
        end

        -- 패치 받을 파일이 없음
        if (self.m_currPatchVer >= self.m_latestPatchVer) then
            return false
        end
    end

    self.m_currDownloadRes = self.m_lDownloadRes[self.m_currPatchVer]

    do
        --local에 파일로 저장할땐 web에 업로드된 패스와 상관없이
	    --writeable경로에 저장하기 위해 파일명만 추출
	    --local web_path = 'http://test.perplelab.com/dv_test/' .. self.m_currDownloadRes['name']  -- v0.0.9까지 사용하던 이전 패치 url
        local web_path = 'http://patch-12.perplelab.net/dv_test/' .. self.m_currDownloadRes['name']
	    local l_word = seperate(web_path, '/')
	    local local_path = self:getDownloadPath() .. l_word[#l_word]
        self.m_currDownloadRes['web_path'] = web_path
        self.m_currDownloadRes['local_path'] = local_path
    end

    return true
end

-------------------------------------
-- function st_downloadPatchFile_checkExist
-- @brief 다운받고자 하는 zip파일이 존재하고, 용량까지 같은 경우 true 리턴
--        다운로드 과정을 건너뛰고 압축 해제로 상태 변경
-------------------------------------
function PatchCore:st_downloadPatchFile_checkExist(t_download_res)
    -- 파일 존재 유무 확인
    local f = io.open(t_download_res['local_path'], 'r')
    if (not f) then
        return false
    end

    -- 파일 사이즈 얻어옴
    local size = f:seek("end")
    f:close()

    -- 파일 사이즈가 같을 경우 true 리턴
    if (t_download_res['size'] == size) then
        return true
    end

    return false
end

-------------------------------------
-- function st_decompression
-- @brief 다운받은 zip파일을 압축 해제
-------------------------------------
function PatchCore:st_decompression()
    local t_download_res = self.m_currDownloadRes

    local local_path = t_download_res['local_path']
    local download_path = self:getDownloadPath()
    local md5 = t_download_res['md5']

    --[[
    local ret = unzip(local_path, download_path, md5)

    if (ret == 0) then
        -- 압축해제가 완료된 zip파일은 삭제
        os.remove(local_path)
        self.m_currDownloadRes = nil
        self:savePatchData()

        -- 다음 스텝으로 이동
        self.m_state = PATCH_STATE.download_patch_file 
        self:doStep()
        return
    else
        local msg = Str('추가 리소스 패치 중 오류({0})가 발생하였습니다. 불필요한 앱과 파일을 삭제 후 다시 시도해 주세요.', ret)
        self:errorHandler(Str('추가 리소스 패치 중 오류({0})가 발생하였습니다.\n다시 시도하시겠습니까?'))
    end
    --]]

    local function result_cb(ret)
        if (ret == 0) then
            -- 압축해제가 완료된 zip파일은 삭제
            os.remove(local_path)
            self.m_currDownloadRes = nil
            self:savePatchData()

            -- 다음 스텝으로 이동
            self.m_state = PATCH_STATE.download_patch_file 
            self:doStep()
            return
        else
            local msg = Str('추가 리소스 패치 중 오류({0})가 발생하였습니다. 불필요한 앱과 파일을 삭제 후 다시 시도해 주세요.', ret)
            self:errorHandler(Str('추가 리소스 패치 중 오류({0})가 발생하였습니다.\n다시 시도하시겠습니까?'))
        end
    end

    if unzipAsync then
        unzipAsync(local_path, download_path, md5, result_cb)
    else
        local ret = unzip(local_path, download_path, md5)
        result_cb(ret)
    end
end

-------------------------------------
-- function savePatchData
-- @brief 패치 데이터 저장
--        패치 파일 하나를 다운받았을 때마다 저장
-------------------------------------
function PatchCore:savePatchData()
    local patch_data = PatchData:getInstance()

    if (self.m_type == 'res') then
        patch_data:set('res_ver', self.m_currPatchVer)
    elseif (self.m_type == 'patch') then
        patch_data:set('patch_ver', self.m_currPatchVer)
    else
        error('self.m_type : ' .. self.m_type)
    end

	patch_data:save()
end

-------------------------------------
-- function checkGuideTime
-- @brief 작은 용량 패치 파일 다운로드시 최소 가이드 노출 시간
-------------------------------------
function PatchCore:checkGuideTime()
    if (self.m_showGuideTime) and (self.m_showGuideTime < MIN_GUIDE_TIME) then
        return false
    end
    return true
end

-------------------------------------
-- function setFinishCB
-------------------------------------
function PatchCore:setFinishCB(finish_cb)
    self.m_finishCB = finish_cb
end

-------------------------------------
-- function close_patch_guide
-- @brief
-------------------------------------
function PatchCore:close_patch_guide()
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