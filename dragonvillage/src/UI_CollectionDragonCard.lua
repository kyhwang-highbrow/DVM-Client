local PARENT = class(UI, ITableViewCell:getCloneTable())

-------------------------------------
-- class UI_CollectionDragonCard
-------------------------------------
UI_CollectionDragonCard = class(PARENT, {
        m_tItemData = 'table',
        m_dragonCardList = 'UI_DragonCard',
        m_cbDragonCardClick = '',
    })

-------------------------------------
-- function getUIFile
-------------------------------------
function UI_CollectionDragonCard:getUIFile()
    return 'collection_dragon_item_new.ui'
end

-------------------------------------
-- function getUISize
-------------------------------------
function UI_CollectionDragonCard:getUISize()
    local ui_file = self:getUIFile()
    local ui = UI()
    ui:load(ui_file)
    local size = ui.root:getContentSize()
    return size['width'], size['height']
end

-------------------------------------
-- function init
-------------------------------------
function UI_CollectionDragonCard:init(t_item_data)
    self.m_tItemData = t_item_data
    local vars = self:load(self:getUIFile())

    self:initUI(t_item_data)
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_CollectionDragonCard:initUI(t_item_data)
    local vars = self.vars

    -- 드래곤 이름
    local name = Str(t_item_data['t_name'])
    vars['nameLabel']:setString(name)

    -- 드래곤 아이콘 (해치, 해츨링, 성룡)
    local did = t_item_data['did']
    self.m_dragonCardList = {}
    for i=1, MAX_DRAGON_EVOLUTION do

        local evolution = i
        local t_data = {['evolution'] = evolution}
        local card = MakeSimpleDragonCard(did, t_data)
        card.root:setSwallowTouch(false)
        card.vars['starIcon']:setVisible(false)
        vars['dragonNode' .. i]:addChild(card.root)

        -- 버튼 터치
        card.vars['clickBtn']:registerScriptTapHandler(function() self.m_cbDragonCardClick(did, evolution) end)

        -- 리스트에 저장
        self.m_dragonCardList[i] = card
    end
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_CollectionDragonCard:initButton()
    local vars = self.vars
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_CollectionDragonCard:refresh()
    local vars = self.vars

    local did = self.m_tItemData['did']

    -- 획득한적이 있는지 없는지 체크
    local exist = g_collectionData:isExist(did)
    for i,v in pairs(self.m_dragonCardList) do
        v:setShadowSpriteVisible(not exist)

        if (not exist) then
            v.vars['shadowSprite']:setOpacity(127)
        end
    end

    do -- 인연포인트
        -- 인연포인트 값 얻어오기
        local req_rpoint = TableDragon():getRelationPoint(did)
        local cur_rpoint = g_collectionData:getRelationPoint(did)
        
        -- 인연포인트 표시
        --local str = Str('{1}/{2}', comma_value(cur_rpoint), comma_value(req_rpoint))
        --vars['relationPointLabel']:setString(str)

        -- 하일라이트
        if (cur_rpoint >= req_rpoint) then
            vars['notiSprite']:setVisible(true)
        else
            vars['notiSprite']:setVisible(false)
        end
    end
end



-------------------------------------
-- function makeDragonCard
-------------------------------------
function UI_CollectionDragonCard:makeDragonCard(did, t_data, scale)
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
-- @param function(did, evolution)
-------------------------------------
function UI_CollectionDragonCard:setDragonCardClick(cb)
    self.m_cbDragonCardClick = cb
end
