local PARENT = class(UI, ITableViewCell:getCloneTable())

-------------------------------------
-- class UI_TamerCostumeListItem
-------------------------------------
UI_TamerCostumeListItem = class(PARENT, {
        m_costumeData = 'StructTamerCostume',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_TamerCostumeListItem:init(costume_data)
    local vars = self:load('tamer_costume_item.ui')
    self.m_costumeData = costume_data

    self:initUI()
    self:initButton()
    self:refresh()

    self.m_cellSize = cc.size(200, 250)
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_TamerCostumeListItem:initUI()
    local vars = self.vars
    local costume_data = self.m_costumeData

    -- 이름
    vars['costumeTitleLabel']:setString(costume_data:getName())

    -- 이미지
    local img = costume_data:getTamerSDIcon()
    if (img) then
        vars['tamerNode']:addChild(img)
    end

    -- 할인
    local is_sale = costume_data:isSale()
    vars['saleSprite']:setVisible(is_sale)

    -- 테이머 열려있지 않으면 코스튬도 잠금
    local is_lock = costume_data:isTamerLock()
    vars['lockSprite']:setVisible(is_lock)
    

    -- 생성시에는 사용중인 코스튬 선택처리
    local is_used = costume_data:isUsed()
    vars['selectSprite']:setVisible(is_used)
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_TamerCostumeListItem:initButton()
    local vars = self.vars
end

-------------------------------------
-- function refresh
function UI_TamerCostumeListItem:refresh()
    local vars = self.vars
    local costume_data = self.m_costumeData

    local is_used = costume_data:isUsed()
    vars['useSprite']:setVisible(is_used)
end

-------------------------------------
-- function setClickHandler
-------------------------------------
function UI_TamerCostumeListItem:setClickHandler(click_func)
    local vars = self.vars

    vars['costumeBtn']:registerScriptTapHandler(function()
        click_func(self.m_costumeData)
    end)
end

-------------------------------------
-- function setSelected
-------------------------------------
function UI_TamerCostumeListItem:setSelected(sel_id)
    local vars = self.vars
    local costume_data = self.m_costumeData
    local cid = costume_data:getCid()

    vars['selectSprite']:setVisible(cid == sel_id)
end