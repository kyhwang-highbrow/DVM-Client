// DlgDlg.cpp : implementation file
//

#include "stdafx.h"
#include "dlgsample.h"
#include "DlgDlg.h"

#ifdef _DEBUG
#define new DEBUG_NEW
#undef THIS_FILE
static char THIS_FILE[] = __FILE__;
#endif

#define IDC_PROPERTYTREE			100

/////////////////////////////////////////////////////////////////////////////
// CDlgDlg dialog

CDlgDlg::CDlgDlg(CWnd* pParent /*=NULL*/)
	: CDialog(CDlgDlg::IDD, pParent)
{
	//{{AFX_DATA_INIT(CDlgDlg)
		// NOTE: the ClassWizard will add member initialization here
	//}}AFX_DATA_INIT
	// Note that LoadIcon does not require a subsequent DestroyIcon in Win32
	m_hIcon = AfxGetApp()->LoadIcon(IDR_MAINFRAME);
}

void CDlgDlg::DoDataExchange(CDataExchange* pDX)
{
	CDialog::DoDataExchange(pDX);
	//{{AFX_DATA_MAP(CDlgDlg)
		// NOTE: the ClassWizard will add DDX and DDV calls here
	//}}AFX_DATA_MAP
}

BEGIN_MESSAGE_MAP(CDlgDlg, CDialog)
	//{{AFX_MSG_MAP(CDlgDlg)
	ON_WM_PAINT()
	ON_WM_QUERYDRAGICON()
	ON_WM_SIZE()
	ON_WM_ERASEBKGND()
	//}}AFX_MSG_MAP
	ON_NOTIFY(PTN_ITEMCHANGED, IDC_PROPERTYTREE, OnItemChanged)
END_MESSAGE_MAP()

/////////////////////////////////////////////////////////////////////////////
// CDlgDlg message handlers

BOOL CDlgDlg::OnInitDialog()
{
	CDialog::OnInitDialog();

	// Set the icon for this dialog.  The framework does this automatically
	//  when the application's main window is not a dialog
	SetIcon(m_hIcon, TRUE);			// Set big icon
	SetIcon(m_hIcon, FALSE);		// Set small icon
	
	DWORD dwStyle;
	CRect rc;

	// PTS_NOTIFY - CPropTree will send notification messages to the parent window
	dwStyle = WS_CHILD|WS_VISIBLE|PTS_NOTIFY;

	// Init the control's size to cover the entire client area
	GetClientRect(rc);

	// Create CPropTree control
	m_Tree.Create(dwStyle, rc, this, IDC_PROPERTYTREE);

	//
	// Create some tree items
	//

	// Create a root item (root items should always be CPropTreeItem object since they
	// can not have properties
	CPropTreeItem* pRoot;

	pRoot = m_Tree.InsertItem(new CPropTreeItem());
	pRoot->SetLabelText(_T("Properties"));
	pRoot->SetInfoText(_T("This is a root level item"));
	pRoot->Expand(); // have this item expanded by default

	// Create a static item
	CPropTreeItem* pItem;

	pItem = m_Tree.InsertItem(new CPropTreeItem(), pRoot);
	pItem->SetLabelText(_T("Sub Item"));
	pItem->SetInfoText(_T("This is a simple subitem"));
	
	// Create a dropdown combolist box
	CPropTreeItemCombo* pCombo;

	pCombo = (CPropTreeItemCombo*)m_Tree.InsertItem(new CPropTreeItemCombo(), pRoot);
	pCombo->SetLabelText(_T("Combo Item"));
	pCombo->SetInfoText(_T("This is a TRUE/FALSE dropdown combo list"));
	pCombo->CreateComboBoxBool();	// create the ComboBox control and auto fill with TRUE/FALSE values
	pCombo->SetItemValue(TRUE);		// set the combo box to default as TRUE

	// Create another item
	pItem = m_Tree.InsertItem(new CPropTreeItemStatic(), pRoot);
	pItem->SetLabelText(_T("Sub Item 2"));
	pItem->SetInfoText(_T("This is item has child items"));
	pItem->SetItemValue((LPARAM)_T("Text Info"));

	// Create a child item
	pItem = m_Tree.InsertItem(new CPropTreeItem(), pItem);
	pItem->SetLabelText(_T("SubSub"));
	pItem->SetInfoText(_T("This is item has a check box"));
	pItem->HasCheckBox();		// we want this item to have a checkbox
	pItem->Check();				// have the checkbox initially checked

	// Create another item
	pItem = m_Tree.InsertItem(new CPropTreeItem(), pRoot);
	pItem->SetLabelText(_T("Sub Item 3"));

	// Create another root item
	pRoot = m_Tree.InsertItem(new CPropTreeItem());
	pRoot->SetLabelText(_T("Styles"));

	// Create a color item
	CPropTreeItemColor* pColor;
	pColor = (CPropTreeItemColor*)m_Tree.InsertItem(new CPropTreeItemColor(), pRoot);
	pColor->SetLabelText(_T("Color"));
	pColor->SetInfoText(_T("Simple color picker"));
	pColor->SetItemValue((LPARAM)RGB(0xff, 0xff, 0x00)); // default as color yellow
	
	CPropTreeItemEdit* pEdit;
	pEdit = (CPropTreeItemEdit*)m_Tree.InsertItem(new CPropTreeItemEdit(), pRoot);
	pEdit->SetLabelText(_T("Name"));
	pEdit->SetInfoText(_T("Edit text attribute"));
	pEdit->SetItemValue((LPARAM)_T("This text is editable"));

	pEdit = (CPropTreeItemEdit*)m_Tree.InsertItem(new CPropTreeItemEdit(), pRoot);
	pEdit->SetLabelText(_T("Number"));
	pEdit->SetInfoText(_T("Number edit box"));
	pEdit->SetValueFormat(CPropTreeItemEdit::ValueFormatNumber);	// this allows you to
																	// pass in a number in SetItemValue
	pEdit->SetItemValue((LPARAM)56);

	return TRUE;  // return TRUE  unless you set the focus to a control
}

// If you add a minimize button to your dialog, you will need the code below
//  to draw the icon.  For MFC applications using the document/view model,
//  this is automatically done for you by the framework.

void CDlgDlg::OnPaint() 
{
	if (IsIconic())
	{
		CPaintDC dc(this); // device context for painting

		SendMessage(WM_ICONERASEBKGND, (WPARAM) dc.GetSafeHdc(), 0);

		// Center icon in client rectangle
		int cxIcon = GetSystemMetrics(SM_CXICON);
		int cyIcon = GetSystemMetrics(SM_CYICON);
		CRect rect;
		GetClientRect(&rect);
		int x = (rect.Width() - cxIcon + 1) / 2;
		int y = (rect.Height() - cyIcon + 1) / 2;

		// Draw the icon
		dc.DrawIcon(x, y, m_hIcon);
	}
	else
	{
		CDialog::OnPaint();
	}
}

// The system calls this to obtain the cursor to display while the user drags
//  the minimized window.
HCURSOR CDlgDlg::OnQueryDragIcon()
{
	return (HCURSOR) m_hIcon;
}


void CDlgDlg::OnSize(UINT nType, int cx, int cy) 
{
	CDialog::OnSize(nType, cx, cy);
	
	// resize the control to always fit the dialog
	if (::IsWindow(m_Tree.GetSafeHwnd()))
		m_Tree.SetWindowPos(NULL, -1, -1, cx, cy, SWP_NOMOVE|SWP_NOZORDER);	
}


BOOL CDlgDlg::OnEraseBkgnd(CDC*) 
{
	// don't bother erasing the background since our control will always
	// cover the entire client area
	return TRUE;
}


void CDlgDlg::OnItemChanged(NMHDR* pNotifyStruct, LRESULT* plResult)
{
	LPNMPROPTREE pNMPropTree = (LPNMPROPTREE)pNotifyStruct;

	if (pNMPropTree->pItem)
	{
		CString s;

		s.Format(_T("Item '%s' has been changed\n"),  pNMPropTree->pItem->GetLabelText());
		OutputDebugString(s);
	}

	*plResult = 0;
}
