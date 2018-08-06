local PARENT = UI_DragonManage_Base

-------------------------------------
-- class UI_DragonMastery
-------------------------------------
UI_DragonMastery = class(PARENT,{
    })

UI_DragonMastery.TAB_LVUP = 'mastery' -- 특성 레벨업
UI_DragonMastery.TAB_SKILL = 'skill' -- 특성 스킬

-------------------------------------
-- function initParentVariable
-- @brief 자식 클래스에서 반드시 구현할 것
-------------------------------------
function UI_DragonMastery:initParentVariable()
    -- ITopUserInfo_EventListener의 맴버 변수들 설정
    self.m_uiName = 'UI_DragonMastery'
    self.m_bVisible = true or false
    self.m_titleStr = Str('특성')
    self.m_bUseExitBtn = true or false -- click_exitBtn()함구 구현이 반드시 필요함
end

-------------------------------------
-- function init
-------------------------------------
function UI_DragonMastery:init(doid)
    local vars = self:load('dragon_mastery.ui')
    UIManager:open(self, UIManager.SCENE)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_DragonMastery')

    self:sceneFadeInAction()

    self:initUI()
    self:initTab()
    self:initButton()
    self:refresh()

    -- 첫 선택 드래곤 지정
    self:setDefaultSelectDragon(doid)

    -- 정렬 도우미
    self:init_dragonSortMgr()
	--self:init_mtrDragonSortMgr(true) -- slime_first
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_DragonMastery:initUI()
    local vars = self.vars
    self:init_dragonTableView()
    self:initStatusUI()
end

-------------------------------------
-- function initTab
-------------------------------------
function UI_DragonMastery:initTab()
    local vars = self.vars
    self:addTabAuto(UI_DragonMastery.TAB_LVUP, vars, vars['masteryLvUpMenu'])
    self:addTabAuto(UI_DragonMastery.TAB_SKILL, vars, vars['masterySkillMenu'])
    self:setTab(UI_DragonMastery.TAB_LVUP)

	self:setChangeTabCB(function(tab, first) self:onChangeTab(tab, first) end)
end

-------------------------------------
-- function onChangeTab
-------------------------------------
function UI_DragonMastery:onChangeTab(tab, first)
    local vars = self.vars
end

-------------------------------------
-- function initStatusUI
-------------------------------------
function UI_DragonMastery:initStatusUI()
    local vars = self.vars
end

-------------------------------------
-- function initButton
-- @brief 버튼 UI 초기화
-------------------------------------
function UI_DragonMastery:initButton()
    local vars = self.vars
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_DragonMastery:refresh()
end

-------------------------------------
-- function refresh_dragonInfo
-- @brief 드래곤 정보
-------------------------------------
function UI_DragonMastery:refresh_dragonInfo()
    local t_dragon_data = self.m_selectDragonData

    if (not t_dragon_data) then
        return
    end

    local vars = self.vars
end

-------------------------------------
-- function getDragonList
-- @breif 하단 리스트뷰에 노출될 드래곤 리스트
-- @override
-------------------------------------
function UI_DragonMastery:getDragonList()
    local dragon_dic = g_dragonsData:getDragonsList()

    -- 특성 조건이 되지 않는 드래곤 제거 (6성 60레벨)
    for oid, v in pairs(dragon_dic) do
        if (v:isMaxGradeAndLv() == false) then
            dragon_dic[oid] = nil
        end
    end

    return dragon_dic
end

-------------------------------------
-- function getDragonMaterialList
-- @brief 재료리스트 : 레벨업
-- @override
-------------------------------------
function UI_DragonMastery:getDragonMaterialList(doid)
end

-------------------------------------
-- function click_dragonMaterial
-- @override
-------------------------------------
function UI_DragonMastery:click_dragonMaterial(t_dragon_data)
end

-------------------------------------
-- function refresh_materialDragonIndivisual
-- @brief 드래곤 재료 리스트에서 선택된 드래곤 표시
-------------------------------------
function UI_DragonMastery:refresh_materialDragonIndivisual(doid)
end

-------------------------------------
-- function refresh_selectedMaterial
-- @brief 선택된 재료의 구성이 변경되었을때
-------------------------------------
function UI_DragonMastery:refresh_selectedMaterial()
end

-------------------------------------
-- function refresh_stats
-- @brief 능력치
-------------------------------------
function UI_DragonMastery:refresh_stats(t_dragon_data, lv)
end

-------------------------------------
-- function createDragonCardCB
-- @brief 드래곤 생성 콜백
-- @override
-------------------------------------
function UI_DragonMastery:createDragonCardCB(ui, data)
end

-------------------------------------
-- function createMtrlDragonCardCB
-- @brief 재료 카드 만든 후..
-------------------------------------
function UI_DragonMastery:createMtrlDragonCardCB(ui, data)
end


--@CHECK
UI:checkCompileError(UI_DragonMastery)
