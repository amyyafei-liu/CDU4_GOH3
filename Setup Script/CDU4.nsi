; Script generated with the Venis Install Wizard
!include "FileAssociation.nsh"
;!include "FileFunc.nsh"

; Define your application name
!define APPNAME "CDU4"
!define APPNAMEANDVERSION "CDU4"
!define VERSION "1.0"
!define PUBLISHER "RSI"


; Main Install settings
Name "${APPNAME} ${VERSION}"
InstallDir "C:\RSI\${APPNAME} ${VERSION}"
InstallDirRegKey HKLM "Software\${APPNAME} ${VERSION}" ""

!define /date MyTIMESTAMP "%d%m%Y_%H%M%S"
 
OutFile "${APPNAME}_${VERSION}.exe"
RequestExecutionLevel admin ;Require admin rights on NT6+ (When UAC is turned on)

; Modern interface settings
!include "MUI.nsh"

!define MUI_ABORTWARNING

!insertmacro MUI_PAGE_WELCOME
!insertmacro MUI_PAGE_DIRECTORY
;!insertmacro MUI_PAGE_COMPONENTS
!insertmacro MUI_PAGE_INSTFILES
!insertmacro MUI_PAGE_FINISH

!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES

; Set languages (first is default language)
!insertmacro MUI_LANGUAGE "English"
!insertmacro MUI_RESERVEFILE_LANGDLL

;section obligatoire d'ou le -
Section "CDU4" Section1
SetShellVarContext current


; *********************IndissPlus core	
	; Set Section properties
	SetOverwrite on

	; -------------------------------------------------------------------------------------------------------------------
	; BP_BP	
	; -------------------------------------------------------------------------------------------------------------------
	SetOutPath "$INSTDIR"
	File /r /x "*.pdb" "..\bin\Debug\*.*"
	File "..\Simulator\CDU4.IndissPlus"
	;File /r /x "*.pdb" "..\bin\Release\*.*"
	
	; Copy Unit system files
	Call GetIndissPlusInstallationFolder
	SetOutPath "$0\UnitServer"
	File "..\UnitSystem\*.system"
	
	; -------------------------------------------------------------------------------------------------------------------
	; Csv configuration file
	; -------------------------------------------------------------------------------------------------------------------
	SetOverwrite off
    File /oname=$DOCUMENTS\RSI\CDU4.csv "..\CDU4.csv"
	SetOverwrite on
	
    Call GetViewerInstallationFolder
	
	; ShortCuts
	CreateShortCut "$DESKTOP\CDU4_${VERSION}.lnk" \ 
				   "$0\Viewer.exe" \
				   "$\"$INSTDIR\CDU4.dll$\" -UnitSystem:BP_CDU4"


Return

err_dot_net_not_found2:
	Abort "Aborted: .Net framework not found on registry."

SectionEnd

Section -FinishSection
SetShellVarContext all
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APPNAME} ${VERSION}" "DisplayName" "${APPNAME}"
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APPNAME} ${VERSION}" "UninstallString" "$INSTDIR\uninstall.exe"
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APPNAME} ${VERSION}" "Publisher" "${PUBLISHER}"
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APPNAME} ${VERSION}" "DisplayVersion" "${VERSION}"
	WriteUninstaller "$INSTDIR\uninstall.exe"

SectionEnd

; Modern install component descriptions
!insertmacro MUI_FUNCTION_DESCRIPTION_BEGIN
	!insertmacro MUI_DESCRIPTION_TEXT ${Section1} "NKREFORM MASTER HIS0164"
!insertmacro MUI_FUNCTION_DESCRIPTION_END

;Uninstall section
Section Uninstall
	SetShellVarContext all

	;Remove from registry...
	DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APPNAME} ${VERSION}"
	DeleteRegKey HKLM "SOFTWARE\${APPNAME} ${VERSION}"
	DeleteRegKey /ifempty HKLM "SOFTWARE\${APPNAME}"
	
	
	; Delete self
	Delete "$INSTDIR\uninstall.exe"

	; Delete Shortcuts
	Delete "$DESKTOP\CDU4_${VERSION}.lnk"
	; Clean up Core
	RMDir /r $INSTDIR

SectionEnd

BrandingText "Copyright 2014 RSI"


Function GetViewerInstallationFolder

	ReadRegStr $0 HKLM "SOFTWARE\RSI" Viewer
 
	
FunctionEnd

Function GetIndissPlusInstallationFolder

	ReadRegStr $0 HKLM "SOFTWARE\RSI" Core
 
	
FunctionEnd

; Given a .NET version number, this function returns that .NET framework's
; install directory. Returns "" if the given .NET version is not installed.
; Params: [version] (eg. "v2.0")
; Return: [dir] (eg. "C:\WINNT\Microsoft.NET\Framework\v2.0.50727")
Function GetDotNetDir
	Exch $R0 ; Set R0 to .net version major
	Push $R1
	Push $R2
 DetailPrint ".Net Major Version $R0"
	; set R1 to minor version number of the installed .NET runtime
	EnumRegValue $R1 HKLM \
		"Software\Microsoft\.NetFramework\policy\$R0" 0
	IfErrors getdotnetdir_err
	 
	DetailPrint ".Net Version $R0.$R1"
	; set R2 to .NET install dir root
	ReadRegStr $R2 HKLM \
		"Software\Microsoft\.NetFramework" "InstallRoot"
	IfErrors getdotnetdir_err
 
	; set R0 to the .NET install dir full
	StrCpy $R0 "$R2$R0.$R1"
 
	getdotnetdir_end:
		Pop $R2
		Pop $R1
		Exch $R0 ; return .net install dir full
		DetailPrint ".Net folder $R0"
		Return
	 
	getdotnetdir_err:
		DetailPrint ".Net retrieving error"
		StrCpy $R0 ""
		Goto getdotnetdir_end
 
FunctionEnd


Function CheckDotNet_4_5
    Exch $R0 ; Set R0 to .net version major
    ; Magic numbers from http://msdn.microsoft.com/en-us/library/ee942965.aspx
    ClearErrors
    ReadRegDWORD $R0 HKLM "SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full" "Release"

    IfErrors NotDetected

    ${If} $R0 >= 378389

        DetailPrint "Microsoft .NET Framework 4.5 is installed ($R0)"
		Exch $R0 ;
		return
    ${Else}
    NotDetected:
;        DetailPrint "Installing Microsoft .NET Framework 4.5"
;        SetDetailsPrint listonly
;        ExecWait '"$INSTDIR\Tools\dotNetFx45_Full_setup.exe" /passive /norestart' $0
;        ${If} $0 == 3010 
;        ${OrIf} $0 == 1641
;            DetailPrint "Microsoft .NET Framework 4.5 installer requested reboot"
;            SetRebootFlag true
;        ${EndIf}
;        SetDetailsPrint lastused
;        DetailPrint "Microsoft .NET Framework 4.5 installer returned $0"
		
		StrCpy $R0 ""
		Exch $R0 ;
		
    ${EndIf}

FunctionEnd


; eof