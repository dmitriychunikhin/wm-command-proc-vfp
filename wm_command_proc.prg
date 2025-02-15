#define WM_COMMAND 0x0111
#define IDM_PASTE 327680 + 6

DEFINE CLASS wm_command_proc as Custom

    PROCEDURE Init
        IF PEMSTATUS(_VFP, This.Class, 5) = .T.
            ERROR 'Object ' + This.Class + ' already exists'
            RETURN .F.
        ENDIF
        ADDPROPERTY(_VFP, This.Class, This)
        
        BINDEVENT(_VFP.HWnd, WM_COMMAND, This, "On_WM_COMMAND")
        
        LOCAL lcCmdPaste
        lcCmdPaste = "_VFP." + This.Class + ".Paste()"
        ON KEY LABEL CTRL+V &lcCmdPaste
    ENDPROC
    
    PROCEDURE Release
        UNBINDEVENTS(_VFP.HWnd, WM_COMMAND)
        ON KEY LABEL CTRL+V

        IF PEMSTATUS(_VFP, This.Class, 5) = .T.
            REMOVEPROPERTY(_VFP, This.Class)
        ENDIF
    ENDPROC
        
    PROCEDURE Destroy
        This.Release()
    ENDPROC
    
    PROCEDURE On_WM_COMMAND
        LPARAMETERS hWnd, nMsg, wParam, lParam

        #define GWL_WNDPROC -4
        DECLARE LONG GetWindowLong IN user32 as GetWindowLong LONG hWnd, LONG nIndex
        DECLARE LONG CallWindowProc IN user32 as CallWindowProc LONG lpPrevWndFunc, LONG hWnd, LONG Msg, LONG wParam, LONG lParam
        
        IF VARTYPE(_VFP.ActiveForm) = "O"
            IF VARTYPE(_VFP.ActiveForm.ActiveControl) = "O"
                IF m.wParam = IDM_PASTE
                    IF PEMSTATUS(_VFP.ActiveForm.ActiveControl, "OnPaste", 5)
                        IF _VFP.ActiveForm.ActiveControl.OnPaste() = .F.
                            RETURN
                        ENDIF
                    ENDIF
                ENDIF
            ENDIF
        ENDIF
        
        LOCAL lhOrigProc
        lhOrigProc = GetWindowLong(m.hWnd, GWL_WNDPROC)
        CallWindowProc(lhOrigProc, m.hWnd, m.nMsg, m.wParam, m.lParam)
    ENDPROC
    
    PROCEDURE Paste
        DECLARE LONG SendMessage IN user32 as SendMessage LONG hWnd, LONG Msg, LONG wParam, LONG lParam
        *DECLARE LONG PostMessage IN user32 LONG hWnd, LONG Msg, LONG wParam, LONG lParam

        SendMessage(_VFP.HWnd, WM_COMMAND, IDM_PASTE, 0)
    ENDPROC
    
ENDDEFINE
