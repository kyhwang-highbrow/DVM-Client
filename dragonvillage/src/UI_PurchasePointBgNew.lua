local PARENT = UI_PurchasePointBg

-------------------------------------
-- class UI_PurchasePointBgNew
-------------------------------------
UI_PurchasePointBgNew = class(PARENT,{})

-------------------------------------
-- function init
-------------------------------------
function UI_PurchasePointBgNew:init(bg_type, item_id, item_count, version)
end

-------------------------------------
-- function getUrl
-------------------------------------
function UI_PurchasePointBgNew:getUrl(bg_type)
    local url = 'event_purchase_point_item_reward_new_03.ui'
    
    -- 드래곤
    if (bg_type == 'dragon') then
        url = 'event_purchase_point_item_reward_new_02.ui'
    
    -- 드래곤 뽑기권
    elseif (bg_type == 'dragon_ticket') then
        url = 'event_purchase_point_item_reward_new_01.ui'
    
    -- 슬라임, 아이템
    else
        url = 'event_purchase_point_item_reward_new_03.ui'
    end

    return url
end