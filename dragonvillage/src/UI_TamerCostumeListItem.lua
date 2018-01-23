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

    local is_open = costume_data:isOpen()
    local badge_node = vars['badgeNode']
    badge_node:removeAllChildren()

    -- 배지 추가 (할인, 기간한정)
    if (not is_open) then
        local is_sale = costume_data:isSale()
        local is_limit = costume_data:isLimit()
        local is_end = costume_data:isEnd()
        local img
        -- 할인
        if (is_sale) then            
            img = cc.Sprite:create('res/' .. Translate:getTranslatedPath('ui/typo/ko/badge_discount.png'))

        -- 기간한정
        elseif (is_limit) then
            img = cc.Sprite:create('res/' .. Translate:getTranslatedPath('ui/typo/ko/badge_period.png'))

        -- 판매종료
        elseif (is_end) then
            img = cc.Sprite:create('res/' .. Translate:getTranslatedPath('ui/typo/ko/badge_finish.png'))
        end

        if (img) then
            img:setDockPoint(cc.p(0.5, 0.5))
            img:setAnchorPoint(cc.p(0.5, 0.5))
            badge_node:addChild(img)
        end
    end

    -- 테이머 잠금이 아니라 오픈 여부로 변경
    vars['lockSprite']:setVisible(not is_open)
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