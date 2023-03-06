local PARENT = UI

-------------------------------------
-- class UI_DragonSkinSaleFullPopup
-------------------------------------
UI_DragonSkinSaleFullPopup = class(PARENT, {
    m_skinId = 'number',
})

-------------------------------------
-- function init
-------------------------------------
function UI_DragonSkinSaleFullPopup:init(skin_id)
    self.m_skinId = skin_id
    local vars = self:load('event_dragon_skin.ui')

    -- @UI_ACTION
    self:doActionReset()
    self:doAction(nil, false)

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_DragonSkinSaleFullPopup:initUI()
    local vars = self.vars
    --local _, struct_product = g_dragonSkinData:isDragonSkinSalePurchaseAvailable()
    --local item_list = struct_product:getItemList()
    local item_id = 731031 --self.m_skinId --item_list[1].item_id

    local t_dragon_data = {}
    local did = TableDragonSkin:getDragonSkinValue('did', item_id)
    local attribute = TableDragonSkin:getDragonSkinValue('attribute', item_id)
    local struct_dragon_exist = g_dragonsData:getBestDragonByDid(did)

    t_dragon_data['did'] = did
    t_dragon_data['evolution'] = 3 --struct_dragon_exist and struct_dragon_exist['evolution'] or 3
    t_dragon_data['grade'] = struct_dragon_exist and struct_dragon_exist['grade'] or 1
    t_dragon_data['dragon_skin'] = item_id

    local struct_dragon = StructDragonObject(t_dragon_data)

    do -- 스파인
	    local animator = AnimatorHelper:makeDragonAnimatorByTransform(struct_dragon)
	    vars['dragonSpineNode']:addChild(animator.m_node)
    end

    do -- 이름
        local dragon_name = TableDragonSkin:getDragonSkinValue('t_desc', item_id)
        vars['titleLabel']:setString(Str(dragon_name))
    end

    do -- 배경
        local res_file = string.format('res/ui/event/bg_dragon_skin_%s.png', attribute)
        local animator = MakeAnimator(res_file)
        vars['bgNode']:removeAllChildren()
        vars['bgNode']:addChild(animator.m_node)
    end
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_DragonSkinSaleFullPopup:initButton()
    local vars = self.vars
    --vars['rewardBtn']:registerScriptTapHandler(function() self:click_rewardBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_DragonSkinSaleFullPopup:refresh()
    local vars = self.vars
end

-------------------------------------
-- function click_rewardBtn
-------------------------------------
function UI_DragonSkinSaleFullPopup:click_rewardBtn()
    local vars = self.vars
end

-------------------------------------
-- function open
-------------------------------------
function UI_DragonSkinSaleFullPopup.open()
    local struct_dragon_skin_map = g_dragonSkinData:getDragonSkinSaleMap()
    for _, struct_dragon_skin in pairs(struct_dragon_skin_map) do
        if struct_dragon_skin:isDragonSkinSale() == true then
            local skin_id = struct_dragon_skin:getSkinID()
            return UI_DragonSkinSaleFullPopup(skin_id)
        end
    end
    return nil
end