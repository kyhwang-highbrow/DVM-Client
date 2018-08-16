local PARENT = UI

-------------------------------------
-- class UI_DragonDevApiPopup
-------------------------------------
UI_DragonDevApiPopup = class(PARENT, {
        m_dragonObjectID = 'string',

        m_evolution = 'number',
        m_grade = 'number',
        m_level = 'number',
		m_rlv = 'number',
		m_flv = 'number',

        m_skill0 = 'number',
        m_skill1 = 'number',
        m_skill2 = 'number',
        m_skill3 = 'number',

        m_skillMaxLv0 = 'number',
        m_skillMaxLv1 = 'number',
        m_skillMaxLv2 = 'number',
        m_skillMaxLv3 = 'number',

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
	self.m_rlv = t_dragon_data:getRlv()
	self.m_flv = t_dragon_data:getFlv()

    self.m_skill0 = t_dragon_data['skill_0']
    self.m_skill1 = t_dragon_data['skill_1']
    self.m_skill2 = t_dragon_data['skill_2']
    self.m_skill3 = t_dragon_data['skill_3']

    self.m_skillMaxLv0 = TableDragonSkillModify:getMaxLV(t_dragon['skill_active'])
    self.m_skillMaxLv1 = TableDragonSkillModify:getMaxLV(t_dragon['skill_1'])
    self.m_skillMaxLv2 = TableDragonSkillModify:getMaxLV(t_dragon['skill_2'])
    self.m_skillMaxLv3 = TableDragonSkillModify:getMaxLV(t_dragon['skill_3'])

end

-------------------------------------
-- function initButton
-------------------------------------
function UI_DragonDevApiPopup:initButton()
    local vars = self.vars

    local max_evolution = 3
    local max_grade = 6
    local max_level = 40
	local max_rlv = MAX_DRAGON_REINFORCE
	local max_flv = 9

    vars['evolutionUpBtn']:registerScriptTapHandler(function() self.m_evolution = math_clamp(self.m_evolution + 1, 1, max_evolution) self:refresh() end)
    vars['evolutionDownBtn']:registerScriptTapHandler(function() self.m_evolution = math_clamp(self.m_evolution - 1, 1, max_evolution) self:refresh() end)
    vars['evolutionMaxBtn']:registerScriptTapHandler(function() self.m_evolution = max_evolution self:refresh() end)

    vars['gradeUpBtn']:registerScriptTapHandler(function() self.m_grade = math_clamp(self.m_grade + 1, 1, max_grade) self:refresh() end)
    vars['gradeDownBtn']:registerScriptTapHandler(function()
        self.m_grade = math_clamp(self.m_grade - 1, 1, max_grade)
        self.m_level = math_clamp(self.m_level, 1, TableGradeInfo:getMaxLv(self.m_grade))
        self:refresh()
    end)
    vars['gradeMaxBtn']:registerScriptTapHandler(function() self.m_grade = 6 self:refresh() end)

    vars['levelUpBtn']:registerScriptTapHandler(function() self.m_level = math_clamp(self.m_level + 1, 1, TableGradeInfo:getMaxLv(self.m_grade)) self:refresh() end)
    vars['levelDownBtn']:registerScriptTapHandler(function() self.m_level = math_clamp(self.m_level - 1, 1, TableGradeInfo:getMaxLv(self.m_grade)) self:refresh() end)
    vars['levelMaxBtn']:registerScriptTapHandler(function() self.m_level = TableGradeInfo:getMaxLv(self.m_grade) self:refresh() end)

	-- 드래곤 친밀도
	vars['friendshipUpBtn']:registerScriptTapHandler(function() self.m_flv = math_clamp(self.m_flv + 1, 0, max_flv); self:refresh() end)
    vars['friendshipDownBtn']:registerScriptTapHandler(function() self.m_flv = math_clamp(self.m_flv - 1, 0, max_flv); self:refresh() end)
    vars['friendshipMaxBtn']:registerScriptTapHandler(function() self.m_flv = max_flv; self:refresh() end)

	-- 드래곤 강화
	vars['reinforceUpBtn']:registerScriptTapHandler(function() self.m_rlv = math_clamp(self.m_rlv + 1, 0, max_rlv) self:refresh() end)
    vars['reinforceDownBtn']:registerScriptTapHandler(function() self.m_rlv = math_clamp(self.m_rlv - 1, 0, max_rlv) self:refresh() end)
    vars['reinforceMaxBtn']:registerScriptTapHandler(function() self.m_rlv = max_rlv self:refresh() end)

    -- 스킬 레벨들
    vars['skillUpBtn0']:registerScriptTapHandler(function() self.m_skill0 = math_clamp(self.m_skill0 + 1, 1, self.m_skillMaxLv0) self:networkSkillLevel(0) end)
    vars['skillDownBtn0']:registerScriptTapHandler(function() self.m_skill0 = math_clamp(self.m_skill0 - 1, 1, self.m_skillMaxLv0) self:networkSkillLevel(0) end)
    vars['skillMaxBtn0']:registerScriptTapHandler(function() self.m_skill0 = self.m_skillMaxLv0 self:networkSkillLevel(0) end)

    vars['skillUpBtn1']:registerScriptTapHandler(function() self.m_skill1 = math_clamp(self.m_skill1 + 1, 0, self.m_skillMaxLv1) self:networkSkillLevel(1) end)
    vars['skillDownBtn1']:registerScriptTapHandler(function() self.m_skill1 = math_clamp(self.m_skill1 - 1, 0, self.m_skillMaxLv1) self:networkSkillLevel(1) end)
    vars['skillMaxBtn1']:registerScriptTapHandler(function() self.m_skill1 = self.m_skillMaxLv1 self:networkSkillLevel(1) end)

    vars['skillUpBtn2']:registerScriptTapHandler(function() self.m_skill2 = math_clamp(self.m_skill2 + 1, 0, self.m_skillMaxLv2) self:networkSkillLevel(2) end)
    vars['skillDownBtn2']:registerScriptTapHandler(function() self.m_skill2 = math_clamp(self.m_skill2 - 1, 0, self.m_skillMaxLv2) self:networkSkillLevel(2) end)
    vars['skillMaxBtn2']:registerScriptTapHandler(function() self.m_skill2 = self.m_skillMaxLv2 self:networkSkillLevel(2) end)

    vars['skillUpBtn3']:registerScriptTapHandler(function() self.m_skill3 = math_clamp(self.m_skill3 + 1, 0, self.m_skillMaxLv3) self:networkSkillLevel(3) end)
    vars['skillDownBtn3']:registerScriptTapHandler(function() self.m_skill3 = math_clamp(self.m_skill3 - 1, 0, self.m_skillMaxLv3) self:networkSkillLevel(3) end)
    vars['skillMaxBtn3']:registerScriptTapHandler(function() self.m_skill3 = self.m_skillMaxLv3 self:networkSkillLevel(3) end)

    -- 특성
    vars['masteryEraseBtn']:registerScriptTapHandler(function() self:click_masteryBtn('erase') end)
    vars['masteryUpBtn']:registerScriptTapHandler(function() self:click_masteryBtn('lvup') end)
    vars['masteryResetBtn']:registerScriptTapHandler(function() self:click_masteryBtn('reset') end)

	-- 특수 키
	vars['maxAllBtn']:registerScriptTapHandler(function() self:click_maxAllBtn() end)
	vars['copyBtn']:registerScriptTapHandler(function() self:click_copyBtn() end)

    vars['applyBtn']:registerScriptTapHandler(function() self:click_closeBtn() end)

    vars['closeBtn']:registerScriptTapHandler(function() self:click_closeBtn() end)
end


-------------------------------------
-- function click_maxAllBtn
-- @brief 하드코딩이니 추후 드래곤 시스템 변경 시 수정해주세요
-------------------------------------
function UI_DragonDevApiPopup:click_maxAllBtn()
    self.m_level = 60
	self.m_grade = 6
	self.m_evolution = 3
	self.m_rlv = 6
	self.m_flv = 9

	self.m_skill0 = 5
    self.m_skill1 = 5
    self.m_skill2 = 5
    self.m_skill3 = 1

	local function coroutine_function(dt)
		local co = CoroutineHelper()

		co:work()
		self:__networkSkillLevel(0, co.NEXT)
		if co:waitWork() then return end

		co:work()
		self:__networkSkillLevel(1, co.NEXT)
		if co:waitWork() then return end

		co:work()
		self:__networkSkillLevel(2, co.NEXT)

		co:work()
		if co:waitWork() then return end
		self:__networkSkillLevel(3, co.NEXT)

		UIManager:toastNotificationGreen('특성은 별도입니다.')
		self:refresh()
	end

	Coroutine(coroutine_function, 'MAX ALL API')
end

-------------------------------------
-- function click_copyBtn
-------------------------------------
function UI_DragonDevApiPopup:click_copyBtn()
    SDKManager:copyOntoClipBoard(tostring(self.m_dragonObjectID))
    UIManager:toastNotificationGreen('doid를 복사하였습니다.')
end

-------------------------------------
-- function click_masteryBtn
-- @brief 특성 조정
-------------------------------------
function UI_DragonDevApiPopup:click_masteryBtn(action)
    local function success_cb(ret)
        if ret and ret['modified_dragon'] then
            g_dragonsData:applyDragonData(ret['modified_dragon'])
            self:refresh()
            self.m_bChangeSkill = true -- 드래곤 관리창에서 갱신을 위해 설정
        end
    end

    local uid = g_userData:get('uid')
    local ui_network = UI_Network()
    ui_network:setUrl('/manage/dragon_mastery_' .. action)
    ui_network:setRevocable(true)
    ui_network:setParam('uid', uid)
    ui_network:setParam('doid', self.m_dragonObjectID)
    ui_network:setSuccessCB(success_cb)
    ui_network:request()
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_DragonDevApiPopup:refresh()
    local vars = self.vars

    vars['evolutionLabel']:setString('진화 : ' .. self.m_evolution)
    vars['gradeLabel']:setString('승급 : ' .. self.m_grade)
    vars['levelLabel']:setString('레벨 : ' .. self.m_level)
	vars['reinforceLabel']:setString('강화 : ' .. self.m_rlv)
	vars['friendshipLabel']:setString('친밀도 : ' .. self.m_flv)

    vars['skillLabel0']:setString('스킬 0 레벨 : ' .. self.m_skill0)
    vars['skillLabel1']:setString('스킬 1 레벨 : ' .. self.m_skill1)
    vars['skillLabel2']:setString('스킬 2 레벨 : ' .. self.m_skill2)
    vars['skillLabel3']:setString('스킬 3 레벨 : ' .. self.m_skill3)

    do -- 특성
        local dragon_obj = g_dragonsData:getDragonDataFromUid(self.m_dragonObjectID)
        vars['masteryLabel']:setString('특성 : ' .. dragon_obj:getMasteryLevel())
    end
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

    self:__networkSkillLevel(skill_idx, success_cb)
end

-------------------------------------
-- function __networkSkillLevel
-- @brief skill level up function
-------------------------------------
function UI_DragonDevApiPopup:__networkSkillLevel(skill_idx, cb_func)
	local uid = g_userData:get('uid')
    local ui_network = UI_Network()
    ui_network:setUrl('/dragons/update')
    ui_network:setRevocable(true)
    ui_network:setParam('uid', uid)
    ui_network:setParam('did', self.m_dragonObjectID)
    ui_network:setParam('act', 'update')
    ui_network:setParam('skills', string.format('%d,%d', skill_idx, self['m_skill' .. skill_idx]))
    ui_network:setSuccessCB(cb_func)
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

    if (t_dragon_data:getRlv() ~= self.m_rlv) then
        is_change = true
    end

	if (t_dragon_data:getFlv() ~= self.m_flv) then
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
		ui_network:setParam('reinforce', 'lv,' .. self.m_rlv)
		ui_network:setParam('friendship', 'lv,' .. self.m_flv)
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