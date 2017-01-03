local PARENT = UI

-------------------------------------
-- class UI_SimpleDragonInfoPopup
-------------------------------------
UI_SimpleDragonInfoPopup = class(PARENT, {
        m_tDragonData = 'table',
     })

-------------------------------------
-- function init
-------------------------------------
function UI_SimpleDragonInfoPopup:init(did)
    self.m_tDragonData = self:makeDragonData(did)

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
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_SimpleDragonInfoPopup:refresh()
    local vars = self.vars

    local did = self.m_tDragonData['did']

    local table_dragon = TableDragon()
    local t_dragon = table_dragon:get(did)

    local t_dragon_data = self.m_tDragonData

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

    local t_dragon_data = self.m_tDragonData
    local dragon_id = t_dragon_data['did']
    local lv = t_dragon_data['lv']
    local grade = t_dragon_data['grade']
    local evolution = t_dragon_data['evolution']
    local l_friendship_bonus = {}
    local l_train_bonus = {}

    local status_calc = MakeDragonStatusCalculator(dragon_id, lv, grade, evolution, l_friendship_bonus, l_train_bonus)

    vars['atk_p_label']:setString(status_calc:getFinalStatDisplay('atk'))
    vars['atk_spd_label']:setString(status_calc:getFinalStatDisplay('aspd'))
    vars['cri_chance_label']:setString(status_calc:getFinalStatDisplay('cri_chance'))
    vars['def_p_label']:setString(status_calc:getFinalStatDisplay('def'))
    vars['hp_label']:setString(status_calc:getFinalStatDisplay('hp'))
    vars['cri_avoid_label']:setString(status_calc:getFinalStatDisplay('cri_avoid'))
    vars['avoid_label']:setString(status_calc:getFinalStatDisplay('avoid'))
    vars['hit_rate_label']:setString(status_calc:getFinalStatDisplay('hit_rate'))
    vars['cri_dmg_label']:setString(status_calc:getFinalStatDisplay('cri_dmg'))
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
    local ui = UI_SkillDetailPopup(t_dragon_data)

    ui.vars['upgradeBtn']:setVisible(false)
end