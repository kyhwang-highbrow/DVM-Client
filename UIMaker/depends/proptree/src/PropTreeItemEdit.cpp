// PropTreeItemEdit.cpp : implementation file
//
//  Copyright (C) 1998-2001 Scott Ramsay
//	sramsay@gonavi.com
//	http://www.gonavi.com
//
//  This material is provided "as is", with absolutely no warranty expressed
//  or implied. Any use is at your own risk.
// 
//  Permission to use or copy this software for any purpose is hereby granted 
//  without fee, provided the above notices are retained on all copies.
//  Permission to modify the code and to distribute modified code is granted,
//  provided the above notices are retained, and a notice that the code was
//  modified is included with the above copyright notice.
// 
//	If you use this code, drop me an email.  I'd like to know if you find the code
//	useful.

#include "stdafx.h"
#include "proptree.h"
#include "PropTreeItemEdit.h"

#define FILE_BUTTON_WIDTH  21


#ifdef _DEBUG
#define new DEBUG_NEW
#undef THIS_FILE
static char THIS_FILE[] = __FILE__;
#endif

/////////////////////////////////////////////////////////////////////////////
// CPropTreeItemEdit

CPropTreeItemEdit::CPropTreeItemEdit() :
	m_sEdit(_T("")),
	m_nFormat(ValueFormatText),
	m_bPassword(FALSE),
	m_fValue(0.0f)
{
}

CPropTreeItemEdit::~CPropTreeItemEdit()
{
}


BEGIN_MESSAGE_MAP(CPropTreeItemEdit, CEdit)
	//{{AFX_MSG_MAP(CPropTreeItemEdit)
	ON_WM_GETDLGCODE()
	ON_WM_KEYDOWN()
	ON_CONTROL_REFLECT(EN_KILLFOCUS, OnKillfocus)
	//}}AFX_MSG_MAP
END_MESSAGE_MAP()

/////////////////////////////////////////////////////////////////////////////
// CPropTreeItemEdit message handlers

void CPropTreeItemEdit::DrawAttribute(CDC* pDC, const RECT& rc)
{
	ASSERT(m_pProp!=NULL);

	pDC->SelectObject(IsReadOnly() ? m_pProp->GetNormalFont() : m_pProp->GetBoldFont());
	pDC->SetTextColor(RGB(0,0,0));
	pDC->SetBkMode(TRANSPARENT);

	CRect r = rc;

	TCHAR ch;

	// can't use GetPasswordChar(), because window may not be created yet
	ch = (m_bPassword) ? '*' : '\0';

	if (ch)
	{
		CString s;

		s = m_sEdit;
		for (LONG i=0; i<s.GetLength();i++)
			s.SetAt(i, ch);

		pDC->DrawText(s, r, DT_SINGLELINE|DT_VCENTER);
	}
	else
	{
		if (m_nFormat > ValueFormat_NeedFileDialog)
		{
			r.right -= FILE_BUTTON_WIDTH +1;
			pDC->DrawText(m_sEdit, r, DT_SINGLELINE | DT_VCENTER);

			CRect rcbutton(r);
			rcbutton.left = rcbutton.right + 1;
			rcbutton.right = rcbutton.left + FILE_BUTTON_WIDTH;
			pDC->FillSolidRect(&rcbutton, RGB(0, 0, 0));
			rcbutton.DeflateRect(1, 1);
			pDC->FillSolidRect(&rcbutton, ::GetSysColor(COLOR_BTNFACE));
			CRect rcdot(rcbutton);
			rcdot.top = rcdot.bottom = (rcbutton.top + rcbutton.bottom) / 2;
			rcdot.bottom += 2;
			rcdot.left = rcdot.right = (rcbutton.left + rcbutton.right) / 2;
			rcdot.right += 2;
			pDC->FillSolidRect(&rcdot, RGB(0, 0, 0));
			rcdot.OffsetRect(-5, 0);
			pDC->FillSolidRect(&rcdot, RGB(0, 0, 0));
			rcdot.OffsetRect(10, 0);
			pDC->FillSolidRect(&rcdot, RGB(0, 0, 0));
		}
		else
		{
			pDC->DrawText(m_sEdit, r, DT_SINGLELINE | DT_VCENTER);
		}
	}
}



void CPropTreeItemEdit::SetAsPassword(BOOL bPassword)
{
	m_bPassword = bPassword;
}


void CPropTreeItemEdit::SetValueFormat(ValueFormat nFormat)
{
	m_nFormat = nFormat;
}


CPropTreeItemEdit::ValueFormat CPropTreeItemEdit::GetValueFormat()
{
	return m_nFormat;
}


LPARAM CPropTreeItemEdit::GetItemValue()
{
	switch (m_nFormat)
	{
		case ValueFormatNumber:
			return _ttoi(m_sEdit);

		case ValueFormatFloatPointer:
			_stscanf_s(m_sEdit, _T("%f"), &m_fValue);
			return (LPARAM)&m_fValue;
	}

	return (LPARAM)(LPCTSTR)m_sEdit;
}


void CPropTreeItemEdit::SetItemValue(LPARAM lParam)
{
	switch (m_nFormat)
	{
		case ValueFormatNumber:
			m_sEdit.Format(_T("%d"), lParam);
			return;

		case ValueFormatFloatPointer:
			{
				TCHAR tmp[MAX_PATH];
				m_fValue = *(float*)lParam;
				_stprintf_s(tmp, _T("%f"), m_fValue);
				m_sEdit = tmp;
			}
			return;
	}

	if (lParam==0L)
	{
		TRACE0("CPropTreeItemEdit::SetItemValue - Invalid lParam value\n");
		return;
	}

	m_sEdit = (LPCTSTR)lParam;
}

void CPropTreeItemEdit::SetItem(int v)
{
	m_sEdit.Format(_T("%d"), v);
}
void CPropTreeItemEdit::SetItem(unsigned int v)
{
	m_sEdit.Format(_T("%u"), v);
}
void CPropTreeItemEdit::SetItem(long long v)
{
	m_sEdit.Format(_T("%lld"), v);
}
void CPropTreeItemEdit::SetItem(unsigned long long v)
{
	m_sEdit.Format(_T("%llu"), v);
}
void CPropTreeItemEdit::SetItem(float v)
{
	m_sEdit.Format(_T("%g"), v);
}
void CPropTreeItemEdit::SetItem(double v)
{
	m_sEdit.Format(_T("%f"), v);
}
void CPropTreeItemEdit::SetItem(const CString& v)
{
	m_sEdit = v;
}

int CPropTreeItemEdit::GetItem_Int32()
{
	int v;
	_stscanf_s(m_sEdit, _T("%d"), &v);
	return v;
}
unsigned int CPropTreeItemEdit::GetItem_UInt32()
{
	unsigned int v;
	_stscanf_s(m_sEdit, _T("%u"), &v);
	return v;
}
long long CPropTreeItemEdit::GetItem_Int64()
{
	long long v;
	_stscanf_s(m_sEdit, _T("%lld"), &v);
	return v;
}
unsigned long long CPropTreeItemEdit::GetItem_UInt64()
{
	unsigned long long v;
	_stscanf_s(m_sEdit, _T("%llu"), &v);
	return v;
}
float CPropTreeItemEdit::GetItem_Float()
{
	float v;
	_stscanf_s(m_sEdit, _T("%f"), &v);
	return v;
}
double CPropTreeItemEdit::GetItem_Double()
{
	double v;
	_stscanf_s(m_sEdit, _T("%lf"), &v);
	return v;
}
CString CPropTreeItemEdit::GetItem_String()
{
	return m_sEdit;
}

void CPropTreeItemEdit::OnMove()
{
	if (IsWindow(m_hWnd))
		SetWindowPos(NULL, m_rc.left, m_rc.top, m_rc.Width(), m_rc.Height(), SWP_NOZORDER|SWP_NOACTIVATE);
}


void CPropTreeItemEdit::OnRefresh()
{
	if (IsWindow(m_hWnd))
		SetWindowText(m_sEdit);
}


void CPropTreeItemEdit::OnCommit()
{
	if (IsWindow(m_hWnd) && IsWindowVisible())
	{
		// hide edit control
		ShowWindow(SW_HIDE);

		// store edit text for GetItemValue
		GetWindowText(m_sEdit);
	}
}


void CPropTreeItemEdit::OnActivate(CPoint pt)
{
	CRect rcedit(m_rc);
	CRect rcbutton(m_rc);

	if (m_nFormat > ValueFormat_NeedFileDialog)
	{
		rcedit.right -= FILE_BUTTON_WIDTH + 1;

		rcbutton.left = rcedit.right + 1;
		rcbutton.right = rcbutton.left + FILE_BUTTON_WIDTH;

		if (rcbutton.PtInRect(pt))
		{
			if (IsWindow(m_hWnd))
			{
				ShowWindow(SW_HIDE);
			}

			TCHAR* ext = _T("*.*");
			TCHAR* filter = _T("All Files (*.*)|*.*||");
			switch (m_nFormat)
			{
			case ValueFormat_FILE: break;
			case ValueFormat_FILE_IMAGE: ext = _T("*.png"); filter = _T("PNG (*.png)|*.png|All Files (*.*)|*.*||"); break;
			case ValueFormat_FILE_SOUND: ext = _T("*.ogg"); filter = _T("OGG (*.ogg)|*.ogg|MP3 (*.mp3)|*.mp3|Wave (*.wav)|*.wav|All Files (*.*)|*.*||"); break;
			case ValueFormat_FILE_BMFONT: ext = _T("*.fnt"); filter = _T("BMFont (*.fnt)|*.fnt|All Files (*.*)|*.*||"); break;
			case ValueFormat_FILE_TTF: ext = _T("*.ttf"); filter = _T("True Type Font (*.ttf)|*.ttf|All Files (*.*)|*.*||"); break;
			case ValueFormat_FILE_VISUAL: ext = _T("*.a2d"); filter = _T("Visual (*.a2d)|*.a2d|All Files (*.*)|*.*||"); break;
			case ValueFormat_FILE_PLIST: ext = _T("*.plist"); filter = _T("plist (*.plist)|*.plist|All Files (*.*)|*.*||"); break;
			}

			CString tmp(m_sEdit);
			tmp.Replace(_T('/'), _T('\\'));

			CFileDialog dlg(TRUE, ext, tmp, OFN_HIDEREADONLY | OFN_OVERWRITEPROMPT | OFN_ENABLESIZING, filter, this);
			if (dlg.DoModal() == IDOK)
			{
				m_sEdit = dlg.GetPathName();
			}

			CommitChanges();

			return;
		}
	}

	OpenEdit();
}


void CPropTreeItemEdit::OpenEdit()
{
	CPropTreeItem::OpenEdit();

	CRect rcedit(m_rc);
	CRect rcbutton(m_rc);

	if (m_nFormat > ValueFormat_NeedFileDialog)
	{
		rcedit.right -= FILE_BUTTON_WIDTH + 1;
	}

	// Check if the edit control needs creation
	if (!IsWindow(m_hWnd))
	{
		DWORD dwStyle;

		dwStyle = WS_CHILD | ES_AUTOHSCROLL;
		Create(dwStyle, rcedit, m_pProp->GetCtrlParent(), GetCtrlID());
		SendMessage(WM_SETFONT, (WPARAM)m_pProp->GetNormalFont()->m_hObject);
	}

	SetPasswordChar((TCHAR)(m_bPassword ? '*' : 0));
	SetWindowText(m_sEdit);
	SetSel(0, -1);

	SetWindowPos(NULL, rcedit.left, rcedit.top, rcedit.Width(), rcedit.Height(), SWP_NOZORDER | SWP_SHOWWINDOW);
	SetFocus();
}


UINT CPropTreeItemEdit::OnGetDlgCode() 
{
	return CEdit::OnGetDlgCode()|DLGC_WANTALLKEYS;
}


void CPropTreeItemEdit::OnKillfocus() 
{
	CommitChanges();
}

BOOL CPropTreeItemEdit::PreTranslateMessage(MSG* pMsg)
{
	if (pMsg->message == WM_KEYDOWN)
	{
		if (pMsg->wParam == VK_RETURN || pMsg->wParam == VK_TAB)
		{
			::TranslateMessage(pMsg);
			::DispatchMessage(pMsg);
			return 1;
		}
	}

	return CEdit::PreTranslateMessage(pMsg);
}

void CPropTreeItemEdit::OnKeyDown(UINT nChar, UINT nRepCnt, UINT nFlags)
{
	switch (nChar)
	{
	case VK_TAB:
		CommitChanges();
		if (GetAsyncKeyState(VK_SHIFT) & 0x8000) OpenPrevEdit();
		else                                     OpenNextEdit();
		return;
	case VK_RETURN:
		CommitChanges();
		return;
	}

	CEdit::OnKeyDown(nChar, nRepCnt, nFlags);
}
