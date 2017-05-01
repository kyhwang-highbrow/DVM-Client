local PARENT = class(UI, ITableViewCell:getCloneTable())

-------------------------------------
-- class UI_RecommendedDragonInfoListItem_Party
-------------------------------------
UI_RecommendedDragonInfoListItem_Party = class(PARENT,{
		m_lPartyInfoList = '',
		m_rank = 'num'
    })

-------------------------------------
-- function init
-------------------------------------
function UI_RecommendedDragonInfoListItem_Party:init(t_data)
    self:load('dragon_ranking_party_item.ui')
	
	self:makePartyData(t_data)

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_RecommendedDragonInfoListItem_Party:initUI()
    local vars = self.vars

	-- 랭킹
	vars['rankingLabel']:setString(self.m_rank)

	-- 드래곤 아이콘들
	for i, t_dragon_info in pairs(self.m_lPartyInfoList) do
		local dragon_icon = UI_DragonCard(t_dragon_info)
		vars['dragonNode' .. i]:addChild(dragon_icon.root)
		dragon_icon.root:setSwallowTouch(false)
	end
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_RecommendedDragonInfoListItem_Party:initButton()
    local vars = self.vars
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_RecommendedDragonInfoListItem_Party:refresh()
end

-------------------------------------
-- function makePartyData
-------------------------------------
function UI_RecommendedDragonInfoListItem_Party:makePartyData(t_data)
	do
		self.m_lPartyInfoList = {}
		local l_temp = seperate(t_data['data'], ',')
		for i, v in pairs(l_temp) do
			if (string.find(v, ';')) then
				local t_ret = {}
				local list = seperate(v, ';')
				t_ret['did'] = tonumber(list[1])
				t_ret['grade'] = list[2]
				t_ret['evolution'] = list[3]

				table.insert(self.m_lPartyInfoList, t_ret)
			end
		end
	end

	do
		self.m_rank = t_data['rank']
	end
end

--@CHECK
UI:checkCompileError(UI_RecommendedDragonInfoListItem_Party)
