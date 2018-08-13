local PARENT = UI

-------------------------------------
-- class UI_DragonMasterySkillLevelUpPopup
-------------------------------------
UI_DragonMasterySkillLevelUpPopup = class(PARENT,{
        m_dragonObject = 'StructDragonObject',
        m_masterySkillTier = 'number',
        m_masterySkillNum = 'number',
        m_bChanged = 'boolean', -- 초기화 실행 여부
    })

-------------------------------------
-- function init
-------------------------------------
function UI_DragonMasterySkillLevelUpPopup:init(dragon_obj, mastery_skill_tier, mastery_skill_num)
    self.m_dragonObject = dragon_obj
    self.m_masterySkillTier = mastery_skill_tier
    self.m_masterySkillNum = mastery_skill_num
    self.m_bChanged = false

    local vars = self:load('dragon_mastery_skill_levelup_popup.ui')
    UIManager:open(self, UIManager.POPUP)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:click_closeBtn() end, 'UI_DragonMasterySkillLevelUpPopup')

    -- @UI_ACTION
    --self:addAction(vars['rootNode'], UI_ACTION_TYPE_LEFT, 0, 0.2)
    self:doActionReset()
    self:doAction(nil, false)

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_DragonMasterySkillLevelUpPopup:initUI()
    local vars = self.vars
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_DragonMasterySkillLevelUpPopup:initButton()
    local vars = self.vars
    vars['closeBtn']:registerScriptTapHandler(function() self:click_closeBtn() end)
    vars['enhanceBtn']:registerScriptTapHandler(function() self:click_enhanceBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_DragonMasterySkillLevelUpPopup:refresh()
    local vars = self.vars

    local dragon_obj = self.m_dragonObject
    local tier = self.m_masterySkillTier
    local num = self.m_masterySkillNum

    local rarity_str = dragon_obj:getRarity()
    local role_str = dragon_obj:getRole()

    -- 특성 스킬 ID
    local mastery_skill_id = TableMasterySkill:makeMasterySkillID(rarity_str, role_str, tier, num)

    -- 특성 스킬 LV
    local mastery_skill_lv = dragon_obj:getMasterySkilLevel(mastery_skill_id)

    -- 스킬 아이콘
    vars['skillIconNode']:removeAllChildren()
    --local icon = UI_DragonMasterySkillCard(mastery_skill_id, mastery_skill_lv)
    local res_name = TableMasterySkill():getValue(mastery_skill_id, 'icon')
    local icon = IconHelper:getIcon(res_name)
    vars['skillIconNode']:addChild(icon)

    -- 스킬 설명
    local name = TableMasterySkill:getMasterySkillName(mastery_skill_id)
    vars['skillLabel1']:setString('{@DESC}' .. (name or ''))
    local curr_text = TableMasterySkill:getMasterySkillStepDesc_single(mastery_skill_id, mastery_skill_lv)
    local next_text = TableMasterySkill:getMasterySkillStepDesc_single(mastery_skill_id, mastery_skill_lv + 1)
    vars['skillLabel2']:setString(curr_text)
    vars['skillLabel3']:setString(next_text)


    -- 특성 스킬 레벨 / 보유 특성 스킬 포인트
    local mastery_level = dragon_obj:getMasteryLevel()
    local mastery_point = dragon_obj:getMasteryPoint()
    vars['masteryLabel']:setString(Str('특성 레벨 {1}', mastery_level))
    vars['spLabel']:setString(Str('스킬 포인트: {1}', mastery_point))


    -- 스킬 포인트 수량
    local req_count = 1
    local own_count = mastery_point
    local str = Str('{1} / {2}', own_count, req_count)
    if (req_count <= own_count) then
        str = '{@possible}' .. str
    else
        str = '{@impossible}' .. str
    end
    vars['priceLabel']:setString(str)
end

-------------------------------------
-- function click_closeBtn
-------------------------------------
function UI_DragonMasterySkillLevelUpPopup:click_closeBtn()
    self:close()
end

-------------------------------------
-- function click_enhanceBtn
-------------------------------------
function UI_DragonMasterySkillLevelUpPopup:click_enhanceBtn()
    local dragon_obj = self.m_dragonObject
    local vars = self.vars

    -- 스킬 포인트가 있는지 확인
    local mastery_point = dragon_obj:getMasteryPoint()
    if (mastery_point <= 0) then
        UIManager:toastNotificationRed(Str('스킬 포인트가 부족합니다.'))
        cca.uiImpossibleAction(vars['enhanceBtn'])
        return
    end

    local function cb_func(ret)
        self.m_bChanged = true
        self:close()
    end
    
    local function fail_cb()
    end

    local doid = self.m_dragonObject['id']
    local mastery_skill_id = MasteryHelper:makeMasterySkillID(self.m_dragonObject, self.m_masterySkillTier, self.m_masterySkillNum)

    self:request_mastery_skillup(doid, mastery_skill_id, cb_func, fail_cb)
end


-------------------------------------
-- function request_mastery_skillup
-- @brief
-------------------------------------
function UI_DragonMasterySkillLevelUpPopup:request_mastery_skillup(doid, mastery_skill_id, cb_func, fail_cb)
    local uid = g_userData:get('uid')

    --[[
    -- 에러코드 처리
    local function response_status_cb(ret)
        return true
    end

    -- 통신실패 처리
    local function response_fail_cb(ret)
    end
    --]]

    local function success_cb(ret)
		-- 드래곤 갱신
		g_dragonsData:applyDragonData(ret['modified_dragon'])

		-- 재화 갱신
		g_serverData:networkCommonRespone(ret)

		if (cb_func) then
			cb_func()
		end
    end

    local ui_network = UI_Network()
    ui_network:setUrl('/dragons/mastery_skillup')
    ui_network:setParam('uid', uid)
    ui_network:setParam('doid', doid)
    ui_network:setParam('mastery_id', mastery_skill_id)
	--ui_network:hideLoading()
    ui_network:setRevocable(true)
    --ui_network:setResponseStatusCB(response_status_cb)
    ui_network:setSuccessCB(function(ret) success_cb(ret) end)
    --ui_network:setFailCB(response_fail_cb)
    ui_network:request()
end

-------------------------------------
-- function isChanged
-- @brief 레벨업 실행 여부
-------------------------------------
function UI_DragonMasterySkillLevelUpPopup:isChanged()
    return self.m_bChanged
end

--@CHECK
UI:checkCompileError(UI_DragonMasterySkillLevelUpPopup)
