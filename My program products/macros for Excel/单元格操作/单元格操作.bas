Attribute VB_Name = "ģ��1"
Sub ��ת��Ԫ��()
Dim v, Counter
Dim vs()
Counter = 0
For Each v In Selection.Cells
    Counter = Counter + 1
Next
Counter = Counter - 1
ReDim vs(Counter)
For Each v In Selection.Cells
    vs(Counter) = v.Value
    Counter = Counter - 1
Next
Counter = 0
For Each v In Selection.Cells
    v.Value = vs(Counter)
    Counter = Counter + 1
Next
End Sub
Sub ���б任()
    frmCR.Show
End Sub
Sub �б����б任(flag As Boolean)
Dim mysel
Set mysel = Selection.Cells
If flag Then
    �е��� (mysel)
Else
    �е��� (mysel)
End If
End Sub
Sub �е���(ByVal mysel)
Dim v, fg
Dim firstC, firstR
firstC = mysel.Column
firstR = mysel.Row
fg = False
ActiveSheet.Cells(firstR, firstC).Activate
For Each v In mysel
    ActiveSheet.Cells(firstR, firstC).Value = v.Value
    If fg Then v.Clear
    firstC = firstC + 1
    fg = True
Next
End Sub
Sub �е���(ByVal mysel)
Dim v, fg
Dim firstC, firstR
firstC = mysel.Column
firstR = mysel.Row
fg = False
ActiveSheet.Cells(firstR, firstC).Activate
For Each v In mysel
    ActiveSheet.Cells(firstR, firstC).Value = v.Value
    If fg Then v.Clear
    firstR = firstR + 1
    fg = True
Next
End Sub
