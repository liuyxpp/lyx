VERSION 5.00
Begin {C62A69F0-16DC-11CE-9E98-00AA00574A4F} frmCR 
   Caption         =   "���б任"
   ClientHeight    =   675
   ClientLeft      =   45
   ClientTop       =   435
   ClientWidth     =   2190
   OleObjectBlob   =   "���б任.frx":0000
   StartUpPosition =   1  '����������
End
Attribute VB_Name = "frmCR"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Private Sub cmdC2R_Click()
    ģ��1.�б����б任 (False)
    Unload frmCR
End Sub

Private Sub cmdR2C_Click()
    ģ��1.�б����б任 (True)
    Unload frmCR
End Sub
