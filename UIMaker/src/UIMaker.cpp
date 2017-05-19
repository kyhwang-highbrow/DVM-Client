
// UI.Maker.cpp : 응용 프로그램에 대한 클래스 동작을 정의합니다.
//

#include "stdafx.h"
#include "UIMaker.h"
#include "UIMakerDlg.h"

#ifdef _DEBUG
#define new DEBUG_NEW
#endif


// CUIMakerApp

BEGIN_MESSAGE_MAP(CUIMakerApp, CWinApp)
	ON_COMMAND(ID_HELP, &CWinApp::OnHelp)
END_MESSAGE_MAP()


// CUIMakerApp 생성

CUIMakerApp::CUIMakerApp()
{
	// 다시 시작 관리자 지원
	m_dwRestartManagerSupportFlags = AFX_RESTART_MANAGER_SUPPORT_RESTART;

	// TODO: 여기에 생성 코드를 추가합니다.
	// InitInstance에 모든 중요한 초기화 작업을 배치합니다.
}


// 유일한 CUIMakerApp 개체입니다.

CUIMakerApp theApp;


// CUIMakerApp 초기화

BOOL CUIMakerApp::InitInstance()
{
	SetRegistryKey(_T("UIMaker_PA_Yellow"));

	CUIMakerDlg dlg;
	m_pMainWnd = &dlg;

	CCommandLineInfo cmdInfo;
	ParseCommandLine(cmdInfo);

	if (m_lpCmdLine)
	{
		dlg.SetFileName(m_lpCmdLine);
	}

	INT_PTR nResponse = dlg.DoModal();
	if (nResponse == IDOK)
	{
		// TODO: 여기에 [확인]을 클릭하여 대화 상자가 없어질 때 처리할
		//  코드를 배치합니다.
	}
	else if (nResponse == IDCANCEL)
	{
		// TODO: 여기에 [취소]를 클릭하여 대화 상자가 없어질 때 처리할
		//  코드를 배치합니다.
	}
	else if (nResponse == -1)
	{
		TRACE(traceAppMsg, 0, "경고: 대화 상자를 만들지 못했으므로 응용 프로그램이 예기치 않게 종료됩니다.\n");
		TRACE(traceAppMsg, 0, "경고: 대화 상자에서 MFC 컨트롤을 사용하는 경우 #define _AFX_NO_MFC_CONTROLS_IN_DIALOGS를 수행할 수 없습니다.\n");
	}

	// 대화 상자가 닫혔으므로 응용 프로그램의 메시지 펌프를 시작하지 않고  응용 프로그램을 끝낼 수 있도록 FALSE를
	// 반환합니다.
	return FALSE;
}

