-------------------------------------
-- class ServerData_ContentLock
-------------------------------------
ServerData_ContentLock = class({
        m_serverData = 'ServerData',

        m_tContentOpen = 'list',
        m_bContentOpenDirty = 'boolean',
    })

-------------------------------------
-- function init
-------------------------------------
function ServerData_ContentLock:init(server_data)
    self.m_serverData = server_data
	self.m_tContentOpen = {}
    self.m_bContentOpenDirty = true
end

-------------------------------------
-- function isContentLock
-- @param content_name string
--        adventure      모험
--        exploration	 탐험
--        nest_tree	     [네스트] 거목 던전
--        nest_evo_stone [네스트] 진화재료 던전
--        ancient        고대의 탑
--        attr_tower     시험의 탑
--        colosseum	     콜로세움
--        nest_nightmare [네스트] 악몽 던전
--        ancient_ruin   [네스트] 고대 유적 던전
--        rune_guardian  룬 수호자의 던전
--        dmgate         차원문
-------------------------------------
function ServerData_ContentLock:isContentLock(content_name)
    local table_content_lock = TABLE:get('table_content_lock')
    local t_content_lock = table_content_lock[content_name]

    -- 테이블에 없는데 조건 검사해야하는 던전들 =====================

    -- [그랜드 아레나 이벤트]
	-- 오픈 여부& 스테이지 여부 검사
    if (content_name == 'grand_arena') then
        return (not g_grandArena:isActive_grandArena())
    end

	-- [클랜전]
	-- 1.클랜이 열려야 함 2.클랜에 가입되어 있어야함
    local is_clan_open = self:isContentOpenByServer('clan')
    if (content_name == 'clan_war') then
        if (is_clan_open) then  
            local is_guest = g_clanData:isClanGuest()
            return is_guest
        end
		return true
    end

    -- 테이블에 있어서 조건 검사해야하는 던전들 =====================
    
    -- 테이블에 없는 컨텐츠 이름은 다 풀어준다.
    if (not t_content_lock) then
        --error('content_name : ' .. content_name)
        return false
    end

    -- [시험의 탑]
	-- 유저 레벨이 아닌 고대의 탑 40층 기준으로 오픈
    if (content_name == 'attr_tower') then
        local attr_tower_open = g_attrTowerData:isContentOpen()
        local is_lock = not attr_tower_open
        return is_lock
    end

	-- [클랜 던전]
	-- 1.클랜이 열려야 함 2.클랜에 가입되어 있어야함
    local is_clan_open = self:isContentOpenByServer('clan')
    if (content_name == 'clan_raid') then
        if (is_clan_open) then  
            local is_guest = g_clanData:isClanGuest()
            return is_guest
        end
		return true
    end

	-- [룬 수호자의 던전]
	-- 1.클랜이 열려야 함 2.클랜에 가입되어 있어야함 3. 악몽던전 10을 깨야함
    local is_clan_open = self:isContentOpenByServer('clan')
    if (content_name == 'rune_guardian') then
        if (is_clan_open) then  
            local is_guest = g_clanData:isClanGuest()
            if (not is_guest) then
				local is_open = g_ancientRuinData:isOpenAncientRuin() -- 고대유적 던전이랑 조건이 같음
				if (is_open) then  -- 열려 있다면 false
					return false
				end
			end
        end
		return true
    end

	-- [캡슐 뽑기]
	-- 스테이지 조건에 맞아야하고, 캡슐뽑기 열렸을 때에만 오픈
	if (content_name == 'capsule') then
		if (self:isContentOpenByServer(content_name)) then
			if (g_capsuleBoxData:getIsOpen()) then
				return false
			end	
		end
		return true
	end

    -- [고대 유적 던전]
	-- 악몽 던전 클리어 여부로 검사
    if (content_name == 'ancient_ruin') then
        local is_open = g_ancientRuinData:isOpenAncientRuin()
        return (not is_open)
    end

    return not self:isContentOpenByServer(content_name)
end

-------------------------------------
-- function isContentLock
-- @param content_name string
-- table_content_lock.csv 2017-07-06 sgkim
--        adventure      모험
--        exploation	 탐험
--        nest_tree	     [네스트] 거목 던전
--        nest_evo_stone [네스트] 진화재료 던전
--        ancient        고대의 탑
--        attr_tower     시험의 탑
--        colosseum	     콜로세움
--        nest_nightmare [네스트] 악몽 던전
--        ancient_ruin   [네스트] 고대 유적 던전
-------------------------------------
function ServerData_ContentLock:isContentLockByLevel(content_name)
    local table_content_lock = TABLE:get('table_content_lock')
    local t_content_lock = table_content_lock[content_name]

    -- 지정되지 않은 콘텐츠 이름일 경우
    if (not t_content_lock) then
        --error('content_name : ' .. content_name)
        return false
    end

    -- 시험의 탑 경우 유저 레벨이 아닌 다른 조건으로 검사
    if (content_name == 'attr_tower') then
        local attr_tower_open = g_attrTowerData:isContentOpen()
        local is_lock = not attr_tower_open
        return is_lock
    end

    -- 클랜던전의 경우 클랜 가입 여부로 검사
    if (content_name == 'clan_raid') then
        local is_guest = g_clanData:isClanGuest()
        return is_guest
    end

    -- 고대 유적 던전의 경우 악몽 던전 클리어 여부로 검사
    if (content_name == 'ancient_ruin') then
        local is_open = g_ancientRuinData:isOpenAncientRuin()
        return (not is_open)
    end

    -- 필요 유저 레벨 지정
    local user_lv = g_userData:get('lv')
    local req_user_lv = t_content_lock['req_user_lv']
    if (user_lv < req_user_lv) then
        return true, req_user_lv
    end

    return false
end

-------------------------------------
-- function getContentsQuestList
-- @brief 컨텐츠 퀘스트에서 필요한 리스트 반환
-------------------------------------
function ServerData_ContentLock:getContentsQuestList()
    local t_content_lock = TABLE:get('table_content_lock')
    local t_filter = {}

	-- 리워드가 있는 것 == 컨텐츠 해금 퀘스트로 판단
    for content_name, data in pairs(t_content_lock) do
        if (data['reward']) and (data['reward'] ~= '') then
            t_filter[content_name] = data
        end
    end

    return t_filter
end

-------------------------------------
-- function isContentOpenByServer
-- @param 로비통신에서 받는 콘텐츠 해금 여부
-- @brief 서버 값에만 의존한 결과, 종합적으로 판단한 콘텐츠 해금 여부는 isContentLock 함수를 사용해야함
-- 스테이지 클리어가 조건인 경우는 서버에서 컨텐츠 상태 값의 default가 0(신규유저) 혹은 안내려오지만(기존 유저중 조건이 안되는 경우)
-- 그 외의 조건인 경우 default 값이 1로 내려오기 때문에 클라에서 추가적인 조건이 필요함.
-------------------------------------
function ServerData_ContentLock:isContentOpenByServer(content_name)
    local t_content = self.m_tContentOpen or {}
    
    -- 언락 리스트에 없다면 잠금 처리
    -- [21/04/16] 차원문과 같이 신규 컨텐츠가 들어가는 경우 기존 유저 중에 신규 컨텐츠 언락 조건이 안되는 유저들은
    -- 서버에서 신규 컨텐츠에 대한 정보가 내려오지 않기 때문에 조건이 안되어도 보상 수령이 가능하고 수령 이후에는
    -- 서버에서 컨텐츠 해금 처리를 하기 때문에 이와 같은 상황을 막기 위해 return 값을 true에서 false로 수정.
    if (not t_content[content_name]) then
        return false
    end

    -- 0 이라면 lock이 걸린 상태
    -- 1 이라면 lock이 풀린 상태
    -- 2 이라면 보상을 받은 상태
    if (t_content[content_name] >= 1) then
        return true
    else
        return false
    end
end

-------------------------------------
-- function isRewardDone
-- @param 로비통신에서 받는 콘텐츠 보상 받을 수 있는지 여부
-------------------------------------
function ServerData_ContentLock:isRewardDone(content_name)
    local t_content = self.m_tContentOpen or {}
    
    -- 언락 리스트에 없다면 보상 받은 상태로 둠
    if (not t_content[content_name]) then
        return false
    end

    -- 0 이라면 lock이 걸린 상태
    -- 1 이라면 lock이 풀린 상태
    -- 2 이라면 보상을 받은 상태
    if (t_content[content_name] == 2) then
        return true
    else
        return false
    end
end


-------------------------------------
-- function applyContentLockByStage
-------------------------------------
function ServerData_ContentLock:applyContentLockByStage(l_content)
    self:setIsContentLockDirty(true)
    self.m_tContentOpen = l_content or {}
end

-------------------------------------
-- function getIsContentLockDirty
-------------------------------------
function ServerData_ContentLock:getIsContentLockDirty()
    return self.m_bContentOpenDirty
end

-------------------------------------
-- function setIsContentLockDirty
-------------------------------------
function ServerData_ContentLock:setIsContentLockDirty(is_dirty)
    self.m_bContentOpenDirty = is_dirty
end

-------------------------------------
-- function isContentBeta
-- @param content_name string
-------------------------------------
function ServerData_ContentLock:isContentBeta(content_name)

    -- 2017-09-15 ios정책에서 게임 내 beta/ demo / test / 체험판 / 타플랫폼 문구가 노출되지 않아야 합니다.
    if isIos() then
        return false
    end

    local table_content_lock = TABLE:get('table_content_lock')
    local t_content_lock = table_content_lock[content_name]

    -- 지정되지 않은 콘텐츠 이름일 경우
    if (not t_content_lock) then
        --error('content_name : ' .. content_name)
        return false
    end

    local beta = t_content_lock['beta']
    if (beta == true) or (beta == 'true') then
        return true
    end

    return false
end

-------------------------------------
-- function checkContentLock
-- @param content_name string
-- @param excute_func function
-------------------------------------
function ServerData_ContentLock:checkContentLock(content_name, excute_func)

    -- 콘텐츠 오픈 여부 받아옴
    local is_content_lock = self:isContentLock(content_name)
    if (not is_content_lock) then
        return true
    end

    local table_content_lock = TABLE:get('table_content_lock')
    local t_content_lock = table_content_lock[content_name]

    -- 잠금 안내
    local msg = UI_QuestListItem_Contents.makeConditionDesc(t_content_lock['req_stage_id'], t_content_lock['t_desc']) or ''
    msg = string.format('[%s]\n\n%s', Str('입장 조건'), msg)
    MakeSimplePopup(POPUP_TYPE.OK, msg)

    -- 함수 실행
    if excute_func then
        excute_func()
    end

    return false
end

-------------------------------------
-- function getOpenContentNameWithLv
-------------------------------------
function ServerData_ContentLock:getOpenContentNameWithLv(lv)
    local table_content_lock = TABLE:get('table_content_lock')
	if (true) then
		return nil
	end
	-- @190825 컨텐츠 오픈 조건이 레벨->스테이지로 바뀌면서 필요없어진 함수
	--[[
    for _, t_content_lock in pairs(table_content_lock) do
        local req_user_lv = t_content_lock['req_user_lv']

		-- 콘텐츠 오픈 팝업 skip항목 필터 (sgkim 2018.12.12 그림자의 신전, 그랜드 콜로세움)
        local skip_popup = toboolean(t_content_lock['skip_popup'])
        if (not skip_popup) and (req_user_lv == lv) then
            return t_content_lock['content_name']
        end
    end
	--]]
end

-------------------------------------
-- function getOpenContentDesc
-------------------------------------
function ServerData_ContentLock:getOpenContentDesc(content_name)
    if (not content_name) then
        return ''
    end

    if (content_name == '') then
        return ''
    end
    
    local table_content_lock = TABLE:get('table_content_lock')
    local t_content_lock = table_content_lock[content_name]

    if (not t_content_lock) then
        return ''
    end

    local open_desc = t_content_lock['t_open_desc']
    if (not open_desc) then
        return ''
    end

    return open_desc
end

-------------------------------------
-- function request_contentsOpenReward
-------------------------------------
function ServerData_ContentLock:request_contentsOpenReward(content_name, finish_cb)
    -- 파라미터
    local uid = g_userData:get('uid')

    -- 콜백 함수
    local function success_cb(ret)
        if (ret['content_unlock_list']) then
            self:applyContentLockByStage(ret['content_unlock_list'])
        end
        
		-- 로비에서 노티 갱신하도록
		g_highlightData:setDirty(true)

        -- 바로 지급되는 리워드의 경우 added_items로 들어옴 table_quest의 product_content, mail_content 참고
        local l_reward_item = {}
        if (ret['added_items']) then
            if (ret['added_items']['items_list']) then
                l_reward_item = ret['added_items']['items_list']
            end
        end
	
		-- 지급된 아이템 동기화
        g_serverData:networkCommonRespone_addedItems(ret)		

        if (finish_cb) then
            finish_cb(l_reward_item)
        end
    end

    -- 콜백 함수
    local function fail_cb(ret)
    end

    -- 네트워크 통신 UI 생성
    local ui_network = UI_Network()
    ui_network:setUrl('/users/content/unlock')
    ui_network:setParam('uid', uid)
    ui_network:setParam('content_name', content_name) -- adventrue(모험)
    ui_network:setSuccessCB(success_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()

	return ui_network
end

-------------------------------------
-- function isRewardableContentQuest
-- @brief 보상받을 컨텐츠 해금 퀘스트가 있는 지 확인
-------------------------------------
function ServerData_ContentLock:isRewardableContentQuest()
	local t_quest = g_contentLockData:getContentsQuestList()
    for idx, data in pairs(t_quest) do
        local content_name = data['content_name']
        local reward_state = UI_QuestListItem_Contents.getRewardState(content_name) -- 보상 가능일 때 1 리턴
        if (reward_state == 1) then
           return true
        end
    end

	return false
end