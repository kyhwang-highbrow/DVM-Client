local t_package =
{
	'com.bluestacks.home'

	,'com.android.ggjb'
	,'com.android.xxx'
	,'com.google.android.xyz'
	,'com.google.android.kkk'
	,'rme.odu.skdml.djflsdo'
	,'wo1al3djqt5ek7.ekdjqt.alw'
	,'com.formyhm.hideroot'

	,'lyout.fire.kk'
	,'ggma.skdml.djflsdo'
	,'lg.min.cris'
	,'maozhu7.aque.gg'
	,'love88.love.qq'
	,'cris2.jeong2.samsung2'
	,'sinnanahiihi.code.all'
	,'qkd.rhkd.wnl'
	,'m.b.c5'
	,'love.for.you'
	,'qorehf01.dnrpa730.Wkd19'
	,'wmr05237w.ffree2.gg'
	,'cc.cz.madkite.freedom'
	,'cris.jeong.samsung'
	,'sub.love.in'
	,'eun.jung.jjang'
	,'love.cris.jeong'
	,'present.for.u'
	,'kirino.oreimo.guardian'
	,'lf.cafe.forum'
	,'sksms.wkdus.dlsdlek'

	,'tree.cross.lott'
	,'mr.sai.stuff'
	,'mr.big.stuff'
	,'wmr05237.free2.gg'
	,'wmr05237.free.gg'
	,'devv.codee.alll'
	,'sjfmfgi.code.all'
	,'sinnayooyo.code.all'
	,'arc12.sjw.arc'
	,'duly.make.cheat'
	,'qkd2.rhkd2.wnl2'
	,'maozhu4.aqub.gg'

	,'sinnandagolyo.code.all'
	,'stroydc.code.all'
	,'lIlI11lllIIllIII.code.all'
	,'mbc.g.j'
	,'asc2rf12ss.code.all'
	,'DPCross.code.all'
	,'sinna.code.all'
	,'ckdssa.code.all'
	,'park.geon.ju'
	,'dev.code.all'
	,'gamebil.fuck.you'
	,'you.so.good'
	,'hi.you.sexy'

	,'com.google.android.gg'
	,'bro.wnie.all'
	,'brom.wniem.all'
	,'cn.mc.aaa'
	,'soulk.ss.dd'
	,'An.dro.meda'

	-- for china
	,'com.saitesoft.gamecheater'
	,'com.thirdmoney.crack'
	,'com.huati'

	-- 게임해커 및 우회 패키지
	,'org.sbtools.gamehack_2.6'
	,'org.sbtools.gamehack'
	,'org.sbtools.gamespeed'
	--,'biz.bokhorst.xprivacy'

	-- 게임킬러 및 우회 패키지
	,'cn.luomao.gamekiller'
	,'cn.maocai.gamekiller'
	,'cn.mc.sq'
	,'cn.maocai.gameki11er'
	,'cn.maocai.game'

	-- kisa hex 및 우회 패키지
	,'OhRedKisa.aqua.gg'

	-- 게임치 및 우회 패키지
	,'com.cih.game_cih'
	,'com.cih.gamecih'
	,'com.cih.gamecih2co.kr.fuckingdetect'
	,'com.cih.gamecih2'
	,'com.duly.game_cih'
	,'com.cih.game'

	-- 게임가디언 및 우회 패키지
	,'kakao.cafe.coffee'
	,'rmeodu.skdml.djflsdo'
	,'sss.uuu.lall'
	,'co.kr.fuckingdetect'
	,'idv.aqua.bulldog'
	,'idv.aqua.bull'
	,'doll.coll.aoll'
	,'dodo.spo.kkkk'
	--,'www.fow.kr'

	-- 루팅 우회 프로그램
	--,'de.robv.android.xposed.installer'

	-- 매크로 프로그램
	,'com.cygery.repetitouch.pro'	--repetitouch pro
	,'com.cygery.repetitouch.free'	--repetitouch free
	,'me.autotouch.autotouch'		--Autotouch
	,'com.x0.strai.frep'			--Frep
	,'com.prohiro.macro'			--히로메크로
	,'com.woodthm.thetoucherimp'	--The Toucher
	,'com.lux.smacro'				--SMacro
	,'com.lunatics.macro'			--MAcro
	,'com.frapeti.androidbotmaker'	--Android Bot Maker

	-- 2016. 01. 19. 추가
	, 'gor47.zet.zizp'
	, 'ckdssa.code.all'
	, 'mommom.pusan.korea'
	, 'bp1108.fuq.gg'
}

HackingDetector = {}

-------------------------------------
-- function checkHack
-------------------------------------
function HackingDetector:checkHack()
    if (not Is026Ver()) then return false end

	local check1 = self:checkDat()
	local check2 = self:checkPackage()

	return check1 or check2
end

-------------------------------------
-- function checkDat
-------------------------------------
function HackingDetector:checkDat()
	if isWin32() then return false end

    --[[
	local t_hash = TABLE:get('col')
	local t_ret = {}

	for k, v in pairs(t_hash) do
		if not t_skip_teable[t_skip_teable] then
			local target = 'data_dat/' .. k .. '.dat'
			local path = cc.FileUtils:getInstance():fullPathForFilename(target)

			if cc.FileUtils:getInstance():isFileExist(path) then
				if isSameMd5(v['hash'], path) then
					--cclog('HackingDetector:checkDat() ok! ' .. k)
				else
					cclog('HackingDetector:checkDat() fail! ' .. k, v['hash'])
					table.insert(t_ret, k)
				end
			end
		end
	end

	if #t_ret > 0 then
		self:requestToSnitch({ type = 'table_local_hack', data = t_ret })
		return true
	end
    ]]--

	return false
end

-------------------------------------
-- function checkPackage
-------------------------------------
function HackingDetector:checkPackage()
	local t_ret = {}
	local t_running = nil
	local running = nil

	-- getRunningApps함수가 있을 경우에만 적용
	if (getRunningApps) then
		running = getRunningApps()
        cclog('getRunningApps exist!')
		if running then
			t_running = dkjson.decode(running)
		end
	end

	if (t_running) then
        cclog('t_running exist!')
        ccdump(t_running)
		for i, v in ipairs(t_package) do
			if t_running[v] then
				table.insert(t_ret, v)
			end
		end

		for k, v in pairs(t_running) do
			if string.match(k, 'aqua.qq') then
				table.insert(t_ret, k)
			elseif string.match(k, 'aqua.gg') then
				table.insert(t_ret, k)
			elseif string.match(k, 'mon.blue.warcat') then
				table.insert(t_ret, k)
			elseif string.match(k, 'ss.dd') then
				table.insert(t_ret, k)
			elseif string.match(k, 'fuq.gg') then
				table.insert(t_ret, k)
			end
		end
	end

	if #t_ret > 0 then
		self:requestToSnitch({ type = 'hacking_tool', data = t_ret })
		return true
	end

	return false
end

-------------------------------------
-- function requestToSnitch
-------------------------------------
function HackingDetector:requestToSnitch(t)
	local t_ret = t
	if not t_ret then return end

	local package_name = t_ret.type or ''

	local table_name = ''
	if t_ret.data then
		if type(t_ret.data) == 'table' then
			for i,v in ipairs(t_ret.data) do
				local comma = i == 1 and '' or ','
				table_name = table_name .. comma .. v
			end
		else
			table_name = t_ret.data
		end
	end

	if string.len(package_name) <= 0 and string.len(table_name) <= 0 then return end

	-- 유저 ID
    local uid = g_userData:get('uid')

    -- 성공 콜백
    local function success_cb(ret)
        if ret['status'] == 0 then
			self:notice(t_ret)
		else
            msg  = ret['message']
		    MakeSimplePopup(POPUP_TYPE.OK, msg, function() closeApplication() end)
		end
    end

    -- 네트워크 통신
    local ui_network = UI_Network()
    ui_network:setUrl('/users/detect_hack')
    ui_network:setParam('uid', uid)
    ui_network:setParam('package_name', package_name)
    ui_network:setParam('table_name', table_name)
    ui_network:setSuccessCB(success_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()

    return ui_network
end

-------------------------------------
-- function notice
-------------------------------------
function HackingDetector:notice(t)
	local msg = Str('\n\n회원번호가 수집되었으며 지속적인 클라이언트 조작 시도, 관련 파일 배포 등의 행위가 감지될 경우 고소 등 법적 처분의 대상이 될 수 있음을 알려 드립니다. 정상적인 방법으로 재접속해 주시기 바랍니다.')

	if t.type == 'table_local_hack' then
		msg = Str('클라이언트 데이터 파일 변조가 감지되었습니다.') .. msg
		MakeSimplePopup(POPUP_TYPE.OK, msg, function() closeApplication() end)

	elseif t.type == 'table_mem_hack' then
		msg = Str('클라이언트 메모리 변조가 감지되었습니다.') .. msg
		MakeSimplePopup(POPUP_TYPE.OK, msg, function() closeApplication() end)
	else
		msg = Str('불법적인 클라이언트 데이터 조작 프로그램 또는 매크로 프로그램이 감지되었습니다.') .. msg
		MakeSimplePopup(POPUP_TYPE.OK, msg, function() closeApplication() end)
	end
end