Attribute VB_Name = "模块1"
Sub 反转单元格()
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
Sub 行列变换()
    frmCR.Show
End Sub
Sub 判别行列变换(flag As Boolean)
Dim mysel
Set mysel = Selection.Cells
If flag Then
    列到行 (mysel)
Else
    行到列 (mysel)
End If
End Sub
Sub 列到行(ByVal mysel)
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
Sub 行到列(ByVal mysel)
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
