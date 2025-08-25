from typing import Tuple

__version__ = "1.0.0"

class HexColor:
    """一个处理16进制颜色的类,支持多种格式和操作"""
    
    def __init__(self, color: str):
        """
        初始化HexColor对象
        
        Args:
            color: 颜色值,需要是字符串16进制
                  支持: #RGB, #RRGGBB, #RGBA, #RRGGBBAA
        """
        if isinstance(color, int):
            raise ValueError(
                f"无效的颜色格式: {color}. "
                f"颜色需要16进制"
            )
        
        color = color.upper()
        if not color.startswith('#'):
            color = '#' + color
        
        self._validate_color(color)
        self.color = self._normalize_color(color)

    def _1to2(self, color: str) -> str:
        """将1位颜色转换为2位颜色"""
        if len(color) == 1:
            return f"0{color}"
        return color

    def _passage_add(self, color1: str, color2: str) -> str:
        """颜色相加"""
        return self._1to2(hex(min(round((int(color1, 16) + int(color2, 16)) / 2), 255))[2:].upper())
    
    def _passage_sub(self, color1: str, color2: str) -> str:
        """颜色相减"""
        return self._1to2(hex(max(int(color1, 16) - int(color2, 16), 0))[2:].upper())

    def _rgb2rgba(self, rgb_color) -> str:
        """将RGB颜色转换为RGBA颜色"""
        if len(rgb_color) == 7:
            return f"{rgb_color}FF"
        return rgb_color

    def _validate_color(self, color: str):
        """验证颜色格式"""
        length = len(color) - 1  # 去掉#号后的长度
        
        if length not in [3, 4, 6, 8]:
            raise ValueError(
                f"无效的颜色格式: {color}. "
                f"支持: #RGB, #RRGGBB, #RGBA, #RRGGBBAA"
            )
        
        hex_part = color[1:]
        if not all(c in '0123456789ABCDEF' for c in hex_part):
            raise ValueError(
                f"颜色包含非法字符: {color}. "
                f"只允许0-9, A-F字符"
            )
    
    def _normalize_color(self, color: str) -> str:
        """标准化颜色格式为6位或8位"""
        hex_part = color[1:]
        
        if len(hex_part) == 3:
            return f"#{hex_part[0]*2}{hex_part[1]*2}{hex_part[2]*2}"
        elif len(hex_part) == 4:
            return f"#{hex_part[0]*2}{hex_part[1]*2}{hex_part[2]*2}{hex_part[3]*2}"
        
        return color
    
    def __str__(self) -> str:
        return self.color
    
    def __int__(self) -> int:
        return int(self.color[1:], 16)
    
    def __float__(self) -> float:
        return float(int(self))
    
    def __repr__(self) -> str:
        return f"HexColor('{self.color}')"
    
    def __hash__(self):
        return hash(self._rgb2rgba(self.color))

    def __add__(self, other: 'HexColor') -> 'HexColor':
        if not isinstance(other, HexColor):
            return NotImplemented
        if len(self.color) == 9 or len(other.color) == 9:
            return HexColor(f"#{self._passage_add(self._rgb2rgba(self.color)[1:3], self._rgb2rgba(other.color)[1:3])}"
                            f"{self._passage_add(self._rgb2rgba(self.color)[3:5], self._rgb2rgba(other.color)[3:5])}"
                            f"{self._passage_add(self._rgb2rgba(self.color)[5:7], self._rgb2rgba(other.color)[5:7])}"
                            f"{self._passage_add(self._rgb2rgba(self.color)[7:9], self._rgb2rgba(other.color)[7:9])}")
        return HexColor(f"#{self._passage_add(self.color[1:3], other.color[1:3])}"
                        f"{self._passage_add(self.color[3:5], other.color[3:5])}"
                        f"{self._passage_add(self.color[5:7], other.color[5:7])}")
    
    def __sub__(self, other: 'HexColor') -> 'HexColor':
        if not isinstance(other, HexColor):
            return NotImplemented
        if len(self.color) == 9 or len(other.color) == 9:
            return HexColor(f"#{self._passage_sub(self._rgb2rgba(self.color)[1:3], self._rgb2rgba(other.color)[1:3])}"
                            f"{self._passage_sub(self._rgb2rgba(self.color)[3:5], self._rgb2rgba(other.color)[3:5])}"
                            f"{self._passage_sub(self._rgb2rgba(self.color)[5:7], self._rgb2rgba(other.color)[5:7])}"
                            f"{self._passage_sub(self._rgb2rgba(self.color)[7:9], self._rgb2rgba(other.color)[7:9])}")
        return HexColor(f"#{self._passage_sub(self.color[1:3], other.color[1:3])}"
                        f"{self._passage_sub(self.color[3:5], other.color[3:5])}"
                        f"{self._passage_sub(self.color[5:7], other.color[5:7])}")

    def __eq__(self, other) -> bool:
        if not isinstance(other, HexColor):
            return NotImplemented
        return self._rgb2rgba(self.color) == self._rgb2rgba(other.color)
    
    def __bool__(self) -> bool:
        return True
    
    @property
    def rgb(self) -> Tuple[int, int, int]:
        """转换为RGB元组"""
        hex_color = self.color[1:]
        return (
            int(hex_color[0:2], 16),
            int(hex_color[2:4], 16),
            int(hex_color[4:6], 16)
        )
    
    @property
    def rgba(self) -> Tuple[int, int, int, int]:
        """转换为RGBA元组"""
        hex_color = self.color[1:]
        if len(hex_color) == 8:
            return (
                int(hex_color[0:2], 16),
                int(hex_color[2:4], 16),
                int(hex_color[4:6], 16),
                int(hex_color[6:8], 16)
            )
        else:
            return (
                int(hex_color[0:2], 16),
                int(hex_color[2:4], 16),
                int(hex_color[4:6], 16),
                255
            )
    
    @property
    def red(self) -> int:
        """获取红色分量"""
        return int(self.color[1:3], 16)
    
    @property
    def green(self) -> int:
        """获取绿色分量"""
        return int(self.color[3:5], 16)
    
    @property
    def blue(self) -> int:
        """获取蓝色分量"""
        return int(self.color[5:7], 16)
    
    @property
    def alpha(self) -> int:
        """获取Alpha透明度分量"""
        if len(self.color) == 9:
            return int(self.color[7:9], 16)
        return 255
    
    def edit_red(self, hex_red: str) -> None:
        """修改红色分量"""
        hex_red = hex_red.upper()
        if len(hex_red) != 2 or not all(c in '0123456789ABCDEF' for c in hex_red):
            raise ValueError("红色分量必须是2位16进制数")
        self.color = f"#{hex_red}{self.color[3:]}"

    def edit_green(self, hex_green: str) -> None:
        """修改绿色分量"""
        hex_green = hex_green.upper()
        if len(hex_green) != 2 or not all(c in '0123456789ABCDEF' for c in hex_green):
            raise ValueError("绿色分量必须是2位16进制数")
        self.color = f"{self.color[:3]}{hex_green}{self.color[5:]}"
    
    def edit_blue(self, hex_blue: str) -> None:
        """修改蓝色分量"""
        hex_blue = hex_blue.upper()
        if len(hex_blue) != 2 or not all(c in '0123456789ABCDEF' for c in hex_blue):
            raise ValueError("蓝色分量必须是2位16进制数")
        self.color = f"{self.color[:5]}{hex_blue}{self.color[7:]}"

    def edit_alpha(self, hex_alpha: str) -> None:
        """修改Alpha透明度分量"""
        hex_alpha = hex_alpha.upper()
        if len(hex_alpha) != 2 or not all(c in '0123456789ABCDEF' for c in hex_alpha):
            raise ValueError("Alpha透明度分量必须是2位16进制数")
        if len(self.color) == 9:
            self.color = f"{self.color[:7]}{hex_alpha}"
        else:
            self.color = f"{self.color}{hex_alpha}"
