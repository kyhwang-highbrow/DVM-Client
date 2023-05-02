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
        -- 드래곤 뽑기권에서 나올 드래곤들 출력
        local item_id = self.m_item_id
        local dragon_list_str = TablePickDragon:getCustomList(item_id)
        local dragon_list = plSplit(dragon_list_str, ',')
        -- 드래곤 수로 case_num 설정
        local case_num = table.count(dragon_list)
        if case_num == 0 then
            -- 드래곤이 하나도 없는 경우는 새로운 ui 레이아웃 사용(소환권 크기를 크게)
            url = 'event_purchase_point_item_reward_new_04.ui'
        else
            url = 'event_purchase_point_item_reward_new_01.ui'
        end
    
    -- 슬라임, 아이템
    else
        url = 'event_purchase_point_item_reward_new_03.ui'
    end

    return url
end