#!/bin/sh
#
# Next line is both a Tcl comment and a shell command \
exec tclsh "$0" "$@"

set f [open "lcid.csv" "r"]
set t [read $f]
close $f

set prevCode ""

foreach l [split $t "\n"] {
    set ll [string trim $l]
    if {$ll != ""} {
        set fields [split $ll ";"]

        set langCountry [lindex $fields 0]
        if {[regexp {^(\w+) - (.+)$}  $langCountry match lang country]} {
            set country " ([string toupper $country])"
        } else {
            set lang $langCountry
            set country ""
        }

        set langCountryCode [lindex $fields 1]
        set code [string range $langCountryCode 0 1]
        if {[string length $langCountryCode] > 2 && 
            ![string equal $code $prevCode]} {
            puts "<xsl:when test=\"\$lang = '$code'\">"
            puts "  <xsl:sequence select=\"'[lindex $fields 2] ${lang}${country}'\"/>"
            puts "</xsl:when>"
        }

        puts "<xsl:when test=\"\$lang = '$langCountryCode'\">"
        puts "  <xsl:sequence select=\"'[lindex $fields 2] ${lang}${country}'\"/>"
        puts "</xsl:when>"

        set prevCode $code
    }
}
