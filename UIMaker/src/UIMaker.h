
// UI.Maker.h : PROJECT_NAME ���� ���α׷��� ���� �� ��� �����Դϴ�.
//

#pragma once

#ifndef __AFXWIN_H__
	#error "PCH�� ���� �� ������ �����ϱ� ���� 'stdafx.h'�� �����մϴ�."
#endif

#include "resource.h"		// �� ��ȣ�Դϴ�.

// CUIMakerApp:
// �� Ŭ������ ������ ���ؼ��� UI.Maker.cpp�� �����Ͻʽÿ�.
//

class CUIMakerApp : public CWinApp
{
public:
	CUIMakerApp();

// �������Դϴ�.
public:
	virtual BOOL InitInstance();

// �����Դϴ�.

	DECLARE_MESSAGE_MAP()
};

extern CUIMakerApp theApp;