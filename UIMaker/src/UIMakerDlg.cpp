
// UI.MakerDlg.cpp : 구현 파일
//

#include "stdafx.h"
#include "UIMaker.h"
#include "UIMakerDlg.h"
#include "afxdialogex.h"

#include "CMDPipe.h"

#include "ConfigParser.h"

#include <fstream>
#include <sstream>

#ifdef _DEBUG
#define new DEBUG_NEW
#endif


// CUIMakerDlg 대화 상자

#define SPLITER_WIDTH               5
#define MIN_PROPERTIES_WIDTH        30
#define SPLITER_HEIGHT              5
#define MIN_HISTORY_HEIGHT          30
#define MIN_LUANAMES_HEIGHT         30

#define DONT_DRAW_SPLITER           -99999999
#define NOTIFY_CODE__NEW_CMD        5001
#define NOTIFY_CODE__NEW_POPUP_MENU 5002
#define NOTIFY_CODE__OPEN_VIEWER    5003

#define IDC_ENTITIES                    1007
#define IDC_PROPERTIES                  1008
#define IDC_HISTORY                     1009
#define IDC_LUANAMES                    1010
#define ID_WRITE_PASTEASHYPERLINK       32770
#define ID_OPEN_VIEWER                  32771
#define ID_SELECT_RESOLUTION            32772

// 프로젝트 별로 관리
#define PROJECT_DH	0
#define PROJECT_DV	1

#define PROJECT_	PROJECT_DV

CCocos2dXViewer CUIMakerDlg::sm_viewer;

#if PROJECT_ == PROJECT_DH
bool CUIMakerDlg::m_portat = true;
CUIMakerDlg::RES CUIMakerDlg::m_display_mode = CUIMakerDlg::RES::_640_1138;
#else
bool CUIMakerDlg::m_portat = false;
CUIMakerDlg::RES CUIMakerDlg::m_display_mode = CUIMakerDlg::RES::_1280_720;
#endif


void SendNewCmdNotifycation()
{
	auto main_window = DYNAMIC_DOWNCAST(CUIMakerDlg, AfxGetApp()->GetMainWnd());
	if (main_window)
	{
		main_window->SendNewCmdNotifycation();
	}
}
void SendOpenPopupNotifycation(maker::CMD& cmd)
{
	auto main_window = DYNAMIC_DOWNCAST(CUIMakerDlg, AfxGetApp()->GetMainWnd());
	if (main_window)
	{
		main_window->SendOpenPopupNotifycation(cmd);
	}
}
void SendOpenViewer()
{
	auto main_window = DYNAMIC_DOWNCAST(CUIMakerDlg, AfxGetApp()->GetMainWnd());
	if (main_window)
	{
		main_window->SendOpenViewer();
	}
}

void SaveToClipboard(const maker::Entity& entity)
{
	auto main_window = AfxGetMainWnd();
	if (!main_window) return;

	auto main_window_handle = main_window->GetSafeHwnd();
	if (!IsWindow(main_window_handle)) return;

	UINT format = RegisterClipboardFormat(L"UI_MAKER_ENTITY");
	if (!OpenClipboard(main_window_handle)) return;

	std::stringstream ss;
	entity.SerializePartialToOstream(&ss);

	auto content = ss.str();

	//allocate some global memory
	HGLOBAL clipbuffer;
	EmptyClipboard();
	clipbuffer = GlobalAlloc(GMEM_DDESHARE, content.size() + sizeof(int));
	char* buffer = (char*)GlobalLock(clipbuffer);

	//put the data into that memory
	int size = content.size();
	memcpy(buffer, &size, sizeof(int));
	memcpy(buffer + sizeof(int), content.c_str(), content.size());

/*	int size2 = 0;
	memcpy(&size2, buffer, sizeof(int));
	std::string content2(buffer + sizeof(int), size2);
	std::stringstream ss2(content2);
	
	maker::Entity entity2;
	entity2.ParsePartialFromIstream(&ss2);
*/
	//put it on the clipboard
	GlobalUnlock(clipbuffer);
	SetClipboardData(format, clipbuffer);
	CloseClipboard();
}
void LoadFromClipboard(maker::Entity& entity)
{
	auto main_window = AfxGetMainWnd();
	if (!main_window) return;

	auto main_window_handle = main_window->GetSafeHwnd();
	if (!IsWindow(main_window_handle)) return;

	UINT format = RegisterClipboardFormat(L"UI_MAKER_ENTITY");
	if (!OpenClipboard(main_window_handle)) return;

	//get the buffer
	HANDLE hData = GetClipboardData(format);
	char* buffer = (char*)GlobalLock(hData);

	//make a local copy
	int size = 0;
	memcpy(&size, buffer, sizeof(int));
	std::string content(buffer + sizeof(int), size);
	std::stringstream ss(content);

	entity.ParsePartialFromIstream(&ss);

	GlobalUnlock(hData);
	CloseClipboard();
}

const char* getSavePath()
{
	// 내문서 경로 가져온다.
	TCHAR szPath[512] = { 0 };
	SHGetSpecialFolderPath(NULL, szPath, CSIDL_PERSONAL, FALSE);
	
	// 저장할 파일 명 추가
	const wchar_t* file_name = _T("\\uimaker.cfg");
	wcscat(szPath, file_name);

	int len = 512;
	char ctemp[512];

	// 실제 변환
	WideCharToMultiByte(CP_ACP, 0, szPath, len, ctemp, len, NULL, NULL);
	char* cc = &ctemp[0];
	return cc;
}






CUIMakerDlg::CUIMakerDlg(CWnd* pParent /*=NULL*/)
	: CDialogEx(CUIMakerDlg::IDD, pParent)
	, m_propertiesWidth(300)
	, m_luanameWidth(100)
	, m_historyWidth(50)
	, m_historyHeight(100)
	, m_pickPropertiesSpliter(false)
	, m_pickHistorySpliter(false)
	, m_isPickLuanameSpliter(false)
	, m_isPickHistoryWidthSpliter(false)
{
	m_hIcon = AfxGetApp()->LoadIcon(IDR_MAINFRAME);
	/*HICON hIcon = LoadIcon(AfxGetInstanceHandle(), MAKEINTRESOURCE(IDR_MAINFRAME));
	this->SetIcon(hIcon, FALSE);*/
}

void CUIMakerDlg::DoDataExchange(CDataExchange* pDX)
{
	CDialogEx::DoDataExchange(pDX);
}

#pragma region MFC_MESSAGE_MAP

BEGIN_MESSAGE_MAP(CUIMakerDlg, CDialogEx)
    ON_WM_ACTIVATE()
	ON_WM_PAINT()
	ON_WM_QUERYDRAGICON()
	ON_WM_RBUTTONUP()
	ON_WM_SIZE()
	ON_WM_MOUSEMOVE()
	ON_WM_LBUTTONDOWN()
	ON_WM_LBUTTONUP()
	ON_WM_CLOSE()
	ON_WM_CREATE()
	ON_WM_MOVE()
	ON_WM_DROPFILES()
	ON_COMMAND(ID_EXIT, &CUIMakerDlg::onExit)
	ON_COMMAND(ID_FILE_CLOSE_UI, &CUIMakerDlg::onFileCloseUi)
	ON_COMMAND(ID_FILE_OPEN_UI, &CUIMakerDlg::onFileOpenUi)
	ON_COMMAND(ID_FILE_SAVE_UI, &CUIMakerDlg::onFileSaveUi)
	ON_COMMAND(ID_FILE_SAVE_UI_AS, &CUIMakerDlg::onFileSaveUiAs)
	ON_COMMAND(ID_RES_480_800, &CUIMakerDlg::OnOpenCocos2dViewer_480_800)
	ON_COMMAND(ID_RES_640_1138, &CUIMakerDlg::OnOpenCocos2dViewer_640_1138)
	ON_COMMAND(ID_RES_640_960, &CUIMakerDlg::OnOpenCocos2dViewer_640_960)
	ON_COMMAND(ID_RES_640_852, &CUIMakerDlg::OnOpenCocos2dViewer_640_852)
	ON_COMMAND(ID_RES_720_1280, &CUIMakerDlg::OnOpenCocos2dViewer_720_1280)
	ON_COMMAND(ID_RES_720_1080, &CUIMakerDlg::OnOpenCocos2dViewer_720_1080)
	ON_COMMAND(ID_RES_720_960, &CUIMakerDlg::OnOpenCocos2dViewer_720_960)
	ON_COMMAND(ID_RES_800_480, &CUIMakerDlg::OnOpenCocos2dViewer_800_480)
	ON_COMMAND(ID_RES_1138_640, &CUIMakerDlg::OnOpenCocos2dViewer_1138_640)
	ON_COMMAND(ID_RES_960_640, &CUIMakerDlg::OnOpenCocos2dViewer_960_640)
	ON_COMMAND(ID_RES_852_640, &CUIMakerDlg::OnOpenCocos2dViewer_852_640)
	ON_COMMAND(ID_RES_1280_720, &CUIMakerDlg::OnOpenCocos2dViewer_1280_720)
	ON_COMMAND(ID_RES_1080_720, &CUIMakerDlg::OnOpenCocos2dViewer_1080_720)
	ON_COMMAND(ID_RES_960_720, &CUIMakerDlg::OnOpenCocos2dViewer_960_720)
	ON_COMMAND(ID_RES_1280_960, &CUIMakerDlg::OnOpenCocos2dViewer_1280_960)
	ON_COMMAND(ID_RES_960_1280, &CUIMakerDlg::OnOpenCocos2dViewer_960_1280)
	ON_COMMAND(ID_RES_1280_853, &CUIMakerDlg::OnOpenCocos2dViewer_1280_853)
	ON_COMMAND(ID_RES_853_1280, &CUIMakerDlg::OnOpenCocos2dViewer_853_1280)

    ON_COMMAND(ID_TOOLS_FILECONVERT, &CUIMakerDlg::onFileConvert)
    ON_COMMAND(ID_RES_SCALE_50, &CUIMakerDlg::OnOpenCocos2dViewer_Scale_50)
    ON_COMMAND(ID_RES_SCALE_60, &CUIMakerDlg::OnOpenCocos2dViewer_Scale_60)
    ON_COMMAND(ID_RES_SCALE_70, &CUIMakerDlg::OnOpenCocos2dViewer_Scale_70)
    ON_COMMAND(ID_RES_SCALE_80, &CUIMakerDlg::OnOpenCocos2dViewer_Scale_80)
    ON_COMMAND(ID_RES_SCALE_90, &CUIMakerDlg::OnOpenCocos2dViewer_Scale_90)
    ON_COMMAND(ID_RES_SCALE_100, &CUIMakerDlg::OnOpenCocos2dViewer_Scale_100)
    ON_COMMAND(ID_RES_720_1440, &CUIMakerDlg::OnOpenCocos2dViewer_720_1440)
END_MESSAGE_MAP()

#pragma endregion


// CUIMakerDlg 메시지 처리기

BOOL CUIMakerDlg::OnInitDialog()
{
	CDialogEx::OnInitDialog();

	GetWindowText(m_title);

	// 이 대화 상자의 아이콘을 설정합니다.  응용 프로그램의 주 창이 대화 상자가 아닐 경우에는
	//  프레임워크가 이 작업을 자동으로 수행합니다.
	SetIcon(m_hIcon, TRUE);			// 큰 아이콘을 설정합니다.
	SetIcon(m_hIcon, FALSE);		// 작은 아이콘을 설정합니다.

	CRect rcclient;
	GetClientRect(rcclient);

	DWORD dwStyle;
	dwStyle = WS_CHILD | WS_VISIBLE | PTS_NOTIFY;

	if (!::IsWindow(m_entity_list_view.GetSafeHwnd()))
	{
		m_entity_list_view.Create(dwStyle, rcclient, this, IDC_ENTITIES);
	}

	if (!::IsWindow(m_properties.GetSafeHwnd()))
	{
		m_properties.Create(dwStyle, rcclient, this, IDC_PROPERTIES);
	}

	if (!::IsWindow(m_history.GetSafeHwnd()))
	{
		m_history.Create(dwStyle, rcclient, this, IDC_HISTORY);
	}

	if (!::IsWindow(m_luaname_list_view.GetSafeHwnd()))
	{
		m_luaname_list_view.Create(dwStyle, rcclient, this, IDC_LUANAMES);
	}

	Bind(CEntityMgr::getInstance()->getRoot());


	int version = 0;
	int portat = m_portat ? 1 : 0, viewer_w = -1, viewer_h = -1;
    float viewer_scale = 1.0f;
	int tool_x = 0, tool_y = 0, tool_w = 600, tool_h = 800;
	
	// 내문서 경로 가져온다.
	TCHAR szPath[512] = { 0 };
	SHGetSpecialFolderPath(NULL, szPath, CSIDL_PERSONAL, FALSE);

	// 저장할 파일 명 추가
	const wchar_t* file_name = _T("\\uimaker.cfg");
	wcscat(szPath, file_name);

	int len = 512;
	char ctemp[512];

	// 실제 변환
	WideCharToMultiByte(CP_ACP, 0, szPath, len, ctemp, len, NULL, NULL);
	char* real_path = &ctemp[0];

	FILE* pf = fopen(real_path, "rt");
	if (pf)
	{
		fscanf(pf, "version %d", &version);
        fscanf(pf, " viewer %d, %d, %d, %f", &portat, &viewer_w, &viewer_h, &viewer_scale);
		fscanf(pf, " tool %d, %d, %d, %d, %d, %d, %d, %d", &tool_x, &tool_y, &tool_w, &tool_h, &m_propertiesWidth, &m_historyHeight, &m_historyWidth, &m_luanameWidth);
		fclose(pf);
	}

	if (m_propertiesWidth < MIN_PROPERTIES_WIDTH) m_propertiesWidth = MIN_PROPERTIES_WIDTH;
	if (m_historyHeight < MIN_HISTORY_HEIGHT) m_historyHeight = MIN_HISTORY_HEIGHT;

#if PROJECT_ == PROJECT_DH
	if (m_historyWidth < MIN_PROPERTIES_WIDTH) m_historyWidth = MIN_PROPERTIES_WIDTH;
	if (m_luanameWidth < MIN_PROPERTIES_WIDTH) m_luanameWidth = MIN_PROPERTIES_WIDTH;
#endif

	bool invalid_tool_rect = true;
	CRect rctool(tool_x, tool_y, tool_x + tool_w, tool_y + tool_h);
	DISPLAY_DEVICE device;
	device.cb = sizeof(DISPLAY_DEVICE);
	for (int i = 0;; i++)
	{
		if (!::EnumDisplayDevices(NULL, i, &device, 0)) break;

		DEVMODE devMode;
		if (!::EnumDisplaySettings(device.DeviceName, ENUM_CURRENT_SETTINGS, &devMode)) continue;

		CRect rcdisplay(devMode.dmPosition.x, devMode.dmPosition.y,
			devMode.dmPosition.x + devMode.dmPelsWidth, devMode.dmPosition.y + devMode.dmPelsHeight);

		CRect rcintersect;
		if (rcintersect.IntersectRect(&rcdisplay, &rctool) && rcintersect.EqualRect(&rctool))
		{
			invalid_tool_rect = false;
			break;
		}

#ifdef DEBUG
		char buf[1024];
		sprintf(buf, "---> Position: (%d, %d) Size: %dx%d\n", devMode.dmPosition.x, devMode.dmPosition.y, devMode.dmPelsWidth, devMode.dmPelsHeight);
		OutputDebugStringA(buf);
#endif
	}

	if (portat) m_portat = true;

	if (invalid_tool_rect)
	{
		int screen_w = GetSystemMetrics(SM_CXSCREEN);
		int screen_h = GetSystemMetrics(SM_CYSCREEN);
		tool_x = screen_w / 2;
		tool_y = screen_h / 6;
		tool_w = 600;
		tool_h = screen_h*2/3;
	}
	MoveWindow(tool_x, tool_y, tool_w, tool_h);
    sm_viewer.open(viewer_w, viewer_h, viewer_scale, (int)m_hWnd);

	if (!m_ui_file_path_name.IsEmpty() && !m_ui_file_name.IsEmpty())
	{	
		if (::IsWindow(GetSafeHwnd()))
		{
			SetWindowText(m_title + _T(" - ") + m_ui_file_name);
		}
		CEntityMgr::getInstance()->Load(ASCII(LPCTSTR(m_ui_file_path_name)));
		Bind(CEntityMgr::getInstance()->getRoot());
		m_entity_list_view.Redraw();
		m_luaname_list_view.Redraw();

		CCMDPipe::getInstance()->applyToViewer();
	}

	return TRUE;
}

void CUIMakerDlg::OnActivate(UINT nState, CWnd* pWndOther, BOOL bMinimized)
{
    CDialogEx::OnActivate(nState, pWndOther, bMinimized);

    maker::CMD cmd;
    switch (nState)
    {
    case WA_ACTIVE:
    case WA_CLICKACTIVE:
        sm_viewer.setForeground((int)m_hWnd);
        break;
    }
}

// 대화 상자에 최소화 단추를 추가할 경우 아이콘을 그리려면
//  아래 코드가 필요합니다.  문서/뷰 모델을 사용하는 MFC 응용 프로그램의 경우에는
//  프레임워크에서 이 작업을 자동으로 수행합니다.

void CUIMakerDlg::OnPaint()
{
	if (IsIconic())
	{
		CPaintDC dc(this); // 그리기를 위한 디바이스 컨텍스트입니다.

		SendMessage(WM_ICONERASEBKGND, reinterpret_cast<WPARAM>(dc.GetSafeHdc()), 0);

		// 클라이언트 사각형에서 아이콘을 가운데에 맞춥니다.
		int cxIcon = GetSystemMetrics(SM_CXICON);
		int cyIcon = GetSystemMetrics(SM_CYICON);
		CRect rect;
		GetClientRect(&rect);
		int x = (rect.Width() - cxIcon + 1) / 2;
		int y = (rect.Height() - cyIcon + 1) / 2;

		// 아이콘을 그립니다.
		dc.DrawIcon(x, y, m_hIcon);
	}
	else
	{
		CDialogEx::OnPaint();
	}
}

// 사용자가 최소화된 창을 끄는 동안에 커서가 표시되도록 시스템에서
//  이 함수를 호출합니다.
HCURSOR CUIMakerDlg::OnQueryDragIcon()
{
	return static_cast<HCURSOR>(m_hIcon);
}


void CUIMakerDlg::SendNewCmdNotifycation()
{
	static NMHDR nm;
	UINT id = (UINT)::GetMenu(m_hWnd);
	nm.code = NOTIFY_CODE__NEW_CMD;
	nm.hwndFrom = m_hWnd;
	nm.idFrom = (UINT)::GetMenu(m_hWnd);

	PostMessage(WM_NOTIFY, (WPARAM)id, (LPARAM)&nm);
}
void CUIMakerDlg::SendOpenPopupNotifycation(maker::CMD& cmd)
{
	m_queue_for_popup_menu.push(cmd);

	static NMHDR nm;
	UINT id = (UINT)::GetMenu(m_hWnd);
	nm.code = NOTIFY_CODE__NEW_POPUP_MENU;
	nm.hwndFrom = m_hWnd;
	nm.idFrom = (UINT)::GetMenu(m_hWnd);

	PostMessage(WM_NOTIFY, (WPARAM)id, (LPARAM)&nm);
}

void CUIMakerDlg::UpdateCmd()
{
	maker::CMD cmd;
	while (CCMDPipe::getInstance()->recvAtTool(cmd))
	{
		switch (cmd.type())
		{
		case maker::CMD__Create:
 		case maker::CMD__Paste: onCmd_Create(cmd); break;
		case maker::CMD__Cut:
		case maker::CMD__Remove: onCmd_Remove(cmd); break;
		case maker::CMD__Move: onCmd_Move(cmd);   break;
		case maker::CMD__Modify: onCmd_Modify(cmd); break;
        case maker::CMD__SizeToContent: onCmd_SizeToContent(cmd); break;
		case maker::CMD__SelectOne: onCmd_SelectOne(cmd); break;
		case maker::CMD__SelectAppend: onCmd_SelectAppend(cmd); break;
		case maker::CMD__SelectBoxAppend: onCmd_SelectBoxAppend(cmd); break;
		case maker::CMD__ApplyToTool: onCmd_ApplyToTool(cmd); break;
		case maker::CMD__EventToTool: onCmd_EventToTool(cmd); break;
		}
	}

	m_history.Redraw();
}

void CUIMakerDlg::Bind(const maker::Entity* entity)
{
	if (!m_field_bind.empty())
	{
		m_properties.DeleteAllItems();
		m_field_bind.clear();
	}

	if (!entity)
	{
		m_properties.Invalidate();
		return;
	}

	const ::google::protobuf::Message* msg = dynamic_cast<const ::google::protobuf::Message*>(&(entity->properties()));
	if (!msg) return;

	auto desc = msg->GetDescriptor();
	if (!desc) return;

	auto reflect = msg->GetReflection();
	if (!reflect) return;

	for (int i = 0; i < desc->field_count(); ++i)
	{
		auto* field = desc->field(i);

		if (!field) continue;
		if (field->is_repeated()) continue;
		if (field->type() != ::google::protobuf::FieldDescriptor::TYPE_MESSAGE) continue;

		if (!reflect->HasField(*msg, field)) continue;

		if (field->message_type()->name() == "Node")
		{
			Bind(dynamic_cast<const maker::Node*>(&(reflect->GetMessage(*msg, field))));
		}
		else
		{
			Bind(&(reflect->GetMessage(*msg, field)));
		}
	}

	m_properties.Invalidate();
}
void CUIMakerDlg::Bind(const maker::Node* node)
{
	auto* msg = dynamic_cast<const ::google::protobuf::Message*>(node);
	if (!msg) return;

	auto* desc = msg->GetDescriptor();
	if (!desc) return;

	auto* parent = m_properties.InsertItem(new CPropTreeItem());
	parent->SetLabelText(UTF16LE(desc->name()).c_str());
	parent->SetInfoText(_T("This is a root level item 1st Bind"));
	parent->Expand(); // have this item expanded by default

	for (int i = 0; i< desc->field_count(); ++i)
    {
		const auto* field = desc->field(i);
		if (!field) continue;

		Bind(parent, *msg, field);
	}
}
void CUIMakerDlg::Bind(const ::google::protobuf::Message* msg)
{
	if (!msg) return;

	auto* desc = msg->GetDescriptor();
	if (!desc) return;

	auto* parent = m_properties.InsertItem(new CPropTreeItem());
	parent->SetLabelText(UTF16LE(desc->name()).c_str());
	parent->SetInfoText(_T("This is a root level item"));
	parent->Expand(); // have this item expanded by default

	for (int i = 0; i< desc->field_count(); ++i) {
		const auto* field = desc->field(i);
		if (!field) continue;

		Bind(parent, *msg, field);
	}
}
void CUIMakerDlg::Bind(CPropTreeItem* parent, const ::google::protobuf::Message& msg, const ::google::protobuf::FieldDescriptor* field)
{
    if (!field || field->is_repeated()) return;

    auto reflect = msg.GetReflection();

    CPropTreeItem* property_item = nullptr;
    switch (field->cpp_type())
    {
    case ::google::protobuf::FieldDescriptor::CPPTYPE_INT32:
        {
            int v = reflect->GetInt32(msg, field);

            auto edit = (CPropTreeItemEdit*)m_properties.InsertItem(new CPropTreeItemEdit(), parent);
            edit->SetLabelText(UTF16LE(field->name()).c_str());
            edit->SetInfoText(_T("Number edit box"));
            edit->SetValueFormat(CPropTreeItemEdit::ValueFormat_Int32);
            edit->SetItem(v);

            property_item = dynamic_cast<CPropTreeItem*>(edit);
        }
        break;
    case ::google::protobuf::FieldDescriptor::CPPTYPE_INT64:
        {
            long long v = reflect->GetInt64(msg, field);

            auto edit = (CPropTreeItemEdit*)m_properties.InsertItem(new CPropTreeItemEdit(), parent);
            edit->SetLabelText(UTF16LE(field->name()).c_str());
            edit->SetInfoText(_T("Number edit box"));
            edit->SetValueFormat(CPropTreeItemEdit::ValueFormat_Int64);
            edit->SetItem(v);

            property_item = dynamic_cast<CPropTreeItem*>(edit);
        }
        break;
    case ::google::protobuf::FieldDescriptor::CPPTYPE_UINT32:
        {
            unsigned int v = reflect->GetUInt32(msg, field);

            auto edit = (CPropTreeItemEdit*)m_properties.InsertItem(new CPropTreeItemEdit(), parent);
            edit->SetLabelText(UTF16LE(field->name()).c_str());
            edit->SetInfoText(_T("Number edit box"));
            edit->SetValueFormat(CPropTreeItemEdit::ValueFormat_UInt32);
            edit->SetItem(v);

            property_item = dynamic_cast<CPropTreeItem*>(edit);
        }
        break;
    case ::google::protobuf::FieldDescriptor::CPPTYPE_UINT64:
        {
            unsigned long long v = reflect->GetUInt64(msg, field);

            auto edit = (CPropTreeItemEdit*)m_properties.InsertItem(new CPropTreeItemEdit(), parent);
            edit->SetLabelText(UTF16LE(field->name()).c_str());
            edit->SetInfoText(_T("Number edit box"));
            edit->SetValueFormat(CPropTreeItemEdit::ValueFormat_UInt64);
            edit->SetItem(v);

            property_item = dynamic_cast<CPropTreeItem*>(edit);
        }
        break;
    case ::google::protobuf::FieldDescriptor::CPPTYPE_DOUBLE:
        {
            double v = reflect->GetDouble(msg, field);

            auto edit = (CPropTreeItemEdit*)m_properties.InsertItem(new CPropTreeItemEdit(), parent);
            edit->SetLabelText(UTF16LE(field->name()).c_str());
            edit->SetInfoText(_T("Number edit box"));
            edit->SetValueFormat(CPropTreeItemEdit::ValueFormat_Double);
            edit->SetItem(v);

            property_item = dynamic_cast<CPropTreeItem*>(edit);
        }
        break;
    case ::google::protobuf::FieldDescriptor::CPPTYPE_FLOAT:
        {
            float v = reflect->GetFloat(msg, field);

            auto edit = (CPropTreeItemEdit*)m_properties.InsertItem(new CPropTreeItemEdit(), parent);
            edit->SetLabelText(UTF16LE(field->name()).c_str());
            edit->SetInfoText(_T("Number edit box"));
            edit->SetValueFormat(CPropTreeItemEdit::ValueFormat_Float);
            edit->SetItem(v);

            property_item = dynamic_cast<CPropTreeItem*>(edit);
        }
        break;
    case ::google::protobuf::FieldDescriptor::CPPTYPE_STRING:
        {
            std::string v = reflect->GetString(msg, field);

            auto edit = (CPropTreeItemEdit*)m_properties.InsertItem(new CPropTreeItemEdit(), parent);
            edit->SetLabelText(UTF16LE(field->name()).c_str());
            edit->SetInfoText(_T("Text edit box"));
            edit->SetValueFormat(CPropTreeItemEdit::ValueFormat_String);
            edit->SetItem(UTF16LE(v).c_str());

            property_item = dynamic_cast<CPropTreeItem*>(edit);
        }
        break;
    case ::google::protobuf::FieldDescriptor::CPPTYPE_BOOL:
        {
            bool v = reflect->GetBool(msg, field);

            CPropTreeItemCombo* combo = (CPropTreeItemCombo*)m_properties.InsertItem(new CPropTreeItemCombo(), parent);
            combo->SetLabelText(UTF16LE(field->name()).c_str());
            combo->SetInfoText(_T("This is a TRUE/FALSE dropdown combo list"));
            combo->CreateComboBoxBool();
            combo->SetItemValue(v ? TRUE : FALSE);

            property_item = dynamic_cast<CPropTreeItem*>(combo);
        }
        break;
    case ::google::protobuf::FieldDescriptor::CPPTYPE_ENUM:
        {
            auto* ev = reflect->GetEnum(msg, field);

            CPropTreeItemCombo* combo = (CPropTreeItemCombo*)m_properties.InsertItem(new CPropTreeItemCombo(), parent);
            combo->SetLabelText(UTF16LE(field->name()).c_str());
            combo->SetInfoText(_T("This is a TRUE/FALSE dropdown combo list"));
            combo->CreateComboBox(WS_CHILD | WS_VSCROLL | CBS_DROPDOWNLIST);

            int select = 0;
            auto edesc = ev->type();
            for (int i = 0; i < edesc->value_count(); ++i)
            {
                auto* evdesc = edesc->value(i);
                if (!evdesc) continue;

                std::string enum_name(CEntityMgr::getInstance()->getEnumNameforTool(evdesc));
                int idx = combo->InsertString(i, UTF16LE(enum_name).c_str());
                combo->SetItemData(idx, evdesc->number());

                if (ev == evdesc) select = i;
            }

            combo->SetCurSel(select);

            property_item = dynamic_cast<CPropTreeItem*>(combo);
        }
        break;
    case ::google::protobuf::FieldDescriptor::CPPTYPE_MESSAGE:
        {
            auto& v = reflect->GetMessage(msg, field);
            auto& type_name = v.GetDescriptor()->name();

            if (type_name == "COLOR")
            {
                auto color = dynamic_cast<const maker::COLOR*>(&v);
                if (!color) break;

                auto* desc = color->GetDescriptor();
                if (!desc) return;

                CPropTreeItemColor* pColor;
                pColor = (CPropTreeItemColor*)m_properties.InsertItem(new CPropTreeItemColor(), parent);
                pColor->SetLabelText(UTF16LE(field->name()).c_str());
                pColor->SetInfoText(_T("Color picker"));
                pColor->SetItemValue((LPARAM)RGB(color->r(), color->g(), color->b()));

                property_item = dynamic_cast<CPropTreeItem*>(pColor);
            }
            else if (type_name == "FILE")
            {
                property_item = appendPropetyItem<maker::FILE>(v, UTF16LE(field->name()).c_str(), _T("File name edit box"), CPropTreeItemEdit::ValueFormat_FILE, parent);
            }
            else if (type_name == "FILE_IMAGE")
            {
                property_item = appendPropetyItem<maker::FILE_IMAGE>(v, UTF16LE(field->name()).c_str(), _T("Image file name edit box"), CPropTreeItemEdit::ValueFormat_FILE_IMAGE, parent);
            }
            else if (type_name == "FILE_SOUND")
            {
                property_item = appendPropetyItem<maker::FILE_SOUND>(v, UTF16LE(field->name()).c_str(), _T("Sound file name edit box"), CPropTreeItemEdit::ValueFormat_FILE_SOUND, parent);
            }
            else if (type_name == "FILE_BMFONT")
            {
                property_item = appendPropetyItem<maker::FILE_BMFONT>(v, UTF16LE(field->name()).c_str(), _T("BMFont file name edit box"), CPropTreeItemEdit::ValueFormat_FILE_BMFONT, parent);
            }
            else if (type_name == "FILE_TTF")
            {
                property_item = appendPropetyItem<maker::FILE_TTF>(v, UTF16LE(field->name()).c_str(), _T("TTF file name edit box"), CPropTreeItemEdit::ValueFormat_FILE_TTF, parent);
            }
            else if (type_name == "FILE_VISUAL")
            {
                property_item = appendPropetyItem<maker::FILE_VISUAL>(v, UTF16LE(field->name()).c_str(), _T("Visual file name edit box"), CPropTreeItemEdit::ValueFormat_FILE_VISUAL, parent);
            }
            else if (type_name == "FILE_PLIST")
            {
                property_item = appendPropetyItem<maker::FILE_PLIST>(v, UTF16LE(field->name()).c_str(), _T("Visual file name edit box"), CPropTreeItemEdit::ValueFormat_FILE_PLIST, parent);
            }
            else if (type_name == "NAME_VISUAL")
            {
                property_item = appendPropetyItem<maker::NAME_VISUAL>(v, UTF16LE(field->name()).c_str(), _T("Visual name combo box"), parent);
            }
            else
            {
                Bind(&v);
            }
        }
        break;
    default:
        std::string msg("unknown field type - ");
        msg += field->name();
        OutputDebugString(UTF16LE(msg.c_str()).c_str());
        break;
    }

    if (property_item)
    {
        m_field_bind.insert(TYPE_FIELD_BIND_MAP::value_type(field, property_item));
    }
}
template <typename T>
CPropTreeItem* CUIMakerDlg::appendPropetyItem(const ::google::protobuf::Message& msg, const TCHAR* field_name, const TCHAR* desc, CPropTreeItemEdit::ValueFormat format, CPropTreeItem* parent)
{
	auto t = dynamic_cast<const T*>(&msg);
	if (!t) return nullptr;

	CPropTreeItemEdit* edit;
	edit = (CPropTreeItemEdit*)m_properties.InsertItem(new CPropTreeItemEdit(), parent);
	edit->SetLabelText(field_name);
	edit->SetInfoText(desc);
	edit->SetValueFormat(format);
	edit->SetItem(UTF16LE(CEntityMgr::getInstance()->refineFilePath(t->path())).c_str());

	return dynamic_cast<CPropTreeItem*>(edit);
}
template <typename T>
CPropTreeItem* CUIMakerDlg::appendPropetyItem(const ::google::protobuf::Message& msg, const TCHAR* field_name, const TCHAR* desc, CPropTreeItem* parent)
{
	auto t = dynamic_cast<const T*>(&msg);
	if (!t) return nullptr;

	CPropTreeItemCombo* combo = (CPropTreeItemCombo*)m_properties.InsertItem(new CPropTreeItemCombo(), parent);
	combo->SetLabelText(field_name);
	combo->SetInfoText(desc);
	combo->CreateComboBox(WS_CHILD | WS_VSCROLL | CBS_DROPDOWNLIST);
	combo->SetFormat(CPropTreeItemCombo::ValueFormat_STRING);

	return dynamic_cast<CPropTreeItem*>(combo);
}


void CUIMakerDlg::applyBind(const maker::Entity& entity, const maker::CMD& cmd)
{
    auto properties = entity.properties();
    auto desc = properties.GetDescriptor();
    auto reflect = properties.GetReflection();
    if (desc && reflect)
    {
        for (int i = 0; i < desc->field_count(); ++i)
        {
            auto field = desc->field(i);

            if (!field) continue;
            if (field->is_repeated()) continue;
            if (field->type() != ::google::protobuf::FieldDescriptor::TYPE_MESSAGE) continue;

            if (!reflect->HasField(properties, field)) continue;

            auto& property = reflect->GetMessage(properties, field);

            auto property_desc = property.GetDescriptor();
            auto property_reflect = property.GetReflection();
            if (!property_desc) return;

            for (int i = 0; i < property_desc->field_count(); ++i)
            {
                auto property_field = property_desc->field(i);

                if (!property_field) continue;
                if (property_field->is_repeated()) continue;
                if (!property_reflect->HasField(property, property_field)) continue;

                auto iter = m_field_bind.find(property_field);
                if (iter == m_field_bind.end()) continue;

                auto property_item = iter->second;
                if (!property_item) continue;

                CPropTreeItemEdit* edit = dynamic_cast<CPropTreeItemEdit*>(property_item);
                CPropTreeItemCombo* combo = dynamic_cast<CPropTreeItemCombo*>(property_item);
                CPropTreeItemColor* color = dynamic_cast<CPropTreeItemColor*>(property_item);
                switch (property_field->cpp_type())
                {
                case ::google::protobuf::FieldDescriptor::CPPTYPE_INT32:
                    if (edit) edit->SetItem(property_reflect->GetInt32(property, property_field));
                    break;
                case ::google::protobuf::FieldDescriptor::CPPTYPE_INT64:
                    if (edit) edit->SetItem(property_reflect->GetInt64(property, property_field));
                    break;
                case ::google::protobuf::FieldDescriptor::CPPTYPE_UINT32:
                    if (edit) edit->SetItem(property_reflect->GetUInt32(property, property_field));
                    break;
                case ::google::protobuf::FieldDescriptor::CPPTYPE_UINT64:
                    if (edit) edit->SetItem(property_reflect->GetInt64(property, property_field));
                    break;
                case ::google::protobuf::FieldDescriptor::CPPTYPE_DOUBLE:
                    if (edit) edit->SetItem(property_reflect->GetDouble(property, property_field));
                    break;
                case ::google::protobuf::FieldDescriptor::CPPTYPE_FLOAT:
                    if (edit) edit->SetItem(property_reflect->GetFloat(property, property_field));
					break;
                case ::google::protobuf::FieldDescriptor::CPPTYPE_STRING:
                    if (edit) edit->SetItem(UTF16LE(property_reflect->GetString(property, property_field)).c_str());
                    break;
                case ::google::protobuf::FieldDescriptor::CPPTYPE_BOOL:
                    if (combo) combo->SetItemValue(property_reflect->GetBool(property, property_field) ? TRUE : FALSE);
                    break;
                case ::google::protobuf::FieldDescriptor::CPPTYPE_ENUM:
                    if (combo)
                    {
                        auto ev = property_reflect->GetEnum(property, property_field);

                        int select = 0;
                        auto edesc = ev->type();
                        for (int i = 0; i < edesc->value_count(); ++i)
                        {
                            auto evdesc = edesc->value(i);
                            if (!evdesc) continue;

                            if (ev == evdesc) select = i;
                        }

                        if (select != combo->GetCurSel())
                        {
                            combo->SetCurSel(select);
                        }
                    }
                    break;
                case ::google::protobuf::FieldDescriptor::CPPTYPE_MESSAGE:
                    {
                        auto& v = property_reflect->GetMessage(property, property_field);

                        if (v.GetDescriptor()->name() == "COLOR")
                        {
                            auto color = dynamic_cast<const maker::COLOR*>(&v);
                            if (!color) break;

                            auto* desc = color->GetDescriptor();
                            if (!desc) break;

                            auto pColor = dynamic_cast<CPropTreeItemColor*>(property_item);
                            if (pColor) pColor->SetItemValue((LPARAM)RGB(color->r(), color->g(), color->b()));
                        }
                        else if (CEntityMgr::isFileProperty(v.GetDescriptor()->name()))
                        {
                            auto file_desc = v.GetDescriptor();
                            auto file_reflect = v.GetReflection();
                            if (!file_desc || !file_reflect) break;

                            auto pFile = dynamic_cast<CPropTreeItemEdit*>(property_item);
                            if (pFile)
                            {
                                auto file_path = file_reflect->GetString(v, file_desc->FindFieldByName("path"));
                                auto refined_file_path = CEntityMgr::getInstance()->refineFilePath(file_path);
                                pFile->SetItem(UTF16LE(refined_file_path).c_str());
                            }
                        }
                        else if (CEntityMgr::isEnumNameProperty(v.GetDescriptor()->name()))
                        {
                            auto name_desc = v.GetDescriptor();
                            auto name_reflect = v.GetReflection();
                            if (!name_desc || !name_reflect) break;

                            auto name = name_reflect->GetString(v, name_desc->FindFieldByName("name"));

                            auto combo = dynamic_cast<CPropTreeItemCombo*>(property_item);
                            if (combo)
                            {
                                int select = 0;

                                if (cmd.type() == maker::CMD__ApplyToTool && cmd.enum_list_size() > 0)
                                {
                                    combo->ResetContent();
                                    for (int i = 0; i < cmd.enum_list_size(); ++i)
                                    {
                                        auto& enum_name = cmd.enum_list().Get(i);;
                                        int idx = combo->InsertString(i, UTF16LE(enum_name).c_str());
                                        combo->SetItemData(idx, i);

                                        if (name == enum_name) select = i;
                                    }
                                }
                                else
                                {
                                    select = combo->FindString(-1, UTF16LE(name).c_str());
                                }

                                combo->SetCurSel(select);
                            }
                        }
                        else
                        {
                            //Bind(&v);
                        }
                    }
                    break;
                default:
                    std::string msg("unknown field type - ");
                    msg += field->name();
                    OutputDebugString(UTF16LE(msg.c_str()).c_str());
                    break;
                }
            }
        }
    }

    m_properties.Invalidate();
	//m_luaname_list_view.Redraw();
}

void CUIMakerDlg::onCmd_Create(const maker::CMD& cmd)
{
	for (auto& entity : cmd.entities())
	{
		auto new_entity = CEntityMgr::getInstance()->create(entity.id(), entity.parent_id(), entity.properties(), entity.children());
		if (!new_entity) continue;

		if (entity.has_dest_id())
		{
			CEntityMgr::getInstance()->moveNext(entity.id(), entity.parent_id(), entity.dest_id(), entity.dest_parent_id());
		}

		if (cmd.type() == maker::CMD__Paste)
		{
			CCMDPipe::getInstance()->applyToViewer(new_entity);
		}
	}

	m_entity_list_view.Redraw();
	m_luaname_list_view.Redraw();

	if (cmd.type() != maker::CMD__Paste)
	{
		maker::CMD select_cmd;
		CCMDPipe::initSelect(select_cmd, cmd);
		CCMDPipe::getInstance()->send(select_cmd);
	}
}
void CUIMakerDlg::onCmd_Remove(const maker::CMD& cmd)
{
	for (auto& entity : cmd.entities())
	{
		if (CEntityMgr::getInstance()->remove(entity.id(), entity.parent_id()))
		{
			// error log
		}
	}

	Bind((const maker::Entity*)nullptr);

	m_entity_list_view.Redraw();
	m_luaname_list_view.Redraw();
}
void CUIMakerDlg::onCmd_Move(const maker::CMD& cmd)
{
	for (auto& entity : cmd.entities())
	{
		CEntityMgr::getInstance()->moveNext(entity.id(), entity.parent_id(), entity.dest_id(), entity.dest_parent_id());
	}
	m_entity_list_view.Redraw();
	m_luaname_list_view.Redraw();
}
void CUIMakerDlg::onCmd_Modify(const maker::CMD& cmd)
{
	for (auto& entity : cmd.entities())
	{
		onCmd_Modify(CEntityMgr::getInstance()->get(entity.id()), entity.properties(), cmd);
	}
}
void CUIMakerDlg::onCmd_Modify(maker::Entity* entity, const maker::Properties& properties, const maker::CMD& cmd)
{
	if (!entity) return;

	entity->mutable_properties()->MergeFrom(properties);

	if (entity == CEntityMgr::getInstance()->getCurrent())
	{
		applyBind(*entity, cmd);

		if (cmd.type() == maker::CMD__ApplyToTool && entity->properties().type() == maker::ENTITY__Visual)
		{
			auto& socket_node_list = cmd.socket_node_list();
			for (int child_index = 0; child_index < entity->children_size();)
			{
				bool remove_socket_node = false;
				auto& child = entity->children().Get(child_index);
				auto& properties = child.properties();
				if (properties.has_socket_node())
				{
					remove_socket_node = true;
					auto& child_socket_node_name = properties.socket_node().socket_name();
					for (auto socket_name : cmd.socket_node_list())
					{
						auto socket_name_splt_pos = socket_name.find(";");
						if (socket_name_splt_pos != std::string::npos)
						{
							socket_name = socket_name.substr(socket_name_splt_pos + 1);
						}
						if (child_socket_node_name == socket_name)
						{
							remove_socket_node = false;
							break;
						}
					}
				}
				if (remove_socket_node)
				{
					while(child.children_size())
					{
						auto& ch = child.children().Get(0);
						CEntityMgr::getInstance()->moveNext(ch.id(), child.id(), 0, entity->id());
					}
					CEntityMgr::getInstance()->remove(child.id(), entity->id());
				}
				else
				{
					++child_index;
				}
			}
			auto tmp_uinode = CEntityMgr::getInstance()->get(entity->id());
			auto tmp_children = tmp_uinode->children();
			for (auto socket_name : cmd.socket_node_list())
			{
				auto booked_id = 0;
				auto socket_name_splt_pos = socket_name.find(";");
				if (socket_name_splt_pos != std::string::npos)
				{
					booked_id = atoi(socket_name.substr(0, socket_name_splt_pos).c_str());
					socket_name = socket_name.substr(socket_name_splt_pos + 1);
				}

				bool append = true;
				for (auto& child : entity->children())
				{
					if (child.properties().has_socket_node())
					{
						if (child.properties().socket_node().socket_name() == socket_name)
						{
							append = false;
							break;
						}
					}
				}
				if (!append) continue;

				maker::Properties properties;
				properties.set_type(maker::ENTITY__SocketNode);
				auto socket_node = properties.mutable_socket_node();
				if (!socket_node) continue;

				socket_node->set_socket_name(socket_name);

				::google::protobuf::RepeatedPtrField< ::maker::Entity > empty_children;

				CEntityMgr::getInstance()->create(booked_id, entity->id(), properties, empty_children);
			}

			m_entity_list_view.Invalidate();
			m_luaname_list_view.Invalidate();
		}
	}
}
void CUIMakerDlg::onCmd_SizeToContent(const maker::CMD& cmd)
{
    // CMakerScene에서 모든 처리(속성창과의 동기화 처리 포함)를 하고 있으므로 여기서는 별도의 처리가 필요 없다.
}
void CUIMakerDlg::onCmd_SelectOne(const maker::CMD& cmd)
{
	m_properties.DeleteAllItems();
	m_field_bind.clear();

	CEntityMgr::getInstance()->clearAllSelectedFlag();

	onCmd_SelectAppend(cmd);
}
void CUIMakerDlg::onCmd_SelectAppend(const maker::CMD& cmd)
{
	bool binded = false;
	for (auto& entity : cmd.entities())
	{
		auto selected_entity = CEntityMgr::getInstance()->get(entity.id());
		if (!selected_entity) continue;

		selected_entity->set_selected(!selected_entity->selected());

		if (selected_entity->selected())
		{
			if (!binded)
			{
				binded = true;
				Bind(selected_entity);

				m_entity_list_view.SetCurrentEntity(entity.id());
				m_luaname_list_view.SetCurrentEntity(entity.id());
			}
		}
	}

	m_entity_list_view.Invalidate();
	m_luaname_list_view.Invalidate();
}
void CUIMakerDlg::onCmd_SelectBoxAppend(const maker::CMD& cmd)
{
	m_properties.DeleteAllItems();
	m_field_bind.clear();

	CEntityMgr::getInstance()->clearAllSelectedFlag();

	bool binded = false;
	for (auto& entity : cmd.entities())
	{
		auto selected_entity = CEntityMgr::getInstance()->get(entity.id());
		if (!selected_entity) continue;

		selected_entity->set_selected(true);

		if (!binded)
		{
			binded = true;
			Bind(selected_entity);

			m_entity_list_view.SetCurrentEntity(entity.id());
			m_luaname_list_view.SetCurrentEntity(entity.id());
		}
	}

	m_entity_list_view.Invalidate();
	m_luaname_list_view.Invalidate();
}
void CUIMakerDlg::onCmd_ApplyToTool(const maker::CMD& cmd)
{
	onCmd_Modify(cmd);
}
void CUIMakerDlg::onCmd_EventToTool(const maker::CMD& cmd)
{
	switch (cmd.event_id())
	{
	case maker::EVENT__Save: onFileSaveUi(); break;
	case maker::EVENT__SaveAs: onFileSaveUiAs(); break;
	case maker::EVENT__Open: onFileOpenUi(); break;
	case maker::EVENT__Close: onFileCloseUi();
	case maker::EVENT__Copy: onCopy(); break;
	case maker::EVENT__Cut: onCut(); break;
	case maker::EVENT__Paste: onPaste(); break;
	case maker::EVENT__Remove: onRemove(); break;
    case maker::EVENT__ToggleDisplayStats: onToggleDisplayStats(); break;
	case maker::EVENT__ReopenView: onReopenView(); break;
	case maker::EVENT__NextResolution: onNextResolution(); break;
	case maker::EVENT__PrevResolution: onPrevResolution(); break;
	case maker::EVENT__SpecResolution: onSpecificResolution(); break;
	case maker::EVENT__ConfResolution: onConfigResolution(true); break;
	case maker::EVENT__ToggleVisible: onToggleVisible(); break;
	}
}
void CUIMakerDlg::onCmd_AddCmdHistory(const maker::CMD& cmd)
{

}

void CUIMakerDlg::onSize(int cx, int cy)
{
#if PROJECT_ == PROJECT_DV
	if (::IsWindow(m_entity_list_view.GetSafeHwnd()))
	{
		m_entity_list_view.MoveWindow(0, 0, cx - m_propertiesWidth - SPLITER_WIDTH, cy - (m_historyHeight + SPLITER_HEIGHT));
	}

	if (::IsWindow(m_properties.GetSafeHwnd()))
	{
		m_properties.MoveWindow(cx - m_propertiesWidth, 0, m_propertiesWidth, cy - (m_historyHeight + SPLITER_HEIGHT));
	}

	if (::IsWindow(m_history.GetSafeHwnd()))
	{
		m_history.MoveWindow(0, cy - m_historyHeight, cx - m_propertiesWidth - SPLITER_WIDTH, m_historyHeight);
	}

	if (::IsWindow(m_luaname_list_view.GetSafeHwnd()))
	{
		m_luaname_list_view.MoveWindow(cx - m_propertiesWidth, cy - m_historyHeight, m_propertiesWidth, m_historyHeight);
	}
#elif PROJECT_ == PROJECT_DH
	auto pos_x = 0;
	auto pos_y = 0;
	auto width = 0;
	auto height = 0;
	if (::IsWindow(m_entity_list_view.GetSafeHwnd()))
	{
		pos_x = 0;
		pos_y = 0; 
		width = cx - m_propertiesWidth - m_luanameWidth - m_historyWidth - SPLITER_WIDTH * 3;
		height = cy;
		m_entity_list_view.MoveWindow(pos_x, pos_y, width, height);
	}

	if (::IsWindow(m_properties.GetSafeHwnd()))
	{
		pos_x = cx - m_propertiesWidth - m_luanameWidth - m_historyWidth - SPLITER_WIDTH * 2;
		pos_y = 0; 
		width = m_propertiesWidth;
		height = cy;
		m_properties.MoveWindow(pos_x, pos_y, width, height);
	}

	if (::IsWindow(m_luaname_list_view.GetSafeHwnd()))
	{
		pos_x = cx - m_luanameWidth - m_historyWidth - SPLITER_WIDTH * 1;
		pos_y = 0;
		width = m_luanameWidth;
		height = cy;
		m_luaname_list_view.MoveWindow(pos_x, pos_y, width, height);
	}

	if (::IsWindow(m_history.GetSafeHwnd()))
	{
		pos_x = cx - m_historyWidth;
		pos_y = 0;
		width = m_historyWidth;
		height = cy;
		m_history.MoveWindow(pos_x, pos_y, width, height);
	}
#endif
}

void CUIMakerDlg::OnSize(UINT nType, int cx, int cy)
{
	CDialogEx::OnSize(nType, cx, cy);

	onSize(cx, cy);
}
void CUIMakerDlg::onMove()
{
    short code = GetAsyncKeyState(VK_CONTROL);
    if (!(code & 0x8000))
        return;

    CRect rcwindow;
    GetWindowRect(&rcwindow);

    maker::CMD cmd;
    cmd.set_type(maker::CMD__MoveViewer);
    cmd.set_window_x(rcwindow.left);
    cmd.set_window_y(rcwindow.top);
    CCMDPipe::getInstance()->send(cmd);
}
void CUIMakerDlg::OnMove(int x, int y)
{
	CDialogEx::OnMove(x, y);

	onMove();
}
void CUIMakerDlg::SendOpenViewer()
{
	static NMHDR nm;
	UINT id = (UINT)::GetMenu(m_hWnd);
	nm.code = NOTIFY_CODE__OPEN_VIEWER;
	nm.hwndFrom = m_hWnd;
	nm.idFrom = (UINT)::GetMenu(m_hWnd);

	PostMessage(WM_NOTIFY, (WPARAM)id, (LPARAM)&nm);
}

///////////////////////////////////
// properties spliter
//////////////////////////////////
bool CUIMakerDlg::IsPickPropertiesSpliter(CPoint point)
{
	CRect rcclient;
	GetClientRect(&rcclient);
	CRect rcspliter = rcclient;
#if PROJECT_ == PROJECT_DV
	rcspliter.right = rcclient.Width() - m_propertiesWidth;
	rcspliter.left = rcspliter.right - SPLITER_WIDTH;
	rcspliter.bottom = rcclient.Height();
#elif PROJECT_ == PROJECT_DH
	rcspliter.right = rcclient.Width() - m_propertiesWidth - m_luanameWidth - m_historyWidth - SPLITER_WIDTH * 2;
	rcspliter.left = rcspliter.right - SPLITER_WIDTH;
	rcspliter.bottom = rcclient.Height();
#endif
	return rcspliter.PtInRect(point) == TRUE;
}
void CUIMakerDlg::DrawPickPropertiesSpliter(int prevX, int x)
{
	CRect rcclient;
	GetClientRect(rcclient);
	CDC* pDC = GetDC();
	if (prevX != DONT_DRAW_SPLITER)	pDC->PatBlt(prevX - SPLITER_WIDTH / 2, 0, SPLITER_WIDTH, rcclient.bottom, PATINVERT);
	if (x != DONT_DRAW_SPLITER) pDC->PatBlt(x - SPLITER_WIDTH / 2, 0, SPLITER_WIDTH, rcclient.bottom, PATINVERT);
	ReleaseDC(pDC);
}
int CUIMakerDlg::AdjustByPropertiesWidth(int cursorX)
{
	CRect rcclient;
	GetClientRect(rcclient);

	int width = rcclient.Width() - cursorX;
#if PROJECT_ == PROJECT_DV
	if (width < MIN_PROPERTIES_WIDTH) width = MIN_PROPERTIES_WIDTH;
	if (rcclient.Width() - SPLITER_WIDTH - width < MIN_PROPERTIES_WIDTH) width = rcclient.Width() - SPLITER_WIDTH - MIN_PROPERTIES_WIDTH;
#elif PROJECT_ == PROJECT_DH
	if (width - (m_luanameWidth + m_historyWidth) < MIN_PROPERTIES_WIDTH*2) width = MIN_PROPERTIES_WIDTH*2 + m_luanameWidth + m_historyWidth;
#endif

	return rcclient.Width() - width;
}

///////////////////////////////////
// history height spliter
//////////////////////////////////
bool CUIMakerDlg::IsPickHistorySpliter(CPoint point)
{
	CRect rcclient;
	GetClientRect(&rcclient);

	CRect rcspliter = rcclient;
	rcspliter.top = rcclient.Height() - (m_historyHeight + SPLITER_HEIGHT);
	rcspliter.bottom = rcspliter.top + SPLITER_HEIGHT;

	return rcspliter.PtInRect(point) == TRUE;
}
void CUIMakerDlg::DrawPickHistorySpliter(int prevY, int y)
{
	CRect rcclient;
	GetClientRect(rcclient);

	CDC* pDC = GetDC();
	if (prevY != DONT_DRAW_SPLITER) pDC->PatBlt(0, prevY - SPLITER_HEIGHT / 2, rcclient.right, SPLITER_HEIGHT, PATINVERT);
	if (y != DONT_DRAW_SPLITER) pDC->PatBlt(0, y - SPLITER_HEIGHT / 2, rcclient.right, SPLITER_HEIGHT, PATINVERT);
	ReleaseDC(pDC);
}
int CUIMakerDlg::AdjustByHistoryHeight(int cursorY)
{
	CRect rcclient;
	GetClientRect(rcclient);

	int height = rcclient.Height() - cursorY;
	if (height < MIN_HISTORY_HEIGHT) height = MIN_HISTORY_HEIGHT;
	if (rcclient.Height() - SPLITER_HEIGHT - height < MIN_HISTORY_HEIGHT) height = rcclient.Height() - SPLITER_HEIGHT - MIN_HISTORY_HEIGHT;

	return rcclient.Height() - height;
}

///////////////////////////////////
// luaname spliter
//////////////////////////////////
bool CUIMakerDlg::IsPickLuanameSpliter(CPoint point)
{
	CRect rcclient;
	GetClientRect(&rcclient);
	CRect rcspliter = rcclient;

	rcspliter.right = rcclient.Width() - m_luanameWidth - m_historyWidth - SPLITER_WIDTH * 1;
	rcspliter.left = rcspliter.right - SPLITER_WIDTH;
	rcspliter.bottom = rcclient.Height();

	return rcspliter.PtInRect(point) == TRUE;
}
void CUIMakerDlg::DrawPickLuanameSpliter(int prevX, int x)
{
	CRect rcclient;
	GetClientRect(rcclient);
	CDC* pDC = GetDC();

	if (prevX != DONT_DRAW_SPLITER)	pDC->PatBlt(prevX - SPLITER_WIDTH / 2, 0, SPLITER_WIDTH, rcclient.bottom, PATINVERT);
	if (x != DONT_DRAW_SPLITER) pDC->PatBlt(x - SPLITER_WIDTH / 2, 0, SPLITER_WIDTH, rcclient.bottom, PATINVERT);

	ReleaseDC(pDC);
}
int CUIMakerDlg::AdjustByLuanameWidth(int cursorX)
{
	CRect rcclient;
	GetClientRect(rcclient);

	int width = rcclient.Width() - cursorX;
	if (width - m_historyWidth < MIN_PROPERTIES_WIDTH * 2) width = MIN_PROPERTIES_WIDTH * 2 + m_historyWidth;
	
	return rcclient.Width() - width;
}

///////////////////////////////////
// history width spliter
//////////////////////////////////
bool CUIMakerDlg::IsPickHistoryWidthSpliter(CPoint point)
{
	CRect rcclient;
	GetClientRect(&rcclient);
	CRect rcspliter = rcclient;

	rcspliter.right = rcclient.Width() - m_historyWidth;
	rcspliter.left = rcspliter.right - SPLITER_WIDTH;
	rcspliter.bottom = rcclient.Height();

	return rcspliter.PtInRect(point) == TRUE;
}
void CUIMakerDlg::DrawPickHistoryWidthSpliter(int prevX, int x)
{
	CRect rcclient;
	GetClientRect(rcclient);
	CDC* pDC = GetDC();

	if (prevX != DONT_DRAW_SPLITER)	pDC->PatBlt(prevX - SPLITER_WIDTH / 2, 0, SPLITER_WIDTH, rcclient.bottom, PATINVERT);
	if (x != DONT_DRAW_SPLITER) pDC->PatBlt(x - SPLITER_WIDTH / 2, 0, SPLITER_WIDTH, rcclient.bottom, PATINVERT);

	ReleaseDC(pDC);
}
int CUIMakerDlg::AdjustByHistoryWidth(int cursorX)
{
	CRect rcclient;
	GetClientRect(rcclient);

	int width = rcclient.Width() - cursorX;
	if (width < MIN_PROPERTIES_WIDTH) width = MIN_PROPERTIES_WIDTH;

	return rcclient.Width() - width;
}

///////////////////////////////////
// on Function s
//////////////////////////////////
void CUIMakerDlg::OnMouseMove(UINT nFlags, CPoint point)
{
	// PROPETIES
	if (IsPickPropertiesSpliter(point))
	{
		SetCursor(LoadCursor(0, IDC_SIZEWE));
	}
	if (m_pickPropertiesSpliter)
	{
		int x = AdjustByPropertiesWidth(point.x);

		DrawPickPropertiesSpliter(m_prevPick, x);

		m_prevPick = x;
		return;
	}

#if PROJECT_ == PROJECT_DV
	// HISTORY HEIGHT
	if (IsPickHistorySpliter(point))
	{
		SetCursor(LoadCursor(0, IDC_SIZENS));
	}
	if (m_pickHistorySpliter)
	{
		int y = AdjustByHistoryHeight(point.y);

		DrawPickHistorySpliter(m_prevPick, y);

		m_prevPick = y;
		return;
	}
#elif PROJECT_ == PROJECT_DH
	// LUA WIDTH
	if (IsPickLuanameSpliter(point))
	{
		SetCursor(LoadCursor(0, IDC_SIZEWE));
	}
	if (m_isPickLuanameSpliter)
	{
		int x = AdjustByLuanameWidth(point.x);

		DrawPickLuanameSpliter(m_prevPick, x);

		m_prevPick = x;
		return;
	}
	// HISTORY WIDTH
	if (IsPickHistoryWidthSpliter(point))
	{
		SetCursor(LoadCursor(0, IDC_SIZEWE));
	}
	if (m_isPickHistoryWidthSpliter)
	{
		int x = AdjustByHistoryWidth(point.x);

		DrawPickHistoryWidthSpliter(m_prevPick, x);

		m_prevPick = x;
		return;
	}
#endif
	CDialogEx::OnMouseMove(nFlags, point);
}
void CUIMakerDlg::OnLButtonDown(UINT nFlags, CPoint point)
{
	if (IsPickPropertiesSpliter(point))
	{
		SetCursor(LoadCursor(0, IDC_SIZEWE));

		int x = AdjustByPropertiesWidth(point.x);

		DrawPickPropertiesSpliter(DONT_DRAW_SPLITER, x);

		m_prevPick = x;
		m_pickPropertiesSpliter = true;
		SetCapture();
	}
#if PROJECT_ == PROJECT_DV
	else if (IsPickHistorySpliter(point))
	{
		SetCursor(LoadCursor(0, IDC_SIZENS));

		int y = AdjustByHistoryHeight(point.y);

		DrawPickHistorySpliter(DONT_DRAW_SPLITER, y);

		m_prevPick = y;
		m_pickHistorySpliter = true;
		SetCapture();
	}
#elif PROJECT_ == PROJECT_DH
	else if (IsPickLuanameSpliter(point))
	{
		SetCursor(LoadCursor(0, IDC_SIZEWE));

		int x = AdjustByLuanameWidth(point.x);

		DrawPickLuanameSpliter(DONT_DRAW_SPLITER, x);

		m_prevPick = x;
		m_isPickLuanameSpliter = true;
		SetCapture();
	}

	else if (IsPickHistoryWidthSpliter(point))
	{
		SetCursor(LoadCursor(0, IDC_SIZEWE));

		int x = AdjustByHistoryWidth(point.x);

		DrawPickHistoryWidthSpliter(DONT_DRAW_SPLITER, x);

		m_prevPick = x;
		m_isPickHistoryWidthSpliter = true;
		SetCapture();
	}
#endif
	CDialogEx::OnLButtonDown(nFlags, point);
}
void CUIMakerDlg::OnLButtonUp(UINT nFlags, CPoint point)
{
	if (m_pickPropertiesSpliter)
	{
		SetCursor(LoadCursor(0, IDC_SIZEWE));

		int x = AdjustByPropertiesWidth(point.x);

		CRect rcclient;
		GetClientRect(&rcclient);

#if PROJECT_ == PROJECT_DV
		m_propertiesWidth = rcclient.Width() - x;
#elif PROJECT_ == PROJECT_DH
		m_propertiesWidth = rcclient.Width() - (x + m_luanameWidth + m_historyWidth);
#endif

		DrawPickPropertiesSpliter(m_prevPick, DONT_DRAW_SPLITER);

		m_pickPropertiesSpliter = false;
		ReleaseCapture();

		OnSize(SIZE_RESTORED, rcclient.Width(), rcclient.Height());
	}
#if PROJECT_ == PROJECT_DV
	else if (m_pickHistorySpliter)
	{
		SetCursor(LoadCursor(0, IDC_SIZEWE));

		int y = AdjustByHistoryHeight(point.y);

		CRect rcclient;
		GetClientRect(&rcclient);
		m_historyHeight = rcclient.Height() - y;

		DrawPickHistorySpliter(m_prevPick, DONT_DRAW_SPLITER);

		m_pickHistorySpliter = false;
		ReleaseCapture();

		OnSize(SIZE_RESTORED, rcclient.Width(), rcclient.Height());
	}
#elif PROJECT_ == PROJECT_DH
	else if (m_isPickLuanameSpliter)
	{
		SetCursor(LoadCursor(0, IDC_SIZEWE));

		int x = AdjustByLuanameWidth(point.x);

		CRect rcclient;
		GetClientRect(&rcclient);

		m_luanameWidth = rcclient.Width() - (x + m_historyWidth);

		DrawPickLuanameSpliter(m_prevPick, DONT_DRAW_SPLITER);

		m_isPickLuanameSpliter = false;
		ReleaseCapture();

		OnSize(SIZE_RESTORED, rcclient.Width(), rcclient.Height());
	}

	else if (m_isPickHistoryWidthSpliter)
	{
		SetCursor(LoadCursor(0, IDC_SIZEWE));

		int x = AdjustByHistoryWidth(point.x);

		CRect rcclient;
		GetClientRect(&rcclient);

		m_historyWidth = rcclient.Width() - x;

		DrawPickHistoryWidthSpliter(m_prevPick, DONT_DRAW_SPLITER);

		m_isPickHistoryWidthSpliter = false;
		ReleaseCapture();

		OnSize(SIZE_RESTORED, rcclient.Width(), rcclient.Height());
	}
#endif
	CDialogEx::OnLButtonUp(nFlags, point);
}


BOOL CUIMakerDlg::OnNotify(WPARAM wParam, LPARAM lParam, LRESULT* pResult)
{
	if (!lParam) return CDialogEx::OnNotify(wParam, lParam, pResult);

	LPNMPROPTREE nmmp = (LPNMPROPTREE)lParam;
	if (nmmp->hdr.code == PTN_ITEMCHANGED && nmmp->hdr.hwndFrom == m_properties.GetSafeHwnd())
	{
		auto current_entity = CEntityMgr::getInstance()->getCurrent();
		if (!current_entity) return FALSE;

		auto item = nmmp->pItem;
		if (!item) return FALSE;

		auto item_parent = item->GetParent();
		if (!item_parent) return FALSE;

		std::string property_group_name(UTF8(item_parent->GetLabelText()));
		std::string property_name(UTF8(item->GetLabelText()));

		CCMDPipe::VAR v;
		auto item_edit = dynamic_cast<CPropTreeItemEdit*>(nmmp->pItem);
		if (item_edit)
		{
			auto format_type = item_edit->GetValueFormat();

			if (format_type >= CPropTreeItemEdit::ValueFormat_FILE)
			{
				auto tmp = item_edit->GetItem_String();
				bool changeed = tmp.Replace(_T('\\'), _T('/')) != 0;
				v = CCMDPipe::VAR(UTF8(LPCTSTR(tmp)));
				switch (format_type)
				{
				case CPropTreeItemEdit::ValueFormat_FILE:        v.m_type = CCMDPipe::VAR::TYPE::FILE; break;
				case CPropTreeItemEdit::ValueFormat_FILE_IMAGE:  v.m_type = CCMDPipe::VAR::TYPE::FILE_IMAGE; break;
				case CPropTreeItemEdit::ValueFormat_FILE_SOUND:  v.m_type = CCMDPipe::VAR::TYPE::FILE_SOUND; break;
				case CPropTreeItemEdit::ValueFormat_FILE_BMFONT: v.m_type = CCMDPipe::VAR::TYPE::FILE_BMFONT; break;
				case CPropTreeItemEdit::ValueFormat_FILE_TTF:    v.m_type = CCMDPipe::VAR::TYPE::FILE_TTF; break;
				case CPropTreeItemEdit::ValueFormat_FILE_VISUAL: v.m_type = CCMDPipe::VAR::TYPE::FILE_VISUAL; break;
				case CPropTreeItemEdit::ValueFormat_FILE_PLIST:  v.m_type = CCMDPipe::VAR::TYPE::FILE_PLIST; break;
				}

				auto refined_file_path = CEntityMgr::getInstance()->refineFilePath(v.m_string);
				if (changeed || refined_file_path != v.m_string)
				{
					item_edit->SetItem(UTF16LE(refined_file_path).c_str());
					m_properties.Invalidate();
				}
				else
				{
					v.m_string = CEntityMgr::getInstance()->getBaseFolderPath() + v.m_string;
				}
			}
			else
			{
				switch (format_type)
				{
				case CPropTreeItemEdit::ValueFormat_Int32:  v = CCMDPipe::VAR(item_edit->GetItem_Int32()); break;
				case CPropTreeItemEdit::ValueFormat_Int64:  v = CCMDPipe::VAR(item_edit->GetItem_Int64()); break;
				case CPropTreeItemEdit::ValueFormat_UInt32: v = CCMDPipe::VAR(item_edit->GetItem_UInt32()); break;
				case CPropTreeItemEdit::ValueFormat_UInt64: v = CCMDPipe::VAR(item_edit->GetItem_UInt64()); break;
				case CPropTreeItemEdit::ValueFormat_Float:  v = CCMDPipe::VAR(item_edit->GetItem_Float()); break;
				case CPropTreeItemEdit::ValueFormat_Double: v = CCMDPipe::VAR(item_edit->GetItem_Double()); break;
				case CPropTreeItemEdit::ValueFormat_String: v = CCMDPipe::VAR(UTF8(LPCTSTR(item_edit->GetItem_String()))); break;
				}
			}

			if (format_type == CPropTreeItemEdit::ValueFormat_String &&
				(property_name == "lua_name" || property_name == "ui_name"))
			{
				m_entity_list_view.Invalidate();
				m_luaname_list_view.Invalidate();
			}
		}
		auto item_combo = dynamic_cast<CPropTreeItemCombo*>(nmmp->pItem);
		if (item_combo)
		{
			int select_idx = item_combo->GetCurSel();
			CString tmp;
			switch (item_combo->GetFormat())
			{
			case CPropTreeItemCombo::ValueFormat_BOOL:
				v = CCMDPipe::VAR((select_idx == TRUE) ? true : false);
				break;
			case CPropTreeItemCombo::ValueFormat_NUMBER:
				v.m_type = CCMDPipe::VAR::TYPE::ENUM;
				v.V.m_enum = item_combo->GetItemData(select_idx);
				break;
			case CPropTreeItemCombo::ValueFormat_STRING:
				if (select_idx >= 0)
				{
					item_combo->GetLBText(select_idx, tmp);
				}

				v.m_type = CCMDPipe::VAR::TYPE::NAME_VISUAL_ID;
				v.m_string = UTF8(LPCTSTR(tmp));
				break;
			}
		}
		auto item_color = dynamic_cast<CPropTreeItemColor*>(nmmp->pItem);
		if (item_color)
		{
			COLORREF color = static_cast<COLORREF>(item_color->GetItemValue());

			v = CCMDPipe::VAR(GetRValue(color), GetGValue(color), GetBValue(color));
		}

		maker::CMD cmd;
		CCMDPipe::getInstance()->initModify(cmd, current_entity->id(), property_group_name, property_name, v);

		if (CCMDPipe::getInstance()->isModified(cmd.entities().Get(cmd.entities_size() - 1), *current_entity))
		{
			CCMDPipe::getInstance()->initBackup(cmd, *current_entity);
			CCMDPipe::getInstance()->send(cmd);
			
			// shadow color는 stroke color를 따라감.. 반대는 불성립
			if (property_group_name == "LabelTTF" && property_name == "stroke_color")
			{
				maker::CMD cmd_2;
				CCMDPipe::getInstance()->initModify(cmd_2, current_entity->id(), property_group_name, "shadow_color", v);
				CCMDPipe::getInstance()->initBackup(cmd_2, *current_entity);
				CCMDPipe::getInstance()->send(cmd_2);
			}
			// stencil type 에 따라 alpha_threshold를 기본값을 준다.
			else if (property_group_name == "ClippingNode" && property_name == "stencil_type")
			{
				maker::CMD cmd_2;

				v.m_type = CCMDPipe::VAR::TYPE::FLOAT;
				if (v.V.m_int32 == 1) v.V.m_float = 0.0f; //CUSTOM
				else v.V.m_float = 1.0f;
				
				CCMDPipe::getInstance()->initModify(cmd_2, current_entity->id(), property_group_name, "alpha_threshold", v);
				CCMDPipe::getInstance()->initBackup(cmd_2, *current_entity);
				CCMDPipe::getInstance()->send(cmd_2);
			}
		}

		return TRUE;
	}

	LPNMHDR hdr = (LPNMHDR)lParam;
	if (hdr->hwndFrom == m_hWnd)
	{
		switch (hdr->code)
		{
		case NOTIFY_CODE__NEW_CMD:
			UpdateCmd();
			return TRUE;
		case NOTIFY_CODE__NEW_POPUP_MENU: {
			maker::CMD cmd;
			m_queue_for_popup_menu.pop(cmd);

			SetForegroundWindow();
			m_entity_list_view.OnContextMenu(nullptr, CPoint(0, 0), true, &cmd);
		} return TRUE;
		case NOTIFY_CODE__OPEN_VIEWER:
			onMove();
			CCMDPipe::getInstance()->applyToViewer();
			return TRUE;
		}
	}

	return CDialogEx::OnNotify(wParam, lParam, pResult);
}

int CUIMakerDlg::checkSaveChangedFile()
{
    int ret = IDNO;

    if (CCMDPipe::getInstance()->isEdited())
    {
        ret = AfxMessageBox(_T("변경된 사항을 저장하시겠습니까?"), MB_YESNOCANCEL);
        switch (ret)
        {
        case IDYES:
            // 세이브 시킨다.
            onFileSaveUi();
            break;
        }
    }

    return ret;
}

void CUIMakerDlg::onFileCloseUi()
{
    switch (checkSaveChangedFile())
    {
    case IDYES:
    case IDNO:
        break;
    case IDCANCEL:
        return;
    }

	CEntityMgr::getInstance()->clear();
	CEntityMgr::getInstance()->init();
	CCMDPipe::getInstance()->clear();

	m_entity_list_view.Redraw();
	m_luaname_list_view.Redraw();
    m_history.Redraw();

	Bind(CEntityMgr::getInstance()->getRoot());

	CCMDPipe::getInstance()->applyToViewer();
}
void CUIMakerDlg::onFileOpenUi()
{
    switch (checkSaveChangedFile())
    {
    case IDYES:
    case IDNO:
        break;
    case IDCANCEL:
        return;
    }

	CFileDialog dlg(TRUE, _T("*.ui"), NULL,
		OFN_HIDEREADONLY | OFN_OVERWRITEPROMPT | OFN_ENABLESIZING, _T("UIMaker (*.ui)|*.ui|All Files (*.*)|*.*||"), this);
	if (dlg.DoModal() != IDOK) return;

	SetFileName(dlg.GetPathName());

	CEntityMgr::getInstance()->Load(ASCII(LPCTSTR(m_ui_file_path_name)));
	Bind(CEntityMgr::getInstance()->getRoot());

    CCMDPipe::getInstance()->clear();

	m_entity_list_view.Redraw();
	m_luaname_list_view.Redraw();
    m_history.Redraw();

	CCMDPipe::getInstance()->applyToViewer();
}
void CUIMakerDlg::onFileSaveUi()
{
	std::string duplicatedLuaname = m_luaname_list_view.getDuplicatedLuaName();
	if (duplicatedLuaname != "")
	{
		CString temp;
		CString name((duplicatedLuaname).c_str());
		temp.Format(_T("Lua name 중복!!\n[ %s ]"), name);
		AfxMessageBox(temp);
		//return; 저장은 가능
	}

	if (m_ui_file_name.IsEmpty())
	{
		onFileSaveUiAs();
		return;
	}

	CEntityMgr::getInstance()->Save(ASCII(LPCTSTR(m_ui_file_path_name)));
    CCMDPipe::getInstance()->resetEdited();
}
void CUIMakerDlg::onFileSaveUiAs()
{
	std::string duplicatedLuaname = m_luaname_list_view.getDuplicatedLuaName();
	if (duplicatedLuaname != "")
	{
		CString temp;
		CString name((duplicatedLuaname).c_str());
		temp.Format(_T("Lua name 중복!!\n[ %s ]"), name);
		AfxMessageBox(temp);
		//return; 저장은 가능
	}

	CFileDialog dlg(FALSE, _T("*.ui"), NULL,
		OFN_HIDEREADONLY | OFN_OVERWRITEPROMPT | OFN_ENABLESIZING, _T("UIMaker (*.ui)|*.ui|All Files (*.*)|*.*||"), this);
	if (dlg.DoModal() != IDOK) return;

	SetFileName(dlg.GetPathName());

	CEntityMgr::getInstance()->Save(ASCII(LPCTSTR(m_ui_file_path_name)));
    CCMDPipe::getInstance()->resetEdited();
}
void CUIMakerDlg::onFileConvert()
{
    LPCTSTR szFilter = _T("UIMaker (*.ui)|*.ui|All Files(*.*)|*.*||");
    CFileDialog dlgFile(TRUE, _T("*.ui"), NULL, OFN_HIDEREADONLY | OFN_ALLOWMULTISELECT, szFilter);

    CString fileNameBuffer = _T("");

    int maxCount = 9999;
    int bufferSize = maxCount * (MAX_PATH + 1) + 1;

    dlgFile.GetOFN().lpstrFile = fileNameBuffer.GetBuffer(bufferSize);
    dlgFile.GetOFN().nMaxFile = bufferSize;

    INT_PTR nResult = dlgFile.DoModal();

    if (nResult == IDOK)
    {
        CString strText;
        int fileCount = 0;

        POSITION pos = dlgFile.GetStartPosition();
        while (pos)
        {
            CString pathName = dlgFile.GetNextPathName(pos);

            fileCount++;
            if (fileCount >= maxCount)
            {
                strText.Format(_T("동시 선택 가능한 개수(%d개)를 초과하여 선택하셨습니다! %d개까지만 처리됩니다."), maxCount, maxCount);
                AfxMessageBox(strText);
                break;
            }
        }

        strText.Format(_T("총 %d개의 파일을 선택하셨습니다. 모두 최신 버전으로 변환하시겠습니까?"), fileCount);
        if (AfxMessageBox(strText, MB_OKCANCEL) == IDOK)
        {
            fileCount = 0;
            pos = dlgFile.GetStartPosition();
            while (pos)
            {
                CString strSrcFile = dlgFile.GetNextPathName(pos);

                TCHAR strTemp[MAX_PATH];
                StrCpy(strTemp, strSrcFile);
                PathRemoveFileSpec(strTemp);
                CString strPath = strTemp;

                CString strFile = strSrcFile.Right(strSrcFile.GetLength() - strPath.GetLength() - 1);

                CString strDstFile = strPath;
                strDstFile += _T("\\");
                strDstFile += _T("_old_files");

                CreateDirectory(strDstFile, NULL);

                strDstFile += _T("\\");
                strDstFile += strFile;

                // 현재 파일을 백업 폴더에 복사
                CopyFile(strSrcFile, strDstFile, FALSE);

                // 현재 파일을 Load
                CEntityMgr::getInstance()->Load(ASCII(LPCTSTR(strSrcFile)));

                // 현재 파일을 Save
                CEntityMgr::getInstance()->Save(ASCII(LPCTSTR(strSrcFile)));

                fileCount++;
                if (fileCount >= maxCount)
                {
                    break;
                }
            }

            strText.Format(_T("총 %d개의 파일을 변환 완료하였습니다. 변환되기 전 파일들은 _old_files 폴더에 백업되었습니다."), fileCount);
            AfxMessageBox(strText);
        }
    }

    fileNameBuffer.ReleaseBuffer();
}
int CUIMakerDlg::OnCreate(LPCREATESTRUCT lpCreateStruct)
{
	if (CDialogEx::OnCreate(lpCreateStruct) == -1)
		return -1;

	return 0;
}
void CUIMakerDlg::OnClose()
{
    switch (checkSaveChangedFile())
	{
	case IDYES:
	case IDNO:
		break;
    case IDCANCEL:
        return;
	}

	int version = 0;
	int viewer_w = sm_viewer.getWidth(), viewer_h = sm_viewer.getHeight();
    float viewer_scale = sm_viewer.getScale();
	CRect rcwindow;
	GetWindowRect(&rcwindow);
	


	// 내문서 경로 가져온다.
	TCHAR szPath[512] = { 0 };
	SHGetSpecialFolderPath(NULL, szPath, CSIDL_PERSONAL, FALSE);

	// 저장할 파일 명 추가
	const wchar_t* file_name = _T("\\uimaker.cfg");
	wcscat(szPath, file_name);

	int len = 512;
	char ctemp[512];

	// 실제 변환
	WideCharToMultiByte(CP_ACP, 0, szPath, len, ctemp, len, NULL, NULL);
	char* real_path = &ctemp[0];



	FILE* pf = fopen(real_path, "wt");
	if (pf)
	{
		fprintf(pf, "version %d", &version);
        fprintf(pf, " viewer %d, %d, %d, %.2f", m_portat ? 1 : 0, viewer_w, viewer_h, viewer_scale);
		fprintf(pf, " tool %d, %d, %d, %d, %d, %d, %d, %d", rcwindow.left, rcwindow.top, rcwindow.Width(), rcwindow.Height(), m_propertiesWidth, m_historyHeight, m_historyWidth, m_luanameWidth);
		fclose(pf);
	}

	sm_viewer.close();

	CDialogEx::OnClose();

	CCMDPipe::destroyInstance();
	CEntityMgr::destroyInstance();

    // 프로그램이 종료될 때 PropTreeItem의 OnKillfocus함수가 호출되면서 발생하는 크래시를 방지하기 위해
    // 미리 모든 PropTreeItem을 삭제
    this->m_properties.DeleteAllItems();

	CDialogEx::OnOK();
}
void CUIMakerDlg::onToggleDisplayStats()
{
    sm_viewer.toggleDisplayStats();
}
void CUIMakerDlg::onReopenView()
{
	updateResolution(m_portat, m_display_mode);
}
void CUIMakerDlg::updateResolution(bool portat, RES display_mode, float scale)
{
	m_portat = portat;
	m_display_mode = display_mode;
	if (m_portat)
	{
		switch (m_display_mode)
		{
        case RES::_480_800:  sm_viewer.open(480, 800, scale); break;
        case RES::_640_852:  sm_viewer.open(640, 852, scale); break;
        case RES::_640_960:  sm_viewer.open(640, 960, scale); break;
        case RES::_640_1138: sm_viewer.open(640, 1138, scale); break;
        case RES::_720_960:  sm_viewer.open(720, 960, scale); break;
        case RES::_720_1080: sm_viewer.open(720, 1080, scale); break;
        case RES::_720_1280: sm_viewer.open(720, 1280, scale); break;
        case RES::_960_1280: sm_viewer.open(960, 1280, scale); break;
        case RES::_853_1280: sm_viewer.open(853, 1280, scale); break;
        case RES::_720_1440: sm_viewer.open(720, 1440, scale); break;

		case RES::_CONFIG:   onConfigResolution(false, scale); break;
		}
	}
	else
	{
		switch (m_display_mode)
		{
        case RES::_800_480:  sm_viewer.open(800, 480, scale); break;
        case RES::_852_640:  sm_viewer.open(852, 640, scale); break;
        case RES::_960_640:  sm_viewer.open(960, 640, scale); break;
        case RES::_1138_640: sm_viewer.open(1138, 640, scale); break;
        case RES::_960_720:  sm_viewer.open(960, 720, scale); break;
        case RES::_1080_720: sm_viewer.open(1080, 720, scale); break;
        case RES::_1280_720: sm_viewer.open(1280, 720, scale); break;
        case RES::_1280_960: sm_viewer.open(1280, 960, scale); break;
        case RES::_1280_853: sm_viewer.open(1280, 853, scale); break;

        case RES::_CONFIG:   onConfigResolution(false, scale); break;
		}
	}
}
void CUIMakerDlg::onNextResolution()
{
	RES display_mode = m_display_mode;
	if (m_portat)
	{
		switch (display_mode)
		{
#if PROJECT_ == PROJECT_DH
		case RES::_640_852:  display_mode = RES::_640_960; break;
		case RES::_640_960:  display_mode = RES::_640_1138; break;
		case RES::_640_1138: display_mode = RES::_640_852; break;
#else
		case RES::_640_1138: display_mode = RES::_720_1280; break;
		case RES::_853_1280: display_mode = RES::_960_1280; break;
		case RES::_960_1280: display_mode = RES::_720_1280; break;
		case RES::_720_1280: display_mode = RES::_720_1440; break;
        case RES::_720_1440: display_mode = RES::_960_1280; break;
#endif
        default: display_mode = RES::_720_1280;
		}
	}
	else
	{
		switch (display_mode)
		{

		case RES::_1280_720: display_mode = RES::_1280_960; break;
		case RES::_1280_960: display_mode = RES::_1280_853; break;
		case RES::_1280_853: display_mode = RES::_1280_720; break;

		default: display_mode = RES::_1280_720;
		}
	}

	updateResolution(m_portat, display_mode);
}
void CUIMakerDlg::onPrevResolution()
{
	RES display_mode = m_display_mode;
	if (m_portat)
	{
		switch (display_mode)
		{
#if PROJECT_ == PROJECT_DH
		case RES::_640_852:  display_mode = RES::_640_1138; break;
		case RES::_640_960:  display_mode = RES::_640_852; break;
		case RES::_640_1138: display_mode = RES::_640_960; break;
#else
		case RES::_640_1138: display_mode = RES::_720_1280; break;
		case RES::_853_1280: display_mode = RES::_720_1280; break;
		case RES::_960_1280: display_mode = RES::_853_1280; break;
        case RES::_720_1280: display_mode = RES::_720_1440; break;
        case RES::_720_1440: display_mode = RES::_960_1280; break;
#endif
        default: display_mode = RES::_720_1280;
		}
	}
	else
	{
		switch (display_mode)
		{
		case RES::_1280_720: display_mode = RES::_1280_853; break;
		case RES::_1280_960: display_mode = RES::_1280_720; break;
		case RES::_1280_853: display_mode = RES::_1280_960; break;

		default: display_mode = RES::_1280_720;
		}
	}

	updateResolution(m_portat, display_mode);
}
void CUIMakerDlg::onSpecificResolution()
{
	RES display_mode = m_display_mode;
	if (m_portat)
	{
		if (display_mode == RES::_720_1280)			display_mode = RES::_960_1280;
		else if (display_mode == RES::_960_1280)	display_mode = RES::_720_1280;
		else										display_mode = RES::_720_1280;
	}
	else
	{
		if (display_mode == RES::_1280_720)			display_mode = RES::_1280_960;
		else if (display_mode == RES::_1280_960)	display_mode = RES::_1280_720;
		else										display_mode = RES::_1280_720;
	}

	updateResolution(m_portat, display_mode);
}

void CUIMakerDlg::onConfigResolution(bool isNext, float scale)
{	
	if (!ConfigParser::getInstance()->isInit())
	{
		ConfigParser::getInstance()->readConfig();
	}
	
	m_display_mode = RES::_CONFIG;
	
	int width, height;
	if (isNext)	{
		const SimulatorScreenSize simulatorScrSize = ConfigParser::getInstance()->getNextScreenSize();
		width = simulatorScrSize.width;
		height = simulatorScrSize.height;
	}
	else
	{
		const SimulatorScreenSize simulatorScrSize = ConfigParser::getInstance()->getCurrScreenSize();
		width = simulatorScrSize.width;
		height = simulatorScrSize.height;
	}
	
    sm_viewer.open(width, height, scale);
}

void CUIMakerDlg::OnOpenCocos2dViewer_480_800()  { updateResolution(true, RES::_480_800); }
void CUIMakerDlg::OnOpenCocos2dViewer_640_1138() { updateResolution(true, RES::_640_1138); }
void CUIMakerDlg::OnOpenCocos2dViewer_640_960()	 { updateResolution(true, RES::_640_960); }
void CUIMakerDlg::OnOpenCocos2dViewer_640_852()	 { updateResolution(true, RES::_640_852); }
void CUIMakerDlg::OnOpenCocos2dViewer_720_1280() { updateResolution(true, RES::_720_1280); }
void CUIMakerDlg::OnOpenCocos2dViewer_720_1080() { updateResolution(true, RES::_720_1080); }
void CUIMakerDlg::OnOpenCocos2dViewer_720_960()	 { updateResolution(true, RES::_720_960); }
void CUIMakerDlg::OnOpenCocos2dViewer_960_1280() { updateResolution(true, RES::_960_1280); }
void CUIMakerDlg::OnOpenCocos2dViewer_853_1280() { updateResolution(true, RES::_853_1280); }
void CUIMakerDlg::OnOpenCocos2dViewer_720_1440() { updateResolution(true, RES::_720_1440); }

void CUIMakerDlg::OnOpenCocos2dViewer_800_480()  { updateResolution(false, RES::_800_480); }
void CUIMakerDlg::OnOpenCocos2dViewer_1138_640() { updateResolution(false, RES::_1138_640); }
void CUIMakerDlg::OnOpenCocos2dViewer_960_640()	 { updateResolution(false, RES::_960_640); }
void CUIMakerDlg::OnOpenCocos2dViewer_852_640()	 { updateResolution(false, RES::_852_640); }
void CUIMakerDlg::OnOpenCocos2dViewer_1280_720() { updateResolution(false, RES::_1280_720); }
void CUIMakerDlg::OnOpenCocos2dViewer_1080_720() { updateResolution(false, RES::_1080_720); }
void CUIMakerDlg::OnOpenCocos2dViewer_960_720()	 { updateResolution(false, RES::_960_720); }
void CUIMakerDlg::OnOpenCocos2dViewer_1280_960() { updateResolution(false, RES::_1280_960); }
void CUIMakerDlg::OnOpenCocos2dViewer_1280_853() { updateResolution(false, RES::_1280_853); }

void CUIMakerDlg::OnOpenCocos2dViewer_Scale_50() { updateResolution(m_portat, m_display_mode, 0.5f); }
void CUIMakerDlg::OnOpenCocos2dViewer_Scale_60() { updateResolution(m_portat, m_display_mode, 0.6f); }
void CUIMakerDlg::OnOpenCocos2dViewer_Scale_70() { updateResolution(m_portat, m_display_mode, 0.7f); }
void CUIMakerDlg::OnOpenCocos2dViewer_Scale_80() { updateResolution(m_portat, m_display_mode, 0.8f); }
void CUIMakerDlg::OnOpenCocos2dViewer_Scale_90() { updateResolution(m_portat, m_display_mode, 0.9f); }
void CUIMakerDlg::OnOpenCocos2dViewer_Scale_100() { updateResolution(m_portat, m_display_mode, 1.0f); }

BOOL CUIMakerDlg::SetFileName(CString file_name)
{
	m_ui_file_path_name.Empty();
	m_ui_file_name.Empty();

	int file_name_length = file_name.GetLength();
	if (file_name[0] == _T('\"') && file_name[file_name_length - 1] == _T('\"'))
	{
		file_name = file_name.Mid(1, file_name_length - 2);
		file_name_length = file_name.GetLength();
	}
	CString file_name_icase(file_name);
	file_name_icase.MakeLower();
	if (file_name_icase.Find(_T(".ui")) != file_name_length - 3) return FALSE;

	m_ui_file_path_name = file_name;
	m_ui_file_path_name.Replace(_T('\\'), _T('/'));
	m_ui_file_name = m_ui_file_path_name.Right(m_ui_file_path_name.GetLength() - m_ui_file_path_name.ReverseFind(_T('/')) - 1);
	//m_ui_folder_path_name = m_ui_file_path_name.Left(m_ui_file_path_name.GetLength() - m_ui_file_name.GetLength());

	if (::IsWindow(GetSafeHwnd()))
	{
		SetWindowText(m_title + _T(" - ") + m_ui_file_name);
	}
	return TRUE;
}

void CUIMakerDlg::OnDropFiles(HDROP hDropInfo)
{
    switch (checkSaveChangedFile())
    {
    case IDYES:
    case IDNO:
        break;
    case IDCANCEL:
        return;
    }

	TCHAR szFile[MAX_PATH];
	int nFile = DragQueryFile(hDropInfo, 0xFFFFFFFF, szFile, MAX_PATH);
	for (int iFile = 0; iFile < nFile; ++iFile)
	{
		::DragQueryFile(hDropInfo, iFile, szFile, MAX_PATH);

		if (SetFileName(szFile))
		{
			SetFileName(szFile);

			CEntityMgr::getInstance()->Load(ASCII(LPCTSTR(m_ui_file_path_name)));
			Bind(CEntityMgr::getInstance()->getRoot());

            CCMDPipe::getInstance()->clear();

			m_entity_list_view.Redraw();
			m_luaname_list_view.Redraw();
            m_history.Redraw();

			CCMDPipe::getInstance()->applyToViewer();

			break;
		}
	}
	DragFinish(hDropInfo);

	CDialogEx::OnDropFiles(hDropInfo);
}


void CUIMakerDlg::OnCancel()
{
}
void CUIMakerDlg::OnOK()
{
}
void CUIMakerDlg::onExit()
{
	OnClose();
}

void CUIMakerDlg::onUndo()
{
	maker::CMD cmd;
	CCMDPipe::initUndo(cmd);
	CCMDPipe::getInstance()->send(cmd);
}
void CUIMakerDlg::onRedo()
{
	maker::CMD cmd;
	CCMDPipe::initRedo(cmd);
	CCMDPipe::getInstance()->send(cmd);
}

void CUIMakerDlg::onCopy()
{
	maker::CMD cmd;
	if (CCMDPipe::initCopy(cmd))
	{
		CCMDPipe::getInstance()->send(cmd);

		SaveToClipboard(CEntityMgr::getInstance()->getClipboard());
	}
}
void CUIMakerDlg::onCut()
{
	maker::CMD cmd;
	if (CCMDPipe::initCut(cmd))
	{
		CCMDPipe::getInstance()->send(cmd);

		SaveToClipboard(CEntityMgr::getInstance()->getClipboard());
	}
}
void CUIMakerDlg::onPaste()
{
	LoadFromClipboard(CEntityMgr::getInstance()->getClipboard());

	maker::CMD cmd;
	if (CCMDPipe::initPaste(cmd, CEntityMgr::getInstance()->getCurrentID()))
	{
		CCMDPipe::getInstance()->send(cmd);
	}
}
void CUIMakerDlg::onRemove()
{
	maker::CMD cmd;
	if (CCMDPipe::getInstance()->initRemove(cmd))
	{
		CCMDPipe::getInstance()->send(cmd);
	}
}

void CUIMakerDlg::onToggleVisible()
{
	CEntityMgr::TYPE_SELECTED_ENTITIES selected_entities;
	CEntityMgr::getInstance()->getSelectedNearestChildren(selected_entities);
	if (selected_entities.empty()) return;

	maker::CMD cmd;
	CCMDPipe::VAR v;
	if (CCMDPipe::getInstance()->initModify(cmd, CEntityMgr::INVALID_ID, "", "", v))
	{
		for (auto entity : selected_entities)
		{
			if (!entity->has_properties() || !entity->properties().has_node()) continue;

			auto child = cmd.add_entities();
			if (!child) continue;

			child->set_id(entity->id());
			auto properties = child->mutable_properties();

			std::string modify_info;

			v.m_type = CCMDPipe::VAR::TYPE::BOOL;
			v.V.m_bool = !entity->properties().node().visible();
			CCMDPipe::getInstance()->initModify(properties, "Node", "visible", v, modify_info);

			CCMDPipe::getInstance()->initBackup(cmd, *entity);
		}
		if (cmd.entities_size() <= 0) return;

		char szbuf[1024];
		if (cmd.entities_size() > 1)
		{
			sprintf_s(szbuf, "Modify visible '%s, ...' (%d) entities", CCMDPipe::getNodeInfo(cmd.entities().Get(0)).c_str(), cmd.entities_size());
		}
		else
		{
			sprintf_s(szbuf, "Modify visible '%s'", CCMDPipe::getNodeInfo(cmd.entities().Get(0)).c_str());
		}
		cmd.set_description(szbuf);

		CCMDPipe::getInstance()->send(cmd);
	}
}

bool CUIMakerDlg::UpdateKeyState(MSG* pMsg)
{
	auto focused_window = GetFocus();
	if (GetAsyncKeyState(VK_CONTROL) & 0x8001)
	{
		if (focused_window == this || focused_window == &m_entity_list_view || focused_window == &m_history)
		{
			if (GetAsyncKeyState('Z') & 0x8000)
			{
				if (GetAsyncKeyState(VK_SHIFT) & 0x8001) onRedo();
				else onUndo();
				return true;
			}
            else if (GetAsyncKeyState('Y') & 0x8000) { onRedo(); return true; }
			else if (GetAsyncKeyState('C') & 0x8000) { onCopy(); return true; }
			else if (GetAsyncKeyState('X') & 0x8000) { onCut(); return true; }
			else if (GetAsyncKeyState('V') & 0x8000) { onPaste();  return true; }
		}
		if (GetAsyncKeyState('S') & 0x8000)
		{
			if (GetAsyncKeyState(VK_SHIFT) & 0x8001) onFileSaveUiAs();
			else onFileSaveUi();
			return true;
		}
		else if (GetAsyncKeyState('O') & 0x8000) { onFileOpenUi(); return true; }
		else if (GetAsyncKeyState('N') & 0x8000) { onFileCloseUi(); return true; }
		else if (GetAsyncKeyState('G') & 0x8000) { m_entity_list_view.OnCMD_GridOpacity(); return true; }
	}
	else
	{
		// 특정 창에 해당하는 키 입력부터 체크
		if (focused_window == this || focused_window == &m_entity_list_view || focused_window == &m_history)
		{
			if (GetAsyncKeyState('G') & 0x8000) { m_entity_list_view.OnCMD_GridOnOff(); return true; }
			else if (GetAsyncKeyState('V') & 0x8000) { onToggleVisible(); return true; }
		}
		else if (focused_window == &m_luaname_list_view)
		{
			// 영문자 입력하여 리스트 이동 시킴
			m_luaname_list_view.findLuaname(pMsg->wParam);
			return true;
		}

		// 전역적으로 체크하는 키 입력
        /*
		if (GetAsyncKeyState(VK_TAB) & 0x8000)
		{
			if (GetAsyncKeyState(VK_SHIFT) & 0x8001) onPrevResolution();
			else									 onNextResolution();
			return true;
		}
        else
        */
		if (GetAsyncKeyState(VK_F2) & 0x8000) { onSpecificResolution(); return true; }
		else if (GetAsyncKeyState(VK_F3) & 0x8000) { onToggleDisplayStats(); return true; }
		else if (GetAsyncKeyState(VK_F5) & 0x8000) { onReopenView(); return true; }
		else if (GetAsyncKeyState(VK_OEM_3) & 0x8000) { onConfigResolution(true); return true; }
		else if (GetAsyncKeyState(VK_DELETE) & 0x8000 && GetFocus() == &m_entity_list_view) { onRemove(); return true; }

	}
	return false;
}
BOOL CUIMakerDlg::PreTranslateMessage(MSG* pMsg)
{
	if (pMsg->message == WM_KEYDOWN)
	{
		if (UpdateKeyState(pMsg)) return TRUE;
	}

	return CDialogEx::PreTranslateMessage(pMsg);
}
