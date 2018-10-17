-------------------------------------
-- class ServerData_PurchasePoint
-- @instance g_purchasePointData
-------------------------------------
ServerData_PurchasePoint = class({
        m_serverData = 'ServerData',
        m_purchasePointInfo = 'table',
    })

-------------------------------------
-- function init
-------------------------------------
function ServerData_PurchasePoint:init(server_data)
    self.m_serverData = server_data
end

-------------------------------------
-- function response_purchasePointInfo
-- @brief
-- @used_at API:/users/lobby
-------------------------------------
function ServerData_PurchasePoint:response_purchasePointInfo(ret, finish_cb)
    self:applyPurchasePointInfo(ret['purchase_point_info'])

    if finish_cb then
        finish_cb(ret)
    end
end

-------------------------------------
-- function applyPurchasePointInfo
-- @brief
-------------------------------------
function ServerData_PurchasePoint:applyPurchasePointInfo(t_data)
    if (not t_data) then
        return
    end

    -- t_dat : ret에 purchase_point_info라는 key 값으로 아래와 같은 형태로 전달됨
    -- start, end : timestamp
    --"purchase_point_info": {
	--    "purchase_point_list": {
	--	    "1010001": {
	--		    "4": {
	--			    "item": "770455;1",
	--			    "purchase_point": 300000
	--		    },
	--		    "1": {
	--			    "item": "700402;3",
	--			    "purchase_point": 1
	--		    },
	--		    "2": {
	--			    "item": "700002;5000000",
	--			    "purchase_point": 50000
	--		    },
	--		    "end": 1539788400000,
	--		    "start": 1538578800000,
	--		    "3": {
	--			    "item": "700001;10000",
	--			    "purchase_point": 100000
	--		    }
	--	    }
	--    },
	--    "purchase_point_reward": {
	--	    "1010001": 0
	--    },
	--    "purchase_point": {
	--	    "1010001": 60
	--    }
   --}

    if (not self.m_purchasePointInfo) then
        self.m_purchasePointInfo = {}
    end
    
    if t_data['purchase_point_list'] then
        self.m_purchasePointInfo['purchase_point_list'] = t_data['purchase_point_list']
    end

    if t_data['purchase_point'] then
        self.m_purchasePointInfo['purchase_point'] = t_data['purchase_point']
    end

    if t_data['purchase_point_reward'] then
        self.m_purchasePointInfo['purchase_point_reward'] = t_data['purchase_point_reward']
    end
end


-------------------------------------
-- function hasPurchasePointReward
-- @brief
-------------------------------------
function ServerData_PurchasePoint:hasPurchasePointReward()
    local purchase_point_list = self.m_purchasePointInfo['purchase_point_list'] or {}

    for version, t_data in pairs(purchase_point_list) do
        local curr_purchase_point = self:getPurchasePoint(version)
        local curr_purchase_reward_step = self:getPurchaseRewardStep(version)
        for i,v in pairs(t_data['step_list']) do
            -- 다음 보상이 획득 가능하지 확인
            if (tonumber(i) == (curr_purchase_reward_step + 1)) then
                if (v['purchase_point'] <= curr_purchase_point) then
                    return true
                end
            end
        end
    end

    return false
end

-------------------------------------
-- function getPurchasePoint
-- @brief
-------------------------------------
function ServerData_PurchasePoint:getPurchasePoint(version)
   local purchase_point = self.m_purchasePointInfo['purchase_point'] or {}
   return purchase_point[tostring(version)] or 0
end

-------------------------------------
-- function getPurchaseRewardStep
-- @brief
-------------------------------------
function ServerData_PurchasePoint:getPurchaseRewardStep(version)
   local purchase_point_reward = self.m_purchasePointInfo['purchase_point_reward'] or {}
   return purchase_point_reward[tostring(version)] or 0
end

-------------------------------------
-- function getEventPopupTabList
-------------------------------------
function ServerData_PurchasePoint:getEventPopupTabList()
    local purchase_point_list = self.m_purchasePointInfo['purchase_point_list'] or {}

    local l_item_list = {}

    for version,v in pairs(purchase_point_list) do

        local event_data = {}
        event_data['t_name'] = Str('누적 결제 이벤트')
        event_data['icon'] = 'ui/event/list_time_reward.png'

        local struct_event_popup_tab = StructEventPopupTab(event_data)
        local type_name = 'purchase_point_' .. version
        struct_event_popup_tab.m_type = type_name
        struct_event_popup_tab.m_sortIdx = 0

        l_item_list[type_name] = struct_event_popup_tab
    end

    return l_item_list
end