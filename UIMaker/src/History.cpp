// History.cpp : implementation file
//

#include "stdafx.h"
#include "UIMaker.h"
#include "History.h"


#define NODE_DEFHEIGHT			20
#define NODE_HEAD				16

static const CString strOfficeFontName = _T("Tahoma");
static const CString strDefaultFontName = _T("MS Sans Serif");

// CHistory

IMPLEMENT_DYNAMIC(CHistory, CWnd)

CHistory::CHistory()
	: m_pNormalFont(nullptr)
	, m_pBoldFont(nullptr)
{
    _oldHistoryCount = 0;
}
CHistory::~CHistory()
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

BOOL CHistory::Create(DWORD dwStyle, const RECT& rect, CWnd* pParentWnd, UINT nID)
{
	CWnd* pWnd = this;

	LPCTSTR pszCreateClass = AfxRegisterWndClass(CS_HREDRAW | CS_VREDRAW | CS_DBLCLKS, ::LoadCursor(NULL, IDC_ARROW));

	InitFont();

	return pWnd->Create(pszCreateClass, _T("UIMAKER_UINODES"), dwStyle, rect, pParentWnd, nID);
}

static int CALLBACK FontFamilyProcFonts(const LOGFONT FAR* lplf, const TEXTMETRIC FAR*, ULONG, LPARAM)
{
	ASSERT(lplf != NULL);
	CString strFont = lplf->lfFaceName;
	return strFont.CollateNoCase(strOfficeFontName) == 0 ? 0 : 1;
}
void CHistory::InitFont()
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


BEGIN_MESSAGE_MAP(CHistory, CWnd)
	ON_WM_SIZE()
	ON_WM_PAINT()
	ON_WM_MOUSEWHEEL()
	ON_WM_LBUTTONDOWN()
	ON_WM_VSCROLL()
END_MESSAGE_MAP()



// CHistory message handlers



void CHistory::OnSize(UINT nType, int cx, int cy)
{
	CWnd::OnSize(nType, cx, cy);

	RecreateBackBuffer(cx, cy);

	UpdateResize();
	Invalidate();
	UpdateWindow();
}
void CHistory::UpdateResize()
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

    /*
	int count = 0;
	auto current_id = CCMDPipe::getInstance()->getCurrentCmdID();
	auto& history = CCMDPipe::getInstance()->getHistory();
	for (auto& cmd : history)
	{
		if (cmd.id() == current_id)
		{
			ny = count*NODE_DEFHEIGHT;
			break;
		}
		++count;
	}
	ny = __min(__max(ny, si.nMin), si.nMax - nHeight);
    */

    if (CCMDPipe::getInstance()->getHistory().size() != _oldHistoryCount)
    {
        _oldHistoryCount = CCMDPipe::getInstance()->getHistory().size();
        ny = __max(si.nMin, si.nMax - nHeight);
    }

	if ((int)si.nPage > si.nMax) ny = 0;

	m_origin.y = ny;
	si.nPos = ny;

	SetScrollInfo(SB_VERT, &si, TRUE);
}
int CHistory::GetTotalHeight()
{
	int total_height = CCMDPipe::getInstance()->getHistory().size()*NODE_DEFHEIGHT;

	return total_height + NODE_DEFHEIGHT*2; // 시작과 끝을 표시하기 위해
}
void CHistory::RecreateBackBuffer(int cx, int cy)
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

void CHistory::Redraw()
{
	UpdateResize();
	Invalidate();
	UpdateWindow();
}

void CHistory::OnPaint()
{
	CPaintDC dc(this);
	CDC memdc;
	CBitmap* pOldBitmap;

	memdc.CreateCompatibleDC(&dc);
	pOldBitmap = memdc.SelectObject(&m_BackBuffer);

	CRect rc;
	GetClientRect(rc);

	// draw control background
	memdc.SelectObject(GetSysColorBrush(COLOR_BTNFACE));
	memdc.PatBlt(rc.left, rc.top, rc.Width(), rc.Height(), PATCOPY);

	// draw control inside fill color
	rc.DeflateRect(2, 2);
	memdc.PatBlt(rc.left, rc.top, rc.Width(), rc.Height(), IsWindowEnabled() ? WHITENESS : PATCOPY);
	rc.InflateRect(2, 2);

	// draw edge
	memdc.DrawEdge(&rc, BDR_SUNKENOUTER, BF_RECT);

	rc.DeflateRect(2, 2);

	// create clip region
	HRGN hRgn = CreateRectRgn(rc.left, rc.top, rc.right, rc.bottom);
	SelectClipRgn(memdc.m_hDC, hRgn);

	DrawCmdHistory(&memdc, rc);
	
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
void CHistory::DrawCmdHistory(CDC* pDC, CRect rect)
{
	int count = 0;
	auto current_id = CCMDPipe::getInstance()->getCurrentCmdID();
	DrawBegin(pDC, rect, count, false);
	{
		auto& history = CCMDPipe::getInstance()->getHistory();

        if (current_id == 0 && history.size() > 0)
        {
            current_id = history.rbegin()->id();
        }

		for (auto& cmd : history)
		{
			DrawCmd(pDC, rect, count, cmd, cmd.id() == current_id);
		}
	}
	DrawEnd(pDC, rect, count, false);
}
CRect CHistory::CalCurrentRect(CRect rcclient, int count)
{
	CRect rc(rcclient);
	rc.left = NODE_HEAD - m_origin.x;
	rc.top = count*NODE_DEFHEIGHT - m_origin.y;
	rc.bottom = rc.top + NODE_DEFHEIGHT - 1;

	return rc;
}
void CHistory::DrawBegin(CDC* pDC, CRect rect, int& count, bool current_cmd)
{
	CRect rcitem(CalCurrentRect(rect, count));

	++count;

	if (rcitem.bottom < 0) return;
	if (rcitem.top > rect.bottom) return;

	if (current_cmd)
	{
		_DrawBGRect(pDC, rcitem, COLOR_INACTIVECAPTION);
	}

	std::string node_info("unknown node !!");

	CRect rctext(rcitem);
	rctext.left += NODE_HEAD;
    pDC->SetTextColor(GetSysColor(COLOR_INACTIVECAPTIONTEXT));
	pDC->SetBkMode(TRANSPARENT);
	pDC->SelectObject(m_pNormalFont);
	pDC->DrawText(_T(">> Begin - CMD history"), &rctext, DT_SINGLELINE | DT_VCENTER | DT_END_ELLIPSIS);

	// draw horzontal sep
	_DotHLine(pDC->m_hDC, rctext.left, rcitem.bottom - 1, rctext.Width());
}
void CHistory::DrawCmd(CDC* pDC, CRect rect, int& count, const maker::CMD& cmd, bool current_cmd)
{
	CRect rcitem(CalCurrentRect(rect, count));

	++count;

	if (rcitem.bottom < 0) return;
	if (rcitem.top > rect.bottom) return;

    int textColor = COLOR_BTNTEXT;
	if (current_cmd)
	{
        _DrawBGRect(pDC, rcitem, COLOR_HIGHLIGHT);
        textColor = COLOR_BTNHIGHLIGHT;
	}

	std::string node_info("unknown node !!");

	CRect rctext(rcitem);
	rctext.left += NODE_HEAD;
    pDC->SetTextColor(GetSysColor(textColor));
	pDC->SetBkMode(TRANSPARENT);
	pDC->SelectObject(m_pNormalFont);
	if (cmd.has_description())
	{
		pDC->DrawText(UTF16LE(cmd.description()).c_str(), &rctext, DT_SINGLELINE | DT_VCENTER | DT_END_ELLIPSIS);
	}
	else
	{
		pDC->DrawText(_T("No CMD description !!"), &rctext, DT_SINGLELINE | DT_VCENTER | DT_END_ELLIPSIS);
	}

	// draw horzontal sep
	_DotHLine(pDC->m_hDC, rctext.left, rcitem.bottom - 1, rctext.Width());
}
void CHistory::DrawEnd(CDC* pDC, CRect rect, int& count, bool current_cmd)
{
	CRect rcitem(CalCurrentRect(rect, count));

	++count;

	if (rcitem.bottom < 0) return;
	if (rcitem.top > rect.bottom) return;

	if (current_cmd)
	{
		_DrawBGRect(pDC, rcitem, COLOR_INACTIVECAPTION);
	}

	std::string node_info("unknown node !!");

	CRect rctext(rcitem);
	rctext.left += NODE_HEAD;
    pDC->SetTextColor(GetSysColor(COLOR_INACTIVECAPTIONTEXT));
	pDC->SetBkMode(TRANSPARENT);
	pDC->SelectObject(m_pNormalFont);
	pDC->DrawText(_T(">> End - CMD History"), &rctext, DT_SINGLELINE | DT_VCENTER | DT_END_ELLIPSIS);

	// draw horzontal sep
	_DotHLine(pDC->m_hDC, rctext.left, rcitem.bottom - 1, rctext.Width());
}

maker::CMD* CHistory::HitTest(const POINT& pt)
{
	CRect rcclient;
	GetClientRect(&rcclient);

	const maker::CMD* hit_cmd = nullptr;

	int count = 1; // begin 표시 다음부터 피킹 테스트
	auto& history = CCMDPipe::getInstance()->getHistory();
	for (auto& cmd : history)
	{
		CRect rcitem(CalCurrentRect(rcclient, count));

		++count;

		if (rcitem.PtInRect(pt))
		{
			hit_cmd = &cmd;
			break;
		}
	}

	return const_cast<maker::CMD*>(hit_cmd);
}

BOOL CHistory::OnMouseWheel(UINT nFlags, short zDelta, CPoint pt)
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
void CHistory::OnLButtonDown(UINT nFlags, CPoint point)
{
	CPoint ptcursor;
	GetCursorPos(&ptcursor);
	ScreenToClient(&ptcursor);

	SetFocus();

	auto* hit_cmd = HitTest(ptcursor);
	if (hit_cmd)
	{
		maker::CMD cmd;
		CCMDPipe::initHistory(cmd, hit_cmd->id());
		CCMDPipe::getInstance()->send(cmd);
	}

	CWnd::OnLButtonDown(nFlags, point);
}
void CHistory::OnVScroll(UINT nSBCode, UINT nPos, CScrollBar* pScrollBar)
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

