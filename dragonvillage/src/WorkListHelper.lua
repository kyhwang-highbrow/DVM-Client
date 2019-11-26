-------------------------------------
-- class WorkListHelper
-------------------------------------
WorkListHelper = class({
        m_workIdx = 'number',
        m_lWorkUnitList = 'list[WorkUnit]',
        m_finishCB = 'function',
    })

-------------------------------------
-- function init
-- @brief
-------------------------------------
function WorkListHelper:init()
    self.m_workIdx = 0
    self.m_lWorkUnitList = {}
    self.m_finishCB = nil
end

-------------------------------------
-- function addWork
-------------------------------------
function WorkListHelper:addWork(name, func_enter, funk_work, func_exit)
    local work_unit = WorkUnit()

    work_unit:setName(name)
    work_unit:registerEnterHandler(func_enter)
    work_unit:registerWorkHandler(funk_work)
    work_unit:registerExitHandler(func_exit)

    table.insert(self.m_lWorkUnitList, work_unit)
end

-------------------------------------
-- function setFinishCallback
-------------------------------------
function WorkListHelper:setFinishCallback(func)
    self.m_finishCB = func
end

-------------------------------------
-- function doNextWork
-------------------------------------
function WorkListHelper:doNextWork()
    local work_idx = self.m_workIdx + 1
    self:doWorkByIdx(work_idx)

    -- 모든 작업이 완료되었을 경우
    if (table.count(self.m_lWorkUnitList) < work_idx) then
        self:log('Finish')
        if self.m_finishCB then
            return self.m_finishCB()
        end
    end
end

-------------------------------------
-- function doPreviousWork
-------------------------------------
function WorkListHelper:doPreviousWork()
    self:doWorkByIdx(self.m_workIdx - 1)
end

-------------------------------------
-- function retryCurrWork
-------------------------------------
function WorkListHelper:retryCurrWork()
    self:doWorkByIdx(self.m_workIdx)
end

-------------------------------------
-- function doWorkByIdx
-------------------------------------
function WorkListHelper:doWorkByIdx(idx)
    -- 이전에 진행 중인 작업 정리
    local prev_work_unit = self:getWorkUnit(self.m_workIdx)
    if prev_work_unit then
        if prev_work_unit.m_onExit then
            self:log(tostring(prev_work_unit.m_name) .. ' ' .. 'onExit')
            prev_work_unit.m_onExit()
        end
    end

    -- workIdx 변경
    self.m_workIdx = idx

    -- 다음 작업 시작
    local next_work_unit = self:getWorkUnit(self.m_workIdx)
    if next_work_unit then
        if next_work_unit.m_onEnter then
            self:log(tostring(next_work_unit.m_name) .. ' ' .. 'onEnter')
            next_work_unit.m_onEnter()
        end

        if next_work_unit.m_onWork then
            self:log(tostring(next_work_unit.m_name) .. ' ' .. 'onWork')
            next_work_unit.m_onWork()
        end
    end
end

-------------------------------------
-- function getWorkUnit
-- private
-------------------------------------
function WorkListHelper:getWorkUnit(idx)

    -- 숫자 타입과 nil체크
    local num_idx = tonumber(idx)
    if (num_idx == nil) then
        return nil
    end

    return self.m_lWorkUnitList[num_idx]
end

-------------------------------------
-- function log
-------------------------------------
function WorkListHelper:log(msg)
    local skip = false
    if (skip == true) then
        return
    end

    cclog('##WorkListHelper log## : ' .. tostring(msg))
end