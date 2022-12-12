.386
.model flat, stdcall
.stack 10448576
option casemap:none

; ========== LIBRERIAS =============
include masm32\include\windows.inc 
include masm32\include\kernel32.inc
include masm32\include\user32.inc
includelib masm32\lib\kernel32.lib
includelib masm32\lib\user32.lib
include masm32\include\gdi32.inc
includelib masm32\lib\Gdi32.lib
include masm32\include\msimg32.inc
includelib masm32\lib\msimg32.lib
include masm32\include\winmm.inc
includelib masm32\lib\winmm.lib
include masm32\include\masm32.inc
includelib masm32\lib\masm32.lib.

; ================================================== PROTOTIPOS ==========================================================
; Delcaramos los prototipos que no están declarados en las librerias
; (Son funciones que nosotros hicimos)
main			proto
WinMain			proto	:DWORD, :DWORD, :DWORD, :DWORD
createwindow2   proto	:DWORD, :DWORD, :DWORD, :DWORD
NumRam          proto
Llamar          proto
Llamardos       proto
Llamartres      proto
Llamarcuatro    proto
Llamarcinco      proto
;============================================ Estructura====================================================================
elementos struct
ID  dword   0
X   dword   0
Y   dword   0 
elementos ends


; =========================================== DECLARACION DE VARIABLES =====================================================
.data
className				db			"ProyectoEnsamblador",0
className2				db			"ProyectoEnsamblador",0
windowHandler			dword		?							
windowClass				WNDCLASSEX	<>
windowClass2			WNDCLASSEX	<>
windowMessage			MSG			<>							
clientRect				RECT		<>							
windowContext			HDC			?							
layer					HBITMAP		?							
layerContext			HDC			?							
auxiliarLayer			HBITMAP		?							
auxiliarLayerContext	HBITMAP		?							
clearColor				HBRUSH		?							
windowPaintstruct		PAINTSTRUCT	<>							
joystickInfo			JOYINFO		<>							
errorTitle				byte		'Error',0
joystickErrorText		byte		'No se pudo inicializar el joystick',0
ButtonClass             db          "button",0
ButtonText              db          "¡Iniciar Juego!",0
ButtonText1             db          "Ver puntuaciones",0
ButtonText2             db          "Salir",0
EditClass               db          "static",0
Texto                   db          "Puntuacion:",0
score                   dword        0
Gameover                dword        0
auxgameover             dword        0
;===============================================Variables que pueden cambiar===================================================

windowTitle				db			"Peds Crush",0
windowWidth				DWORD		600	
windowHeight			DWORD		600
window2x				DWORD		650
window2y    			DWORD		680
messageBoxTitle			byte		' ',0	
messageBoxText			byte		' ',0
musicFilename			byte		'01.wav',0
image					HBITMAP		?
imageFilename			byte		'PEDSCRUSH.bmp',0
imageFilename2			byte		'PedsDef.bmp',0
mover                   dword       0
cuadrox                 dword       0
cuadroy                 dword       0
idxy                    elementos   90 dup                ({})
cuadro1                 RECT        {}
cuadro2                 RECT        {}
punto                   POINT       {}
id                      word        0
idprimerpunto           word        0
idsegundopunto          word        0
idpuntouno              word        0
idpuntodos              word        0
idCaso                  word        0
aux                     dword       0
auxy                    dword       0
auxpuntoalto            word        0
auxpuntounox            word        0
auxpuntodosx            word        0
auxpuntotresx           word        0
idllamar                word        0
auxx                    dword       0
auxid                   dword       0
contador                word        0
contador2               word        0
contador3               word        0

; ================================================================== MACROS ========================================================
RGB MACRO red, green, blue
	exitm % blue shl 16 + green shl 8 + red
endm 
;=================================================================== Identificador de botones ======================================
.const
ButtonID                equ          1
ButtonID2               equ          2

.code

main proc
	invoke	GetModuleHandleA, NULL   
	invoke	WinMain, eax, NULL, NULL, SW_SHOWDEFAULT
	invoke  ExitProcess,0
main endp


WinMain proc hInstance:dword, hPrevInst:dword, cmdLine:dword, cmdShow:DWORD

	mov		windowClass.lpfnWndProc, OFFSET WindowCallback
	mov		windowClass.cbSize, SIZEOF WNDCLASSEX
	mov		eax, hInstance
	mov		windowClass.hInstance, eax
	mov		windowClass.lpszClassName, OFFSET className
	invoke RegisterClassExA, addr windowClass                      
    
	; ===================================================== CREACIÓN DE LA VENATANA =================================================

	xor		ebx, ebx
	mov		ebx, WS_OVERLAPPED
	or		ebx, WS_CAPTION
	or		ebx, WS_SYSMENU
	invoke CreateWindowExA, NULL, ADDR className, ADDR windowTitle, ebx, CW_USEDEFAULT, CW_USEDEFAULT, windowWidth, windowHeight, NULL, NULL, hInstance, NULL
	mov		windowHandler, eax
    invoke ShowWindow, windowHandler,cmdShow               
    invoke UpdateWindow, windowHandler                    

	; ============================================================ EL CICLO DE MENSAJES ================================================
    invoke	GetMessageA, ADDR windowMessage, NULL, 0, 0
	.WHILE eax != 0                                  
        invoke	TranslateMessage, ADDR windowMessage
        invoke	DispatchMessageA, ADDR windowMessage
		invoke	GetMessageA, ADDR windowMessage, NULL, 0, 0
   .ENDW
    mov eax, windowMessage.wParam
	ret
WinMain endp

createwindow2 proc hInstance:dword, hPrevInst:dword, cmdLine:dword, cmdShow:DWORD

	mov		windowClass2.lpfnWndProc, OFFSET WindowCallback2
	mov		windowClass2.cbSize, SIZEOF WNDCLASSEX
	mov		eax, hInstance
	mov		windowClass2.hInstance, eax
	mov		windowClass2.lpszClassName, OFFSET className2
	invoke RegisterClassExA, addr windowClass2                      

	xor		ebx, ebx
	mov		ebx, WS_OVERLAPPED
	or		ebx, WS_CAPTION
	or		ebx, WS_SYSMENU
	invoke CreateWindowExA, NULL, ADDR className2, ADDR windowTitle, ebx, CW_USEDEFAULT, CW_USEDEFAULT, window2x, window2y, NULL, NULL, hInstance, NULL
	mov		windowHandler, eax
    invoke ShowWindow, windowHandler,cmdShow               
    invoke UpdateWindow, windowHandler                    

    invoke	GetMessageA, ADDR windowMessage, NULL, 0, 0
	.WHILE eax != 0                                  
        invoke	TranslateMessage, ADDR windowMessage
        invoke	DispatchMessageA, ADDR windowMessage
		invoke	GetMessageA, ADDR windowMessage, NULL, 0, 0
   .ENDW
    mov eax, windowMessage.wParam
	ret
createwindow2 endp


; El callback de la ventana.
; La mayoria de la lógica de su proyecto se encontrará aquí.
; (O desde aquí se mandarán a llamar a otras funciones)

WindowCallback proc handler:dword, message:dword, wParam:dword, lParam:dword
	.IF message == WM_CREATE

		invoke	GetClientRect, handler, addr clientRect
		invoke	GetDC, handler
		mov		windowContext, eax
		invoke	CreateCompatibleBitmap, windowContext, clientRect.right, clientRect.bottom
		mov		layer, eax
		invoke	CreateCompatibleDC, windowContext
		mov		layerContext, eax
		invoke	ReleaseDC, handler, windowContext
		invoke	SelectObject, layerContext, layer
		invoke	DeleteObject, layer
		invoke	CreateSolidBrush, RGB(0,0,0)
		mov		clearColor, eax
		invoke	LoadImage, NULL, addr imageFilename, IMAGE_BITMAP, 0, 0, LR_LOADFROMFILE
		mov		image, eax
		invoke	joyGetNumDevs
		invoke  CreateWindowExA,NULL, addr ButtonClass , addr ButtonText, WS_CHILD or WS_VISIBLE or BS_DEFPUSHBUTTON, 165,250,250,60,handler,ButtonID2,NULL, 0 
		invoke  CreateWindowExA,NULL, addr ButtonClass , addr ButtonText1, WS_CHILD or WS_VISIBLE or BS_DEFPUSHBUTTON, 165,330,250,60,handler,NULL,NULL, 0
		invoke  CreateWindowExA,NULL, addr ButtonClass , addr ButtonText2, WS_CHILD or WS_VISIBLE or BS_DEFPUSHBUTTON, 165,410,250,60,handler,ButtonID,NULL, 0
    .ELSEIF message==WM_COMMAND
	    mov	eax, wParam
	    .IF al==1
		  invoke PostQuitMessage, NULL
		.ENDIF
		.IF al==2
		 mov cuadroy,33
		 mov cuadrox,54
		 mov si,0
		 mov ecx,90
		 forinicializar:
		    push ecx
		    mov idxy[si].ID,0
		    mov eax,cuadrox
		    mov idxy[si].X,eax
		    mov eax,cuadroy
		    mov idxy[si].Y,eax
		    add cuadrox,54
		    add si,12
		    .IF cuadrox== 594
		        mov cuadrox,54
		        add cuadroy,54
		    .ENDIF
		    pop ecx
		 loop forinicializar
		 mov score, 0
		 mov Gameover,0
         invoke	createwindow2, eax, NULL, NULL, SW_SHOWDEFAULT
		.ENDIF
	.ELSEIF message == WM_PAINT
		invoke	BeginPaint, handler, addr windowPaintstruct
		mov		windowContext, eax
		invoke	CreateCompatibleBitmap, layerContext, clientRect.right, clientRect.bottom
		mov		auxiliarLayer, eax
		invoke	CreateCompatibleDC, layerContext
		mov		auxiliarLayerContext, eax
		invoke	SelectObject, auxiliarLayerContext, auxiliarLayer
		invoke	DeleteObject, auxiliarLayer
		invoke	FillRect, auxiliarLayerContext, addr clientRect, clearColor
		invoke	SelectObject, layerContext, image
		invoke	TransparentBlt, auxiliarLayerContext, 0, 0, 585, 560, layerContext, 0, 0, 500, 600, 00000FF00h
		invoke	BitBlt, windowContext, 0, 0, clientRect.right, clientRect.bottom, auxiliarLayerContext, 0, 0, SRCCOPY
		invoke  EndPaint, handler, addr windowPaintstruct
		invoke	DeleteDC, windowContext
		invoke	DeleteDC, auxiliarLayerContext

	.ELSEIF message == WM_DESTROY 
        invoke PostQuitMessage, NULL
    .ENDIF
    invoke DefWindowProcA, handler, message, wParam, lParam      
    ret
WindowCallback endp



;============================================================= segundo callback ======================================================================================


WindowCallback2 proc handler:dword, message:dword, wParam:dword, lParam:dword
	.IF message == WM_CREATE
	invoke	GetClientRect, handler, addr clientRect
		invoke	GetDC, handler
		mov		windowContext, eax
		invoke	CreateCompatibleBitmap, windowContext, clientRect.right, clientRect.bottom
		mov		layer, eax
		invoke	CreateCompatibleDC, windowContext
		mov		layerContext, eax
		invoke	ReleaseDC, handler, windowContext
		invoke	SelectObject, layerContext, layer
		invoke	DeleteObject, layer
		invoke	CreateSolidBrush, RGB(0,0,0)
		mov		clearColor, eax
		invoke	LoadImage, NULL, addr imageFilename2, IMAGE_BITMAP, 0, 0, LR_LOADFROMFILE
		mov		image, eax
		invoke	joyGetNumDevs
 	
		invoke	SetTimer, handler, 100, 10, NULL
	.ELSEIF message == WM_PAINT
		invoke	BeginPaint, handler, addr windowPaintstruct
		mov		windowContext, eax
		invoke	CreateCompatibleBitmap, layerContext, clientRect.right, clientRect.bottom
		mov		auxiliarLayer, eax
		invoke	CreateCompatibleDC, layerContext
		mov		auxiliarLayerContext, eax
		invoke	SelectObject, auxiliarLayerContext, auxiliarLayer
		invoke	DeleteObject, auxiliarLayer
		invoke	FillRect, auxiliarLayerContext, addr clientRect, clearColor
		invoke	SelectObject, layerContext, image
		;invoke  CreateWindowExA,NULL, addr EditClass , addr Texto, WS_CHILD or WS_VISIBLE, 150,570,80,20,handler,NULL,NULL, 0
        ;invoke  CreateWindowExA,NULL, addr EditClass, addr score, WS_CHILD or WS_VISIBLE, 230,570,45,20,handler,NULL,NULL, 0 
		invoke	TransparentBlt, auxiliarLayerContext, 0, 0, 660, 685, layerContext, 40, 32, 1215, 1250, 00000FF00h
		.IF idxy[0].ID==0
		invoke NumRam
		mov eax,mover
		mov idxy[0].ID,eax
		.ENDIF
		invoke	TransparentBlt, auxiliarLayerContext, idxy[0].X,idxy[0].Y , 50, 50, layerContext, idxy[0].ID, 1274, 233, 241, 00000FF00h
		.IF idxy[12].ID==0
		invoke NumRam
		mov eax,mover
		mov idxy[12].ID,eax
		.ENDIF
		invoke	TransparentBlt, auxiliarLayerContext, idxy[12].X, idxy[12].Y, 50, 50, layerContext, idxy[12].ID, 1274, 233, 241, 00000FF00h
		.IF idxy[24].ID==0
		invoke NumRam
		mov eax,mover
		mov idxy[24].ID,eax
		.ENDIF
		invoke	TransparentBlt, auxiliarLayerContext, idxy[24].X, idxy[24].Y, 50, 50, layerContext, idxy[24].ID, 1274, 233, 241, 00000FF00h
		.IF idxy[36].ID==0
		invoke NumRam
		mov eax,mover
		mov idxy[36].ID,eax
		.ENDIF
		invoke	TransparentBlt, auxiliarLayerContext, idxy[36].X, idxy[36].Y, 50, 50, layerContext, idxy[36].ID, 1274, 233, 241, 00000FF00h
		.IF idxy[48].ID==0
		invoke NumRam
		mov eax,mover
		mov idxy[48].ID,eax
		.ENDIF
		invoke	TransparentBlt, auxiliarLayerContext, idxy[48].X, idxy[48].Y, 50, 50, layerContext, idxy[48].ID, 1274, 233, 241, 00000FF00h
		.IF idxy[60].ID==0
		invoke NumRam
		mov eax,mover
		mov idxy[60].ID,eax
		.ENDIF
		invoke	TransparentBlt, auxiliarLayerContext, idxy[60].X, idxy[60].Y, 50, 50, layerContext, idxy[60].ID, 1274, 233, 241, 00000FF00h
		.IF idxy[72].ID==0
		invoke NumRam
		mov eax,mover
		mov idxy[72].ID,eax
		.ENDIF
		invoke	TransparentBlt, auxiliarLayerContext, idxy[72].X, idxy[72].Y, 50, 50, layerContext, idxy[72].ID, 1274, 233, 241, 00000FF00h
		
		.IF idxy[84].ID==0
		invoke NumRam
		mov eax,mover
		mov idxy[84].ID,eax
		.ENDIF
		invoke	TransparentBlt, auxiliarLayerContext, idxy[84].X, idxy[84].Y, 50, 50, layerContext, idxy[84].ID, 1274, 233, 241, 00000FF00h
		.IF idxy[96].ID==0
		invoke NumRam
		mov eax,mover
		mov idxy[96].ID,eax
		.ENDIF
		invoke	TransparentBlt, auxiliarLayerContext, idxy[96].X, idxy[96].Y, 50, 50, layerContext, idxy[96].ID, 1274, 233, 241, 00000FF00h
		.IF idxy[108].ID==0
		invoke NumRam
		mov eax,mover
		mov idxy[108].ID,eax
		.ENDIF
		invoke	TransparentBlt, auxiliarLayerContext, idxy[108].X, idxy[108].Y, 50, 50, layerContext, idxy[108].ID, 1274, 233, 241, 00000FF00h
		.IF idxy[120].ID==0
		invoke NumRam
		mov eax,mover
		mov idxy[120].ID,eax
		.ENDIF
		invoke	TransparentBlt, auxiliarLayerContext, idxy[120].X, idxy[120].Y, 50, 50, layerContext, idxy[120].ID, 1274, 233, 241, 00000FF00h
		.IF idxy[132].ID==0
		invoke NumRam
		mov eax,mover
		mov idxy[132].ID,eax
		.ENDIF
		invoke	TransparentBlt, auxiliarLayerContext, idxy[132].X, idxy[132].Y, 50, 50, layerContext, idxy[132].ID, 1274, 233, 241, 00000FF00h
		.IF idxy[144].ID==0
		invoke NumRam
		mov eax,mover
		mov idxy[144].ID,eax
		.ENDIF
		invoke	TransparentBlt, auxiliarLayerContext, idxy[144].X, idxy[144].Y, 50, 50, layerContext, idxy[144].ID, 1274, 233, 241, 00000FF00h
		.IF idxy[156].ID==0
		invoke NumRam
		mov eax,mover
		mov idxy[156].ID,eax
		.ENDIF
		invoke	TransparentBlt, auxiliarLayerContext, idxy[156].X, idxy[156].Y, 50, 50, layerContext, idxy[156].ID, 1274, 233, 241, 00000FF00h
		.IF idxy[168].ID==0
		invoke NumRam
		mov eax,mover
		mov idxy[168].ID,eax
		.ENDIF
		invoke	TransparentBlt, auxiliarLayerContext, idxy[168].X, idxy[168].Y, 50, 50, layerContext, idxy[168].ID, 1274, 233, 241, 00000FF00h
		.IF idxy[180].ID==0
		invoke NumRam
		mov eax,mover
		mov idxy[180].ID,eax
		.ENDIF
		invoke	TransparentBlt, auxiliarLayerContext, idxy[180].X, idxy[180].Y, 50, 50, layerContext, idxy[180].ID, 1274, 233, 241, 00000FF00h
		.IF idxy[192].ID==0
		invoke NumRam
		mov eax,mover
		mov idxy[192].ID,eax
		.ENDIF
		invoke	TransparentBlt, auxiliarLayerContext, idxy[192].X, idxy[192].Y, 50, 50, layerContext, idxy[192].ID, 1274, 233, 241, 00000FF00h
		.IF idxy[204].ID==0
		invoke NumRam
		mov eax,mover
		mov idxy[204].ID,eax
		.ENDIF
		invoke	TransparentBlt, auxiliarLayerContext, idxy[204].X, idxy[204].Y, 50, 50, layerContext, idxy[204].ID, 1274, 233, 241, 00000FF00h
		.IF idxy[216].ID==0
		invoke NumRam
		mov eax,mover
		mov idxy[216].ID,eax
		.ENDIF
		invoke	TransparentBlt, auxiliarLayerContext, idxy[216].X, idxy[216].Y, 50, 50, layerContext, idxy[216].ID, 1274, 233, 241, 00000FF00h
		.IF idxy[228].ID==0
		invoke NumRam
		mov eax,mover
		mov idxy[228].ID,eax
		.ENDIF
		invoke	TransparentBlt, auxiliarLayerContext, idxy[228].X, idxy[228].Y, 50, 50, layerContext, idxy[228].ID, 1274, 233, 241, 00000FF00h
		.IF idxy[240].ID==0
		invoke NumRam
		mov eax,mover
		mov idxy[240].ID,eax
		.ENDIF
		invoke	TransparentBlt, auxiliarLayerContext, idxy[240].X, idxy[240].Y, 50, 50, layerContext, idxy[240].ID, 1274, 233, 241, 00000FF00h
		.IF idxy[252].ID==0
		invoke NumRam
		mov eax,mover
		mov idxy[252].ID,eax
		.ENDIF
		invoke	TransparentBlt, auxiliarLayerContext, idxy[252].X, idxy[252].Y, 50, 50, layerContext, idxy[252].ID, 1274, 233, 241, 00000FF00h
		.IF idxy[264].ID==0
		invoke NumRam
		mov eax,mover
		mov idxy[264].ID,eax
		.ENDIF
		invoke	TransparentBlt, auxiliarLayerContext, idxy[264].X, idxy[264].Y, 50, 50, layerContext, idxy[264].ID, 1274, 233, 241, 00000FF00h
		.IF idxy[276].ID==0
		invoke NumRam
		mov eax,mover
		mov idxy[276].ID,eax
		.ENDIF
		invoke	TransparentBlt, auxiliarLayerContext, idxy[276].X, idxy[276].Y, 50, 50, layerContext, idxy[276].ID, 1274, 233, 241, 00000FF00h
		.IF idxy[288].ID==0
		invoke NumRam
		mov eax,mover
		mov idxy[288].ID,eax
		.ENDIF
		invoke	TransparentBlt, auxiliarLayerContext, idxy[288].X, idxy[288].Y, 50, 50, layerContext, idxy[288].ID, 1274, 233, 241, 00000FF00h
		.IF idxy[300].ID==0
		invoke NumRam
		mov eax,mover
		mov idxy[300].ID,eax
		.ENDIF
		invoke	TransparentBlt, auxiliarLayerContext, idxy[300].X, idxy[300].Y, 50, 50, layerContext, idxy[300].ID, 1274, 233, 241, 00000FF00h
		.IF idxy[312].ID==0
		invoke NumRam
		mov eax,mover
		mov idxy[312].ID,eax
		.ENDIF
		invoke	TransparentBlt, auxiliarLayerContext, idxy[312].X, idxy[312].Y, 50, 50, layerContext, idxy[312].ID, 1274, 233, 241, 00000FF00h
		.IF idxy[324].ID==0
		invoke NumRam
		mov eax,mover
		mov idxy[324].ID,eax
		.ENDIF
		invoke	TransparentBlt, auxiliarLayerContext, idxy[324].X, idxy[324].Y, 50, 50, layerContext, idxy[324].ID, 1274, 233, 241, 00000FF00h
		.IF idxy[336].ID==0
		invoke NumRam
		mov eax,mover
		mov idxy[336].ID,eax
		.ENDIF
		invoke	TransparentBlt, auxiliarLayerContext, idxy[336].X, idxy[336].Y, 50, 50, layerContext, idxy[336].ID, 1274, 233, 241, 00000FF00h
		.IF idxy[348].ID==0
		invoke NumRam
		mov eax,mover
		mov idxy[348].ID,eax
		.ENDIF
		invoke	TransparentBlt, auxiliarLayerContext, idxy[348].X, idxy[348].Y, 50, 50, layerContext, idxy[348].ID, 1274, 233, 241, 00000FF00h
		.IF idxy[360].ID==0
		invoke NumRam
		mov eax,mover
		mov idxy[360].ID,eax
		.ENDIF
		invoke	TransparentBlt, auxiliarLayerContext, idxy[360].X, idxy[360].Y, 50, 50, layerContext, idxy[360].ID, 1274, 233, 241, 00000FF00h
		.IF idxy[372].ID==0
		invoke NumRam
		mov eax,mover
		mov idxy[372].ID,eax
		.ENDIF
		invoke	TransparentBlt, auxiliarLayerContext, idxy[372].X, idxy[372].Y, 50, 50, layerContext, idxy[372].ID, 1274, 233, 241, 00000FF00h
		.IF idxy[384].ID==0
		invoke NumRam
		mov eax,mover
		mov idxy[384].ID,eax
		.ENDIF
		invoke	TransparentBlt, auxiliarLayerContext, idxy[384].X, idxy[384].Y, 50, 50, layerContext, idxy[384].ID, 1274, 233, 241, 00000FF00h
		.IF idxy[396].ID==0
		invoke NumRam
		mov eax,mover
		mov idxy[396].ID,eax
		.ENDIF
		invoke	TransparentBlt, auxiliarLayerContext, idxy[396].X, idxy[396].Y, 50, 50, layerContext, idxy[396].ID, 1274, 233, 241, 00000FF00h
		.IF idxy[408].ID==0
		invoke NumRam
		mov eax,mover
		mov idxy[408].ID,eax
		.ENDIF
		invoke	TransparentBlt, auxiliarLayerContext, idxy[408].X, idxy[408].Y, 50, 50, layerContext, idxy[408].ID, 1274, 233, 241, 00000FF00h
		.IF idxy[420].ID==0
		invoke NumRam
		mov eax,mover
		mov idxy[420].ID,eax
		.ENDIF
		invoke	TransparentBlt, auxiliarLayerContext, idxy[420].X, idxy[420].Y, 50, 50, layerContext, idxy[420].ID, 1274, 233, 241, 00000FF00h
		.IF idxy[432].ID==0
		invoke NumRam
		mov eax,mover
		mov idxy[432].ID,eax
		.ENDIF
		invoke	TransparentBlt, auxiliarLayerContext, idxy[432].X, idxy[432].Y, 50, 50, layerContext, idxy[432].ID, 1274, 233, 241, 00000FF00h
		.IF idxy[444].ID==0
		invoke NumRam
		mov eax,mover
		mov idxy[444].ID,eax
		.ENDIF
		invoke	TransparentBlt, auxiliarLayerContext, idxy[444].X, idxy[444].Y, 50, 50, layerContext, idxy[444].ID, 1274, 233, 241, 00000FF00h
		.IF idxy[456].ID==0
		invoke NumRam
		mov eax,mover
		mov idxy[456].ID,eax
		.ENDIF
		invoke	TransparentBlt, auxiliarLayerContext, idxy[456].X, idxy[456].Y, 50, 50, layerContext, idxy[456].ID, 1274, 233, 241, 00000FF00h
		.IF idxy[468].ID==0
		invoke NumRam
		mov eax,mover
		mov idxy[468].ID,eax
		.ENDIF
		invoke	TransparentBlt, auxiliarLayerContext, idxy[468].X, idxy[468].Y, 50, 50, layerContext, idxy[468].ID, 1274, 233, 241, 00000FF00h
		.IF idxy[480].ID==0
		invoke NumRam
		mov eax,mover
		mov idxy[480].ID,eax
		.ENDIF
		invoke	TransparentBlt, auxiliarLayerContext, idxy[480].X, idxy[480].Y, 50, 50, layerContext, idxy[480].ID, 1274, 233, 241, 00000FF00h
		.IF idxy[492].ID==0
		invoke NumRam
		mov eax,mover
		mov idxy[492].ID,eax
		.ENDIF
		invoke	TransparentBlt, auxiliarLayerContext, idxy[492].X, idxy[492].Y, 50, 50, layerContext, idxy[492].ID, 1274, 233, 241, 00000FF00h
		.IF idxy[504].ID==0
		invoke NumRam
		mov eax,mover
		mov idxy[504].ID,eax
		.ENDIF
		invoke	TransparentBlt, auxiliarLayerContext, idxy[504].X, idxy[504].Y, 50, 50, layerContext, idxy[504].ID, 1274, 233, 241, 00000FF00h
		.IF idxy[516].ID==0
		invoke NumRam
		mov eax,mover
		mov idxy[516].ID,eax
		.ENDIF
		invoke	TransparentBlt, auxiliarLayerContext, idxy[516].X, idxy[516].Y, 50, 50, layerContext, idxy[516].ID, 1274, 233, 241, 00000FF00h
		.IF idxy[528].ID==0
		invoke NumRam
		mov eax,mover
		mov idxy[528].ID,eax
		.ENDIF
		invoke	TransparentBlt, auxiliarLayerContext, idxy[528].X, idxy[528].Y, 50, 50, layerContext, idxy[528].ID, 1274, 233, 241, 00000FF00h
		.IF idxy[540].ID==0
		invoke NumRam
		mov eax,mover
		mov idxy[540].ID,eax
		.ENDIF
		invoke	TransparentBlt, auxiliarLayerContext, idxy[540].X, idxy[540].Y, 50, 50, layerContext, idxy[540].ID, 1274, 233, 241, 00000FF00h
		.IF idxy[552].ID==0
		invoke NumRam
		mov eax,mover
		mov idxy[552].ID,eax
		.ENDIF
		invoke	TransparentBlt, auxiliarLayerContext, idxy[552].X, idxy[552].Y, 50, 50, layerContext, idxy[552].ID, 1274, 233, 241, 00000FF00h
		.IF idxy[564].ID==0
		invoke NumRam
		mov eax,mover
		mov idxy[564].ID,eax
		.ENDIF
		invoke	TransparentBlt, auxiliarLayerContext, idxy[564].X, idxy[564].Y, 50, 50, layerContext, idxy[564].ID, 1274, 233, 241, 00000FF00h
		.IF idxy[576].ID==0
		invoke NumRam
		mov eax,mover
		mov idxy[576].ID,eax
		.ENDIF
		invoke	TransparentBlt, auxiliarLayerContext, idxy[576].X, idxy[576].Y, 50, 50, layerContext, idxy[576].ID, 1274, 233, 241, 00000FF00h
		.IF idxy[588].ID==0
		invoke NumRam
		mov eax,mover
		mov idxy[588].ID,eax
		.ENDIF
		invoke	TransparentBlt, auxiliarLayerContext, idxy[588].X, idxy[588].Y, 50, 50, layerContext, idxy[588].ID, 1274, 233, 241, 00000FF00h
		.IF idxy[600].ID==0
		invoke NumRam
		mov eax,mover
		mov idxy[600].ID,eax
		.ENDIF
		invoke	TransparentBlt, auxiliarLayerContext, idxy[600].X, idxy[600].Y, 50, 50, layerContext, idxy[600].ID, 1274, 233, 241, 00000FF00h
		.IF idxy[612].ID==0
		invoke NumRam
		mov eax,mover
		mov idxy[612].ID,eax
		.ENDIF
		invoke	TransparentBlt, auxiliarLayerContext, idxy[612].X, idxy[612].Y, 50, 50, layerContext, idxy[612].ID, 1274, 233, 241, 00000FF00h
		.IF idxy[624].ID==0
		invoke NumRam
		mov eax,mover
		mov idxy[624].ID,eax
		.ENDIF
		invoke	TransparentBlt, auxiliarLayerContext, idxy[624].X, idxy[624].Y, 50, 50, layerContext, idxy[624].ID, 1274, 233, 241, 00000FF00h
		.IF idxy[636].ID==0
		invoke NumRam
		mov eax,mover
		mov idxy[636].ID,eax
		.ENDIF
		invoke	TransparentBlt, auxiliarLayerContext, idxy[636].X, idxy[636].Y, 50, 50, layerContext, idxy[636].ID, 1274, 233, 241, 00000FF00h
		.IF idxy[648].ID==0
		invoke NumRam
		mov eax,mover
		mov idxy[648].ID,eax
		.ENDIF
		invoke	TransparentBlt, auxiliarLayerContext, idxy[648].X, idxy[648].Y, 50, 50, layerContext, idxy[648].ID, 1274, 233, 241, 00000FF00h
		.IF idxy[660].ID==0
		invoke NumRam
		mov eax,mover
		mov idxy[660].ID,eax
		.ENDIF
		invoke	TransparentBlt, auxiliarLayerContext, idxy[660].X, idxy[660].Y, 50, 50, layerContext, idxy[660].ID, 1274, 233, 241, 00000FF00h
		.IF idxy[672].ID==0
		invoke NumRam
		mov eax,mover
		mov idxy[672].ID,eax
		.ENDIF
		invoke	TransparentBlt, auxiliarLayerContext, idxy[672].X, idxy[672].Y, 50, 50, layerContext, idxy[672].ID, 1274, 233, 241, 00000FF00h
		.IF idxy[684].ID==0
		invoke NumRam
		mov eax,mover
		mov idxy[684].ID,eax
		.ENDIF
		invoke	TransparentBlt, auxiliarLayerContext, idxy[684].X, idxy[684].Y, 50, 50, layerContext, idxy[684].ID, 1274, 233, 241, 00000FF00h
		.IF idxy[696].ID==0
		invoke NumRam
		mov eax,mover
		mov idxy[696].ID,eax
		.ENDIF
		invoke	TransparentBlt, auxiliarLayerContext, idxy[696].X, idxy[696].Y, 50, 50, layerContext, idxy[696].ID, 1274, 233, 241, 00000FF00h
		.IF idxy[708].ID==0
		invoke NumRam
		mov eax,mover
		mov idxy[708].ID,eax
		.ENDIF
		invoke	TransparentBlt, auxiliarLayerContext, idxy[708].X, idxy[708].Y, 50, 50, layerContext, idxy[708].ID, 1274, 233, 241, 00000FF00h
		.IF idxy[720].ID==0
		invoke NumRam
		mov eax,mover
		mov idxy[720].ID,eax
		.ENDIF
		invoke	TransparentBlt, auxiliarLayerContext, idxy[720].X, idxy[720].Y, 50, 50, layerContext, idxy[720].ID, 1274, 233, 241, 00000FF00h
		.IF idxy[732].ID==0
		invoke NumRam
		mov eax,mover
		mov idxy[732].ID,eax
		.ENDIF
		invoke	TransparentBlt, auxiliarLayerContext, idxy[732].X, idxy[732].Y, 50, 50, layerContext, idxy[732].ID, 1274, 233, 241, 00000FF00h
		.IF idxy[744].ID==0
		invoke NumRam
		mov eax,mover
		mov idxy[744].ID,eax
		.ENDIF
		invoke	TransparentBlt, auxiliarLayerContext, idxy[744].X, idxy[744].Y, 50, 50, layerContext, idxy[744].ID, 1274, 233, 241, 00000FF00h
		.IF idxy[756].ID==0
		invoke NumRam
		mov eax,mover
		mov idxy[756].ID,eax
		.ENDIF
		invoke	TransparentBlt, auxiliarLayerContext, idxy[756].X, idxy[756].Y, 50, 50, layerContext, idxy[756].ID, 1274, 233, 241, 00000FF00h
		.IF idxy[768].ID==0
		invoke NumRam
		mov eax,mover
		mov idxy[768].ID,eax
		.ENDIF
		invoke	TransparentBlt, auxiliarLayerContext, idxy[768].X, idxy[768].Y, 50, 50, layerContext, idxy[768].ID, 1274, 233, 241, 00000FF00h
		.IF idxy[780].ID==0
		invoke NumRam
		mov eax,mover
		mov idxy[780].ID,eax
		.ENDIF
		invoke	TransparentBlt, auxiliarLayerContext, idxy[780].X, idxy[780].Y, 50, 50, layerContext, idxy[780].ID, 1274, 233, 241, 00000FF00h
		.IF idxy[792].ID==0
		invoke NumRam
		mov eax,mover
		mov idxy[792].ID,eax
		.ENDIF
		invoke	TransparentBlt, auxiliarLayerContext, idxy[792].X, idxy[792].Y, 50, 50, layerContext, idxy[792].ID, 1274, 233, 241, 00000FF00h
		.IF idxy[804].ID==0
		invoke NumRam
		mov eax,mover
		mov idxy[804].ID,eax
		.ENDIF
		invoke	TransparentBlt, auxiliarLayerContext, idxy[804].X, idxy[804].Y, 50, 50, layerContext, idxy[804].ID, 1274, 233, 241, 00000FF00h
		.IF idxy[816].ID==0
		invoke NumRam
		mov eax,mover
		mov idxy[816].ID,eax
		.ENDIF
		invoke	TransparentBlt, auxiliarLayerContext, idxy[816].X, idxy[816].Y, 50, 50, layerContext, idxy[816].ID, 1274, 233, 241, 00000FF00h
		.IF idxy[828].ID==0
		invoke NumRam
		mov eax,mover
		mov idxy[828].ID,eax
		.ENDIF
		invoke	TransparentBlt, auxiliarLayerContext, idxy[828].X, idxy[828].Y, 50, 50, layerContext, idxy[828].ID, 1274, 233, 241, 00000FF00h
		.IF idxy[840].ID==0
		invoke NumRam
		mov eax,mover
		mov idxy[840].ID,eax
		.ENDIF
		invoke	TransparentBlt, auxiliarLayerContext, idxy[840].X, idxy[840].Y, 50, 50, layerContext, idxy[840].ID, 1274, 233, 241, 00000FF00h
		.IF idxy[852].ID==0
		invoke NumRam
		mov eax,mover
		mov idxy[852].ID,eax
		.ENDIF
		invoke	TransparentBlt, auxiliarLayerContext, idxy[852].X, idxy[852].Y, 50, 50, layerContext, idxy[852].ID, 1274, 233, 241, 00000FF00h
		.IF idxy[864].ID==0
		invoke NumRam
		mov eax,mover
		mov idxy[864].ID,eax
		.ENDIF
		invoke	TransparentBlt, auxiliarLayerContext, idxy[864].X, idxy[864].Y, 50, 50, layerContext, idxy[864].ID, 1274, 233, 241, 00000FF00h
		.IF idxy[876].ID==0
		invoke NumRam
		mov eax,mover
		mov idxy[876].ID,eax
		.ENDIF
		invoke	TransparentBlt, auxiliarLayerContext, idxy[876].X, idxy[876].Y, 50, 50, layerContext, idxy[876].ID, 1274, 233, 241, 00000FF00h
		.IF idxy[888].ID==0
		invoke NumRam
		mov eax,mover
		mov idxy[888].ID,eax
		.ENDIF
		invoke	TransparentBlt, auxiliarLayerContext, idxy[888].X, idxy[888].Y, 50, 50, layerContext, idxy[888].ID, 1274, 233, 241, 00000FF00h
		.IF idxy[900].ID==0
		invoke NumRam
		mov eax,mover
		mov idxy[900].ID,eax
		.ENDIF
		invoke	TransparentBlt, auxiliarLayerContext, idxy[900].X, idxy[900].Y, 50, 50, layerContext, idxy[900].ID, 1274, 233, 241, 00000FF00h
		.IF idxy[912].ID==0
		invoke NumRam
		mov eax,mover
		mov idxy[912].ID,eax
		.ENDIF
		invoke	TransparentBlt, auxiliarLayerContext, idxy[912].X, idxy[912].Y, 50, 50, layerContext, idxy[912].ID, 1274, 233, 241, 00000FF00h
		.IF idxy[924].ID==0
		invoke NumRam
		mov eax,mover
		mov idxy[924].ID,eax
		.ENDIF
		invoke	TransparentBlt, auxiliarLayerContext, idxy[924].X, idxy[924].Y, 50, 50, layerContext, idxy[924].ID, 1274, 233, 241, 00000FF00h
		.IF idxy[936].ID==0
		invoke NumRam
		mov eax,mover
		mov idxy[936].ID,eax
		.ENDIF
		invoke	TransparentBlt, auxiliarLayerContext, idxy[936].X, idxy[936].Y, 50, 50, layerContext, idxy[936].ID, 1274, 233, 241, 00000FF00h
		.IF idxy[948].ID==0
		invoke NumRam
		mov eax,mover
		mov idxy[948].ID,eax
		.ENDIF
		invoke	TransparentBlt, auxiliarLayerContext, idxy[948].X, idxy[948].Y, 50, 50, layerContext, idxy[948].ID, 1274, 233, 241, 00000FF00h
		.IF idxy[960].ID==0
		invoke NumRam
		mov eax,mover
		mov idxy[960].ID,eax
		.ENDIF
		invoke	TransparentBlt, auxiliarLayerContext, idxy[960].X, idxy[960].Y, 50, 50, layerContext, idxy[960].ID, 1274, 233, 241, 00000FF00h
		.IF idxy[972].ID==0
		invoke NumRam
		mov eax,mover
		mov idxy[972].ID,eax
		.ENDIF
		invoke	TransparentBlt, auxiliarLayerContext, idxy[972].X, idxy[972].Y, 50, 50, layerContext, idxy[972].ID, 1274, 233, 241, 00000FF00h
		.IF idxy[984].ID==0
		invoke NumRam
		mov eax,mover
		mov idxy[984].ID,eax
		.ENDIF
		invoke	TransparentBlt, auxiliarLayerContext, idxy[984].X, idxy[984].Y, 50, 50, layerContext, idxy[984].ID, 1274, 233, 241, 00000FF00h
		.IF idxy[996].ID==0
		invoke NumRam
		mov eax,mover
		mov idxy[996].ID,eax
		.ENDIF
		invoke	TransparentBlt, auxiliarLayerContext, idxy[996].X, idxy[996].Y, 50, 50, layerContext, idxy[996].ID, 1274, 233, 241, 00000FF00h
		.IF idxy[1008].ID==0
		invoke NumRam
		mov eax,mover
		mov idxy[1008].ID,eax
		.ENDIF
		invoke	TransparentBlt, auxiliarLayerContext, idxy[1008].X, idxy[1008].Y, 50, 50, layerContext, idxy[1008].ID, 1274, 233, 241, 00000FF00h
		.IF idxy[1020].ID==0
		invoke NumRam
		mov eax,mover
		mov idxy[1020].ID,eax
		.ENDIF
		invoke	TransparentBlt, auxiliarLayerContext, idxy[1020].X, idxy[1020].Y, 50, 50, layerContext, idxy[1020].ID, 1274, 233, 241, 00000FF00h
		.IF idxy[1032].ID==0
		invoke NumRam
		mov eax,mover
		mov idxy[1032].ID,eax
		.ENDIF
		invoke	TransparentBlt, auxiliarLayerContext, idxy[1032].X, idxy[1032].Y, 50, 50, layerContext, idxy[1032].ID, 1274, 233, 241, 00000FF00h
		.IF idxy[1044].ID==0
		invoke NumRam
		mov eax,mover
		mov idxy[1044].ID,eax
		.ENDIF
		invoke	TransparentBlt, auxiliarLayerContext, idxy[1044].X, idxy[1044].Y, 50, 50, layerContext, idxy[1044].ID, 1274, 233, 241, 00000FF00h
		.IF idxy[1056].ID==0
		invoke NumRam
		mov eax,mover
		mov idxy[1056].ID,eax
		.ENDIF
		invoke	TransparentBlt, auxiliarLayerContext, idxy[1056].X, idxy[1056].Y, 50, 50, layerContext, idxy[1056].ID, 1274, 233, 241, 00000FF00h
		.IF idxy[1068].ID==0
		invoke NumRam
		mov eax,mover
		mov idxy[1068].ID,eax
		.ENDIF
		invoke	TransparentBlt, auxiliarLayerContext, idxy[1068].X, idxy[1068].Y, 50, 50, layerContext, idxy[1068].ID, 1274, 233, 241, 00000FF00h

		;============================================ Caso 1 =======================================================================================
		.IF idCaso==1
		  mov si, idprimerpunto
		  mov di,idsegundopunto
		  mov eax, auxy
		  .IF idxy[si].Y==eax
			  mov auxpuntoalto, 2
		  .ENDIF
		  .IF auxpuntoalto == 1 
		      sub idxy[si].Y,6
			  add idxy[di].Y,6
		  .ENDIF

		  .IF auxpuntoalto == 2 
		      add idxy[si].Y, 6
			  sub idxy[di].Y, 6	  
		  .ENDIF
		  .IF idxy[di].Y == eax
		      mov idCaso, 0
		  .ENDIF
		  .IF idxy[si].Y==eax
			  mov idllamar, 0
		  .ENDIF
		.ENDIF
		;============================================ Caso 2 =======================================================================================
		.IF idCaso==2
		  mov si, idprimerpunto
		  mov di,idsegundopunto
		  mov eax, auxy
		  .IF idxy[si].Y==eax
			  mov auxpuntoalto, 2
		  .ENDIF
		  .IF auxpuntoalto == 1 
		      add idxy[si].Y,6
			  sub idxy[di].Y,6
		  .ENDIF

		  .IF auxpuntoalto == 2 
		      sub idxy[si].Y, 6
			  add idxy[di].Y, 6		  
		  .ENDIF
		  .IF idxy[di].Y == eax
		      mov idCaso, 0
		  .ENDIF
		  .IF idxy[si].Y==eax
			  mov idllamar, 0
		  .ENDIF
		.ENDIF
		;============================================ Caso 3 =======================================================================================
		.IF idCaso==3
		  mov si, idprimerpunto
		  mov di,idsegundopunto
		  mov eax, aux
		  .IF idxy[si].X==eax
			  mov auxpuntoalto, 2
		  .ENDIF
		  .IF auxpuntoalto == 1 
		      sub idxy[si].X,6
			  add idxy[di].X,6
		  .ENDIF
		  
		  .IF auxpuntoalto == 2 
		      add idxy[si].X, 6
			  sub idxy[di].X, 6	  
		  .ENDIF
		  .IF idxy[di].X == eax
		      mov idCaso, 0
		  .ENDIF
		  .IF idxy[si].X==eax
			  mov idllamar,0
		  .ENDIF
		.ENDIF
		;============================================ Caso 4 ==========================================================================================
		.IF idCaso==4
		  mov si, idprimerpunto
		  mov di,idsegundopunto
		  mov eax, aux
		  .IF idxy[si].X==eax
			  mov auxpuntoalto, 2
		  .ENDIF
		  .IF auxpuntoalto == 1 
		      add idxy[si].X,6
			  sub idxy[di].X,6
		  .ENDIF
		  
		  .IF auxpuntoalto == 2 
		      sub idxy[si].X, 6
			  add idxy[di].X, 6		  
		  .ENDIF
		  .IF idxy[di].X == eax
		      mov idCaso, 0
		  .ENDIF
		  .IF idxy[si].X==eax
			  mov idllamar, 0
		  .ENDIF
		.ENDIF
		;=====================================================================================
		.IF idllamar == 0
		 invoke	Llamar
		 invoke Llamardos
		 invoke Llamartres
		 invoke Llamarcuatro
		 invoke Llamarcinco
		 mov idllamar, 1
		.ENDIF
		inc idllamar
		.IF idllamar == 50
		    mov idllamar, 0
		.ENDIF

		inc auxgameover 
		.IF auxgameover == 100
		    inc Gameover
			mov auxgameover, 0
		.ENDIF

		.IF score > 30 
		    invoke	TransparentBlt, auxiliarLayerContext, 50, 100, 540, 300, layerContext, 1301, 52, 540, 352, 00000FF00h
			invoke KillTimer, handler, 100
		.ENDIF
		
		.IF Gameover == 10
		    invoke	TransparentBlt, auxiliarLayerContext, 20, 220, 600, 180, layerContext, 1313, 449, 800, 250, 00000FF00h
			invoke KillTimer, handler, 100
		.ENDIF
		invoke	BitBlt, windowContext, 0, 0, clientRect.right, clientRect.bottom, auxiliarLayerContext, 0, 0, SRCCOPY
		invoke  EndPaint, handler, addr windowPaintstruct
		invoke	DeleteDC, windowContext
		invoke	DeleteDC, auxiliarLayerContext

    .ELSEIF message == WM_LBUTTONDOWN
	 .IF idpuntouno==0
	    mov idCaso, 0
	    mov edx, lParam
		mov ebx, lParam
		and edx, 00000FFFFh
		and ebx, 0FFFF0000h
		ror ebx,16
		mov punto.x, edx
		mov punto.y, ebx
		mov ecx, 90
		mov si,0
		top:
		  push ecx
		  mov eax, idxy[si].X
		  mov cuadro1.left,eax
		  add eax, 53
		  mov cuadro1.right, eax
		  mov eax, idxy[si].Y
		  mov cuadro1.top, eax
		  add eax, 54
		  mov cuadro1.bottom, eax
		  invoke PtInRect, addr cuadro1, punto.x, punto.y
		  .IF eax != 0
			 mov ecx,90
			 mov idprimerpunto,si
			 mov idpuntouno, 1
			 jmp miEtiqueta
		  .ENDIF
		  add si,12
		  pop ecx
		loop top

	  .ENDIF

	    mov edx, lParam
		mov ebx, lParam
		and edx, 00000FFFFh
		and ebx, 0FFFF0000h
		ror ebx,16
		mov punto.x, edx
		mov punto.y, ebx
		mov ecx, 90
		mov di,0
		puntodos:
		  push ecx
		  mov eax, idxy[di].X
		  mov cuadro1.left,eax
		  add eax, 54
		  mov cuadro2.right, eax
		  mov eax, idxy[di].Y
		  mov cuadro2.top, eax
		  add eax, 54
		  mov cuadro2.bottom, eax
		  invoke PtInRect, addr cuadro2, punto.x, punto.y
		  .IF eax != 0
			 mov ecx,90
			 mov id, 1
			 mov idsegundopunto,di
			 mov idpuntouno, 0
			 jmp misegundaetiqueta
		  .ENDIF
		  add di,12
		  pop ecx
		loop puntodos
		misegundaetiqueta:
		;================================================= Eje Y ========================================================
		mov eax, idxy[di].X
		mov si, idprimerpunto
		.IF idxy[si].X == eax
		   mov eax, idxy[di].Y
		   .IF idxy[si].Y > eax
		       mov auxy, eax
		 	   sub idxy[si].Y,54
		       .IF idxy[si].Y == eax
			   	  mov idCaso, 1
				  mov auxpuntoalto, 1
			   .ENDIF
			   add idxy[si].Y, 54
		  .ENDIF
		   .IF idxy[si].Y < eax
		       mov auxy, eax
		 	   add idxy[si].Y,54
		       .IF idxy[si].Y == eax
			   	  mov idCaso, 2
				  mov auxpuntoalto, 1
			   .ENDIF
			   sub idxy[si].Y, 54
		   .ENDIF
		.ENDIF
		;================================================= Eje x ========================================================
		mov eax, idxy[di].Y
		mov si, idprimerpunto
		.IF idxy[si].Y == eax
		    mov eax, idxy[di].X
		    .IF idxy[si].X > eax
		        mov aux, eax
				sub idxy[si].X, 54
				.IF idxy[si].X == eax
				    mov idCaso, 3
					mov auxpuntoalto, 1
				.ENDIF
				add idxy[si].X,54
		    .ENDIF
			mov eax, idxy[di].X
		    .IF idxy[si].X < eax
		        mov aux, eax
				add idxy[si].X, 54
				.IF idxy[si].X == eax
				    mov idCaso, 4
					mov auxpuntoalto, 1
				.ENDIF
				sub idxy[si].X,54
		    .ENDIF



		.ENDIF
		miEtiqueta:
        .ELSEIF message == WM_KEYDOWN
		mov	eax, wParam
		.IF al == 80
			mov eax, score
		.ENDIF
	.ELSEIF message == WM_TIMER
		invoke	InvalidateRect, handler, NULL, FALSE

	.ELSEIF message == WM_DESTROY
        invoke PostQuitMessage, NULL
    .ENDIF
    invoke DefWindowProcA, handler, message, wParam, lParam      
    ret
WindowCallback2 endp

NumRam proc
	xor		ebx, ebx
	invoke nrandom, 5
	.IF eax ==0
       mov mover, 16
	.ENDIF
	.IF eax==1
	  mov mover, 265
	.ENDIF
	.IF eax==2
	  mov mover, 511
	.ENDIF
	.IF eax==3
	  mov mover, 759
	.ENDIF
	.IF eax==4
	  mov mover, 1005
	.ENDIF
	ret
NumRam endp

Llamar proc
;==================================================================== Logica en Y ============================================================================
		mov si, 0
		mov contador, 0
		foruno:
		  mov eax, idxy[si].X
		  mov contador2, 0
		  mov di, si
		  add di, 108
		  mov auxpuntounox, di
		  .IF idxy[di].X == eax
		      mov eax, idxy[si].ID
			  .IF idxy[di].ID == eax
		          mov auxpuntodosx, di
				  mov eax, idxy[si].X
			      add di, 132
			      .IF idxy[di].X == eax
			          mov eax, idxy[si].ID
				      .IF idxy[di].ID == eax
				          mov idxy[si].ID, 0
					      mov idxy[di].ID, 0
					      sub di, 132
					      mov idxy[di].ID, 0
						  add score, 3
				      .ENDIF
			      .ENDIF
			  .ENDIF
		  .ENDIF
		  mov di, auxpuntounox
		  add di, 12
		  mov auxpuntounox, di
		  mov eax, idxy[si].X
		  .IF idxy[di].X == eax
		      mov eax, idxy[si].ID
			  .IF idxy[di].ID == eax
			      mov auxpuntodosx, di
				  add di, 108
				  mov eax, idxy[si].X
				  .IF idxy[di].X == eax
				      mov eax, idxy[si].ID
					  .IF idxy[di].ID == eax
					      mov idxy[si].ID, 0
						  mov idxy[di].ID, 0
						  sub di, 108
						  mov idxy[di].ID, 0
						  add score, 3
					  .ENDIF
				  .ENDIF
				  mov di, auxpuntodosx
				  add di, 120
				  mov eax, idxy[si].X
				  .IF idxy[di].X == eax
				      mov eax, idxy[si].ID
					  .IF idxy[di].ID == eax
					      mov idxy[si].ID, 0
						  mov idxy[di].ID, 0
						  sub di, 120
						  mov idxy[di].ID, 0
						  add score, 3
					  .ENDIF
				  .ENDIF

				  mov di, auxpuntodosx
				  add di, 240
				  mov eax, idxy[si].X
				  .IF idxy[di].X == eax
				      mov eax, idxy[si].Y
					  add eax, 108
					  .IF idxy[di].Y == eax
					      mov eax, idxy[si].ID
						  .IF idxy[di].ID == eax
					          mov idxy[si].ID, 0
						      mov idxy[di].ID, 0
						      sub di, 240
						      mov idxy[di].ID, 0
							  add score, 3
						  .ENDIF
					  .ENDIF
				  .ENDIF


				  mov di, auxpuntodosx
				  add di, 132
				  mov eax, idxy[si].X
				  .IF idxy[di].X == eax
				      mov eax, idxy[si].ID
					  .IF idxy[di].ID == eax
					      mov idxy[si].ID, 0
						  mov idxy[di].ID, 0
						  sub di, 132
						  mov idxy[di].ID, 0
						  add score, 3
					  .ENDIF
				  .ENDIF
			  .ENDIF
		  .ENDIF
		  mov di, auxpuntounox
		  add di, 12
		  mov eax, idxy[si].X
		  .IF idxy[di].X == eax
		      mov eax, idxy[si].ID
			  .IF idxy[di].ID == eax
                  mov auxpuntodosx, di
				  mov eax, idxy[si].X
			      add di, 108
			      .IF idxy[di].X == eax
			          mov eax, idxy[si].ID
				      .IF idxy[di].ID == eax
				          mov idxy[si].ID, 0
					      mov idxy[di].ID, 0
					      sub di, 108
					      mov idxy[di].ID, 0
						  add score, 3
				      .ENDIF
			      .ENDIF
			  .ENDIF
		  .ENDIF
		  add si, 12
		  inc contador
		  .IF contador == 70
		     jmp findelfor
		  .ENDIF
		jnz foruno
		findelfor:
		ret
Llamar endp


Llamardos proc
		mov si, 0
		mov contador, 0
		foruno:
		mov di, si
		mov eax, idxy[si].ID
		add di, 120
		.IF idxy[di].ID == eax
		    add di, 120
			.IF idxy[di].ID == eax
			    mov idxy[si].ID, 0
				mov idxy[di].ID, 0
				sub di, 120
				mov idxy[di].ID, 0
				add score, 3
			.ENDIF
		 
		.ENDIF
		add si, 12
		inc contador
		.IF contador == 70
		    jmp finuno
		.ENDIF
		jnz foruno
		finuno:
		ret
Llamardos endp

Llamartres proc
        mov si, 0
		mov contador, 0
		foruno:
		mov di, si
		add di, 132
		mov eax, idxy[si].X
		.IF idxy[di].X == eax
		    mov eax, idxy[si].ID
			.IF idxy[di]. ID == eax
			    add di, 120
				mov eax, idxy[si].X
				.IF idxy[di].X == eax
				    mov eax, idxy[si].ID
					.IF idxy[si].ID == eax
					    mov idxy[si].ID, 0
						mov idxy[di].ID, 0
						sub di, 120
						mov idxy[si].ID, 0
						add score, 3
					.ENDIF
				.ENDIF
			.ENDIF
	    .ENDIF
        mov di, si
		add di, 108
		mov eax, idxy[si].X
		.IF idxy[di].X == eax
		    mov eax, idxy[si].ID
			.IF idxy[di]. ID == eax
			    add di, 120
				mov eax, idxy[si].X
				.IF idxy[di].X == eax
				    mov eax, idxy[si].ID
					.IF idxy[si].ID == eax
					    mov idxy[si].ID, 0
						mov idxy[di].ID, 0
						sub di, 120
						mov idxy[si].ID, 0
						add score, 3
					.ENDIF
				.ENDIF
			.ENDIF
	    .ENDIF
		add si, 12
		inc contador
		.IF contador == 70
		    jmp findelfor
		.ENDIF
		jnz foruno
		findelfor:
		ret
Llamartres endp

Llamarcuatro proc
        mov si, 0
		mov contador,0
		foruno:
		mov di, si
		add di, 240
		mov eax, idxy[si].Y
		add eax, 54
		.IF idxy[di].Y == eax
		    mov eax, idxy[si].ID
			.IF idxy[di].ID == eax
			    add di, 120
				.IF idxy[di].ID == eax
				    mov idxy[si].ID, 0
					mov idxy[di].ID, 0
					sub di, 120
					mov idxy[di].ID, 0
					add score, 3
				.ENDIF
			.ENDIF
		.ENDIF
		add si, 12
		inc contador
		.IF contador == 60
		    jmp findelfor
		.ENDIF
		jnz foruno
		findelfor:
		ret
Llamarcuatro endp
       
Llamarcinco proc
 mov contador, 0
		mov contador, 2
		mov si,0
		foruno:
		mov di, si 
		add di, 12
		mov eax, idxy[si].ID
		.IF idxy[di].ID == eax
		    add di, 12
			.IF idxy[di].ID == eax
			    mov idxy[si].ID, 0
				mov idxy[di].ID, 0
				sub di, 12
				mov idxy[di].ID, 0
			.ENDIF
		.ENDIF
		inc contador 
		inc contador2
		add si, 12
		.IF contador2 == 8
		    mov contador2, 0
			add si, 24
		.ENDIF
		.IF contador == 72
		    jmp findelfor
		.ENDIF
		jnz foruno
		findelfor:
		ret
Llamarcinco endp

;auxpuntounox            word        0
;auxpuntodosx            word        0
;auxpuntotresx           word        0
;auxx                    dword       0
;auxid                   dword       0
;contador                word        0

credits	proc handler:DWORD
	; Estoy matando al timer para que no haya problemas al mostrar el Messagebox.
	; Veanlo como un sistema de pausa
	invoke KillTimer, handler, 100
	xor ebx, ebx
	mov ebx, MB_OK
	or	ebx, MB_ICONINFORMATION
	invoke	MessageBoxA, handler, addr messageBoxText, addr messageBoxTitle, ebx
	; Volvemos a habilitar el timer
	invoke SetTimer, handler, 100, 10, NULL
	ret
credits endp



end main