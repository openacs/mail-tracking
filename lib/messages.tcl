# Expects the following optional parameters (in each combination):
#
# recipient_id - to filter mails for a single receiver
# sender_id - to filter mails for a single sender
# package_id to filter mails for a package instance


ad_page_contract {

@author Nima Mazloumi
@creation-date Mon May 30 17:55:50 CEST 2005
@cvs-id $Id$
} -query {
    recipient_id:optional
    sender_id:optional
    package_id:optional
    {orderby:optional "recipient_id"}
} -properties {
    acs_mail_log:multirow 
    context:onevalue
}

set sender_p [exists_and_not_null sender_id]
set receiver_p [exists_and_not_null receiver_id]
set package_p [exists_and_not_null package_id]
set sum_p [expr $sender_p + $receiver_p + $package_p]

if {$sender_p} {
    set sender_id_clause "and sender_id = :sender_id"
} else {
    set sender_id_clause ""
}

if {$receiver_p} {
    set recipient_id_clause "and recipient_id = :recipient_id"
} else {
    set recipient_id_clause ""
}

if {$package_p} {
    set package_id_clause "and package_id = :package_id"
} else {
    set package_id_clause ""
}

set page_title [ad_conn instance_name]
set context [list "index"]

    template::list::create  -name messages  -multirow messages  -key acs_mail_log_id  -row_pretty_plural "[_ mail-tracking.messages]" -elements {
            sender_id {
                label "[_ mail-tracking.Sender]"
		display_template {
		    @messages.sender@
		}
            }
            recipient_id {
                label "[_ mail-tracking.Recipient]"
		display_template {
		    @messages.receiver@
		}
            }
            package_id {
                label "[_ mail-tracking.Package]"
		display_template {
		    <a href="@messages.package_url@">@messages.package_name@</a>
		}
            }
            subject {
                label "[_ mail-tracking.Subject]"
            }
            body {
                label "[_ mail-tracking.Body]"
            }
            sent_date {
                label "[_ mail-tracking.Sent_Date]"
            }            
    } -orderby {
	recipient_id {orderby recipient_id}
	sender_id {orderby sender_id}
	package_id {orderby package_id}
	subject {orderby subject}
	sent_date {orderby sent_date}
    } -filters {
	acs_mail_log_id
    }

set orderby [template::list::orderby_clause -name "messages" -orderby]

db_multirow -extend { sender receiver package_name package_url } messages select_messages {} {

    acs_user::get -user_id $sender_id -array sender_info
    acs_user::get -user_id $recipient_id -array receiver_info

    set sender "$sender_info(first_names) $sender_info(last_name)"
    set receiver "$receiver_info(first_names) $receiver_info(last_name)"

    set package_name [apm_instance_name_from_id $package_id]
    set package_url [apm_package_url_from_id $package_id]
    
}
 
ad_return_template