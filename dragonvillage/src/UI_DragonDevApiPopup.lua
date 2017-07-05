local PARENT = UI

-------------------------------------
-- class UI_DragonDevApiPopup
-------------------------------------
UI_DragonDevApiPopup = class(PARENT, {
        m_dragonObjectID = 'string',

        m_evolution = 'number',
        m_grade = 'number',
        m_level = 'number',

        m_skill0 = 'number',
        m_skill1 = 'number',
        m_skill2 = 'number',
        m_skill3 = 'number',

        m_bChangeSkill = 'boolean',
     })

-------------------------------------
-- function init
-------------------------------------
function UI_DragonDevApiPopup:init(dragon_object_id)
    self.m_dragonObjectID = dragon_object_id
    self.m_bChangeSkill = false

    local vars = self:load('dragon_dev_api_popup.ui')
    UIManager:open(self, UIManager.POPUP)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:click_closeBtn() end, 'UI_DragonDevApiPopup')

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
function UI_DragonDevApiPopup:initUI()
    local vars = self.vars
    local t_dragon_data = g_dragonsData:getDragonDataFromUid(self.m_dragonObjectID)
    
    local dragon_id = t_dragon_data['did']

    local table_dragon = TABLE:get('dragon')
    local t_dragon = table_dragon[dragon_id]

    -- 드래곤 이름 지정
    vars['nameLabel']:setString(Str(t_dragon['t_name']))

    -- 드래곤 진화, 승급, 레벨 저장
    self.m_evolution = t_dragon_data['evolution']
    self.m_grade = t_dragon_data['grade']
    self.m_level = t_dragon_data['lv']

    self.m_skill0 = t_dragon_data['skill_0']
    self.m_skill1 = t_dragon_data['skill_1']
    self.m_skill2 = t_dragon_data['skill_2']
    self.m_skill3 = t_dragon_data['skill_3']
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_DragonDevApiPopup:initButton()
    local vars = self.vars

    local max_evolution = 3
    local max_grade = 6
    local max_level = 40

    vars['evolutionUpBtn']:registerScriptTapHandler(function() self.m_evolution = math_clamp(self.m_evolution + 1, 1, max_evolution) self:refresh() end)
    vars['evolutionDownBtn']:registerScriptTapHandler(function() self.m_evolution = math_clamp(self.m_evolution - 1, 1, max_evolution) self:refresh() end)

    vars['gradeUpBtn']:registerScriptTapHandler(function() self.m_grade = math_clamp(self.m_grade + 1, 1, max_grade) self:refresh() end)
    vars['gradeDownBtn']:registerScriptTapHandler(function()
        self.m_grade = math_clamp(self.m_grade - 1, 1, max_grade)
        self.m_level = math_clamp(self.m_level, 1, TableGradeInfo:getMaxLv(self.m_grade))
        self:refresh()
    end)

    vars['levelUpBtn']:registerScriptTapHandler(function() self.m_level = math_clamp(self.m_level + 1, 1, TableGradeInfo:getMaxLv(self.m_grade)) self:refresh() end)
    vars['levelDownBtn']:registerScriptTapHandler(function() self.m_level = math_clamp(self.m_level - 1, 1, TableGradeInfo:getMaxLv(self.m_grade)) self:refresh() end)

    -- 스킬 레벨들
    vars['skillUpBtn0']:registerScriptTapHandler(function() self.m_skill0 = math_clamp(self.m_skill0 + 1, 1, 10) self:networkSkillLevel(0) end)
    vars['skillDownBtn0']:registerScriptTapHandler(function() self.m_skill0 = math_clamp(self.m_skill0 - 1, 1, 10) self:networkSkillLevel(0) end)

    vars['skillUpBtn1']:registerScriptTapHandler(function() self.m_skill1 = math_clamp(self.m_skill1 + 1, 0, 10) self:networkSkillLevel(1) end)
    vars['skillDownBtn1']:registerScriptTapHandler(function() self.m_skill1 = math_clamp(self.m_skill1 - 1, 0, 10) self:networkSkillLevel(1) end)

    vars['skillUpBtn2']:registerScriptTapHandler(function() self.m_skill2 = math_clamp(self.m_skill2 + 1, 0, 10) self:networkSkillLevel(2) end)
    vars['skillDownBtn2']:registerScriptTapHandler(function() self.m_skill2 = math_clamp(self.m_skill2 - 1, 0, 10) self:networkSkillLevel(2) end)

    vars['skillUpBtn3']:registerScriptTapHandler(function() self.m_skill3 = math_clamp(self.m_skill3 + 1, 0, 1) self:networkSkillLevel(3) end)
    vars['skillDownBtn3']:registerScriptTapHandler(function() self.m_skill3 = math_clamp(self.m_skill3 - 1, 0, 1) self:networkSkillLevel(3) end)

    vars['applyBtn']:registerScriptTapHandler(function() self:click_closeBtn() end)

    vars['closeBtn']:registerScriptTapHandler(function() self:click_closeBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_DragonDevApiPopup:refresh()
    local vars = self.vars

    vars['evolutionLabel']:setString('진화 : ' .. self.m_evolution)
    vars['gradeLabel']:setString('승급 : ' .. self.m_grade)
    vars['levelLabel']:setString('레벨 : ' .. self.m_level)

    vars['skillLabel0']:setString('스킬 0 레벨 : ' .. self.m_skill0)
    vars['skillLabel1']:setString('스킬 1 레벨 : ' .. self.m_skill1)
    vars['skillLabel2']:setString('스킬 2 레벨 : ' .. self.m_skill2)
    vars['skillLabel3']:setString('스킬 3 레벨 : ' .. self.m_skill3)
end

-------------------------------------
-- function networkSkillLevel
-------------------------------------
function UI_DragonDevApiPopup:networkSkillLevel(skill_idx)
    local function success_cb(ret)
        if ret and ret['dragon'] then
            g_dragonsData:applyDragonData(ret['dragon'])
            self:refresh()
            self.m_bChangeSkill = true
        end
    end

    local uid = g_userData:get('uid')
    local ui_network = UI_Network()
    ui_network:setUrl('/dragons/update')
    ui_network:setRevocable(true)
    ui_network:setParam('uid', uid)
    ui_network:setParam('did', self.m_dragonObjectID)
    ui_network:setParam('act', 'update')
    ui_network:setParam('skills', string.format('%d,%d', skill_idx, self['m_skill' .. skill_idx]))
    ui_network:setSuccessCB(success_cb)
    ui_network:request()
end

-------------------------------------
-- function click_closeBtn
-------------------------------------
function UI_DragonDevApiPopup:click_closeBtn()

    local t_dragon_data = g_dragonsData:getDragonDataFromUid(self.m_dragonObjectID)

    local is_change = false

    if (t_dragon_data['evolution'] ~= self.m_evolution) then
        is_change = true
    end

    if (t_dragon_data['grade'] ~= self.m_grade) then
        is_change = true
    end

    if (t_dragon_data['lv'] ~= self.m_level) then
        is_change = true
    end

    if (t_dragon_data['skill_0'] ~= self.m_skill0) then
        is_change = true
    end

    if (t_dragon_data['skill_1'] ~= self.m_skill1) then
        is_change = true
    end

    if (t_dragon_data['skill_2'] ~= self.m_skill2) then
        is_change = true
    end

    if (t_dragon_data['skill_3'] ~= self.m_skill3) then
        is_change = true
    end

    if is_change then
        local function success_cb(ret)
            if ret and ret['dragon'] then
                g_dragonsData:applyDragonData(ret['dragon'])
            end

            self:close()
        end

        local uid = g_userData:get('uid')
        local ui_network = UI_Network()
        ui_network:setUrl('/dragons/update')
        ui_network:setRevocable(true)
        ui_network:setParam('uid', uid)
        ui_network:setParam('did', self.m_dragonObjectID)
        ui_network:setParam('act', 'update')
        ui_network:setParam('evolution', self.m_evolution)
        ui_network:setParam('grade', self.m_grade)
        ui_network:setParam('lv', self.m_level)
        ui_network:setParam('skills', '0,' .. self.m_skill0)
        ui_network:setParam('skills', '1,' .. self.m_skill1)
        ui_network:setParam('skills', '2,' .. self.m_skill2)
        ui_network:setParam('skills', '3,' .. self.m_skill3)
        ui_network:setSuccessCB(success_cb)
        ui_network:request()

        return
    end
    
    if (self.m_bChangeSkill == false) then
        self:setCloseCB(nil)
    end
    self:close()
end

--@CHECK