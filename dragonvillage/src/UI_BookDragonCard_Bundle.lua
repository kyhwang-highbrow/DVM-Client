local PARENT = class(UI, ITableViewCell:getCloneTable())

-------------------------------------
-- class UI_BookDragonCard_Bundle
-------------------------------------
UI_BookDragonCard_Bundle = class(PARENT,{
    	m_data = '',
        m_owner_ui = '',

        m_lcardUI = 'List-UI',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_BookDragonCard_Bundle:init(data, owner_ui)
    self:load('book_item.ui')
    self.m_data = data
    self.m_owner_ui = owner_ui
    self.m_lcardUI = {}

    self:initUI()
    self:initButton()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_BookDragonCard_Bundle:initUI()
    local vars = self.vars
    local data = self.m_data
    local did = data['did']
    local is_slime = TableSlime:isSlimeID(did)
    local is_cardpack = (data['category'] and data['category'] == 'cardpack') or false -- 토파즈 드래곤인지
    local is_limit = (data['category'] and data['category'] == 'limited') or false -- 한정 드래곤인지
    local is_event = (data['category'] and data['category'] == 'event') or false -- 이벤트 드래곤인지
    local is_myth = (data['rarity'] and data['rarity'] == 'myth') or false -- 신화 드래곤인지

    local is_undering = is_slime and false or (data['underling'] == 1) -- 자코인지
    local table_char = getCharTable(did)
    local t_char = table_char:get(did)

    -- 드래곤 & 슬라임 이름
    local name_label = vars['nameLabel']
    name_label:setString(Str(t_char['t_name']))

    -- 드래곤 & 슬라임 설명
    local desc = ''
    if (is_slime) then
        local type = t_char['material_type']
        if (type == 'exp') then
            desc = '{@LIGHTGREEN}'.. Str('경험치 슬라임')

        elseif (type == 'upgrade') then
            desc = '{@LIGHTGREEN}'.. Str('승급 슬라임')

        elseif (type == 'skill') then
            desc = '{@LIGHTGREEN}'.. Str('스킬 슬라임')
        end
    
    elseif (is_cardpack) then
        desc = '{@purple}'.. Str('토파즈 드래곤')

    elseif (is_limit) then
        desc = '{@purple}'.. Str('한정 드래곤')

    elseif (is_event) then
        desc = '{@purple}'.. Str('이벤트 드래곤')

    elseif (is_myth) then
        desc = '{@ROSE}'.. Str('신화 드래곤')

    else
        name_label:setPositionY(46)
    end

    local text_color = is_myth and COLOR['ROSE'] or COLOR['DESC']

    vars['dscLabel']:setString(desc)
    vars['mythSprite']:setVisible(is_myth)

    self:refresh()
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_BookDragonCard_Bundle:initButton()
    local vars = self.vars
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_BookDragonCard_Bundle:refresh()
	local vars = self.vars
    local data = self.m_data

	local did = data['did']
	local is_slime = TableSlime:isSlimeID(did)
	local is_undering = is_slime and false or (data['underling'] == 1) -- 자코인지

    -- 해치 정보만 받아온 상태에서 진화도만 수정하여 해츨링, 성룡 데이터 생성해줌
    local l_dragon = {}

    local data_hatch = clone(data)
    table.insert(l_dragon, data_hatch)

    if (not is_undering and not is_slime) then
        local data_hatchling = clone(data)
        data_hatchling['evolution'] = 2
        table.insert(l_dragon, data_hatchling)

        local data_adult = clone(data)
        data_adult['grade'] = math.min(data['grade'] + 1, 6)
        data_adult['evolution'] = 3
        table.insert(l_dragon, data_adult)
    end

    for i, _data in ipairs(l_dragon) do
        local node = vars['dragonNode'..i]
        if (node) then
            node:removeAllChildren()
            local card = UI_BookDragonCard(_data)
            card.root:setSwallowTouch(false)
            UI_Book.cellCreateCB(card, _data, self.m_owner_ui)
            table.insert(self.m_lcardUI, card)
            node:addChild(card.root)
        end
    end
end

--@CHECK
UI:checkCompileError(UI_BookDragonCard_Bundle)
