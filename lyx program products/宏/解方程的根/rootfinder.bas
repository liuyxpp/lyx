Attribute VB_Name = "ģ��1"
Public formula As String
Public Min, Max, esp, MinB, MaxB As Single '���ķ�Χ��[min,max],���ľ���Ϊesp
Sub �ⷽ�̵ĸ�()
    With ActiveSheet
        formula = "=" & .Cells(2, 3).Value
        esp = .Cells(2, 4).Value
        Min = .Cells(2, 1).Value
        Max = .Cells(3, 1).Value
    End With
    MinB = Min '�����ʼ������ֵ���Ա��ʼ�����̵���
    MaxB = Max '�����ʼ������ֵ���Ա��ʼ�����̵���
    Finder     '�Ҹ�����Ҫ����
End Sub

Sub Finder() '������ȱ�ݣ����ܽ�����ڷ�Χ�Ķ���������һ������
Dim y1, y2, y3, Mid As Single
Dim MidIndex As Integer '��ʾ���ַ��м�ֲ�Ĳ���λ��
ActiveSheet.Range("B2:B3").Value = formula '����excel�����ñ��ʽ��������
y1 = ActiveSheet.Cells(2, 2).Value
y2 = ActiveSheet.Cells(3, 2).Value
If y1 * y2 > 0 Then GoTo NOROOT  '�����û�и����б����ƣ������ж�ż�������Ĵ���
MidIndex = 3
MAIN: '���ַ�����
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
    ActiveSheet.Cells(MidIndex, 1).Font.Color = vbRed '��������ɫ��Ϊ��ɫ
    ActiveSheet.Cells(MidIndex, 2).Font.Color = vbBlue '�����Ķ�Ӧ����ֵ����ɫ��ʾ
    'ActiveSheet.Cells(MidIndex - 1, 3).Value = Abs(ActiveSheet.Cells(MidIndex - 1, 2).Value - y3)
    'ActiveSheet.Cells(MidIndex + 1, 3).Value = Abs(ActiveSheet.Cells(MidIndex + 1, 2).Value - y3)
    Exit Sub
NOROOT:
    MsgBox "�ڴ˷�Χ��û�и�������������x�ķ�Χ"
End Sub

Sub Initial() '����ĳ�ʼ�����̣�Ҫ���û�ÿ�μ���ǰ�ȳ�ʼ��
Dim Formats, n, i
With ActiveSheet
        formula = "=" & .Cells(2, 3).Value
        esp = .Cells(2, 4).Value
        Min = .Cells(2, 1).Value
        Max = .Cells(3, 1).Value
    End With
n = -Log(esp) / Log(10#) 'log����eΪ�׵�
Formats = "0."
For i = 1 To n
    Formats = Formats & "0"
Next
Formats = Formats & "E+00" '����û���Ҫ��ľ��ȣ������õ�Ԫ���ʽ
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
