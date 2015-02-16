proc paint_str { str color } {
#colorful the string str
    set default  "\033\[0\;m"
    set grey "\033\[1\;30\;40m"
    set red "\033\[1\;31\;40m"
    set green "\033\[1\;32\;40m"
    set yellow "\033\[1\;33\;40m"
    set blue "\033\[1\;34\;40m"
    set purple "\033\[1\;35\;40m"
    set azure "\033\[1\;36\;40m"
    set white "\033\[1\;37\;40m"
    set color [expr $$color]
    set newstr ${color}${str}
    set newstr ${newstr}${default}
    return $newstr
}

proc color_syno { str } {
    regsub -all { } $str "\x07 " str
    set str [paint_str $str purple]
    return $str
}

proc color_desc { str } {
    regsub -all { } $str "\x07 " str
    set str [paint_str $str yellow]
    return $str
}
