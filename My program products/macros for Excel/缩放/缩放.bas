Attribute VB_Name = "模块1"
Option Explicit
Public Xmin As Double
Public Xmax As Double
Public Ymin As Double
Public Ymax As Double
Public Xgridchk As Boolean
Public Ygridchk As Boolean

Sub 缩放()
    Load frmRange
   
    frmRange.Xgrid.Value = True
    frmRange.Ygrid.Value = True
    frmRange.cmbXmin.Text = ActiveChart.Axes(xlCategory).MinimumScale
    frmRange.cmbXmax.Text = ActiveChart.Axes(xlCategory).MaximumScale
    frmRange.cmbYmin.Text = ActiveChart.Axes(xlValue).MinimumScale
    frmRange.cmbYmax.Text = ActiveChart.Axes(xlValue).MaximumScale
    frmRange.Show
End Sub

Sub 缩放1()
Attribute 缩放1.VB_Description = "lyx 记录的宏 2002-9-12"
Attribute 缩放1.VB_ProcData.VB_Invoke_Func = " \n14"
'
' 缩放 Macro
' lyx 记录的宏 2002-9-12
'
'
    ActiveChart.ChartArea.Select
    ActiveChart.Axes(xlCategory).Select
    With ActiveChart.Axes(xlCategory)
        .MinimumScale = Xmin
        .MaximumScale = Xmax
        .MajorUnit = (Xmax - Xmin) / 5
        .MinorUnit = (Xmax - Xmin) / 50
        .Crosses = xlCustom
        .CrossesAt = Xmin
        .ReversePlotOrder = False
        .ScaleType = xlLinear
        .DisplayUnit = xlNone
    End With
    ActiveChart.ChartArea.Select
    ActiveChart.Axes(xlValue).Select
    With ActiveChart.Axes(xlValue)
        .MinimumScale = Ymin
        .MaximumScale = Ymax
        .MinorUnit = (Ymax - Ymin) / 50
        .MajorUnit = (Ymax - Ymin) / 5
        .Crosses = xlCustom
        .CrossesAt = Ymin
        .ReversePlotOrder = False
        .ScaleType = xlLinear
        .DisplayUnit = xlNone
    End With
    
    ActiveChart.PlotArea.Select
    With ActiveChart.Axes(xlCategory)
        .HasMajorGridlines = True
        .HasMinorGridlines = Xgridchk
    End With
    With ActiveChart.Axes(xlValue)
        .HasMajorGridlines = True
        .HasMinorGridlines = Ygridchk
    End With
End Sub
    
    


