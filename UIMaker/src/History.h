#pragma once

#include "maker.pb.h"

#include "EntityMgr.h"
#include "CMDPipe.h"

// CHistory

class CHistory : public CWnd
{
	DECLARE_DYNAMIC(CHistory)

public:
	CHistory();
	virtual ~CHistory();

	BOOL Create(DWORD dwStyle, const RECT& rect, CWnd* pParentWnd, UINT nID);

	void Redraw();

protected:
	CPoint	m_origin;
	void UpdateResize();
	int GetTotalHeight();
	maker::CMD* HitTest(const POINT& pt);

	CBitmap	m_BackBuffer;
	CSize	m_BackBufferSize;

	CFont*	m_pNormalFont;
	CFont*	m_pBoldFont;
    int _oldHistoryCount;

	void InitFont();

	void RecreateBackBuffer(int cx, int cy);
	void DrawCmdHistory(CDC* pDC, CRect rect);
	CRect CalCurrentRect(CRect rcclient, int count);
	void DrawBegin(CDC* pDC, CRect rect, int& count, bool current_cmd);
	void DrawCmd(CDC* pDC, CRect rect, int& count, const maker::CMD& cmd, bool current_cmd);
	void DrawEnd(CDC* pDC, CRect rect, int& count, bool current_cmd);

protected:
	afx_msg void OnSize(UINT nType, int cx, int cy);
	afx_msg void OnPaint();
	DECLARE_MESSAGE_MAP()
public:
	afx_msg BOOL OnMouseWheel(UINT nFlags, short zDelta, CPoint pt);
	afx_msg void OnLButtonDown(UINT nFlags, CPoint point);
	afx_msg void OnVScroll(UINT nSBCode, UINT nPos, CScrollBar* pScrollBar);
};


