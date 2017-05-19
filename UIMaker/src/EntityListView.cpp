// Entitys.cpp : 구현 파일입니다.
//

#include "stdafx.h"
#include "EntityListView.h"

#include "CMDPipe.h"

#include "Cocos2dXViewer.h"

#include "resource.h"
#include "UIMakerDlg.h"


#define NODE_DEFHEIGHT			20
#define NODE_EXPANDBOX			9
#define NODE_EXPANDBOXHALF		(NODE_EXPANDBOX/2)
#define NODE_CHECKBOX			14
#define NODE_EXPANDCOLUMN		16
#define NODE_INDENT				16
#define NODE_NEXT_HEAD			6
#define NODE_NEXT_HEIGHT		3

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

static const CString strOfficeFontName = _T("Tahoma");
static const CString strDefaultFontName = _T("MS Sans Serif");


// CEntityListView

IMPLEMENT_DYNAMIC(CEntityListView, CWnd)

CEntityListView::CEntityListView()
	: m_pNormalFont(nullptr)
	, m_pBoldFont(nullptr)
	, m_drag(false)
	, m_prepare_drag(false)
{

}
CEntityListView::~CEntityListView()
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

BOOL CEntityListView::Create(DWORD dwStyle, const RECT& rect, CWnd* pParentWnd, UINT nID)
{
	CWnd* pWnd = this;

	LPCTSTR pszCreateClass = AfxRegisterWndClass(CS_HREDRAW|CS_VREDRAW|CS_DBLCLKS, ::LoadCursor(NULL, IDC_ARROW));

	InitFont();

	return pWnd->Create(pszCreateClass, _T("UIMAKER_ENTITYS"), dwStyle, rect, pParentWnd, nID);
}

static int CALLBACK FontFamilyProcFonts(const LOGFONT FAR* lplf, const TEXTMETRIC FAR*, ULONG, LPARAM)
{
	ASSERT(lplf != NULL);
	CString strFont = lplf->lfFaceName;
	return strFont.CollateNoCase (strOfficeFontName) == 0 ? 0 : 1;
}
void CEntityListView::InitFont()
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
		if (::EnumFontFamilies(dc.GetSafeHdc(), NULL, FontFamilyProcFonts, 0)==0)
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

#pragma region MFC_MESSAGE_MAP

BEGIN_MESSAGE_MAP(CEntityListView, CWnd)
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

	ON_COMMAND(ID_CMD_GRID_ON_OFF, OnCMD_GridOnOff)
	ON_COMMAND(ID_CMD_RESET_ZOOM, OnCMD_ResetZoom)
	ON_COMMAND(ID_CMD_RESET_SCROLL, OnCMD_ResetScroll)

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


	ON_COMMAND(ID_CMD_PICK_ENTITY__00 + 0, OnCMD_PickEntity_00)
	ON_COMMAND(ID_CMD_PICK_ENTITY__00 + 1, OnCMD_PickEntity_01)
	ON_COMMAND(ID_CMD_PICK_ENTITY__00 + 2, OnCMD_PickEntity_02)
	ON_COMMAND(ID_CMD_PICK_ENTITY__00 + 3, OnCMD_PickEntity_03)
	ON_COMMAND(ID_CMD_PICK_ENTITY__00 + 4, OnCMD_PickEntity_04)
	ON_COMMAND(ID_CMD_PICK_ENTITY__00 + 5, OnCMD_PickEntity_05)
	ON_COMMAND(ID_CMD_PICK_ENTITY__00 + 6, OnCMD_PickEntity_06)
	ON_COMMAND(ID_CMD_PICK_ENTITY__00 + 7, OnCMD_PickEntity_07)
	ON_COMMAND(ID_CMD_PICK_ENTITY__00 + 8, OnCMD_PickEntity_08)
	ON_COMMAND(ID_CMD_PICK_ENTITY__00 + 9, OnCMD_PickEntity_09)
	ON_COMMAND(ID_CMD_PICK_ENTITY__00 + 10, OnCMD_PickEntity_10)
	ON_COMMAND(ID_CMD_PICK_ENTITY__00 + 11, OnCMD_PickEntity_11)
	ON_COMMAND(ID_CMD_PICK_ENTITY__00 + 12, OnCMD_PickEntity_12)
	ON_COMMAND(ID_CMD_PICK_ENTITY__00 + 13, OnCMD_PickEntity_13)
	ON_COMMAND(ID_CMD_PICK_ENTITY__00 + 14, OnCMD_PickEntity_14)
	ON_COMMAND(ID_CMD_PICK_ENTITY__00 + 15, OnCMD_PickEntity_15)
	ON_COMMAND(ID_CMD_PICK_ENTITY__00 + 16, OnCMD_PickEntity_16)
	ON_COMMAND(ID_CMD_PICK_ENTITY__00 + 17, OnCMD_PickEntity_17)
	ON_COMMAND(ID_CMD_PICK_ENTITY__00 + 18, OnCMD_PickEntity_18)
	ON_COMMAND(ID_CMD_PICK_ENTITY__00 + 19, OnCMD_PickEntity_19)
	ON_COMMAND(ID_CMD_PICK_ENTITY__00 + 20, OnCMD_PickEntity_20)
	ON_COMMAND(ID_CMD_PICK_ENTITY__00 + 21, OnCMD_PickEntity_21)
	ON_COMMAND(ID_CMD_PICK_ENTITY__00 + 22, OnCMD_PickEntity_22)
	ON_COMMAND(ID_CMD_PICK_ENTITY__00 + 23, OnCMD_PickEntity_23)
	ON_COMMAND(ID_CMD_PICK_ENTITY__00 + 24, OnCMD_PickEntity_24)
	ON_COMMAND(ID_CMD_PICK_ENTITY__00 + 25, OnCMD_PickEntity_25)
	ON_COMMAND(ID_CMD_PICK_ENTITY__00 + 26, OnCMD_PickEntity_26)
	ON_COMMAND(ID_CMD_PICK_ENTITY__00 + 27, OnCMD_PickEntity_27)
	ON_COMMAND(ID_CMD_PICK_ENTITY__00 + 28, OnCMD_PickEntity_28)
	ON_COMMAND(ID_CMD_PICK_ENTITY__00 + 29, OnCMD_PickEntity_29)
	ON_COMMAND(ID_CMD_PICK_ENTITY__00 + 30, OnCMD_PickEntity_30)
	ON_COMMAND(ID_CMD_PICK_ENTITY__00 + 31, OnCMD_PickEntity_31)
	ON_COMMAND(ID_CMD_PICK_ENTITY__00 + 32, OnCMD_PickEntity_32)
	ON_COMMAND(ID_CMD_PICK_ENTITY__00 + 33, OnCMD_PickEntity_33)
	ON_COMMAND(ID_CMD_PICK_ENTITY__00 + 34, OnCMD_PickEntity_34)
	ON_COMMAND(ID_CMD_PICK_ENTITY__00 + 35, OnCMD_PickEntity_35)
	ON_COMMAND(ID_CMD_PICK_ENTITY__00 + 36, OnCMD_PickEntity_36)
	ON_COMMAND(ID_CMD_PICK_ENTITY__00 + 37, OnCMD_PickEntity_37)
	ON_COMMAND(ID_CMD_PICK_ENTITY__00 + 38, OnCMD_PickEntity_38)
	ON_COMMAND(ID_CMD_PICK_ENTITY__00 + 39, OnCMD_PickEntity_39)
	ON_COMMAND(ID_CMD_PICK_ENTITY__00 + 40, OnCMD_PickEntity_40)
	ON_COMMAND(ID_CMD_PICK_ENTITY__00 + 41, OnCMD_PickEntity_41)
	ON_COMMAND(ID_CMD_PICK_ENTITY__00 + 42, OnCMD_PickEntity_42)
	ON_COMMAND(ID_CMD_PICK_ENTITY__00 + 43, OnCMD_PickEntity_43)
	ON_COMMAND(ID_CMD_PICK_ENTITY__00 + 44, OnCMD_PickEntity_44)
	ON_COMMAND(ID_CMD_PICK_ENTITY__00 + 45, OnCMD_PickEntity_45)
	ON_COMMAND(ID_CMD_PICK_ENTITY__00 + 46, OnCMD_PickEntity_46)
	ON_COMMAND(ID_CMD_PICK_ENTITY__00 + 47, OnCMD_PickEntity_47)
	ON_COMMAND(ID_CMD_PICK_ENTITY__00 + 48, OnCMD_PickEntity_48)
	ON_COMMAND(ID_CMD_PICK_ENTITY__00 + 49, OnCMD_PickEntity_49)
	ON_COMMAND(ID_CMD_PICK_ENTITY__00 + 50, OnCMD_PickEntity_50)
	ON_COMMAND(ID_CMD_PICK_ENTITY__00 + 51, OnCMD_PickEntity_51)
	ON_COMMAND(ID_CMD_PICK_ENTITY__00 + 52, OnCMD_PickEntity_52)
	ON_COMMAND(ID_CMD_PICK_ENTITY__00 + 53, OnCMD_PickEntity_53)
	ON_COMMAND(ID_CMD_PICK_ENTITY__00 + 54, OnCMD_PickEntity_54)
	ON_COMMAND(ID_CMD_PICK_ENTITY__00 + 55, OnCMD_PickEntity_55)
	ON_COMMAND(ID_CMD_PICK_ENTITY__00 + 56, OnCMD_PickEntity_56)
	ON_COMMAND(ID_CMD_PICK_ENTITY__00 + 57, OnCMD_PickEntity_57)
	ON_COMMAND(ID_CMD_PICK_ENTITY__00 + 58, OnCMD_PickEntity_58)
	ON_COMMAND(ID_CMD_PICK_ENTITY__00 + 59, OnCMD_PickEntity_59)
	ON_COMMAND(ID_CMD_PICK_ENTITY__00 + 60, OnCMD_PickEntity_60)
	ON_COMMAND(ID_CMD_PICK_ENTITY__00 + 61, OnCMD_PickEntity_61)
	ON_COMMAND(ID_CMD_PICK_ENTITY__00 + 62, OnCMD_PickEntity_62)
	ON_COMMAND(ID_CMD_PICK_ENTITY__00 + 63, OnCMD_PickEntity_63)
	ON_COMMAND(ID_CMD_PICK_ENTITY__00 + 64, OnCMD_PickEntity_64)
	ON_COMMAND(ID_CMD_PICK_ENTITY__00 + 65, OnCMD_PickEntity_65)
	ON_COMMAND(ID_CMD_PICK_ENTITY__00 + 66, OnCMD_PickEntity_66)
	ON_COMMAND(ID_CMD_PICK_ENTITY__00 + 67, OnCMD_PickEntity_67)
	ON_COMMAND(ID_CMD_PICK_ENTITY__00 + 68, OnCMD_PickEntity_68)
	ON_COMMAND(ID_CMD_PICK_ENTITY__00 + 69, OnCMD_PickEntity_69)
	ON_COMMAND(ID_CMD_PICK_ENTITY__00 + 70, OnCMD_PickEntity_70)
	ON_COMMAND(ID_CMD_PICK_ENTITY__00 + 71, OnCMD_PickEntity_71)
	ON_COMMAND(ID_CMD_PICK_ENTITY__00 + 72, OnCMD_PickEntity_72)
	ON_COMMAND(ID_CMD_PICK_ENTITY__00 + 73, OnCMD_PickEntity_73)
	ON_COMMAND(ID_CMD_PICK_ENTITY__00 + 74, OnCMD_PickEntity_74)
	ON_COMMAND(ID_CMD_PICK_ENTITY__00 + 75, OnCMD_PickEntity_75)
	ON_COMMAND(ID_CMD_PICK_ENTITY__00 + 76, OnCMD_PickEntity_76)
	ON_COMMAND(ID_CMD_PICK_ENTITY__00 + 77, OnCMD_PickEntity_77)
	ON_COMMAND(ID_CMD_PICK_ENTITY__00 + 78, OnCMD_PickEntity_78)
	ON_COMMAND(ID_CMD_PICK_ENTITY__00 + 79, OnCMD_PickEntity_79)
	ON_COMMAND(ID_CMD_PICK_ENTITY__00 + 80, OnCMD_PickEntity_80)
	ON_COMMAND(ID_CMD_PICK_ENTITY__00 + 81, OnCMD_PickEntity_81)
	ON_COMMAND(ID_CMD_PICK_ENTITY__00 + 82, OnCMD_PickEntity_82)
	ON_COMMAND(ID_CMD_PICK_ENTITY__00 + 83, OnCMD_PickEntity_83)
	ON_COMMAND(ID_CMD_PICK_ENTITY__00 + 84, OnCMD_PickEntity_84)
	ON_COMMAND(ID_CMD_PICK_ENTITY__00 + 85, OnCMD_PickEntity_85)
	ON_COMMAND(ID_CMD_PICK_ENTITY__00 + 86, OnCMD_PickEntity_86)
	ON_COMMAND(ID_CMD_PICK_ENTITY__00 + 87, OnCMD_PickEntity_87)
	ON_COMMAND(ID_CMD_PICK_ENTITY__00 + 88, OnCMD_PickEntity_88)
	ON_COMMAND(ID_CMD_PICK_ENTITY__00 + 89, OnCMD_PickEntity_89)
	ON_COMMAND(ID_CMD_PICK_ENTITY__00 + 90, OnCMD_PickEntity_90)
	ON_COMMAND(ID_CMD_PICK_ENTITY__00 + 91, OnCMD_PickEntity_91)
	ON_COMMAND(ID_CMD_PICK_ENTITY__00 + 92, OnCMD_PickEntity_92)
	ON_COMMAND(ID_CMD_PICK_ENTITY__00 + 93, OnCMD_PickEntity_93)
	ON_COMMAND(ID_CMD_PICK_ENTITY__00 + 94, OnCMD_PickEntity_94)
	ON_COMMAND(ID_CMD_PICK_ENTITY__00 + 95, OnCMD_PickEntity_95)
	ON_COMMAND(ID_CMD_PICK_ENTITY__00 + 96, OnCMD_PickEntity_96)
	ON_COMMAND(ID_CMD_PICK_ENTITY__00 + 97, OnCMD_PickEntity_97)
	ON_COMMAND(ID_CMD_PICK_ENTITY__00 + 98, OnCMD_PickEntity_98)
	ON_COMMAND(ID_CMD_PICK_ENTITY__00 + 99, OnCMD_PickEntity_99)

END_MESSAGE_MAP()

#pragma endregion 


// CEntityListView 메시지 처리기입니다.



void CEntityListView::OnSize(UINT nType, int cx, int cy) 
{
	CWnd::OnSize(nType, cx, cy);

	RecreateBackBuffer(cx, cy);

	UpdateResize();
	Invalidate();
	UpdateWindow();
}
void CEntityListView::UpdateResize()
{
	SCROLLINFO si;
	LONG nHeight;
	CRect rc;

	GetClientRect(rc);
	nHeight = rc.Height() + 1;

	ZeroMemory(&si, sizeof(SCROLLINFO));
	si.cbSize = sizeof(SCROLLINFO);
	si.fMask = SIF_RANGE | SIF_PAGE;
	si.nMin = 0;
	si.nMax = GetTotalHeight(CEntityMgr::getInstance()->getRoot());
	si.nPage = nHeight;

	if ((int)si.nPage > si.nMax) m_origin.y = 0;

	SetScrollInfo(SB_VERT, &si, TRUE);
}
int CEntityListView::GetTotalHeight(const maker::Entity* entity)
{
	if (!entity) return 0;

	bool is_expend = entity->expand();

	int total_height = NODE_DEFHEIGHT;
	if (is_expend)
	{
		for (int i = entity->children_size() - 1; i >= 0; --i)
		{
			total_height += GetTotalHeight(&(entity->children().Get(i)));
		}
	}
	return total_height;
}
void CEntityListView::UpdateScroll()
{
	CRect rc;
	GetClientRect(rc);
	LONG nHeight = rc.Height() + 1;

	SCROLLINFO si;
	ZeroMemory(&si, sizeof(SCROLLINFO));
	si.cbSize = sizeof(SCROLLINFO);
	si.fMask = SIF_RANGE | SIF_PAGE;
	si.nMin = 0;
	si.nMax = GetTotalHeight(CEntityMgr::getInstance()->getRoot());
	si.nPage = nHeight;

	bool found = false;
	LONG ny = GetScrollPos(CEntityMgr::getInstance()->getRoot(), CEntityMgr::getInstance()->getCurrent(), found);

	LONG y = __min(__max(ny, si.nMin), si.nMax - nHeight);

	if (m_origin.y > ny || m_origin.y + nHeight < ny)
	{
		m_origin.y = y;
		si.fMask |= SIF_POS;
		si.nPos = y;
	}

	SetScrollInfo(SB_VERT, &si, TRUE);
}
int CEntityListView::GetScrollPos(const maker::Entity* entity, const maker::Entity* current, bool& found)
{
	if (!entity) return 0;
	if (entity == current)
	{
		found = true;
		return 0;
	}

	bool is_expend = entity->expand();

	int total_height = NODE_DEFHEIGHT;
	if (is_expend)
	{
		for (int i = entity->children_size() - 1; i >= 0; --i)
		{
			total_height += GetScrollPos(&(entity->children().Get(i)), current, found);
			if (found) return total_height;
		}
	}
	return total_height;
}
void CEntityListView::RecreateBackBuffer(int cx, int cy)
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

void CEntityListView::Redraw()
{
	UpdateResize();
	Invalidate();
	UpdateWindow();
}

void CEntityListView::OnPaint() 
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
	rc.DeflateRect(2,2);
	memdc.PatBlt(rc.left, rc.top, rc.Width(), rc.Height(), IsWindowEnabled() ? WHITENESS : PATCOPY);

	// create clip region
	HRGN hRgn = CreateRectRgn(rc.left, rc.top, rc.right, rc.bottom);
	SelectClipRgn(memdc.m_hDC, hRgn);

	int count = 0;
	DrawEntity(&memdc, rc, count, CEntityMgr::getInstance()->getRoot(), 0, false);

	DrawDragEntity(&memdc, rc, CEntityMgr::getInstance()->getCurrent());

	// remove clip region
	SelectClipRgn(memdc.m_hDC, NULL);
	DeleteObject(hRgn);

	// copy back buffer to the display
	dc.GetClipBox(&rc);
	dc.BitBlt(rc.left, rc.top, rc.Width(), rc.Height(), &memdc, rc.left, rc.top, SRCCOPY);
	memdc.DeleteDC();
}

static void _DotHLine(HDC hdc, LONG x, LONG y, LONG w)
{
	for (; w>0; w -= 2, x += 2)
		SetPixel(hdc, x, y, GetSysColor(COLOR_BTNSHADOW));
}
static void _DrawExpand(HDC hdc, LONG x, LONG y, bool bExpand)
{
	HPEN hPen;
	HPEN oPen;
	HBRUSH oBrush;

	hPen = CreatePen(PS_SOLID, 1, GetSysColor(COLOR_BTNSHADOW));
	oPen = (HPEN)SelectObject(hdc, hPen);
	oBrush = (HBRUSH)SelectObject(hdc, GetStockObject(WHITE_BRUSH));

	Rectangle(hdc, x, y, x + NODE_EXPANDBOX, y + NODE_EXPANDBOX);
	SelectObject(hdc, GetStockObject(BLACK_PEN));

	if (!bExpand)
	{
		MoveToEx(hdc, x + NODE_EXPANDBOXHALF, y + 2, NULL);
		LineTo(hdc, x + NODE_EXPANDBOXHALF, y + NODE_EXPANDBOXHALF + 3);
	}

	MoveToEx(hdc, x + 2, y + NODE_EXPANDBOXHALF, NULL);
	LineTo(hdc, x + NODE_EXPANDBOX - 2, y + NODE_EXPANDBOXHALF);

	SelectObject(hdc, oPen);
	SelectObject(hdc, oBrush);
	DeleteObject(hPen);
}
static void _DrawBGRect(CDC* pDC, CRect rect, int brushIdx)
{
	HGDIOBJ oPen = pDC->SelectObject(GetStockObject(NULL_PEN));
	HGDIOBJ oBrush = pDC->SelectObject(GetSysColorBrush(brushIdx));

	CRect rcselect(rect);
	rcselect.left += NODE_EXPANDCOLUMN;

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
	rcdrag_targetnext.right = rcdrag_targetnext.left + NODE_NEXT_HEAD + NODE_EXPANDCOLUMN;
	rcdrag_targetnext.left -= 2;
	_DrawBGRect(pDC, rcdrag_targetnext, COLOR_HIGHLIGHT);

	rcdrag_targetnext.top += 2;
	rcdrag_targetnext.bottom -= 2;
	rcdrag_targetnext.left += 2;
	rcdrag_targetnext.right -= 2;
	_DrawBGRect(pDC, rcdrag_targetnext, AFX_IDC_COLOR_BLACK);
}
void CEntityListView::DrawEntity(CDC* pDC, CRect rect, int& count, const maker::Entity* entity, int depth, bool invisible)
{
	if (!entity) return;

	bool is_expend = entity->expand();

	if (entity->properties().has_node() && !entity->properties().node().visible())
	{
		invisible = true;
	}

	CPoint ptcursor;
	GetCursorPos(&ptcursor);
	ScreenToClient(&ptcursor);

	CRect rcitem(rect);
	rcitem.left = depth*NODE_EXPANDCOLUMN - m_origin.x;
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
	if (m_drag && rchititem.PtInRect(ptcursor))
	{
		rchititem.left = rcitem.left;
		if (entity->children_size() > 0 && is_expend)
		{
			CRect rcdrag_targetchild(rchititem);
			if (entity != CEntityMgr::getInstance()->getRoot()) rcdrag_targetchild.bottom -= NODE_NEXT_HEIGHT;
			if (rcdrag_targetchild.PtInRect(ptcursor))
			{
				CRect rcdrag_targetnext(rchititem);
				rcdrag_targetnext.left += NODE_EXPANDCOLUMN;
				_DrawInsertRect(pDC, rcdrag_targetnext, COLOR_HIGHLIGHT);
			}
			else
			{
				CRect rcdrag_targetnext(rchititem);
				rcdrag_targetnext.bottom += 1;
				if (rcdrag_targetnext.PtInRect(ptcursor) && entity != CEntityMgr::getInstance()->getRoot())
				{
					CRect rcdrag_targetnext(rchititem);
					rcdrag_targetnext.left += NODE_EXPANDCOLUMN;
					_DrawInsertRect(pDC, rcdrag_targetnext, COLOR_HIGHLIGHT);
				}
			}
		}
		else
		{
			CRect rcdrag_targetchild(rchititem);
			if (entity != CEntityMgr::getInstance()->getRoot()) rcdrag_targetchild.bottom -= NODE_NEXT_HEIGHT;
			if (rcdrag_targetchild.PtInRect(ptcursor))
			{
				CRect rcdrag_targetnext(rchititem);
				rcdrag_targetnext.left += NODE_EXPANDCOLUMN;
				_DrawInsertRect(pDC, rcdrag_targetnext, COLOR_HIGHLIGHT);
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
						_DrawInsertRect(pDC, rchititem, COLOR_HIGHLIGHT);
					}
					else
					{
						auto entity_tmp = entity;
						auto parent = CEntityMgr::getInstance()->get(entity_tmp->parent_id());
						if (parent && parent->children().Get(0).id() == entity_tmp->id())
						{
							CRect rcdrag_targetparentnext(rchititem);
							while (rcdrag_targetparentnext.left > NODE_EXPANDCOLUMN)
							{
								rcdrag_targetparentnext.right = rcdrag_targetparentnext.left + NODE_EXPANDCOLUMN;
								if (rcdrag_targetparentnext.PtInRect(ptcursor))
								{
									CRect rcdrag_targetnext(rchititem);
									rcdrag_targetnext.left = rcdrag_targetparentnext.left - NODE_EXPANDCOLUMN;
									rcdrag_targetnext.right = rchititem.right;
									_DrawInsertRect(pDC, rcdrag_targetnext, COLOR_HIGHLIGHT);
									break;
								}

								entity_tmp = parent;
								parent = CEntityMgr::getInstance()->get(entity_tmp->parent_id());
								rcdrag_targetparentnext.left -= NODE_EXPANDCOLUMN;
							}
						}
					}
				}
			}
		}
	}

	if (entity->children_size() > 0)
	{
		CRect rcexpand(rcitem);
		rcexpand.left += NODE_EXPANDCOLUMN / 2 - NODE_EXPANDBOXHALF;
		rcexpand.top += (rcitem.Height() - NODE_EXPANDBOX) / 2;
		rcexpand.right = rcexpand.left + NODE_EXPANDBOX - 1;
		rcexpand.bottom = rcexpand.top + NODE_EXPANDBOX - 1;
		_DrawExpand(pDC->m_hDC, rcexpand.left, rcexpand.top, is_expend);
	}

	std::string entity_info(GetEntityInfo(entity));

	CRect rctext(rcitem);
	rctext.left += NODE_EXPANDCOLUMN;
	if (invisible)
	{
		pDC->SetTextColor(GetSysColor(COLOR_GRAYTEXT));
	}
	else
	{
        pDC->SetTextColor(GetSysColor(textColor));
	}
	pDC->SetBkMode(TRANSPARENT);
	pDC->SelectObject(m_pNormalFont);
	pDC->DrawText(UTF16LE(entity_info).c_str(), &rctext, DT_SINGLELINE | DT_VCENTER | DT_END_ELLIPSIS);

	// draw horzontal sep
	_DotHLine(pDC->m_hDC, rctext.left, rcitem.bottom - 1, rctext.Width());

	++count;

	if (is_expend)
	{
		++depth;

		for (int i = entity->children_size() - 1; i >= 0; --i)
		{
			DrawEntity(pDC, rect, count, &(entity->children().Get(i)), depth, invisible);
		}
	}
}
void CEntityListView::DrawDragEntity(CDC* pDC, CRect rect, const maker::Entity* entity)
{
	if (!entity || !m_drag) return;

	CPoint ptcursor;
	GetCursorPos(&ptcursor);
	ScreenToClient(&ptcursor);

	CRect rcitem(rect);
	rcitem.left = ptcursor.x;
	rcitem.top = ptcursor.y;
	rcitem.bottom = rcitem.top + NODE_DEFHEIGHT - 1;

	_DrawBGRect(pDC, rcitem, COLOR_HIGHLIGHT);

	std::string entity_info(GetEntityInfo(entity));

	CRect rctext(rcitem);
	rctext.left += NODE_EXPANDCOLUMN;
	pDC->SetTextColor(GetSysColor(COLOR_HIGHLIGHTTEXT));
	pDC->SetBkMode(TRANSPARENT);
	pDC->SelectObject(m_pNormalFont);
	pDC->DrawText(UTF16LE(entity_info).c_str(), &rctext, DT_SINGLELINE | DT_VCENTER | DT_END_ELLIPSIS);

	// draw horzontal sep
	_DotHLine(pDC->m_hDC, rctext.left, rcitem.top + 1, rctext.Width());
	_DotHLine(pDC->m_hDC, rctext.left, rcitem.bottom - 1, rctext.Width());
}

std::string CEntityListView::GetEntityInfo(const maker::Entity* entity) const
{
	std::string entity_info("unknown entity !!");

	if (!entity) return entity_info;

	auto properties = entity->properties();
	auto desc = properties.GetDescriptor();
	auto reflect = properties.GetReflection();
	if (desc && reflect)
	{
		for (int i = 0; i < desc->field_count(); ++i)
		{
			auto* field = desc->field(i);
			if (!field) continue;

			const auto* ev = reflect->GetEnum(properties, field);
			if (ev->type()->name() == "ENTITY_TYPE")
			{
				entity_info = CEntityMgr::getInstance()->getEnumNameforTool(ev);
				break;
			}
		}
	}
	if (properties.has_node())
	{
		if (!properties.node().lua_name().empty())
		{
			entity_info += " : ";
			entity_info += properties.node().lua_name();
		}
		else
		{
			if (!properties.node().ui_name().empty())
			{
				entity_info += " : ";
			}
		}
		if (!properties.node().ui_name().empty())
		{
			entity_info += " - '";
			entity_info += properties.node().ui_name();
			entity_info += "'";
		}
	}

	switch (properties.type())
	{
	case maker::ENTITY__LabelSystemFont: entity_info += " - '" + properties.label_syatem_font().text() + "'"; break;
	case maker::ENTITY__LabelTTF: entity_info += " - '" + properties.label_ttf().text() + "'"; break;
	case maker::ENTITY__Sprite: entity_info += " - '" + properties.sprite().file_name().path() + "'"; break;
	case maker::ENTITY__Scale9Sprite: entity_info += " - '" + properties.scale_9_sprite().file_name().path() + "'"; break;
	case maker::ENTITY__ProgressTimer: entity_info += " - '" + properties.progress_timer().file_name().path() + "'"; break;
	case maker::ENTITY__Visual: entity_info += " - '" + properties.visual().file_name().path() + "'"; break;
	case maker::ENTITY__Particle: entity_info += " - '" + properties.particle().file_name().path() + "'"; break;
	case maker::ENTITY__SocketNode: entity_info = "Socket Node: '" + properties.socket_node().socket_name() + "'"; break;
	}

	return entity_info;
}

void CEntityListView::OnMouseMove(UINT nFlags, CPoint point)
{
	if (m_prepare_drag)
	{
		CPoint d = m_prepare_drag_pos - point;
		if (d.x*d.x + d.y*d.y > 25)
		{
			m_prepare_drag = false;
			m_drag = true;
		}
	}
	if (m_drag)
	{
		Invalidate();
	}

	CWnd::OnMouseMove(nFlags, point);
}
BOOL CEntityListView::OnMouseWheel(UINT nFlags, short zDelta, CPoint pt)
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
void CEntityListView::OnMouseLeave()
{
	// TODO: Add your message handler code here and/or call default

	CWnd::OnMouseLeave();
}

void CEntityListView::SetCurrentEntity(CEntityMgr::ID entity_id)
{
	CEntityMgr::getInstance()->setCurrentID(entity_id);

	auto entity = CEntityMgr::getInstance()->getParent(entity_id);
	while (entity)
	{
		if (entity)
		{
			entity->set_expand(true);
		}
		entity = CEntityMgr::getInstance()->get(entity->parent_id());
	}

	UpdateScroll();
	Invalidate();
}

maker::Entity* CEntityListView::hitReleaseEntity(const POINT& ptcursor, int& hit_part)
{
	CRect rcclient;
	GetClientRect(&rcclient);

	hit_part = HIT_CLIENT;

	int count = 0;
	CRect rchititem;
	auto entity = findHitEntity(rcclient, CEntityMgr::getInstance()->getRoot(), ptcursor, count, rchititem, 0, false);
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
maker::Entity* CEntityListView::hitEntity(const POINT& pt, int& hit_part)
{
	CRect rcclient;
	GetClientRect(&rcclient);

	hit_part = HIT_CLIENT;

	int count = 0;
	CRect rchititem;
	auto entity = findHitEntity(rcclient, CEntityMgr::getInstance()->getRoot(), pt, count, rchititem, 0, true);
	if (entity)
	{
		CRect rchitexpand(rchititem);
		rchitexpand.right = rchitexpand.left + NODE_EXPANDCOLUMN;
		if (rchitexpand.PtInRect(pt))
		{
			hit_part = HIT_EXPAND;
			return entity;
		}

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
maker::Entity* CEntityListView::findHitEntity(CRect rect, const maker::Entity* entity, const POINT& pt, int& count, CRect& rchititem, int depth, bool select_only_node)
{
	if (!entity) return nullptr;

	bool is_expend = entity->expand();

	CRect rcitem(rect);
	rcitem.left = depth*NODE_EXPANDCOLUMN - m_origin.x;
	rcitem.top = count*NODE_DEFHEIGHT - m_origin.y;
	rcitem.bottom = rcitem.top + NODE_DEFHEIGHT;

	CRect rcvaliditem(rcitem);
	rcvaliditem.left = 0;
	if (rcvaliditem.PtInRect(pt))
	{
		rchititem = rcitem;
		return const_cast<maker::Entity*>(entity);
	}

	++count;

	if (is_expend)
	{
		++depth;

		for (int i = entity->children_size() - 1; i >= 0; --i)
		{
			auto hit_entity = findHitEntity(rect, &(entity->children().Get(i)), pt, count, rchititem, depth, select_only_node);
			if (hit_entity)
			{
				if (select_only_node && hit_entity->properties().type() > maker::ENTITY__NoNeedNode)
				{
					rchititem = rcitem;
					hit_entity = const_cast<maker::Entity*>(entity);
				}
				return hit_entity;
			}
		}
	}

	return nullptr;
}

void CEntityListView::OnLButtonDown(UINT nFlags, CPoint point)
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
void CEntityListView::OnLButtonUp(UINT nFlags, CPoint point)
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

                // drag로 eneity들을 move시켰을 때 순서가 뒤바뀌지 않도록 처리
                selected_entities.reverse();

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
void CEntityListView::OnRButtonDown(UINT nFlags, CPoint point)
{
	SetFocus();

	CWnd::OnRButtonDown(nFlags, point);
}
void CEntityListView::OnRButtonUp(UINT nFlags, CPoint point)
{
	ClientToScreen(&point);
	OnContextMenu(this, point, false);
}
void CEntityListView::OnContextMenu(CWnd* /* pWnd */, CPoint point, bool callFromViewer, maker::CMD* cmd)
{
	CPoint ptcursor;
	GetCursorPos(&ptcursor);
	ScreenToClient(&ptcursor);

	int hit_part;
	auto* hit_entity = hitEntity(ptcursor, hit_part);
	if (hit_entity)
	{
		switch (hit_part)
		{
		case HIT_LABEL:
		case HIT_NEXT:
			if (hit_entity != CEntityMgr::getInstance()->getCurrent())
			{
				maker::CMD cmd;
				CCMDPipe::getInstance()->initSelect(cmd, hit_entity->id());
				CCMDPipe::getInstance()->send(cmd);
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

	// root 객체는 삭제 할 수 없다.
	if (hit_entity == CEntityMgr::getInstance()->getRoot())
	{
		hit_entity = nullptr;
	}

	m_MenuPopup.DestroyMenu();
	m_MenuPopup.CreatePopupMenu();

    bool isFirstMenu = true;
    bool isRoofContentMenu = false;

	auto edesc = maker::ENTITY_TYPE_descriptor();
	auto ev = edesc->value(0);
	auto base_index = ev->number();

	maker::ENTITY_TYPE parent_type = maker::ENTITY__Menu;
	if (hit_entity)
	{
		if (hit_entity && hit_entity != CEntityMgr::getInstance()->getRoot())
		{
			m_MenuPopup.AppendMenu(MF_STRING, ID_CMD_REMOVE, _T("&Remove"));
            isFirstMenu = false;
		}

		parent_type = hit_entity->properties().type();

        bool isShowSizeToContentMenu = false;

        if (parent_type == maker::ENTITY__Button ||
            parent_type == maker::ENTITY__LabelTTF ||
            parent_type == maker::ENTITY__LabelSystemFont ||
            parent_type == maker::ENTITY__Sprite ||
            parent_type == maker::ENTITY__Scale9Sprite)
        {
            isShowSizeToContentMenu = true;
        }
        else
        {
            CEntityMgr::TYPE_SELECTED_ENTITIES selected_entities;
            CEntityMgr::getInstance()->getSelectedNearestChildren(selected_entities);

            for (auto entity : selected_entities)
            {
                if (entity->properties().type() == maker::ENTITY__Button ||
                    entity->properties().type() == maker::ENTITY__LabelTTF ||
                    entity->properties().type() == maker::ENTITY__LabelSystemFont ||
                    entity->properties().type() == maker::ENTITY__Sprite ||
                    entity->properties().type() == maker::ENTITY__Scale9Sprite)
                {
                    isShowSizeToContentMenu = true;
                    break;
                }
            }
        }

        if (isShowSizeToContentMenu)
        {
            if (!isFirstMenu)
                m_MenuPopup.AppendMenu(MF_SEPARATOR);

            m_MenuPopup.AppendMenu(MF_STRING, ID_CMD_SIZETOCONTENT, _T("&Size to Content"));
            isFirstMenu = false;
        }
	}

    isRoofContentMenu = false;
	int enum_id = -1;
	for (int i = 0; i < edesc->value_count(); ++i)
	{
		auto ev = edesc->value(i);
		if (!ev) continue;
		if (!CEntityMgr::canAppendChild(parent_type, (maker::ENTITY_TYPE)ev->number())) continue;

		if (ev->number() >= maker::ENTITY__NoNeedNode) continue;

		if (enum_id >= 0 && enum_id + 1 < ev->number())
		{
			m_MenuPopup.AppendMenu(MF_SEPARATOR);
		}
        else if (!isFirstMenu)
        {
            m_MenuPopup.AppendMenu(MF_SEPARATOR);
            isFirstMenu = true;
        }

		enum_id = ev->number();

		std::string type_name(CEntityMgr::getInstance()->getEnumNameforTool(ev));
		std::string msg("Create ");

		m_MenuPopup.AppendMenu(MF_STRING, ID_CMD_CREATE_ENTITY_TYPE__00 + (enum_id - base_index), UTF16LE(msg + type_name).c_str());
        isRoofContentMenu = true;
	}

    if (isRoofContentMenu)
        isFirstMenu = false;

	if (callFromViewer)
	{
		if (cmd)
		{
            m_popup_cmd = *cmd;

            isRoofContentMenu = false;
            int i = 0;
			for (auto& entity : m_popup_cmd.entities())
			{
                if (!isFirstMenu)
                {
                    m_MenuPopup.AppendMenu(MF_SEPARATOR);
                    isFirstMenu = true;
                }

				auto entity_info = GetEntityInfo(CEntityMgr::getInstance()->get(entity.id()));
				m_MenuPopup.AppendMenu(MF_STRING, ID_CMD_PICK_ENTITY__00 + i, UTF16LE(">>  " + entity_info).c_str());
                isRoofContentMenu = true;
				++i;
			}

            if (isRoofContentMenu)
                isFirstMenu = false;
		}

        if (!isFirstMenu)
            m_MenuPopup.AppendMenu(MF_SEPARATOR);

		m_MenuPopup.AppendMenu(MF_STRING, ID_CMD_GRID_ON_OFF, _T("&Grid On/Off"));
		m_MenuPopup.AppendMenu(MF_STRING, ID_CMD_RESET_ZOOM, _T("Reset &Zoom"));
		m_MenuPopup.AppendMenu(MF_STRING, ID_CMD_RESET_SCROLL, _T("Reset &Scroll"));
        isFirstMenu = false;
	}

	GetCursorPos(&ptcursor);
	m_MenuPopup.TrackPopupMenu(TPM_LEFTBUTTON | TPM_CENTERALIGN, ptcursor.x, ptcursor.y, this, NULL);
	m_MenuPopup.Detach();
}

void CEntityListView::OnCMD_CreateEntity(int type)
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
void CEntityListView::OnCMD_PickEntity(int index)
{
	int i = 0;
	for (auto& entity : m_popup_cmd.entities())
	{
		if (index == i)
		{
			maker::CMD cmd;
			CCMDPipe::getInstance()->initSelect(cmd, entity.id());
			CCMDPipe::getInstance()->send(cmd);

			return;
		}
		++i;
	}
}

void CEntityListView::OnCMD_Remove()
{
	CUIMakerDlg::onRemove();
}

void CEntityListView::OnCMD_SizeToContent()
{
    maker::CMD cmd;
    if (CCMDPipe::getInstance()->initSizeToContent(cmd))
    {
        CCMDPipe::getInstance()->send(cmd);
    }
}

void CEntityListView::OnVScroll(UINT nSBCode, UINT nPos, CScrollBar* pScrollBar)
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


void CEntityListView::OnCMD_GridOnOff()
{
	maker::CMD cmd;
	if (CCMDPipe::getInstance()->initEventToViewer(cmd, maker::EVENT_TO_VIEWER(maker::VIEWER_EVENT__GridOnOff)))
	{
		CCMDPipe::getInstance()->send(cmd);
	}
}
void CEntityListView::OnCMD_GridOpacity()
{
	maker::CMD cmd;
	if (CCMDPipe::getInstance()->initEventToViewer(cmd, maker::EVENT_TO_VIEWER(maker::VIEWER_EVENT__GridOpacity)))
	{
		CCMDPipe::getInstance()->send(cmd);
	}
}
void CEntityListView::OnCMD_ResetZoom()
{
	maker::CMD cmd;
	if (CCMDPipe::getInstance()->initEventToViewer(cmd, maker::EVENT_TO_VIEWER(maker::VIEWER_EVENT__ResetZoom)))
	{
		CCMDPipe::getInstance()->send(cmd);
	}
}
void CEntityListView::OnCMD_ResetScroll()
{
	maker::CMD cmd;
	if (CCMDPipe::getInstance()->initEventToViewer(cmd, maker::EVENT_TO_VIEWER(maker::VIEWER_EVENT__ResetScroll)))
	{
		CCMDPipe::getInstance()->send(cmd);
	}
}

#pragma region OnCMD_CreateEntity_TypeXX
void CEntityListView::OnCMD_CreateEntity_Type00() { OnCMD_CreateEntity(0); }
void CEntityListView::OnCMD_CreateEntity_Type01() { OnCMD_CreateEntity(1); }
void CEntityListView::OnCMD_CreateEntity_Type02() { OnCMD_CreateEntity(2); }
void CEntityListView::OnCMD_CreateEntity_Type03() { OnCMD_CreateEntity(3); }
void CEntityListView::OnCMD_CreateEntity_Type04() { OnCMD_CreateEntity(4); }
void CEntityListView::OnCMD_CreateEntity_Type05() { OnCMD_CreateEntity(5); }
void CEntityListView::OnCMD_CreateEntity_Type06() { OnCMD_CreateEntity(6); }
void CEntityListView::OnCMD_CreateEntity_Type07() { OnCMD_CreateEntity(7); }
void CEntityListView::OnCMD_CreateEntity_Type08() { OnCMD_CreateEntity(8); }
void CEntityListView::OnCMD_CreateEntity_Type09() { OnCMD_CreateEntity(9); }
void CEntityListView::OnCMD_CreateEntity_Type10() { OnCMD_CreateEntity(10); }
void CEntityListView::OnCMD_CreateEntity_Type11() { OnCMD_CreateEntity(11); }
void CEntityListView::OnCMD_CreateEntity_Type12() { OnCMD_CreateEntity(12); }
void CEntityListView::OnCMD_CreateEntity_Type13() { OnCMD_CreateEntity(13); }
void CEntityListView::OnCMD_CreateEntity_Type14() { OnCMD_CreateEntity(14); }
void CEntityListView::OnCMD_CreateEntity_Type15() { OnCMD_CreateEntity(15); }
void CEntityListView::OnCMD_CreateEntity_Type16() { OnCMD_CreateEntity(16); }
void CEntityListView::OnCMD_CreateEntity_Type17() { OnCMD_CreateEntity(17); }
void CEntityListView::OnCMD_CreateEntity_Type18() { OnCMD_CreateEntity(18); }
void CEntityListView::OnCMD_CreateEntity_Type19() { OnCMD_CreateEntity(19); }
void CEntityListView::OnCMD_CreateEntity_Type20() { OnCMD_CreateEntity(20); }
void CEntityListView::OnCMD_CreateEntity_Type21() { OnCMD_CreateEntity(21); }
void CEntityListView::OnCMD_CreateEntity_Type22() { OnCMD_CreateEntity(22); }
void CEntityListView::OnCMD_CreateEntity_Type23() { OnCMD_CreateEntity(23); }
void CEntityListView::OnCMD_CreateEntity_Type24() { OnCMD_CreateEntity(24); }
void CEntityListView::OnCMD_CreateEntity_Type25() { OnCMD_CreateEntity(25); }
void CEntityListView::OnCMD_CreateEntity_Type26() { OnCMD_CreateEntity(26); }
void CEntityListView::OnCMD_CreateEntity_Type27() { OnCMD_CreateEntity(27); }
void CEntityListView::OnCMD_CreateEntity_Type28() { OnCMD_CreateEntity(28); }
void CEntityListView::OnCMD_CreateEntity_Type29() { OnCMD_CreateEntity(29); }
void CEntityListView::OnCMD_CreateEntity_Type30() { OnCMD_CreateEntity(30); }
void CEntityListView::OnCMD_CreateEntity_Type31() { OnCMD_CreateEntity(31); }
void CEntityListView::OnCMD_CreateEntity_Type32() { OnCMD_CreateEntity(32); }
void CEntityListView::OnCMD_CreateEntity_Type33() { OnCMD_CreateEntity(33); }
void CEntityListView::OnCMD_CreateEntity_Type34() { OnCMD_CreateEntity(34); }
void CEntityListView::OnCMD_CreateEntity_Type35() { OnCMD_CreateEntity(35); }
void CEntityListView::OnCMD_CreateEntity_Type36() { OnCMD_CreateEntity(36); }
void CEntityListView::OnCMD_CreateEntity_Type37() { OnCMD_CreateEntity(37); }
void CEntityListView::OnCMD_CreateEntity_Type38() { OnCMD_CreateEntity(38); }
void CEntityListView::OnCMD_CreateEntity_Type39() { OnCMD_CreateEntity(39); }
void CEntityListView::OnCMD_CreateEntity_Type40() { OnCMD_CreateEntity(40); }
void CEntityListView::OnCMD_CreateEntity_Type41() { OnCMD_CreateEntity(41); }
void CEntityListView::OnCMD_CreateEntity_Type42() { OnCMD_CreateEntity(42); }
void CEntityListView::OnCMD_CreateEntity_Type43() { OnCMD_CreateEntity(43); }
void CEntityListView::OnCMD_CreateEntity_Type44() { OnCMD_CreateEntity(44); }
void CEntityListView::OnCMD_CreateEntity_Type45() { OnCMD_CreateEntity(45); }
void CEntityListView::OnCMD_CreateEntity_Type46() { OnCMD_CreateEntity(46); }
void CEntityListView::OnCMD_CreateEntity_Type47() { OnCMD_CreateEntity(47); }
void CEntityListView::OnCMD_CreateEntity_Type48() { OnCMD_CreateEntity(48); }
void CEntityListView::OnCMD_CreateEntity_Type49() { OnCMD_CreateEntity(49); }
void CEntityListView::OnCMD_CreateEntity_Type50() { OnCMD_CreateEntity(50); }
void CEntityListView::OnCMD_CreateEntity_Type51() { OnCMD_CreateEntity(51); }
void CEntityListView::OnCMD_CreateEntity_Type52() { OnCMD_CreateEntity(52); }
void CEntityListView::OnCMD_CreateEntity_Type53() { OnCMD_CreateEntity(53); }
void CEntityListView::OnCMD_CreateEntity_Type54() { OnCMD_CreateEntity(54); }
void CEntityListView::OnCMD_CreateEntity_Type55() { OnCMD_CreateEntity(55); }
void CEntityListView::OnCMD_CreateEntity_Type56() { OnCMD_CreateEntity(56); }
void CEntityListView::OnCMD_CreateEntity_Type57() { OnCMD_CreateEntity(57); }
void CEntityListView::OnCMD_CreateEntity_Type58() { OnCMD_CreateEntity(58); }
void CEntityListView::OnCMD_CreateEntity_Type59() { OnCMD_CreateEntity(59); }
void CEntityListView::OnCMD_CreateEntity_Type60() { OnCMD_CreateEntity(60); }
void CEntityListView::OnCMD_CreateEntity_Type61() { OnCMD_CreateEntity(61); }
void CEntityListView::OnCMD_CreateEntity_Type62() { OnCMD_CreateEntity(62); }
void CEntityListView::OnCMD_CreateEntity_Type63() { OnCMD_CreateEntity(63); }
void CEntityListView::OnCMD_CreateEntity_Type64() { OnCMD_CreateEntity(64); }
void CEntityListView::OnCMD_CreateEntity_Type65() { OnCMD_CreateEntity(65); }
void CEntityListView::OnCMD_CreateEntity_Type66() { OnCMD_CreateEntity(66); }
void CEntityListView::OnCMD_CreateEntity_Type67() { OnCMD_CreateEntity(67); }
void CEntityListView::OnCMD_CreateEntity_Type68() { OnCMD_CreateEntity(68); }
void CEntityListView::OnCMD_CreateEntity_Type69() { OnCMD_CreateEntity(69); }
void CEntityListView::OnCMD_CreateEntity_Type70() { OnCMD_CreateEntity(70); }
void CEntityListView::OnCMD_CreateEntity_Type71() { OnCMD_CreateEntity(71); }
void CEntityListView::OnCMD_CreateEntity_Type72() { OnCMD_CreateEntity(72); }
void CEntityListView::OnCMD_CreateEntity_Type73() { OnCMD_CreateEntity(73); }
void CEntityListView::OnCMD_CreateEntity_Type74() { OnCMD_CreateEntity(74); }
void CEntityListView::OnCMD_CreateEntity_Type75() { OnCMD_CreateEntity(75); }
void CEntityListView::OnCMD_CreateEntity_Type76() { OnCMD_CreateEntity(76); }
void CEntityListView::OnCMD_CreateEntity_Type77() { OnCMD_CreateEntity(77); }
void CEntityListView::OnCMD_CreateEntity_Type78() { OnCMD_CreateEntity(78); }
void CEntityListView::OnCMD_CreateEntity_Type79() { OnCMD_CreateEntity(79); }
void CEntityListView::OnCMD_CreateEntity_Type80() { OnCMD_CreateEntity(80); }
void CEntityListView::OnCMD_CreateEntity_Type81() { OnCMD_CreateEntity(81); }
void CEntityListView::OnCMD_CreateEntity_Type82() { OnCMD_CreateEntity(82); }
void CEntityListView::OnCMD_CreateEntity_Type83() { OnCMD_CreateEntity(83); }
void CEntityListView::OnCMD_CreateEntity_Type84() { OnCMD_CreateEntity(84); }
void CEntityListView::OnCMD_CreateEntity_Type85() { OnCMD_CreateEntity(85); }
void CEntityListView::OnCMD_CreateEntity_Type86() { OnCMD_CreateEntity(86); }
void CEntityListView::OnCMD_CreateEntity_Type87() { OnCMD_CreateEntity(87); }
void CEntityListView::OnCMD_CreateEntity_Type88() { OnCMD_CreateEntity(88); }
void CEntityListView::OnCMD_CreateEntity_Type89() { OnCMD_CreateEntity(89); }
void CEntityListView::OnCMD_CreateEntity_Type90() { OnCMD_CreateEntity(90); }
void CEntityListView::OnCMD_CreateEntity_Type91() { OnCMD_CreateEntity(91); }
void CEntityListView::OnCMD_CreateEntity_Type92() { OnCMD_CreateEntity(92); }
void CEntityListView::OnCMD_CreateEntity_Type93() { OnCMD_CreateEntity(93); }
void CEntityListView::OnCMD_CreateEntity_Type94() { OnCMD_CreateEntity(94); }
void CEntityListView::OnCMD_CreateEntity_Type95() { OnCMD_CreateEntity(95); }
void CEntityListView::OnCMD_CreateEntity_Type96() { OnCMD_CreateEntity(96); }
void CEntityListView::OnCMD_CreateEntity_Type97() { OnCMD_CreateEntity(97); }
void CEntityListView::OnCMD_CreateEntity_Type98() { OnCMD_CreateEntity(98); }
void CEntityListView::OnCMD_CreateEntity_Type99() { OnCMD_CreateEntity(99); }

void CEntityListView::OnCMD_PickEntity_00() { OnCMD_PickEntity(0); }
void CEntityListView::OnCMD_PickEntity_01() { OnCMD_PickEntity(1); }
void CEntityListView::OnCMD_PickEntity_02() { OnCMD_PickEntity(2); }
void CEntityListView::OnCMD_PickEntity_03() { OnCMD_PickEntity(3); }
void CEntityListView::OnCMD_PickEntity_04() { OnCMD_PickEntity(4); }
void CEntityListView::OnCMD_PickEntity_05() { OnCMD_PickEntity(5); }
void CEntityListView::OnCMD_PickEntity_06() { OnCMD_PickEntity(6); }
void CEntityListView::OnCMD_PickEntity_07() { OnCMD_PickEntity(7); }
void CEntityListView::OnCMD_PickEntity_08() { OnCMD_PickEntity(8); }
void CEntityListView::OnCMD_PickEntity_09() { OnCMD_PickEntity(9); }
void CEntityListView::OnCMD_PickEntity_10() { OnCMD_PickEntity(10); }
void CEntityListView::OnCMD_PickEntity_11() { OnCMD_PickEntity(11); }
void CEntityListView::OnCMD_PickEntity_12() { OnCMD_PickEntity(12); }
void CEntityListView::OnCMD_PickEntity_13() { OnCMD_PickEntity(13); }
void CEntityListView::OnCMD_PickEntity_14() { OnCMD_PickEntity(14); }
void CEntityListView::OnCMD_PickEntity_15() { OnCMD_PickEntity(15); }
void CEntityListView::OnCMD_PickEntity_16() { OnCMD_PickEntity(16); }
void CEntityListView::OnCMD_PickEntity_17() { OnCMD_PickEntity(17); }
void CEntityListView::OnCMD_PickEntity_18() { OnCMD_PickEntity(18); }
void CEntityListView::OnCMD_PickEntity_19() { OnCMD_PickEntity(19); }
void CEntityListView::OnCMD_PickEntity_20() { OnCMD_PickEntity(20); }
void CEntityListView::OnCMD_PickEntity_21() { OnCMD_PickEntity(21); }
void CEntityListView::OnCMD_PickEntity_22() { OnCMD_PickEntity(22); }
void CEntityListView::OnCMD_PickEntity_23() { OnCMD_PickEntity(23); }
void CEntityListView::OnCMD_PickEntity_24() { OnCMD_PickEntity(24); }
void CEntityListView::OnCMD_PickEntity_25() { OnCMD_PickEntity(25); }
void CEntityListView::OnCMD_PickEntity_26() { OnCMD_PickEntity(26); }
void CEntityListView::OnCMD_PickEntity_27() { OnCMD_PickEntity(27); }
void CEntityListView::OnCMD_PickEntity_28() { OnCMD_PickEntity(28); }
void CEntityListView::OnCMD_PickEntity_29() { OnCMD_PickEntity(29); }
void CEntityListView::OnCMD_PickEntity_30() { OnCMD_PickEntity(30); }
void CEntityListView::OnCMD_PickEntity_31() { OnCMD_PickEntity(31); }
void CEntityListView::OnCMD_PickEntity_32() { OnCMD_PickEntity(32); }
void CEntityListView::OnCMD_PickEntity_33() { OnCMD_PickEntity(33); }
void CEntityListView::OnCMD_PickEntity_34() { OnCMD_PickEntity(34); }
void CEntityListView::OnCMD_PickEntity_35() { OnCMD_PickEntity(35); }
void CEntityListView::OnCMD_PickEntity_36() { OnCMD_PickEntity(36); }
void CEntityListView::OnCMD_PickEntity_37() { OnCMD_PickEntity(37); }
void CEntityListView::OnCMD_PickEntity_38() { OnCMD_PickEntity(38); }
void CEntityListView::OnCMD_PickEntity_39() { OnCMD_PickEntity(39); }
void CEntityListView::OnCMD_PickEntity_40() { OnCMD_PickEntity(40); }
void CEntityListView::OnCMD_PickEntity_41() { OnCMD_PickEntity(41); }
void CEntityListView::OnCMD_PickEntity_42() { OnCMD_PickEntity(42); }
void CEntityListView::OnCMD_PickEntity_43() { OnCMD_PickEntity(43); }
void CEntityListView::OnCMD_PickEntity_44() { OnCMD_PickEntity(44); }
void CEntityListView::OnCMD_PickEntity_45() { OnCMD_PickEntity(45); }
void CEntityListView::OnCMD_PickEntity_46() { OnCMD_PickEntity(46); }
void CEntityListView::OnCMD_PickEntity_47() { OnCMD_PickEntity(47); }
void CEntityListView::OnCMD_PickEntity_48() { OnCMD_PickEntity(48); }
void CEntityListView::OnCMD_PickEntity_49() { OnCMD_PickEntity(49); }
void CEntityListView::OnCMD_PickEntity_50() { OnCMD_PickEntity(50); }
void CEntityListView::OnCMD_PickEntity_51() { OnCMD_PickEntity(51); }
void CEntityListView::OnCMD_PickEntity_52() { OnCMD_PickEntity(52); }
void CEntityListView::OnCMD_PickEntity_53() { OnCMD_PickEntity(53); }
void CEntityListView::OnCMD_PickEntity_54() { OnCMD_PickEntity(54); }
void CEntityListView::OnCMD_PickEntity_55() { OnCMD_PickEntity(55); }
void CEntityListView::OnCMD_PickEntity_56() { OnCMD_PickEntity(56); }
void CEntityListView::OnCMD_PickEntity_57() { OnCMD_PickEntity(57); }
void CEntityListView::OnCMD_PickEntity_58() { OnCMD_PickEntity(58); }
void CEntityListView::OnCMD_PickEntity_59() { OnCMD_PickEntity(59); }
void CEntityListView::OnCMD_PickEntity_60() { OnCMD_PickEntity(60); }
void CEntityListView::OnCMD_PickEntity_61() { OnCMD_PickEntity(61); }
void CEntityListView::OnCMD_PickEntity_62() { OnCMD_PickEntity(62); }
void CEntityListView::OnCMD_PickEntity_63() { OnCMD_PickEntity(63); }
void CEntityListView::OnCMD_PickEntity_64() { OnCMD_PickEntity(64); }
void CEntityListView::OnCMD_PickEntity_65() { OnCMD_PickEntity(65); }
void CEntityListView::OnCMD_PickEntity_66() { OnCMD_PickEntity(66); }
void CEntityListView::OnCMD_PickEntity_67() { OnCMD_PickEntity(67); }
void CEntityListView::OnCMD_PickEntity_68() { OnCMD_PickEntity(68); }
void CEntityListView::OnCMD_PickEntity_69() { OnCMD_PickEntity(69); }
void CEntityListView::OnCMD_PickEntity_70() { OnCMD_PickEntity(70); }
void CEntityListView::OnCMD_PickEntity_71() { OnCMD_PickEntity(71); }
void CEntityListView::OnCMD_PickEntity_72() { OnCMD_PickEntity(72); }
void CEntityListView::OnCMD_PickEntity_73() { OnCMD_PickEntity(73); }
void CEntityListView::OnCMD_PickEntity_74() { OnCMD_PickEntity(74); }
void CEntityListView::OnCMD_PickEntity_75() { OnCMD_PickEntity(75); }
void CEntityListView::OnCMD_PickEntity_76() { OnCMD_PickEntity(76); }
void CEntityListView::OnCMD_PickEntity_77() { OnCMD_PickEntity(77); }
void CEntityListView::OnCMD_PickEntity_78() { OnCMD_PickEntity(78); }
void CEntityListView::OnCMD_PickEntity_79() { OnCMD_PickEntity(79); }
void CEntityListView::OnCMD_PickEntity_80() { OnCMD_PickEntity(80); }
void CEntityListView::OnCMD_PickEntity_81() { OnCMD_PickEntity(81); }
void CEntityListView::OnCMD_PickEntity_82() { OnCMD_PickEntity(82); }
void CEntityListView::OnCMD_PickEntity_83() { OnCMD_PickEntity(83); }
void CEntityListView::OnCMD_PickEntity_84() { OnCMD_PickEntity(84); }
void CEntityListView::OnCMD_PickEntity_85() { OnCMD_PickEntity(85); }
void CEntityListView::OnCMD_PickEntity_86() { OnCMD_PickEntity(86); }
void CEntityListView::OnCMD_PickEntity_87() { OnCMD_PickEntity(87); }
void CEntityListView::OnCMD_PickEntity_88() { OnCMD_PickEntity(88); }
void CEntityListView::OnCMD_PickEntity_89() { OnCMD_PickEntity(89); }
void CEntityListView::OnCMD_PickEntity_90() { OnCMD_PickEntity(90); }
void CEntityListView::OnCMD_PickEntity_91() { OnCMD_PickEntity(91); }
void CEntityListView::OnCMD_PickEntity_92() { OnCMD_PickEntity(92); }
void CEntityListView::OnCMD_PickEntity_93() { OnCMD_PickEntity(93); }
void CEntityListView::OnCMD_PickEntity_94() { OnCMD_PickEntity(94); }
void CEntityListView::OnCMD_PickEntity_95() { OnCMD_PickEntity(95); }
void CEntityListView::OnCMD_PickEntity_96() { OnCMD_PickEntity(96); }
void CEntityListView::OnCMD_PickEntity_97() { OnCMD_PickEntity(97); }
void CEntityListView::OnCMD_PickEntity_98() { OnCMD_PickEntity(98); }
void CEntityListView::OnCMD_PickEntity_99() { OnCMD_PickEntity(99); }
#pragma endregion recv message from popup menu
