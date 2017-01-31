-------------------------------------
-- class ResPreloadMgr
-------------------------------------
ResPreloadMgr = class({
    m_stageName             = 'number',
    m_bCompletedPreload     = 'boolean',
    m_bPreparedPreloadList  = 'boolean',
    m_tPreloadList          = 'table',
})

-------------------------------------
-- function init
-------------------------------------
function ResPreloadMgr:init()
    self.m_stageName = ''
    self.m_bCompletedPreload = false
    self.m_bPreparedPreloadList = false
    self.m_tPreloadList = {}
end

-------------------------------------
-- function loadFromStageName
--@brief 해당 스테이지 관련 리소스를 프리로드
-------------------------------------
function ResPreloadMgr:loadFromStageName(stageName)
    
    if (self.m_bCompletedPreload and self.m_stageName == stageName) then
        -- 이미 프리로드된 경우
        return true
    end

    if (not self.m_bPreparedPreloadList or self.m_stageName ~= stageName) then
        self.m_stageName = stageName
        self.m_bCompletedPreload = false
        self.m_bPreparedPreloadList = true

        -- 프리로드 리스트 초기화
        self.m_tPreloadList = {}

        -- 스테이지에 관련된 것들을 제외한 나머지 리소스들을 추가
        do
            local basePreloadList = makeResListForGame()
            self.m_tPreloadList = basePreloadList
        end

        -- @DOTO: 친구 유닛에 대한 리소스를 추가
        

        -- 해당 스테이지 관련 리소스 추가
        do
            local stagePreloadList = loadPreloadFile()
            local addPreloadList

            if stagePreloadList and stagePreloadList[stageName] then
                addPreloadList = stagePreloadList[stageName]
            else
                -- 해당 스테이지의 리소스 정보가 없는 경우
                --addPreloadList = makeResListForGame(stageName, true)
            end

            if addPreloadList then
                for _, res in pairs(addPreloadList) do
                    table.insert(self.m_tPreloadList, res)
                end
            end
        end

        --cclog('self.m_tPreloadList = ' .. luadump(self.m_tPreloadList))

        return false
    end

    self.m_bCompletedPreload = self:_loadRes()
    return self.m_bCompletedPreload
end

-------------------------------------
-- function loadForColosseum
--@brief 콜로세움 관련 리소스를 프리로드
-------------------------------------
function ResPreloadMgr:loadForColosseum(t_enemy)
    if (self.m_bCompletedPreload) then
        -- 이미 프리로드된 경우
        return true
    end

    if (not self.m_bPreparedPreloadList) then
        self.m_bCompletedPreload = false
        self.m_bPreparedPreloadList = true

        -- 프리로드 리스트 초기화
        self.m_tPreloadList = {}

        -- 스테이지에 관련된 것들을 제외한 나머지 리소스들을 추가
        do
            local basePreloadList = makeResListForGame()
            self.m_tPreloadList = basePreloadList
        end

        -- @DOTO: 상대편 유닛에 대한 리소스를 추가

        
        --cclog('self.m_tPreloadList = ' .. luadump(self.m_tPreloadList))

        return false
    end

    self.m_bCompletedPreload = self:_loadRes()
    return self.m_bCompletedPreload
end

-------------------------------------
-- function _loadRes
-------------------------------------
function ResPreloadMgr:_loadRes()
    local limitedCount = 10  -- 프레임마다 처리될 리소스 수
    local count = 0
    local t_remove = {}

    for i, v in ipairs(self.m_tPreloadList) do
        resCaching(v)
        count = count + 1

        table.insert(t_remove, 1, i)

        if (count >= limitedCount) then break end
    end

    for _, v in ipairs(t_remove) do
		table.remove(self.m_tPreloadList, v)
	end

    return (#self.m_tPreloadList == 0)
end