local PARENT = UI

-------------------------------------
-- class UI_SkillDetailPopupListItem
-------------------------------------
UI_SkillDetailPopupListItem = class(PARENT, {
        m_dragonData = '',
		m_skillIndividualInfo = '',
        m_bSimpleMode = '',
     })

-------------------------------------
-- function init
-------------------------------------
function UI_SkillDetailPopupListItem:init(t_dragon_data, skill_indivisual_info, is_simple_mode)
    self.m_dragonData = t_dragon_data
    self.m_skillIndividualInfo = skill_indivisual_info
    self.m_bSimpleMode = is_simple_mode

    local vars = self:load('dragon_skill_detail_popup_item.ui')
  
    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_SkillDetailPopupListItem:initUI()
    local vars = self.vars
    local skill_indivisual_info = self.m_skillIndividualInfo

    do -- 스킬 타입
        local str = skill_indivisual_info:getSkillType()
        vars['skillTypeLabel']:setString(str)
    end

    do -- 스킬 아이콘
        local skill_id = skill_indivisual_info:getSkillID()
        local icon = IconHelper:getSkillIcon('dragon', skill_id)
        vars['skillNode']:addChild(icon)
    end

    do -- 스킬 이름
        local name = skill_indivisual_info:getSkillName()
        vars['skillNameLabel']:setString(name)
    end
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_SkillDetailPopupListItem:initButton()
    local vars = self.vars
    vars['enhanceBtn']:registerScriptTapHandler(function() self:click_enhanceBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_SkillDetailPopupListItem:refresh()
    local vars = self.vars
    local skill_indivisual_info = self.m_skillIndividualInfo

    do -- 스킬 오픈 여부
		--[[
        local skill_level = skill_indivisual_info:getSkillLevel()
        if (skill_level <= 0) then
            vars['skillOpenSprite']:setVisible(true)

            local skill_idx = self.m_skillIdx
            if (skill_idx == 2) then
                vars['skillOpenLabel']:setString(Str('해츨링 스킬'))
            elseif (skill_idx == 3) then
                vars['skillOpenLabel']:setString(Str('성룡 스킬'))
            else
                error('skill_idx : ' .. skill_idx)
            end
        else
        end
		]]
        vars['skillOpenSprite']:setVisible(false)
    end

    do -- 레벨 표시
        local skill_level = skill_indivisual_info:getSkillLevel()
        local max_lv_segment, max_lv = self:getSkillMaxLevel()
        vars['skillEnhanceLabel']:setString(Str('Lv.{1}/{2}', skill_level, max_lv_segment))
    end

    do -- 스킬 설명
        local desc = skill_indivisual_info:getSkillDesc()
        vars['skillDscLabel']:setString(desc)
    end

    do -- 강화 가격 표시
        local skill_level = skill_indivisual_info:getSkillLevel()
        local req_gold = TableReqGold:getDragonSkillEnhanceReqGold(skill_level)
        vars['priceLabel']:setString(comma_value(req_gold))
    end

    do
        if self.m_bSimpleMode then
            vars['lockSprite']:setVisible(false)
            vars['maxSprite']:setVisible(false)
            vars['enhanceBtn']:setVisible(false)
        else
            local skill_level = skill_indivisual_info:getSkillLevel()
            local max_lv_segment, max_lv = self:getSkillMaxLevel()
            --vars['enhanceBtn']:setVisible(true)

            vars['lockSprite']:setVisible(false)
            vars['maxSprite']:setVisible(false)
            vars['enhanceBtn']:setVisible(false)

            -- 미습득 상황
            if (skill_level <= 0) then
                vars['lockSprite']:setVisible(true)

            -- 최대 레벨
            elseif (max_lv <= skill_level) then
                vars['maxSprite']:setVisible(true)

            -- 구간별 최대 레벨
            elseif (max_lv_segment <= skill_level) then
                vars['enhanceBtn']:setVisible(true)
                vars['enhanceBtnLabel']:setString(Str('강화 단계 상승'))

            -- 강화가 가능한 상태
            else
                vars['enhanceBtn']:setVisible(true)
                vars['enhanceBtnLabel']:setString(Str('강화'))
            end
        end
    end
end

-------------------------------------
-- function getSkillMaxLevel
-------------------------------------
function UI_SkillDetailPopupListItem:getSkillMaxLevel()
--[[
    local eclv = self.m_dragonData['eclv']
    local skill_idx = self.m_skillIdx

    -- 초월 구간별 최대 레벨
    local max_lv_segment = 1

    -- 최대 초월에서의 최대 레벨
    local max_lv = 1

    -- skill_idx가 3인 경우 1레벨이 MAX
    if (skill_idx == 3) then
        max_lv_segment = 1
        max_lv = 1
    else
        max_lv_segment = 10 + (eclv * 10), 10
        max_lv = 10 + (MAX_DRAGON_ECLV * 10)
    end

    return max_lv_segment, max_lv
	]]

	return 10, 10
end

-------------------------------------
-- function click_enhanceBtn
-------------------------------------
function UI_SkillDetailPopupListItem:click_enhanceBtn()
--[[
    local skill_indivisual_info = self.m_skillIndividualInfo

    do -- 초월 구간별 최대 레벨 확인
        local skill_level = skill_indivisual_info:getSkillLevel()
        local max_lv_segment, max_lv = self:getSkillMaxLevel()

        if (max_lv_segment <= skill_level) then
            local msg = Str('드래곤 초월 단계에 따라 스킬 강화 최대치가 상승합니다.\n초월 화면으로 이동하시겠습니까?')
            local function ok_cb()
                local doid = self.m_dragonData['id']
                UINavigator:goTo_transcend(doid)
                return true -- 팝업을 닫지 말라는 의미
            end
            MakeSimplePopup(POPUP_TYPE.YES_NO, msg, ok_cb)
            -- 초월 안내
            return
        end
    end

    -- 확인 팝업
    local skill_level = skill_indivisual_info:getSkillLevel()
    local req_gold = TableReqGold:getDragonSkillEnhanceReqGold(skill_level)

    local item_type = 'gold'
    local item_value = req_gold
    local function ok_btn_cb()
        self:request_skillEnhance()
    end
    local cancel_btn_cb = nil

    --MakeSimplePopup_Confirm(item_type, item_value, '스킬을 강화하시겠습니까?', ok_btn_cb, cancel_btn_cb)
    ok_btn_cb()
	]]
end


-------------------------------------
-- function request_skillEnhance
-------------------------------------
function UI_SkillDetailPopupListItem:request_skillEnhance()
--[[
    local uid = g_userData:get('uid')
    local doid = self.m_dragonData['id']
    local skill = self.m_skillIdx

    local function success_cb(ret)
        -- 드래곤 정보 갱신
        g_dragonsData:applyDragonData(ret['modified_dragon'])

        -- 골드 갱신
        if ret['gold'] then
            g_serverData:applyServerData(ret['gold'], 'user', 'gold')
            g_topUserInfo:refreshData()
        end

        self:refresh_enhance()

        self.vars['EnhanceVisual']:setVisible(true)
        self.vars['EnhanceVisual']:changeAni('slot_fx_01', false)
        self.vars['EnhanceVisual']:addAniHandler(function() self.vars['EnhanceVisual']:setVisible(false) end)
    end

    local ui_network = UI_Network()
    ui_network:setUrl('/dragons/skillup')
    ui_network:setParam('uid', uid)
    ui_network:setParam('doid', doid)
    ui_network:setParam('skill', skill)
    ui_network:setRevocable(true)
    ui_network:setSuccessCB(function(ret) success_cb(ret) end)
    ui_network:request()
	]]
end

-------------------------------------
-- function refresh_enhance
-------------------------------------
function UI_SkillDetailPopupListItem:refresh_enhance()
--[[
    local old_dragon_data = self.m_dragonData
    local new_dragon_data = g_dragonsData:getDragonDataFromUid(old_dragon_data['id'])

    if (old_dragon_data['updated_at'] == new_dragon_data['updated_at']) then
        return
    end

    self.m_dragonData = new_dragon_data

    self:refresh()
	]]
end