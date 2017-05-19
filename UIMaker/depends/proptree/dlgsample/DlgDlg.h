// DlgDlg.h : header file
//

#if !defined(AFX_DLGDLG_H__0C0656DC_98B8_458F_B8B5_F3A9046F912A__INCLUDED_)
#define AFX_DLGDLG_H__0C0656DC_98B8_458F_B8B5_F3A9046F912A__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000

/////////////////////////////////////////////////////////////////////////////
// CDlgDlg dialog

class CDlgDlg : public CDialog
{
// Construction
public:
	CDlgDlg(CWnd* pParent = NULL);	// standard constructor

// Dialog Data
	//{{AFX_DATA(CDlgDlg)
	enum { IDD = IDD_DLGSAMPLE_DIALOG };
		// NOTE: the ClassWizard will add data members here
	//}}AFX_DATA

	// ClassWizard generated virtual function overrides
	//{{AFX_VIRTUAL(CDlgDlg)
	protected:
	virtual void DoDataExchange(CDataExchange* pDX);	// DDX/DDV support
	//}}AFX_VIRTUAL

// Implementation
protected:
	HICON			m_hIcon;
	CPropTree		m_Tree;

	// Generated message map functions
	//{{AFX_MSG(CDlgDlg)
	virtual BOOL OnInitDialog();
	afx_msg void OnPaint();
	afx_msg HCURSOR OnQueryDragIcon();
	afx_msg void OnSize(UINT nType, int cx, int cy);
	afx_msg BOOL OnEraseBkgnd(CDC* pDC);
	//}}AFX_MSG
	afx_msg void OnItemChanged(NMHDR* pNotifyStruct, LRESULT* plResult);

	DECLARE_MESSAGE_MAP()
};

//{{AFX_INSERT_LOCATION}}
// Microsoft Visual C++ will insert additional declarations immediately before the previous line.

#endif // !defined(AFX_DLGDLG_H__0C0656DC_98B8_458F_B8B5_F3A9046F912A__INCLUDED_)
