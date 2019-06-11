local PARENT = UI

-------------------------------------
-- class UI_SelectStartingDragon
-------------------------------------
UI_SelectStartingDragon = class(PARENT,{
		m_makeAccountFunc = 'function',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_SelectStartingDragon:init(make_account_func)
    local vars = self:load('account_create_01.ui')
    UIManager:open(self, UIManager.SCENE)

    SoundMgr:playBGM('bgm_title')
    SoundMgr.m_bStopPreload = true

	-- 이걸 계속 던져서 실행시킨다
	self.m_makeAccountFunc = make_account_func

    -- 씬 전환 효과
    self:sceneFadeInAction()

	self:initUI()
    self:initButton()
	--self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_SelectStartingDragon:initUI()
    local vars = self.vars

	local l_starting_data = self.getStartingData()

	for i, t_data in pairs(l_starting_data) do
		self.setDragonAni(vars, i, t_data['did'])
	end
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_SelectStartingDragon:initButton()
    local vars = self.vars

	local l_starting_data = self:getStartingData()

	for i, _ in pairs(l_starting_data) do
		vars['dragonBtn' .. i]:registerScriptTapHandler(function() self:click_dragonBtn(i) end)
	end
end

-------------------------------------
-- function click_dragonBtn
-- @brief 드래곤 선택
-------------------------------------
function UI_SelectStartingDragon:click_dragonBtn(idx)
    -- @analytics
    Analytics:firstTimeExperience('Select_Start_Dragon')

	local function cb_func()
		self.m_makeAccountFunc()
		self:close()
	end
    UI_SelectStartingDragon_Detail(idx, cb_func)
end



-- UI_SelectStartingDragon_Detail에서도 사용하기 위한 처리

local L_STARTING_DATA = nil
-------------------------------------
-- function setDragonAni
-- @static
-------------------------------------
function UI_SelectStartingDragon.getStartingData()
	if (not L_STARTING_DATA) then
		local l_data = g_startTamerData:getData()

		L_STARTING_DATA = {}
		for i, t_data in pairs(l_data) do
			local t = {
				['did'] = table.getFirst(t_data['dragon_ids']),
				['tid'] = t_data['tamer_id'],
				['user_type'] = t_data['user_type']
			}
			table.insert(L_STARTING_DATA, t)
		end
	end

	return L_STARTING_DATA
end

-------------------------------------
-- function setDragonAni
-- @static
-------------------------------------
function UI_SelectStartingDragon.setDragonAni(vars, idx, did)
    local ani_dragon = AnimatorHelper:makeDragonAnimator_usingDid(did)
    vars['dragonNode' .. idx]:removeAllChildren()
	vars['dragonNode' .. idx]:addChild(ani_dragon.m_node)
end
