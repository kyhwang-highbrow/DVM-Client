-------------------------------------
-- class ResPreloadMgr
-------------------------------------
ResPreloadMgr = class({
    m_stageID               = 'number',
    m_bCompletedPreload     = 'boolean',
    m_bPreparedPreloadList  = 'boolean',
    m_tPreloadList          = 'table',
})

-------------------------------------
-- function init
-------------------------------------
function ResPreloadMgr:init()
    self.m_stageID = -1
    self.m_bCompletedPreload = false
    self.m_bPreparedPreloadList = false
    self.m_tPreloadList = {}
end

-------------------------------------
-- function loadFromStageID
--@brief 해당 스테이지 관련 리소스를 프리로드
-------------------------------------
function ResPreloadMgr:loadFromStageID(stageID)
    if (self.m_bCompletedPreload and self.m_stageID == stageID) then
        -- 이미 프리로드된 경우
        return true
    end

    if (not self.m_bPreparedPreloadList or self.m_stageID ~= stageID) then
        -- 프리로드할 리스트가 준비되지 않은 경우 리스트를 생성
        self.m_tPreloadList = self:makeResList(stageID)

        self.m_stageID = stageID
        self.m_bPreparedPreloadList = true

        --cclog('self.m_tPreloadList = ' .. luadump(self.m_tPreloadList))

        return false
    end

    local ret = self:loadRes()
    return ret
end

-------------------------------------
-- function loadRes
-------------------------------------
function ResPreloadMgr:loadRes()
    local limitedCount = 10  -- 프레임마다 처리될 리소스 수
    local count = 0
    local t_remove = {}

    for i, v in ipairs(self.m_tPreloadList) do
        --cclog('ResPreloadMgr:loadRes ' .. v)
        self:caching(v)
        count = count + 1

        table.insert(t_remove, 1, i)

        if (count >= limitedCount) then break end
    end

    for _, v in ipairs(t_remove) do
		table.remove(self.m_tPreloadList, v)
	end

    return (#self.m_tPreloadList == 0)
end

-------------------------------------
-- function makeResList
-- @brief 해당 스테이지 관련 리소스 목록을 얻음
-------------------------------------
function ResPreloadMgr:makeResList(stageID)
    local ret = {}
    local temp = {}

    -- 공용 리소스
    do
        local tList = self:getPreloadList_Common()
        for _, k in ipairs(tList) do
            temp[k] = true
        end
    end

    -- 테이머 관련 리소스
    do
        local tList = self:getPreloadList_Tamer()
        for _, k in ipairs(tList) do
            temp[k] = true
        end
    end

    -- 아군 관련 리소스
    do
        local tList = self:getPreloadList_Hero()
        for _, k in ipairs(tList) do
            temp[k] = true
        end
    end
    
    -- 스테이지(적군) 관련 리소스
    do
        -- TODO: 프리로드 정보 파일을 열어서 해당 스테이지의 리소스 목록을 가져옴
        local tList = self:getPreloadList_Stage(stageID)
        for _, k in ipairs(tList) do
            temp[k] = true
        end
    end

    -- 인덱스형 테이블로 변환
    for k, _ in pairs(temp) do
        table.insert(ret, k)
    end

    return ret
end

-------------------------------------
-- function caching
-------------------------------------
function ResPreloadMgr:caching(res_name)
    if (not res_name) or (string.len(res_name) == 0) then return end

    -- plist
    if string.match(res_name, '%.plist') then
        cc.SpriteFrameCache:getInstance():addSpriteFrames(res_name)

    -- vrp
	elseif string.match(res_name, '%.vrp') then
		res_name = string.gsub(res_name, '%.vrp', '')
		
		-- plist 등록(SpriteFrame 캐싱)
		local plist_name = res_name .. '.plist'
		if cc.FileUtils:getInstance():isFileExist(plist_name) then
			cc.SpriteFrameCache:getInstance():addSpriteFrames(plist_name)
		end

		-- vrp를 생성(VRP 캐싱)
		local node = cc.AzVRP:create(res_name .. '.vrp')
        if node then
		    node:buildSprite('')
        else
            cclog('## ERROR!! ResPreloadMgr:caching() file not exist', res_name)
        end

    -- spine
    elseif string.match(res_name, '%.spine') then
		res_name = string.gsub(res_name, '%.spine', '')
		
		local node = sp.SkeletonAnimation:create(res_name .. '.json', res_name ..  '.atlas', 1)
        if node then
            
        else
            cclog('## ERROR!! ResPreloadMgr:caching() file not exist', res_name)
        end
	end
end