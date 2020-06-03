local PARENT = UI

-------------------------------------
-- class UI_LoadingGuide_Patch
-------------------------------------
UI_LoadingGuide_Patch = class(PARENT,{
		m_lPatchGuideTable = 'list<table>',
		m_numberLoop = 'NumberLoop',
		m_patchTimer = 'num',
		m_getNextTime = 'num',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_LoadingGuide_Patch:init()
    local vars = self:load('loading_tip.ui')
	local guide_type = 'patch'

	-- 멤버 변수
	self.m_lPatchGuideTable = TableLoadingGuide():getGuideList(guide_type)
    local guid_cnt = table.count(self.m_lPatchGuideTable)
	self.m_numberLoop = NumberLoop(guid_cnt)
	self.m_patchTimer = 0
	self.m_getNextTime = 5

	-- init 함수
	self:initUI()
	self:initButton()
	self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_LoadingGuide_Patch:initUI()
	local vars = self.vars

	vars['prevBtn']:setVisible(true)
	vars['nextBtn']:setVisible(true)
	vars['loadingGauge']:setPercentage(0)
end

-------------------------------------
-- function initButton
-- @brief 버튼 UI 초기화
-------------------------------------
function UI_LoadingGuide_Patch:initButton()
	local vars = self.vars
	
	vars['prevBtn']:registerScriptTapHandler(function() self:click_prevBtn() end)
	vars['nextBtn']:registerScriptTapHandler(function() self:click_nextBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_LoadingGuide_Patch:refresh(is_prev)
    local vars = self.vars
	local tar_idx = (is_prev) and self.m_numberLoop:prev() or self.m_numberLoop:next()
	local t_loading = self:getNextGuideTable(tar_idx)

	if (t_loading) then
        self:setCleanMenu()
        -- table에 did값 입력되있으면 드래곤 스파인 보여줌
        local is_dragon = (t_loading['did'] ~= '') and true or false
        if (is_dragon) then
            self:showDragonInfo(t_loading)
        else
            self:showTipInfo(t_loading)
        end
	else
		vars['tipLabel']:setString('')
	end
end

-------------------------------------
-- function getNextGuideTable
-------------------------------------
function UI_LoadingGuide_Patch:getNextGuideTable(idx)
	local ret_data = TableLoadingGuide:getGuideData_Order(self.m_lPatchGuideTable, idx)
	
	return ret_data
end

-------------------------------------
-- function setCleanMenu
-------------------------------------
function UI_LoadingGuide_Patch:setCleanMenu()
    local vars = self.vars
    vars['tipMenu']:setVisible(false)
    vars['tipNode']:removeAllChildren()

    vars['dragonMenu']:setVisible(false)
    vars['dragonNode']:removeAllChildren()
end

-------------------------------------
-- function showDragonInfo
-------------------------------------
function UI_LoadingGuide_Patch:showDragonInfo(t_loading)
    local vars = self.vars
    vars['dragonMenu']:setVisible(true)

    local did = t_loading['did']
    local ani_dragon = AnimatorHelper:makeDragonAnimator_usingDid(did)
    vars['dragonNode']:addChild(ani_dragon.m_node)

    local t_dragon = TableDragon():get(did)
    vars['infoLabel']:setVisible(false) -- 높이, 체중 미정
    vars['nameLabel']:setString(Str(t_dragon['t_name']))
    vars['dscLabel']:setString(Str(t_dragon['t_desc']))
end

-------------------------------------
-- function showTipInfo
-------------------------------------
function UI_LoadingGuide_Patch:showTipInfo(t_loading)
    local vars = self.vars
    vars['tipMenu']:setVisible(true)

    local tip_icon = IconHelper:getIcon(t_loading['res'])
    vars['tipNode']:addChild(tip_icon)
    vars['tipLabel']:setString(Str(t_loading['t_desc']))

	-- desc가 없다면 큰 이미지. 위치를 조절해준다
	if (t_loading['t_desc'] == '') then
		vars['tipNode']:setPositionY(10)

	-- 기본값
	else
		vars['tipNode']:setPositionY(94) 
	end	
end

-------------------------------------
-- function update
-------------------------------------
function UI_LoadingGuide_Patch:update(dt)
	self.m_patchTimer = self.m_patchTimer + dt
	if (self.m_patchTimer > self.m_getNextTime) then
		self:refresh()
		self.m_patchTimer = self.m_patchTimer - self.m_getNextTime
	end
end


-------------------------------------
-- function click_prevBtn
-------------------------------------
function UI_LoadingGuide_Patch:click_prevBtn()
	self:refresh(true)
	self.m_patchTimer = 0
end


-------------------------------------
-- function click_nextBtn
-------------------------------------
function UI_LoadingGuide_Patch:click_nextBtn()
	self:refresh()
	self.m_patchTimer = 0
end

--@CHECK
UI:checkCompileError(UI_LoadingGuide_Patch)