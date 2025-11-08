# 版本信息
$version = "1.0.0"

# 加载Windows Forms
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# 必须在创建任何控件之前调用
[System.Windows.Forms.Application]::EnableVisualStyles()
[System.Windows.Forms.Application]::SetCompatibleTextRenderingDefault($false)

# 设置 DPI 感知模式（需要 Windows 10 1703 或更高版本）
# 使用 try-catch 避免重复定义错误
try {
    Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;

public class DpiHelper
{
    [DllImport("user32.dll")]
    public static extern bool SetProcessDPIAware();
    
    [DllImport("SHCore.dll")]
    public static extern int SetProcessDpiAwareness(int value);
}
"@ -ErrorAction SilentlyContinue
} catch {
    # 类型已存在，忽略错误
}

try {
    # 尝试使用最新的 DPI 感知 API (Per-Monitor V2)
    $null = [DpiHelper]::SetProcessDpiAwareness(2) 
} catch {
    try {
        # 降级到基本的 DPI 感知
        $null = [DpiHelper]::SetProcessDPIAware()
    } catch {
        # 如果都失败了，至少应用程序仍可运行
    }
}

# 创建主窗口
$form = New-Object System.Windows.Forms.Form
$form.AutoScaleMode = [System.Windows.Forms.AutoScaleMode]::Dpi
$form.Text = "Magnet Tracker Appender v$version"
$form.Size = New-Object System.Drawing.Size(800, 550)
$form.StartPosition = "CenterScreen"
$form.Font = New-Object System.Drawing.Font("Microsoft YaHei UI", 9, [System.Drawing.FontStyle]::Regular)
$form.MinimumSize = New-Object System.Drawing.Size(800, 550)

# 输入Magnet链接的标签
$labelInput = New-Object System.Windows.Forms.Label
$labelInput.Text = "输入Magnet链接:"
$labelInput.Location = New-Object System.Drawing.Point(20, 20)
$labelInput.AutoSize = $true
$form.Controls.Add($labelInput)

# 输入Magnet链接的文本框
$textBoxInput = New-Object System.Windows.Forms.TextBox
$textBoxInput.Location = New-Object System.Drawing.Point(20, 50)
$textBoxInput.Size = New-Object System.Drawing.Size(740, 30)
$textBoxInput.Anchor = [System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Left -bor [System.Windows.Forms.AnchorStyles]::Right
$form.Controls.Add($textBoxInput)

# 加速获取复选框
$checkBoxAccelerate = New-Object System.Windows.Forms.CheckBox
$checkBoxAccelerate.Text = "加速获取列表"
$checkBoxAccelerate.Location = New-Object System.Drawing.Point(20, 95)
$checkBoxAccelerate.AutoSize = $true
$checkBoxAccelerate.Checked = $true
$form.Controls.Add($checkBoxAccelerate)

# 加速域名下拉框
$comboBoxProxy = New-Object System.Windows.Forms.ComboBox
$comboBoxProxy.Location = New-Object System.Drawing.Point(240, 93)
$comboBoxProxy.Size = New-Object System.Drawing.Size(300, 25)
$comboBoxProxy.DropDownStyle = [System.Windows.Forms.ComboBoxStyle]::DropDownList
$comboBoxProxy.Items.AddRange(@(
    "https://ghfast.top/",
    "https://gh.llkk.cc/",
    "https://gh.qninq.cn/",
    "https://ghproxy.cfd/",
    "自定义..."
))
$comboBoxProxy.SelectedIndex = 0
$form.Controls.Add($comboBoxProxy)

# 自定义加速地址标签
$labelCustomProxy = New-Object System.Windows.Forms.Label
$labelCustomProxy.Text = "自定义:"
$labelCustomProxy.Location = New-Object System.Drawing.Point(20, 140)
$labelCustomProxy.AutoSize = $true
$labelCustomProxy.Visible = $false
$form.Controls.Add($labelCustomProxy)

# 自定义加速地址文本框
$textBoxCustomProxy = New-Object System.Windows.Forms.TextBox
$textBoxCustomProxy.Location = New-Object System.Drawing.Point(120, 140)
$textBoxCustomProxy.Size = New-Object System.Drawing.Size(630, 25)
$textBoxCustomProxy.Visible = $false
$textBoxCustomProxy.Anchor = [System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Left -bor [System.Windows.Forms.AnchorStyles]::Right
$form.Controls.Add($textBoxCustomProxy)

# 下拉框选择改变事件
$comboBoxProxy.Add_SelectedIndexChanged({
    if ($comboBoxProxy.SelectedItem -eq "自定义...") {
        $labelCustomProxy.Visible = $true
        $textBoxCustomProxy.Visible = $true
    } else {
        $labelCustomProxy.Visible = $false
        $textBoxCustomProxy.Visible = $false
    }
})

# 复选框状态改变事件
$checkBoxAccelerate.Add_CheckedChanged({
    if ($checkBoxAccelerate.Checked) {
        $comboBoxProxy.Enabled = $true
        if ($comboBoxProxy.SelectedItem -eq "自定义...") {
            $labelCustomProxy.Visible = $true
            $textBoxCustomProxy.Visible = $true
        }
    } else {
        $comboBoxProxy.Enabled = $false
        $labelCustomProxy.Visible = $false
        $textBoxCustomProxy.Visible = $false
    }
})

# 输出Magnet链接的标签
$labelOutput = New-Object System.Windows.Forms.Label
$labelOutput.Text = "输出Magnet链接:"
$labelOutput.Location = New-Object System.Drawing.Point(20, 190)
$labelOutput.AutoSize = $true
$form.Controls.Add($labelOutput)

# 输出Magnet链接的文本框
$textBoxOutput = New-Object System.Windows.Forms.TextBox
$textBoxOutput.Location = New-Object System.Drawing.Point(20, 220)
$textBoxOutput.Size = New-Object System.Drawing.Size(740, 155)
$textBoxOutput.Multiline = $true
$textBoxOutput.ScrollBars = "Vertical"
$textBoxOutput.ReadOnly = $true
$textBoxOutput.Anchor = [System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Left -bor [System.Windows.Forms.AnchorStyles]::Right
$form.Controls.Add($textBoxOutput)

# 添加Tracker按钮
$button = New-Object System.Windows.Forms.Button
$button.Text = "添加Tracker"
$button.Location = New-Object System.Drawing.Point(20, 400)
$button.Size = New-Object System.Drawing.Size(140, 40)
$button.Anchor = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Left
$form.Controls.Add($button)

# 复制结果按钮
$buttonCopy = New-Object System.Windows.Forms.Button
$buttonCopy.Text = "复制结果"
$buttonCopy.Location = New-Object System.Drawing.Point(180, 400)
$buttonCopy.Size = New-Object System.Drawing.Size(140, 40)
$buttonCopy.Anchor = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Left
$form.Controls.Add($buttonCopy)

# 按钮点击事件
$button.Add_Click({
    $magnet = $textBoxInput.Text.Trim()
    if ($magnet -match '^magnet:\?') {
        # 保存原始按钮文本并设置加载状态
        $originalButtonText = $button.Text
        $button.Text = "加载中..."
        $button.Enabled = $false
        $buttonCopy.Enabled = $false
        $form.Cursor = [System.Windows.Forms.Cursors]::WaitCursor
        $form.Refresh()
        
        # 下载tracker列表
        $trackerUrl = "https://raw.githubusercontent.com/ngosang/trackerslist/refs/heads/master/trackers_best_ip.txt"
        
        # 如果启用加速获取，在URL前添加加速域名
        if ($checkBoxAccelerate.Checked) {
            if ($comboBoxProxy.SelectedItem -eq "自定义...") {
                # 使用自定义地址
                $customProxy = $textBoxCustomProxy.Text.Trim()
                if ($customProxy -ne "") {
                    # 确保地址以 / 结尾
                    if (-not $customProxy.EndsWith("/")) {
                        $customProxy += "/"
                    }
                    $trackerUrl = $customProxy + $trackerUrl
                } else {
                    # 恢复按钮状态
                    $button.Text = $originalButtonText
                    $button.Enabled = $true
                    $buttonCopy.Enabled = $true
                    $form.Cursor = [System.Windows.Forms.Cursors]::Default
                    [System.Windows.Forms.MessageBox]::Show("请输入自定义加速地址。", "提示")
                    return
                }
            } else {
                # 使用预设的加速域名
                $proxyDomain = $comboBoxProxy.SelectedItem
                $trackerUrl = $proxyDomain + $trackerUrl
            }
        }
        
        try {
            $response = Invoke-WebRequest -Uri $trackerUrl -UseBasicParsing
            $trackers = $response.Content -split "`n" | Where-Object { $_ -match '^[a-z]+://' } | ForEach-Object { "&tr=" + [uri]::EscapeDataString($_.Trim()) }
            # 构建新的Magnet链接
            $newMagnet = $magnet + ($trackers -join "")
            $textBoxOutput.Text = $newMagnet
        } catch {
            [System.Windows.Forms.MessageBox]::Show("下载tracker失败: " + $_.Exception.Message, "错误")
        } finally {
            # 恢复按钮状态
            $button.Text = $originalButtonText
            $button.Enabled = $true
            $buttonCopy.Enabled = $true
            $form.Cursor = [System.Windows.Forms.Cursors]::Default
        }
    } else {
        [System.Windows.Forms.MessageBox]::Show("请输入有效的Magnet链接。", "错误")
    }
})

# 复制按钮点击事件
$buttonCopy.Add_Click({
    if ($textBoxOutput.Text -ne "") {
        [System.Windows.Forms.Clipboard]::SetText($textBoxOutput.Text)
        [System.Windows.Forms.MessageBox]::Show("结果已复制到剪贴板。", "成功")
    } else {
        [System.Windows.Forms.MessageBox]::Show("没有结果可复制。", "提示")
    }
})

# 显示窗口
$null = $form.ShowDialog()
