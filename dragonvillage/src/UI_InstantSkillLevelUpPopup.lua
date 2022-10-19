--@inherit UI
local PARENT = UI_DragonManage_Base

-------------------------------------
---@class UI_InstantSkillLevelUpPopup
-------------------------------------
UI_InstantSkillLevelUpPopup = class(PARENT, {
    --m_selectDragonData = 'table',
    --m_selectDragonOID = 'number',
    m_targetRarity = 'string',

    m_dragonAnimator = 'UIC_DragonAnimator',
    m_mailID = 'number',
    m_itemID = 'number',
    m_successCB = 'function',
})

-------------------------------------
-- function init
-------------------------------------
function UI_InstantSkillLevelUpPopup:init(mail_id, item_id, success_cb)
    self.m_uiName = 'UI_InstantSkillLevelUpPopup'
    self.m_resName = 'instant_skill_levelup_popup.ui'
    self.m_targetRarity = 'myth'
    self.m_mailID = mail_id
    self.m_itemID = item_id
    self.m_successCB = success_cb
end

-------------------------------------
-- function init_after
-------------------------------------
function UI_InstantSkillLevelUpPopup:init_after()
    self:load(self.m_resName)
    UIManager:open(self, UIManager.POPUP)

    g_currScene:pushBackKeyListener(self, function() self:click_closeBtn() end, self.m_uiName)

    self:doActionReset()
    self:doAction(nil, false)

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_InstantSkillLevelUpPopup:initUI()
    local vars = self.vars

    self:init_dragonTableView() -- from UI_DragonManage_Base

    self.m_dragonAnimator = UIC_DragonAnimator()
    vars['dragonNode']:addChild(self.m_dragonAnimator.m_node)

    self:setDefaultSelectDragon()

    -- initTab
    self:addTabAuto(UI_DragonSkillEnhance.TAB_ENHANCE, vars, vars['materialTableViewNode'])
    --self:addTabAuto(UI_DragonSkillEnhance.TAB_MOVE, vars, vars['moveTableViewNode'])
    self:setTab(UI_DragonSkillEnhance.TAB_ENHANCE)
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_InstantSkillLevelUpPopup:initButton()
    local vars = self.vars

    if vars['closeBtn'] then
        vars['closeBtn']:registerScriptTapHandler(function() self:click_closeBtn() end)
    end

    vars['enhanceBtn']:registerScriptTapHandler(function() self:click_enhanceBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_InstantSkillLevelUpPopup:refresh()
    local vars = self.vars
    ---@type StructDragonObject
    local struct_dragon_object = self.m_selectDragonData

    if (not struct_dragon_object) then
        return
    end
    
    local attr = struct_dragon_object:getAttr()
    local role_type = struct_dragon_object:getRole()

    local rarity_type = struct_dragon_object:getRarity()
    local t_info = DragonInfoIconHelper.makeInfoParamTable(attr, role_type, rarity_type)
    
    do -- 드래곤 이름
        vars['dragonNameLabel']:setString(struct_dragon_object:getDragonNameWithEclv())
    end
    
    do -- 드래곤 속성
        vars['attrNode']:removeAllChildren()
        DragonInfoIconHelper.setDragonAttrBtn(attr, vars['attrNode'], vars['attrLabel'], t_info)
    end

    do -- 드래곤 역할(role)
        vars['typeNode']:removeAllChildren()
        DragonInfoIconHelper.setDragonRoleBtn(role_type, vars['typeNode'], vars['typeLabel'], t_info)
    end

    do -- 희귀도
        vars['rarityNode']:removeAllChildren()
        DragonInfoIconHelper.setDragonRarityBtn(rarity_type, vars['rarityNode'], vars['rarityLabel'], t_info)
    end

    do -- 드래곤 현재 정보 카드
        vars['dragonIconNode']:removeAllChildren()
        local dragon_card = UI_DragonCard(struct_dragon_object)
        vars['dragonIconNode']:addChild(dragon_card.root)
    end

    do -- 드래곤 애니메이션
        local did = struct_dragon_object['did']
        local evolution = struct_dragon_object:getEvolution()
        self.m_dragonAnimator:setDragonAnimator(did, evolution)
    end

    do -- 등급            
        vars['starNode']:removeAllChildren()
        
        local star_icon = IconHelper:getDragonGradeIcon(struct_dragon_object, 2)
        vars['starNode']:addChild(star_icon)
    end

        -- 레벨업 가능 여부 처리
	local possible = g_dragonsData:possibleDragonSkillEnhance(self.m_selectDragonOID)
    if (not possible) then
        if (struct_dragon_object['evolution'] < MAX_DRAGON_EVOLUTION) then
            local next_evolution = struct_dragon_object['evolution'] + 1
            local tar_evolution = evolutionName(next_evolution)
	        vars['lockSprite']:setVisible(true)
            vars['infoLabel2']:setString(Str('{1} 진화시 스킬 레벨업이 가능해요 ', tar_evolution))
        end
    end

	self:refresh_skillIcon()
end

-------------------------------------
-- function refresh_skillIcon
-------------------------------------
function UI_InstantSkillLevelUpPopup:refresh_skillIcon()
	local vars = self.vars

	local struct_dragon_object = self.m_selectDragonData

	local skill_mgr = MakeDragonSkillFromDragonData(struct_dragon_object)
	local l_skill_icon = skill_mgr:getDragonSkillIconList()

	for _, i in ipairs(IDragonSkillManager:getSkillKeyList()) do
		local skill_node = vars['skillNode' .. i]
		skill_node:removeAllChildren()
            
		-- 스킬 아이콘 생성
		if l_skill_icon[i] then
			skill_node:addChild(l_skill_icon[i].root)
            l_skill_icon[i].vars['clickBtn']:setActionType(UIC_Button.ACTION_TYPE_WITHOUT_SCAILING)
            l_skill_icon[i].vars['clickBtn']:registerScriptTapHandler(function()
				UI_SkillDetailPopup(struct_dragon_object, i)
			end)

		-- 비어있는 스킬 아이콘 생성
		else
			local empty_skill_icon = IconHelper:getEmptySkillCard()
			skill_node:addChild(empty_skill_icon)

		end
	end
end

-------------------------------------
-- function getDragonList
-- @breif 하단 리스트뷰에 노출될 드래곤 리스트
---@return table
-------------------------------------
function UI_InstantSkillLevelUpPopup:getDragonList()
    if isString(self.m_targetRarity) then
        return g_dragonsData:getDragonsListWithRarity('myth')
    else
        return g_dragonsData:getDragonsList()
    end
end

-------------------------------------
-- function click_closeBtn
-------------------------------------
function UI_InstantSkillLevelUpPopup:click_closeBtn(is_success)
    if is_success and isFunction(self.m_successCB) then
        self.m_successCB() 
    end

    self:close()
end

-------------------------------------
-- function click_enhanceBtn
-------------------------------------
function UI_InstantSkillLevelUpPopup:click_enhanceBtn()
    local mid = self.m_mailID
    local doid = self.m_selectDragonOID
    local t_prev_dragon_data = self.m_selectDragonData

    local function success_cb(ret)
        local function finish_cb()
            local mod_struct_dragon = StructDragonObject(ret['modified_dragon'])
            local ui = UI_DragonSkillEnhance_Result(t_prev_dragon_data, mod_struct_dragon)
		    ui:setCloseCB(function()
			    -- 스킬 강화 가능 여부 판별하여 가능하지 않으면 닫아버림
			    local impossible, msg = g_dragonsData:impossibleSkillEnhanceForever(doid)
			    if (impossible) then
				    UIManager:toastNotificationRed(msg)
				    self:click_closeBtn(true)
			    end
		    end)

            -- 동시에 본UI 갱신
		    self.m_selectDragonData = mod_struct_dragon
            self:refresh()
        end

        self:createLevelUpAnimator(finish_cb)
    end
    
    g_dragonsData:request_instantSkillLevelUp(mid, doid, success_cb)
end


-------------------------------------
-- function createLevelUpAnimator
---@param finish_cb  function
-------------------------------------
function UI_InstantSkillLevelUpPopup:createLevelUpAnimator(finish_cb)
    local block_ui = UI_BlockPopup() 
    local res_path = 'res/ui/a2d/dragon_skill_enhance_move/dragon_skill_enhance_move.vrp'

    -- SKILL LV UP 
    do
        local slot = g_dragonsData:getChangeSkillLvSlot(self.m_selectDragonData)
        local target_node = self.vars['skillNode'..slot]

        local effect = MakeAnimator(res_path)
        effect:changeAni('lvup', false)
        effect:setPosition(ZERO_POINT)
        effect:setScale(1.2)
        target_node:addChild(effect.m_node)

        local duration = effect:getDuration()
        effect:runAction(cc.Sequence:create(
            cc.DelayTime:create(duration),
            cc.CallFunc:create(function() 
                if (finish_cb) then
                    finish_cb()
                end
                block_ui:close()
            end),
            cc.RemoveSelf:create()
        ))
    end
end



