-------------------------------------
-- class ServerData_Eggs
-------------------------------------
ServerData_Eggs = class({
        m_serverData = 'ServerData',
    })

-------------------------------------
-- function init
-------------------------------------
function ServerData_Eggs:init(server_data)
    self.m_serverData = server_data
end

-------------------------------------
-- function request_incubate
-- @breif
-------------------------------------
function ServerData_Eggs:request_incubate(egg_id, cnt, finish_cb, fail_cb)
    -- 유저 ID
    local uid = g_userData:get('uid')
    local cnt = cnt or 1

    local function response_status_cb(ret)
        -- (미중복알 특성상) 도감에 있는 드래곤을 다 뽑아서 더 이상 뽑을 수 없는 경우
        if (ret['status']) then
            if (ret['status'] == -1702) then
                local msg1 = Str('더 이상 부화할 수 없습니다.') .. '\n' .. Str('(도감에 있는 모든 드래곤을 획득했습니다.)')
                local msg2 = Str('신규 드래곤이 추가되면 부화할 수 있습니다.')
                MakeSimplePopup2(POPUP_TYPE.OK, msg1, msg2)
                return true           
            end
        end
    end

    -- 성공 콜백
    local function success_cb(ret)
        -- @analytics
        Analytics:firstTimeExperience('DragonIncubate')

        -- Eggs 갱신
        g_serverData:networkCommonRespone(ret)

        -- 드래곤들 추가
        g_dragonsData:applyDragonData_list(ret['added_dragons'])

        -- 슬라임들 추가
        g_slimesData:applySlimeData_list(ret['added_slimes'])

        --드래곤 획득 패키지 정보 갱신
        g_getDragonPackage:applyPackageList(ret)

        if finish_cb then
            finish_cb(ret)
        end
    end

    -- 네트워크 통신
    local ui_network = UI_Network()
    ui_network:setUrl('/shop/incubate')
    ui_network:setParam('uid', uid)
    ui_network:setParam('eggid', egg_id)
    ui_network:setParam('cnt', cnt)
    ui_network:setResponseStatusCB(response_status_cb)
    ui_network:setMethod('POST')
    ui_network:setSuccessCB(success_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()

    return ui_network
end

-------------------------------------
-- function isExistEgg
-- @brief 해당 알 존재 여부
-------------------------------------
function ServerData_Eggs:isExistEgg(egg_id)
	local egg_id = tostring(egg_id)
	local egg_count = self.m_serverData:get('user', 'eggs', egg_id)
	if (egg_count) and (egg_count > 0) then 
		return true
	else
		return false
	end
end

-------------------------------------
-- function isExistTutorialEgg
-- @brief 해당 알 존재 여부
-------------------------------------
function ServerData_Eggs:isExistTutorialEgg()
	return self:isExistEgg(703027)
end

-------------------------------------
-- function getEggCount
-- @brief 보유중인 알 갯수 리턴
-------------------------------------
function ServerData_Eggs:getEggCount(egg_id)
    local egg_id = tostring(egg_id)
    local count = self.m_serverData:get('user', 'eggs', egg_id) or 0
    return count
end

-------------------------------------
-- function getEggList
-- @brief 보유중인 알 리스트 리턴
-------------------------------------
function ServerData_Eggs:getEggList(is_all)
    local is_all = is_all or false
    local egg_list = self.m_serverData:getRef('user', 'eggs')
    local table_item = TableItem()

    local t_ret = {}

    -- 리스트 생성
    for i,v in pairs(egg_list) do
        local egg_id = i
        local count = v

        if (is_all or 0 < count) then
            table.insert(t_ret, {['egg_id']=egg_id, ['count']=count})
        end
    end
    
    -- 정렬
    table.sort(t_ret, function(a, b) return self:sort_egg(a, b) end)

    return t_ret
end

-------------------------------------
-- function getEggListForUI
-- @brief UI에서 사용될 보유중인 알 리스트 리턴
-------------------------------------
function ServerData_Eggs:getEggListForUI()
    local egg_list = self.m_serverData:getRef('user', 'eggs')
    local table_item = TableItem()
    local t_ret = {}

    -- 리스트 생성
    for i,v in pairs(egg_list) do
        local egg_id = i
        local count = v

        -- 20180415 @jhakim 모든 알 10개 꾸러미로 부화 가능하도록 수정
        -- 20200109 @jhakim 미중복알은 10개 꾸러미 안됨
        if (self:isUndulpicateEgg(egg_id)) then
            for _i=1, count do
                table.insert(t_ret, {['egg_id']=egg_id, ['count']=1})
            end
        elseif (0 < count) then
            local full_type = table_item:getValue(tonumber(egg_id), 'full_type')
            
            local bundle_cnt = math_floor(count / 10)
            local indivisual_cnt = count - (bundle_cnt * 10)
            
            for _i=1, bundle_cnt do
                table.insert(t_ret, {['egg_id']=egg_id, ['count']=10})
            end
            
            for _i=1, indivisual_cnt do
                table.insert(t_ret, {['egg_id']=egg_id, ['count']=1})
            end
        end
    end

    -- 정렬
    table.sort(t_ret, function(a, b) return self:sort_egg(a, b) end)

    return t_ret
end

-------------------------------------
-- function isUndulpicateEgg
-------------------------------------
function ServerData_Eggs:isUndulpicateEgg(item_id)
    if (not item_id) then
        return false
    end

    local table_gacha_probability = TABLE:get('table_gacha_probability')
    t_gacha_probability = table_gacha_probability[tonumber(item_id)]
    if (not t_gacha_probability) then
        return false
    end

    return (t_gacha_probability['unduplicate'] == 1)
end

-------------------------------------
-- function sort_egg
-------------------------------------
function ServerData_Eggs:sort_egg(a, b)
    local table_summon_gacha = TableSummonGacha()

    local a_id = a['egg_id']
    local b_id = b['egg_id']

    local a_priority = table_summon_gacha:getUIPriority(a_id)
    local b_priority = table_summon_gacha:getUIPriority(b_id)

    -- UI 우선순위 (큰 값이 앞쪽)
    if (a_priority ~= b_priority) then
        return a_priority > b_priority

    -- egg_id(item_id) (작은 값이 앞쪽)
    elseif (a_id ~= b_id) then
        return a_id < b_id

    -- count가 높은게 우선순위가 높음
    else
        return a['count'] > b['count']
    end
end