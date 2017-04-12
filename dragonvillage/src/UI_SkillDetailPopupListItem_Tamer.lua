local PARENT = UI
 
-------------------------------------
-- class UI_SkillDetailPopupListItem_Tamer
-------------------------------------
UI_SkillDetailPopupListItem_Tamer = class(PARENT, {
        m_tableTamer = '',
        m_skillMgr = '',
        m_skillIdx = '',
        m_bSimpleMode = '',
     })

-------------------------------------
-- function init
-------------------------------------
function UI_SkillDetailPopupListItem_Tamer:init(t_tamer, skill_mgr, skill_idx, is_simple_mode)
    self.m_tableTamer = t_tamer
    self.m_skillMgr = skill_mgr
    self.m_skillIdx = skill_idx
    self.m_bSimpleMode = is_simple_mode

    local vars = self:load('tamer_skill_detail_popup_item.ui')
  
    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_SkillDetailPopupListItem_Tamer:initUI()
    local vars = self.vars
    local skill_indivisual_info = self.m_skillMgr:getSkillIndivisualInfo_usingIdx(self.m_skillIdx)

    do -- 스킬 타입
        local skill_idx = self.m_skillIdx
        local evolution = skill_idx
        local str = getSkillType_byEvolution(evolution)
        vars['skillTypeLabel']:setString(str)
    end

    do -- 스킬 아이콘
		local char_type = skill_indivisual_info.m_charType
        local skill_id = skill_indivisual_info:getSkillID()
        local icon = IconHelper:getSkillIcon(char_type, skill_id)
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
function UI_SkillDetailPopupListItem_Tamer:initButton()
    local vars = self.vars
    --vars['enhanceBtn']:registerScriptTapHandler(function() self:click_enhanceBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_SkillDetailPopupListItem_Tamer:refresh()
    local vars = self.vars
    local skill_indivisual_info = self.m_skillMgr:getSkillIndivisualInfo_usingIdx(self.m_skillIdx)

    do -- 레벨 표시
        local skill_level = skill_indivisual_info:getSkillLevel()
        local max_lv_segment, max_lv = self:getSkillMaxLevel()
        --vars['skillEnhanceLabel']:setString(Str('Lv.{1}/{2}', skill_level, max_lv_segment))
		vars['skillEnhanceLabel']:setString(Str('Lv. {1}', skill_level))
    end

    do -- 스킬 설명
        local desc = skill_indivisual_info:getSkillDesc()
        vars['skillDscLabel']:setString(desc)
    end
end

-------------------------------------
-- function getSkillMaxLevel
-------------------------------------
function UI_SkillDetailPopupListItem_Tamer:getSkillMaxLevel()
    return 10
end

-------------------------------------
-- function click_enhanceBtn
-------------------------------------
function UI_SkillDetailPopupListItem_Tamer:click_enhanceBtn()
    local skill_indivisual_info = self.m_skillMgr:getSkillIndivisualInfo_usingIdx(self.m_skillIdx)

    do -- 초월 구간별 최대 레벨 확인
        local skill_level = skill_indivisual_info:getSkillLevel()
        local max_lv_segment, max_lv = self:getSkillMaxLevel()

        if (max_lv_segment <= skill_level) then
            local msg = Str('드래곤 초월 단계에 따라 스킬 강화 최대치가 상승합니다.\n초월 화면으로 이동하시겠습니까?')
            local function ok_cb()
                local doid = self.m_tableTamer['id']
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
    local req_gold = TableDragonSkillEnhance:getDragonSkillEnhanceReqGold(skill_level)

    local item_type = 'gold'
    local item_value = req_gold
    local function ok_btn_cb()
        self:request_skillEnhance()
    end
    local cancel_btn_cb = nil

    MakeSimplePopup_Confirm(item_type, item_value, '스킬을 강화하시겠습니까?', ok_btn_cb, cancel_btn_cb)
end


-------------------------------------
-- function request_skillEnhance
-------------------------------------
function UI_SkillDetailPopupListItem_Tamer:request_skillEnhance()
    local uid = g_userData:get('uid')
    local doid = self.m_tableTamer['id']
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
end

-------------------------------------
-- function refresh_enhance
-------------------------------------
function UI_SkillDetailPopupListItem_Tamer:refresh_enhance()
    local old_dragon_data = self.m_tableTamer
    local new_dragon_data = g_dragonsData:getDragonDataFromUid(old_dragon_data['id'])

    if (old_dragon_data['updated_at'] == new_dragon_data['updated_at']) then
        return
    end

    self.m_tableTamer = new_dragon_data
    self.m_skillMgr = MakeDragonSkillFromDragonData(self.m_tableTamer)

    self:refresh()
end