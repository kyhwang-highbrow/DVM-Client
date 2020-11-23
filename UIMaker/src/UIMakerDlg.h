
// UI.MakerDlg.h : 헤더 파일
//

#pragma once

#include "EntityListView.h"
#include "PropTree.h"
#include "History.h"
#include "LuaNameListView.h"
#include "maker.pb.h"
#include "EntityMgr.h"

#include "Cocos2dXViewer.h"
#include "afxwin.h"


// CUIMakerDlg 대화 상자
class CUIMakerDlg : public CDialogEx
{
// 생성입니다.
public:
	CUIMakerDlg(CWnd* pParent = NULL);	// 표준 생성자입니다.

// 대화 상자 데이터입니다.
	enum { IDD = IDD_UIMAKER_DIALOG };

	protected:
	virtual void DoDataExchange(CDataExchange* pDX);	// DDX/DDV 지원입니다.

public:
	void SendNewCmdNotifycation();
	void SendOpenPopupNotifycation(maker::CMD& cmd);
	void SendOpenViewer();
	void UpdateCmd();

	BOOL SetFileName(CString file_name);

protected:
	void Bind(const maker::Entity* entity);
	void Bind(const maker::Node* node);
	void Bind(const ::google::protobuf::Message* msg);
	void Bind(CPropTreeItem* parent, const ::google::protobuf::Message& msg, const ::google::protobuf::FieldDescriptor* field);

	template <typename T>
	CPropTreeItem* appendPropetyItem(const ::google::protobuf::Message& msg, const TCHAR* field_name, const TCHAR* desc, CPropTreeItemEdit::ValueFormat format, CPropTreeItem* parent);
	template <typename T>
	CPropTreeItem* appendPropetyItem(const ::google::protobuf::Message& msg, const TCHAR* field_name, const TCHAR* desc, CPropTreeItem* parent);

	void applyBind(const maker::Entity& entity, const maker::CMD& cmd);

	void onCmd_Create(const maker::CMD& cmd);
	void onCmd_Remove(const maker::CMD& cmd);
	void onCmd_Move(const maker::CMD& cmd);
	void onCmd_Modify(const maker::CMD& cmd);
	void onCmd_Modify(maker::Entity* entity, const maker::Properties& properties, const maker::CMD& cmd);
    void onCmd_SizeToContent(const maker::CMD& cmd);
	void onCmd_SelectOne(const maker::CMD& cmd);
	void onCmd_SelectAppend(const maker::CMD& cmd);
	void onCmd_SelectBoxAppend(const maker::CMD& cmd);
	void onCmd_ApplyToTool(const maker::CMD& cmd);
	void onCmd_EventToTool(const maker::CMD& cmd);
	void onCmd_AddCmdHistory(const maker::CMD& cmd);

	bool UpdateKeyState(MSG* pMsg);

// 구현입니다.
protected:
	HICON m_hIcon;

	static CCocos2dXViewer sm_viewer;

	int m_prevPick;

	tsqueue<maker::CMD> m_queue_for_popup_menu;

	CEntityListView m_entity_list_view;
	CLuaNameListView m_luaname_list_view;
	CPropTree m_properties;
	CHistory m_history;
	
	int m_propertiesWidth;
	int m_historyHeight;

	bool m_pickPropertiesSpliter;
	bool IsPickPropertiesSpliter(CPoint point);
	void DrawPickPropertiesSpliter(int prevX, int x);
	int AdjustByPropertiesWidth(int cursorX);

	bool m_pickHistorySpliter;
	bool IsPickHistorySpliter(CPoint point);
	void DrawPickHistorySpliter(int prevY, int y);
	int AdjustByHistoryHeight(int cursorY);

	// @4열
	int m_luanameWidth;
	int m_historyWidth;

	bool m_isPickLuanameSpliter;
	bool IsPickLuanameSpliter(CPoint point);
	void DrawPickLuanameSpliter(int prevX, int x);
	int AdjustByLuanameWidth(int cursorX);

	bool m_isPickHistoryWidthSpliter;
	bool IsPickHistoryWidthSpliter(CPoint point);
	void DrawPickHistoryWidthSpliter(int prevX, int x);
	int AdjustByHistoryWidth(int cursorX);

	typedef std::map< const ::google::protobuf::FieldDescriptor*, CPropTreeItem* > TYPE_FIELD_BIND_MAP;
	TYPE_FIELD_BIND_MAP m_field_bind;

	CString m_ui_file_path_name;
	CString m_ui_folder_path_name;
	CString m_ui_file_name;

	CString m_title;

	void onSize(int cx, int cy);
	void onMove();

    int checkSaveChangedFile();

public:
	enum class RES {
		MIN_PORTRATE = 0,
		_480_800,
		_640_852,
		_640_960,
		_640_1138,
		_720_960,
		_720_1080,
		_720_1280,
		_960_1280,
		_853_1280,
        _720_1440,
		_CONFIG,
		MAX_PORTRATE,

		MIN_LANDSCAPE = 0,
		_800_480,
		_852_640,
		_960_640,
		_1138_640,
		_960_720,
		_1080_720,
		_1280_720,
		_1280_960,
		_1280_853,
		MAX_LANDSCAPE,
	};

protected:
	static bool m_portat;
	static RES m_display_mode;

	static void updateResolution(bool portat, RES display_mode, float scale = -1.0f);
	static int getResolutionWidth(bool portat, RES display_mode);
	static int getResolutionHeight(bool portat, RES display_mode);

public:
    static void onToggleDisplayStats();
	static void onReopenView();
	static void onNextResolution();
	static void onPrevResolution();

	static void onSpecificResolution();
    static void onConfigResolution(bool isNext, float scale = -1.0f);

	static void onUndo();
	static void onRedo();

	static void onCopy();
	static void onCut();
	static void onPaste();
	static void onRemove();

	static void onToggleVisible();

protected:
	// 생성된 메시지 맵 함수
	virtual BOOL OnInitDialog();
    afx_msg void OnActivate(UINT nState, CWnd* pWndOther, BOOL bMinimized);
	afx_msg void OnPaint();
	afx_msg int OnCreate(LPCREATESTRUCT lpCreateStruct);
	afx_msg void OnMove(int x, int y);
	afx_msg void OnDropFiles(HDROP hDropInfo);
	virtual BOOL PreTranslateMessage(MSG* pMsg);
	afx_msg HCURSOR OnQueryDragIcon();
	DECLARE_MESSAGE_MAP()
	afx_msg void OnSize(UINT nType, int cx, int cy);
	afx_msg void OnMouseMove(UINT nFlags, CPoint point);
	afx_msg void OnLButtonDown(UINT nFlags, CPoint point);
	afx_msg void OnLButtonUp(UINT nFlags, CPoint point);
	virtual BOOL OnNotify(WPARAM wParam, LPARAM lParam, LRESULT* pResult);
	afx_msg void onFileCloseUi();
	afx_msg void onFileOpenUi();
	afx_msg void onFileSaveUi();
	afx_msg void onFileSaveUiAs();
    afx_msg void onFileConvert();
	virtual void OnCancel();
	virtual void OnOK();
	afx_msg void onExit();
	afx_msg void OnClose();
	afx_msg void OnOpenCocos2dViewer_480_800();
	afx_msg void OnOpenCocos2dViewer_640_1138();
	afx_msg void OnOpenCocos2dViewer_640_960();
	afx_msg void OnOpenCocos2dViewer_640_852();
	afx_msg void OnOpenCocos2dViewer_720_1280();
	afx_msg void OnOpenCocos2dViewer_720_1080();
	afx_msg void OnOpenCocos2dViewer_720_960();
	afx_msg void OnOpenCocos2dViewer_800_480();
	afx_msg void OnOpenCocos2dViewer_1138_640();
	afx_msg void OnOpenCocos2dViewer_960_640();
	afx_msg void OnOpenCocos2dViewer_852_640();
	afx_msg void OnOpenCocos2dViewer_1280_720();
	afx_msg void OnOpenCocos2dViewer_1080_720();
	afx_msg void OnOpenCocos2dViewer_960_720();

	afx_msg void OnOpenCocos2dViewer_960_1280();
	afx_msg void OnOpenCocos2dViewer_1280_960();
	afx_msg void OnOpenCocos2dViewer_853_1280();
	afx_msg void OnOpenCocos2dViewer_1280_853();

public:
    afx_msg void OnOpenCocos2dViewer_Scale_50();
    afx_msg void OnOpenCocos2dViewer_Scale_60();
    afx_msg void OnOpenCocos2dViewer_Scale_70();
    afx_msg void OnOpenCocos2dViewer_Scale_80();
    afx_msg void OnOpenCocos2dViewer_Scale_90();
    afx_msg void OnOpenCocos2dViewer_Scale_100();
    afx_msg void OnOpenCocos2dViewer_720_1440();
};
