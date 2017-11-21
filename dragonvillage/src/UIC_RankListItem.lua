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

    local struct_clan = struct_user_info:getStructClan()    
    if (not struct_clan) then
        vars['clanLabel']:setVisible(false)
        return
    end

    -- 클랜 이름
    local clan_name = struct_clan:getClanName()
    vars['clanLabel']:setString(clan_name)

    -- 클랜 마크
    local mark_icon = struct_clan:makeClanMarkIcon()
    vars['markNode']:addChild(mark_icon)
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