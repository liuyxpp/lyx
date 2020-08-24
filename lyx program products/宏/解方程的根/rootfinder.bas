Attribute VB_Name = "模块1"
Public formula As String
Public Min, Max, esp, MinB, MaxB As Single '根的范围在[min,max],根的精度为esp
Sub 解方程的根()
    With ActiveSheet
        formula = "=" & .Cells(2, 3).Value
        esp = .Cells(2, 4).Value
        Min = .Cells(2, 1).Value
        Max = .Cells(3, 1).Value
    End With
    MinB = Min '保存初始的设置值，以便初始化过程调用
    MaxB = Max '保存初始的设置值，以便初始化过程调用
    Finder     '找根的主要过程
End Sub

Sub Finder() '本过程缺陷：不能解出所在范围的多个根，需进一步完善
Dim y1, y2, y3, Mid As Single
Dim MidIndex As Integer '表示二分法中间植的插入位置
ActiveSheet.Range("B2:B3").Value = formula '利用excel的内置表达式分析功能
y1 = ActiveSheet.Cells(2, 2).Value
y2 = ActiveSheet.Cells(3, 2).Value
If y1 * y2 > 0 Then GoTo NOROOT  '这里的没有根的判别不完善，不能判定偶数个根的存在
MidIndex = 3
MAIN: '二分法过程
Mid = (Min + Max) / 2
ActiveSheet.Rows(MidIndex).Insert
ActiveSheet.Cells(MidIndex, 1).Value = Mid
ActiveSheet.Cells(MidIndex, 2).FillUp
y3 = ActiveSheet.Cells(MidIndex, 2).Value
If Abs(y3) <= esp Then GoTo ROOTFIND
If y1 * y3 < 0 Then
    Max = Mid
    GoTo MAIN
Else
    Min = Mid
    MidIndex = MidIndex + 1
    GoTo MAIN
End If
ROOTFIND:
    ActiveSheet.Cells(MidIndex, 1).Font.Color = vbRed '将根的颜色置为红色
    ActiveSheet.Cells(MidIndex, 2).Font.Color = vbBlue '将根的对应函数值以蓝色表示
    'ActiveSheet.Cells(MidIndex - 1, 3).Value = Abs(ActiveSheet.Cells(MidIndex - 1, 2).Value - y3)
    'ActiveSheet.Cells(MidIndex + 1, 3).Value = Abs(ActiveSheet.Cells(MidIndex + 1, 2).Value - y3)
    Exit Sub
NOROOT:
    MsgBox "在此范围内没有根，请另行输入x的范围"
End Sub

Sub Initial() '程序的初始化过程，要求用户每次计算前先初始化
Dim Formats, n, i
With ActiveSheet
        formula = "=" & .Cells(2, 3).Value
        esp = .Cells(2, 4).Value
        Min = .Cells(2, 1).Value
        Max = .Cells(3, 1).Value
    End With
n = -Log(esp) / Log(10#) 'log是以e为底的
Formats = "0."
For i = 1 To n
    Formats = Formats & "0"
Next
Formats = Formats & "E+00" '求得用户所要求的精度，并设置单元格格式
With ActiveSheet
    .Columns("A").Clear
    .Columns("A").NumberFormat = Formats
    .Columns("B").Clear
    .Columns("B").NumberFormat = Formats
    .Cells(1, 1).Value = "X"
    .Cells(1, 2).Value = "Y"
    .Cells(2, 1).Value = MinB
    .Cells(2, 2).Value = formula
    .Cells(3, 1).Value = MaxB
    .Cells(3, 2).FillDown
End With
End Sub
