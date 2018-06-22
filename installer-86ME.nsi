!include x64.nsh
!include FileFunc.nsh

!define PRODUCT_NAME "86ME"
!define PRODUCT_EXE "86ME.exe"
!define PRODUCT_VERSION 2.1
!define PRODUCT_PUBLISHER "86ME Srl"
!define PRODUCT_WEB_SITE "http://www.86duino.com"
!define PRODUCT_DIR_REGKEY "Software\Microsoft\Windows\CurrentVersion\App Paths\${PRODUCT_EXE}"
!define PRODUCT_UNINST_KEY "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT_NAME}"
!define PRODUCT_UNINST_ROOT_KEY "HKLM"
!define LOCAL_FILES_PATH "C:\Users\AndrewLin\Desktop\86Scratch_installer"
!define PROGRAMDATAFILES "C:\ProgramData"
/*!define PATH_ICON "${LOCAL_FILES_PATH}\files\arduino-${PRODUCT_VERSION}\lib"*/
!define LICENSE_PATH "${LOCAL_FILES_PATH}"
!define SOURCE_PATH "${LOCAL_FILES_PATH}\files\86ME-${PRODUCT_VERSION}"

SetCompressor /SOLID lzma
Name "${PRODUCT_NAME}"
OutFile "86ME-${PRODUCT_VERSION}-windows.exe"
LoadLanguageFile "${NSISDIR}\Contrib\Language files\English.nlf"
InstallDir "${PROGRAMDATAFILES}\${PRODUCT_NAME}"
/*Icon "${PATH_ICON}\arduino_icon.ico" ;------->file icona*/
/*UninstallIcon "${PATH_ICON}\arduino_icon.ico"*/
InstallDirRegKey HKLM "${PRODUCT_DIR_REGKEY}" ""
ComponentText "Check the components you want to install and uncheck the components you don't want to install:"
DirText "Setup will install $(^Name) in the following folder.$\r$\n$\r$\nTo install in a different folder, click Browse and select another folder."
LicenseText "If you accept all the terms of the agreement, choose I Agree to continue. You must accept the agreement to install $(^Name)."
LicenseData "${LICENSE_PATH}\License-86ME.txt" ;----->file licenza
ShowInstDetails hide
ShowUnInstDetails hide

Section "Install 86ME software" SEC01
  SectionIn RO
  SetOutPath "$INSTDIR"
  SetOverwrite try
  File /r "${SOURCE_PATH}\" ;---->directory contenente tutti i file e subdirectory. Importante la \ alla fine
  CreateDirectory "$SMPROGRAMS\${PRODUCT_NAME}"

SectionEnd

Section /o "Install USB drivers" SEC02
  ${IF} ${RunningX64}
    DetailPrint "Installing 64 bit drivers"
    ExecShell "open" "$INSTDIR\drivers\dpinst-amd64.exe" "/LM /SA /SW"
  ${ELSE}
    DetailPrint "Installing 32 bit drivers"
    ExecShell "open" "$INSTDIR\drivers\dpinst-x86.exe" "/LM /SA /SW"
  ${ENDIF}
SectionEnd

Section "Create Start Menu shortcut" SEC03
  CreateShortCut "$SMPROGRAMS\${PRODUCT_NAME}\${PRODUCT_NAME}.lnk" "$INSTDIR\${PRODUCT_EXE}"
SectionEnd

Section "Create Desktop shortcut" SEC04
  CreateShortCut "$DESKTOP\${PRODUCT_NAME}.lnk" "$INSTDIR\${PRODUCT_EXE}"
SectionEnd

Section -AdditionalIcons
  SetOutPath $INSTDIR
  WriteIniStr "$INSTDIR\${PRODUCT_NAME}.url" "InternetShortcut" "URL" "${PRODUCT_WEB_SITE}"
  CreateShortCut "$SMPROGRAMS\${PRODUCT_NAME}\Website.lnk" "$INSTDIR\${PRODUCT_NAME}.url"
  CreateShortCut "$SMPROGRAMS\${PRODUCT_NAME}\Uninstall.lnk" "$INSTDIR\uninst.exe"
SectionEnd

Section -Post
  WriteUninstaller "$INSTDIR\uninst.exe"
  WriteRegStr HKLM "${PRODUCT_DIR_REGKEY}" "" "$INSTDIR\${PRODUCT_EXE}"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "DisplayName" "$(^Name)"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "UninstallString" "$INSTDIR\uninst.exe"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "DisplayIcon" "$INSTDIR\${PRODUCT_EXE}"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "DisplayVersion" "${PRODUCT_VERSION}"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "URLInfoAbout" "${PRODUCT_WEB_SITE}"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "Publisher" "${PRODUCT_PUBLISHER}"
SectionEnd

Function .onInit
  ;to check if the software is already installed
  Var /GLOBAL version
  ReadRegStr $R0 HKLM \
  "${PRODUCT_UNINST_KEY}" \
  "UninstallString"
  StrCmp $R0 "" done
  ;to detect the installed software release
  ReadRegStr $version HKLM \
  "${PRODUCT_UNINST_KEY}" \
  "DisplayVersion"

  MessageBox MB_OKCANCEL|MB_ICONEXCLAMATION \
    "${PRODUCT_NAME} version $version is already installed and must be uninstalled before you install this version. This won't affect scketches or libraries in the sketch directory. $\n$\nClick `OK` to uninstall from: $\n$\n$\nClick 'Cancel' if you have files in the install directory that you wish to keep (most users don't). Copy them somewhere else re-run the installer."\
  IDOK uninst
  Abort

;Run the uninstaller
uninst:
  ClearErrors
  ExecWait '$R0 _?=$INSTDIR' ;Do not copy the uninstaller to a temp file

  IfErrors no_remove_uninstaller done
    ;You can either use Delete /REBOOTOK in the uninstaller or add some code
    ;here to remove the uninstaller. Use a registry key to check
    ;whether the user has chosen to uninstall. If you are using an uninstaller
    ;components page, make sure all sections are uninstalled.
  no_remove_uninstaller:
  Abort

done:

FunctionEnd

Function un.onUninstSuccess
  HideWindow
  MessageBox MB_ICONINFORMATION|MB_OK "The $(^Name) software has been uninstalled. You can safely delete the 86ME install directory (if it still exists) and your 86ME sketch directory if you wish."
FunctionEnd

Section Uninstall
  MessageBox MB_OKCANCEL "Warning: All existing files in $INSTDIR will be deleted. This includes files and folders present before or added since you installed the 86ME software." IDYES uninstall_file IDCANCEL not_uninstall

  uninstall_file:
  RMDir /r "$INSTDIR"

  DetailPrint "Remove registry keys..."
  DeleteRegKey ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}"
  DeleteRegKey HKLM "${PRODUCT_DIR_REGKEY}"
  DetailPrint "Disassociating .ino files..."
  /*${unregisterExtension} ".ino" "Files INO"*/
  ;Delete Start Menu Shortcuts
  DetailPrint "Delete shortucts..."
  Delete "$DESKTOP\${PRODUCT_NAME}.lnk"
  Delete "C:\Users\Public\Desktop\86ME.lnk"
  SetAutoClose false
  return

  not_uninstall:
  Abort
SectionEnd
