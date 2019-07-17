-------------------------------------
-- table AdWithoutPlayManager
-- @brief 광고 재생 없이 광고를 보상을 처리하는 매니저
-------------------------------------
AdWithoutPlayManager = {
    }

-------------------------------------
-- function showByAdType
-- @param ad_type
-- @param result_cb function(ret, info)
--                      -- 광고 시청 완료 -> 보상 처리
--                      if (ret == 'finish') then
--
--                      -- 광고 시청 취소
--                      elseif (ret == 'cancel') then
--
--                      -- 광고 에러
--                      elseif (ret == 'error') then
--
--                      end
--                  end
-------------------------------------
function AdWithoutPlayManager:showByAdType(ad_type, result_cb)
    local function ok_cb()
        if result_cb then
            result_cb('finish')
        end
    end

    MakeSimplePopup(POPUP_TYPE.OK, Str('광고 시스템 점검 중입니다.\n점검 중에는 광고 재생 없이 보상 획득이 가능합니다.'), ok_cb)
end

-------------------------------------
-- function showDailyAd
-- @breif 횟수 제한형 광고
-------------------------------------
function AdWithoutPlayManager:showDailyAd(ad_type, finish_cb)
    self:log('call showDailyAd() ad_type : ' .. tostring(ad_type)) 

    local function result_cb(ret, info)
        if (ret == 'finish') then
            g_advertisingData:request_dailyAdShow(ad_type, function()
                if (finish_cb) then
                    finish_cb()
                end
            end)
        end
    end

    self:showByAdType(ad_type, result_cb)
end


-------------------------------------
-- function log
-------------------------------------
function AdWithoutPlayManager:log(msg)
    local active = true
    if (not active) then
        return
    end

    cclog('##AdWithoutPlayManager log## : ' .. tostring(msg))
end