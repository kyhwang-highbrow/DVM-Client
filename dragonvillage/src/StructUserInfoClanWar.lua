local PARENT = StructUserInfoArena


-------------------------------------
-- class StructUserInfoClanWar
-- @instance
-------------------------------------
StructUserInfoClanWar = class(PARENT, {
	m_structMatchItem = 'StructClanWarMatchItem',
})

-------------------------------------
-- function setClanWarStructMatchItem
-------------------------------------
function StructUserInfoClanWar:setClanWarStructMatchItem(struct_match_item)
	self.m_structMatchItem = struct_match_item
end

-------------------------------------
-- function setClanWarStructMatchItem
-------------------------------------
function StructUserInfoClanWar:getClanWarStructMatchItem()
	return self.m_structMatchItem
end
