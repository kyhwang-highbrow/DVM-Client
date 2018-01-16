local PARENT = UI_MonsterCard

-------------------------------------
-- class UI_MonsterCustomCard
-- @brief clikc_handler 등록되지 않은 몬스터 카드, 드래곤 카드처럼 선택하여 쓸 때 사용
-------------------------------------
UI_MonsterCustomCard = class(PARENT,{})

-------------------------------------
-- function init
-------------------------------------
function UI_MonsterCustomCard:init(monster_id, is_boss)
end

-------------------------------------
-- function makeClickBtn
-------------------------------------
function UI_MonsterCustomCard:makeClickBtn(res)
    if (self.m_clickBtnRes == res) then
        return
    end
    self.m_clickBtnRes = res
    local btn = self.vars['clickBtn']

    if (not btn) then
        btn = cc.MenuItemImage:create()
        btn:setDockPoint(CENTER_POINT)
        btn:setAnchorPoint(CENTER_POINT)
        self.vars['clickBtn'] = UIC_Button(btn)
        self.root:addChild(btn)
    end

    btn:setNormalSpriteFrame(cc.SpriteFrameCache:getInstance():getSpriteFrame(res))
        
    return btn
end

-------------------------------------
-- function setHighlightSpriteVisible
-- @brief highlight 표시
-- @external call
-------------------------------------
function UI_MonsterCustomCard:setHighlightSpriteVisible(visible)
    local res = 'character_card_frame_select.png'
    local lua_name = 'selectSprite'

    if self.vars[lua_name] then
        self.vars[lua_name]:setVisible(visible)
    elseif (visible) then
        self:makeSprite(lua_name, res, nil, 99)
        -- 깜빡임 액션
        self.vars[lua_name]:runAction(cca.flash())
    end
end

-------------------------------------
-- function makeSprite
-- @brief 카드에 사용되는 sprite는 모두 이 로직으로 생성
-------------------------------------
function UI_MonsterCustomCard:makeSprite(lua_name, res, no_use_frames, zorder)
    local vars = self.vars
    local zorder = zorder or 0
    if vars[lua_name] then
        vars[lua_name]:removeFromParent()
        vars[lua_name] = nil
    end
    
    local sprite
    if (no_use_frames) then
        sprite = IconHelper:getIcon(res)
    else
        sprite = IconHelper:createWithSpriteFrameName(res)
    end
    vars['clickBtn']:addChild(sprite, zorder)
    vars[lua_name] = sprite
end
