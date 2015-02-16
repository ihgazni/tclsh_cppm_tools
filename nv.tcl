#package require base64
#package require sha1

package require http
package require tls
package provide nv 0.1

http::register https 443 ::tls::socket
# http::register https 443 [list ::tls::socket -ssl3 1]
# http::register https 443 [list ::tls::socket -request 0]
namespace eval nv {
    variable timeout 60000
}

proc nv::gen_cookie_from_resp {meta} {
    set cookies [list]
    foreach {name value} $meta {
        if { $name eq "set-cookie" } {
            lappend cookies [lindex [split $value {;}] 0]
        } elseif { $name eq  "Set-Cookie" } {
            lappend cookies [lindex [split $value {;}] 0]
        }
    }
    set ck [list [join $cookies {; }]]
    return $ck
}

proc nv::gen_cookie_kv_pairs { cookie } {
    regexp {(.*)} $cookie orig kv
    set kv [regsub -all {; } $kv \x01]
    set kv_pairs [split $kv \x01]
    return $kv_pairs
}

proc nv::get_keys_via_value { kv_pairs value } {
    set results {}
    set llen [llength $kv_pairs]
    for {set i 0} { $i < $llen} { incr i } {
        set kv [lindex $kv_pairs $i]
        regexp {(.*)=(.*)} $kv o k v
        set k [string trim $k]
        set v [string trim $v]
        if {[string equal $v $value]} {
            lappend results $k
        }
    }
    return $results
}

proc nv::get_values_via_key { kv_pairs key } {
    set results {}
    set llen [llength $kv_pairs]
    for {set i 0} { $i < $llen} { incr i } {
        set kv [lindex $kv_pairs $i]
        regexp {(.*)=(.*)} $kv o k v
        set k [string trim $k]
        set v [string trim $v]
        if {[string equal $k $key]} {
            lappend results $v
        }
    }
    return $results
}

proc nv::creat_cookie_from_kv_pairs { args } {
    set cookie ""
    set llen [llength $args]
    for { set i 0 } { $i < $llen } { incr i 2 } {
        append cookie [lindex $args $i]
        append cookie "="
        append cookie [lindex $args [expr $i + 1 ] ]
        append cookie "; "
    }
    set cookie [string trimright $cookie " "]
    set cookie [string trimright $cookie ";"]
    return $cookie
}


proc nv::get_uni_header_from_resp { meta header_name } {
    array set opts $meta
    set keys [array names opts]
    foreach key $keys {
        if {[string equal $key $header_name] } {
            return $opts($key)
        }
    }
    return {}
}

proc nv::uri_escape {str} {
    set str [http::formatQuery {*}$str]
    # uppercase all %hex where hex=2 octets
    set str [regsub -all -- {%(\w{2})} $str {%[string toupper \1]}]
    return [subst $str]
}

proc nv::uri_decode {str {old 0}} {
        # http://wiki.tcl.tk/14144
        # rewrite "+" back to space
        # protect \ from quoting another '\'
        if { $old == 1 } {
            set str [string map [list + { } "\\" "\\\\"] $str]
        } else {
            set str [string map [list "\\" "\\\\"] $str]
        }
        # prepare to process all %-escapes
        regsub -all -- {%([A-Fa-f0-9][A-Fa-f0-9])} $str {\\u00\1} str
        # process \u unicode mapped chars
        return [subst -novar -nocommand $str]
}

proc nv::find_header_in_req_headers { req_headers header_name } {
    array set opts $req_headers
    set keys [array names opts]
    foreach key $keys {
        if { [string equal $key $header_name]} {
            return $opts($key)
        }
    }
    return {}    
}

proc nv::remove_header_from_req_headers { req_headers header_name {header_value ""}} {
    set new_req_headers {}
    array set opts $req_headers
    set keys [array names opts]
    foreach key $keys {
        if { [string equal $key $header_name]} {
            if { [string equal $header_value ""] } { 
            } else {
                if { [string equal $header_value $opts($key)] } { 
                } else {
                    lappend new_req_headers $key
                    lappend new_req_headers $opts($key)
                }
            }
        } else {
            lappend new_req_headers $key
            lappend new_req_headers $opts($key)
        }
    }
    return $new_req_headers
}

proc nv::add_header_to_req_headers { req_headers header_name header_value} {
    lappend req_headers $header_name
    lappend req_headers $header_value
    return $req_headers
}

proc nv::gen_req_headers { args } {
    array set opts {
        Accept              {text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8}
        User-Agent          {Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/40.0.2214.93 Safari/537.36}
        Accept-Encoding     {gzip, deflate, sdch}
        Accept-Language     {en-US,en;q=0.5}
        Referer             {}
        Origin              {}
        Cookie              {}
        Host                {}
        Connection          {}
        Content-Type        {}
        Content-Length      {}
        Cache-Control       {}
        X-Requested-With    {}
        UA-CPU              {}
        Pragma              {}
    }
    array set opts $args
    set keys [array names opts]
    set req_headers {}
    foreach key $keys {
        if { $opts($key) == {} } {
        } else {
            lappend req_headers $key
            lappend req_headers $opts($key)
        }
    }
    return $req_headers
}

proc nv::gen_post_body { args } {
    array set opts $args
    set keys [array names opts]
    set post_body ""
    foreach key $keys {
        append post_body $key 
        append post_body " "
        append post_body $opts($key)
        append post_body " "
    }
    set len [string length $post_body]
    set post_body [string range $post_body 0 [expr $len - 1]]
    set post_body [::http::formatQuery {*}$post_body]
    return $post_body
}

proc nv::patch_non_zlib { req_headers } {
    set req_headers [nv::remove_header_from_req_headers $req_headers Accept-Encoding]
    set req_headers [nv::add_header_to_req_headers $req_headers Accept-Encoding {}]
    return $req_headers
}

# 与Connetion: keep-alive配合使用的还有下面参数,不过一般是SERVER端的参数
# Keep-Alive: timeout=5, max=100
# timeout：过期时间5秒（对应httpd.conf里的参数是：KeepAliveTimeout），max是最多一百次请求，强制断掉连接
# 就是在timeout时间内又有新的连接过来，同时max会自动减1，直到为0，强制断掉

proc nv::req { url  args } {
    array set opts {
        -method "GET"
        -headers {}
        -post_body {}
        -keepalive 1
        -explict_keepalive 1
    }
    array set opts $args
    set headers [nv::remove_header_from_req_headers $opts(-headers) Connection]
    if {($opts(-keepalive) == 1) && ($opts(-explict_keepalive)==1) } {
        set headers [nv::add_header_to_req_headers $opts(-headers) Connection keep-alive]
    } elseif { ($opts(-keepalive) == 1) && ($opts(-explict_keepalive)==0)} {
    } elseif { ($opts(-keepalive) == 0) && ($opts(-explict_keepalive)==1)} {
        set headers [nv::add_header_to_req_headers  $opts(-headers) Connection close]
    } else {
    }
    if { [string equal $opts(-method) "POST"] } {
        set tok [http::geturl $url -headers $opts(-headers) -query $opts(-post_body) -method POST -keepalive $opts(-keepalive)]
    } else { 
        set tok [http::geturl $url -headers $opts(-headers) -method GET -keepalive $opts(-keepalive)]
    }
    set tok_meta [http::meta $tok]
    puts $tok_meta
    set tok_data [http::data $tok]
    set resp_close [nv::get_uni_header_from_resp  $tok_meta Connection]
    set resp {}
    lappend resp meta 
    lappend resp $tok_meta
    lappend resp data 
    lappend resp $tok_data
    lappend resp 
    if { $opts(-keepalive) == 0 } {
        http::reset $tok
        http::cleanup $tok
        lappend resp closed
        lappend resp 11
    } elseif { [string equal $resp_close close] } {
        http::reset $tok
        http::cleanup $tok
        lappend resp closed
        lappend resp 10
    } else {
        lappend resp closed
        lappend resp 0
    }
    lappend resp tok
    lappend resp $tok
    return $resp
}

proc nv::teardown { tok } {
    http::reset $tok
    http::cleanup $tok
}

# ########################## #

proc nv::prepend_herf { href scheme host {parent ""} } {
    if { [regexp {"^/"} $herf] } {
        return "$scheme://$host$herf"
    } else {
        return "$scheme://$host/$parent$herf"
    }
}

# ######################### #
#step 1
# set url_1 https://10.64.18.200
# set req_headers [nv::gen_req_headers]
# set resp [nv::req $url_1 -headers $req_headers -keepalive 0]
#when using <-keepalive 1 >the CPPM server returned  <Keep-Alive: timeout=4,max=493>,  when server timeout < 10  the tclsh keepalive feature cant work well
# array set resp_arr $resp


#step 2 http://www.baidu.com
# set url_2 [nv::get_uni_header_from_resp $resp_arr(meta) Location]
# set resp [nv::req $url_2 -keepalive 0 ]
# array set resp_arr $resp

#step 3
# set req_cookie [nv::gen_cookie_from_resp $resp_arr(meta)]
# set req_headers [nv::gen_req_headers Accept-Encoding {} Cookie $req_cookie ]
# set url_3 https://10.64.18.200/tips/tipsLogin.action
# set resp [nv::req $url_3 -headers $req_headers -keepalive 0]



#step 4
# set url_4 https://10.64.18.200/tips/tipsLoginSubmit.action
# username=admin&password=eTIPS123
#step 5
# set url_5 https://10.64.18.200/tips/tipsContent.action




#http::geturl $url -headers $header -query $query -method $method -timeout $oauth::timeout
#http::geturl $url -headers $header -method $method -timeout $oauth::timeout
#use keepalive
#step1
# set header1 "$headerAE $headerAL $headerC"
# set tok1 [::http::geturl $CDEmgmt::mgmtIP_url  -headers $header1 -keepalive 1]
# set tok1data [::http::data $tok1]
# set tok1meta [::http::meta $tok1]
# set CDEmgmt::mgmtHome_url [CDEmgmt::getLocation $tok1meta]
# ......
# http::reset $tok6
# http::cleanup $tok6
