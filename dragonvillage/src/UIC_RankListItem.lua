-------------------------------------
-- class IRankListItem
-------------------------------------
IRankListItem = ITableViewCell:getCloneTable()

-------------------------------------
-- function initRankInfo
-------------------------------------
function IRankListItem:initRankInfo(vars, struct_user_info)
    if (not vars) then
        return
    end
	
	-- 클랜 버튼 swallow touch false
	if (vars['clanBtn']) then
		vars['clanBtn'].m_node:getParent():setSwallowTouch(false)
	end

    local struct_clan = struct_user_info:getStructClan()    
    if (not struct_clan) then
        vars['clanLabel']:setVisible(false)
        return
    end

    -- 클랜 이름
	if (vars['clanLabel']) then
		local clan_name = struct_clan:getClanName()
		vars['clanLabel']:setString(clan_name)
	end

    -- 클랜 마크
	if (vars['markNode']) then
		local mark_icon = struct_clan:makeClanMarkIcon()
		vars['markNode']:addChild(mark_icon)
	end
	
	-- 클랜 버튼
	if (vars['clanBtn']) then
		vars['clanBtn']:registerScriptTapHandler(function()
			local clan_object_id = struct_clan:getClanObjectID()
			g_clanData:requestClanInfoDetailPopup(clan_object_id)
		end)
	end
end

-------------------------------------
-- function getCloneTable
-------------------------------------
function IRankListItem:getCloneTable()
	return clone(IRankListItem)
end

-------------------------------------
-- function getCloneClass
-------------------------------------
function IRankListItem:getCloneClass()
	return class(clone(IRankListItem))
end