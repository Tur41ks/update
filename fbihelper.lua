-- Copyright (c) 2020 Tur41ks Prod.

-- ���������� � �������
script_name('�FBI-Helper�') 		-- ��������� ��� �������
script_version(1.1) 						-- ��������� ������ �������
script_author('Henrich_Rogge') 	-- ��������� ��� ������

-- ����������
require 'lib.moonloader'
require 'lib.sampfuncs'

local lsg, sf               = pcall(require, 'sampfuncs')
local lsampev, sampevents = pcall(require, 'lib.samp.events')
local lencoding, encoding = pcall(require, 'encoding')
local lkey, key           = pcall(require, 'vkeys')
local lmemory, memory     = pcall(require, 'memory')
local lrkeys, rkeys       = pcall(require, 'rkeys')
local limgui, imgui       = pcall(require, 'imgui')
local limadd, imadd       = pcall(require, 'imgui_addons')
local lwm, wm             = pcall(require, 'lib.windows.message')
local llfs, lfs           = pcall(require, 'lfs')
local lpie, pie           = pcall(require, 'imgui_piemenu')

------------------
encoding.default = 'CP1251'
local u8 = encoding.UTF8
dlstatus = require('moonloader').download_status
imgui.ToggleButton = imadd.ToggleButton
imgui.HotKey = imadd.HotKey
------------------

-- ���������� �� ������ ����
tLastKeys = {}
mstype = '' 
targetID = nil
sessionTime = nil

-- Imgui ����������
x, y = getScreenResolution()
wave = imgui.ImBuffer(512)
lectureStatus = 0
show = 6
openPopup = nil

-- ������\�����
data = {
	lecture = {
    string = '',
    list = {},
    text = {},
    time = imgui.ImInt(5000)
	},
	combo = {
    lecture = imgui.ImInt(0)
	},
	shpora = {
    edit = -1,
    loaded = 0,
    page = 0,
    select = {},
    inputbuffer = imgui.ImBuffer(10000),
    search = imgui.ImBuffer(256),
    text = ''
	},
	imgui = {
		inputmodal = imgui.ImBuffer(128)
	},
	filename = '',
}

-- Imgui ����
window = {
	['main'] = { bool = imgui.ImBool(false), cursor = true },
	['shpora'] = { bool = imgui.ImBool(false), cursor = true },
	['binder'] = { bool = imgui.ImBool(false), cursor = false },
	['msk1'] = { bool = imgui.ImBool(false), cursor = true},
	['msk2'] = { bool = imgui.ImBool(false), cursor = true},
	['msk3'] = { bool = imgui.ImBool(false), cursor = true},
	['msk0'] = { bool = imgui.ImBool(false), cursor = true},
}

-- �������
binders = {
	-- ��������� ������
	bindtext    = imgui.ImBuffer(20480),
	bindname    = imgui.ImBuffer(256),
	bindselect  = nil,
	-- ��������� ������
	cmdtext     = imgui.ImBuffer(20480),
	cmdbuf      = imgui.ImBuffer(256),
	cmdparams   = imgui.ImInt(0),
	cmdselect   = nil
}

-- ���������� ���������
sInfo = {
	WorkingDay = false,
	VehicleId = nil,
	AuthTime = nil,
	updateAFK = 0,
	health = nil,
	armour = nil,
	MySkin = nil,
	MyId = nil,
	Nick = ''
}

-- ���������
pInfo = {
	-- �������� ���������
	options = {
		clistb = false,
		clist = 0,
	},
	-- ������� �������
	onlineTimer = {
		date = 0,
		time = tonumber(0),
		workTime = tonumber(0),
		dayAFK = 0
	},
	-- ������� �������, �������.
	dayCounter = {
		arrested = 0,
	}
}

-- ������� �������������\������
config_keys = {
	punaccept = { v = {key.VK_F12}}
}

-- ��������� ������
cmd_binder = {}

-- ��������� ������
tBindList = {}

-- ��� ����������
updatesInfo = {
  version = thisScript().version,
  type = '����', -- �������� ����������, ������������� ����������, ����������� ����������, ����
  date = '19.09.2020',
  list = {
		{ '���������� ����;' }
  }
}

function main()
	-- ��������� �������� �� sampfuncs � SAMP ���� �� ��������� - ��������� ������
	if not isSampfuncsLoaded() or not isSampLoaded() then 
		return 
	end
	-- ��������� ����������, ���� ����� �������
	local directoryes = { 'FBI-Helper', 'FBI-Helper/lectures', 'FBI-Helper/shpores' }
	for k, v in pairs(directoryes) do
		if not doesDirectoryExist('moonloader/'..v) then 
			createDirectory('moonloader/'..v) 
		end
	end
	-- ��������� �������� �� SA-MP
	while not isSampAvailable() do
		wait(0) 
	end
	-- �������� ����������� ����������
	-- ������� �������������
	if not doesFileExist('moonloader/FBI-Helper/keys.json') then
		local file = io.open('moonloader/FBI-Helper/keys.json', 'w')
		file:write(encodeJson(config_keys))
		file:close()
	else
		local file = io.open('moonloader/FBI-Helper/keys.json', 'r')
		config_keys = decodeJson(file:read('*a'))
	end
	saveData(config_keys, 'moonloader/FBI-Helper/keys.json')
	-- ��������� ������
	if doesFileExist('moonloader/FBI-Helper/cmdbinder.json') then
		local file = io.open('moonloader/FBI-Helper/cmdbinder.json', 'r')
		if file then
			cmd_binder = decodeJson(file:read('*a'))
		end
	end
	saveData(cmd_binder, 'moonloader/FBI-Helper/cmdbinder.json')
	-- ��������� �������
	if not doesFileExist('moonloader/FBI-Helper/config.json') then 
    io.open('moonloader/FBI-Helper/config.json', 'w'):close()
  else 
    local file = io.open('moonloader/FBI-Helper/config.json', 'r')
		pInfo = decodeJson(file:read('*a'))
  end
	saveData(pInfo, 'moonloader/FBI-Helper/config.json') 
	-- ��������� ������
	if doesFileExist('moonloader/FBI-Helper/buttonbinder.json') then
		local file = io.open('moonloader/FBI-Helper/buttonbinder.json', 'r')
		if file then
			tBindList = decodeJson(file:read())
		end
	end
	saveData(tBindList, 'moonloader/FBI-Helper/buttonbinder.json')
	for k, v in pairs(tBindList) do
		rkeys.registerHotKey(v.v, true, onHotKey)
		if v.time ~= nil then 
			v.time = nil 
		end
		if v.name == nil then 
			v.name = '����'..k 
		end
		v.text = v.text:gsub('%[enter%]', ''):gsub('{noenter}', '{noe}')
	end
	saveData(tBindList, 'moonloader/FBI-Helper/buttonbinder.json')
	-- ���� ����� ����� ��� - ������� ���� � ���������� ���� ��������� ����������
	if not doesFileExist('moonloader/FBI-Helper/shpores/fisrtshpora.txt') then
		local file = io.open('moonloader/FBI-Helper/shpores/fisrtshpora.txt', 'w')
		file:write('�� ���� ��� �� ��������� �����.\n��� �� �������� ���� ���� ����� ��� ����� ��������� ��� ��������:\n1. ������� ����� FBI-Helper ������� ��������� � ����� moonloader\n2. ������� ���� fisrtshpora.txt ����� ���������\n3. �������� ����� � ��� �� ����� ��� �����\n4. ��������� ����')
		file:close()
	end
	-- ������������ ������� �������������
	punacceptbind = rkeys.registerHotKey(config_keys.punaccept.v, true, punaccept)
	-- ������������ ������� �� �������
	sampRegisterChatCommand('shpora', function()
		window['shpora'].bool.v = not window['shpora'].bool.v
	end)
	sampRegisterChatCommand('sw', function() 
		window['main'].bool.v = not window['main'].bool.v
	end)
	sampRegisterChatCommand('swupd', function()
		local str = '{FFFFFF}���: {2C7AA9}'..updatesInfo.type..'\n{FFFFFF}������ �������: {2C7AA9}'..updatesInfo.version..'\n{FFFFFF}���� ������: {2C7AA9}'..updatesInfo.date..'{FFFFFF}\n\n'
		for i = 1, #updatesInfo.list do
			str = str..'{2C7AA9}-{FFFFFF}'
			for j = 1, #updatesInfo.list[i] do
				str = string.format('%s %s%s\n', str, j > 1 and ' ' or '', updatesInfo.list[i][j]:gsub('``(.-)``', '{2C7AA9}%1{FFFFFF}'))
			end
		end
		sampShowDialog(61315125, '{2C7AA9}FBI-Helper | {FFFFFF}������ ����������', str, '�������', '', DIALOG_STYLE_MSGBOX)
	end)
	sampRegisterChatCommand('msk', function(args)
		local arg = args:match('(%d+)')
		if arg == nil then
			atext('/msk [���] 1 - ���� | 2 - �������� | 3 - ����� | 4 - ����� ����������')
			return
		end
		args = string.split(args, ' ')
		if arg == '1' then
			window['msk1'].bool.v = not window['msk1'].bool.v	
		elseif arg == '2' then
			window['msk2'].bool.v = not window['msk2'].bool.v	
		elseif arg == '3' then
			window['msk3'].bool.v = not window['msk3'].bool.v	
		elseif arg == '4' then
			lua_thread.create(function()
				sampSendChat('/me ���� � ���� ����������')
				wait(4000)
				sampSendChat('/me ����� �� ���� ������ ������')
				wait(4000)
				sampSendChat('/r ���������� � ������ ������')
				wait(1000)
				sampSendChat(string.format('/rb %s', sInfo.MyId))
			end)
		end
	end)
	sampRegisterChatCommand('cn', function(args)
		if #args == 0 then 
			atext('�������: /cn [id] [0 - RP nick, 1 - NonRP nick]') 
			return 
		end
		args = string.split(args, ' ')
		if #args == 1 then
			local getID = tonumber(args[1])
			if getID == nil then 
				stext('�������� ID ������!') 
				return 
			end
			if not sampIsPlayerConnected(getID) then 
				stext('����� �������!') 
				return 
			end 
			getID = sampGetPlayerNickname(getID)
			getID = string.gsub(getID, '_', ' ')
			stext(('�� ��� {2C7AA9}%s {FFFFFF}���������� � ����� ������.'):format(getID))
			setClipboardText(getID)
		elseif #args == 2 then
			local getID = tonumber(args[1])
			if getID == nil then 
				stext('�������� ID ������!') 
				return 
			end
			if not sampIsPlayerConnected(getID) then 
				stext('����� �������!') 
				return 
			end 
			getID = sampGetPlayerNickname(getID)
			if tonumber(args[2]) == 1 then
				stext(('����� ��� {2C7AA9}%s {FFFFFF}���������� � ����� ������.'):format(getID))
			else
				getID = string.gsub(getID, '_', ' ')
				stext(('�� ��� {2C7AA9}%s {FFFFFF}���������� � ����� ������.'):format(getID))
			end
			setClipboardText(getID)
		else
			atext('�������: /cn [id] [0 - RP nick, 1 - NonRP nick]')
			return
		end 
	end)
	-- ��������� ���������� ���������
	-- ��������� ����� �� ����� �� ������
	while not sampIsLocalPlayerSpawned() do 
		wait(0) 
	end
	sInfo.MyId = select(2, sampGetPlayerIdByCharHandle(PLAYER_PED))
	sInfo.Nick = sampGetPlayerNickname(sInfo.MyId)
	sInfo.updateAFK = os.time()
	sInfo.AuthTime = os.date('%d.%m.%y %H:%M:%S') 
	-- �������������� �������
	registerCommandsBinder()
	apply_custom_style()
	onlineTimer()
	update()
	-- ����� ���������������� �� ������� �� ��������, ��� ������ ��������
	stext('������ ������� ��������! ������� ���� ������� - /sw')
	-- ���������� �������� ������ 24 ����
	if os.date('%a') ~= pInfo.onlineTimer.date and tonumber(os.date('%H')) > 4 then
		pInfo.onlineTimer.date = os.date('%a')
		pInfo.onlineTimer.time = tonumber(0)
		pInfo.onlineTimer.dayAFK = tonumber(0)
		pInfo.onlineTimer.workTime = tonumber(0)
		pInfo.dayCounter.arrested = tonumber(0)
		saveData(pInfo, 'moonloader/FBI-Helper/config.json') 
	end
	-- ����������� ����
	while true do 
		wait(0)
		-- ��������� ���� ������ ���������, � ����������� �������� � ����������
		sInfo.MySkin = getCharModel(PLAYER_PED)
		if sInfo.MySkin == 286 or sInfo.MySkin == 141 or sInfo.MySkin == 163 or sInfo.MySkin == 164 or sInfo.MySkin == 165 or sInfo.MySkin == 166 then 
			sInfo.WorkingDay = true
		else
			sInfo.WorkingDay = false
		end
		-- Imgui ����
		local ImguiWindowSettings = {false, false}
		for k, settings in pairs(window) do
			if settings.bool.v and ImguiWindowSettings[1] == false then
				imgui.Process = true
				ImguiWindowSettings[1] = true
			end
			if settings.bool.v and settings.cursor and ImguiWindowSettings[2] == false then
				imgui.ShowCursor = true
				ImguiWindowSettings[2] = true
			end
		end
		if ImguiWindowSettings[1] == false then
			imgui.Process = false
		end
		if ImguiWindowSettings[2] == false then
			imgui.ShowCursor = false
		end
    -- ��������� ���� �� �
    if isKeyJustPressed(VK_T) and not sampIsDialogActive() and not sampIsScoreboardOpen() and not isSampfuncsConsoleActive() then
      sampSetChatInputEnabled(true)
		end
		-- ������ � ���������� id ����������
		if isCharInAnyCar(PLAYER_PED) then 
			sInfo.VehicleId = select(2, sampGetVehicleIdByCarHandle(storeCarCharIsInNoSave(PLAYER_PED))) 
		end
  end
end

function imgui.OnDrawFrame()
	-- ���� ����������
	if window['msk1'].bool.v then
		-- ������������� ������ ����
 		imgui.SetNextWindowSize(imgui.ImVec2(305, 610), imgui.Cond.FirstUseEver)
		imgui.SetNextWindowPos(imgui.ImVec2(x / 2, y / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		-- ��������� ���� � ��������� ��� 
		imgui.Begin(u8(thisScript().name..' | ���� ���������� | Version: '..thisScript().version), window['msk1'].bool, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize)
		local btn_size = imgui.ImVec2(275, 25)
		if imgui.Button(u8('�����������'), btn_size) then
			lua_thread.create(function()
				sampSendChat('/me ���� � ���� ������ ������ � ������� �� �������')
				wait(4000)
				sampSendChat('/me ������ ����, ����� ���� ������ �������� ����������')
				wait(4000)
				sampSendChat('/me ����� �� ���� ���������� � ������ ����')
				wait(4000)
				sampSendChat('/do ����� � ����������.')
				wait(1400)
				sampSendChat('/r ���������� � ���������� �����������.')
				wait(1400)
				sampSendChat(string.format('/rb %s', sInfo.MyId))
			end)
		end
		if imgui.Button(u8('�����������'), btn_size) then
			imgui.OpenPopup('Grazdanka')
			mstype = '������������'
		end
		if imgui.Button(u8('�������'), btn_size) then
			imgui.OpenPopup('Police')
			mstype = '������������'
		end
		if imgui.Button(u8('�����'), btn_size) then
			imgui.OpenPopup('Army')
			mstype = '��������'
		end
		if imgui.Button(u8('���'), btn_size) then
			imgui.OpenPopup('MOH')
			mstype = '������'
		end
		if imgui.Button(u8('�����'), btn_size) then
			imgui.OpenPopup('Meria')
			mstype = '���������� �����'
		end
		if imgui.Button(u8('���������'), btn_size) then
			imgui.OpenPopup('Autoschool')
			mstype = '��������� ���������'
		end
		if imgui.Button(u8('�������'), btn_size) then
			imgui.OpenPopup('News')
			mstype = '��������� ��������'
		end
		if imgui.Button(u8('LCN'), btn_size) then
			imgui.OpenPopup('LCN')
			mstype = '��� LCN'
		end
		if imgui.Button(u8('Yakuza'), btn_size) then
			imgui.OpenPopup('Yakuza')
			mstype = '��� Yakuza'
		end
		if imgui.Button(u8('Russian Mafia'), btn_size) then
			imgui.OpenPopup('Russian Mafia')
			mstype = '��� Russian Mafia'
		end
		if imgui.Button(u8('Rifa'), btn_size) then
			imgui.OpenPopup('Rifa')
			mstype = '�� Rifa'
		end
		if imgui.Button(u8('Grove'), btn_size) then
			imgui.OpenPopup('Grove')
			mstype = '�� Grove'
		end
		if imgui.Button(u8('Vagos'), btn_size) then
			imgui.OpenPopup('Vagos')
			mstype = '�� Vagos'
		end
		if imgui.Button(u8('Ballas'), btn_size) then
			imgui.OpenPopup('Ballas')
			mstype = '�� Ballas'
		end
		if imgui.Button(u8('Aztec'), btn_size) then
			imgui.OpenPopup('Aztec')
			mstype = '�� Aztec'
		end
		if imgui.Button(u8('�������'), btn_size) then
			imgui.OpenPopup('Bikers')
			mstype = '��������'
		end
		if imgui.BeginPopupModal(u8('Grazdanka'), _, imgui.WindowFlags.AlwaysAutoResize) or 
		imgui.BeginPopupModal(u8('Police'), _, imgui.WindowFlags.AlwaysAutoResize) or  
		imgui.BeginPopupModal(u8('Army'), _, imgui.WindowFlags.AlwaysAutoResize) or  
		imgui.BeginPopupModal(u8('MOH'), _, imgui.WindowFlags.AlwaysAutoResize) or  
		imgui.BeginPopupModal(u8('Meria'), _, imgui.WindowFlags.AlwaysAutoResize) or  
		imgui.BeginPopupModal(u8('Autoschool'), _, imgui.WindowFlags.AlwaysAutoResize) or  
		imgui.BeginPopupModal(u8('News'), _, imgui.WindowFlags.AlwaysAutoResize) or  
		imgui.BeginPopupModal(u8('LCN'), _, imgui.WindowFlags.AlwaysAutoResize) or  
		imgui.BeginPopupModal(u8('Yakuza'), _, imgui.WindowFlags.AlwaysAutoResize) or  
		imgui.BeginPopupModal(u8('Russian Mafia'), _, imgui.WindowFlags.AlwaysAutoResize) or  
		imgui.BeginPopupModal(u8('Rifa'), _, imgui.WindowFlags.AlwaysAutoResize) or  
		imgui.BeginPopupModal(u8('Grazdanka'), _, imgui.WindowFlags.AlwaysAutoResize) or  
		imgui.BeginPopupModal(u8('Grove'), _, imgui.WindowFlags.AlwaysAutoResize) or  
		imgui.BeginPopupModal(u8('Vagos'), _, imgui.WindowFlags.AlwaysAutoResize) or  
		imgui.BeginPopupModal(u8('Ballas'), _, imgui.WindowFlags.AlwaysAutoResize) or  
		imgui.BeginPopupModal(u8('Aztec'), _, imgui.WindowFlags.AlwaysAutoResize) or  
		imgui.BeginPopupModal(u8('Bikers'), _, imgui.WindowFlags.AlwaysAutoResize) then
			imgui.Text(u8('������� �������'))
			imgui.Spacing()
			imgui.InputText('##inputtext', data.imgui.inputmodal)
			imgui.Spacing()
			imgui.Separator()
			imgui.Spacing()
			if imgui.Button(u8('���������'), imgui.ImVec2(120, 30)) then
				local input = u8:decode(data.imgui.inputmodal.v)
				lua_thread.create(function()
					sampSendChat('/me ���� � ���� ������ ������ � ������� �� �������')
					wait(4000)
					sampSendChat('/me ������ ����, ����� ���� ������ �������� ����������')
					wait(4000)
					sampSendChat('/me ����� �� ���� ���������� � ������ ����')
					wait(4000)
					sampSendChat('/do ����� � ����������.')
					wait(1400)
					sampSendChat(string.format('/r ����������	� ����� %s. �������: %s', mstype, input))
					wait(1400)
					sampSendChat(string.format('/rb %s', sInfo.MyId))
				end)
				dialogCursor = false
				imgui.CloseCurrentPopup()
			end
			imgui.SameLine()
			if imgui.Button(u8('�������'), imgui.ImVec2(120, 30)) then
				dialogCursor = false
				data.imgui.inputmodal = ''
				imgui.CloseCurrentPopup()
			end
			imgui.EndPopup()
		end
		imgui.End()
	end
	if window['msk2'].bool.v then
		-- ������������� ������ ����
 		imgui.SetNextWindowSize(imgui.ImVec2(305, 610), imgui.Cond.FirstUseEver)
		imgui.SetNextWindowPos(imgui.ImVec2(x / 2, y / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		-- ��������� ���� � ��������� ��� 
		imgui.Begin(u8(thisScript().name..' | ���� ���������� | Version: '..thisScript().version), window['msk2'].bool, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize)
		local btn_size = imgui.ImVec2(275, 25)
		if imgui.Button(u8('�����������'), btn_size) then
			lua_thread.create(function()
				sampSendChat('/me ������ �������� ����������')
				wait(4000)
				sampSendChat('/me ���� � ���� ������ ������ � ����� � ��������')
				wait(4000)
				sampSendChat('/me ������ �� ��������� �������� ���������� ������ �� ����')
				wait(4000)
				sampSendChat('/me ������ ��������')
				wait(4000)
				sampSendChat('/do ����� � ����������.')
				wait(1400)
				sampSendChat('/r ���������� � ���������� �����������.')
				wait(1400)
				sampSendChat(string.format('/rb %s', sInfo.MyId))
			end)
		end
		if imgui.Button(u8('�����������'), btn_size) then
			imgui.OpenPopup('Grazdanka')
			mstype = '������������'
		end
		if imgui.Button(u8('�������'), btn_size) then
			imgui.OpenPopup('Police')
			mstype = '������������'
		end
		if imgui.Button(u8('�����'), btn_size) then
			imgui.OpenPopup('Army')
			mstype = '��������'
		end
		if imgui.Button(u8('���'), btn_size) then
			imgui.OpenPopup('MOH')
			mstype = '������'
		end
		if imgui.Button(u8('�����'), btn_size) then
			imgui.OpenPopup('Meria')
			mstype = '���������� �����'
		end
		if imgui.Button(u8('���������'), btn_size) then
			imgui.OpenPopup('Autoschool')
			mstype = '��������� ���������'
		end
		if imgui.Button(u8('�������'), btn_size) then
			imgui.OpenPopup('News')
			mstype = '��������� ��������'
		end
		if imgui.Button(u8('LCN'), btn_size) then
			imgui.OpenPopup('LCN')
			mstype = '��� LCN'
		end
		if imgui.Button(u8('Yakuza'), btn_size) then
			imgui.OpenPopup('Yakuza')
			mstype = '��� Yakuza'
		end
		if imgui.Button(u8('Russian Mafia'), btn_size) then
			imgui.OpenPopup('Russian Mafia')
			mstype = '��� Russian Mafia'
		end
		if imgui.Button(u8('Rifa'), btn_size) then
			imgui.OpenPopup('Rifa')
			mstype = '�� Rifa'
		end
		if imgui.Button(u8('Grove'), btn_size) then
			imgui.OpenPopup('Grove')
			mstype = '�� Grove'
		end
		if imgui.Button(u8('Vagos'), btn_size) then
			imgui.OpenPopup('Vagos')
			mstype = '�� Vagos'
		end
		if imgui.Button(u8('Ballas'), btn_size) then
			imgui.OpenPopup('Ballas')
			mstype = '�� Ballas'
		end
		if imgui.Button(u8('Aztec'), btn_size) then
			imgui.OpenPopup('Aztec')
			mstype = '�� Aztec'
		end
		if imgui.Button(u8('�������'), btn_size) then
			imgui.OpenPopup('Bikers')
			mstype = '��������'
		end
		if imgui.BeginPopupModal(u8('Grazdanka'), _, imgui.WindowFlags.AlwaysAutoResize) or 
		imgui.BeginPopupModal(u8('Police'), _, imgui.WindowFlags.AlwaysAutoResize) or  
		imgui.BeginPopupModal(u8('Army'), _, imgui.WindowFlags.AlwaysAutoResize) or  
		imgui.BeginPopupModal(u8('MOH'), _, imgui.WindowFlags.AlwaysAutoResize) or  
		imgui.BeginPopupModal(u8('Meria'), _, imgui.WindowFlags.AlwaysAutoResize) or  
		imgui.BeginPopupModal(u8('Autoschool'), _, imgui.WindowFlags.AlwaysAutoResize) or  
		imgui.BeginPopupModal(u8('News'), _, imgui.WindowFlags.AlwaysAutoResize) or  
		imgui.BeginPopupModal(u8('LCN'), _, imgui.WindowFlags.AlwaysAutoResize) or  
		imgui.BeginPopupModal(u8('Yakuza'), _, imgui.WindowFlags.AlwaysAutoResize) or  
		imgui.BeginPopupModal(u8('Russian Mafia'), _, imgui.WindowFlags.AlwaysAutoResize) or  
		imgui.BeginPopupModal(u8('Rifa'), _, imgui.WindowFlags.AlwaysAutoResize) or  
		imgui.BeginPopupModal(u8('Grazdanka'), _, imgui.WindowFlags.AlwaysAutoResize) or  
		imgui.BeginPopupModal(u8('Grove'), _, imgui.WindowFlags.AlwaysAutoResize) or  
		imgui.BeginPopupModal(u8('Vagos'), _, imgui.WindowFlags.AlwaysAutoResize) or  
		imgui.BeginPopupModal(u8('Ballas'), _, imgui.WindowFlags.AlwaysAutoResize) or  
		imgui.BeginPopupModal(u8('Aztec'), _, imgui.WindowFlags.AlwaysAutoResize) or  
		imgui.BeginPopupModal(u8('Bikers'), _, imgui.WindowFlags.AlwaysAutoResize) then
			imgui.Text(u8('������� �������'))
			imgui.Spacing()
			imgui.InputText('##inputtext', data.imgui.inputmodal)
			imgui.Spacing()
			imgui.Separator()
			imgui.Spacing()
			if imgui.Button(u8('���������'), imgui.ImVec2(120, 30)) then
				local input = u8:decode(data.imgui.inputmodal.v)
				lua_thread.create(function()
					sampSendChat('/me ������ �������� ����������')
					wait(4000)
					sampSendChat('/me ���� � ���� ������ ������ � ����� � ��������')
					wait(4000)
					sampSendChat('/me ������ �� ��������� �������� ���������� ������ �� ����')
					wait(4000)
					sampSendChat('/me ������ ��������')
					wait(4000)
					sampSendChat('/do ����� � ����������.')
					wait(1400)
					sampSendChat(string.format('/r ����������	� ����� %s. �������: %s', mstype, input))
					wait(1400)
					sampSendChat(string.format('/rb %s', sInfo.MyId))
				end)
				dialogCursor = false
				imgui.CloseCurrentPopup()
			end
			imgui.SameLine()
			if imgui.Button(u8('�������'), imgui.ImVec2(120, 30)) then
				dialogCursor = false
				data.imgui.inputmodal = ''
				imgui.CloseCurrentPopup()
			end
			imgui.EndPopup()
		end
		imgui.End()
	end
	if window['msk3'].bool.v then
		-- ������������� ������ ����
 		imgui.SetNextWindowSize(imgui.ImVec2(305, 610), imgui.Cond.FirstUseEver)
		imgui.SetNextWindowPos(imgui.ImVec2(x / 2, y / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		-- ��������� ���� � ��������� ��� 
		imgui.Begin(u8(thisScript().name..' | ���� ���������� | Version: '..thisScript().version), window['msk3'].bool, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize)
		local btn_size = imgui.ImVec2(275, 25)
		if imgui.Button(u8('�����������'), btn_size) then
			lua_thread.create(function()
				sampSendChat('/do �� ����� ������ ����� �����.')
				wait(4000)
				sampSendChat('/me ������ �����, ���� ������ ������ � ����� ����')
				wait(4000)
				sampSendChat('/me ������ �� ����� �������� ���������� � ����� �� ����')
				wait(4000)
				sampSendChat('/me ������ �����')
				wait(4000)
				sampSendChat('/do ����� � ����������.')
				wait(1400)
				sampSendChat('/r ���������� � ���������� �����������.')
				wait(1400)
				sampSendChat(string.format('/rb %s', sInfo.MyId))
			end)
		end
		if imgui.Button(u8('�����������'), btn_size) then
			imgui.OpenPopup('Grazdanka')
			mstype = '������������'
		end
		if imgui.Button(u8('�������'), btn_size) then
			imgui.OpenPopup('Police')
			mstype = '������������'
		end
		if imgui.Button(u8('�����'), btn_size) then
			imgui.OpenPopup('Army')
			mstype = '��������'
		end
		if imgui.Button(u8('���'), btn_size) then
			imgui.OpenPopup('MOH')
			mstype = '������'
		end
		if imgui.Button(u8('�����'), btn_size) then
			imgui.OpenPopup('Meria')
			mstype = '���������� �����'
		end
		if imgui.Button(u8('���������'), btn_size) then
			imgui.OpenPopup('Autoschool')
			mstype = '��������� ���������'
		end
		if imgui.Button(u8('�������'), btn_size) then
			imgui.OpenPopup('News')
			mstype = '��������� ��������'
		end
		if imgui.Button(u8('LCN'), btn_size) then
			imgui.OpenPopup('LCN')
			mstype = '��� LCN'
		end
		if imgui.Button(u8('Yakuza'), btn_size) then
			imgui.OpenPopup('Yakuza')
			mstype = '��� Yakuza'
		end
		if imgui.Button(u8('Russian Mafia'), btn_size) then
			imgui.OpenPopup('Russian Mafia')
			mstype = '��� Russian Mafia'
		end
		if imgui.Button(u8('Rifa'), btn_size) then
			imgui.OpenPopup('Rifa')
			mstype = '�� Rifa'
		end
		if imgui.Button(u8('Grove'), btn_size) then
			imgui.OpenPopup('Grove')
			mstype = '�� Grove'
		end
		if imgui.Button(u8('Vagos'), btn_size) then
			imgui.OpenPopup('Vagos')
			mstype = '�� Vagos'
		end
		if imgui.Button(u8('Ballas'), btn_size) then
			imgui.OpenPopup('Ballas')
			mstype = '�� Ballas'
		end
		if imgui.Button(u8('Aztec'), btn_size) then
			imgui.OpenPopup('Aztec')
			mstype = '�� Aztec'
		end
		if imgui.Button(u8('�������'), btn_size) then
			imgui.OpenPopup('Bikers')
			mstype = '��������'
		end
		if imgui.BeginPopupModal(u8('Grazdanka'), _, imgui.WindowFlags.AlwaysAutoResize) or 
		imgui.BeginPopupModal(u8('Police'), _, imgui.WindowFlags.AlwaysAutoResize) or  
		imgui.BeginPopupModal(u8('Army'), _, imgui.WindowFlags.AlwaysAutoResize) or  
		imgui.BeginPopupModal(u8('MOH'), _, imgui.WindowFlags.AlwaysAutoResize) or  
		imgui.BeginPopupModal(u8('Meria'), _, imgui.WindowFlags.AlwaysAutoResize) or  
		imgui.BeginPopupModal(u8('Autoschool'), _, imgui.WindowFlags.AlwaysAutoResize) or  
		imgui.BeginPopupModal(u8('News'), _, imgui.WindowFlags.AlwaysAutoResize) or  
		imgui.BeginPopupModal(u8('LCN'), _, imgui.WindowFlags.AlwaysAutoResize) or  
		imgui.BeginPopupModal(u8('Yakuza'), _, imgui.WindowFlags.AlwaysAutoResize) or  
		imgui.BeginPopupModal(u8('Russian Mafia'), _, imgui.WindowFlags.AlwaysAutoResize) or  
		imgui.BeginPopupModal(u8('Rifa'), _, imgui.WindowFlags.AlwaysAutoResize) or  
		imgui.BeginPopupModal(u8('Grazdanka'), _, imgui.WindowFlags.AlwaysAutoResize) or  
		imgui.BeginPopupModal(u8('Grove'), _, imgui.WindowFlags.AlwaysAutoResize) or  
		imgui.BeginPopupModal(u8('Vagos'), _, imgui.WindowFlags.AlwaysAutoResize) or  
		imgui.BeginPopupModal(u8('Ballas'), _, imgui.WindowFlags.AlwaysAutoResize) or  
		imgui.BeginPopupModal(u8('Aztec'), _, imgui.WindowFlags.AlwaysAutoResize) or  
		imgui.BeginPopupModal(u8('Bikers'), _, imgui.WindowFlags.AlwaysAutoResize) then
			imgui.Text(u8('������� �������'))
			imgui.Spacing()
			imgui.InputText('##inputtext', data.imgui.inputmodal)
			imgui.Spacing()
			imgui.Separator()
			imgui.Spacing()
			if imgui.Button(u8('���������'), imgui.ImVec2(120, 30)) then
				local input = u8:decode(data.imgui.inputmodal.v)
				lua_thread.create(function()
					sampSendChat('/do �� ����� ������ ����� �����.')
					wait(4000)
					sampSendChat('/me ������ �����, ���� ������ ������ � ����� ����')
					wait(4000)
					sampSendChat('/me ������ �� ����� �������� ���������� � ����� �� ����')
					wait(4000)
					sampSendChat('/me ������ �����')
					wait(4000)
					sampSendChat('/do ����� � ����������.')
					wait(1400)
					sampSendChat(string.format('/r ����������	� ����� %s. �������: %s', mstype, input))
					wait(1400)
					sampSendChat(string.format('/rb %s', sInfo.MyId))
				end)
				dialogCursor = false
				imgui.CloseCurrentPopup()
			end
			imgui.SameLine()
			if imgui.Button(u8('�������'), imgui.ImVec2(120, 30)) then
				dialogCursor = false
				data.imgui.inputmodal = ''
				imgui.CloseCurrentPopup()
			end
			imgui.EndPopup()
		end
		imgui.End()
	end
	-- �������� imgui ����
	if window['main'].bool.v then
		-- ������������� ������ ����
 		imgui.SetNextWindowSize(imgui.ImVec2(700, 400), imgui.Cond.FirstUseEver)
		imgui.SetNextWindowPos(imgui.ImVec2(x / 2, y / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		-- ��������� ���� � ��������� ��� 
		imgui.Begin(u8(thisScript().name..' | ������� ���� | Version: '..thisScript().version), window['main'].bool, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.MenuBar + imgui.WindowFlags.NoResize)
		-- ��������� ����
		if imgui.BeginMenuBar() then
			if imgui.BeginMenu(u8('��������')) then
				if imgui.MenuItem(u8('������� ����')) then
					binderclose()
					show = 6
				elseif imgui.MenuItem(u8('���������')) then
					binderclose()
					show = 1 
				end
				imgui.EndMenu()
			end
			if imgui.BeginMenu(u8('��������')) then
				if imgui.MenuItem(u8('������')) then
					binderclose()
					show = 2
				elseif imgui.MenuItem(u8('������ ���. �����')) then
					binderclose()
					show = 10 
				end
				imgui.EndMenu()
			end
			if imgui.BeginMenu(u8('��������')) then
				if imgui.MenuItem(u8('�����')) then 
					window['shpora'].bool.v = not window['shpora'].bool.v
				elseif imgui.MenuItem(u8('������')) then
					window['binder'].bool.v = true
					show = 4
				end
				imgui.EndMenu()
			end
			if imgui.BeginMenu(u8('����������')) then
				if imgui.MenuItem(u8('������')) then
					binderclose()
					show = 3
				elseif imgui.MenuItem(u8('�������')) then
					binderclose()
					show = 7
				end
				imgui.EndMenu()
			end
			if imgui.BeginMenu(u8('���������')) then
				if imgui.MenuItem(u8('������������� ������')) then
					lua_thread.create(function()
						stext('���������������...')
						binderclose()
						window['main'].bool.v = not window['main'].bool.v
						wait(1000)
						thisScript():reload()
					end)
				end
				if imgui.MenuItem(u8('��������� ������')) then
					lua_thread.create(function()
						stext('�������� ������...')
						binderclose()
						window['main'].bool.v = not window['main'].bool.v
						wait(1000)
						stext('������ ������� ��������!')
						thisScript():unload()
					end)
				end
				imgui.EndMenu()
			end
			imgui.EndMenuBar()
		end
		if show == 1 then
			local clistb 			= imgui.ImBool(pInfo.options.clistb)
			local clistbuffer = imgui.ImInt(pInfo.options.clist)
			-- ������� ��������� ����-������
			if imgui.BeginChild('##2', imgui.ImVec2(320, 90)) then
				imgui.CentrText(u8('��������� ����-������'))
				if imgui.ToggleButton(u8('������������ ����-�����'), clistb) then 
					pInfo.options.clistb = not pInfo.options.clistb
					saveData(pInfo, 'moonloader/FBI-Helper/config.json') 
				end; imgui.SameLine(); imgui.Text(u8('������������ ����-�����')); imgui.SameLine(); imgui.TextQuestion(u8('� ������� �� ���������'))
				if clistb.v then
					imgui.PushItemWidth(195)
					if imgui.SliderInt(u8('�������� ��������'), clistbuffer, 0, 33) then 
						pInfo.options.clist = clistbuffer.v
						saveData(pInfo, 'moonloader/FBI-Helper/config.json') 
					end
				end
				imgui.EndChild()
			end
			imgui.SameLine()
			if imgui.BeginChild('##10312', imgui.ImVec2(345, 100)) then
				if imgui.HotKey('##punaccept', config_keys.punaccept, tLastKeys, 50) then
					rkeys.changeHotKey(punacceptbind, config_keys.punaccept.v)
					stext('������� ������� ��������!')
					saveData(config_keys, 'moonloader/FBI-Helper/keys.json')
				end; imgui.SameLine(); imgui.Text(u8('������� �������������'))
				imgui.EndChild()
			end
		elseif show == 2 then
			imgui.PushItemWidth(150)
			if data.lecture.string == '' then
				-- ��������� ������ ������ � �������� � �������
				data.combo.lecture.v = 0
				data.lecture.list = {}
				data.lecture.string = u8('�� �������\0')
				for file in lfs.dir(getWorkingDirectory()..'\\FBI-Helper\\lectures') do
					if file ~= '.' and file ~= '..' then
						local attr = lfs.attributes(getWorkingDirectory()..'\\FBI-Helper\\lectures\\'..file)
						if attr.mode == 'file' then 
							table.insert(data.lecture.list, file)
							data.lecture.string = data.lecture.string..u8:encode(file)..'\0'
						end
					end
				end
				if #data.lecture.list == 0 then
					name = 'firstlecture.txt'
					local file = io.open('moonloader/FBI-Helper/lectures/firstlecture.txt', 'w+')
					file:write('������� ���������\n/s ��������� � ������\n/b ��������� � b ���\n/rb ��������� � �����\n/w ��������� �������')
					file:flush()
					file:close()
					file = nil
				end
				data.lecture.string = data.lecture.string..'\0'
			end
			imgui.Columns(2, _, false)
			imgui.SetColumnWidth(-1, 200)
			imgui.Text(u8('�������� ���� ������'))
			imgui.Combo('##lec', data.combo.lecture, data.lecture.string)
			if imgui.Button(u8('��������� ������')) then
				if data.combo.lecture.v > 0 then
					local file = io.open('moonloader/FBI-Helper/lectures/'..data.lecture.list[data.combo.lecture.v], 'r+')
					if file == nil then 
						atext('���� �� ������!')
					else
						data.lecture.text = {} 
						for line in io.lines('moonloader/FBI-Helper/lectures/'..data.lecture.list[data.combo.lecture.v]) do
							table.insert(data.lecture.text, line)
						end
						if #data.lecture.text > 0 then
							atext('���� ������ ������� ��������!')
						else 
							atext('���� ������ ����!') 
						end
					end
					file:close()
					file = nil
				else 
					atext('�������� ���� ������!') 
				end
			end
			imgui.NextColumn()
			imgui.PushItemWidth(200)
			imgui.Text(u8('�������� �������� (� �������������)'))
			imgui.InputInt('##inputlec', data.lecture.time)
			if lectureStatus == 0 then
				if imgui.Button(u8('��������� ������')) then
					if #data.lecture.text == 0 then 
						stext('���� ������ �� ��������!') 
						return 
					end
					if data.lecture.time.v == 0 then 
						stext('����� �� ����� ���� ����� 0!') 
						return 
					end
					if lectureStatus ~= 0 then 
						stext('������ ��� ��������/�� �����.') 
						return 
					end
					local ltext = data.lecture.text
					local ltime = data.lecture.time.v
					atext('����� ������ �������.')
					lectureStatus = 1
					lua_thread.create(function()
						while true do
							if lectureStatus == 0 then 
								break 
							end
							if lectureStatus >= 1 then
								sampSendChat(ltext[lectureStatus])
								lectureStatus = lectureStatus + 1
							end
							if lectureStatus > #ltext then
								wait(150)
								lectureStatus = 0
								stext('����� ������ ��������.')
								break 
							end
							wait(tonumber(ltime))
						end
					end)
				end
			else
				if imgui.Button(u8:encode(string.format('%s', lectureStatus > 0 and '�����' or '�����������'))) then
					if lectureStatus == 0 then 
						stext('������ �� ��������.') 
						return 
					end
					lectureStatus = lectureStatus * -1
					if lectureStatus > 0 then 
						stext('������ ������������.')
					else 
						stext('������ ��������������.') 
					end
				end
				imgui.SameLine()
				if imgui.Button(u8('����')) then
					if lectureStatus == 0 then 
						stext('������ �� ��������.') 
						return 
					end
					lectureStatus = 0
					stext('����� ������ ���������.')
				end
			end
			imgui.NextColumn()
			imgui.Columns(1)
			imgui.Separator()
			imgui.Text(u8('���������� ����� ������:'))
			imgui.Spacing()
			if #data.lecture.text == 0 then 
				imgui.Text(u8('���� �� ��������/����!')) 
			end
			for i = 1, #data.lecture.text do
				imgui.Text(u8:encode(data.lecture.text[i]))
			end
		elseif show == 3 then
			imgui.NewLine()
			imgui.NewLine()
			imgui.NewLine()
			imgui.NewLine()
			imgui.CentrText('Script Version: '..thisScript().version)
			imgui.NewLine()
			imgui.CentrText(u8('�����������: Henrich Rogge'))
			imgui.CentrText(u8('������: Bernhard Rogge'))
			imgui.CentrText(u8('������: Henrich Rogge and Bernhard Rogge'))
		elseif show == 4 then
			if imgui.BeginChild('##commandlist', imgui.ImVec2(170, 290)) then
				for k, v in pairs(cmd_binder) do
					if imgui.Selectable(u8(('/%s##%s'):format(v.cmd, k)), binders.cmdselect == k) then 
						binders.cmdselect = k 
						binders.cmdbuf.v = u8(v.cmd) 
						binders.cmdparams.v = v.params
						binders.cmdtext.v = u8(v.text)
					end
				end
				imgui.EndChild()
			end
			imgui.SameLine()
			if imgui.BeginChild('##cmd_binderetting', imgui.ImVec2(500, 290)) then
				for k, v in pairs(cmd_binder) do
					if binders.cmdselect == k then
						if imgui.BeginChild('##������', imgui.ImVec2(110, 50)) then
							imgui.PushItemWidth(105)
							imgui.Text(u8('������� �������:'))
							imgui.InputText(u8('##������� �������'), binders.cmdbuf)
						 	imgui.EndChild()
						end
						imgui.SameLine()
						if imgui.BeginChild('##casd', imgui.ImVec2(170, 50)) then
							imgui.PushItemWidth(165)
							imgui.Text(u8('������� ���-�� ����������:'))
							imgui.InputInt(u8('##����� ���-�� ����������'), binders.cmdparams, 0)
							imgui.EndChild()
						end
						imgui.Text(u8('������� ����� �������:'))
						imgui.InputTextMultiline(u8('##cmdtext'), binders.cmdtext, imgui.ImVec2(470, 175))
						if imgui.Button(u8('��������� �������'), imgui.ImVec2(130, 25)) then
							sampUnregisterChatCommand(v.cmd)
							v.cmd = u8:decode(binders.cmdbuf.v)
							v.params = binders.cmdparams.v
							v.text = u8:decode(binders.cmdtext.v)
							saveData(cmd_binder, 'moonloader/FBI-Helper/cmdbinder.json')
							registerCommandsBinder()
							stext('������� ������� ���������!')
						end
						imgui.SameLine()
						if imgui.Button(u8('������� �������##')..k, imgui.ImVec2(130, 25)) then
							sampUnregisterChatCommand(v.cmd)
							binders.cmdselect = nil
							binders.cmdbuf.v = ''
							binders.cmdparams.v = 0
							binders.cmdtext.v = ''
							table.remove(cmd_binder, k)
							saveData(cmd_binder, 'moonloader/FBI-Helper/cmdbinder.json')
							registerCommandsBinder()
							stext('������� ������� �������!')
						end
					end
				end
				imgui.EndChild()
			end
			if imgui.Button(u8('�������� �������'), imgui.ImVec2(170, 25)) then
				table.insert(cmd_binder, {cmd = '', params = 0, text = ''})
				saveData(cmd_binder, 'moonloader/FBI-Helper/cmdbinder.json')
			end
			imgui.SameLine(564)
			if imgui.Button(u8('��������� ������')) then
				show = 5
			end
		elseif show == 5 then
			imgui.BeginChild('##bindlist', imgui.ImVec2(170, 290))
			for k, v in ipairs(tBindList) do
				if imgui.Selectable(u8('')..u8:encode(v.name)) then 
					binders.bindselect = k
					binders.bindname.v = u8(v.name) 
					binders.bindtext.v = u8(v.text)
				end
			end
			imgui.EndChild()
			imgui.SameLine()
			if imgui.BeginChild('##editbind', imgui.ImVec2(500, 290)) then
				for k, v in ipairs(tBindList) do 
					if binders.bindselect == k then
						if imgui.BeginChild('##cmbdas', imgui.ImVec2(155, 50)) then
							imgui.PushItemWidth(150)
							imgui.Text(u8('������� �������� �����:'))
							imgui.InputText('##������� �������� �����', binders.bindname)
							imgui.EndChild()
						end
						imgui.SameLine()
						if imgui.BeginChild('##3123454', imgui.ImVec2(200, 50)) then
							imgui.Text(u8('�������:'))
							if imgui.HotKey(u8('##HK').. k, v, tLastKeys, 55) then
								if not rkeys.isHotKeyDefined(v.v) then
									if rkeys.isHotKeyDefined(tLastKeys.v) then
										rkeys.unRegisterHotKey(tLastKeys.v)
									end
									rkeys.registerHotKey(v.v, true, onHotKey)
								end
								saveData(tBindList, 'moonloader/FBI-Helper/buttonbinder.json')
							end
							imgui.EndChild()
						end
						imgui.Text(u8('������� ����� �����:'))
						imgui.InputTextMultiline('##������� ����� �����', binders.bindtext, imgui.ImVec2(470, 175))
						if imgui.Button(u8('��������� ����##')..k, imgui.ImVec2(110, 25)) then
							stext('���� ������� ��������!')
							v.name = u8:decode(binders.bindname.v)
							v.text = u8:decode(binders.bindtext.v)
							saveData(tBindList, 'moonloader/FBI-Helper/buttonbinder.json')
						end
						imgui.SameLine()
						if imgui.Button(u8('������� ����##')..k, imgui.ImVec2(100, 25)) then
							stext('���� ������� ������!')
							table.remove(tBindList, k)
							saveData(tBindList, 'moonloader/FBI-Helper/buttonbinder.json')
						end
					end
				end
				imgui.EndChild()
			end
			if imgui.Button(u8('�������� �������'), imgui.ImVec2(170, 25)) then
				tBindList[#tBindList + 1] = {text = '', v = {}, time = 0, name = '����'..#tBindList + 1}
				saveData(tBindList, 'moonloader/FBI-Helper/buttonbinder.json')
			end
			imgui.SameLine(564)
			if imgui.Button(u8('��������� ������')) then
				show = 4
			end
		elseif show == 6 then
			if imgui.BeginChild('##FirstW', imgui.ImVec2(327.5, 322), true, imgui.WindowFlags.VerticalScrollbar) then
				imgui.CentrText(u8('����������')) 
				imgui.Separator()
				imgui.Text(u8('���: %s[%d]'):format(sInfo.Nick, sInfo.MyId))
				imgui.TextColoredRGB(string.format('������� ����: %s', sInfo.WorkingDay == true and '{00bf80}�����' or '{ec3737}�������'))
				imgui.Text(u8(('����� �����������: %s'):format(sInfo.AuthTime)))
				imgui.Text(u8('�������� �� �������: %s'):format(secToTime(sessionTime)))
				imgui.Text(u8('�� ��� �� ������: %s'):format(secToTime(pInfo.onlineTimer.workTime)))
				imgui.Text(u8('�� ��� � AFK: %s'):format(secToTime(pInfo.onlineTimer.dayAFK)))
				imgui.EndChild()
			end
			imgui.SameLine()
			if imgui.BeginChild('##TwoW', imgui.ImVec2(330, 322), true, imgui.WindowFlags.VerticalScrollbar) then
				imgui.CentrText(u8('���������� �� ����'))
				imgui.Separator()
				imgui.Text(u8('������������ ����������: %s'):format(pInfo.dayCounter.arrested))
				imgui.EndChild()
			end
		elseif show == 7 then
			imgui.BulletText(u8('/sw - ������� ���� �������.'))
			imgui.BulletText(u8('/shpora - ������� ���� � �������.'))
			imgui.BulletText(u8('/cn [id] [0 - RP nick, 1 - NonRP nick] - ����������� ��� � ������ ������.'))
			imgui.BulletText(u8('/swupd - ����������� ������ ����������.'))
			imgui.BulletText(u8('/msk [���] 1 - ���� | 2 - �������� | 3 - ����� | 4 - ����� ���������� - ����� ����������.'))
		elseif show == 10 then
			local btn_size = imgui.ImVec2(-0.1, 25)
			imgui.PushItemWidth(200)
			imgui.Text(u8('������� ����� ����� � ������� **:**, **:** � �. �.'))
			imgui.InputText('##inputtext', wave)
			imgui.Separator()
			imgui.Text(u8('/d OG, ���. ����� �� %s ������ �� FBI. ���������� �� �.%s.'):format(u8:decode(wave.v), sInfo.MyId))
			if imgui.Button(u8('������ ���. ����� ��������'), btn_size) then
				sampSendChat(string.format('/d OG, ���. ����� �� %s ������ �� FBI. ���������� �� �.%s.', u8:decode(wave.v), sInfo.MyId))
			end
			imgui.Text(u8('/d OG, ���������, ���. ����� �������� �� %s �� FBI.'):format(u8:decode(wave.v)))
			if imgui.Button(u8('��������� � ������� ���. ����� ��������'), btn_size) then
				sampSendChat(string.format('/d OG, ���������, ���. ����� �������� �� %s �� FBI.', u8:decode(wave.v)))
			end
		end
		imgui.End()
		-- ����� ��� ��������
		if window['binder'].bool.v then
			imgui.SetNextWindowSize(imgui.ImVec2(200, 300), imgui.Cond.FirstUseEver)
			imgui.SetNextWindowPos(imgui.ImVec2(x / 2.7, y / 1.2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
			imgui.Begin('##binder', window['binder'].bool, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize + imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoTitleBar)
			if show == 4 then
				imgui.Text(u8('{noe} - �������� ��������� � ���� �����\n{f6} - ��������� ��������� ����� ���\n{param:1} � �.� - ���������\n{myid} - ��� ID\n{myrpnick} - ��� �� ���\n{VehId} - ��� ID ����\n{wait:sek} - �������� ����� ��������\n{screen} - ������� �������� ������'))
			elseif show == 5 then
				imgui.Text(u8('{noe} - �������� ��������� � ���� �����\n{f6} - ��������� ��������� ����� ���\n{myid} - ��� ID\n{myrpnick} - ��� �� ���\n{VehId} - ��� ID ����\n{wait:sek} - �������� ����� ��������\n{screen} - ������� �������� ������'))
			end
			imgui.End()
		end
	end
	-- ���� �����
	if window['shpora'].bool.v then
    if data.shpora.loaded == 0 then
      data.shpora.select = {}
      for file in lfs.dir(getWorkingDirectory()..'\\FBI-Helper\\shpores') do
        if file ~= '.' and file ~= '..' then
          local attr = lfs.attributes(getWorkingDirectory()..'\\FBI-Helper\\shpores\\'..file)
          if attr.mode == 'file' then 
            table.insert(data.shpora.select, file)
          end
        end
      end
      data.shpora.page = 1
      data.shpora.loaded = 1
    end
    if data.shpora.loaded == 1 then
      if #data.shpora.select == 0 then
        data.shpora.text = {}
        data.shpora.edit = 0
      else
        -- ��������� ����� ����, ��������� ����� �� ��� ������������ ������ ������
        data.filename = 'moonloader/FBI-Helper/shpores/'..data.shpora.select[data.shpora.page]
        ----------
        data.shpora.text = {}
        for line in io.lines(data.filename) do
          table.insert(data.shpora.text, line)
        end
      end
      data.shpora.search.v = ''
      data.shpora.loaded = 2
    end
    imgui.SetNextWindowSize(imgui.ImVec2(x - 400, y - 250), imgui.Cond.FirstUseEver)
    imgui.SetNextWindowPos(imgui.ImVec2(x / 2, y / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
    imgui.Begin(u8('FBI-Helper | �����'), window['shpora'].bool, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.MenuBar + imgui.WindowFlags.HorizontalScrollbar)
    if imgui.BeginMenuBar(u8('FBI-Helper')) then
      for i = 1, #data.shpora.select do
        -- ������� �������� ������ � ������ ����, ������� .txt �� ��������
        local text = data.shpora.select[i]:gsub('.txt', '')
        if imgui.MenuItem(u8:encode(text)) then
          data.shpora.page = i
          data.shpora.loaded = 1
        end
      end
      imgui.EndMenuBar()
    end
    ---------
    if data.shpora.edit < 0 and #data.shpora.select > 0 then
      if imgui.Button(u8('����� �����'), imgui.ImVec2(120, 30)) then
        data.shpora.edit = 0
        data.shpora.search.v = ''
        data.shpora.inputbuffer.v = ''
      end
      imgui.SameLine()
      if imgui.Button(u8('�������� �����'), imgui.ImVec2(120, 30)) then
        data.shpora.edit = data.shpora.page
        local text = data.shpora.select[data.shpora.page]:gsub('.txt', '')
        data.shpora.search.v = u8:encode(text)
        local ttext  = ''
        for k, v in pairs(data.shpora.text) do
          ttext = ttext .. v .. '\n'
        end
        data.shpora.inputbuffer.v = u8:encode(ttext)
      end
      imgui.SameLine()
      if imgui.Button(u8('������� �����'), imgui.ImVec2(120, 30)) then
        os.remove(data.filename)
        data.shpora.loaded = 0
        stext('����� \''..data.filename..'\' ������� �������!')
      end
      imgui.Spacing()
      ---------
      imgui.PushItemWidth(250)
      imgui.Text(u8('����� �� ������'))
      imgui.InputText('##inptext', data.shpora.search)
      imgui.PopItemWidth()
      imgui.Separator()
      imgui.Spacing()
      for k, v in pairs(data.shpora.text) do
        if u8:decode(data.shpora.search.v) == '' or string.find(rusUpper(v), rusUpper(u8:decode(data.shpora.search.v))) ~= nil then
          imgui.Text(u8(v))
        end
      end
    else
      imgui.PushItemWidth(250)
      imgui.Text(u8('������� �������� �����'))
      imgui.InputText('##inptext', data.shpora.search)
      imgui.PopItemWidth()
      if imgui.Button(u8('���������'), imgui.ImVec2(120, 30)) then
        if #data.shpora.search.v ~= 0 and #data.shpora.inputbuffer.v ~= 0 then
          if data.shpora.edit == 0 then
            local file = io.open('moonloader\\FBI-Helper\\shpores\\'..u8:decode(data.shpora.search.v)..'.txt', 'a+')
            file:write(u8:decode(data.shpora.inputbuffer.v))
            file:close()
            stext('����� ������� �������!')
          elseif data.shpora.edit > 0 then
            local file = io.open(data.filename, 'w+')
            file:write(u8:decode(data.shpora.inputbuffer.v))
            file:close()
            local rename = os.rename(data.filename, 'moonloader\\FBI-Helper\\shpores\\'..u8:decode(data.shpora.search.v)..'.txt')
            if rename then
              stext('����� ������� ��������!')
            else
              stext('������ ��� ��������� �����')
            end
          end
          data.shpora.search.v = ''
          data.shpora.loaded = 0
          data.shpora.edit = -1
				else 
					stext('��� ���� ������ ���� ���������!') 
				end
      end
      imgui.SameLine()
      if imgui.Button(u8('������'), imgui.ImVec2(120, 30)) then
        if #data.shpora.select > 0 then
          data.shpora.edit = -1
          data.shpora.search.v = ''
				else 
					stext('��� ���������� ������� ���� �� ���� �����!') 
				end
      end
      imgui.Separator()
      imgui.Spacing()
      imgui.InputTextMultiline('##intextmulti', data.shpora.inputbuffer, imgui.ImVec2(-1, -1))
    end
    imgui.End()
	end 
end

-- rusUpper ��� ������� ����
function rusUpper(string)
	-- ������� �����
	local russian_characters = {
  	[168] = '�', [184] = '�', [192] = '�', [193] = '�', [194] = '�', [195] = '�', [196] = '�', [197] = '�', [198] = '�', [199] = '�', [200] = '�', [201] = '�', [202] = '�', [203] = '�', [204] = '�', [205] = '�', [206] = '�', [207] = '�', [208] = '�', [209] = '�', [210] = '�', [211] = '�', [212] = '�', [213] = '�', [214] = '�', [215] = '�', [216] = '�', [217] = '�', [218] = '�', [219] = '�', [220] = '�', [221] = '�', [222] = '�', [223] = '�', [224] = '�', [225] = '�', [226] = '�', [227] = '�', [228] = '�', [229] = '�', [230] = '�', [231] = '�', [232] = '�', [233] = '�', [234] = '�', [235] = '�', [236] = '�', [237] = '�', [238] = '�', [239] = '�', [240] = '�', [241] = '�', [242] = '�', [243] = '�', [244] = '�', [245] = '�', [246] = '�', [247] = '�', [248] = '�', [249] = '�', [250] = '�', [251] = '�', [252] = '�', [253] = '�', [254] = '�', [255] = '�',
	}
  local strlen = string:len()
	if strlen == 0 then 
		return string 
	end
  string = string:upper()
  local output = ''
  for i = 1, strlen do
    local ch = string:byte(i)
    if ch >= 224 and ch <= 255 then -- lower russian characters
      output = output .. russian_characters[ch-32]
    elseif ch == 184 then -- �
      output = output .. russian_characters[168]
    else
      output = output .. string.char(ch)
    end
  end
  return output
end

-- ����� ������ �� ��������
function string.split(str, delim, plain)
  local tokens, pos, plain = {}, 1, not (plain == false)
  repeat
    local npos, epos = string.find(str, delim, pos, plain)
    table.insert(tokens, string.sub(str, pos, npos and npos - 1))
    pos = epos and epos + 1
  until not pos
  return tokens
end

-- ���� ������ ������� �������� ������, � ��������� ������
function onScriptTerminate(LuaScript, quitGame)
	if LuaScript == thisScript() then
		showCursor(false)
		lua_thread.create(function()
			print('������ ����������. ��������� ���������.')
			if pInfo.onlineTimer.time then
				pInfo.onlineTimer.time = pInfo.onlineTimer.time
				saveData(pInfo, 'moonloader/FBI-Helper/config.json') 
			end
		end)
  end
end

-- C�������
function onlineTimer()
	lua_thread.create(function()
		updatecount = 0 
		while true do
			if sInfo.WorkingDay == true then
				pInfo.onlineTimer.workTime = pInfo.onlineTimer.workTime + 1
			end
			pInfo.onlineTimer.time = pInfo.onlineTimer.time + 1
			pInfo.onlineTimer.dayAFK = pInfo.onlineTimer.dayAFK + (os.time() - sInfo.updateAFK - 1)
			if updatecount >= 10 then 
				saveData(pInfo, 'moonloader/FBI-Helper/config.json')  
				updatecount = 0 
			end
			updatecount = updatecount + 1
			sInfo.updateAFK = os.time()
			sessionTime = pInfo.onlineTimer.time + pInfo.onlineTimer.dayAFK
			wait(1000)
		end
	end)
end

-- ������� ������ � 00:00:00
function secToTime(sec)
  local hour, minute, second = sec / 3600, math.floor(sec / 60), sec % 60
  return string.format('%02d:%02d:%02d', math.floor(hour) ,  minute - (math.floor(hour) * 60), second)
end

-- �������� ���� ��������� ��� ��������
function binderclose()
	if window['binder'].bool.v == true then
		window['binder'].bool.v = false
	end
end

-- ���� ����� ������� - ��������� ��������
function punaccept()

end

-- ����-����������
function update()
	local filepath = os.getenv('TEMP') .. '\\FBIhelperupd.json'
	downloadUrlToFile('https://raw.githubusercontent.com/Tur41k/update/master/FBIhelperupd.json', filepath, function(id, status, p1, p2)
		if status == dlstatus.STATUS_ENDDOWNLOADDATA then
			local file = io.open(filepath, 'r')
			if file then
				local info = decodeJson(file:read('*a'))
				updatelink = info.updateurl
				if info and info.latest then
					if tonumber(thisScript().version) < tonumber(info.latest) then
						lua_thread.create(function()
							stext('�������� ���������� ����������. ������ �������������� ����� ���� ������.')
							wait(300)
							downloadUrlToFile(updatelink, thisScript().path, function(id3, status1, p13, p23)
								if status1 == dlstatus.STATUS_ENDDOWNLOADDATA then
									print('���������� ������� ������� � �����������.')
								elseif status1 == 64 then
									stext('���������� ������� ������� � �����������. ����������� ������ ��������� - /swupd')
								end
							end)
						end)
					else
						print('���������� ������� �� ����������.')
						update = false
					end
				end
			else
				print('�������� ���������� ������ ���������. �������� ������ ������.')
			end
		elseif status == 64 then
			print('�������� ���������� ������ ���������. �������� ������ ������.')
			update = false
		end
	end)
end

-- ����� ��� ���������� �������
function registerCommandsBinder()
	for k, v in pairs(cmd_binder) do
		if sampIsChatCommandDefined(v.cmd) then 
			sampUnregisterChatCommand(v.cmd) 
		end
		sampRegisterChatCommand(v.cmd, function(args)
			thread = lua_thread.create(function()
				local params = string.split(args, ' ', v.params)
				local cmdtext = v.text
				if #params < v.params then
					local paramtext = ''
					for i = 1, v.params do
						paramtext = paramtext .. '[��������'..i..'] '
					end
					atext(('�������: /%s %s'):format(v.cmd, paramtext))
					return
				else
					for line in cmdtext:gmatch('[^\r\n]+') do
						if line:match('^{wait%:%d+}$') then
							wait(line:match('^%{wait%:(%d+)}$'))
						elseif line:match('^{screen}$') then
							screen()
						else
							local bIsEnter = string.match(line, '^{noe}(.+)') ~= nil
							local bIsF6 = string.match(line, '^{f6}(.+)') ~= nil
							local keys = {
								['{f6}'] = '',
								['{noe}'] = '',
								['{myid}'] = sInfo.MyId,
								['{myrpnick}'] = sInfo.Nick:gsub('_', ' '),
								['{VehId}'] = sInfo.VehicleId,
							}
							for i = 1, v.params do
								keys['{param:'..i..'}'] = params[i]
							end
							for k1, v1 in pairs(keys) do
								line = line:gsub(k1, v1)
							end
							if not bIsEnter then
								if bIsF6 then
									sampProcessChatInput(line)
								else
									sampSendChat(line)
								end
							else
								sampSetChatInputText(line)
								sampSetChatInputEnabled(true)
							end
						end
					end
				end
			end)
		end)
	end
end

-- ����� ��� ���������� �������
function onHotKey(id, keys)
	lua_thread.create(function()
		local sKeys = tostring(table.concat(keys, ' '))
		for k, v in pairs(tBindList) do
			if sKeys == tostring(table.concat(v.v, ' ')) then
				local tostr = tostring(v.text)
				if tostr:len() > 0 then
					for line in tostr:gmatch('[^\r\n]+') do
						if line:match('^{wait%:%d+}$') then
							wait(line:match('^%{wait%:(%d+)}$'))
						elseif line:match('^{screen}$') then
							screen()
						else
							local bIsEnter = string.match(line, '^{noe}(.+)') ~= nil
							local bIsF6 = string.match(line, '^{f6}(.+)') ~= nil
							local keys = {
								['{f6}'] = '',
								['{noe}'] = '',
								['{myid}'] = sInfo.MyId,
								['{myrpnick}'] = sInfo.Nick:gsub('_', ' '),
								['{VehId}'] = sInfo.VehicleId,
							}
							for k1, v1 in pairs(keys) do
								line = line:gsub(k1, v1)
							end
							if not bIsEnter then
								if bIsF6 then
									sampProcessChatInput(line)
								else
									sampSendChat(line)
								end
							else
								sampSetChatInputText(line)
								sampSetChatInputEnabled(true)
							end
						end
					end
				end
			end
		end
	end)
end

-- ���� ���� ������� ��������� ������� �������
function rkeys.onHotKey(id, keys)
	if sampIsChatInputActive() or sampIsDialogActive() or isSampfuncsConsoleActive() then
		return false
	end
end

-- ����� ������ (��� ���������� �������)
function screen()
	memory.setuint8(sampGetBase() + 0x119CBC, 1) 
end

-- Samp Events (����)
function sampevents.onServerMessage(color, text)
	if color == 1687547391 then
		if text:find('�� �������� � ������') then
			pInfo.dayCounter.arrested = pInfo.dayCounter.arrested + 1
		end
		if pInfo.options.clistb == true then
			if text:find('������� ���� �����') then
				lua_thread.create(function()
					wait(1)
					sampSendChat(string.format('/clist %s', pInfo.options.clist))
				end)
			end
		end
	end
end

function sampevents.onSendSpawn()
	if pInfo.options.clistb and sInfo.WorkingDay == true then
		lua_thread.create(function()
			wait(1400)
			sampSendChat(string.format('/clist %s', pInfo.options.clist))
		end)
	end
end

-- ��������� ����������
function saveData(table, path)
	if doesFileExist(path) then 
		os.remove(path) 
	end
    local file = io.open(path, 'w')
    if file then
		file:write(encodeJson(table))
		file:close()
  end
end

-- ������� ��� ������� � imgui
function imgui.CentrText(text)
	local width = imgui.GetWindowWidth()
	local calc = imgui.CalcTextSize(text)
	imgui.SetCursorPosX( width / 2 - calc.x / 2 )
	imgui.Text(text)
end

function imgui.TextQuestion(text)
	imgui.TextDisabled('(?)')
	if imgui.IsItemHovered() then
		imgui.BeginTooltip()
		imgui.PushTextWrapPos(450)
		imgui.TextUnformatted(text)
		imgui.PopTextWrapPos()
		imgui.EndTooltip()
	end
end

function imgui.TextColoredRGB(text)
  local style = imgui.GetStyle()
  local colors = style.Colors
  local ImVec4 = imgui.ImVec4
  local explode_argb = function(argb)
    local a = bit.band(bit.rshift(argb, 24), 0xFF)
    local r = bit.band(bit.rshift(argb, 16), 0xFF)
    local g = bit.band(bit.rshift(argb, 8), 0xFF)
    local b = bit.band(argb, 0xFF)
    return a, r, g, b
  end
  local getcolor = function(color)
    if color:sub(1, 6):upper() == 'SSSSSS' then
    	local r, g, b = colors[1].x, colors[1].y, colors[1].z
    	local a = tonumber(color:sub(7, 8), 16) or colors[1].w * 255
    	return ImVec4(r, g, b, a / 255)
    end
  	local color = type(color) == 'string' and tonumber(color, 16) or color
  	if type(color) ~= 'number' then return end
    	local r, g, b, a = explode_argb(color)
    	return imgui.ImColor(r, g, b, a):GetVec4()
  	end
  	local render_text = function(text_)
  	for w in text_:gmatch('[^\r\n]+') do
    	local text, colors_, m = {}, {}, 1
    	w = w:gsub('{(......)}', '{%1FF}')
    	while w:find('{........}') do
      	local n, k = w:find('{........}')
      	local color = getcolor(w:sub(n + 1, k - 1))
      	if color then
        	text[#text], text[#text + 1] = w:sub(m, n - 1), w:sub(k + 1, #w)
        	colors_[#colors_ + 1] = color
        	m = n
      	end
      	w = w:sub(1, n - 1) .. w:sub(k + 1, #w)
     	end
      if text[0] then
        for i = 0, #text do
          imgui.TextColored(colors_[i] or colors[1], u8(text[i]))
          imgui.SameLine(nil, 0)
        end
        imgui.NewLine()
			else 
				imgui.Text(u8(w)) 
			end
    end
  end
  render_text(text)
end

-- ��������� ������ ����� ����
function apply_custom_style()
	imgui.SwitchContext()
	local style = imgui.GetStyle()
	local colors = style.Colors
	local clr = imgui.Col
	local ImVec4 = imgui.ImVec4
	local ImVec2 = imgui.ImVec2
	
	style.ChildWindowRounding = 8.0
	style.WindowTitleAlign = imgui.ImVec2(0.5, 0.5)
	style.WindowPadding = ImVec2(15, 15)
	style.WindowRounding = 10.0
	style.FramePadding = ImVec2(5, 5)
	style.FrameRounding = 6.0
	style.ItemSpacing = ImVec2(12, 8)
	style.ItemInnerSpacing = ImVec2(8, 5)
	style.IndentSpacing = 25.0
	style.ScrollbarSize = 15.0
	style.ScrollbarRounding = 9.0
	style.GrabMinSize = 15.0
	style.GrabRounding = 7.0
	
	colors[clr.Text] = ImVec4(0.95, 0.96, 0.98, 1.00)
	colors[clr.TextDisabled] = ImVec4(0.36, 0.42, 0.47, 1.00)
	colors[clr.WindowBg] = ImVec4(0.11, 0.15, 0.17, 1.00)
	colors[clr.ChildWindowBg] = ImVec4(0.11, 0.15, 0.17, 1.00)
	colors[clr.PopupBg] = ImVec4(0.08, 0.08, 0.08, 0.94)
	colors[clr.Border] = ImVec4(0.43, 0.43, 0.50, 0.50)
	colors[clr.BorderShadow] = ImVec4(0.00, 0.00, 0.00, 0.00)
	colors[clr.FrameBg] = ImVec4(0.20, 0.25, 0.29, 1.00)
	colors[clr.FrameBgHovered] = ImVec4(0.12, 0.20, 0.28, 1.00)
	colors[clr.FrameBgActive] = ImVec4(0.09, 0.12, 0.14, 1.00)
	colors[clr.TitleBg] = ImVec4(0.09, 0.12, 0.14, 0.65)
	colors[clr.TitleBgCollapsed] = ImVec4(0.00, 0.00, 0.00, 0.51)
	colors[clr.TitleBgActive] = ImVec4(0.08, 0.10, 0.12, 1.00)
	colors[clr.MenuBarBg] = ImVec4(0.15, 0.18, 0.22, 1.00)
	colors[clr.ScrollbarBg] = ImVec4(0.02, 0.02, 0.02, 0.39)
	colors[clr.ScrollbarGrab] = ImVec4(0.20, 0.25, 0.29, 1.00)
	colors[clr.ScrollbarGrabHovered] = ImVec4(0.18, 0.22, 0.25, 1.00)
	colors[clr.ScrollbarGrabActive] = ImVec4(0.09, 0.21, 0.31, 1.00)
	colors[clr.ComboBg] = ImVec4(0.20, 0.25, 0.29, 1.00)
	colors[clr.CheckMark] = ImVec4(0.28, 0.56, 1.00, 1.00)
	colors[clr.SliderGrab] = ImVec4(0.28, 0.56, 1.00, 1.00)
	colors[clr.SliderGrabActive] = ImVec4(0.37, 0.61, 1.00, 1.00)
	colors[clr.Button] = ImVec4(0.20, 0.25, 0.29, 1.00)
	colors[clr.ButtonHovered] = ImVec4(0.28, 0.56, 1.00, 1.00)
	colors[clr.ButtonActive] = ImVec4(0.06, 0.53, 0.98, 1.00)
	colors[clr.Header] = ImVec4(0.20, 0.25, 0.29, 0.55)
	colors[clr.HeaderHovered] = ImVec4(0.26, 0.59, 0.98, 0.80)
	colors[clr.HeaderActive] = ImVec4(0.26, 0.59, 0.98, 1.00)
	colors[clr.ResizeGrip] = ImVec4(0.26, 0.59, 0.98, 0.25)
	colors[clr.ResizeGripHovered] = ImVec4(0.26, 0.59, 0.98, 0.67)
	colors[clr.ResizeGripActive] = ImVec4(0.06, 0.05, 0.07, 1.00)
	colors[clr.CloseButton] = ImVec4(0.40, 0.39, 0.38, 0.16)
	colors[clr.CloseButtonHovered] = ImVec4(0.40, 0.39, 0.38, 0.39)
	colors[clr.CloseButtonActive] = ImVec4(0.40, 0.39, 0.38, 1.00)
	colors[clr.PlotLines] = ImVec4(0.61, 0.61, 0.61, 1.00)
	colors[clr.PlotLinesHovered] = ImVec4(1.00, 0.43, 0.35, 1.00)
	colors[clr.PlotHistogram] = ImVec4(0.90, 0.70, 0.00, 1.00)
	colors[clr.PlotHistogramHovered] = ImVec4(1.00, 0.60, 0.00, 1.00)
	colors[clr.TextSelectedBg] = ImVec4(0.25, 1.00, 0.00, 0.43)
	colors[clr.ModalWindowDarkening] = ImVec4(1.00, 0.98, 0.95, 0.73)
end

-- ��������� �����
function stext(text)
  sampAddChatMessage((' %s {FFFFFF}%s'):format(script.this.name, text), 0x2C7AA9)
end

function atext(text)
	sampAddChatMessage((' �  {FFFFFF}%s'):format(text), 0x2C7AA9)
end

-- samgui �������
function submenus_show(menu, caption, select_button, close_button, back_button)
	select_button, close_button, back_button = select_button or '�', close_button or 'x', back_button or '�'
	prev_menus = {}
	function display(menu, id, caption)
		local string_list = {}
		for i, v in ipairs(menu) do
			table.insert(string_list, type(v.submenu) == 'table' and v.title .. ' �' or v.title)
		end
		sampShowDialog(id, caption, table.concat(string_list, '\n'), select_button, (#prev_menus > 0) and back_button or close_button, sf.DIALOG_STYLE_LIST)
		repeat
			wait(0)
			local result, button, list = sampHasDialogRespond(id)
			if result then
				if button == 1 and list ~= -1 then
					local item = menu[list + 1]
					if type(item.submenu) == 'table' then
						table.insert(prev_menus, {menu = menu, caption = caption})
						if type(item.onclick) == 'function' then
							item.onclick(menu, list + 1, item.submenu)
						end
						return display(item.submenu, id + 1, item.submenu.title and item.submenu.title or item.title)
					elseif type(item.onclick) == 'function' then
						local result = item.onclick(menu, list + 1)
						if not result then 
							return result 
						end
						return display(menu, id, caption)
					end
				else
					if #prev_menus > 0 then
						local prev_menu = prev_menus[#prev_menus]
						prev_menus[#prev_menus] = nil
						return display(prev_menu.menu, id - 1, prev_menu.caption)
					end
					return false
				end
			end
		until result
	end
	return display(menu, 31337, caption or menu.title)
end