source /usr/local/bin/DLIB/nv.tcl
source /usr/local/bin/DLIB/color.tcl

http::register https 443 [list ::tls::socket -request 0 -ssl2 0 -ssl3 1]

proc cppm::get_role_names { req_cookie scriptSessionId args } {
    array set opts {
        -zlib_support no
        -batchId 36
    }
    array set opts $args
    set req_headers [nv::gen_req_headers Cache-Control {no-cache} Pragma {no-cache} Cookie $req_cookie Referer $cppm::host$cppm::tipsContent Content-Type {text/plain; charset=UTF-8}]
    if { [string equal $opts(-zlib_support) no]} {
        set req_headers [nv::patch_non_zlib $req_headers]
    }
    set req_post_body "callCount=1\nwindowName=c0-e4\nc0-scriptName=localUsers\nc0-methodName=getRoleNames\nc0-id=0\nc0-param0=boolean:true\nbatchId=$opts(-batchId)\ninstanceId=0\npage=%2Ftips%2FtipsContent.action\nscriptSessionId=$scriptSessionId\n"
    set resp [nv::req $cppm::host$cppm::localUsers(getRoleNames) -headers $req_headers -method POST -post_body $req_post_body -keepalive 0]
    array set resp_arr $resp
    if { [regexp {r.handleCallback\(.*\"(.*)\"\)} $resp_arr(data) orig role_names ]} {
    } else {
        # this is beacuse explict Content-Type will fail  under tclsh8.5 + http 2.7.5
        set req_headers [nv::gen_req_headers Cookie $req_cookie Referer $cppm::host$cppm::tipsContent]
        if { [string equal $opts(-zlib_support) no]} {
            set req_headers [nv::patch_non_zlib $req_headers]
        }
        set tok [http::geturl $cppm::host$cppm::__System(generateId) -headers $req_headers -method POST -query $req_post_body -keepalive 0 -type {text/plain; charset=UTF-8}]
        set data [http::data $tok]
        regexp {r.handleCallback.*(\{.*\})\);} $data orig role_names
    }
    set role_names [regsub -all {,} $role_names "\x01"]
    set role_names [regsub -all {\[|\]} $role_names ""]
    set role_names [string trim $role_names]
    set role_names [string trim $role_names \{]
    set role_names [string trim $role_names \}]
    set role_names [split $role_names \x01]
    set kv_list {}
    set vk_list {}
    set llen [llength $role_names]
    for {set i 0} {$i < $llen} {incr i} {
        set kv [lindex $role_names $i]
        set kv [split $kv :]
        set k [lindex $kv 0]
        set v [lindex $kv 1]
        lappend kv_list $k
        lappend vk_list $v
        lappend kv_list $v
        lappend vk_list $k
    }
    set kvvk_list {} 
    lappend kvvk_list $kv_list
    lappend kvvk_list $vk_list
    return $kvvk_list
}

proc cppm::disaply_role_names { kvvk_list } {
    array set kv_arr [lindex $kvvk_list 0]
    array set vk_arr [lindex $kvvk_list 1]
    puts "\033\[1\;32\;40m"
    parray kv_arr
    parray vk_arr
    puts "\033\[0\;m"
}

proc cppm::current_supported_role { req_cookie scriptSessionId args } {
    set kvvk_list [cppm::get_role_names $req_cookie $scriptSessionId {*}$args]
    cppm::disaply_role_names $kvvk_list 
}

proc cppm::role_name_to_id { kvvk_list role_name } {
    set kv_list [lindex $kvvk_list 0]
    array set arr $kv_list 
    set keys [array names arr]
    foreach key $keys {
        set temp_1 $arr($key)
        set temp_1 [regsub -all {\"} $temp_1 ""]
        set temp_1 [regsub -all {[ \-_]+} $temp_1 ""]
        set temp_1 [string tolower $temp_1]
        set temp_2 $role_name
        set temp_2 [regsub -all {\"} $temp_2 ""]
        set temp_2 [regsub -all {[ \-_]+} $temp_2 ""]
        set temp_2 [string tolower $temp_2]
        if { [string equal $temp_1 $temp_2] } {
            return $arr($key)
        } else {
            return ""
        }
    }
}

proc cppm::role_id_to_name { kvvk_list role_id } {
    set kv_list [lindex $kvvk_list 0]
    array set arr $vk_list
    return $arr(role_id)
}

namespace eval cppm {
    variable host https://10.64.18.200
    variable welcome /tips/welcome.action
    variable hrefs
    array set hrefs {
        policy_manager "/tips/tipsLogin.action"
        guest "/guest/guest_index.php"
        onboard "/guest/mdps_index.php"
        insight "/insight"
    }
    variable login_username admin
    variable login_password eTIPS123
    variable tipsLoginSubmit /tips/tipsLoginSubmit.action 
    variable tipsContent /tips/tipsContent.action
    variable tipsLocalUser /tips/tipsLocalUsers.action
    variable tipsAddLocalUser   /tips/tipsAddLocalUser.action
    variable tipsEditLocalUser  /tips/tipsEditLocalUser.action
    variable __System
    array set __System {
        generateId /tips/dwrS/call/plaincall/__System.generateId.dwr
        pageLoaded /tips/dwrS/call/plaincall/__System.pageLoaded.dwr
    }
    variable login
    array set login {
        getPublisherUrl            /tips/dwr/call/plaincall/login.getPublisherUrl.dwr
        getServerModes             /tips/dwr/call/plaincall/login.getServerModes.dwr
        getServerDate              /tips/dwr/call/plaincall/login.getServerDate.dwr
        isSessionValid             /tips/dwr/call/plaincall/login.isSessionValid.dwr
        getloggedInUserInfo        /tips/dwr/call/plaincall/login.getloggedInUserInfo.dwr
        getMenuTree                /tips/dwr/call/plaincall/login.getMenuTree.dwr
        getUserFromSession         /tips/dwr/call/plaincall/login.getUserFromSession.dwr
    }
    variable cliAction
    array set cliAction {
        getStandByPublisherTakeOverStatus    /tips/dwr/call/plaincall/cliAction.getStandByPublisherTakeOverStatus.dwr
    }
    variable licensingInfo
    array set licensingInfo {
        getExpiredAppLicenses    /tips/dwr/call/plaincall/licensingInfo.getExpiredAppLicenses.dwr
    }
    variable tipsMashups
    array set tipsMashups {
        getLocalhostId    /tips/dwr/call/plaincall/tipsMashups.getLocalhostId.dwr
        getConfigBean    /tips/dwr/call/plaincall/tipsMashups.getConfigBean.dwr
        getSystemCPU       /tips/dwr/call/plaincall/tipsMashups.getSystemCPU.dwr
        getRequestTime    /tips/dwr/call/plaincall/tipsMashups.getRequestTime.dwr
    }
    variable fipsParam
    array set fipsParam {
        getFipsEnabled     /tips/dwr/call/plaincall/fipsParam.getFipsEnabled.dwr
    }
    variable summaryPage
    array set summaryPage {
        getAllowedQuickLinks                                  /tips/dwr/call/plaincall/summaryPage.getAllowedQuickLinks.dwr
        filterTableOnServerWithQueryId1                        /tips/dwr/call/plaincall/summaryPage.filterTableOnServerWithQueryId1.dwr
        
    }
    variable dashboard
    array set dashboard {
        getOemName    /tips/dwr/call/plaincall/dashboard.getOemName.dwr
    }
    variable systemMonitor
    array set systemMonitor {
        getServerTimeZoneOffset    /tips/dwr/call/plaincall/systemMonitor.getServerTimeZoneOffset.dwr
    } 
    variable localUsers
    array set localUsers {
        addLocalUser           /tips/dwr/call/plaincall/localUsers.addLocalUser.dwr
        addRuleElement         /tips/dwr/call/plaincall/localUsers.addRuleElement.dwr
        getRoleNames           /tips/dwr/call/plaincall/localUsers.getRoleNames.dwr
        getAllMandatoryTags    /tips/dwr/call/plaincall/localUsers.getAllMandatoryTags.dwr
        deleteConfirmation     /tips/dwr/call/plaincall/localUsers.deleteConfirmation.dwr
        deleteLocalUsers       /tips/dwr/call/plaincall/localUsers.deleteLocalUsers.dwr
        getNewRuleElementList  /tips/dwr/call/plaincall/localUsers.getNewRuleElementList.dwr
        getRuleElementAttrNameMap   /tips/dwr/call/plaincall/localUsers.getRuleElementAttrNameMap.dwr
        filterTable         /tips/dwr/call/plaincall/localUsers.filterTable.dwr
    }
    variable cliAction
    array set cliAction {
        getStandByPublisherTakeOverStatus /tips/dwr/call/plaincall/cliAction.getStandByPublisherTakeOverStatus.dwr
    }
    variable licensingInfo
    array set licensingInfo {
        getExpiredAppLicenses  /tips/dwr/call/plaincall/licensingInfo.getExpiredAppLicenses.dwr
    }
    variable tipsMashups
    array set tipsMashups {
        getLocalhostId         /tips/dwr/call/plaincall/licensingInfo.getLocalhostId.dwr
        getConfigBean         /tips/dwr/call/plaincall/tipsMashups.getConfigBean.dwr 
    }
    variable summaryPage
    array set summaryPage {
        getAllowedQuickLinks /tips/dwr/call/plaincall/summaryPage.getAllowedQuickLinks.dwr
    }
}

proc cppm::tokenify { {number ""} } {
   if { [string match $number ""]} {
       set number [expr 10000000000000000 * [expr rand()] ]
       set number [expr round($number)]
   } else {
       set number [expr round($number)]
   }
   set tokenbuf ""
   set charmap "1234567890abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ*\$"
   set remainder $number
   while {$remainder > 0 } {
       set seq [expr $remainder & 0x3F]
       append tokenbuf [string range $charmap $seq $seq]
       set remainder [expr $remainder / 64]
   }
   return $tokenbuf
}

proc cppm::page_id { } { 
    set page_id ""
    set part_1 [cppm::tokenify [clock milliseconds]]
    append page_id $part_1
    append page_id "-"
    set part_2 [cppm::tokenify]
    append page_id $part_2
}

proc cppm::dwrsess { login_cookie } {
    regexp {DWRSESSIONID=(.*?);} $login_cookie orig dwrsess
    return $dwrsess
} 

proc cppm::scriptSessionId { login_cookie } {
    set dwrsess [cppm::dwrsess $login_cookie]
    set page_id [cppm::page_id]
    return "$dwrsess/$page_id"
}

proc cppm::welcome { args } {
    array set opts {
        -zlib_support no 
    }
    array set opts $args
    set req_headers [nv::gen_req_headers]
    if { [string equal $opts(-zlib_support) no]} {
        set req_headers [nv::patch_non_zlib $req_headers]
    }
    set resp [nv::req $cppm::host -headers $req_headers -keepalive 0]
    array set resp_arr $resp
    set url_2 [nv::get_uni_header_from_resp $resp_arr(meta) Location]
    set resp [nv::req $url_2 -keepalive 0 ]
    array set resp_arr $resp
    set req_cookie [nv::gen_cookie_from_resp $resp_arr(meta) ]
    set req_headers [nv::gen_req_headers Cookie $req_cookie Referer $url_2 ]
    if { [string equal $opts(-zlib_support) no]} {
        set req_headers [nv::patch_non_zlib $req_headers]
    }
    set resp [nv::req $cppm::host$cppm::hrefs(policy_manager) -headers $req_headers -keepalive 0]
    array set resp_arr $resp
    set req_headers [nv::gen_req_headers Cookie $req_cookie Referer $cppm::host$cppm::hrefs(policy_manager) Content-Type {text/plain; charset=UTF-8}]
    if { [string equal $opts(-zlib_support) no]} {
        set req_headers [nv::patch_non_zlib $req_headers]
    }
    return $req_headers
}

proc cppm::generateId { req_headers {instanceId 0} {batchId 0} args } {
    array set opts {
        -zlib_support no
    }
    array set opts $args
    array set arr $req_headers
    set req_cookie $arr(Cookie)
    set req_post_body "callCount=1\nc0-scriptName=__System\nc0-methodName=generateId\nc0-id=0\nbatchId=$batchId\ninstanceId=$instanceId\npage=%2Ftips%2FtipsLogin.action\nscriptSessionId=\nwindowName=\n"
    set resp [nv::req $cppm::host$cppm::__System(generateId) -headers $req_headers -method POST -post_body $req_post_body -keepalive 0]
    array set resp_arr $resp
    if { [regexp {r.handleCallback\(.*\"(.*)\"\)} $resp_arr(data) orig v1 ]} {
    } else {
        set req_headers [nv::gen_req_headers Cookie $req_cookie Referer $cppm::host$cppm::hrefs(policy_manager)]
        if { [string equal $opts(-zlib_support) no]} {
            set req_headers [nv::patch_non_zlib $req_headers]
        }
        set tok [http::geturl $cppm::host$cppm::__System(generateId) -headers $req_headers -method POST -query $req_post_body -keepalive 0 -type {text/plain; charset=UTF-8}]
        set data [http::data $tok]
        regexp {r.handleCallback\(.*\"(.*)\"\)} $data orig v1
    }
    set k1 DWRSESSIONID
    set DWRSESSIONID $v1
    regexp {(.*)=(.*)} [lindex [nv::gen_cookie_kv_pairs $req_cookie] 0] orig k2 v2
    set req_cookie [nv::creat_cookie_from_kv_pairs $k1 $v1 $k2 $v2]
    return $req_cookie
}

proc cppm::pageLoaded {req_cookie {instanceId 0} {batchId 1} args } {
    array set opts {
        -zlib_support no
    }
    array set opts $args
    set req_headers [nv::gen_req_headers Cache-Control no-cache Pragma no-cache  Cookie $req_cookie Referer $cppm::host$cppm::hrefs(policy_manager)]
    if { [string equal $opts(-zlib_support) no]} {
        set req_headers [nv::patch_non_zlib $req_headers]
    }
    set scriptSessionId [cppm::scriptSessionId $req_cookie]
    set req_post_body "callCount=1\nwindowName=\nc0-scriptName=__System\nc0-methodName=pageLoaded\nc0-id=0\nbatchId=$batchId\ninstanceId=$instanceId\npage=%2Ftips%2FtipsLogin.action\nscriptSessionId=$scriptSessionId\n"
    set resp [nv::req $cppm::host$cppm::__System(pageLoaded) -headers $req_headers -method POST -post_body $req_post_body -keepalive 0]
    array set resp_arr $resp
    if { [regexp {r.handleCallback\(\"$batchId\",\"0\",null\)} $resp_arr(data) orig v1 ]} {
    } else {
        set req_headers [nv::gen_req_headers Cookie $req_cookie Referer $cppm::host$cppm::hrefs(policy_manager)]
        if { [string equal $opts(-zlib_support) no]} {
            set req_headers [nv::patch_non_zlib $req_headers]
        }
        set tok [http::geturl $cppm::host$cppm::__System(pageLoaded) -headers $req_headers -method POST -query $req_post_body -keepalive 0 -type {text/plain; charset=UTF-8}]
        set data [http::data $tok]
        regexp {r.handleCallback\(\"$batchId\",\"0\",null\)} $data orig v1
    }
    set results {}
    lappend results $req_cookie
    lappend results $scriptSessionId
    return $results
}

proc cppm::getPublisherUrl { req_cookie scriptSessionId {instanceId 0} {batchId 1} args } {
    array set opts {
        -zlib_support no
        -windowName ""
    }
    array set opts $args
    set req_headers [nv::gen_req_headers Cache-Control no-cache Pragma no-cache  Cookie $req_cookie Referer $cppm::host$cppm::hrefs(policy_manager)]
    if { [string equal $opts(-zlib_support) no]} {
        set req_headers [nv::patch_non_zlib $req_headers]
    }
    set req_post_body "callCount=1\nwindowName=$opts(-windowName)\nc0-scriptName=login\nc0-methodName=getPublisherUrl\nc0-id=0\nbatchId=$batchId\ninstanceId=$instanceId\npage=%2Ftips%2FtipsLogin.action\nscriptSessionId=$scriptSessionId\n"
    set resp [nv::req $cppm::host$cppm::login(getPublisherUrl) -headers $req_headers -method POST -post_body $req_post_body -keepalive 0]
    array set resp_arr $resp
    if { [regexp {r.handleCallback\(\"$batchId\",\"0\",null\)} $resp_arr(data) orig v1 ]} {
    } else {
        set req_headers [nv::gen_req_headers Cookie $req_cookie Referer $cppm::host$cppm::hrefs(policy_manager)]
        if { [string equal $opts(-zlib_support) no]} {
            set req_headers [nv::patch_non_zlib $req_headers]
        }
        set tok [http::geturl $cppm::host$cppm::login(getPublisherUrl) -headers $req_headers -method POST -query $req_post_body -keepalive 0 -type {text/plain; charset=UTF-8}]
        set data [http::data $tok]
        regexp {r.handleCallback\(\"$batchId\",\"0\",null\)} $data orig v1
    }
    return $req_cookie
}

proc cppm::tipsLoginSubmit { req_cookie args } {
    array set opts {
        -zlib_support no
    }
    array set opts $args
    array set temp_arr [nv::gen_cookie_kv_pairs $req_cookie]
    set DWRSESSIONID [nv::get_values_via_key [nv::gen_cookie_kv_pairs $req_cookie] DWRSESSIONID]
    set req_headers [nv::gen_req_headers Cache-Control {max-age=0}  Cookie $req_cookie Referer $cppm::host$cppm::hrefs(policy_manager) Origin $cppm::host ]
    if { [string equal $opts(-zlib_support) no]} {
        set req_headers [nv::patch_non_zlib $req_headers]
    }
    set req_post_body [nv::gen_post_body username $cppm::login_username password $cppm::login_password]
    set resp [nv::req $cppm::host$cppm::tipsLoginSubmit -headers $req_headers -method POST -post_body $req_post_body -keepalive 0]
    array set resp_arr $resp
    
    set url_7 [nv::get_uni_header_from_resp $resp_arr(meta) Location]
    set req_cookie [nv::gen_cookie_from_resp $resp_arr(meta)]
    set k1 DWRSESSIONID
    set v1 $DWRSESSIONID
    regexp {(.*)=(.*)} $req_cookie orig k2 v2 
    set req_cookie [nv::creat_cookie_from_kv_pairs $k1 $v1 $k2 $v2]
    set req_headers [nv::gen_req_headers Cache-Control {max-age=0} Cookie $req_cookie Referer $cppm::host$cppm::hrefs(policy_manager)]
    if { [string equal $opts(-zlib_support) no]} {
        set req_headers [nv::patch_non_zlib $req_headers]
    }
    set resp [nv::req $url_7 -headers $req_headers -keepalive 0]
    array set resp_arr $resp
    return $req_cookie
}

proc cppm::getMenuTree { req_cookie scriptSessionId {instanceId 0} {batchId 2} args } {
    array set opts {
        -zlib_support no
        -windowName ""
    }
    array set opts $args
    set req_headers [nv::gen_req_headers Cache-Control no-cache Pragma no-cache  Cookie $req_cookie Referer $cppm::host$cppm::tipsContent]
    if { [string equal $opts(-zlib_support) no]} {
        set req_headers [nv::patch_non_zlib $req_headers]
    }
    set req_post_body "callCount=1\nwindowName=$opts(-windowName)\nc0-scriptName=login\nc0-methodName=getMenuTree\nc0-id=0\nbatchId=$batchId\ninstanceId=$instanceId\npage=%2Ftips%2FtipsContent.action\nscriptSessionId=$scriptSessionId\n"
    set resp [nv::req $cppm::host$cppm::login(getMenuTree) -headers $req_headers -method POST -post_body $req_post_body -keepalive 0]
    array set resp_arr $resp
    if { [regexp {r.handleCallback\(\"$batchId\",\"0\",.*\)} $resp_arr(data) orig v1 ]} {
        puts [paint_str $resp_arr(data) green]
    } else {
        # this is beacuse explict Content-Type will fail  under tclsh8.5 + http 2.7.5
        set req_headers [nv::gen_req_headers Cookie $req_cookie Referer $cppm::host$cppm::tipsContent]
        if { [string equal $opts(-zlib_support) no]} {
            set req_headers [nv::patch_non_zlib $req_headers]
        }
        set tok [http::geturl $cppm::host$cppm::login(getMenuTree) -headers $req_headers -method POST -query $req_post_body -keepalive 0 -type {text/plain; charset=UTF-8}]
        set data [http::data $tok]
        puts [paint_str $data green]
        regexp {r.handleCallback\(\"$batchId\",\"0\",.*\)} $data orig v1
    }
    return $req_cookie
}

proc cppm::getFipsEnabled { req_cookie scriptSessionId {instanceId 0} {batchId 3} args } {
    array set opts {
        -zlib_support no
        -windowName ""
    }
    array set opts $args
    set req_headers [nv::gen_req_headers Cache-Control no-cache Pragma no-cache  Cookie $req_cookie Referer $cppm::host$cppm::tipsContent]
    if { [string equal $opts(-zlib_support) no]} {
        set req_headers [nv::patch_non_zlib $req_headers]
    }
    set req_post_body "callCount=1\nwindowName=$opts(-windowName)\nc0-scriptName=fipsParam\nc0-methodName=getFipsEnabled\nc0-id=0\nbatchId=$batchId\ninstanceId=$instanceId\npage=%2Ftips%2FtipsContent.action\nscriptSessionId=$scriptSessionId\n"
    set resp [nv::req $cppm::host$cppm::fipsParam(getFipsEnabled) -headers $req_headers -method POST -post_body $req_post_body -keepalive 0]
    array set resp_arr $resp
    if { [regexp {r.handleCallback\(\"$batchId\",\"0\",.*\)} $resp_arr(data) orig v1 ]} {
    } else {
        # this is beacuse explict Content-Type will fail  under tclsh8.5 + http 2.7.5
        set req_headers [nv::gen_req_headers Cookie $req_cookie Referer $cppm::host$cppm::tipsContent]
        if { [string equal $opts(-zlib_support) no]} {
            set req_headers [nv::patch_non_zlib $req_headers]
        }
        set tok [http::geturl $cppm::host$cppm::fipsParam(getFipsEnabled) -headers $req_headers -method POST -query $req_post_body -keepalive 0 -type {text/plain; charset=UTF-8}]
        set data [http::data $tok]
        regexp {r.handleCallback\(\"$batchId\",\"0\",.*\)} $data orig v1
    }
    return $req_cookie
}

proc cppm::getServerModes { req_cookie scriptSessionId {instanceId 0} {batchId 4} args } {
    array set opts {
        -zlib_support no
        -windowName ""
    }
    array set opts $args
    set req_headers [nv::gen_req_headers Cache-Control no-cache Pragma no-cache  Cookie $req_cookie Referer $cppm::host$cppm::tipsContent]
    if { [string equal $opts(-zlib_support) no]} {
        set req_headers [nv::patch_non_zlib $req_headers]
    }
    set req_post_body "callCount=1\nwindowName=$opts(-windowName)\nc0-scriptName=login\nc0-methodName=getServerModes\nc0-id=0\nbatchId=$batchId\ninstanceId=$instanceId\npage=%2Ftips%2FtipsContent.action\nscriptSessionId=$scriptSessionId\n"
    set resp [nv::req $cppm::host$cppm::login(getServerModes) -headers $req_headers -method POST -post_body $req_post_body -keepalive 0]
    array set resp_arr $resp
    if { [regexp {r.handleCallback\(\"$batchId\",\"0\",.*\)} $resp_arr(data) orig v1 ]} {
    } else {
        set req_headers [nv::gen_req_headers Cookie $req_cookie Referer $cppm::host$cppm::tipsContent]
        if { [string equal $opts(-zlib_support) no]} {
            set req_headers [nv::patch_non_zlib $req_headers]
        }
        set tok [http::geturl $cppm::host$cppm::login(getServerModes) -headers $req_headers -method POST -query $req_post_body -keepalive 0 -type {text/plain; charset=UTF-8}]
        set data [http::data $tok]
        regexp {r.handleCallback\(\"$batchId\",\"0\",.*\)} $data orig v1
    }
    return $req_cookie
}

proc cppm::getStandByPublisherTakeOverStatus { req_cookie scriptSessionId {instanceId 0} {batchId 5} args } {
    array set opts {
        -zlib_support no
        -windowName ""
    }
    array set opts $args
    set req_headers [nv::gen_req_headers Cache-Control no-cache Pragma no-cache  Cookie $req_cookie Referer $cppm::host$cppm::tipsContent]
    if { [string equal $opts(-zlib_support) no]} {
        set req_headers [nv::patch_non_zlib $req_headers]
    }
    set req_post_body "callCount=1\nwindowName=$opts(-windowName)\nc0-scriptName=cliAction\nc0-methodName=getStandByPublisherTakeOverStatus\nc0-id=0\nbatchId=$batchId\ninstanceId=$instanceId\npage=%2Ftips%2FtipsContent.action\nscriptSessionId=$scriptSessionId\n"
    set resp [nv::req $cppm::host$cppm::cliAction(getStandByPublisherTakeOverStatus) -headers $req_headers -method POST -post_body $req_post_body -keepalive 0]
    array set resp_arr $resp
    if { [regexp {r.handleCallback\(\"$batchId\",\"0\",.*\)} $resp_arr(data) orig v1 ]} {
    } else {
        set req_headers [nv::gen_req_headers Cookie $req_cookie Referer $cppm::host$cppm::tipsContent]
        if { [string equal $opts(-zlib_support) no]} {
            set req_headers [nv::patch_non_zlib $req_headers]
        }
        set tok [http::geturl $cppm::host$cppm::cliAction(getStandByPublisherTakeOverStatus) -headers $req_headers -method POST -query $req_post_body -keepalive 0 -type {text/plain; charset=UTF-8}]
        set data [http::data $tok]
        regexp {r.handleCallback\(\"$batchId\",\"0\",.*\)} $data orig v1
    }
    return $req_cookie
}

proc cppm::getExpiredAppLicenses { req_cookie scriptSessionId {instanceId 0} {batchId 6} args} {
    array set opts {
        -zlib_support no
        -windowName ""
    }
    array set opts $args
    set req_headers [nv::gen_req_headers Cache-Control no-cache Pragma no-cache  Cookie $req_cookie Referer $cppm::host$cppm::tipsContent]
    if { [string equal $opts(-zlib_support) no]} {
        set req_headers [nv::patch_non_zlib $req_headers]
    }
    set req_post_body "callCount=1\nwindowName=$opts(-windowName)\nc0-scriptName=licensingInfo\nc0-methodName=getExpiredAppLicenses\nc0-id=0\nbatchId=$batchId\ninstanceId=$instanceId\npage=%2Ftips%2FtipsContent.action\nscriptSessionId=$scriptSessionId\n"
    set resp [nv::req $cppm::host$cppm::licensingInfo(getExpiredAppLicenses) -headers $req_headers -method POST -post_body $req_post_body -keepalive 0]
    array set resp_arr $resp
    if { [regexp {r.handleCallback\(\"$batchId\",\"0\",.*\)} $resp_arr(data) orig v1 ]} {
    } else {
        set req_headers [nv::gen_req_headers Cookie $req_cookie Referer $cppm::host$cppm::tipsContent]
        if { [string equal $opts(-zlib_support) no]} {
            set req_headers [nv::patch_non_zlib $req_headers]
        }
        set tok [http::geturl $cppm::host$cppm::licensingInfo(getExpiredAppLicenses) -headers $req_headers -method POST -query $req_post_body -keepalive 0 -type {text/plain; charset=UTF-8}]
        set data [http::data $tok]
        regexp {r.handleCallback\(\"$batchId\",\"0\",.*\)} $data orig v1
    }
    return $req_cookie
}

proc cppm::getServerDate { old_req_cookie scriptSessionId {instanceId 0} {batchId 7} args } { 
    array set opts {
        -zlib_support no
        -windowName ""
    }
    array set opts $args
    set req_post_body "callCount=1\nwindowName=$opts(-windowName)\nc0-scriptName=login\nc0-methodName=getServerDate\nc0-id=0\nbatchId=$batchId\ninstanceId=$instanceId\npage=%2Ftips%2FtipsContent.action\nscriptSessionId=$scriptSessionId\n"
    set old_req_cookie $req_cookie
    append req_cookie "; tree_node_0SaveStateCookie=undefined; tree_node_1SaveStateCookie=undefined; tree_node_2SaveStateCookie=undefined; tree_node_3SaveStateCookie=undefined"
    set req_headers [nv::gen_req_headers Cache-Control no-cache Pragma no-cache  Cookie $req_cookie Referer $cppm::host$cppm::tipsContent]
    set resp [nv::req $cppm::host$cppm::login(getServerDate) -headers $req_headers -method POST -post_body $req_post_body -keepalive 0]
    array set resp_arr $resp
    if { [string equal $opts(-zlib_support) no]} {
        set req_headers [nv::patch_non_zlib $req_headers]
    }
    if { [regexp {r.handleCallback\(\"$batchId\",\"0\",.*\)} $resp_arr(data) orig v1 ]} {
        puts [paint_str $resp_arr(data) green]
    } else {
        set req_headers [nv::gen_req_headers Cookie $req_cookie Referer $cppm::host$cppm::tipsContent]
        if { [string equal $opts(-zlib_support) no]} {
            set req_headers [nv::patch_non_zlib $req_headers]
        }
        set tok [http::geturl $cppm::host$cppm::login(getServerDate) -headers $req_headers -method POST -query $req_post_body -keepalive 0 -type {text/plain; charset=UTF-8}]
        set data [http::data $tok]
        puts [paint_str $data green]
        regexp {r.handleCallback\(\"$batchId\",\"0\",.*\)} $data orig v1
    }
    return $old_req_cookie
}

proc cppm::isSessionValid { old_req_cookie scriptSessionId {instanceId 0} {batchId 8} args } { 
    array set opts {
        -zlib_support no
        -windowName ""
    }
    array set opts $args
    set req_post_body "callCount=1\nwindowName=$opts(-windowName)\nc0-scriptName=login\nc0-methodName=isSessionValid\nc0-id=0\nbatchId=$batchId\ninstanceId=$instanceId\npage=%2Ftips%2FtipsContent.action\nscriptSessionId=$scriptSessionId\n"
    set req_cookie $old_req_cookie
    append req_cookie "; tree_node_0SaveStateCookie=undefined; tree_node_1SaveStateCookie=undefined%2Cmenu_3_3_1; tree_node_2SaveStateCookie=undefined; tree_node_3SaveStateCookie=undefined"
    set req_headers [nv::gen_req_headers Cache-Control no-cache Pragma no-cache  Cookie $req_cookie Referer $cppm::host$cppm::tipsContent]
    set resp [nv::req $cppm::host$cppm::login(isSessionValid) -headers $req_headers -method POST -post_body $req_post_body -keepalive 0]
    array set resp_arr $resp
    if { [string equal $opts(-zlib_support) no]} {
        set req_headers [nv::patch_non_zlib $req_headers]
    }
    if { [regexp {r.handleCallback\(\"$batchId\",\"0\",.*\)} $resp_arr(data) orig v1 ]} {
    } else {
        set req_headers [nv::gen_req_headers Cookie $req_cookie Referer $cppm::host$cppm::tipsContent]
        if { [string equal $opts(-zlib_support) no]} {
            set req_headers [nv::patch_non_zlib $req_headers]
        }
        set tok [http::geturl $cppm::host$cppm::login(isSessionValid) -headers $req_headers -method POST -query $req_post_body -keepalive 0 -type {text/plain; charset=UTF-8}]
        set data [http::data $tok]
        regexp {r.handleCallback\(\"$batchId\",\"0\",.*\)} $data orig v1
    }
    return $old_req_cookie
}

proc cppm::getloggedInUserInfo { old_req_cookie scriptSessionId {instanceId 0} {batchId 9} args } { 
    array set opts {
        -zlib_support no
        -windowName ""
    }
    array set opts $args
    set req_post_body "callCount=1\nwindowName=$opts(-windowName)\nc0-scriptName=login\nc0-methodName=getloggedInUserInfo\nc0-id=0\nbatchId=$batchId\ninstanceId=$instanceId\npage=%2Ftips%2FtipsContent.action\nscriptSessionId=$scriptSessionId\n"
    set req_cookie $old_req_cookie
    append req_cookie "; tree_node_0SaveStateCookie=undefined; tree_node_1SaveStateCookie=undefined%2Cmenu_3_3_1; tree_node_2SaveStateCookie=undefined; tree_node_3SaveStateCookie=undefined"
    set req_headers [nv::gen_req_headers Cache-Control no-cache Pragma no-cache  Cookie $req_cookie Referer $cppm::host$cppm::tipsContent]
    set resp [nv::req $cppm::host$cppm::login(getloggedInUserInfo) -headers $req_headers -method POST -post_body $req_post_body -keepalive 0]
    array set resp_arr $resp
    if { [string equal $opts(-zlib_support) no]} {
        set req_headers [nv::patch_non_zlib $req_headers]
    }
    if { [regexp {r.handleCallback\(\"$batchId\",\"0\",.*\)} $resp_arr(data) orig v1 ]} {
    } else {
        set req_headers [nv::gen_req_headers Cookie $req_cookie Referer $cppm::host$cppm::tipsContent]
        if { [string equal $opts(-zlib_support) no]} {
            set req_headers [nv::patch_non_zlib $req_headers]
        }
        set tok [http::geturl $cppm::host$cppm::login(getloggedInUserInfo) -headers $req_headers -method POST -query $req_post_body -keepalive 0 -type {text/plain; charset=UTF-8}]
        set data [http::data $tok]
        regexp {r.handleCallback\(\"$batchId\",\"0\",.*\)} $data orig v1
    }
    return $old_req_cookie
}

proc cppm::getLocalhostId { old_req_cookie scriptSessionId {instanceId 0} {batchId 10} args } { 
    array set opts {
        -zlib_support no
        -windowName ""
    }
    array set opts $args
    set req_post_body "callCount=1\nwindowName=$opts(-windowName)\nc0-scriptName=tipsMashups\nc0-methodName=getLocalhostId\nc0-id=0\nbatchId=$batchId\ninstanceId=$instanceId\npage=%2Ftips%2FtipsContent.action\nscriptSessionId=$scriptSessionId\n"
    set req_cookie $old_req_cookie
    append req_cookie "; tree_node_0SaveStateCookie=undefined; tree_node_1SaveStateCookie=undefined%2Cmenu_3_3_1; tree_node_2SaveStateCookie=undefined%2Cmenu_5_5_7%2Cmenu_5_5_5; tree_node_3SaveStateCookie=undefined"
    set req_headers [nv::gen_req_headers Cache-Control no-cache Pragma no-cache  Cookie $req_cookie Referer $cppm::host$cppm::tipsContent]
    set resp [nv::req $cppm::host$cppm::tipsMashups(getLocalhostId) -headers $req_headers -method POST -post_body $req_post_body -keepalive 0]
    array set resp_arr $resp
    if { [string equal $opts(-zlib_support) no]} {
        set req_headers [nv::patch_non_zlib $req_headers]
    }
    if { [regexp {r.handleCallback\(\"$batchId\",\"0\",.*\)} $resp_arr(data) orig v1 ]} {
    } else {
        set req_headers [nv::gen_req_headers Cookie $req_cookie Referer $cppm::host$cppm::tipsContent]
        if { [string equal $opts(-zlib_support) no]} {
            set req_headers [nv::patch_non_zlib $req_headers]
        }
        set tok [http::geturl $cppm::host$cppm::tipsMashups(getLocalhostId) -headers $req_headers -method POST -query $req_post_body -keepalive 0 -type {text/plain; charset=UTF-8}]
        set data [http::data $tok]
        regexp {r.handleCallback\(\"$batchId\",\"0\",.*\)} $data orig v1
    }
    return $old_req_cookie
}

proc cppm::getConfigBean { old_req_cookie scriptSessionId {instanceId 0} {batchId 11} args } { 
    array set opts {
        -zlib_support no
        -windowName ""
    }
    array set opts $args
    set req_post_body "callCount=1\nwindowName=$opts(-windowName)\nc0-scriptName=tipsMashups\nc0-methodName=getConfigBean\nc0-id=0\nbatchId=$batchId\ninstanceId=$instanceId\npage=%2Ftips%2FtipsContent.action\nscriptSessionId=$scriptSessionId\n"
    set req_cookie $old_req_cookie
    append req_cookie "; tree_node_0SaveStateCookie=undefined; tree_node_1SaveStateCookie=undefined%2Cmenu_3_3_1; tree_node_2SaveStateCookie=undefined%2Cmenu_5_5_7%2Cmenu_5_5_5; tree_node_3SaveStateCookie=undefined"
    set req_headers [nv::gen_req_headers Cache-Control no-cache Pragma no-cache  Cookie $req_cookie Referer $cppm::host$cppm::tipsContent]
    set resp [nv::req $cppm::host$cppm::tipsMashups(getConfigBean) -headers $req_headers -method POST -post_body $req_post_body -keepalive 0]
    array set resp_arr $resp
    if { [string equal $opts(-zlib_support) no]} {
        set req_headers [nv::patch_non_zlib $req_headers]
    }
    if { [regexp {r.handleCallback\(\"$batchId\",\"0\",.*\)} $resp_arr(data) orig v1 ]} {
    } else {
        set req_headers [nv::gen_req_headers Cookie $req_cookie Referer $cppm::host$cppm::tipsContent]
        if { [string equal $opts(-zlib_support) no]} {
            set req_headers [nv::patch_non_zlib $req_headers]
        }
        set tok [http::geturl $cppm::host$cppm::tipsMashups(getConfigBean) -headers $req_headers -method POST -query $req_post_body -keepalive 0 -type {text/plain; charset=UTF-8}]
        set data [http::data $tok]
        regexp {r.handleCallback\(\"$batchId\",\"0\",.*\)} $data orig v1
    }
    return $old_req_cookie
}

proc cppm::getAllowedQuickLinks { old_req_cookie scriptSessionId {instanceId 0} {batchId 12} args } {
    array set opts {
        -zlib_support no
        -windowName ""
    }
    array set opts $args
    set req_post_body "callCount=1\nwindowName=$opts(-windowName)\nc0-scriptName=summaryPage\nc0-methodName=getAllowedQuickLinks\nc0-id=0\nbatchId=$batchId\ninstanceId=$instanceId\npage=%2Ftips%2FtipsContent.action\nscriptSessionId=$scriptSessionId\n"
    set req_cookie $old_req_cookie
    append req_cookie "; tree_node_0SaveStateCookie=undefined; tree_node_1SaveStateCookie=undefined%2Cmenu_3_3_1; tree_node_2SaveStateCookie=undefined%2Cmenu_5_5_7%2Cmenu_5_5_5; tree_node_3SaveStateCookie=undefined"
    set req_headers [nv::gen_req_headers Cache-Control no-cache Pragma no-cache  Cookie $req_cookie Referer $cppm::host$cppm::tipsContent]
    set resp [nv::req $cppm::host$cppm::summaryPage(getAllowedQuickLinks) -headers $req_headers -method POST -post_body $req_post_body -keepalive 0]
    array set resp_arr $resp
    if { [string equal $opts(-zlib_support) no]} {
        set req_headers [nv::patch_non_zlib $req_headers]
    }
    if { [regexp {r.handleCallback\(\"$batchId\",\"0\",.*\)} $resp_arr(data) orig v1 ]} {
    } else {
        set req_headers [nv::gen_req_headers Cookie $req_cookie Referer $cppm::host$cppm::tipsContent]
        if { [string equal $opts(-zlib_support) no]} {
            set req_headers [nv::patch_non_zlib $req_headers]
        }
        set tok [http::geturl $cppm::host$cppm::summaryPage(getAllowedQuickLinks) -headers $req_headers -method POST -query $req_post_body -keepalive 0 -type {text/plain; charset=UTF-8}]
        set data [http::data $tok]
        regexp {r.handleCallback\(\"$batchId\",\"0\",.*\)} $data orig v1
    }
    return $old_req_cookie
}

proc cppm::getOemName { old_req_cookie scriptSessionId {instanceId 0} {batchId 13} args } {
    array set opts {
        -zlib_support no
        -windowName ""
    }
    array set opts $args
    set req_post_body "callCount=1\nwindowName=$opts(-windowName)\nc0-scriptName=dashboard\nc0-methodName=getOemName\nc0-id=0\nbatchId=$batchId\ninstanceId=$instanceId\npage=%2Ftips%2FtipsContent.action\nscriptSessionId=$scriptSessionId\n"
    set req_cookie $old_req_cookie
    append req_cookie "; tree_node_0SaveStateCookie=undefined; tree_node_1SaveStateCookie=undefined%2Cmenu_3_3_1; tree_node_2SaveStateCookie=undefined%2Cmenu_5_5_7%2Cmenu_5_5_5; tree_node_3SaveStateCookie=undefined"
    set req_headers [nv::gen_req_headers Cache-Control no-cache Pragma no-cache  Cookie $req_cookie Referer $cppm::host$cppm::tipsContent]
    if { [string equal $opts(-zlib_support) no]} {
        set req_headers [nv::patch_non_zlib $req_headers]
    }
    set resp [nv::req $cppm::host$cppm::dashboard(getOemName) -headers $req_headers -method POST -post_body $req_post_body -keepalive 0]
    array set resp_arr $resp
    if { [regexp {r.handleCallback\(\"$batchId\",\"0\",.*\)} $resp_arr(data) orig v1 ]} {
    } else {
        set req_headers [nv::gen_req_headers Cookie $req_cookie Referer $cppm::host$cppm::tipsContent]
        if { [string equal $opts(-zlib_support) no]} {
            set req_headers [nv::patch_non_zlib $req_headers]
        }
        set tok [http::geturl $cppm::host$cppm::dashboard(getOemName) -headers $req_headers -method POST -query $req_post_body -keepalive 0 -type {text/plain; charset=UTF-8}]
        set data [http::data $tok]
        regexp {r.handleCallback\(\"$batchId\",\"0\",.*\)} $data orig v1
    }
    return $old_req_cookie
}

proc cppm::tipsLocalUser { old_req_cookie args } {
    array set opts {
        -zlib_support no
        -windowName ""
    }
    array set opts $args
    set req_cookie $old_req_cookie
    append req_cookie "; tree_node_0SaveStateCookie=undefined; tree_node_1SaveStateCookie=undefined%2Cmenu_3_3_1; tree_node_2SaveStateCookie=undefined%2Cmenu_5_5_7%2Cmenu_5_5_5; tree_node_3SaveStateCookie=undefined"
    set req_headers [nv::gen_req_headers Cache-Control no-cache Pragma no-cache  Cookie $req_cookie Referer $cppm::host$cppm::tipsContent Content-Type application/x-www-form-urlencoded]
    if { [string equal $opts(-zlib_support) no]} {
        set req_headers [nv::patch_non_zlib $req_headers]
    }
    set resp [nv::req $cppm::host$cppm::tipsLocalUser -headers $req_headers -method GET  -keepalive 0]
    array set resp_arr $resp
    if { [regexp {localUsersEdit_popContentUrl} $resp_arr(data) orig v1 ]} {
    } else {
        # this is beacuse explict Content-Type will fail  under tclsh8.5 + http 2.7.5
        set req_headers [nv::gen_req_headers Cookie $req_cookie Referer $cppm::host$cppm::tipsContent]
        if { [string equal $opts(-zlib_support) no]} {
            set req_headers [nv::patch_non_zlib $req_headers]
        }
        set tok [http::geturl $cppm::host$cppm::tipsLocalUser -headers $req_headers -method GET -keepalive 0 -type application/x-www-form-urlencoded]
        set data [http::data $tok]
        regexp {localUsersEdit_popContentUrl} $data orig v1
    }
    return $old_req_cookie
}

proc cppm::filterTable { old_req_cookie scriptSessionId {instanceId 0} {batchId 14} args } {
    array set opts {
        -zlib_support no
        -windowName ""
    }
    array set opts $args
    set req_post_body "callCount=1\nwindowName=$opts(-windowName)\nc0-scriptName=localUsers\nc0-methodName=filterTable\nc0-id=0\nc0-e3=string:userId\nc0-e4=string:\nc0-e5=string:STRING\nc0-e6=string:contains\nc0-e7=string:contains\nc0-e2=Object_Object:{filterBarSelect:reference:c0-e3, filterField:reference:c0-e4, dataType:reference:c0-e5, filterFieldCondition:reference:c0-e6, tagColumnCondition:reference:c0-e7}\nc0-e1=array:\[reference:c0-e2\]\nc0-e8=boolean:true\nc0-e9=string:userId\nc0-e10=boolean:true\nc0-e11=number:1\nc0-e12=number:10\nc0-e13=number:0\nc0-e14=number:0\nc0-e15=number:0\nc0-e16=number:0\nc0-e17=string:contains\nc0-e18=string:contains\nc0-param0=Object_Object:{filterCriteriaList:reference:c0-e1, matchAll:reference:c0-e8, sortKey:reference:c0-e9, hasAscending:reference:c0-e10, pageNumber:reference:c0-e11, pageSize:reference:c0-e12, currentRecordInPage:reference:c0-e13, lastRecordInPage:reference:c0-e14, maxRecordsInFilter:reference:c0-e15, maxPageNumber:reference:c0-e16, filterFieldCondition:reference:c0-e17, tagColumnCondition:reference:c0-e18}\nc0-param1=boolean:true\n\nbatchId=$batchId\ninstanceId=$instanceId\npage=%2Ftips%2FtipsContent.action\nscriptSessionId=$scriptSessionId\n"
    set req_cookie $old_req_cookie
    append req_cookie "; tree_node_0SaveStateCookie=undefined; tree_node_1SaveStateCookie=undefined%2Cmenu_3_3_1; tree_node_2SaveStateCookie=undefined%2Cmenu_5_5_7%2Cmenu_5_5_5; tree_node_3SaveStateCookie=undefined"
    set req_headers [nv::gen_req_headers Cache-Control no-cache Pragma no-cache  Cookie $req_cookie Referer $cppm::host$cppm::tipsContent]
    if { [string equal $opts(-zlib_support) no]} {
        set req_headers [nv::patch_non_zlib $req_headers]
    }
    set resp [nv::req $cppm::host$cppm::localUsers(filterTable) -headers $req_headers -method POST -post_body $req_post_body -keepalive 0]
    array set resp_arr $resp
    if { [regexp {r.handleCallback\(\"$batchId\",\"0\",.*\)} $resp_arr(data) orig v1 ]} {
    } else {
        set req_headers [nv::gen_req_headers Cookie $req_cookie Referer $cppm::host$cppm::tipsContent]
        if { [string equal $opts(-zlib_support) no]} {
            set req_headers [nv::patch_non_zlib $req_headers]
        }
        set tok [http::geturl $cppm::host$cppm::localUsers(filterTable) -headers $req_headers -method POST -query $req_post_body -keepalive 0 -type {text/plain; charset=UTF-8}]
        set data [http::data $tok]
        regexp {r.handleCallback\(\"$batchId\",\"0\",.*\)} $data orig v1
    }
    return $old_req_cookie
}

proc cppm::getAllMandatoryTags { old_req_cookie scriptSessionId {instanceId 0} {batchId 15} args } {    
    array set opts {
        -zlib_support no
        -windowName ""
    }
    array set opts $args
    set req_post_body "callCount=1\nwindowName=$opts(-windowName)\nc0-scriptName=localUsers\nc0-methodName=getAllMandatoryTags\nc0-id=0\nbatchId=$batchId\ninstanceId=$instanceId\npage=%2Ftips%2FtipsContent.action\nscriptSessionId=$scriptSessionId\n"
    set req_cookie $old_req_cookie
    append req_cookie "; tree_node_0SaveStateCookie=undefined; tree_node_1SaveStateCookie=undefined%2Cmenu_3_3_1; tree_node_2SaveStateCookie=undefined%2Cmenu_5_5_7%2Cmenu_5_5_5; tree_node_3SaveStateCookie=undefined"
    set req_headers [nv::gen_req_headers Cache-Control no-cache Pragma no-cache  Cookie $req_cookie Referer $cppm::host$cppm::tipsContent]
    if { [string equal $opts(-zlib_support) no]} {
        set req_headers [nv::patch_non_zlib $req_headers]
    }
    set resp [nv::req $cppm::host$cppm::localUsers(getAllMandatoryTags) -headers $req_headers -method POST -post_body $req_post_body -keepalive 0]
    array set resp_arr $resp
    if { [regexp {r.handleCallback\(\"$batchId\",\"0\",.*\)} $resp_arr(data) orig v1 ]} {
    } else {
        set req_headers [nv::gen_req_headers Cookie $req_cookie Referer $cppm::host$cppm::tipsContent]
        if { [string equal $opts(-zlib_support) no]} {
            set req_headers [nv::patch_non_zlib $req_headers]
        }
        set tok [http::geturl $cppm::host$cppm::localUsers(getAllMandatoryTags) -headers $req_headers -method POST -query $req_post_body -keepalive 0 -type {text/plain; charset=UTF-8}]
        set data [http::data $tok]
        regexp {r.handleCallback\(\"$batchId\",\"0\",.*\)} $data orig v1
    }
    return $old_req_cookie
}

proc cppm::tipsEditLocalUser { old_req_cookie } {
    array set opts {
        -zlib_support no
        -windowName ""
    }
    array set opts $args
    set req_cookie $old_req_cookie
    append req_cookie "; tree_node_0SaveStateCookie=undefined; tree_node_1SaveStateCookie=undefined%2Cmenu_3_3_1; tree_node_2SaveStateCookie=undefined%2Cmenu_5_5_7%2Cmenu_5_5_5; tree_node_3SaveStateCookie=undefined"
    set req_headers [nv::gen_req_headers Cache-Control no-cache Pragma no-cache  Cookie $req_cookie Referer $cppm::host$cppm::tipsContent Content-Type application/x-www-form-urlencoded]
    if { [string equal $opts(-zlib_support) no]} {
        set req_headers [nv::patch_non_zlib $req_headers]
    }
    set resp [nv::req $cppm::host$cppm::tipsEditLocalUser -headers $req_headers -method GET  -keepalive 0]
    array set resp_arr $resp
    if { [regexp {localUsersEdit_popContentUrl} $resp_arr(data) orig v1 ]} {
    } else {
        set req_headers [nv::gen_req_headers Cookie $req_cookie Referer $cppm::host$cppm::tipsContent]
        if { [string equal $opts(-zlib_support) no]} {
            set req_headers [nv::patch_non_zlib $req_headers]
        }
        set tok [http::geturl $cppm::host$cppm::tipsEditLocalUser -headers $req_headers -method GET -keepalive 0 -type application/x-www-form-urlencoded]
        set data [http::data $tok]
        regexp {localUsersEdit_popContentUrl} $data orig v1
    }
    return $old_req_cookie
}

proc cppm::getUserFromSession {old_req_cookie scriptSessionId {instanceId 0} {batchId 18} args  } {
    array set opts {
        -zlib_support no
        -windowName ""
    }
    array set opts $args
    set req_post_body "callCount=1\nwindowName=$opts(-windowName)\nc0-scriptName=login\nc0-methodName=getUserFromSession\nc0-id=0\nbatchId=$batchId\ninstanceId=$instanceId\npage=%2Ftips%2FtipsContent.action\nscriptSessionId=$scriptSessionId\n"
    set req_cookie $old_req_cookie
    append req_cookie "; tree_node_0SaveStateCookie=undefined; tree_node_1SaveStateCookie=undefined%2Cmenu_3_3_1; tree_node_2SaveStateCookie=undefined%2Cmenu_5_5_7%2Cmenu_5_5_5; tree_node_3SaveStateCookie=undefined"
    set req_headers [nv::gen_req_headers Cache-Control no-cache Pragma no-cache  Cookie $req_cookie Referer $cppm::host$cppm::tipsContent]
    if { [string equal $opts(-zlib_support) no]} {
        set req_headers [nv::patch_non_zlib $req_headers]
    }
    set resp [nv::req $cppm::host$cppm::login(getUserFromSession) -headers $req_headers -method POST -post_body $req_post_body -keepalive 0]
    array set resp_arr $resp
    if { [regexp {r.handleCallback\(\"$batchId\",\"0\",.*\)} $resp_arr(data) orig v1 ]} {
    } else {
        set req_headers [nv::gen_req_headers Cookie $req_cookie Referer $cppm::host$cppm::tipsContent]
        if { [string equal $opts(-zlib_support) no]} {
            set req_headers [nv::patch_non_zlib $req_headers]
        }
        set tok [http::geturl $cppm::host$cppm::login(getUserFromSession) -headers $req_headers -method POST -query $req_post_body -keepalive 0 -type {text/plain; charset=UTF-8}]
        set data [http::data $tok]
        regexp {r.handleCallback\(\"$batchId\",\"0\",.*\)} $data orig v1
    }
    return $old_req_cookie
}

proc cppm::tipsAddLocalUser { old_req_cookie } {
    set req_cookie $old_req_cookie
    append req_cookie "; tree_node_0SaveStateCookie=undefined; tree_node_1SaveStateCookie=undefined%2Cmenu_3_3_1; tree_node_2SaveStateCookie=undefined%2Cmenu_5_5_7%2Cmenu_5_5_5; tree_node_3SaveStateCookie=undefined"
    set req_headers [nv::gen_req_headers Cache-Control no-cache Pragma no-cache  Cookie $req_cookie Referer $cppm::host$cppm::tipsContent Content-Type application/x-www-form-urlencoded]
    if { [string equal $opts(-zlib_support) no]} {
        set req_headers [nv::patch_non_zlib $req_headers]
    }
    set resp [nv::req $cppm::host$cppm::tipsAddLocalUser -headers $req_headers -method GET  -keepalive 0]
    array set resp_arr $resp
    if { [regexp {TipsLocalUsers.cancelAddPopup} $resp_arr(data) orig v1 ]} {
    } else {
        set req_headers [nv::gen_req_headers Cookie $req_cookie Referer $cppm::host$cppm::tipsContent]
        if { [string equal $opts(-zlib_support) no]} {
            set req_headers [nv::patch_non_zlib $req_headers]
        }
        set tok [http::geturl $cppm::host$cppm::tipsAddLocalUser -headers $req_headers -method GET -keepalive 0 -type application/x-www-form-urlencoded]
        set data [http::data $tok]
        regexp {TipsLocalUsers.cancelAddPopup} $data orig v1
    }
    return $old_req_cookie
}

proc cppm::getNewRuleElementList { old_req_cookie scriptSessionId {instanceId 0} {batchId 19} args} {
    array set opts {
        -zlib_support no
        -windowName ""
    }
    array set opts $args
    set req_post_body "callCount=1\nwindowName=$opts(-windowName)\nc0-scriptName=localUsers\nc0-methodName=getNewRuleElementList\nc0-id=0\nbatchId=$batchId\ninstanceId=$instanceId\npage=%2Ftips%2FtipsContent.action\nscriptSessionId=$scriptSessionId\n"
    set req_cookie $old_req_cookie
    append req_cookie "; tree_node_0SaveStateCookie=undefined; tree_node_1SaveStateCookie=undefined%2Cmenu_3_3_1; tree_node_2SaveStateCookie=undefined%2Cmenu_5_5_7%2Cmenu_5_5_5; tree_node_3SaveStateCookie=undefined"
    set req_headers [nv::gen_req_headers Cache-Control no-cache Pragma no-cache  Cookie $req_cookie Referer $cppm::host$cppm::tipsContent]
    if { [string equal $opts(-zlib_support) no]} {
        set req_headers [nv::patch_non_zlib $req_headers]
    }
    set resp [nv::req $cppm::host$cppm::localUsers(getNewRuleElementList) -headers $req_headers -method POST -post_body $req_post_body -keepalive 0]
    array set resp_arr $resp
    if { [regexp {r.handleCallback\(\"$opts(-windowName)\",\"0\",.*\)} $resp_arr(data) orig v1 ]} {
    } else {
        set req_headers [nv::gen_req_headers Cookie $req_cookie Referer $cppm::host$cppm::tipsContent]
        if { [string equal $opts(-zlib_support) no]} {
            set req_headers [nv::patch_non_zlib $req_headers]
        }
        set tok [http::geturl $cppm::host$cppm::localUsers(getNewRuleElementList) -headers $req_headers -method POST -query $req_post_body -keepalive 0 -type {text/plain; charset=UTF-8}]
        set data [http::data $tok]
        regexp {r.handleCallback\(\"$opts(-windowName)\",\"0\",.*\)} $data orig v1
    }
    return $old_req_cookie
}

proc cppm::getRoleNames { old_req_cookie scriptSessionId {instanceId 0} {batchId 20} args} {
    array set opts {
        -zlib_support no
        -windowName ""
    }
    array set opts $args
    set req_post_body "callCount=1\nwindowName=$opts(-windowName)\nc0-scriptName=localUsers\nc0-methodName=getRoleNames\nc0-id=0\nc0-param0=boolean:true\nbatchId=$batchId\ninstanceId=$instanceId\npage=%2Ftips%2FtipsContent.action\nscriptSessionId=$scriptSessionId\n"
    set req_cookie $old_req_cookie
    append req_cookie "; tree_node_0SaveStateCookie=undefined; tree_node_1SaveStateCookie=undefined%2Cmenu_3_3_1; tree_node_2SaveStateCookie=undefined%2Cmenu_5_5_7%2Cmenu_5_5_5; tree_node_3SaveStateCookie=undefined"
    set req_headers [nv::gen_req_headers Cache-Control no-cache Pragma no-cache  Cookie $req_cookie Referer $cppm::host$cppm::tipsContent]
    if { [string equal $opts(-zlib_support) no]} {
        set req_headers [nv::patch_non_zlib $req_headers]
    }
    set resp [nv::req $cppm::host$cppm::localUsers(getRoleNames) -headers $req_headers -method POST -post_body $req_post_body -keepalive 0]
    array set resp_arr $resp
    if { [regexp {r.handleCallback\(\"$batchId\",\"0\",.*\)} $resp_arr(data) orig v1 ]} {
    } else {
        set req_headers [nv::gen_req_headers Cookie $req_cookie Referer $cppm::host$cppm::tipsContent]
        if { [string equal $opts(-zlib_support) no]} {
            set req_headers [nv::patch_non_zlib $req_headers]
        }
        set tok [http::geturl $cppm::host$cppm::localUsers(getRoleNames) -headers $req_headers -method POST -query $req_post_body -keepalive 0 -type {text/plain; charset=UTF-8}]
        set data [http::data $tok]
        regexp {r.handleCallback\(\"$batchId\",\"0\",.*\)} $data orig v1
    }
    return $old_req_cookie
}

proc cppm::getRuleElementAttrNameMap { old_req_cookie scriptSessionId {instanceId 0} {batchId 21} args} {
    array set opts {
        -zlib_support no
        -windowName ""
    }
    array set opts $args
    set req_post_body "callCount=1\nwindowName=$opts(-windowName)\nc0-scriptName=localUsers\nc0-methodName=getRuleElementAttrNameMap\nc0-id=0\nc0-param0=boolean:true\nbatchId=$batchId\ninstanceId=$instanceId\npage=%2Ftips%2FtipsContent.action\nscriptSessionId=$scriptSessionId\n"
    set req_cookie $old_req_cookie
    append req_cookie "; tree_node_0SaveStateCookie=undefined; tree_node_1SaveStateCookie=undefined%2Cmenu_3_3_1; tree_node_2SaveStateCookie=undefined%2Cmenu_5_5_7%2Cmenu_5_5_5; tree_node_3SaveStateCookie=undefined"
    set req_headers [nv::gen_req_headers Cache-Control no-cache Pragma no-cache  Cookie $req_cookie Referer $cppm::host$cppm::tipsContent]
    if { [string equal $opts(-zlib_support) no]} {
        set req_headers [nv::patch_non_zlib $req_headers]
    }
    set resp [nv::req $cppm::host$cppm::localUsers(getRuleElementAttrNameMap) -headers $req_headers -method POST -post_body $req_post_body -keepalive 0]
    array set resp_arr $resp
    if { [regexp {r.handleCallback\(\"$batchId\",\"0\",.*\)} $resp_arr(data) orig v1 ]} {
    } else {
        set req_headers [nv::gen_req_headers Cookie $req_cookie Referer $cppm::host$cppm::tipsContent]
        if { [string equal $opts(-zlib_support) no]} {
            set req_headers [nv::patch_non_zlib $req_headers]
        }
        set tok [http::geturl $cppm::host$cppm::localUsers(getRuleElementAttrNameMap) -headers $req_headers -method POST -query $req_post_body -keepalive 0 -type {text/plain; charset=UTF-8}]
        set data [http::data $tok]
        regexp {r.handleCallback\(\"$batchId\",\"0\",.*\)} $data orig v1
    }
    return $old_req_cookie
}

proc cppm::login { args } {
    array set opts {
        -zlib_support no
    }
    array set opts $args
    set req_headers [cppm::welcome]
    set req_cookie [cppm::generateId $req_headers]
    set temp [cppm::pageLoaded $req_cookie]
    set req_cookie [lindex $temp 0]
    set scriptSessionId [lindex $temp 1]
    set req_cookie [cppm::getPublisherUrl $req_cookie $scriptSessionId]
    set req_cookie [cppm::tipsLoginSubmit $req_cookie]
    set temp [cppm::pageLoaded $req_cookie 0 0]
    set req_cookie [lindex $temp 0]
    set scriptSessionId [lindex $temp 1]
    set req_cookie [cppm::getPublisherUrl $req_cookie $scriptSessionId 0 1 -windowName c0-e2] 
    set req_cookie [cppm::getMenuTree $req_cookie $scriptSessionId 0 2 -windowName c0-e2]
    set req_cookie [cppm::getFipsEnabled $req_cookie $scriptSessionId 0 3 -windowName c0-e2]
    set req_cookie [cppm::getServerModes $req_cookie $scriptSessionId 0 4 -windowName c0-e2]
    set req_cookie [cppm::getStandByPublisherTakeOverStatus $req_cookie $scriptSessionId 0 5 -windowName c0-e2]
    set req_cookie [cppm::getExpiredAppLicenses $req_cookie $scriptSessionId 0 6 -windowName c0-e2]
    set req_cookie [cppm::getServerDate $req_cookie $scriptSessionId 0 7 -windowName c0-e2]
    set req_cookie [cppm::isSessionValid $req_cookie $scriptSessionId 0 8 -windowName c0-e2]
    set req_cookie [cppm::getloggedInUserInfo $req_cookie $scriptSessionId 0 9 -windowName c0-e2]
    set req_cookie [cppm::getLocalhostId $req_cookie $scriptSessionId 0 10 -windowName c0-e2]
    set req_cookie [cppm::getConfigBean $req_cookie $scriptSessionId 0 11 -windowName c0-e2]
    set req_cookie [cppm::getAllowedQuickLinks $req_cookie $scriptSessionId 0 12 -windowName c0-e2]
    set req_cookie [cppm::getOemName $req_cookie $scriptSessionId 0 13 -windowName c0-e2]
    set req_cookie [cppm::tipsLocalUser $req_cookie]
    set req_cookie [cppm::filterTable $req_cookie $scriptSessionId 0 14 -windowName c0-e2]
    set req_cookie [cppm::getAllMandatoryTags $req_cookie $scriptSessionId 0 15 -windowName c0-e2]
    return $req_cookie 
}

proc cppm::addLocalUser {req_cookie scriptSessionId curr_batchId args } {
    array set opts {
        -zlib_support no
        -userId       ""
        -userName     ""
        -password     ""
    }
    set req_cookie [cppm::tipsEditLocalUser $req_cookie]
    set req_cookie [cppm::filterTable $req_cookie $scriptSessionId 0 $curr_batchId -windowName c0-e4]
    set curr_batchId [expr $curr_batchId + 1]
    set req_cookie [cppm::getAllMandatoryTags $req_cookie $scriptSessionId 0 $curr_batchId -windowName c0-e4]
    set curr_batchId [expr $curr_batchId + 1]
    set req_cookie [cppm::getUserFromSession $req_cookie $scriptSessionId 0 $curr_batchId -windowName c0-e4]
    set curr_batchId [expr $curr_batchId + 1]
    set req_cookie [cppm::getNewRuleElementList $req_cookie $scriptSessionId 0 $curr_batchId -windowName c0-e4]
    set curr_batchId [expr $curr_batchId + 1]
    set req_cookie [cppm::getRoleNames $req_cookie $scriptSessionId 0 $curr_batchId -windowName c0-e4]
    set curr_batchId [expr $curr_batchId + 1]
    set req_cookie [cppm::getRuleElementAttrNameMap $req_cookie $scriptSessionId 0 $curr_batchId -windowName c0-e4]
    set curr_batchId [expr $curr_batchId + 1]
    set req_cookie [cppm::getNewRuleElementList $req_cookie $scriptSessionId 0 $curr_batchId -windowName c0-e4]
    set curr_batchId [expr $curr_batchId + 1]
    set req_post_body [creat_one_local_user_post_body  -userId $opts(-userId) -userName $opts(-userName) -password $opts(-password) -scriptSessionId $scriptSessionId -batchId $curr_batchId]
    set req_headers [nv::gen_req_headers Cache-Control no-cache Pragma no-cache Cookie $req_cookie Referer $cppm::host$cppm::tipsContent Content-Type {text/plain; charset=UTF-8}]
    if { [string equal $opts(-zlib_support) no]} {
        set req_headers [nv::patch_non_zlib $req_headers]
    }
    set resp [nv::req $cppm::host$cppm::localUsers(addLocalUser) -headers $req_headers -method POST -post_body $req_post_body -keepalive 0]
    array set resp_arr $resp
    if { [regexp {r.handleCallback\(.*\"(.*)\"\)} $resp_arr(data) orig v1 ]} {
        puts [paint_str $resp_arr(data) green]
    } else {
        set req_headers [nv::gen_req_headers Cookie $req_cookie Referer $cppm::host$cppm::tipsContent]
        if { [string equal $opts(-zlib_support) no]} {
            set req_headers [nv::patch_non_zlib $req_headers]
        }
        set tok [http::geturl $cppm::host$cppm::localUsers(addLocalUser) -headers $req_headers -method POST -query $req_post_body -keepalive 0 -type {text/plain; charset=UTF-8}]
        set data [http::data $tok]
        puts [paint_str $data green]
        regexp {r.handleCallback\(.*\"(.*)\"\)} $data orig v1
    }
    return $req_cookie
}



set req_cookie [cppm::login]
set curr_batchId 16
set scriptSessionId [cppm::scriptSessionId $req_cookie]
set req_cookie [cppm::addLocalUser $req_cookie $scriptSessionId $curr_batchId  -userId dli7_uid -userName dli7_un  -password dli7_pw]
