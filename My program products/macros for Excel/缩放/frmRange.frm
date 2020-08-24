VERSION 5.00
Begin {C62A69F0-16DC-11CE-9E98-00AA00574A4F} frmRange 
   Caption         =   "边界值"
   ClientHeight    =   2070
   ClientLeft      =   45
   ClientTop       =   435
   ClientWidth     =   3720
   OleObjectBlob   =   "frmRange.frx":0000
   StartUpPosition =   1  '所有者中心
End
Attribute VB_Name = "frmRange"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False

Private Sub cmdCancel_Click()
    End
End Sub

Private Sub cmdOK_Click()
    Dim index As Long
    Dim log As Boolean
    Xmin = cmbXmin.Text
    Xmax = cmbXmax.Text
    Ymin = cmbYmin.Text
    Ymax = cmbYmax.Text
    index = 0: log = False
    While (index < cmbXmin.ListCount) And log = False
        If Xmin = cmbXmin.List(index, 0) Then log = True
        index = index + 1
    Wend
    If log = False Then cmbXmin.AddItem (Xmin)
        
    index = 0: log = False
    While (index < cmbXmax.ListCount) And log = False
        If Xmax = cmbXmax.List(index, 0) Then log = True
        index = index + 1
    Wend
    If log = False Then cmbXmax.AddItem (Xmax)
        
    index = 0: log = False
    While (index < cmbYmin.ListCount) And log = False
        If Ymin = cmbYmin.List(index, 0) Then log = True
        index = index + 1
    Wend
    If log = False Then cmbYmin.AddItem (Ymin)
        
    index = 0: log = False
    While (index < cmbYmax.ListCount) And log = False
        If Ymax = cmbYmax.List(index, 0) Then log = True
        index = index + 1
    Wend
    If log = False Then cmbYmax.AddItem (Ymax)
    Xgridchk = Xgrid.Value
    Ygridchk = Ygrid.Value
    模块1.缩放1
End Sub

