local PARENT = UI

-------------------------------------
-- class UI_SimpleDragonInfoPopup
-------------------------------------
UI_SimpleDragonInfoPopup = class(PARENT, {
        m_tDragonData = 'table',
        m_dragonObjectID = 'string',
        m_tableDragon = 'TableDragon',
        m_idx = 'number',
        m_dragonInfoBoardUI = 'UI_DragonInfoBoard',
        m_dragonAnimator = 'UIC_DragonAnimator',

        m_refreshCb = 'function',
		m_isSelected = 'boolean',
     })

-------------------------------------
-- function init
-------------------------------------
function UI_SimpleDragonInfoPopup:init(t_dragon_data)
    self.m_tableDragon = TableDragon()

    self.m_tDragonData = t_dragon_data
    self.m_dragonObjectID = t_dragon_data['id']

    self.m_uiName = 'UI_SimpleDragonInfoPopup'

    local vars = self:load('dragon_info_mini.ui')
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

    -- 드래곤 정보 보드 생성
    local is_simple_mode = true
    self.m_dragonInfoBoardUI = UI_DragonInfoBoard(is_simple_mode)
    self.vars['rightNode']:addChild(self.m_dragonInfoBoardUI.root)

    -- 드래곤 실리소스
    if vars['dragonNode'] then
        self.m_dragonAnimator = UIC_DragonAnimator()
        vars['dragonNode']:addChild(self.m_dragonAnimator.m_node)
    end
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

    vars['lockBtn']:registerScriptTapHandler(function() self:click_lock() end)
    vars['dragonManageBtn']:registerScriptTapHandler(function() self:click_manage() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_SimpleDragonInfoPopup:refresh()
    local vars = self.vars

    local t_dragon_data = self:getDragonData()

    self.m_dragonInfoBoardUI:refresh(t_dragon_data)

    local did = t_dragon_data['did']

    local table_dragon = TableDragon()
    local t_dragon = table_dragon:get(did)

    -- 코드 중복을 막기 위해 UI_DragonManageInfo클래스의 기능을 활용
    UI_DragonManageInfo.refresh_dragonBasicInfo(self, t_dragon_data, t_dragon)
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

-------------------------------------
-- function showClickRuneInfoPopup
-------------------------------------
function UI_SimpleDragonInfoPopup:showClickRuneInfoPopup(show_popup)
    self.m_dragonInfoBoardUI:showClickRuneInfoPopup(show_popup)
end

-------------------------------------
-- function showIllusionLabel
-------------------------------------
function UI_SimpleDragonInfoPopup:showIllusionLabel()
    self.vars['eventDungeonSprite']:setVisible(true)
end

-------------------------------------
-- function setLockPossible
-------------------------------------
function UI_SimpleDragonInfoPopup:setLockPossible(is_possible, is_selected)
    self.m_isSelected = is_selected
	
	-- 락 기능 제공하지 않는다면 버튼은 아예 보이지 않음
    if (not is_possible) then
        self.vars['lockBtn']:setVisible(false)
        return
    end

    local t_dragon_data = self:getDragonData()
    if (not t_dragon_data) then
        return
    end

    self.vars['lockBtn']:setVisible(true)
    self.vars['lockSprite']:setVisible(t_dragon_data:getLock())
end

-------------------------------------
-- function setManagePossible
-------------------------------------
function UI_SimpleDragonInfoPopup:setManagePossible(is_possible)
	-- 관리 기능 제공하지 않는다면 버튼은 아예 보이지 않음
    if (not is_possible) then
        self.vars['dragonManageBtn']:setVisible(false)
        return
    end

    local t_dragon_data = self:getDragonData()
    if (not t_dragon_data) then
        return
    end

    self.vars['dragonManageBtn']:setVisible(true)
end


-------------------------------------
-- function setRefreshFunc
-------------------------------------
function UI_SimpleDragonInfoPopup:setRefreshFunc(refresh_cb)
    self.m_refreshCb = refresh_cb
end

-------------------------------------
-- function click_lock
-------------------------------------
function UI_SimpleDragonInfoPopup:click_lock()
    local struct_dragon_data
	local doids = ''
	local soids = ''
	
		
	-- 재료로 사용중이라면 눌리지 않음
	if (self.m_isSelected) then
		UIManager:toastNotificationRed(Str('선택된 재료입니다.'))
		return 
	end

    local t_dragon_data = self:getDragonData()
    local is_slim = (t_dragon_data.m_objectType == 'slime')
    
    if (is_slim) then
		soids = self.m_dragonObjectID
		struct_dragon_data = g_slimesData:getSlimeObject(self.m_dragonObjectID)
	else
		doids = self.m_dragonObjectID
		struct_dragon_data = g_dragonsData:getDragonDataFromUid(self.m_dragonObjectID)
	end

	local lock = (not struct_dragon_data:getLock())
	--[[
		-- 드래곤 성장일지 제거
		local start_dragon_doid = g_userData:get('start_dragon')
	    if (start_dragon_doid) and (not g_dragonDiaryData:isClearAll()) then
	        
	        if (doids == start_dragon_doid) then
	            local msg = Str('육성 퀘스트가 진행중인 드래곤입니다.\n퀘스트를 모두 수행해야 잠금 해제가 가능합니다.')
	            MakeSimplePopup(POPUP_TYPE.OK, msg)
	            return
	        end
	    end
	--]]

    -- 슬라임이 아닐 경우에만 드래곤 성장일지 잠금 체크
    if (not is_slim) then
        -- 드래곤 성장일지 (퀘스트 진행중이면 잠금 풀 수 없음)
        if (g_dragonDiaryData:isSelectedDragonLock(doids)) then      
            local msg = ''
	    	if (not g_dragonDiaryData:isEnable()) then
	    		msg = Str('함께 모험을 시작한 드래곤입니다.\n5성 달성 시 잠금 해제가 가능합니다')
	    	else
	    		msg = Str('육성 퀘스트가 진행중인 드래곤입니다.\n퀘스트를 모두 수행해야 잠금 해제가 가능합니다.')
	    	end
	    	
	    	MakeSimplePopup(POPUP_TYPE.OK, msg)
	    	return
        end
    end

	local function cb_func(ret)
		-- 메인 잠금 표시 해제
		self.vars['lockSprite']:setVisible(lock)
		
		-- 잠금 안내 팝업
		local msg = lock and Str('잠금되었습니다.') or Str('잠금이 해제되었습니다.')
		UIManager:toastNotificationGreen(msg)

        -- 드래곤 정보 갱신
        if (ret['modified_dragons']) then
			for _, t_dragon in ipairs(ret['modified_dragons']) do
				g_dragonsData:applyDragonData(t_dragon)
			end
		end
		
		if (ret['modified_slimes']) then
			for _, t_slime in ipairs(ret['modified_slimes']) do
				g_slimesData:applySlimeData(t_slime)
			end
		end

		-- 개별 드래곤 갱신
        if (self.m_refreshCb) then
		    self:m_refreshCb()
	    end
    end

	g_dragonsData:request_dragonLock(doids, soids, lock, cb_func)
end

-------------------------------------
-- function click_manage
-------------------------------------
function UI_SimpleDragonInfoPopup:click_manage()
    local struct_dragon_data
	
    local t_dragon_data = self:getDragonData()
    local is_slim = (t_dragon_data.m_objectType == 'slime')
    local doid = self.m_dragonObjectID

    if (is_slim) then
		struct_dragon_data = g_slimesData:getSlimeObject(self.m_dragonObjectID)
	else
		struct_dragon_data = g_dragonsData:getDragonDataFromUid(self.m_dragonObjectID)
	end

	local ui = UI_DragonManageInfo(doid)
    
    local function close_cb()
        if (self.m_refreshCb) then
            self.m_refreshCb()
        end
    end

    ui:setCloseCB(function() close_cb() end)

    self:close()
end
