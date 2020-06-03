-------------------------------------
-- class BenchmarkManager
-------------------------------------
BenchmarkManager = class({
        m_lStageID = '',
        m_currIdx = '',
        m_bActive = '',

        m_waveTime = '',
        m_lastWaveTime = '',

        m_recordTable = '',
        m_outputFileName = '',
    })

-------------------------------------
-- function init
-------------------------------------
function BenchmarkManager:init()
    self.m_bActive = false
    self.m_waveTime = 10
    self.m_lastWaveTime = 30
    self.m_outputFileName = 'benchmark.csv'
end

-------------------------------------
-- function getInstance
-------------------------------------
function BenchmarkManager:getInstance()
    if (not g_benchmarkMgr) then
        g_benchmarkMgr = BenchmarkManager()
    end
    return g_benchmarkMgr
end

-------------------------------------
-- function release
-------------------------------------
function BenchmarkManager:release()
    g_benchmarkMgr = nil
end

-------------------------------------
-- function setStageIDList
-------------------------------------
function BenchmarkManager:setStageIDList(...)
    local args = {...}
    self.m_lStageID = args
    self.m_currIdx = 0
end

-------------------------------------
-- function setBenchmarkJson
-------------------------------------
function BenchmarkManager:setBenchmarkJson()
    local info = TABLE:loadJsonTable('benchmark', '.json')
    
    ccdump(info)

    self.m_waveTime = info['wave_time']
    self.m_lastWaveTime = info['last_wave_time']
    
    local t_skip = {}
    t_skip[999999] = true  -- 개발 스테이지
    t_skip[1010001] = true -- 튜토리얼 스테이지
	t_skip[1240001] = true -- 금화 던전
    t_skip[1240002] = true -- 금화 던전
    t_skip[1240003] = true -- 금화 던전
    t_skip[1240004] = true -- 금화 던전
    t_skip[1240005] = true -- 금화 던전
    t_skip[1240006] = true -- 금화 던전
    

    if info['all_test'] then
        local table_drop = TableDrop()
        local t_list = {}
        for i,v in pairs(table_drop.m_orgTable) do
            local _stage_id = tonumber(i)
            if (not t_skip[_stage_id]) then
                table.insert(t_list, _stage_id)
            end
        end
        table.sort(t_list, function(a, b) return a < b end)

        self.m_lStageID = t_list

        self.m_currIdx = 0
    else
        self.m_lStageID = info['stage_list']
        self.m_currIdx = 0
    end

    do
        local os_time = os.time()
        local date_str = os.date('%Y-%m-%d-%H-%M', os_time)
        self.m_outputFileName = 'benchmark' .. date_str .. '.csv'
        cclog('# self.m_outputFileName : ' .. self.m_outputFileName)
    end
end

-------------------------------------
-- function startStage
-------------------------------------
function BenchmarkManager:startStage()
    self.m_currIdx = self.m_currIdx + 1
    local stage_id = self.m_lStageID[self.m_currIdx]

    if stage_id then

        cclog('## BenchmarkManager:startStage() : ' .. stage_id)
        cclog(string.format('## BenchmarkManager:startStage() : %d/%d, %d%%', self.m_currIdx, #self.m_lStageID, math_floor(self.m_currIdx/#self.m_lStageID*100)))

        self:runGameScene(stage_id)
        return true
    else
        self.m_bActive = false
        return false
    end
end

-------------------------------------
-- function isActive
-------------------------------------
function BenchmarkManager:isActive()
    return self.m_bActive
end

-------------------------------------
-- function runGameScene
-------------------------------------
function BenchmarkManager:runGameScene(stage_id)

    -- 밴치마크가 활성화되어있다면 즉시 활성화시킴
    g_autoPlaySetting:set('quick_mode', true)
    g_autoPlaySetting:set('auto_mode', false)

    self.m_bActive = true
    local stage_name = 'stage_' .. stage_id
    local scene = SceneGame(nil, stage_id, stage_name)
    scene:runScene()

    -- 아군, 적군 무적 O
    -- 1.5배속 O
    -- 자동 플레이 O
    -- 웨이브당 n초 지속 O
    -- n초 후 웨이브 종료 O
    -- 보스 패턴은 모두 쓰도록 변경 O
end

-------------------------------------
-- function finishStage
-------------------------------------
function BenchmarkManager:finishStage(fpsmeter)
    local stage_id = self.m_lStageID[self.m_currIdx]
    self:recordStage(stage_id, fpsmeter)

    if self:startStage() then

    else
        local function ok_cb()
            local scene = SceneLobby()
            scene:runScene()
        end
        self:stop()
        MakeSimplePopup(POPUP_TYPE.OK, '벤치마크 종료!!', ok_cb)
    end
end

-------------------------------------
-- function recordStage
-------------------------------------
function BenchmarkManager:recordStage(stage_id, fpsmeter)
    if (not self.m_recordTable) then
        self.m_recordTable = {}
    end

    local t_data = {}
    t_data['stage_id'] =  stage_id

    local table_drop = TableDrop()

    do -- info
        t_data['t_name'] = table_drop:getValue(stage_id, 't_name')
        t_data['r_chapter_info'] = table_drop:getValue(stage_id, 'r_chapter_info')
        t_data['r_stage_info'] = table_drop:getValue(stage_id, 'r_stage_info')
    end

    do -- fps
        local curr_time = socket.gettime()
        local dt = (curr_time - fpsmeter.m_prevTime)
        fpsmeter.m_prevTime = curr_time
        local fps = fpsmeter.m_frameCnt / (curr_time - fpsmeter.m_startTime)
        t_data['fps'] = math_floor(fps)
    end

    do -- glcalls
        local average = math_floor(fpsmeter.m_cumulativeGLCalls / fpsmeter.m_frameCnt)
        t_data['glcalls'] = math_floor(average)
        t_data['glcalls_min'] = fpsmeter.m_minGLCalls
        t_data['glcalls_max'] = fpsmeter.m_maxGLCalls
    end

    do -- phys
        local average = math_floor(fpsmeter.m_cumulativePhysObj / fpsmeter.m_frameCnt)
        t_data['phys'] = math_floor(average)
        t_data['phys_min'] = fpsmeter.m_minPhysObj
        t_data['phys_max'] = fpsmeter.m_maxPhysObj
    end

    table.insert(self.m_recordTable, t_data)

    ccdump(t_data)
    self:benchmark(self.m_recordTable)
end

-------------------------------------
-- function checkStageID
-------------------------------------
function BenchmarkManager:checkStageID(stage_id)
    if (self.m_lStageID[self.m_currIdx] ~= stage_id) then
        local msg = '\n###################################################################\n' ..
                    '###################################################################\n' ..
                    '## 유효하지 않은 stage_id입니다.(' .. stage_id .. ')\n' ..
                    '## 밴치마크가 비활성화 되었습니다.\n' ..
                    '###################################################################\n' ..
                    '###################################################################'
        cclog(msg)
        self:stop()
    end
end

-------------------------------------
-- function stop
-------------------------------------
function BenchmarkManager:stop()
    local msg = '\n###################################################################\n' ..
                '###################################################################\n' ..
                '## 밴치마크가 종료 되었습니다.\n' ..
                '###################################################################\n' ..
                '###################################################################'
    cclog(msg)
    self.m_bActive = false
end


-------------------------------------
-- function benchmark
-------------------------------------
function BenchmarkManager:benchmark(table_info)

    local l_header = {'stage_id', 't_name', 'r_chapter_info', 'r_stage_info', 'fps', 'glcalls', 'glcalls_min', 'glcalls_max', 'phys', 'phys_min', 'phys_max'}
    local csv_str = ''

    local line_str = ''
    for i,v in ipairs(l_header) do
        if (line_str == '') then
            line_str = v
        else
            line_str = line_str .. ',' .. v
        end
    end
    csv_str = csv_str .. line_str

    -- stage_id의 값으로 오름차순 정렬
    local table_list = {}
    for i,v in pairs(table_info) do
        table.insert(table_list, v)
    end
    table.sort(table_list, function(a, b) return a['stage_id'] < b['stage_id'] end)

    for _,v in ipairs(table_list) do
        local line_str = ''
        for i,key in ipairs(l_header) do

            local value = v[key] or ''

            if (type(value) == 'string') then
                if string.find(value, ',') then
                    value = '"' .. value .. '"'
                end
            end

            if (i==1) then
                line_str = value
            else
                line_str = line_str .. ',' .. value
            end
        end

        csv_str = csv_str .. '\n' .. line_str
    end


    pl.file.write(self.m_outputFileName, csv_str)
    io.write('\n\n')
    cclog('output : ' .. self.m_outputFileName)
end