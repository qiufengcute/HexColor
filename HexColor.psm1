# HexColor PowerShell Module
# 版本: 1.0.0

class HexColor {
    [string]$Version = "1.0.0"
    [string]$Color

    # 构造函数
    HexColor([string]$color) {
        if ($color -is [int]) {
            throw "无效的颜色格式: $color. 颜色需要16进制字符串"
        }
        
        $normalizedColor = $color.ToUpper()
        if (-not $normalizedColor.StartsWith('#')) {
            $normalizedColor = '#' + $normalizedColor
        }
        
        $this._ValidateColor($normalizedColor)
        $this.Color = $this._NormalizeColor($normalizedColor)
    }

    # 私有方法 - 验证颜色
    hidden [void] _ValidateColor([string]$color) {
        $length = $color.Length - 1
        
        if ($length -notin @(3, 4, 6, 8)) {
            throw "无效的颜色格式: $color. 支持: #RGB, #RRGGBB, #RGBA, #RRGGBBAA"
        }
        
        $hexPart = $color.Substring(1)
        if ($hexPart -notmatch '^[0-9A-F]+$') {
            throw "颜色包含非法字符: $color. 只允许0-9, A-F字符"
        }
    }

    # 私有方法 - 标准化颜色
    hidden [string] _NormalizeColor([string]$color) {
        $hexPart = $color.Substring(1)
        
        if ($hexPart.Length -eq 3) {
            return "#$($hexPart[0])$($hexPart[0])$($hexPart[1])$($hexPart[1])$($hexPart[2])$($hexPart[2])"
        }
        elseif ($hexPart.Length -eq 4) {
            return "#$($hexPart[0])$($hexPart[0])$($hexPart[1])$($hexPart[1])$($hexPart[2])$($hexPart[2])$($hexPart[3])$($hexPart[3])"
        }
        
        return $color
    }

    # 1位转2位颜色
    hidden [string] _1to2([string]$color) {
        if ($color.Length -eq 1) {
            return "0$color"
        }
        return $color
    }

    # 颜色相加
    hidden [string] _PassageAdd([string]$color1, [string]$color2) {
        $val1 = [Convert]::ToInt32($color1, 16)
        $val2 = [Convert]::ToInt32($color2, 16)
        $result = [Math]::Min([Math]::Round(($val1 + $val2) / 2), 255)
        return $this._1to2([Convert]::ToString($result, 16).ToUpper())
    }

    # 颜色相减
    hidden [string] _PassageSub([string]$color1, [string]$color2) {
        $val1 = [Convert]::ToInt32($color1, 16)
        $val2 = [Convert]::ToInt32($color2, 16)
        $result = [Math]::Max($val1 - $val2, 0)
        return $this._1to2([Convert]::ToString($result, 16).ToUpper())
    }

    # RGB转RGBA
    hidden [string] _Rgb2Rgba([string]$rgbColor) {
        if ($rgbColor.Length -eq 7) {
            return "$rgbColor" + "FF"
        }
        return $rgbColor
    }

    # 重写ToString
    [string] ToString() {
        return $this.Color
    }

    # 转换为int
    [int] ToInt() {
        return [Convert]::ToInt32($this.Color.Substring(1), 16)
    }

    # 转换为float
    [double] ToDouble() {
        return [double]$this.ToInt()
    }

    # 重写Equals
    [bool] Equals([object]$other) {
        if ($other -isnot [HexColor]) {
            return $false
        }
        return $this._Rgb2Rgba($this.Color) -eq $this._Rgb2Rgba($other.Color)
    }

    # 重载加法运算符
    static [HexColor] op_Addition([HexColor]$left, [HexColor]$right) {
        if ($left.Color.Length -eq 9 -or $right.Color.Length -eq 9) {
            $leftRgba = $left._Rgb2Rgba($left.Color)
            $rightRgba = $right._Rgb2Rgba($right.Color)
            
            $result = "#" + 
                     $left._PassageAdd($leftRgba.Substring(1, 2), $rightRgba.Substring(1, 2)) +
                     $left._PassageAdd($leftRgba.Substring(3, 2), $rightRgba.Substring(3, 2)) +
                     $left._PassageAdd($leftRgba.Substring(5, 2), $rightRgba.Substring(5, 2)) +
                     $left._PassageAdd($leftRgba.Substring(7, 2), $rightRgba.Substring(7, 2))
            
            return [HexColor]::new($result)
        }
        
        $result = "#" + 
                 $left._PassageAdd($left.Color.Substring(1, 2), $right.Color.Substring(1, 2)) +
                 $left._PassageAdd($left.Color.Substring(3, 2), $right.Color.Substring(3, 2)) +
                 $left._PassageAdd($left.Color.Substring(5, 2), $right.Color.Substring(5, 2))
        
        return [HexColor]::new($result)
    }

    # 重载减法运算符
    static [HexColor] op_Subtraction([HexColor]$left, [HexColor]$right) {
        if ($left.Color.Length -eq 9 -or $right.Color.Length -eq 9) {
            $leftRgba = $left._Rgb2Rgba($left.Color)
            $rightRgba = $right._Rgb2Rgba($right.Color)
            
            $result = "#" + 
                     $left._PassageSub($leftRgba.Substring(1, 2), $rightRgba.Substring(1, 2)) +
                     $left._PassageSub($leftRgba.Substring(3, 2), $rightRgba.Substring(3, 2)) +
                     $left._PassageSub($leftRgba.Substring(5, 2), $rightRgba.Substring(5, 2)) +
                     $left._PassageSub($leftRgba.Substring(7, 2), $rightRgba.Substring(7, 2))
            
            return [HexColor]::new($result)
        }
        
        $result = "#" + 
                 $left._PassageSub($left.Color.Substring(1, 2), $right.Color.Substring(1, 2)) +
                 $left._PassageSub($left.Color.Substring(3, 2), $right.Color.Substring(3, 2)) +
                 $left._PassageSub($left.Color.Substring(5, 2), $right.Color.Substring(5, 2))
        
        return [HexColor]::new($result)
    }

    # 属性 - RGB元组
    [object[]] RGB() {
        $hexColor = $this.Color.Substring(1)
        return @(
            [Convert]::ToInt32($hexColor.Substring(0, 2), 16),
            [Convert]::ToInt32($hexColor.Substring(2, 2), 16),
            [Convert]::ToInt32($hexColor.Substring(4, 2), 16)
        )
    }

    # 属性 - RGBA元组
    [object[]] RGBA() {
        $hexColor = $this.Color.Substring(1)
        if ($hexColor.Length -eq 8) {
            return @(
                [Convert]::ToInt32($hexColor.Substring(0, 2), 16),
                [Convert]::ToInt32($hexColor.Substring(2, 2), 16),
                [Convert]::ToInt32($hexColor.Substring(4, 2), 16),
                [Convert]::ToInt32($hexColor.Substring(6, 2), 16)
            )
        }
        else {
            return @(
                [Convert]::ToInt32($hexColor.Substring(0, 2), 16),
                [Convert]::ToInt32($hexColor.Substring(2, 2), 16),
                [Convert]::ToInt32($hexColor.Substring(4, 2), 16),
                255
            )
        }
    }

    # 属性 - 红色分量
    [int] Red() {
        return [Convert]::ToInt32($this.Color.Substring(1, 2), 16)
    }

    # 属性 - 绿色分量
    [int] Green() {
        return [Convert]::ToInt32($this.Color.Substring(3, 2), 16)
    }

    # 属性 - 蓝色分量
    [int] Blue() {
        return [Convert]::ToInt32($this.Color.Substring(5, 2), 16)
    }

    # 属性 - Alpha分量
    [int] Alpha() {
        if ($this.Color.Length -eq 9) {
            return [Convert]::ToInt32($this.Color.Substring(7, 2), 16)
        }
        return 255
    }

    # 修改红色分量
    [void] EditRed([string]$hexRed) {
        $hexRed = $hexRed.ToUpper()
        if ($hexRed.Length -ne 2 -or $hexRed -notmatch '^[0-9A-F]{2}$') {
            throw "红色分量必须是2位16进制数"
        }
        $this.Color = "#$hexRed" + $this.Color.Substring(3)
    }

    # 修改绿色分量
    [void] EditGreen([string]$hexGreen) {
        $hexGreen = $hexGreen.ToUpper()
        if ($hexGreen.Length -ne 2 -or $hexGreen -notmatch '^[0-9A-F]{2}$') {
            throw "绿色分量必须是2位16进制数"
        }
        $this.Color = $this.Color.Substring(0, 3) + $hexGreen + $this.Color.Substring(5)
    }

    # 修改蓝色分量
    [void] EditBlue([string]$hexBlue) {
        $hexBlue = $hexBlue.ToUpper()
        if ($hexBlue.Length -ne 2 -or $hexBlue -notmatch '^[0-9A-F]{2}$') {
            throw "蓝色分量必须是2位16进制数"
        }
        $this.Color = $this.Color.Substring(0, 5) + $hexBlue + $this.Color.Substring(7)
    }

    # 修改Alpha分量
    [void] EditAlpha([string]$hexAlpha) {
        $hexAlpha = $hexAlpha.ToUpper()
        if ($hexAlpha.Length -ne 2 -or $hexAlpha -notmatch '^[0-9A-F]{2}$') {
            throw "Alpha透明度分量必须是2位16进制数"
        }
        if ($this.Color.Length -eq 9) {
            $this.Color = $this.Color.Substring(0, 7) + $hexAlpha
        }
        else {
            $this.Color = $this.Color + $hexAlpha
        }
    }
}
