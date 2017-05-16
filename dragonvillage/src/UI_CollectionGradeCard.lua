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

    self:initUI(t_item_data)
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_CollectionGradeCard:initUI(t_item_data)
    local vars = self.vars

    -- 드래곤 이름
    local name = Str(t_item_data['t_name'])
    vars['nameLabel']:setString(name)

    
	-- 드래곤 아이콘 (태생 ~ Max 등급)
    self.m_dragonCardList = {}
    local did = t_item_data['did']
	local origin_grade = 1
	local count = MAX_DRAGON_GRADE - origin_grade + 1
	local space = 150
	local start_x = space/2 - (space/2 * count)
	
    for i=1, MAX_DRAGON_GRADE do
        local grade = i
        local t_data = {['grade'] = grade}
		local card = MakeSimpleDragonCard(did, t_data)

		-- card ui 속성
		local pos_x = (space * i) + (start_x - space)
		card.root:setPositionX(pos_x)
        card.root:setSwallowTouch(false)
        card.vars['clickBtn']:registerScriptTapHandler(function() self.m_cbDragonCardClick(did, grade) end)
        
		vars['dragonNode']:addChild(card.root)

        -- 리스트에 저장
        self.m_dragonCardList[i] = card
    end



	for i, card in pairs(self.m_dragonCardList) do
		
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
end

-------------------------------------
-- function makeDragonCard
-------------------------------------
function UI_CollectionGradeCard:makeDragonCard(did, t_data, scale)
    local width = 150 * scale
    local height = 150 * scale
    
    local render = cc.RenderTexture:create(width, height, cc.TEXTURE2_D_PIXEL_FORMAT_RGB_A8888)
    render:setDockPoint(cc.p(0.5, 0.5))
    render:setAnchorPoint(cc.p(0.5, 0.5))

    render:begin()
    
    do
        local card = MakeSimpleDragonCard(did, t_data)
        card.root:setPosition(width/2, height/2)
        card.root:setScale(scale)
        card.root:visit()
    end
    
    render:endToLua()

    return render
end

-------------------------------------
-- function setDragonCardClick
-- @brief
-- @param function(did, grade)
-------------------------------------
function UI_CollectionGradeCard:setDragonCardClick(cb)
    self.m_cbDragonCardClick = cb
end
