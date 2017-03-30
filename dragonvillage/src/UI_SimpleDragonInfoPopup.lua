local PARENT = UI

-------------------------------------
-- class UI_SimpleDragonInfoPopup
-------------------------------------
UI_SimpleDragonInfoPopup = class(PARENT, {
        m_tDragonData = 'table',
        m_dragonObjectID = 'string',
        m_tableDragon = 'TableDragon',
        m_idx = 'number',
     })

-------------------------------------
-- function init
-------------------------------------
function UI_SimpleDragonInfoPopup:init(t_dragon_data)
    self.m_tableDragon = TableDragon()

    self.m_tDragonData = t_dragon_data
    self.m_dragonObjectID = t_dragon_data['id']

    local vars = self:load('dragon_management_info_mini.ui')
    UIManager:open(self, UIManager.POPUP)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:click_closeBtn() end, 'UI_SimpleDragonInfoPopup')

    -- @UI_ACTION
    --self:addAction(vars['rootNode'], UI_ACTION_TYPE_LEFT, 0, 0.2)
    --self:doActionReset()
    --self:doAction(nil, false)

    self:initUI()
    self:initButton()
    self:refresh()

    --local idx = self.m_tableDragon:getIllustratedDragonIdx(did)
    --self:setIdx(idx)
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_SimpleDragonInfoPopup:initUI()
    local vars = self.vars
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_SimpleDragonInfoPopup:initButton()
    local vars = self.vars
    vars['closeBtn']:registerScriptTapHandler(function() self:click_closeBtn() end)
    vars['prevBtn']:setVisible(false)
    vars['nextBtn']:setVisible(false)
    --vars['prevBtn']:registerScriptTapHandler(function() self:setIdx(self.m_idx - 1) end)
    --vars['nextBtn']:registerScriptTapHandler(function() self:setIdx(self.m_idx + 1) end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_SimpleDragonInfoPopup:refresh()
    local vars = self.vars

    local t_dragon_data = self:getDragonData()

    local did = t_dragon_data['did']

    local table_dragon = TableDragon()
    local t_dragon = table_dragon:get(did)

    -- 코드 중복을 막기 위해 UI_DragonManageInfo클래스의 기능을 활용
    UI_DragonManageInfo.refresh_dragonBasicInfo(self, t_dragon_data, t_dragon)
    UI_DragonManageInfo.refresh_dragonSkillsInfo(self, t_dragon_data, t_dragon, function() self:click_skillDetailBtn() end)
    UI_DragonManageInfo.refresh_icons(self, t_dragon_data, t_dragon)

    -- 능력치 출력
    self:refresh_status()
end

-------------------------------------
-- function refresh_status
-- @brief 능력치 출력
-------------------------------------
function UI_SimpleDragonInfoPopup:refresh_status()
    local vars = self.vars

    local status_calc = self:getStatusCalculator()

    vars['atk_p_label']:setString(status_calc:getFinalStatDisplay('atk'))
    vars['atk_spd_label']:setString(status_calc:getFinalStatDisplay('aspd'))
    vars['cri_chance_label']:setString(status_calc:getFinalStatDisplay('cri_chance'))
    vars['def_p_label']:setString(status_calc:getFinalStatDisplay('def'))
    vars['hp_label']:setString(status_calc:getFinalStatDisplay('hp'))
    vars['cri_avoid_label']:setString(status_calc:getFinalStatDisplay('cri_avoid'))
    vars['avoid_label']:setString(status_calc:getFinalStatDisplay('avoid'))
    vars['hit_rate_label']:setString(status_calc:getFinalStatDisplay('hit_rate'))
    vars['cri_dmg_label']:setString(status_calc:getFinalStatDisplay('cri_dmg'))

    if vars['cp_label'] then
        vars['cp_label']:setString(comma_value(status_calc:getCombatPower()))
    end
end

-------------------------------------
-- function click_closeBtn
-------------------------------------
function UI_SimpleDragonInfoPopup:click_closeBtn()
    self:close()
end

-------------------------------------
-- function makeDragonData
-------------------------------------
function UI_SimpleDragonInfoPopup:makeDragonData(did)
    local t_dragon_data = {}
    t_dragon_data['did'] = did
    t_dragon_data['lv'] = 70
    t_dragon_data['evolution'] = 3
    t_dragon_data['grade'] = 6
    t_dragon_data['exp'] = 0
    t_dragon_data['skill_0'] = 10
    t_dragon_data['skill_1'] = 10
    t_dragon_data['skill_2'] = 10
    t_dragon_data['skill_3'] = 1
    
    return t_dragon_data
end

-------------------------------------
-- function click_skillDetailBtn
-- @brief 스킬 상세정보 보기 버튼
-------------------------------------
function UI_SimpleDragonInfoPopup:click_skillDetailBtn()
    local t_dragon_data = self.m_tDragonData
    UI_SkillDetailPopup(t_dragon_data, true)
end

-------------------------------------
-- function setIdx
-------------------------------------
function UI_SimpleDragonInfoPopup:setIdx(idx)
    if (self.m_idx == idx) then
        return
    end

    local illustrated_dragon_list = self.m_tableDragon:getIllustratedDragonList()
    local min = 1
    local max = #illustrated_dragon_list
    idx = math_clamp(idx, min, max)

    self.m_idx = idx
    local t_dragon = self.m_tableDragon:getIllustratedDragon(idx)
    self.m_tDragonData = self:makeDragonData(t_dragon['did'])
    self:refresh()

    local vars = self.vars
    vars['prevBtn']:setVisible(min < idx)
    vars['nextBtn']:setVisible(idx < max)
end

-------------------------------------
-- function getDragonData
-------------------------------------
function UI_SimpleDragonInfoPopup:getDragonData()
    if self.m_dragonObjectID then
        local t_dragon_data = g_dragonsData:getDragonDataFromUid(self.m_dragonObjectID)

        if t_dragon_data then
            self.m_tDragonData = t_dragon_data
        end
    end

    return self.m_tDragonData
end

-------------------------------------
-- function getStatusCalculator
-------------------------------------
function UI_SimpleDragonInfoPopup:getStatusCalculator()
    local status_calc

    if self.m_dragonObjectID then
        local doid = self.m_dragonObjectID
        status_calc = MakeOwnDragonStatusCalculator(doid)
    end

    if (not status_calc) then
        local t_dragon_data = self:getDragonData()
        status_calc = MakeDragonStatusCalculator_fromDragonDataTable(t_dragon_data)
    end

    return status_calc
end