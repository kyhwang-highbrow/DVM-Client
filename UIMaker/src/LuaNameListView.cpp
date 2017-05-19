// LuaNameListView.cpp : implementation file
//

#include "stdafx.h"
#include "UIMaker.h"
#include "LuaNameListView.h"
#include "EntityListView.h"
#include "CMDPipe.h"
#include "UIMakerDlg.h"

#define NODE_DEFHEIGHT			20
#define NODE_DEFLEFT			16
#define NODE_EXPANDCOLUMN		0
#define NODE_NEXT_HEAD			0
#define NODE_NEXT_HEIGHT		3
#define NODE_HEAD				0
#define EMPTY_LUANAME			""

enum
{
	ID_CMD_REMOVE = WM_USER + 1000,
	ID_CMD_SIZETOCONTENT,
	ID_CMD_GRID_ON_OFF = WM_USER + 1900,
	ID_CMD_RESET_ZOOM,
	ID_CMD_RESET_SCROLL,
	ID_CMD_CREATE_ENTITY_TYPE__00 = WM_USER + 2000,
	ID_CMD_PICK_ENTITY__00 = WM_USER + 2200,
};

enum
{
	HIT_PROPFIRST = 50,
	HIT_CLIENT,
	HIT_LABEL,
	HIT_EXPAND,
	HIT_NEXT,
	HIT_FIRST_CHILD,
	HIT_PARENT_NEXT, // to do : 조작 편의를 위해 자식 객체중 마지막 객체의 특정 위치를 가르키면 부모객체 다음 위치로 이동한다.
};


////////////////////////////////////////////////////////////////////////////////////////////////
// STATIC s
////////////////////////////////////////////////////////////////////////////////////////////////
static const CString strOfficeFontName = _T("Tahoma");
static const CString strDefaultFontName = _T("MS Sans Serif");
static void _DotHLine(HDC hdc, LONG x, LONG y, LONG w)
{
	for (; w>0; w -= 2, x += 2)
		SetPixel(hdc, x, y, GetSysColor(COLOR_BTNSHADOW));
}
static void _DrawBGRect(CDC* pDC, CRect rect, int brushIdx)
{
	HGDIOBJ oPen = pDC->SelectObject(GetStockObject(NULL_PEN));
	HGDIOBJ oBrush = pDC->SelectObject(GetSysColorBrush(brushIdx));

	CRect rcselect(rect);
	rcselect.left += NODE_HEAD;

	pDC->Rectangle(&rcselect);

	pDC->SelectObject(oPen);
	pDC->SelectObject(oBrush);

	pDC->SetTextColor(GetSysColor(COLOR_BTNHIGHLIGHT));
}
static void _DrawInsertRect(CDC* pDC, CRect rect, int brushIdx)
{
	CRect rcdrag_targetnext(rect);
	rcdrag_targetnext.top = rcdrag_targetnext.bottom - NODE_NEXT_HEIGHT;
	_DrawBGRect(pDC, rcdrag_targetnext, COLOR_HIGHLIGHT);

	rcdrag_targetnext.top = rcdrag_targetnext.bottom - NODE_NEXT_HEAD;
	rcdrag_targetnext.bottom += 2;
	rcdrag_targetnext.right = rcdrag_targetnext.left + NODE_NEXT_HEAD;
	rcdrag_targetnext.left -= 2;
	_DrawBGRect(pDC, rcdrag_targetnext, COLOR_HIGHLIGHT);

	rcdrag_targetnext.top += 2;
	rcdrag_targetnext.bottom -= 2;
	rcdrag_targetnext.left += 2;
	rcdrag_targetnext.right -= 2;
	_DrawBGRect(pDC, rcdrag_targetnext, AFX_IDC_COLOR_BLACK);
}
static int CALLBACK FontFamilyProcFonts(const LOGFONT FAR* lplf, const TEXTMETRIC FAR*, ULONG, LPARAM)
{
	ASSERT(lplf != NULL);
	CString strFont = lplf->lfFaceName;
	return strFont.CollateNoCase(strOfficeFontName) == 0 ? 0 : 1;
}


// CLuaNameListView

IMPLEMENT_DYNAMIC(CLuaNameListView, CWnd)

////////////////////////////////////////////////////////////////////////////////////////////////
// init Function s
////////////////////////////////////////////////////////////////////////////////////////////////
CLuaNameListView::CLuaNameListView()
	: m_pNormalFont(nullptr)
	, m_pBoldFont(nullptr)
	, m_drag(false)
	, m_prepare_drag(false)
{
    _oldLuaNamesCount = 0;
}
CLuaNameListView::~CLuaNameListView()
{
	if (m_pNormalFont)
	{
		delete m_pNormalFont;
		m_pNormalFont = NULL;
	}

	if (m_pBoldFont)
	{
		delete m_pBoldFont;
		m_pBoldFont = NULL;
	}
}
BOOL CLuaNameListView::Create(DWORD dwStyle, const RECT& rect, CWnd* pParentWnd, UINT nID)
{
	CWnd* pWnd = this;

	LPCTSTR pszCreateClass = AfxRegisterWndClass(CS_HREDRAW | CS_VREDRAW | CS_DBLCLKS, ::LoadCursor(NULL, IDC_ARROW));

	InitFont();

	return pWnd->Create(pszCreateClass, _T("UIMAKER_ENTITYS"), dwStyle, rect, pParentWnd, nID);
}
void CLuaNameListView::InitFont()
{
	NONCLIENTMETRICS info;
	info.cbSize = sizeof(info);

	::SystemParametersInfo(SPI_GETNONCLIENTMETRICS, sizeof(info), &info, 0);

	LOGFONT lf;
	memset(&lf, 0, sizeof (LOGFONT));

	CWindowDC dc(NULL);
	lf.lfCharSet = (BYTE)GetTextCharsetInfo(dc.GetSafeHdc(), NULL, 0);

	lf.lfHeight = info.lfMenuFont.lfHeight;
	lf.lfWeight = info.lfMenuFont.lfWeight;
	lf.lfItalic = info.lfMenuFont.lfItalic;

	// check if we should use system font
	_tcscpy_s(lf.lfFaceName, info.lfMenuFont.lfFaceName);

	BOOL fUseSystemFont = (info.lfMenuFont.lfCharSet > SYMBOL_CHARSET);
	if (!fUseSystemFont)
	{
		// check for "Tahoma" font existance:
		if (::EnumFontFamilies(dc.GetSafeHdc(), NULL, FontFamilyProcFonts, 0) == 0)
		{
			// Found! Use MS Office font!
			_tcscpy_s(lf.lfFaceName, strOfficeFontName);
		}
		else
		{
			// Not found. Use default font:
			_tcscpy_s(lf.lfFaceName, strDefaultFontName);
		}
	}

	m_pNormalFont = new CFont;
	m_pNormalFont->CreateFontIndirect(&lf);

	lf.lfWeight = FW_BOLD;
	m_pBoldFont = new CFont;
	m_pBoldFont->CreateFontIndirect(&lf);
}

////////////////////////////////////////////////////////////////////////////////////////////////
// CLuaNameListView message handlers
////////////////////////////////////////////////////////////////////////////////////////////////
#pragma region MFC_MESSAGE_MAP

BEGIN_MESSAGE_MAP(CLuaNameListView, CWnd)
	ON_WM_SIZE()
	ON_WM_PAINT()
	ON_WM_MOUSEMOVE()
	ON_WM_MOUSEWHEEL()
	ON_WM_MOUSELEAVE()
	ON_WM_LBUTTONDOWN()
	ON_WM_LBUTTONUP()
	ON_WM_RBUTTONUP()
	ON_WM_VSCROLL()
	ON_WM_RBUTTONDOWN()

	ON_COMMAND(ID_CMD_REMOVE, OnCMD_Remove)
	ON_COMMAND(ID_CMD_SIZETOCONTENT, OnCMD_SizeToContent)

	ON_COMMAND(ID_CMD_CREATE_ENTITY_TYPE__00 + 0, OnCMD_CreateEntity_Type00)
	ON_COMMAND(ID_CMD_CREATE_ENTITY_TYPE__00 + 1, OnCMD_CreateEntity_Type01)
	ON_COMMAND(ID_CMD_CREATE_ENTITY_TYPE__00 + 2, OnCMD_CreateEntity_Type02)
	ON_COMMAND(ID_CMD_CREATE_ENTITY_TYPE__00 + 3, OnCMD_CreateEntity_Type03)
	ON_COMMAND(ID_CMD_CREATE_ENTITY_TYPE__00 + 4, OnCMD_CreateEntity_Type04)
	ON_COMMAND(ID_CMD_CREATE_ENTITY_TYPE__00 + 5, OnCMD_CreateEntity_Type05)
	ON_COMMAND(ID_CMD_CREATE_ENTITY_TYPE__00 + 6, OnCMD_CreateEntity_Type06)
	ON_COMMAND(ID_CMD_CREATE_ENTITY_TYPE__00 + 7, OnCMD_CreateEntity_Type07)
	ON_COMMAND(ID_CMD_CREATE_ENTITY_TYPE__00 + 8, OnCMD_CreateEntity_Type08)
	ON_COMMAND(ID_CMD_CREATE_ENTITY_TYPE__00 + 9, OnCMD_CreateEntity_Type09)
	ON_COMMAND(ID_CMD_CREATE_ENTITY_TYPE__00 + 10, OnCMD_CreateEntity_Type10)
	ON_COMMAND(ID_CMD_CREATE_ENTITY_TYPE__00 + 11, OnCMD_CreateEntity_Type11)
	ON_COMMAND(ID_CMD_CREATE_ENTITY_TYPE__00 + 12, OnCMD_CreateEntity_Type12)
	ON_COMMAND(ID_CMD_CREATE_ENTITY_TYPE__00 + 13, OnCMD_CreateEntity_Type13)
	ON_COMMAND(ID_CMD_CREATE_ENTITY_TYPE__00 + 14, OnCMD_CreateEntity_Type14)
	ON_COMMAND(ID_CMD_CREATE_ENTITY_TYPE__00 + 15, OnCMD_CreateEntity_Type15)
	ON_COMMAND(ID_CMD_CREATE_ENTITY_TYPE__00 + 16, OnCMD_CreateEntity_Type16)
	ON_COMMAND(ID_CMD_CREATE_ENTITY_TYPE__00 + 17, OnCMD_CreateEntity_Type17)
	ON_COMMAND(ID_CMD_CREATE_ENTITY_TYPE__00 + 18, OnCMD_CreateEntity_Type18)
	ON_COMMAND(ID_CMD_CREATE_ENTITY_TYPE__00 + 19, OnCMD_CreateEntity_Type19)
	ON_COMMAND(ID_CMD_CREATE_ENTITY_TYPE__00 + 20, OnCMD_CreateEntity_Type20)
	ON_COMMAND(ID_CMD_CREATE_ENTITY_TYPE__00 + 21, OnCMD_CreateEntity_Type21)
	ON_COMMAND(ID_CMD_CREATE_ENTITY_TYPE__00 + 22, OnCMD_CreateEntity_Type22)
	ON_COMMAND(ID_CMD_CREATE_ENTITY_TYPE__00 + 23, OnCMD_CreateEntity_Type23)
	ON_COMMAND(ID_CMD_CREATE_ENTITY_TYPE__00 + 24, OnCMD_CreateEntity_Type24)
	ON_COMMAND(ID_CMD_CREATE_ENTITY_TYPE__00 + 25, OnCMD_CreateEntity_Type25)
	ON_COMMAND(ID_CMD_CREATE_ENTITY_TYPE__00 + 26, OnCMD_CreateEntity_Type26)
	ON_COMMAND(ID_CMD_CREATE_ENTITY_TYPE__00 + 27, OnCMD_CreateEntity_Type27)
	ON_COMMAND(ID_CMD_CREATE_ENTITY_TYPE__00 + 28, OnCMD_CreateEntity_Type28)
	ON_COMMAND(ID_CMD_CREATE_ENTITY_TYPE__00 + 29, OnCMD_CreateEntity_Type29)
	ON_COMMAND(ID_CMD_CREATE_ENTITY_TYPE__00 + 30, OnCMD_CreateEntity_Type30)
	ON_COMMAND(ID_CMD_CREATE_ENTITY_TYPE__00 + 31, OnCMD_CreateEntity_Type31)
	ON_COMMAND(ID_CMD_CREATE_ENTITY_TYPE__00 + 32, OnCMD_CreateEntity_Type32)
	ON_COMMAND(ID_CMD_CREATE_ENTITY_TYPE__00 + 33, OnCMD_CreateEntity_Type33)
	ON_COMMAND(ID_CMD_CREATE_ENTITY_TYPE__00 + 34, OnCMD_CreateEntity_Type34)
	ON_COMMAND(ID_CMD_CREATE_ENTITY_TYPE__00 + 35, OnCMD_CreateEntity_Type35)
	ON_COMMAND(ID_CMD_CREATE_ENTITY_TYPE__00 + 36, OnCMD_CreateEntity_Type36)
	ON_COMMAND(ID_CMD_CREATE_ENTITY_TYPE__00 + 37, OnCMD_CreateEntity_Type37)
	ON_COMMAND(ID_CMD_CREATE_ENTITY_TYPE__00 + 38, OnCMD_CreateEntity_Type38)
	ON_COMMAND(ID_CMD_CREATE_ENTITY_TYPE__00 + 39, OnCMD_CreateEntity_Type39)
	ON_COMMAND(ID_CMD_CREATE_ENTITY_TYPE__00 + 40, OnCMD_CreateEntity_Type40)
	ON_COMMAND(ID_CMD_CREATE_ENTITY_TYPE__00 + 41, OnCMD_CreateEntity_Type41)
	ON_COMMAND(ID_CMD_CREATE_ENTITY_TYPE__00 + 42, OnCMD_CreateEntity_Type42)
	ON_COMMAND(ID_CMD_CREATE_ENTITY_TYPE__00 + 43, OnCMD_CreateEntity_Type43)
	ON_COMMAND(ID_CMD_CREATE_ENTITY_TYPE__00 + 44, OnCMD_CreateEntity_Type44)
	ON_COMMAND(ID_CMD_CREATE_ENTITY_TYPE__00 + 45, OnCMD_CreateEntity_Type45)
	ON_COMMAND(ID_CMD_CREATE_ENTITY_TYPE__00 + 46, OnCMD_CreateEntity_Type46)
	ON_COMMAND(ID_CMD_CREATE_ENTITY_TYPE__00 + 47, OnCMD_CreateEntity_Type47)
	ON_COMMAND(ID_CMD_CREATE_ENTITY_TYPE__00 + 48, OnCMD_CreateEntity_Type48)
	ON_COMMAND(ID_CMD_CREATE_ENTITY_TYPE__00 + 49, OnCMD_CreateEntity_Type49)
	ON_COMMAND(ID_CMD_CREATE_ENTITY_TYPE__00 + 50, OnCMD_CreateEntity_Type50)
	ON_COMMAND(ID_CMD_CREATE_ENTITY_TYPE__00 + 51, OnCMD_CreateEntity_Type51)
	ON_COMMAND(ID_CMD_CREATE_ENTITY_TYPE__00 + 52, OnCMD_CreateEntity_Type52)
	ON_COMMAND(ID_CMD_CREATE_ENTITY_TYPE__00 + 53, OnCMD_CreateEntity_Type53)
	ON_COMMAND(ID_CMD_CREATE_ENTITY_TYPE__00 + 54, OnCMD_CreateEntity_Type54)
	ON_COMMAND(ID_CMD_CREATE_ENTITY_TYPE__00 + 55, OnCMD_CreateEntity_Type55)
	ON_COMMAND(ID_CMD_CREATE_ENTITY_TYPE__00 + 56, OnCMD_CreateEntity_Type56)
	ON_COMMAND(ID_CMD_CREATE_ENTITY_TYPE__00 + 57, OnCMD_CreateEntity_Type57)
	ON_COMMAND(ID_CMD_CREATE_ENTITY_TYPE__00 + 58, OnCMD_CreateEntity_Type58)
	ON_COMMAND(ID_CMD_CREATE_ENTITY_TYPE__00 + 59, OnCMD_CreateEntity_Type59)
	ON_COMMAND(ID_CMD_CREATE_ENTITY_TYPE__00 + 60, OnCMD_CreateEntity_Type60)
	ON_COMMAND(ID_CMD_CREATE_ENTITY_TYPE__00 + 61, OnCMD_CreateEntity_Type61)
	ON_COMMAND(ID_CMD_CREATE_ENTITY_TYPE__00 + 62, OnCMD_CreateEntity_Type62)
	ON_COMMAND(ID_CMD_CREATE_ENTITY_TYPE__00 + 63, OnCMD_CreateEntity_Type63)
	ON_COMMAND(ID_CMD_CREATE_ENTITY_TYPE__00 + 64, OnCMD_CreateEntity_Type64)
	ON_COMMAND(ID_CMD_CREATE_ENTITY_TYPE__00 + 65, OnCMD_CreateEntity_Type65)
	ON_COMMAND(ID_CMD_CREATE_ENTITY_TYPE__00 + 66, OnCMD_CreateEntity_Type66)
	ON_COMMAND(ID_CMD_CREATE_ENTITY_TYPE__00 + 67, OnCMD_CreateEntity_Type67)
	ON_COMMAND(ID_CMD_CREATE_ENTITY_TYPE__00 + 68, OnCMD_CreateEntity_Type68)
	ON_COMMAND(ID_CMD_CREATE_ENTITY_TYPE__00 + 69, OnCMD_CreateEntity_Type69)
	ON_COMMAND(ID_CMD_CREATE_ENTITY_TYPE__00 + 70, OnCMD_CreateEntity_Type70)
	ON_COMMAND(ID_CMD_CREATE_ENTITY_TYPE__00 + 71, OnCMD_CreateEntity_Type71)
	ON_COMMAND(ID_CMD_CREATE_ENTITY_TYPE__00 + 72, OnCMD_CreateEntity_Type72)
	ON_COMMAND(ID_CMD_CREATE_ENTITY_TYPE__00 + 73, OnCMD_CreateEntity_Type73)
	ON_COMMAND(ID_CMD_CREATE_ENTITY_TYPE__00 + 74, OnCMD_CreateEntity_Type74)
	ON_COMMAND(ID_CMD_CREATE_ENTITY_TYPE__00 + 75, OnCMD_CreateEntity_Type75)
	ON_COMMAND(ID_CMD_CREATE_ENTITY_TYPE__00 + 76, OnCMD_CreateEntity_Type76)
	ON_COMMAND(ID_CMD_CREATE_ENTITY_TYPE__00 + 77, OnCMD_CreateEntity_Type77)
	ON_COMMAND(ID_CMD_CREATE_ENTITY_TYPE__00 + 78, OnCMD_CreateEntity_Type78)
	ON_COMMAND(ID_CMD_CREATE_ENTITY_TYPE__00 + 79, OnCMD_CreateEntity_Type79)
	ON_COMMAND(ID_CMD_CREATE_ENTITY_TYPE__00 + 80, OnCMD_CreateEntity_Type80)
	ON_COMMAND(ID_CMD_CREATE_ENTITY_TYPE__00 + 81, OnCMD_CreateEntity_Type81)
	ON_COMMAND(ID_CMD_CREATE_ENTITY_TYPE__00 + 82, OnCMD_CreateEntity_Type82)
	ON_COMMAND(ID_CMD_CREATE_ENTITY_TYPE__00 + 83, OnCMD_CreateEntity_Type83)
	ON_COMMAND(ID_CMD_CREATE_ENTITY_TYPE__00 + 84, OnCMD_CreateEntity_Type84)
	ON_COMMAND(ID_CMD_CREATE_ENTITY_TYPE__00 + 85, OnCMD_CreateEntity_Type85)
	ON_COMMAND(ID_CMD_CREATE_ENTITY_TYPE__00 + 86, OnCMD_CreateEntity_Type86)
	ON_COMMAND(ID_CMD_CREATE_ENTITY_TYPE__00 + 87, OnCMD_CreateEntity_Type87)
	ON_COMMAND(ID_CMD_CREATE_ENTITY_TYPE__00 + 88, OnCMD_CreateEntity_Type88)
	ON_COMMAND(ID_CMD_CREATE_ENTITY_TYPE__00 + 89, OnCMD_CreateEntity_Type89)
	ON_COMMAND(ID_CMD_CREATE_ENTITY_TYPE__00 + 90, OnCMD_CreateEntity_Type90)
	ON_COMMAND(ID_CMD_CREATE_ENTITY_TYPE__00 + 91, OnCMD_CreateEntity_Type91)
	ON_COMMAND(ID_CMD_CREATE_ENTITY_TYPE__00 + 92, OnCMD_CreateEntity_Type92)
	ON_COMMAND(ID_CMD_CREATE_ENTITY_TYPE__00 + 93, OnCMD_CreateEntity_Type93)
	ON_COMMAND(ID_CMD_CREATE_ENTITY_TYPE__00 + 94, OnCMD_CreateEntity_Type94)
	ON_COMMAND(ID_CMD_CREATE_ENTITY_TYPE__00 + 95, OnCMD_CreateEntity_Type95)
	ON_COMMAND(ID_CMD_CREATE_ENTITY_TYPE__00 + 96, OnCMD_CreateEntity_Type96)
	ON_COMMAND(ID_CMD_CREATE_ENTITY_TYPE__00 + 97, OnCMD_CreateEntity_Type97)
	ON_COMMAND(ID_CMD_CREATE_ENTITY_TYPE__00 + 98, OnCMD_CreateEntity_Type98)
	ON_COMMAND(ID_CMD_CREATE_ENTITY_TYPE__00 + 99, OnCMD_CreateEntity_Type99)

END_MESSAGE_MAP()

#pragma endregion 

////////////////////////////////////////////////////////////////////////////////////////////////
// draw Function s
////////////////////////////////////////////////////////////////////////////////////////////////
void CLuaNameListView::UpdateResize()
{
	SCROLLINFO si;
	LONG nHeight;
	CRect rc;

	GetClientRect(rc);
	nHeight = rc.Height() + 1;

	ZeroMemory(&si, sizeof(SCROLLINFO));
	si.cbSize = sizeof(SCROLLINFO);
	si.fMask = SIF_RANGE | SIF_PAGE | SIF_POS;
	si.nMin = 0;
	si.nMax = GetTotalHeight();
	si.nPage = nHeight;

	int ny = m_origin.y;
	if ((int)si.nPage > si.nMax) ny = 0;

	m_origin.y = ny;
	si.nPos = ny;

	SetScrollInfo(SB_VERT, &si, TRUE);
}
void CLuaNameListView::Redraw()
{
	UpdateResize();
	Invalidate();
	UpdateWindow();
}
int CLuaNameListView::GetTotalHeight()
{
	std::list< maker::Entity*> l_entity = CEntityMgr::getInstance()->getLuaEntities();
	int total_height = NODE_DEFHEIGHT * l_entity.size();
	
	return total_height;
}
void CLuaNameListView::UpdateScroll()
{
	CRect rc;
	GetClientRect(rc);
	LONG nHeight = rc.Height() + 1;

	SCROLLINFO si;
	ZeroMemory(&si, sizeof(SCROLLINFO));
	si.cbSize = sizeof(SCROLLINFO);
	si.fMask = SIF_RANGE | SIF_PAGE;
	si.nMin = 0;
	si.nMax = GetTotalHeight();
	si.nPage = nHeight;

	bool found = false;
	LONG ny = GetScrollPos(CEntityMgr::getInstance()->getCurrent());

	LONG y = __min(__max(ny, si.nMin), si.nMax - nHeight);

	if (m_origin.y > ny || m_origin.y + nHeight < ny)
	{
		m_origin.y = y;
		si.fMask |= SIF_POS;
		si.nPos = y;
	}

	SetScrollInfo(SB_VERT, &si, TRUE);
}
int CLuaNameListView::GetScrollPos(const maker::Entity* cur_entity)
{
	std::list< maker::Entity*> l_entity = CEntityMgr::getInstance()->getLuaEntities();

	int count = 0;
	for (maker::Entity* entity : l_entity)
	{
		if (entity->id() == cur_entity->id()) return NODE_DEFHEIGHT * count;
		count++;
	}
	return 0;
}
void CLuaNameListView::RecreateBackBuffer(int cx, int cy)
{
	if (m_BackBufferSize.cx<cx || m_BackBufferSize.cy<cy)
	{
		m_BackBufferSize = CSize(cx, cy);

		CWindowDC dc(NULL);

		int nPlanes = dc.GetDeviceCaps(PLANES);
		int nBitCount = dc.GetDeviceCaps(BITSPIXEL);

		m_BackBuffer.DeleteObject();
		m_BackBuffer.CreateBitmap(cx, cy, nPlanes, nBitCount, NULL);
	}
}
void CLuaNameListView::DrawEntity(CDC* pDC, CRect rect, int& count, const maker::Entity* entity, bool invisible)
{
	if (!entity) return;

	if (entity->properties().has_node() && !entity->properties().node().visible())
	{
		invisible = true;
	}

	CPoint ptcursor;
	GetCursorPos(&ptcursor);
	ScreenToClient(&ptcursor);

	CRect rcitem(rect);
	rcitem.left = NODE_DEFLEFT;
	rcitem.top = count*NODE_DEFHEIGHT - m_origin.y;
	rcitem.bottom = rcitem.top + NODE_DEFHEIGHT - 1;

	int textColor = COLOR_BTNTEXT;
	if (entity->selected())
	{
		if (CEntityMgr::getInstance()->getCurrent() && m_drag)
		{
			_DrawBGRect(pDC, rcitem, COLOR_INACTIVECAPTION);
			textColor = COLOR_INACTIVECAPTIONTEXT;
		}
		else
		{
			_DrawBGRect(pDC, rcitem, COLOR_HIGHLIGHT);
			textColor = COLOR_HIGHLIGHTTEXT;
		}
	}

	CRect rchititem(rcitem);
	rchititem.left = 0;
	rchititem.bottom += 1;
	
	CRect rctext(rcitem);
	if (invisible)
	{
		pDC->SetTextColor(GetSysColor(COLOR_GRAYTEXT));
	}
	else if (entity->lua_name_duplicated())
	{
		pDC->SetTextColor(GetSysColor(COLOR_ACTIVECAPTION));
	}
	else
	{
		pDC->SetTextColor(GetSysColor(textColor));
	}
	pDC->SetBkMode(TRANSPARENT);
	pDC->SelectObject(m_pNormalFont);
	pDC->DrawText(UTF16LE(entity->properties().node().lua_name()).c_str(), &rctext, DT_SINGLELINE | DT_VCENTER | DT_END_ELLIPSIS);

	// draw horzontal sep
	_DotHLine(pDC->m_hDC, rctext.left, rcitem.bottom - 1, rctext.Width());
}
void CLuaNameListView::OnCMD_CreateEntity(int type)
{
	if (!CEntityMgr::getInstance()->getRoot()) return;

	CEntityMgr::ID parent_id = CEntityMgr::INVALID_ID;
	auto current_entity = CEntityMgr::getInstance()->getCurrent();
	if (current_entity)
	{
		parent_id = current_entity->id();
	}

	// Label 계열은 자식을 붙일 수 없어서 상위 객체에 자식으로 붙인다.
	while (CEntityMgr::getInstance()->isLabel(parent_id))
	{
		auto parent = CEntityMgr::getInstance()->getParent(parent_id);
		if (parent)
		{
			parent_id = parent->id();
		}
		else
		{
			parent_id = CEntityMgr::INVALID_ID;
			break;
		}
	}

	if (parent_id == CEntityMgr::INVALID_ID)
	{
		auto root = CEntityMgr::getInstance()->getRoot();
		if (!root) return;

		parent_id = root->id();
	}

	auto new_entity_id = CEntityMgr::getInstance()->bookingId();
	auto new_entity_type = maker::ENTITY_TYPE(maker::ENTITY__Node + type);

	maker::CMD cmd;
	if (CCMDPipe::getInstance()->initCreate(cmd, new_entity_id, parent_id, new_entity_type))
	{
		CCMDPipe::getInstance()->send(cmd);
	}

	CCMDPipe::getInstance()->initSelect(cmd, new_entity_id);
	CCMDPipe::getInstance()->send(cmd);
}


////////////////////////////////////////////////////////////////////////////////////////////////
// lua duplicate check Function s
////////////////////////////////////////////////////////////////////////////////////////////////
list<string> CLuaNameListView::getLuanameList()
{
	list<string> l_lua_name;
	std::list< maker::Entity*> l_entity = CEntityMgr::getInstance()->getLuaEntitiesWithCalc();
	for (maker::Entity* pEntity : l_entity)
	{
		std::string luaname = pEntity->properties().node().lua_name();

		if (luaname != EMPTY_LUANAME) {
			l_lua_name.push_back(luaname);
		}
	}
	return l_lua_name;
}
string CLuaNameListView::getDuplicatedLuaName()
{
	list<string> l_lua_name = getLuanameList();

	if (l_lua_name.size() > 1){
		list<string>::iterator li_1;
		for (li_1 = l_lua_name.begin(); li_1 != l_lua_name.end(); li_1++)
		{
			list<string>::iterator li_2;
			list<string>::iterator li_temp = li_1;
			li_temp++;
			for (li_2 = li_temp; li_2 != l_lua_name.end(); li_2++)
			{
				if (*li_1 == *li_2)
				{
					return *li_2;
				}
			}
		}
	}
	return "";
}

////////////////////////////////////////////////////////////////////////////////////////////////
// find luaname Function s
////////////////////////////////////////////////////////////////////////////////////////////////
bool StartsWith(const std::string& text, const std::string& token)
{

	if (text.length() < token.length() || text.length() == 0)
		return false;

	for (unsigned int i = 0; i<token.length(); ++i)
	{
		if (text[i] != token[i])
			return false;
	}

	return true;
}
maker::Entity* CLuaNameListView::findLuaname(char ch)
{
	ch = tolower(ch);
	std::list< maker::Entity*> l_entity = CEntityMgr::getInstance()->getLuaEntities();
	for (maker::Entity* pEntity : l_entity)
	{
		std::string luaname = pEntity->properties().node().lua_name();
		if (StartsWith(luaname, string(&ch)))
		{
			maker::CMD cmd;
			CCMDPipe::getInstance()->initSelect(cmd, pEntity->id());
			CCMDPipe::getInstance()->send(cmd);
			return pEntity;
		}
	}
}

////////////////////////////////////////////////////////////////////////////////////////////////
// Hit Function s
////////////////////////////////////////////////////////////////////////////////////////////////
maker::Entity* CLuaNameListView::hitReleaseEntity(const POINT& ptcursor, int& hit_part)
{
	CRect rcclient;
	GetClientRect(&rcclient);

	hit_part = HIT_CLIENT;

	int count = 0;
	CRect rchititem;
	auto entity = findHitEntity(ptcursor);
	if (!entity) return nullptr;
	if (CEntityMgr::getInstance()->getRoot() == entity)
	{
		hit_part = HIT_LABEL;
		return entity;
	}

	if (entity->children_size() > 0 && entity->expand())
	{
		CRect rcdrag_targetchild(rchititem);
		if (entity != CEntityMgr::getInstance()->getRoot()) rcdrag_targetchild.bottom -= NODE_NEXT_HEIGHT;
		if (rcdrag_targetchild.PtInRect(ptcursor))
		{
			hit_part = HIT_LABEL;
			return entity;
		}
		else
		{
			CRect rcdrag_targetnext(rchititem);
			rcdrag_targetnext.bottom += 1;
			if (rcdrag_targetnext.PtInRect(ptcursor) && entity != CEntityMgr::getInstance()->getRoot())
			{
				auto parent_id = entity->parent_id();

				hit_part = HIT_NEXT;
				entity = CEntityMgr::getInstance()->getPrevSibling(entity->id());
				if (entity) return entity;

				hit_part = HIT_FIRST_CHILD;
				return CEntityMgr::getInstance()->get(parent_id);
			}
		}
	}
	else
	{
		CRect rcdrag_targetchild(rchititem);
		if (entity != CEntityMgr::getInstance()->getRoot()) rcdrag_targetchild.bottom -= NODE_NEXT_HEIGHT;
		if (rcdrag_targetchild.PtInRect(ptcursor))
		{
			hit_part = HIT_LABEL;
			return entity;
		}
		else
		{
			CRect rcdrag_targetnext(rchititem);
			rcdrag_targetnext.left = 0;
			rcdrag_targetnext.bottom += 1;
			if (rcdrag_targetnext.PtInRect(ptcursor) && entity != CEntityMgr::getInstance()->getRoot())
			{
				rcdrag_targetnext.left = rchititem.left + NODE_EXPANDCOLUMN;
				if (rcdrag_targetnext.PtInRect(ptcursor))
				{
					auto parent_id = entity->parent_id();

					hit_part = HIT_NEXT;
					entity = CEntityMgr::getInstance()->getPrevSibling(entity->id());
					if (entity) return entity;

					hit_part = HIT_FIRST_CHILD;
					return CEntityMgr::getInstance()->get(parent_id);
				}
				else
				{
					auto parent = CEntityMgr::getInstance()->get(entity->parent_id());
					if (parent && parent->children().Get(0).id() == entity->id())
					{
						CRect rcdrag_targetparentnext(rchititem);
						while (rcdrag_targetparentnext.left > NODE_EXPANDCOLUMN)
						{
							rcdrag_targetparentnext.right = rcdrag_targetparentnext.left + NODE_EXPANDCOLUMN;
							if (rcdrag_targetparentnext.PtInRect(ptcursor))
							{
								auto parent_id = entity->parent_id();

								hit_part = HIT_NEXT;
								entity = CEntityMgr::getInstance()->getPrevSibling(parent->id());
								if (entity) return entity;

								hit_part = HIT_FIRST_CHILD;
								return CEntityMgr::getInstance()->get(parent->parent_id());
							}

							entity = parent;
							parent = CEntityMgr::getInstance()->get(entity->parent_id());
							rcdrag_targetparentnext.left -= NODE_EXPANDCOLUMN;
						}
					}
				}
			}
		}
	}

	hit_part = HIT_LABEL;
	return entity;
}
maker::Entity* CLuaNameListView::hitEntity(const POINT& pt, int& hit_part)
{
	CRect rcclient;
	GetClientRect(&rcclient);

	hit_part = HIT_CLIENT;

	int count = 0;
	CRect rchititem;
	auto entity = findHitEntity(pt);
	if (entity)
	{
		CRect rchitlable(rchititem);
		rchitlable.left += NODE_EXPANDCOLUMN;
		if (rchitlable.PtInRect(pt))
		{
			hit_part = HIT_LABEL;
			return entity;
		}
		else
		{
			maker::CMD cmd;
			CCMDPipe::getInstance()->initSelect(cmd, CEntityMgr::INVALID_ID);
			CCMDPipe::getInstance()->send(cmd);
		}

		hit_part = HIT_LABEL;
		return entity;
	}

	return nullptr;
}
maker::Entity* CLuaNameListView::findHitEntity(const POINT& pt)
{
	if (!pt.y) return nullptr;

	std::list< maker::Entity*> l_entity = CEntityMgr::getInstance()->getLuaEntities();

	int idx = pt.y / NODE_DEFHEIGHT;
	int count = 0;

	CRect rcclient;
	GetClientRect(&rcclient);

	for (maker::Entity* entity : l_entity)
	{
		CRect rcitem(rcclient);
		rcitem.left = NODE_DEFLEFT;
		rcitem.top = count*NODE_DEFHEIGHT - m_origin.y;
		rcitem.bottom = rcitem.top + NODE_DEFHEIGHT;

		CRect rcvaliditem(rcitem);
		rcvaliditem.left = 0;
		if (rcvaliditem.PtInRect(pt))
		{
			return entity;
		}
		count++;
	}

	return nullptr;
}
void CLuaNameListView::SetCurrentEntity(CEntityMgr::ID entity_id)
{
	CEntityMgr::getInstance()->setCurrentID(entity_id);

	auto entity = CEntityMgr::getInstance()->getParent(entity_id);
	while (entity)
	{
		entity = CEntityMgr::getInstance()->get(entity->parent_id());
	}

	UpdateScroll();
	Invalidate();
}

////////////////////////////////////////////////////////////////////////////////////////////////
// On Function s
////////////////////////////////////////////////////////////////////////////////////////////////
void CLuaNameListView::OnSize(UINT nType, int cx, int cy)
{
	CWnd::OnSize(nType, cx, cy);

	RecreateBackBuffer(cx, cy);

	UpdateResize();
	Invalidate();
	UpdateWindow();
}
void CLuaNameListView::OnPaint()
{
	CPaintDC dc(this);
	CDC memdc;
	CBitmap* pOldBitmap;

	memdc.CreateCompatibleDC(&dc);
	pOldBitmap = memdc.SelectObject(&m_BackBuffer);

	CRect rc;
	GetClientRect(rc);

	// draw edge
	if (CCocos2dXViewer::isCrashed())
	{
		memdc.FillSolidRect(&rc, RGB(255, 100, 100));
	}
	else
	{
		// draw control background
		memdc.SelectObject(GetSysColorBrush(COLOR_BTNFACE));
		memdc.PatBlt(rc.left, rc.top, rc.Width(), rc.Height(), PATCOPY);

		memdc.DrawEdge(&rc, BDR_SUNKENOUTER, BF_RECT);
	}

	// draw control inside fill color
	rc.DeflateRect(2, 2);
	memdc.PatBlt(rc.left, rc.top, rc.Width(), rc.Height(), IsWindowEnabled() ? WHITENESS : PATCOPY);

	// create clip region
	HRGN hRgn = CreateRectRgn(rc.left, rc.top, rc.right, rc.bottom);
	SelectClipRgn(memdc.m_hDC, hRgn);

	int count = 0;
	std::list< maker::Entity*> l_entity = CEntityMgr::getInstance()->getLuaEntitiesWithCalc();
	for (maker::Entity* pEntity : l_entity)
	{
		DrawEntity(&memdc, rc, count, pEntity, false);
		++count;
	}

	// remove clip region
	SelectClipRgn(memdc.m_hDC, NULL);
	DeleteObject(hRgn);

	// copy back buffer to the display
	dc.GetClipBox(&rc);
	dc.BitBlt(rc.left, rc.top, rc.Width(), rc.Height(), &memdc, rc.left, rc.top, SRCCOPY);
	memdc.DeleteDC();
}
void CLuaNameListView::OnLButtonDown(UINT nFlags, CPoint point)
{
	CPoint ptcursor;
	GetCursorPos(&ptcursor);
	ScreenToClient(&ptcursor);

	SetFocus();

	int hit_part;
	auto* hit_entity = hitEntity(ptcursor, hit_part);
	if (hit_entity)
	{
		switch (hit_part)
		{
		case HIT_EXPAND:
			hit_entity->set_expand(!hit_entity->expand());
			UpdateResize();
			break;
		case HIT_LABEL:
		case HIT_NEXT:
		case HIT_FIRST_CHILD:
			if (GetAsyncKeyState(VK_CONTROL) & 0x8001)
			{
				maker::CMD cmd;
				CCMDPipe::getInstance()->initSelectAppend(cmd, hit_entity->id());
				CCMDPipe::getInstance()->send(cmd);
			}
			else
			{
				if (hit_entity->selected())
				{
					m_prepare_drag = true;
					m_prepare_drag_pos = point;
					SetCapture();
				}
				else
				{
					if (hit_entity != CEntityMgr::getInstance()->getCurrent())
					{
						maker::CMD cmd;
						CCMDPipe::getInstance()->initSelect(cmd, hit_entity->id());
						CCMDPipe::getInstance()->send(cmd);
					}
				}
			}
			break;
		}
	}
	else
	{
		maker::CMD cmd;
		CCMDPipe::getInstance()->initSelect(cmd, CEntityMgr::INVALID_ID);
		CCMDPipe::getInstance()->send(cmd);
	}
	Invalidate();
	UpdateWindow();

	CWnd::OnLButtonDown(nFlags, point);
}
void CLuaNameListView::OnLButtonUp(UINT nFlags, CPoint point)
{
	if (m_prepare_drag)
	{
		ReleaseCapture();
	}
	m_prepare_drag = false;

	if (m_drag)
	{
		m_drag = false;
		ReleaseCapture();

		CPoint ptcursor;
		GetCursorPos(&ptcursor);
		ScreenToClient(&ptcursor);

		int hit_part;
		auto hit_entity = hitReleaseEntity(ptcursor, hit_part);
		if (!hit_entity) return;

		auto current_entity = CEntityMgr::getInstance()->getCurrent();
		if (current_entity != hit_entity)
		{
			auto parent = CEntityMgr::getInstance()->get(current_entity->parent_id());

			CEntityMgr::ID dest_id = CEntityMgr::INVALID_ID;
			auto dest_parent = CEntityMgr::getInstance()->getRoot();
			if (hit_entity)
			{
				dest_parent = CEntityMgr::getInstance()->get(hit_entity->parent_id());
				if (hit_entity == CEntityMgr::getInstance()->getRoot())
				{
					dest_parent = hit_entity;
				}

				const maker::Entity* dest = nullptr;
				switch (hit_part)
				{
				case HIT_LABEL: {
					auto& children = hit_entity->children();
					auto count = children.size();
					if (count > 0)
					{
						auto& child = children.Get(count - 1);
						dest_id = child.id();
					}

					dest_parent = hit_entity;
				} break;
				case HIT_NEXT: dest_id = hit_entity->id(); break;
				case HIT_FIRST_CHILD: dest_parent = hit_entity; break;
				}
			}

			bool is_not_my_child = true;
			if (parent != dest_parent)
			{
				auto tmp_parent = dest_parent;
				while (tmp_parent && tmp_parent != CEntityMgr::getInstance()->getRoot())
				{
					if (tmp_parent->id() == current_entity->id())
					{
						is_not_my_child = false;
						break;
					}
					tmp_parent = CEntityMgr::getInstance()->get(tmp_parent->parent_id());
				}
			}

			if (is_not_my_child && parent && dest_parent && current_entity->id() != dest_id)
			{
				maker::CMD cmd;

				CEntityMgr::TYPE_SELECTED_ENTITIES selected_entities;
				CEntityMgr::getInstance()->getSelectedNearestChildren(selected_entities);

				auto dest_parent_type = dest_parent->properties().type();
				for (auto entity : selected_entities)
				{
					if (!CEntityMgr::getInstance()->canAppendChild(dest_parent_type, entity->properties().type())) continue;

					CEntityMgr::ID prev_sibling_id = CEntityMgr::INVALID_ID;
					auto prev_sibling = CEntityMgr::getInstance()->getPrevSibling(entity->id());
					if (prev_sibling) prev_sibling_id = prev_sibling->id();

					CCMDPipe::initMove(cmd, entity->id(), prev_sibling_id, entity->parent_id(), dest_id, dest_parent->id());
				}
				if (cmd.entities_size() > 0)
				{
					CCMDPipe::getInstance()->send(cmd);
				}
			}
		}

		UpdateResize();
		Invalidate();
		UpdateWindow();
	}

	CWnd::OnLButtonUp(nFlags, point);
}
BOOL CLuaNameListView::OnMouseWheel(UINT nFlags, short zDelta, CPoint pt)
{
	SCROLLINFO si;

	ZeroMemory(&si, sizeof(SCROLLINFO));
	si.cbSize = sizeof(SCROLLINFO);
	si.fMask = SIF_RANGE;

	GetScrollInfo(SB_VERT, &si);

	CRect rc;
	GetClientRect(rc);

	if (si.nMax - si.nMin < rc.Height())
		return TRUE;

	SetFocus();
	OnVScroll(zDelta < 0 ? SB_LINEDOWN : SB_LINEUP, 0, NULL);

	return TRUE;
}
void CLuaNameListView::OnVScroll(UINT nSBCode, UINT nPos, CScrollBar* pScrollBar)
{
	SCROLLINFO si;
	CRect rc;
	LONG nHeight;

	SetFocus();

	GetClientRect(rc);
	nHeight = rc.Height() + 1;

	ZeroMemory(&si, sizeof(SCROLLINFO));
	si.cbSize = sizeof(SCROLLINFO);
	si.fMask = SIF_RANGE;

	GetScrollInfo(SB_VERT, &si);

	LONG ny = m_origin.y;

	switch (nSBCode)
	{
	case SB_LINEDOWN:
		ny += NODE_DEFHEIGHT;
		break;

	case SB_LINEUP:
		ny -= NODE_DEFHEIGHT;
		break;

	case SB_PAGEDOWN:
		ny += nHeight;
		break;

	case SB_PAGEUP:
		ny -= nHeight;
		break;

	case SB_THUMBTRACK:
		ny = nPos;
		break;
	}

	ny = __min(__max(ny, si.nMin), si.nMax - nHeight);

	m_origin.y = ny;
	si.fMask = SIF_POS;
	si.nPos = ny;

	SetScrollInfo(SB_VERT, &si, TRUE);
	Invalidate();
}
void CLuaNameListView::OnCMD_Remove()
{
	CUIMakerDlg::onRemove();
}
void CLuaNameListView::OnCMD_SizeToContent()
{
	maker::CMD cmd;
	if (CCMDPipe::getInstance()->initSizeToContent(cmd))
	{
		CCMDPipe::getInstance()->send(cmd);
	}
}


////////////////////////////////////////////////////////////////////////////////////////////////
// OnCMD_Create Function s
////////////////////////////////////////////////////////////////////////////////////////////////
#pragma region OnCMD_CreateEntity_TypeXX
void CLuaNameListView::OnCMD_CreateEntity_Type00() { OnCMD_CreateEntity(0); }
void CLuaNameListView::OnCMD_CreateEntity_Type01() { OnCMD_CreateEntity(1); }
void CLuaNameListView::OnCMD_CreateEntity_Type02() { OnCMD_CreateEntity(2); }
void CLuaNameListView::OnCMD_CreateEntity_Type03() { OnCMD_CreateEntity(3); }
void CLuaNameListView::OnCMD_CreateEntity_Type04() { OnCMD_CreateEntity(4); }
void CLuaNameListView::OnCMD_CreateEntity_Type05() { OnCMD_CreateEntity(5); }
void CLuaNameListView::OnCMD_CreateEntity_Type06() { OnCMD_CreateEntity(6); }
void CLuaNameListView::OnCMD_CreateEntity_Type07() { OnCMD_CreateEntity(7); }
void CLuaNameListView::OnCMD_CreateEntity_Type08() { OnCMD_CreateEntity(8); }
void CLuaNameListView::OnCMD_CreateEntity_Type09() { OnCMD_CreateEntity(9); }
void CLuaNameListView::OnCMD_CreateEntity_Type10() { OnCMD_CreateEntity(10); }
void CLuaNameListView::OnCMD_CreateEntity_Type11() { OnCMD_CreateEntity(11); }
void CLuaNameListView::OnCMD_CreateEntity_Type12() { OnCMD_CreateEntity(12); }
void CLuaNameListView::OnCMD_CreateEntity_Type13() { OnCMD_CreateEntity(13); }
void CLuaNameListView::OnCMD_CreateEntity_Type14() { OnCMD_CreateEntity(14); }
void CLuaNameListView::OnCMD_CreateEntity_Type15() { OnCMD_CreateEntity(15); }
void CLuaNameListView::OnCMD_CreateEntity_Type16() { OnCMD_CreateEntity(16); }
void CLuaNameListView::OnCMD_CreateEntity_Type17() { OnCMD_CreateEntity(17); }
void CLuaNameListView::OnCMD_CreateEntity_Type18() { OnCMD_CreateEntity(18); }
void CLuaNameListView::OnCMD_CreateEntity_Type19() { OnCMD_CreateEntity(19); }
void CLuaNameListView::OnCMD_CreateEntity_Type20() { OnCMD_CreateEntity(20); }
void CLuaNameListView::OnCMD_CreateEntity_Type21() { OnCMD_CreateEntity(21); }
void CLuaNameListView::OnCMD_CreateEntity_Type22() { OnCMD_CreateEntity(22); }
void CLuaNameListView::OnCMD_CreateEntity_Type23() { OnCMD_CreateEntity(23); }
void CLuaNameListView::OnCMD_CreateEntity_Type24() { OnCMD_CreateEntity(24); }
void CLuaNameListView::OnCMD_CreateEntity_Type25() { OnCMD_CreateEntity(25); }
void CLuaNameListView::OnCMD_CreateEntity_Type26() { OnCMD_CreateEntity(26); }
void CLuaNameListView::OnCMD_CreateEntity_Type27() { OnCMD_CreateEntity(27); }
void CLuaNameListView::OnCMD_CreateEntity_Type28() { OnCMD_CreateEntity(28); }
void CLuaNameListView::OnCMD_CreateEntity_Type29() { OnCMD_CreateEntity(29); }
void CLuaNameListView::OnCMD_CreateEntity_Type30() { OnCMD_CreateEntity(30); }
void CLuaNameListView::OnCMD_CreateEntity_Type31() { OnCMD_CreateEntity(31); }
void CLuaNameListView::OnCMD_CreateEntity_Type32() { OnCMD_CreateEntity(32); }
void CLuaNameListView::OnCMD_CreateEntity_Type33() { OnCMD_CreateEntity(33); }
void CLuaNameListView::OnCMD_CreateEntity_Type34() { OnCMD_CreateEntity(34); }
void CLuaNameListView::OnCMD_CreateEntity_Type35() { OnCMD_CreateEntity(35); }
void CLuaNameListView::OnCMD_CreateEntity_Type36() { OnCMD_CreateEntity(36); }
void CLuaNameListView::OnCMD_CreateEntity_Type37() { OnCMD_CreateEntity(37); }
void CLuaNameListView::OnCMD_CreateEntity_Type38() { OnCMD_CreateEntity(38); }
void CLuaNameListView::OnCMD_CreateEntity_Type39() { OnCMD_CreateEntity(39); }
void CLuaNameListView::OnCMD_CreateEntity_Type40() { OnCMD_CreateEntity(40); }
void CLuaNameListView::OnCMD_CreateEntity_Type41() { OnCMD_CreateEntity(41); }
void CLuaNameListView::OnCMD_CreateEntity_Type42() { OnCMD_CreateEntity(42); }
void CLuaNameListView::OnCMD_CreateEntity_Type43() { OnCMD_CreateEntity(43); }
void CLuaNameListView::OnCMD_CreateEntity_Type44() { OnCMD_CreateEntity(44); }
void CLuaNameListView::OnCMD_CreateEntity_Type45() { OnCMD_CreateEntity(45); }
void CLuaNameListView::OnCMD_CreateEntity_Type46() { OnCMD_CreateEntity(46); }
void CLuaNameListView::OnCMD_CreateEntity_Type47() { OnCMD_CreateEntity(47); }
void CLuaNameListView::OnCMD_CreateEntity_Type48() { OnCMD_CreateEntity(48); }
void CLuaNameListView::OnCMD_CreateEntity_Type49() { OnCMD_CreateEntity(49); }
void CLuaNameListView::OnCMD_CreateEntity_Type50() { OnCMD_CreateEntity(50); }
void CLuaNameListView::OnCMD_CreateEntity_Type51() { OnCMD_CreateEntity(51); }
void CLuaNameListView::OnCMD_CreateEntity_Type52() { OnCMD_CreateEntity(52); }
void CLuaNameListView::OnCMD_CreateEntity_Type53() { OnCMD_CreateEntity(53); }
void CLuaNameListView::OnCMD_CreateEntity_Type54() { OnCMD_CreateEntity(54); }
void CLuaNameListView::OnCMD_CreateEntity_Type55() { OnCMD_CreateEntity(55); }
void CLuaNameListView::OnCMD_CreateEntity_Type56() { OnCMD_CreateEntity(56); }
void CLuaNameListView::OnCMD_CreateEntity_Type57() { OnCMD_CreateEntity(57); }
void CLuaNameListView::OnCMD_CreateEntity_Type58() { OnCMD_CreateEntity(58); }
void CLuaNameListView::OnCMD_CreateEntity_Type59() { OnCMD_CreateEntity(59); }
void CLuaNameListView::OnCMD_CreateEntity_Type60() { OnCMD_CreateEntity(60); }
void CLuaNameListView::OnCMD_CreateEntity_Type61() { OnCMD_CreateEntity(61); }
void CLuaNameListView::OnCMD_CreateEntity_Type62() { OnCMD_CreateEntity(62); }
void CLuaNameListView::OnCMD_CreateEntity_Type63() { OnCMD_CreateEntity(63); }
void CLuaNameListView::OnCMD_CreateEntity_Type64() { OnCMD_CreateEntity(64); }
void CLuaNameListView::OnCMD_CreateEntity_Type65() { OnCMD_CreateEntity(65); }
void CLuaNameListView::OnCMD_CreateEntity_Type66() { OnCMD_CreateEntity(66); }
void CLuaNameListView::OnCMD_CreateEntity_Type67() { OnCMD_CreateEntity(67); }
void CLuaNameListView::OnCMD_CreateEntity_Type68() { OnCMD_CreateEntity(68); }
void CLuaNameListView::OnCMD_CreateEntity_Type69() { OnCMD_CreateEntity(69); }
void CLuaNameListView::OnCMD_CreateEntity_Type70() { OnCMD_CreateEntity(70); }
void CLuaNameListView::OnCMD_CreateEntity_Type71() { OnCMD_CreateEntity(71); }
void CLuaNameListView::OnCMD_CreateEntity_Type72() { OnCMD_CreateEntity(72); }
void CLuaNameListView::OnCMD_CreateEntity_Type73() { OnCMD_CreateEntity(73); }
void CLuaNameListView::OnCMD_CreateEntity_Type74() { OnCMD_CreateEntity(74); }
void CLuaNameListView::OnCMD_CreateEntity_Type75() { OnCMD_CreateEntity(75); }
void CLuaNameListView::OnCMD_CreateEntity_Type76() { OnCMD_CreateEntity(76); }
void CLuaNameListView::OnCMD_CreateEntity_Type77() { OnCMD_CreateEntity(77); }
void CLuaNameListView::OnCMD_CreateEntity_Type78() { OnCMD_CreateEntity(78); }
void CLuaNameListView::OnCMD_CreateEntity_Type79() { OnCMD_CreateEntity(79); }
void CLuaNameListView::OnCMD_CreateEntity_Type80() { OnCMD_CreateEntity(80); }
void CLuaNameListView::OnCMD_CreateEntity_Type81() { OnCMD_CreateEntity(81); }
void CLuaNameListView::OnCMD_CreateEntity_Type82() { OnCMD_CreateEntity(82); }
void CLuaNameListView::OnCMD_CreateEntity_Type83() { OnCMD_CreateEntity(83); }
void CLuaNameListView::OnCMD_CreateEntity_Type84() { OnCMD_CreateEntity(84); }
void CLuaNameListView::OnCMD_CreateEntity_Type85() { OnCMD_CreateEntity(85); }
void CLuaNameListView::OnCMD_CreateEntity_Type86() { OnCMD_CreateEntity(86); }
void CLuaNameListView::OnCMD_CreateEntity_Type87() { OnCMD_CreateEntity(87); }
void CLuaNameListView::OnCMD_CreateEntity_Type88() { OnCMD_CreateEntity(88); }
void CLuaNameListView::OnCMD_CreateEntity_Type89() { OnCMD_CreateEntity(89); }
void CLuaNameListView::OnCMD_CreateEntity_Type90() { OnCMD_CreateEntity(90); }
void CLuaNameListView::OnCMD_CreateEntity_Type91() { OnCMD_CreateEntity(91); }
void CLuaNameListView::OnCMD_CreateEntity_Type92() { OnCMD_CreateEntity(92); }
void CLuaNameListView::OnCMD_CreateEntity_Type93() { OnCMD_CreateEntity(93); }
void CLuaNameListView::OnCMD_CreateEntity_Type94() { OnCMD_CreateEntity(94); }
void CLuaNameListView::OnCMD_CreateEntity_Type95() { OnCMD_CreateEntity(95); }
void CLuaNameListView::OnCMD_CreateEntity_Type96() { OnCMD_CreateEntity(96); }
void CLuaNameListView::OnCMD_CreateEntity_Type97() { OnCMD_CreateEntity(97); }
void CLuaNameListView::OnCMD_CreateEntity_Type98() { OnCMD_CreateEntity(98); }
void CLuaNameListView::OnCMD_CreateEntity_Type99() { OnCMD_CreateEntity(99); }

#pragma endregion recv message from popup menu
