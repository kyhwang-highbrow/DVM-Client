local PARENT = class(UI, ITableViewCell:getCloneTable())

-------------------------------------
-- class UI_AccessTimeDataListItem
-- @brief 접속 시간 보상 리스트 아이템
--        이벤트 팝업에서 일간 접속 시간에 따라 보상을 획득
-------------------------------------
UI_AccessTimeDataListItem = class(PARENT, {
        m_dataInfo = '',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_AccessTimeDataListItem:init(data_info)
    self.m_dataInfo = data_info
    local vars = self:load('event_time_item.ui')

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_AccessTimeDataListItem:initUI()
    local vars = self.vars
    local data_info = self.m_dataInfo
    local step = data_info['step']

    -- 필요 시간
    local need_time = data_info['time']
    vars['timeLabel']:setString(Str('{1}분', need_time/60))

    -- 보상 정보
    local l_str = seperate(data_info['reward'], ';')
    local item_type = l_str[1]
    local cnt = l_str[2]
    local id = TableItem:getItemIDFromItemType(item_type) or tonumber(item_type)
    local item_card = UI_ItemCard(id, cnt)
    vars['itemNode']:addChild(item_card.root)

    -- 보상버튼
    local finish_cb 
    finish_cb = function()
        UIManager:toastNotificationGreen(Str('{1}단계 접속시간 보상을 받았습니다.', step))
        self:refresh()

        -- 전면 광고 노출 (6단계 보상에서만 동작)
        if (tonumber(step) == 6) then
            self:showInterstitialAD(step)
        end
    end

    vars['receiveBtn']:registerScriptTapHandler(function() 
        g_accessTimeData:request_reward(step, function() finish_cb() end)
    end)
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_AccessTimeDataListItem:initButton()
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_AccessTimeDataListItem:refresh()
    local vars = self.vars
    local data_info = self.m_dataInfo

    local step = data_info['step']
    local need_time = data_info['time']
    local cur_time = g_accessTimeData:getTime()

    -- 받은 보상인지
    local is_get = g_accessTimeData:isGetReward(step)
    vars['checkSprite']:setVisible(is_get)
    

    -- 버튼 활성화
    local condition = (cur_time >= need_time) and (not is_get) 
    vars['receiveBtn']:setEnabled(condition)
    vars['readySprite']:setVisible(not condition)
end

-------------------------------------
-- function showInterstitialAD
-- @brief 전면 광고 노출
-------------------------------------
function UI_AccessTimeDataListItem:showInterstitialAD()
    -- 안드로이드에서만 동작
    if (CppFunctions:isAndroid() == false) then
        return
    end

    local loading = nil

    -- 광고를 재생하는 동안 로딩창으로 블럭 처리
    local loading = UI_Loading()
    loading:setLoadingMsg(Str('네트워크 통신 중...'))

    -- 일정 시간 후 닫기 (혹시 모를 무한 대기 상태를 대비)
    local node = loading.root
    local duration = 5
    local function func()
        loading:close()
        loading = nil
    end
    cca.reserveFunc(node, duration, func)

    -- 콜백에서 로딩창 닫기
    local function one_time_callback(ret, info)
        if loading then
            loading:close()
            loading = nil
        end
    end

    -- 광고 재생
    AdMobManager:getInterstitialAd():setOneTimeCallback(one_time_callback)
	AdMobManager:getInterstitialAd():show()
end