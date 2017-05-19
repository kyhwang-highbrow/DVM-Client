#pragma once

#include "maker.pb.h"

#include "EntityMgr.h"
#include "CMDPipe.h"
using namespace std;

// CLuaNameListView

class CLuaNameListView : public CWnd
{
	DECLARE_DYNAMIC(CLuaNameListView);

public:
	CLuaNameListView();
	virtual ~CLuaNameListView();

	BOOL Create(DWORD dwStyle, const RECT& rect, CWnd* pParentWnd, UINT nID);
	void Redraw();
	void SetCurrentEntity(CEntityMgr::ID entity_id);

protected:
	CPoint m_origin;
	
	void UpdateResize();
	void UpdateScroll();
	
	int GetTotalHeight();
	int GetScrollPos(const maker::Entity* current);
	
	maker::Entity* hitEntity(const POINT& pt, int& hit_part);
	maker::Entity* hitReleaseEntity(const POINT& pt, int& hit_part);
	maker::Entity* findHitEntity(const POINT& pt);

	CBitmap	m_BackBuffer;
	CSize	m_BackBufferSize;

	CFont*	m_pNormalFont;
	CFont*	m_pBoldFont;
    int _oldLuaNamesCount;
	
	void OnCMD_CreateEntity(int type);

	bool m_drag;
	bool m_prepare_drag;
	CPoint m_prepare_drag_pos;

	void InitFont();

	void RecreateBackBuffer(int cx, int cy);
	CRect CalCurrentRect(CRect rcclient, int count);

	void DrawEntity(CDC* pDC, CRect rect, int& count, const maker::Entity* entity, bool invisible);



	// lua name check ฐüทร
public:
	string getDuplicatedLuaName();
protected:
	list<string> getLuanameList();
	// lua name find
public:
	maker::Entity* findLuaname(char ch);

protected:
	afx_msg void OnSize(UINT nType, int cx, int cy);
	afx_msg void OnPaint();
	DECLARE_MESSAGE_MAP()
public:
	afx_msg void OnLButtonDown(UINT nFlags, CPoint point);
	afx_msg void OnLButtonUp(UINT nFlags, CPoint point);
	afx_msg void OnVScroll(UINT nSBCode, UINT nPos, CScrollBar* pScrollBar);
	afx_msg BOOL OnMouseWheel(UINT nFlags, short zDelta, CPoint pt);

	afx_msg void OnCMD_Remove();
	afx_msg void OnCMD_SizeToContent();

#pragma region OnCMD_CreateEntity_TypeXX
	afx_msg void OnCMD_CreateEntity_Type00();
	afx_msg void OnCMD_CreateEntity_Type01();
	afx_msg void OnCMD_CreateEntity_Type02();
	afx_msg void OnCMD_CreateEntity_Type03();
	afx_msg void OnCMD_CreateEntity_Type04();
	afx_msg void OnCMD_CreateEntity_Type05();
	afx_msg void OnCMD_CreateEntity_Type06();
	afx_msg void OnCMD_CreateEntity_Type07();
	afx_msg void OnCMD_CreateEntity_Type08();
	afx_msg void OnCMD_CreateEntity_Type09();
	afx_msg void OnCMD_CreateEntity_Type10();
	afx_msg void OnCMD_CreateEntity_Type11();
	afx_msg void OnCMD_CreateEntity_Type12();
	afx_msg void OnCMD_CreateEntity_Type13();
	afx_msg void OnCMD_CreateEntity_Type14();
	afx_msg void OnCMD_CreateEntity_Type15();
	afx_msg void OnCMD_CreateEntity_Type16();
	afx_msg void OnCMD_CreateEntity_Type17();
	afx_msg void OnCMD_CreateEntity_Type18();
	afx_msg void OnCMD_CreateEntity_Type19();
	afx_msg void OnCMD_CreateEntity_Type20();
	afx_msg void OnCMD_CreateEntity_Type21();
	afx_msg void OnCMD_CreateEntity_Type22();
	afx_msg void OnCMD_CreateEntity_Type23();
	afx_msg void OnCMD_CreateEntity_Type24();
	afx_msg void OnCMD_CreateEntity_Type25();
	afx_msg void OnCMD_CreateEntity_Type26();
	afx_msg void OnCMD_CreateEntity_Type27();
	afx_msg void OnCMD_CreateEntity_Type28();
	afx_msg void OnCMD_CreateEntity_Type29();
	afx_msg void OnCMD_CreateEntity_Type30();
	afx_msg void OnCMD_CreateEntity_Type31();
	afx_msg void OnCMD_CreateEntity_Type32();
	afx_msg void OnCMD_CreateEntity_Type33();
	afx_msg void OnCMD_CreateEntity_Type34();
	afx_msg void OnCMD_CreateEntity_Type35();
	afx_msg void OnCMD_CreateEntity_Type36();
	afx_msg void OnCMD_CreateEntity_Type37();
	afx_msg void OnCMD_CreateEntity_Type38();
	afx_msg void OnCMD_CreateEntity_Type39();
	afx_msg void OnCMD_CreateEntity_Type40();
	afx_msg void OnCMD_CreateEntity_Type41();
	afx_msg void OnCMD_CreateEntity_Type42();
	afx_msg void OnCMD_CreateEntity_Type43();
	afx_msg void OnCMD_CreateEntity_Type44();
	afx_msg void OnCMD_CreateEntity_Type45();
	afx_msg void OnCMD_CreateEntity_Type46();
	afx_msg void OnCMD_CreateEntity_Type47();
	afx_msg void OnCMD_CreateEntity_Type48();
	afx_msg void OnCMD_CreateEntity_Type49();
	afx_msg void OnCMD_CreateEntity_Type50();
	afx_msg void OnCMD_CreateEntity_Type51();
	afx_msg void OnCMD_CreateEntity_Type52();
	afx_msg void OnCMD_CreateEntity_Type53();
	afx_msg void OnCMD_CreateEntity_Type54();
	afx_msg void OnCMD_CreateEntity_Type55();
	afx_msg void OnCMD_CreateEntity_Type56();
	afx_msg void OnCMD_CreateEntity_Type57();
	afx_msg void OnCMD_CreateEntity_Type58();
	afx_msg void OnCMD_CreateEntity_Type59();
	afx_msg void OnCMD_CreateEntity_Type60();
	afx_msg void OnCMD_CreateEntity_Type61();
	afx_msg void OnCMD_CreateEntity_Type62();
	afx_msg void OnCMD_CreateEntity_Type63();
	afx_msg void OnCMD_CreateEntity_Type64();
	afx_msg void OnCMD_CreateEntity_Type65();
	afx_msg void OnCMD_CreateEntity_Type66();
	afx_msg void OnCMD_CreateEntity_Type67();
	afx_msg void OnCMD_CreateEntity_Type68();
	afx_msg void OnCMD_CreateEntity_Type69();
	afx_msg void OnCMD_CreateEntity_Type70();
	afx_msg void OnCMD_CreateEntity_Type71();
	afx_msg void OnCMD_CreateEntity_Type72();
	afx_msg void OnCMD_CreateEntity_Type73();
	afx_msg void OnCMD_CreateEntity_Type74();
	afx_msg void OnCMD_CreateEntity_Type75();
	afx_msg void OnCMD_CreateEntity_Type76();
	afx_msg void OnCMD_CreateEntity_Type77();
	afx_msg void OnCMD_CreateEntity_Type78();
	afx_msg void OnCMD_CreateEntity_Type79();
	afx_msg void OnCMD_CreateEntity_Type80();
	afx_msg void OnCMD_CreateEntity_Type81();
	afx_msg void OnCMD_CreateEntity_Type82();
	afx_msg void OnCMD_CreateEntity_Type83();
	afx_msg void OnCMD_CreateEntity_Type84();
	afx_msg void OnCMD_CreateEntity_Type85();
	afx_msg void OnCMD_CreateEntity_Type86();
	afx_msg void OnCMD_CreateEntity_Type87();
	afx_msg void OnCMD_CreateEntity_Type88();
	afx_msg void OnCMD_CreateEntity_Type89();
	afx_msg void OnCMD_CreateEntity_Type90();
	afx_msg void OnCMD_CreateEntity_Type91();
	afx_msg void OnCMD_CreateEntity_Type92();
	afx_msg void OnCMD_CreateEntity_Type93();
	afx_msg void OnCMD_CreateEntity_Type94();
	afx_msg void OnCMD_CreateEntity_Type95();
	afx_msg void OnCMD_CreateEntity_Type96();
	afx_msg void OnCMD_CreateEntity_Type97();
	afx_msg void OnCMD_CreateEntity_Type98();
	afx_msg void OnCMD_CreateEntity_Type99();

	afx_msg void OnCMD_PickEntity_00();
	afx_msg void OnCMD_PickEntity_01();
	afx_msg void OnCMD_PickEntity_02();
	afx_msg void OnCMD_PickEntity_03();
	afx_msg void OnCMD_PickEntity_04();
	afx_msg void OnCMD_PickEntity_05();
	afx_msg void OnCMD_PickEntity_06();
	afx_msg void OnCMD_PickEntity_07();
	afx_msg void OnCMD_PickEntity_08();
	afx_msg void OnCMD_PickEntity_09();
	afx_msg void OnCMD_PickEntity_10();
	afx_msg void OnCMD_PickEntity_11();
	afx_msg void OnCMD_PickEntity_12();
	afx_msg void OnCMD_PickEntity_13();
	afx_msg void OnCMD_PickEntity_14();
	afx_msg void OnCMD_PickEntity_15();
	afx_msg void OnCMD_PickEntity_16();
	afx_msg void OnCMD_PickEntity_17();
	afx_msg void OnCMD_PickEntity_18();
	afx_msg void OnCMD_PickEntity_19();
	afx_msg void OnCMD_PickEntity_20();
	afx_msg void OnCMD_PickEntity_21();
	afx_msg void OnCMD_PickEntity_22();
	afx_msg void OnCMD_PickEntity_23();
	afx_msg void OnCMD_PickEntity_24();
	afx_msg void OnCMD_PickEntity_25();
	afx_msg void OnCMD_PickEntity_26();
	afx_msg void OnCMD_PickEntity_27();
	afx_msg void OnCMD_PickEntity_28();
	afx_msg void OnCMD_PickEntity_29();
	afx_msg void OnCMD_PickEntity_30();
	afx_msg void OnCMD_PickEntity_31();
	afx_msg void OnCMD_PickEntity_32();
	afx_msg void OnCMD_PickEntity_33();
	afx_msg void OnCMD_PickEntity_34();
	afx_msg void OnCMD_PickEntity_35();
	afx_msg void OnCMD_PickEntity_36();
	afx_msg void OnCMD_PickEntity_37();
	afx_msg void OnCMD_PickEntity_38();
	afx_msg void OnCMD_PickEntity_39();
	afx_msg void OnCMD_PickEntity_40();
	afx_msg void OnCMD_PickEntity_41();
	afx_msg void OnCMD_PickEntity_42();
	afx_msg void OnCMD_PickEntity_43();
	afx_msg void OnCMD_PickEntity_44();
	afx_msg void OnCMD_PickEntity_45();
	afx_msg void OnCMD_PickEntity_46();
	afx_msg void OnCMD_PickEntity_47();
	afx_msg void OnCMD_PickEntity_48();
	afx_msg void OnCMD_PickEntity_49();
	afx_msg void OnCMD_PickEntity_50();
	afx_msg void OnCMD_PickEntity_51();
	afx_msg void OnCMD_PickEntity_52();
	afx_msg void OnCMD_PickEntity_53();
	afx_msg void OnCMD_PickEntity_54();
	afx_msg void OnCMD_PickEntity_55();
	afx_msg void OnCMD_PickEntity_56();
	afx_msg void OnCMD_PickEntity_57();
	afx_msg void OnCMD_PickEntity_58();
	afx_msg void OnCMD_PickEntity_59();
	afx_msg void OnCMD_PickEntity_60();
	afx_msg void OnCMD_PickEntity_61();
	afx_msg void OnCMD_PickEntity_62();
	afx_msg void OnCMD_PickEntity_63();
	afx_msg void OnCMD_PickEntity_64();
	afx_msg void OnCMD_PickEntity_65();
	afx_msg void OnCMD_PickEntity_66();
	afx_msg void OnCMD_PickEntity_67();
	afx_msg void OnCMD_PickEntity_68();
	afx_msg void OnCMD_PickEntity_69();
	afx_msg void OnCMD_PickEntity_70();
	afx_msg void OnCMD_PickEntity_71();
	afx_msg void OnCMD_PickEntity_72();
	afx_msg void OnCMD_PickEntity_73();
	afx_msg void OnCMD_PickEntity_74();
	afx_msg void OnCMD_PickEntity_75();
	afx_msg void OnCMD_PickEntity_76();
	afx_msg void OnCMD_PickEntity_77();
	afx_msg void OnCMD_PickEntity_78();
	afx_msg void OnCMD_PickEntity_79();
	afx_msg void OnCMD_PickEntity_80();
	afx_msg void OnCMD_PickEntity_81();
	afx_msg void OnCMD_PickEntity_82();
	afx_msg void OnCMD_PickEntity_83();
	afx_msg void OnCMD_PickEntity_84();
	afx_msg void OnCMD_PickEntity_85();
	afx_msg void OnCMD_PickEntity_86();
	afx_msg void OnCMD_PickEntity_87();
	afx_msg void OnCMD_PickEntity_88();
	afx_msg void OnCMD_PickEntity_89();
	afx_msg void OnCMD_PickEntity_90();
	afx_msg void OnCMD_PickEntity_91();
	afx_msg void OnCMD_PickEntity_92();
	afx_msg void OnCMD_PickEntity_93();
	afx_msg void OnCMD_PickEntity_94();
	afx_msg void OnCMD_PickEntity_95();
	afx_msg void OnCMD_PickEntity_96();
	afx_msg void OnCMD_PickEntity_97();
	afx_msg void OnCMD_PickEntity_98();
	afx_msg void OnCMD_PickEntity_99();
#pragma endregion recv message from popup menu
};


