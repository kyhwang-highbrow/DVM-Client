local MAX_TYPE_CNT = 5

-------------------------------------
-- function openPurchasePointBgByType
-------------------------------------
function openPurchasePointBgByType(bg_type, item_id, item_count, version)
    local ui_bg = UI_PurchasePointBg(item_id, version)

    -- 타입별로 세팅
    if (bg_type == 'dragon_ticket') then
        ui_bg:setDragonTicket()
    elseif (bg_type == 'dragon') then
        ui_bg:setDragon()
    elseif (bg_type == 'reinforce') then
        ui_bg:setReinforce(item_count)
    elseif(bg_type == 'skill_slime') then
        ui_bg:setSkillSlime(item_count)
    elseif(bg_type == 'item') then
        ui_bg:setItem(item_count)
    end

    return  ui_bg
end




local PARENT = UI

-------------------------------------
-- class UI_PurchasePointBg
-------------------------------------
UI_PurchasePointBg = class(PARENT,{
        m_item_id = 'number',
        m_version = 'number',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_PurchasePointBg:init(item_id, version)
    self:load('event_purchase_point_item_new_02.ui')
    self.m_item_id = item_id
    self.m_version = version

    self:doActionReset()
    self:doAction(nil, false)

    -- 타입별 노드 초기화
    for i = 1, MAX_TYPE_CNT do
        if (self.vars['productNode'..i]) then
            self.vars['productNode'..i]:setVisible(false)
        end
    end

    self:setDescLabel()
end


function UI_PurchasePointBg:setDragonTicket()
    if (not self.m_item_id) then
        return
    end

    self:initUI_dragonTicket()
    self:initButton_dragonTicket()
end

function UI_PurchasePointBg:setDragon()
    if (not self.m_item_id) then
        return
    end

    self:initUI_dragon()
    self:initButton_dragon()
end

function UI_PurchasePointBg:setReinforce(item_count)
    if (not self.m_item_id) then
        return
    end

    self:initUI_reinforce(item_count)
end

function UI_PurchasePointBg:setSkillSlime(item_count)
    if (not self.m_item_id) then
        return
    end

    self:initUI_skillSlime(item_count)
end

function UI_PurchasePointBg:setItem(item_count)
    if (not self.m_item_id) then
        return
    end

    self:initUI_Item(item_count)
end





-------------------------------------
-- function initUI_dragonTicket
-- @breif 누적결제 최종 상품이 [드래곤 뽑기권]일 경우 세팅
-------------------------------------
function UI_PurchasePointBg:initUI_dragonTicket()
    local vars = self.vars
    local item_id = self.m_item_id

    vars['productNode1']:setVisible(true)
    self:setLimit(1) -- productNode 1의 1

    local ui_card = UI_ItemCard(item_id, 0)
    ui_card.root:setScale(0.66)
    vars['itemNode']:addChild(ui_card.root)

    local item_name = TableItem:getItemName(item_id)
    vars['itemLabel']:setString(item_name)
    
    -- 드래곤 뽑기권에서 나올 드래곤들 출력
    local dragon_list_str = TablePickDragon:getCustomList(item_id)
    local dragon_list = plSplit(dragon_list_str, ',')

    for i, dragon_id in ipairs(dragon_list) do
        local dragon_animator = UIC_DragonAnimator()
        dragon_animator:setDragonAnimator(tonumber(dragon_id), 3)
        dragon_animator:setTalkEnable(false)
        
        -- 2,3 번째 드래곤은 바라보는 방향이 다름        
        if (i >= 2) then
            dragon_animator.m_animator:setFlip(true)
        end

        if (vars['dragonNode'.. i]) then
            vars['dragonNode'.. i]:addChild(dragon_animator.m_node)
        end
    end

    local res = 'res/bg/ui/dragon_evolution_result/dragon_evolution_result.vrp'
    animator = MakeAnimator(res)    
    vars['bgNode']:addChild(animator.m_node)

end

-------------------------------------
-- function initButton_dragonTicket
-------------------------------------
function UI_PurchasePointBg:initButton_dragonTicket()
   local vars = self.vars
   local item_id = self.m_item_id
   
   vars['dragonInfoBtn']:registerScriptTapHandler(function() UI_SummonDrawInfo(item_id, false) end)
end





-------------------------------------
-- function initUI_dragon
-- @breif 누적결제 최종 상품이 [드래곤]일 경우 세팅
-------------------------------------
function UI_PurchasePointBg:initUI_dragon()
    local vars = self.vars
    local item_id = self.m_item_id
    local did = TableItem:getDidByItemId(item_id)
    
    vars['productNode2']:setVisible(true)
    self:setLimit(2) -- productNode 2의 2

    local table_dragon = TableDragon()

    -- 이름
    local dragon_name = table_dragon:getDragonName(did)
    vars['dragonNameLabel']:setString(Str(dragon_name))
    
    -- 속성 ex) dark
    local dragon_attr = table_dragon:getDragonAttr(did)
    local attr_icon = IconHelper:getAttributeIcon(dragon_attr)
    vars['attrNode']:addChild(attr_icon)
    vars['attrLabel']:setString(dragonAttributeName(dragon_attr))

    -- 역할 ex) healer
    local role_type = table_dragon:getDragonRole(did)
    local role_icon = IconHelper:getRoleIcon(role_type)
    vars['typeNode']:addChild(role_icon)
    vars['typeLabel']:setString(dragonRoleTypeName(role_type))

    -- 희귀도 ex) legend
    local rarity_icon = IconHelper:getRarityIcon('legend')
    vars['rarityNode']:addChild(rarity_icon)
    vars['rarityLabel']:setString(dragonRarityName('legend'))

    -- 진화도 by 별
    local res = string.format('res/ui/icons/star/star_%s_%02d%02d.png', 'yellow', 2, 5)
    local sprite = IconHelper:getIcon(res)
	vars['starNode']:addChild(sprite)

    local dragon_animator = UIC_DragonAnimator()
    dragon_animator:setDragonAnimator(did, 3)
    dragon_animator:setTalkEnable(false)
    vars['dragonNode4']:addChild(dragon_animator.m_node)

    
    -- 최종 상품이 드래곤일 경우 visual  세팅
    local animator
    local did = TableItem:getDidByItemId(item_id)
    local dragon_attr = TableDragon:getDragonAttr(did)
    animator = ResHelper:getUIDragonBG(dragon_attr, 'idle')
    vars['bgNode']:addChild(animator.m_node)


    local category_str = table_dragon:getDragonCartegory(did)
    if (category_str == 'cardpack') then
        category_str = Str('토파즈 드래곤')
    elseif (category_str == 'cardpack') then
        category_str = Str('한정 드래곤')
    else
        category_str = Str('')
    end
    vars['dscLabel']:setString(category_str)
end

-------------------------------------
-- function initButton_dragon
-------------------------------------
function UI_PurchasePointBg:initButton_dragon()
   local vars = self.vars
   local item_id = self.m_item_id
   
   local did = TableItem:getDidByItemId(item_id)
   vars['infoBtn']:registerScriptTapHandler(function() UI_BookDetailPopup.openWithFrame(did, nil, 3, 0.8, true) end)
end






-------------------------------------
-- function initUI_reinforce
-- @breif 누적결제 최종 상품이 [강화 포인트]일 경우 세팅
-------------------------------------
function UI_PurchasePointBg:initUI_reinforce(item_count)
    local vars = self.vars
    local item_id = self.m_item_id
    
    if (not item_count) then
        return
    end

    vars['productNode3']:setVisible(true)
    self:setLimit(3) -- productNode 3의 3

    local item_name = TableItem:getItemName(item_id)
    vars['itemLabel2']:setString(string.format('%s X %d', item_name, item_count))

     -- 배경 visual  세팅
    local animator = MakeAnimator('res/bg/map_jewel/map_jewel.vrp')
    vars['bgNode']:addChild(animator.m_node)
end

-------------------------------------
-- function initUI_skillSlime
-- @breif 누적결제 최종 상품이 [스킬 슬라임]일 경우 세팅
-------------------------------------
function UI_PurchasePointBg:initUI_skillSlime(item_count)
    local vars = self.vars
    local item_id = self.m_item_id

    -- 강화포인트와 같은 MenuNode 사용
    vars['productNode3']:setVisible(true)
    self:setLimit(3) -- productNode 3의 3

    local animator = MakeAnimator('res/character/monster/skill_slime_03/skill_slime_03.json') -- json...
    vars['slimeNode']:addChild(animator.m_node)
    
    local item_name = TableItem:getItemName(item_id)
    vars['itemLabel2']:setString(string.format('%s X %d', item_name, item_count))

    -- 배경 visual  세팅
    local animator = MakeAnimator('res/bg/map_jewel/map_jewel.vrp')
    vars['bgNode']:addChild(animator.m_node)

    vars['effect3']:setIgnoreLowEndMode(true) -- 저사양 모드 무시
end

-------------------------------------
-- function initUI_Item
-- @breif 누적결제 최종 상품이 [아이템]일 경우 세팅 (ex) 신화의 알.. 등등 여기서 하드코딩
-------------------------------------
function UI_PurchasePointBg:initUI_Item(item_count)
    local vars = self.vars
    local item_id = self.m_item_id

    vars['productNode4']:setVisible(true)
    self:setLimit(4) -- productNode 4의 4
    
    -- 갯수 라벨 세팅
    local item_name = TableItem:getItemName(item_id)
    vars['itemLabel3']:setString(string.format('%s X %d', item_name, item_count))

    -- 아이템 Visual 세팅
    local animator = self:getItemVisual(item_id)
    if (animator) then
        vars['itemNode2']:addChild(animator.m_node)
    end

    -- 배경 visual  세팅
    local animator = MakeAnimator('res/bg/ui/dragon_bg_earth/dragon_bg_earth.vrp')
    vars['bgNode']:addChild(animator.m_node)

    vars['effect4']:setIgnoreLowEndMode(true) -- 저사양 모드 무시
end

-------------------------------------
-- function getItemVisual
-- @breif ItemVisual 세팅
-------------------------------------
function UI_PurchasePointBg:getItemVisual(item_id)
    local animator
    local item_full_type = TableItem:getItemFullType(tonumber(item_id))

    -- 아이템이 알 종류일 경우 (파일 이름에 규칙이 있다고 가정)
    if (string.match(item_full_type, 'egg')) then
        animator = MakeAnimator(string.format('res/item/egg/%s/%s.vrp', item_full_type, item_full_type)) -- ex) res/item/egg/egg_super_myth/egg_super_myth.vrp
        if (animator) then
            animator:changeAni('egg_move', true)
        end
    else
        animator = nil
    end

    return animator
end

-------------------------------------
-- function setDescLabel
-- @breif 
-------------------------------------
function UI_PurchasePointBg:setDescLabel(item_count)
    local version = self.m_version
    local vars = self.vars

    -- 설명 값 and 설명라벨 있다면 설명 출력
    local last_reward_desc = g_purchasePointData:getLastRewardDesc(version)
    if (last_reward_desc ~= '') then
        if (vars['dcsLabel'] and vars['dscSprite']) then
            vars['dscSprite']:setVisible(true)
            vars['dcsLabel']:setVisible(true)
            vars['dcsLabel']:setString(last_reward_desc)
            return
        end
    end

    vars['dscSprite']:setVisible(false)
    vars['dcsLabel']:setVisible(false)

    -- 설명이 없다면 어색하게 공간 떨어지지 않도록 위치 조정 (스킬 슬라임, 아이템 타입만)
    vars['productNode3']:setPositionY(-42)
    vars['productNode4']:setPositionY(-42)     
end

-------------------------------------
-- function setLimit
-------------------------------------
function UI_PurchasePointBg:setLimit(idx)
    if (self.vars['limitNode'..idx]) then
        local remain_sec = g_purchasePointData:getPurchasePointEventRemainTime(self.m_version)
        local day = math.floor(remain_sec / 86400)
        if (day < 2) then
            self.vars['limitNode'..idx]:setVisible(true)
            self.vars['limitNode'..idx]:runAction(cca.buttonShakeAction(3, 1)) 
        else
            self.vars['limitNode'..idx]:setVisible(false)
        end
    end
end

