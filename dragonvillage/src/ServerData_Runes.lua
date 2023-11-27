-------------------------------------
-- class ServerData_Runes
-------------------------------------
ServerData_Runes = class({
        m_serverData = 'ServerData',
        m_mRuneObjects = 'map',
        m_runeCount = 'number',
        m_mRuneTicketGachaMileagePrice = 'Map<string, number>',
        m_runeTicketGachaDiaPrice = 'number',
    })

-------------------------------------
-- function init
-------------------------------------
function ServerData_Runes:init(server_data)
    self.m_serverData = server_data
    self.m_mRuneObjects = {}
    self.m_runeCount = 0
    self.m_mRuneTicketGachaMileagePrice = {}
    self.m_runeTicketGachaDiaPrice = 0
end

-------------------------------------
-- function request_runesInfo
-- @breif
-------------------------------------
function ServerData_Runes:request_runesInfo(finish_cb, fail_cb)
    -- 유저 ID
    local uid = g_userData:get('uid')

    -- 성공 콜백
    local function success_cb(ret)
        -- 룬 강화 테이블
        TABLE:setServerTable('table_rune_enhance', ret['table_rune_enhance'])

        -- 룬 등급 테이블
        TABLE:setServerTable('table_rune_grade', ret['table_rune_grade'])

        -- 룬 메인 옵션 능력치 테이블
        TABLE:setServerTable('table_rune_mopt_status', ret['table_rune_mopt_status'])

        -- 룬의 슬롯 종류 및 부옵션으로 가질 수 있는 효과 테이블
        TABLE:setServerTable('table_rune_opt', ret['table_rune_opt'])

        -- 보유 중인 룬 정보를 받아옴
        self:applyRuneData_list(ret['runes'])

        -- 룬 메모 파일 로드
        g_runeMemoData:loadRuneMemoMap()

        -- 룬 티켓 뽑기 가격
        if ret['buy_rune_ticket'] ~= nil then
            self.m_runeTicketGachaDiaPrice = ret['buy_rune_ticket']
        end

        if finish_cb then
            finish_cb(ret)
        end
    end

    -- 네트워크 통신
    local ui_network = UI_Network()
    ui_network:setUrl('/runes/info')
    ui_network:setParam('uid', uid)
    ui_network:setMethod('POST')
    ui_network:setSuccessCB(success_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:setRevocable(false)
    ui_network:setReuse(false)
    ui_network:request()

    return ui_network
end

-------------------------------------
-- function request_runesEquip
-- @breif
-------------------------------------
function ServerData_Runes:request_runesEquip(doid, roid, finish_cb, fail_cb)
    -- 유저 ID
    local uid = g_userData:get('uid')

    -- 성공 콜백
    local function success_cb(ret)

        if ret['deleted_rune_oid'] then
            self:deleteRuneData(ret['deleted_rune_oid'])
        end

        if ret['modified_rune'] then
            self:applyRuneData(ret['modified_rune'])

            -- @adjust
            local rid = ret['modified_rune']['rid'] 
            if (rid) then
                local grade = tonumber(rid)%10
                if (grade == 6) then
                    Adjust:trackEvent(Adjust.EVENT.RUNE_EQUIP)
                end
            end
        end
        
        -- 반드시 룬을 먼저 갱신하고 dragon을 갱신할 것
        if ret['dragon'] then
            g_dragonsData:applyDragonData(ret['dragon'])
        end

        -- @ MASTER ROAD
        local t_data = {clear_key = 'r_eq'}
        g_masterRoadData:updateMasterRoad(t_data)

        -- 드래곤 성장일지 : 룬 장착 체크
        local start_dragon_data = g_dragonDiaryData:getStartDragonData(ret['dragon'])
        if (start_dragon_data) then
            -- @ DRAGON DIARY
            local t_data = {clear_key = 'r_eq_s', sub_data = start_dragon_data}
            g_dragonDiaryData:updateDragonDiary(t_data)
        end

        -- @ GOOGLE ACHIEVEMENT
        GoogleHelper.updateAchievement(t_data)

        if finish_cb then
            finish_cb(ret)
        end
    end

    -- 네트워크 통신
    local ui_network = UI_Network()
    ui_network:setUrl('/runes/equip')
    ui_network:setParam('uid', uid)
    ui_network:setParam('doid', doid)
    ui_network:setParam('roid', roid)
    ui_network:setMethod('POST')
    ui_network:setSuccessCB(success_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()
end

-------------------------------------
-- function request_runesEquipNew
-- @breif 21-01-14 룬 편의성 개선 업데이트
-- @brief 한번에 여러 룬 장착 가능하고, 다른 드래곤이 장착하던 것도 장착 가능
-- @param doid : 대상 드래곤
-- @param roids : 장착되는 룬들의 roid 
-------------------------------------
function ServerData_Runes:request_runesEquipNew(doid, roids, finish_cb, fail_cb)
    -- 유저 ID
    local uid = g_userData:get('uid')

    -- 성공 콜백
    local function success_cb(ret)
        g_serverData:networkCommonRespone(ret)

        if ret['modified_rune'] then
            self:applyRuneData_list(ret['modified_rune'])

            -- @adjust
            for i, v in pairs(ret['modified_rune']) do
                local rid = v['rid'] 
                if (rid) then
                    local grade = tonumber(rid) % 10
                    if (grade == 6) then
                        Adjust:trackEvent(Adjust.EVENT.RUNE_EQUIP)
                    end
                end
            end
        end
        
        -- 반드시 룬을 먼저 갱신하고 dragon을 갱신할 것
        if ret['modified_dragon'] then
            g_dragonsData:applyDragonData_list(ret['modified_dragon'])
        end

        -- @ MASTER ROAD
        local t_data = {clear_key = 'r_eq'}
        g_masterRoadData:updateMasterRoad(t_data)

        -- 드래곤 성장일지 : 룬 장착 체크
        local start_dragon_data = g_dragonDiaryData:getStartDragonDataWithList(ret['modified_dragon'])
        if (start_dragon_data) then
            -- @ DRAGON DIARY
            local t_data = {clear_key = 'r_eq_s', sub_data = start_dragon_data}
            g_dragonDiaryData:updateDragonDiary(t_data)
        end

        -- @ GOOGLE ACHIEVEMENT
        GoogleHelper.updateAchievement(t_data)

        if finish_cb then
            finish_cb(ret)
        end
    end

    -- 네트워크 통신
    local ui_network = UI_Network()
    ui_network:setUrl('/runes/equip_new')
    ui_network:setParam('uid', uid)
    ui_network:setParam('doid', doid)
    ui_network:setParam('roids', roids)
    ui_network:setMethod('POST')
    ui_network:setSuccessCB(success_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()
end

-------------------------------------
-- function request_runesUnequip
-- @breif
-------------------------------------
function ServerData_Runes:request_runesUnequip(doid, slot, finish_cb, fail_cb)
    -- 유저 ID
    local uid = g_userData:get('uid')

    -- 성공 콜백
    local function success_cb(ret)
        g_serverData:networkCommonRespone(ret)

        if ret['modified_rune'] then
            self:applyRuneData(ret['modified_rune'])
        end
        
        -- 반드시 룬을 먼저 갱신하고 dragon을 갱신할 것
        if ret['modified_dragon'] then
            g_dragonsData:applyDragonData(ret['modified_dragon'])
        end

        if finish_cb then
            finish_cb(ret)
        end
    end

    -- 네트워크 통신
    local ui_network = UI_Network()
    ui_network:setUrl('/runes/unequip')
    ui_network:setParam('uid', uid)
    ui_network:setParam('doid', doid)
    ui_network:setParam('slot', slot)
    ui_network:setMethod('POST')
    ui_network:setSuccessCB(success_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()
end

-------------------------------------
-- function request_runeLevelup
-- @breif
-------------------------------------
function ServerData_Runes:request_runeLevelup(owner_doid, roid, finish_cb, fail_cb)
    -- 유저 ID
    local uid = g_userData:get('uid')

    -- 성공 콜백
    local function success_cb(ret)
        -- 공통 응답 처리 (골드 갱신을 위해)
        g_serverData:networkCommonRespone(ret)

        -- 룬 강화 성공
        if ret['modified_rune'] then
            ret['lvup_success'] = true
            ret['modified_rune']['owner_doid'] = owner_doid
            self:applyRuneData(ret['modified_rune'])

        -- 룬 강화 실패
        else
            ret['lvup_success'] = false
        end
        
        -- @ MASTER ROAD
        if ret['modified_rune'] then
            local t_data = {['clear_key'] = 'r_enc', ['clear_value'] = ret['modified_rune']['lv']}
            g_masterRoadData:updateMasterRoad(t_data)

            -- @ GOOGLE ACHIEVEMENT
            GoogleHelper.updateAchievement(t_data)
        end

        if finish_cb then
            finish_cb(ret)
        end
    end

    -- 네트워크 통신
    local ui_network = UI_Network()
    ui_network:setUrl('/runes/levelup')
    ui_network:setParam('uid', uid)
    ui_network:setParam('roid', roid)
    ui_network:setMethod('POST')
    ui_network:setSuccessCB(success_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()
end

-------------------------------------
-- function request_runeSell
-- @brief
-------------------------------------
function ServerData_Runes:request_runeSell(roid, finish_cb)
    local rune_oids = roid
    local items = nil
    g_inventoryData:request_itemSell(rune_oids, items, finish_cb)
end

-------------------------------------
-- function request_runeGacha
-- @brief
-------------------------------------
function ServerData_Runes:request_runeGacha(is_bundle, is_cash, rune_Type, finish_cb, fail_cb)
    -- parameters
    local is_cash = is_cash or false
    local uid = g_userData:get('uid')
    local item_id = 700651
    local is_bundle = is_bundle and is_bundle or false

    -- 성공 콜백
    local function success_cb(ret)
        --if (is_bundle) then
            ---- @analytics
            --Analytics:trackUseGoodsWithRet(ret, '11회 소환')
            --Analytics:firstTimeExperience('DragonSummonEvent_11')
        --else
            --Analytics:trackUseGoodsWithRet(ret, '1회 소환')
        --end
            
        -- cash(캐시) 갱신
        g_serverData:networkCommonRespone(ret)

        -- 룬들 추가
        g_runesData:applyRuneData_list(ret['runes'])

        -- 신규 룬 new 뱃지 정보 저장
        g_highlightData:saveNewDoidMap()

        if finish_cb then
            finish_cb(ret)
        end
    end

    -- 네트워크 통신
    local ui_network = UI_Network()
    ui_network:setUrl('/shop/rune_gacha')
    ui_network:setParam('uid', uid)
    ui_network:setParam('item_id', item_id)
    ui_network:setParam('bundle', is_bundle)
    ui_network:setParam('is_cash', is_cash)
    ui_network:setParam('type', rune_Type)
    ui_network:setMethod('POST')
    ui_network:setSuccessCB(success_cb)
    ui_network:setFailCB(fail_cb)

    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()
    
end

-------------------------------------
-- function request_runeCombine
-- @brief
-------------------------------------
function ServerData_Runes:request_runeCombine(src_roids, runeType, finish_cb, fail_cb)
    -- parameters
    local uid = g_userData:get('uid')
    local src_roids = src_roids or ''

    -- 성공 콜백
    local function success_cb(ret)
            
        -- cash(캐시) 갱신
        g_serverData:networkCommonRespone(ret)

        -- 룬들 추가
        g_runesData:applyRuneData_list(ret['runes'])

        -- 조합 재료 룬 제거
        if ret['deleted_rune_oids'] then
            self:deleteRuneData_list(ret['deleted_rune_oids'])
        end

        -- 신규 룬 new 뱃지 정보 저장
        g_highlightData:saveNewDoidMap()

        if finish_cb then
            finish_cb(ret)
        end
    end

    -- 네트워크 통신
    local ui_network = UI_Network()
    ui_network:setUrl('/runes/combine')
    ui_network:setParam('uid', uid)
    ui_network:setParam('src_roids', src_roids)
    ui_network:setParam('runeType', runeType)
    ui_network:setMethod('POST')
    ui_network:setSuccessCB(success_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()
end

-------------------------------------
-- function applyRuneData
-- @breif 룬 오브젝트 적용 (추가, 갱신)
-------------------------------------
function ServerData_Runes:applyRuneData(t_rune_data)
    local roid = t_rune_data['id']

    -- 룬 아이디가 정상적이지 않은 값은 예외처리
    if (not t_rune_data['rid']) or (t_rune_data['rid'] == 0) then
        return
    end

    -- 추가일 경우 count 증가
    if (not self.m_mRuneObjects[roid]) then
        self.m_runeCount = (self.m_runeCount + 1)

		local created_at = t_rune_data['created_at'] or nil
        g_highlightData:addNewRoid(roid, created_at)
    end

    -- 룬 정보의 관리를 위해 StructRuneObject클래스로 래핑하여 사용
    self.m_mRuneObjects[roid] = StructRuneObject(t_rune_data)
end

-------------------------------------
-- function applyRuneData_list
-- @breif 룬 오브젝트 적용 (추가, 갱신)
-------------------------------------
function ServerData_Runes:applyRuneData_list(l_rune_data)
    for i,v in pairs(l_rune_data) do
        self:applyRuneData(v)
    end
	g_highlightData:saveNewDoidMap()
end

-------------------------------------
-- function deleteRuneData
-- @breif 룬 오브젝트 삭제
-------------------------------------
function ServerData_Runes:deleteRuneData(roid)
    -- 삭제일 경우 count 감소
    if (self.m_mRuneObjects[roid]) then
        self.m_runeCount = (self.m_runeCount - 1)
        self.m_mRuneObjects[roid] = nil
    end
	if (g_highlightData:isNewRoid(roid)) then
		g_highlightData:removeNewRoid(roid)
	end
end

-------------------------------------
-- function deleteRuneData_list
-- @breif 룬 오브젝트 삭제
-------------------------------------
function ServerData_Runes:deleteRuneData_list(l_roid)
    for i,v in pairs(l_roid) do
        self:deleteRuneData(v)
    end
end


-------------------------------------
-- function getUnequippedRuneList
-- @brief 장착되지 않은 룬 리스트
-------------------------------------
function ServerData_Runes:getUnequippedRuneList(slot_idx, grade, lock_include, runeType, l_mopt_list, l_sopt_list, set_id)
    if (slot_idx == nil) then
        -- 전체
        slot_idx = 0
    end

    if (grade == nil) then
        -- 전체
        grade = 0
    end

    if (set_id == 0) then
        set_id = nil
    elseif (set_id == 'normal') then
        set_id = {1, 2, 3, 4, 5, 6, 7, 8}
    elseif (set_id == 'ancient') then
        set_id = {9, 10, 11, 12, 13, 14}
    elseif (set_id ~= nil) then
        set_id = {set_id}
    end


    if (lock_include == nil) then
        lock_include = true
    end
    local isAncient = (runeType == 'ancient')

    local l_ret = {}
    for i,v in pairs(self.m_mRuneObjects) do
        -- 슬롯 확인
        if (slot_idx ~= 0) and (v['slot'] ~= slot_idx) then
        -- 타입 필터
        elseif (isAncient ~= nil) and (v:isAncientRune() ~= isAncient) then
        -- 등급 확인
        elseif (grade ~= 0) and (v['grade'] ~= grade) then
        -- 잠금 여부 확인
        elseif (not lock_include) and (v['lock']) then
        -- 장착 여부 확인
        elseif v:isEquippedRune() then
        -- 세트 필터
        elseif set_id and (table.find(set_id, v['set_id']) == nil) then
        -- 주옵션 필터
        elseif l_mopt_list and (not v:hasMainOption(l_mopt_list)) then
        -- 보조옵션 필터
        elseif l_sopt_list and (not v:hasAuxiliaryOption(l_sopt_list)) then
        -- 보조옵션2 필터

        else
            local roid = v['roid']
            l_ret[roid] = clone(v)
        end
    end

    return l_ret
end

-------------------------------------
-- function getFilteredRuneList
-- @brief 필터링된 룬 리스트
-- @param l_mopt_list : 주옵션
-- @param l_sopt_list : 보조옵션(부옵션 + 추가옵션)
-------------------------------------
function ServerData_Runes:getFilteredRuneList(unequipped, slot, set_id, l_mopt_list, l_sopt_list)
    if (slot == 0) then
        slot = nil
    end

    if (set_id == 0) then
        set_id = nil
    elseif (set_id == 'normal') then
        set_id = {1, 2, 3, 4, 5, 6, 7, 8}
    elseif (set_id == 'ancient') then
        set_id = {9, 10, 11, 12, 13, 14}
    elseif (set_id ~= nil) then
        set_id = {set_id}
    end

    local l_ret = {}
    
    for i,v in pairs(self.m_mRuneObjects) do
        -- 슬롯 필터
        if slot and (slot ~= v['slot']) then
        -- 세트 필터
        elseif set_id and (table.find(set_id, v['set_id']) == nil) then
        -- 장착 여부 필터
        elseif unequipped and (v:isEquippedRune()) then
        -- 주옵션 필터
        elseif l_mopt_list and (not v:hasMainOption(l_mopt_list)) then
        -- 보조옵션 필터
        elseif l_sopt_list and (not v:hasAuxiliaryOption(l_sopt_list)) then
        -- 보조옵션2 필터
        else
            l_ret[i] = v
        end
    end
    

    return l_ret
end

-------------------------------------
-- function getRuneList
-- @breif
-------------------------------------
function ServerData_Runes:getRuneList()
	return self.m_mRuneObjects
end

-------------------------------------
-- function getRuneObject
-- @breif
-------------------------------------
function ServerData_Runes:getRuneObject(roid)
    if (not self.m_mRuneObjects[roid]) then
        --cclog('# 보유하지 않은 룬 검색 : ' .. roid)
		return nil
    end

    return self.m_mRuneObjects[roid]
end

-------------------------------------
-- function applyEquippedRuneInfo
-- @breif
-------------------------------------
function ServerData_Runes:applyEquippedRuneInfo(roid, doid)
    local rune_object = self:getRuneObject(roid)
    if (not rune_object) then
        return
    end
    rune_object:setOwnerDragon(doid)
end

-------------------------------------
-- function getUnequippedRuneCount
-- @breif
-------------------------------------
function ServerData_Runes:getUnequippedRuneCount()
    local unequipped = true
    local l_runes = self:getFilteredRuneList(unequipped)
    local count = table.count(l_runes)
    return count
end

-------------------------------------
-- function getRuneTicketGachaMileageProductPrice
-------------------------------------
function ServerData_Runes:getRuneTicketGachaMileageProductPrice(type)
    local struct_product_list = g_shopDataNew:getProductList(type)
    local struct_product =  table.getFirst(struct_product_list)
    local price = 0
    if struct_product ~= nil then
        price = struct_product:getPrice()
        self.m_mRuneTicketGachaMileagePrice[type] = price
    end
    return price
end

-------------------------------------
-- function isRuneTicketGachaAvailable
-------------------------------------
function ServerData_Runes:isRuneTicketGachaAvailable(is_check_gacha_only)
    local rune_box_count = g_userData:get('rune_ticket') or 0
    if rune_box_count > 0 then
        return true
    end

--[[     local cash = g_userData:get('cash') or 0
    if cash >= self:getRuneTicketGachaDiaPrice() then
        return true
    end ]]

    if is_check_gacha_only == true then
        return false
    end

    local rune_ticket_mileage_type = {'rune_mileage', 'rune_ancient_mileage'}
    for _, type in ipairs(rune_ticket_mileage_type) do
        if self:isRuneTicketGachaMileageAvailable(type) then
            return true
        end
    end

    return false
end

-------------------------------------
-- function isRuneTicketGachaMileageAvailable
-------------------------------------
function ServerData_Runes:isRuneTicketGachaMileageAvailable(type)
    local rune_mileage = g_userData:get(type) or 0
    local price = self.m_mRuneTicketGachaMileagePrice[type] 
                        or self:getRuneTicketGachaMileageProductPrice(type)
    if price <= rune_mileage then
        return true
    end
    return false
end

-------------------------------------
-- function getRuneTicketGachaDiaPrice
-------------------------------------
function ServerData_Runes:getRuneTicketGachaDiaPrice()
    return self.m_runeTicketGachaDiaPrice or 0
end

-------------------------------------
-- function request_runesLock
-- @breif
-------------------------------------
function ServerData_Runes:request_runesLock(roid, owner_doid, lock, finish_cb, fail_cb)
    -- 유저 ID
    local uid = g_userData:get('uid')

    -- 성공 콜백
    local function success_cb(ret)
        -- 룬 데이터 적용
        if ret['modified_rune'] then
            ret['modified_rune']['owner_doid'] = owner_doid
            self:applyRuneData(ret['modified_rune'])
        end

        if finish_cb then
            finish_cb(ret)
        end
    end

    -- 네트워크 통신
    local ui_network = UI_Network()
    ui_network:setUrl('/runes/lock')
    ui_network:setParam('uid', uid)
    ui_network:setParam('roid', roid)
    ui_network:setParam('lock', lock)
    ui_network:setMethod('POST')
    ui_network:setSuccessCB(success_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()

    return ui_network
end

-------------------------------------
-- function request_runesLock_toggle
-- @breif
-------------------------------------
function ServerData_Runes:request_runesLock_toggle(roid, owner_doid, finish_cb, fail_cb)
    local rune_object = self:getRuneObject(roid)
    if (not rune_object) then
        return
    end

    local lock = (not rune_object['lock'])
    return self:request_runesLock(roid, owner_doid, lock, finish_cb, fail_cb)
end

-------------------------------------
-- function request_runeGrind
-- @breif
-------------------------------------
function ServerData_Runes:request_runeGrind(owner_doid, roid, sopt_slot, using_item_id, finish_cb, fail_cb)
    -- 유저 ID
    local uid = g_userData:get('uid')

    -- 성공 콜백
    local function success_cb(ret)
        -- 룬 강화 성공
        if ret['modified_rune'] then
            ret['modified_rune']['owner_doid'] = owner_doid
            self:applyRuneData(ret['modified_rune'])
        end
            
        -- 공통 응답 처리 (골드 갱신을 위해)
        g_serverData:networkCommonRespone(ret)


        if finish_cb then
            finish_cb(ret)
        end
    end

    -- 네트워크 통신
    local ui_network = UI_Network()
    ui_network:setUrl('/runes/grind')
    ui_network:setParam('uid', uid)
    ui_network:setParam('roid', roid)
    ui_network:setParam('sopt_slot', sopt_slot)
    ui_network:setParam('item_id', using_item_id)
    ui_network:setMethod('POST')
    ui_network:setSuccessCB(success_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()
end

-------------------------------------
-- function request_runeBless
-- @breif
-------------------------------------
function ServerData_Runes:request_runeBless(owner_doid, roid, finish_cb, fail_cb)
    -- 유저 ID
    local uid = g_userData:get('uid')

    -- 성공 콜백
    local function success_cb(ret)
        -- 룬 강화 성공
        if ret['modified_rune'] then
            ret['modified_rune']['owner_doid'] = owner_doid
            self:applyRuneData(ret['modified_rune'])
        end
            
        -- 공통 응답 처리 (골드 갱신을 위해)
        g_serverData:networkCommonRespone(ret)


        if finish_cb then
            finish_cb(ret)
        end
    end

    -- 네트워크 통신
    local ui_network = UI_Network()
    ui_network:setUrl('/runes/bless')
    ui_network:setParam('uid', uid)
    ui_network:setParam('roid', roid)
    ui_network:setMethod('POST')
    ui_network:setSuccessCB(success_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()
end

-------------------------------------
-- function request_runeGachaTicket
-------------------------------------
function ServerData_Runes:request_runeGachaTicket(is_bundle, is_cash, rune_Type, finish_cb, fail_cb)
    -- parameters
    local is_cash = is_cash or false
    local uid = g_userData:get('uid')
    local item_id = TableItem:getItemIDFromItemType('rune_ticket')
    local is_bundle = is_bundle and is_bundle or false

    -- 성공 콜백
    local function success_cb(ret)           
        -- cash(캐시) 갱신
        g_serverData:networkCommonRespone(ret)

        -- 룬들 추가
        g_runesData:applyRuneData_list(ret['runes'])

        -- 신규 룬 new 뱃지 정보 저장
        g_highlightData:saveNewDoidMap()

        if finish_cb then
            finish_cb(ret)
        end
    end

    -- 네트워크 통신
    local ui_network = UI_Network()
    ui_network:setUrl('/shop/rune_gacha_new')
    ui_network:setParam('uid', uid)
    ui_network:setParam('item_id', item_id)
    ui_network:setParam('bundle', is_bundle)
    ui_network:setParam('is_cash', is_cash)
    ui_network:setParam('type', rune_Type)
    ui_network:setMethod('POST')
    ui_network:setSuccessCB(success_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()
end

-------------------------------------
-- function checkRuneGachaMaximum
-- @brief 룬 뽑기 최대치 확인
-- @return bool true : 뽑기 가능
--              false : 뽑기 불가능 (안내 팝업 띄움)
-------------------------------------
function ServerData_Runes:checkRuneGachaMaximum(gacha_rune_cnt)
    local gacha_rune_cnt = (gacha_rune_cnt or 0)
    local unequipped_rune_cnt = self:getUnequippedRuneCount()
    local MAXIMUM = 800
    if (MAXIMUM < (unequipped_rune_cnt + gacha_rune_cnt)) then
        local msg = Str('더는 룬을 획득 할 수 없습니다.\n룬 보유 공간을 확보해 주세요.')
        MakeSimplePopup(POPUP_TYPE.OK, msg)
        return false
    end

    return true
end