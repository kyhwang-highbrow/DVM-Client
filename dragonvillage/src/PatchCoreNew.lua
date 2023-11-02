---@alias PATCH_STATE table<number>
local PATCH_STATE = {}
PATCH_STATE.request_patch_info = 1  -- 패치 정보를 요청
PATCH_STATE.download_patch_file = 2 -- 패치 파일 다운로드
PATCH_STATE.decompression = 3       -- 패치 파일 압축 해제
PATCH_STATE.finish = 10             -- 종료
local MB_TO_BYTE = 1024 * 1024
local MIN_GUIDE_TIME = 3                  -- 패치 가이드 노출시 최소 노출 시간 

local PARENT = PatchCore
-------------------------------------
--- @class PatchCoreNew
---@field m_currPatchAsset PatchAssetBase
---@field m_patchAssetRes PatchAssetResource
---@field m_patchAssetLang PatchAssetLanguage
---@field m_currPatchInfo PatchInfo
-------------------------------------
PatchCoreNew = class(PARENT ,{
    -- PatchAsset
    m_currPatchAsset = '',
    m_patchAssetRes = '',
    m_patchAssetLang = '',
    m_currPatchInfo  = '',
})

-------------------------------------
---@function init
---@brief 구현체크
-------------------------------------
function PatchCoreNew:init(scene, type, app_ver)    
    self.m_currPatchAsset = nil
    self.m_currPatchInfo = nil
    self.m_patchAssetRes = PatchAssetResource(app_ver)
    self.m_patchAssetLang = PatchAssetLanguage(app_ver)
end

-------------------------------------
---@function st_requestPatchInfo_successCB
---@brief  패치 파일 요청 성공 콜백(구현 체크)
-------------------------------------
function PatchCoreNew:st_requestPatchInfo_successCB(ret)
    if (not ret) or (not ret['cur_patch_ver']) or (not ret['list']) then
        self:errorHandler(Str('패치 정보에 오류가 있습니다.\n다시 시도하시겠습니까?'))
        return
    end

    -- 최신패치버전 정보 및 패치 파일 리스트 셋팅
    self.m_latestPatchVer = ret['cur_patch_ver']

    -- 다운로드 받을 파일 확인
    do
        -- 1. 일반 에셋 (한글, 영어 에셋 포함)
        self.m_patchAssetRes:applyPatchList(ret['list'], self.m_currPatchVer, self.m_latestPatchVer)
        -- 2. 요청한 언어 에셋
        self.m_patchAssetLang:applyPatchList(ret['lang_list'])
    end

    -- 앱 구동 후 최초 한번만 계산한다.
    -- case 0 : 정상적으로 최초 패치 호출 -> 현재 받아야 할 총 패치 사이즈 계산
    -- case 1 : 네트워크 불안정으로 인해 에러나서 다시 받는 경우 -> 토탈사이즈를 갱신하지 않는다.
    -- case 2 : 패치 중 앱 종료된 경우 현재 남은 패치 사이즈를 계산하여 토탈사이즈로 보여준다.
    if (self.m_totalSize == 0) then
        self.m_totalSize = self.m_patchAssetRes:getTotalSize() + self.m_patchAssetLang:getTotalSize()
    end

	cclog('## TOTAL PATCH SIZE ' .. self.m_totalSize)

	-- [함수] 다음 스텝으로 이동
	local function do_next_step()
		self.m_state = PATCH_STATE.download_patch_file
		self:doStep()
	end

        -- [함수] 패치 가이드 UI 호출
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
    -- 23.05.01 iOS 스토어 정책에 의해 항상 패치 용량 출력하도록 되어 있음
	local std_size = 50 * MB_TO_BYTE
    if (std_size < self.m_totalSize) or ((self.m_totalSize > 0) and (CppFunctions:isIos() == true)) then
        -- 메가바이트로 크기 환산
        local size_mb = string.format('%.2f', self.m_totalSize / MB_TO_BYTE)
		local patch_str = Str('추가 데이터가 다운로드 됩니다.({1}MB).\n다운로드 하시겠습니까?\n[WIFI 연결을 권장하며 3G/LTE을 사용할 경우 과도한 요금이 부과 될 수 있습니다.]', size_mb)

        -- [함수] 수락 -> 다운로드 시작 및 패치 가이드 UI 호출
        local function ok_func()
            do_next_step()
            show_patch_guide()
        end

		-- [함수] 거절 -> 앱 종료!
		local function cancel_func()
			local function close_cb()
				cc.Director:getInstance():endToLua()
			end
			MakeSimplePopup(POPUP_TYPE.OK, Str('앱을 종료합니다.'), close_cb)
		end

		MakeSimplePopup(POPUP_TYPE.YES_NO, patch_str, ok_func, cancel_func)

    -- 패치 받을 것이 있음 -> 다운로드 시작 및 패치 가이드 UI 호출
    elseif (0 < self.m_totalSize) then
        do_next_step()
        show_patch_guide()

    -- 패치가 없음
	else
		do_next_step()
    end
end

-------------------------------------
---@function st_downloadPatchFile_setCurrDownloadRes
---@return boolean 현재 다운받을 파일이 있다는 뜻(구현 체크)
-------------------------------------
function PatchCoreNew:st_downloadPatchFile_setCurrDownloadRes()
    if self.m_currPatchInfo then
        return true
    end

    -- 1. 일반 패치
    self.m_currPatchInfo = self.m_patchAssetRes:getPatchInfo(self.m_currPatchVer, self.m_latestPatchVer)
    self.m_currPatchAsset = self.m_patchAssetRes
    self.m_currPatchVer = self.m_currPatchVer + 1


    -- 2. 언어 패치 탐색
    if (self.m_currPatchInfo == nil) then
        self.m_currPatchInfo = self.m_patchAssetLang:getPatchInfo()
        self.m_currPatchAsset = self.m_patchAssetLang
    end

    -- 3. 탈출 조건 : 일반 패치, 언어 패치 모두 없음
    if (self.m_currPatchInfo == nil) then
        return false
    end

    --local에 파일로 저장할땐 web에 업로드된 패스와 상관없이
    --writeable경로에 저장하기 위해 파일명만 추출
    do
        local download_url = self.m_currPatchInfo['name']
        self.m_currPatchInfo['web_path'] = GetPatchServer() .. '/' .. download_url
        self.m_currPatchInfo['local_path'] = self.m_currPatchAsset:getLocalPath(download_url)
    end

    return true
end

-------------------------------------
---@function st_downloadPatchFile
---@brief 다운로드 요청(구현 체크)
-------------------------------------
function PatchCoreNew:st_downloadPatchFile()
    -- false를 리턴하면 다운받을 패치파일이 없다는 뜻
    if (false == self:st_downloadPatchFile_setCurrDownloadRes()) then
        -- 다음 스텝으로 이동
        self.m_state = PATCH_STATE.finish
        self:doStep()
        return
    end

    local curr_patch_info = self.m_currPatchInfo
    -- zip파일이 이미 다운로드 되어있다면..
    -- 다운받고자 하는 zip파일이 존재하고, 용량까지 같은 경우 true 리턴
    -- 다운로드 과정을 건너뛰고 압축 해제로 상태 변경
    if self.m_currPatchAsset:checkFileExist(curr_patch_info['name'], curr_patch_info['size']) then
        -- 다음 스텝으로 이동
        self.m_state = PATCH_STATE.decompression
        self:doStep()
        return
    end

    do -- 다운로드 진행
        local local_path = curr_patch_info['local_path']
        local web_path = curr_patch_info['web_path']

        -- 다운로드 검증용
        local total_size = curr_patch_info['size']
        local downed_size = 0

        -- 다운 성공 콜백
        local function success_cb()
            -- 다음 스텝으로 이동
            io.write('\n')
            self.m_state = PATCH_STATE.decompression
            self:doStep()
        end

        -- 다운 실패 콜백
        local function fail_cb(error_msg)
            os.remove(local_path)
            local msg = Str('패치 파일을 다운로드하는데 실패하였습니다.')
            if error_msg and (error_msg ~= '') then
                msg = msg .. '\n(' .. error_msg .. ')'
            end
            msg = msg .. '\n' .. Str('다시 시도하시겠습니까?')
            self:errorHandler(msg)
        end

        -- 진행 정도 콜백
        local function progress(size)
            -- 정해진 용량 이상 출력하지 않도록 한다.nb
            -- 간혹 total_size 보다 훨씬 많은 량을 다운받기도 하는데
            -- 연결이 잠시 불안정한 동안 계속 같은 값의 size가 반복해서 들어오는 것으로 추정됨.
            -- 이를 막기 위해서 해당 패치의 총 다운로드 용량을 지정하여 거기까지만 출력하도록 함
            -- self:printDebug(downed_size, total_size)

            -- 현재 리소스 사이즈 보다 받은 사이즈가 크다면 더이상 처리하지 않는다.
            if (downed_size > total_size) then
                return
            end

            io.write(string.format('## PatchCore - curr_progress : %d%% \r', (downed_size/total_size*100)))
			self.m_downloadedSize = self.m_downloadedSize + size
            downed_size = downed_size + size
        end

        -- 다운로드 요청
        Network:download(web_path, local_path, success_cb, fail_cb, progress)
    end
end

-------------------------------------
---@function st_decompression
---@brief 다운받은 zip파일을 압축 해제(구현 체크)
-------------------------------------
function PatchCoreNew:st_decompression()
    local t_download_res = self.m_currPatchInfo

    local local_path = t_download_res['local_path']
    local download_path = self.m_currPatchAsset:getDownloadPath()
    local md5 = t_download_res['md5']

    local function result_cb(ret)
        if (ret == 0) then
            -- 압축해제가 완료된 zip파일은 삭제
            os.remove(local_path)
            self.m_currPatchInfo = nil
            self.m_currPatchAsset:savePatchData(self.m_currPatchVer)

            -- 패치 화면의 버전 표시 업데이트
            self.m_patchScene:refreshPatchIdxLabel()

            -- 다음 스텝으로 이동
            self.m_state = PATCH_STATE.download_patch_file
            self:doStep()
            return

        -- 압축 해제 에러 케이스
        else
            local msg = Str('추가 리소스 패치 중 오류({1})가 발생하였습니다. 다시 시도하시겠습니까?', ret)
            local popup_type = ''

			-- UNZ_MD5ERROR : MD5 error
            if ret == -111 then
                msg = Str('다운로드 받은 패치 파일에 오류가 있습니다. 다운로드를 다시 시도하시겠습니까?')

			-- UNZ_TARGETFILE_OPENFAIL : 읽기 오류
            elseif ret == -112 then
                msg = Str('저장 공간이 부족하여 패치 파일을 설치하는데 실패하였습니다.\n불필요한 앱과 파일을 삭제 후 다시 시도해 주세요.')

			-- UNZ_TARGETFILE_WRITEFAIL : 쓰기 오류
            elseif ret == -113 then
                msg = Str('저장 공간이 부족하여 패치 파일을 저장하는데 실패하였습니다.\n불필요한 앱과 파일을 삭제 후 다시 시도해 주세요.')

            end
            self:errorHandler(msg)
        end
    end

    if unzipAsync then
        unzipAsync(local_path, download_path, md5, result_cb)
    else
        local ret = unzip(local_path, download_path, md5)
        result_cb(ret)
    end
end