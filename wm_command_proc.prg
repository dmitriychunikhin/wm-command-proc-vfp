#define WM_COMMAND 0x0111
#define WM_CHAR 0x0102
#define IDM_PASTE 327680 + 6

DEFINE CLASS wm_command_proc as Custom

    PROCEDURE Init
        IF PEMSTATUS(_VFP, This.Class, 5) = .T.
            ERROR 'Object _VFP.' + This.Class + ' already exists'
            RETURN .F.
        ENDIF
        ADDPROPERTY(_VFP, This.Class, This)

        BINDEVENT(0, WM_COMMAND, This, "On_WM_COMMAND")
        BINDEVENT(0, WM_CHAR , This, "On_WM_CHAR")
    ENDPROC
    
    PROCEDURE Release
        UNBINDEVENTS(0, WM_COMMAND)
        UNBINDEVENTS(0, WM_CHAR)

        IF PEMSTATUS(_VFP, This.Class, 5) = .T.
            REMOVEPROPERTY(_VFP, This.Class)
        ENDIF
    ENDPROC
        
    PROCEDURE Destroy
        This.Release()
    ENDPROC
    
    
    HIDDEN PROCEDURE OnPaste
        IF TYPE("_VFP.ActiveForm.ActiveControl") != "O"
            RETURN
        ENDIF
        IF PEMSTATUS(_VFP.ActiveForm.ActiveControl, "OnPaste", 5) = .F.
            RETURN
        ENDIF
        IF _VFP.ActiveForm.ActiveControl.OnPaste() = .F.
            RETURN .F.
        ENDIF
    ENDPROC

    PROCEDURE On_WM_CHAR
        LPARAMETERS hWnd, nMsg, wParam, lParam

        IF m.wParam = 22 && CTRL + V
            IF This.OnPaste() = .F.
                RETURN
            ENDIF
        ENDIF
        
        #define GWL_WNDPROC -4
        DECLARE LONG GetWindowLong IN user32 as GetWindowLong LONG hWnd, LONG nIndex
        DECLARE LONG CallWindowProc IN user32 as CallWindowProc LONG lpPrevWndFunc, LONG hWnd, LONG Msg, LONG wParam, LONG lParam
        
        LOCAL lhOrigProc
        lhOrigProc = GetWindowLong(m.hWnd, GWL_WNDPROC)
        CallWindowProc(lhOrigProc, m.hWnd, m.nMsg, m.wParam, m.lParam)
    ENDPROC
    
    PROCEDURE On_WM_COMMAND
        LPARAMETERS hWnd, nMsg, wParam, lParam

        *MESSAGEBOX(TRANSFORM(BITAND(BITRSHIFT(m.wParam,16), 0xFFFF)) + "_" + TRANSFORM(BITAND(m.wParam, 0xFFFF)))
        IF m.wParam = IDM_PASTE
            IF This.OnPaste() = .F.
                RETURN
            ENDIF
        ENDIF
        
        #define GWL_WNDPROC -4
        DECLARE LONG GetWindowLong IN user32 as GetWindowLong LONG hWnd, LONG nIndex
        DECLARE LONG CallWindowProc IN user32 as CallWindowProc LONG lpPrevWndFunc, LONG hWnd, LONG Msg, LONG wParam, LONG lParam
        
        LOCAL lhOrigProc
        lhOrigProc = GetWindowLong(m.hWnd, GWL_WNDPROC)
        CallWindowProc(lhOrigProc, m.hWnd, m.nMsg, m.wParam, m.lParam)
    ENDPROC
        
ENDDEFINE
