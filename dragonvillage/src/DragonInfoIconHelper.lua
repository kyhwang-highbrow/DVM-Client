DragonInfoIconHelper = {}

-------------------------------------
-- function makeIconBtn
-------------------------------------
function DragonInfoIconHelper.makeAttrIconBtn(attr, t_info)
	local click_func = function()
		UI_HelpDragonGuidePopup('attr', attr, t_info) -- param : focus_tab
	end

	attr = attributeNumToStr(attr)
    local icon_size = 46

    if (attribute == 'none') then
        attr = 'all'
    end
    
    local res_name = string.format('res/ui/icons/attr/attr_%s_02.png', attr)
    local attr_button = DragonInfoIconHelper.makeImageBtn(res_name, icon_size, click_func)
    
    return attr_button
end

-------------------------------------
-- function makeRoleIconBtn
-------------------------------------
function DragonInfoIconHelper.makeRoleIconBtn(role, t_info)
	local click_func = function()
		UI_HelpDragonGuidePopup('role', role, t_info) -- param : focus_tab
	end
	
	local icon_size = 78
    local res_name = string.format('res/ui/icons/book/role_%s.png', role)
    local role_button = DragonInfoIconHelper.makeImageBtn(res_name, icon_size, click_func)
    
    return role_button
end

-------------------------------------
-- function makeRarityIconBtn
-------------------------------------
function DragonInfoIconHelper.makeRarityIconBtn(rarity, t_info)
	local click_func = function()
		UI_HelpDragonGuidePopup('rarity', rarity, t_info) -- param : type, focus_value, table = {'rarity' = 'legend', 'role' = 'defend', 'attr' = 'fire'}
	end

    local icon_size = 50
    local res_name = string.format('res/ui/icons/rarity/gem_%s.png', rarity)
    local rare_button = DragonInfoIconHelper.makeImageBtn(res_name, icon_size, click_func)
    
    return rare_button
end

-------------------------------------
-- function makeImageBtn
-- @brief 속성/역할/희귀도 아이콘을 sprite로 사용하다가 버튼으로 변경하려고 만든 함수
-- @brief 파일이름을 받으면 그 이미지를 사용한 버튼을 만들어 반환
-------------------------------------
function DragonInfoIconHelper.makeImageBtn(file_name, size, func_click)
    local menu = cc.Menu:create()

    local btn = cc.MenuItemImage:create(file_name, nil, nil, 1)
    btn:setContentSize(size, size)
    btn:setDockPoint(cc.p(0.0, 0.0))
    btn:setAnchorPoint(cc.p(0.0, 0.0))
    btn:setNormalSize(size, size)

    local uic_btn = UIC_Button(btn)
    uic_btn:registerScriptTapHandler(func_click)

    menu:addChild(btn)

    return menu
end

-------------------------------------
-- function makeInfoParamTable
-------------------------------------
function DragonInfoIconHelper.makeInfoParamTable(attr, role, rarity)
    local t_info = {}
    t_info['attr'] = attr
    t_info['role'] = role
    t_info['rarity'] = rarity

    return t_info
end


-------------------------------------
-- function setDragonAttrBtn
-- @brief
-------------------------------------
function DragonInfoIconHelper.setDragonAttrBtn(attr, node, label, t_info)
    if (not attr) then
        return
    end

    if (not node) then
        return
    end

    local icon = IconHelper:getAttributeIconButton(attr, t_info)
    if (icon) then
        node:addChild(icon)
    end
        
    if (label) then
        label:setString(dragonAttributeName(attr))
    end

end

-------------------------------------
-- function setDragonRoleBtn
-- @brief
-------------------------------------
function DragonInfoIconHelper.setDragonRoleBtn(role, node, label, t_info)
    if (not role) then
        return
    end

    if (not node) then
        return
    end
        
    local icon = IconHelper:getRoleIconButton(role, t_info)
    if (icon) then
        node:addChild(icon)
    end
        
    if (label) then
        label:setString(dragonRoleTypeName(role))
    end

end

-------------------------------------
-- function setDragonRarityBtn
-- @brief
-------------------------------------
function DragonInfoIconHelper.setDragonRarityBtn(rarity, node, label, t_info)
    if (not rarity) then
        return
    end

    if (not node) then
        return
    end

    local rarity_icon = IconHelper:getRarityIconButton(rarity, t_info)     
    if (rarity_icon) then
        node:addChild(rarity_icon)
    end
        
    if (label) then
        label:setString(dragonRarityName(rarity))
    end
end
