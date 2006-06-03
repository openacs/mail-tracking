# packages/project-manager/www/send-mail.tcl

ad_page_contract {
    Use acs-mail-lite/lib/email chunk to send out going mail messages.
    
    party_ids: List of party_ids which will be appended to the assignee list
    party_id: A single party_id which will be used instead of anything else. Useful for sending the mail to only one person.
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


set title [_ mail-tracking.Forward_message]
set context [list [list "one-message?log_id=$log_id" [_ mail-tracking.One_message]] $title]

set return_url "one-message?log_id=$log_id"

# Get the information of the message
db_1row get_message_info { }
set sender [party::name -party_id $sender_id]

set reciever_list [list]
db_foreach reciever_id {select recipient_id from acs_mail_log_recipient_map where type ='to' and log_id = :log_id and recipient_id is not null} {
    lappend reciever_list "[party::name -party_id $recipient_id]"
}
if {![string eq "" $to_addr]} {
    lappend reciever_list $to_addr
}
set recipient [join $reciever_list ","]

set export_vars {log_id}
# Now the CC users
set reciever_list [list]
db_foreach reciever_id {select recipient_id from acs_mail_log_recipient_map where type ='cc' and log_id = :log_id and recipient_id is not null} {
    lappend reciever_list "[party::name -party_id $recipient_id]"
}
if {![string eq "" $cc]} {
    lappend reciever_list $cc
}
set cc_string [join $reciever_list ","]

# And the BCC ones
set reciever_list [list]
db_foreach reciever_id {select recipient_id from acs_mail_log_recipient_map where type ='bcc' and log_id = :log_id and recipient_id is not null} {
    lappend reciever_list "[party::name -party_id $recipient_id]"
}
if {![string eq "" $bcc]} {
    lappend reciever_list $bcc
}
set bcc_string [join $reciever_list ","]

# We get the related files
set files [list]

set content_types [list content_revision content_item file_storage_object image]
foreach content_type $content_types {
    
    foreach file [application_data_link::get_linked -from_object_id $log_id -to_object_type "$content_type"] {
	if { [string equal $content_type "content_revision"] } {
	    lappend files [item::get_item_from_revision $file]
	} else {
	    lappend files $file
	}
    }
}

set download_files [list]

foreach file $files {
    set file_title [content::item::get_title -item_id $file]
    if { [empty_string_p $file_title]} {
	set file_title [acs_object_name $file]
    }
    lappend download_files $file_title
}

set download_files [join $download_files ", "]

if {![ad_looks_like_html_p $body]} {
    set body "<pre>$body</pre>"
}

set mime_type "text/html"

set content_body "<div style=\"background-color: #eee; padding: .5em;\">
<table>
<tr><td>
#mail-tracking.Sender#:</td><td>$sender</tr><td>
#mail-tracking.Recipient#:</td><td>$recipient</tr><td>
#mail-tracking.CC#:</td><td>$cc_string</tr><td>
#mail-tracking.BCC#:</td><td>$bcc_string</tr><td>
#mail-tracking.Subject#:</td><td>$subject</tr><td>
#mail-tracking.Attachments#:</td><td>$download_files</tr><td>
#mail-tracking.MessageID#:</td><td>$message_id</tr>
</table>
</div>
<p>
$body
"

set subject "FW: $subject"