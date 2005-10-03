# /packages/mail-tracking/lib/one-message.tcl
ad_page_contract {
    Displays one message that was send to a user

    @author Miguel Marin (miguelmarin@viaro.net)
    @author Viaro Networks www.viaro.net
    @creation-date 2005-09-30
} {
    log_id:notnull
    {return_url ""}
} -validate {
    message_exists  -requires {log_id} {
        if { ![db_0or1row message_exists_p { }] } {
            ad_complain "<b>[_ mail-tracking.The_specified_message_does_not_exist]</b>"
        }
    }
}


set page_title "[_ mail-tracking.One_message]"
set context [list]
set sender ""
set receiver ""

if { [empty_string_p $return_url] } {
    set return_url [get_referrer]
}

# Get the information of the message
db_1row get_message_info { }

if { [catch { set sender [person::name -person_id $sender_id] } errorMsg] } {
    set sender ""
}

if { [catch { set recipient [person::name -person_id $recipient_id] } errMsg] } {
    set recipient ""
}

# We get the related files
set files [application_data_link::get_linked -from_object_id $log_id -to_object_type "content_revision"]
foreach file_id [application_data_link::get_linked -from_object_id $log_id -to_object_type "image"] {
    lappend files $file_id
}

set download_files ""

foreach file $files {
    set file_item_id [item::get_item_from_revision $file]
    set file_title [content::item::get_title -item_id $file_item_id]
    # Creating the link to dowload the files
    append download_files "<a href=\"download/?file_id=$file_item_id\">$file_title</a><br>"
}