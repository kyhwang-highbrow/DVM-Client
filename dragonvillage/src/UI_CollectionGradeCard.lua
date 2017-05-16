local PARENT = class(UI, ITableViewCell:getCloneTable())

-------------------------------------
-- class UI_CollectionGradeCard
-------------------------------------
UI_CollectionGradeCard = class(PARENT, {
        m_tItemData = 'table',
        m_dragonCardList = 'UI_DragonCard',
        m_cbDragonCardClick = '',
    })

-------------------------------------
-- function getUIFile
-------------------------------------
function UI_CollectionGradeCard:getUIFile()
    return 'collection_upgrade_item.ui'
end

-------------------------------------
-- function getUISize
-------------------------------------
function UI_CollectionGradeCard:getUISize()
    local ui_file = self:getUIFile()
    local ui = UI()
    ui:load(ui_file)
    local size = ui.root:getContentSize()
    return size['width'], size['height']
end

-------------------------------------
-- function init
-------------------------------------
function UI_CollectionGradeCard:init(t_item_data)
    self.m_tItemData = t_item_data
    local vars = self:load(self:getUIFile())

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_CollectionGradeCard:initUI()
    local vars = self.vars
	local t_item_data = self.m_tItemData

    -- 드래곤 이름
    local name = Str(t_item_data['t_name'])
    vars['nameLabel']:setString(name)

	-- 드래곤 아이콘 (태생 ~ Max 등급)
    self.m_dragonCardList = {}
    local did = t_item_data['did']
	local origin_grade = TableGradeInfo:getOriginGrade(t_item_data['rarity'])
	local count = MAX_DRAGON_GRADE - origin_grade + 1
	local space = 150
	local start_x = space/2 - (space/2 * count)
	
	local pos_idx = 1
    for i = origin_grade, MAX_DRAGON_GRADE do
        local grade = i
        local t_data = {['grade'] = grade}
		local card = MakeSimpleDragonCard(did, t_data)

		-- card ui 속성
		local pos_x = (space * pos_idx) + (start_x - space)
		pos_idx = pos_idx + 1
		card.root:setPositionX(pos_x)
        card.root:setSwallowTouch(false)
        card.vars['clickBtn']:registerScriptTapHandler(function() self.m_cbDragonCardClick(did, grade) end)
        
		vars['dragonNode']:addChild(card.root)

        -- 리스트에 저장
        self.m_dragonCardList[i] = card
    end
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_CollectionGradeCard:initButton()
    local vars = self.vars
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_CollectionGradeCard:refresh()
    local vars = self.vars

    local did = self.m_tItemData['did']
	local collection_struct = g_collectionData:getCollectionData(did)
	local grade_lv_state = collection_struct:getGradeLvState()

	for grade, card in pairs(self.m_dragonCardList) do
		local lv_state = grade_lv_state[grade]
		
		-- 미획득
		if (lv_state == 0) then
			card:setShadowSpriteVisible(true)

		-- 보상 기 수령
		elseif (lv_state == -1) then
			card:setMaxLvSpriteVisible(true)

		-- 보상 수령 가능
		elseif TableGradeInfo:isMaxLevel(grade, nil, lv_state) then
			card:setHighlightSpriteVisible(true)

		end
	end
end

-------------------------------------
-- function setDragonCardClick
-- @brief
-- @param function(did, grade)
-------------------------------------
function UI_CollectionGradeCard:setDragonCardClick(cb)
    self.m_cbDragonCardClick = cb
end
