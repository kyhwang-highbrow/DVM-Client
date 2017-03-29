UINavigator = {}

-------------------------------------
-- function goTo
-- @brief UI 이동
-------------------------------------
function UINavigator:goTo(location, val_1, val_2)
    if (location == 'transcend') then
        self:goTo_transcend(val_1)
    end
end

-------------------------------------
-- function goTo_transcend
-- @brief UI 이동
-------------------------------------
function UINavigator:goTo_transcend(doid)
    local b_find, idx = self:find_DragonManageInfoUI()

    if (b_find) then
        self:closeUIList(idx)

        local ui = UIManager.m_uiList[idx]
        if doid then
            local b_force = true
            ui:setSelectDragonData(doid, b_force)
        end
        ui:click_transcendBtn()
    end
end

-------------------------------------
-- function find_DragonManageInfoUI
-- @brief 오픈된 UI에서 드래곤 관리 UI를 찾음
-------------------------------------
function UINavigator:find_DragonManageInfoUI()
    local idx = nil

    for i=#UIManager.m_uiList, 1, -1 do
        local ui = UIManager.m_uiList[i]
        if (ui.m_uiName == 'UI_DragonManageInfo') then
            idx = i
            break
        end
    end

    if (idx) then
        return true, idx
    else
        return false
    end
end

-------------------------------------
-- function closeUIList
-- @brief 오픈된 UI에서 idx이후의 UI들을 닫음
-------------------------------------
function UINavigator:closeUIList(idx)
    for i=#UIManager.m_uiList, idx+1, -1 do
        local ui = UIManager.m_uiList[i]
        ui:close()
    end
end