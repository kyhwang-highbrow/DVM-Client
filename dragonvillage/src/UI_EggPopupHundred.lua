local PARENT = UI

-------------------------------------
-- class UI_EggPopupHundred
-------------------------------------
UI_EggPopupHundred = class(PARENT,{
		m_tData = 'table',
		m_cbFunc = 'function',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_EggPopupHundred:init(t_data, cb_func)
	self.m_tData = t_data
	self.m_cbFunc = cb_func

    local vars = self:load('popup_incubate_02.ui')
    UIManager:open(self, UIManager.POPUP)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_EggPopupHundred')

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_EggPopupHundred:initUI()
	local vars = self.vars

	local t_data = self.m_tData
	local egg_id = tonumber(t_data['egg_id'])
	local table_item = TableItem()

	-- 이름
    local name = table_item:getItemName(egg_id)
	vars['eggNameLabel']:setString(name)

	-- 알 아이콘
	local _res = table_item:getValue(egg_id, 'full_type')
    local egg_res = string.format('res/item/egg/%s_10/%s_10.vrp', _res, _res)
    local egg_animator = nil
    
    local bundle_img = nil
    -- 10개 묶음 이미지가 없다면 1개짜리 이미지로
    -- x10 라벨 붙여줌
    if (not LuaBridge:isFileExist(egg_res)) then
        egg_res = string.format('res/item/egg/%s/%s.vrp', _res, _res)
        bundle_img = UI_HatcheryIncubateTab.makeBundleLabelImage()
    end

    local egg_ani = MakeAnimator(egg_res)
	egg_ani:changeAni('egg', true)
	vars['eggNode']:addChild(egg_ani.m_node)

    if (bundle_img) then
        egg_ani.m_node:addChild(bundle_img)
    end
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_EggPopupHundred:initButton()
	local vars = self.vars

    vars['okBtn1']:registerScriptTapHandler(function() self:click_okBtn(1) end)
    vars['okBtn2']:registerScriptTapHandler(function() self:click_okBtn(10) end)
    vars['okBtn3']:registerScriptTapHandler(function() self:click_okBtn(100) end)
    vars['closeBtn']:registerScriptTapHandler(function() self:close() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_EggPopupHundred:refresh()
	local vars = self.vars

end

-------------------------------------
-- function click_okBtn
-------------------------------------
function UI_EggPopupHundred:click_okBtn(count)
	self.m_cbFunc(count)
	self:close()
end

--@CHECK
UI:checkCompileError(UI_EggPopupHundred)
