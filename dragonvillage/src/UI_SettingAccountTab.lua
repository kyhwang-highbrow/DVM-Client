-------------------------------------
-- function init_accounteTab
-------------------------------------
function UI_Setting:init_accountTab()
    local vars = self.vars
    vars['clearBtn']:registerScriptTapHandler(function() self:click_clearBtn() end)
    vars['logoutBtn']:registerScriptTapHandler(function() self:click_logoutBtn() end)
end

-------------------------------------
-- function click_clearBtn
-------------------------------------
function UI_Setting:click_clearBtn()
    local ask_popup
    local request
    local claer

    -- 1. 계정 초기화 여부를 물어보는 팝업
    ask_popup = function()
        local ok_btn_cb = function()
            request()
        end
    
        local cancel_btn_cb = nil

        local msg = Str('{@BLACK}' .. '계정을 초기화하시겠습니까?')
        MakeSimplePopup(POPUP_TYPE.YES_NO, msg, ok_btn_cb, cancel_btn_cb)
    end

    -- 2. 네트워크 통신
    request = function()
        local uid = g_userData:get('uid')
        local success_cb = claer

        local ui_network = UI_Network()
        ui_network:setUrl('/manage/delete_user')
        ui_network:setParam('uid', uid)
        ui_network:setSuccessCB(success_cb)
        ui_network:setRevocable(true)
        ui_network:setMethod('GET')
        ui_network:setHmac(false)
        ui_network:request()
    end

    -- 3. 로컬 세이브 데이터 삭제 후 어플 재시작
    claer = function()
        LocalData:getInstance():clearLocalDataFile()
        ServerData:getInstance():clearServerDataFile()
        UserData:getInstance():clearServerDataFile()

        -- AppDelegate_Custom.cpp에 구현되어 있음
        restart()
    end
    
    ask_popup()
end

-------------------------------------
-- function click_logoutBtn
-------------------------------------
function UI_Setting:click_logoutBtn()
    local ask_popup
    local claer

    -- 1. 계정 초기화 여부를 물어보는 팝업
    ask_popup = function()
        local ok_btn_cb = function()
            claer()
        end
    
        local cancel_btn_cb = nil

        local msg = Str('{@BLACK}' .. '로그아웃하시겠습니까?')
        MakeSimplePopup(POPUP_TYPE.YES_NO, msg, ok_btn_cb, cancel_btn_cb)
    end

    -- 2. 로컬 세이브 데이터 삭제 후 어플 재시작
    claer = function()
        LocalData:getInstance():clearLocalDataFile()
        ServerData:getInstance():clearServerDataFile()
        UserData:getInstance():clearServerDataFile()

        -- AppDelegate_Custom.cpp에 구현되어 있음
        restart()
    end

    ask_popup()
end