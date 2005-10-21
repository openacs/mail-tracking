# Expects the following optional parameters (in each combination):
#
# recipient_id     - to filter mails for a single receiver
# sender_id        - to filter mails for a single sender
# object_id        - to filter mails for a object_id
# page             - to filter the pagination
# page_size        - to know how many rows show (optional default to 10)
# show_filter_p    - to show or not the filters in the inlcude, default to "t"
# from_package_id  - to watch mails of this package instance  
# elements         - a list of elements to show in the list template. If not provided will show all elements.
#                    Posible elemets are: sender_id recipient_id package_id subject object_id file_ids body sent_date

ad_page_contract {

@author Nima Mazloumi
@creation-date Mon May 30 17:55:50 CEST 2005
@cvs-id $Id$
} -query {
    recipient_id:optional
    {emp_mail_f:optional 1}
    sender_id:optional
    package_id:optional
    object_id:optional
    {orderby:optional "recipient_id"}
} -properties {
    show_filter_p
    acs_mail_log:multirow 
    context:onevalue
}


set page_title [ad_conn instance_name]
set context [list "index"]

if { [info exist object_id] && [empty_string_p $object_id] } {
   unset object_id
}

if { ![exists_and_not_null from_package_id] } {
    if { [info exist pkg_id] && [empty_string_p $pkg_id] } {
	unset package_id_f
    }
} else {
    set pkg_id $from_package_id
}

if { ![exists_and_not_null show_filter_p] } {
    set show_filter_p "t"
}

if { ![exists_and_not_null page_size] } {
    set page_size 5
}

set tracking_url [apm_package_url_from_key "mail-tracking"]
# Wich elements will be shown on the list template
set rows_list [list]
if {![exists_and_not_null elements] } {
    set rows_list [list sender_id {} recipient_id {} pkg_id {} subject {} object_id {} file_ids {} body {} sent_date {}]
} else {
    foreach element $elements {
	lappend rows_list $element
	lappend rows_list [list]
    }
}

set filters [list \
		 sender_id {
		     label "[_ mail-tracking.Sender]"
		     where_clause "sender_id = :sender_id"
		 } \
		 object_id {
		     label "[_ mail-trackin.Object_id]"
		     where_clause "object_id = :object_id"
		 } \
		 pkg_id {
		     label "[_ mail-tracking.Package]"
		     where_clause "package_id = :pkg_id"	
		 } ]

set recipient_where_clause ""

if { [exists_and_not_null recipient_id] } {
    set recipient_where_clause " and recipient_id = $recipient_id"
}

if { [apm_package_installed_p organizations] && [exists_and_not_null recipient_id]} {
    set org_p [organization::organization_p -party_id $recipient_id] 
    if { $org_p } {
	lappend filters emp_mail_f {
	    label "[_ mail-tracking.Emails_to]"
	    values { {"[_ mail-tracking.Organization]" 1} { "[_ mail-tracking.Employees]" 2 }}
	}
    }
    
    if { $org_p && [string equal $emp_mail_f 2] } {
	set emp_list [contact::util::get_employees -organization_id $recipient_id]
	lappend emp_list $recipient_id
	set recipient_where_clause " and recipient_id in ([template::util::tcl_to_sql_list $emp_list])"
    }
}




template::list::create \
    -name messages \
    -selected_format normal \
    -multirow messages \
    -key acs_mail_log.log_id \
    -page_size $page_size \
    -page_flush_p 0 \
    -page_query_name "messages_pagination" \
    -row_pretty_plural "[_ mail-tracking.messages]" \
    -elements { 
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
	pkg_id {
	    label "[_ mail-tracking.Package]"
	    display_template {
		<a href="@messages.package_url@">@messages.package_name@</a>
	    }
	}
	subject {
	    label "[_ mail-tracking.Subject]"
	}
	object_id {
	    label "[_ mail-tracking.Object_id]"
	    display_template {
		<a href="@messages.object_url@">@messages.object_id@</a>
	    }
	}
	file_ids {
	    label "[_ mail-tracking.Files]"
	    display_template {@messages.download_files;noquote@}
	}
	body {
	    label "[_ mail-tracking.Body]"
	    display_template {
		<a href="${tracking_url}one-message?log_id=@messages.log_id@" title="#mail-tracking.View_full_message#">#mail-tracking.View#</a>
	    }
	}
	sent_date {
	    label "[_ mail-tracking.Sent_Date]"
	}            
    } -orderby {
	recipient_id {
	    orderby recipient_id
	    label "[_ mail-tracking.Recipient]"
	}
	sender_id {
	    orderby sender_id
	    label "[_ mail-tracking.Sender]"
	}
	pkg_id {
	    orderby package_id
	    label "[_ mail-tracking.Package]"
	}
	subject {
	    orderby subject
	    label "[_ mail-tracking.Subject]"
	}
	sent_date {
	    orderby sent_date
	    label "[_ mail-tracking.Sent_Date]"
	}
    } -formats {
	normal {
	    label "Table"
	    layout table
	    row $rows_list
	}
    } -filters $filters \


db_multirow -extend { file_ids object_url sender receiver package_name package_url url_message_id download_files} messages select_messages { } {
    set sender ""
    set receiver ""
    if { [catch { set sender [person::name -person_id $sender_id] } errMsg] } {
	# We will try to see if it's a contact and has an email. This will break
	# if the contacts package is not installed so this is why we need to put
	# it inside a catch
	if { [catch { set sender [contact::email -party_id $sender_id] } errorMsg] } {
	    set sender ""
	}
    }
    if { [catch { set receiver [person::name -person_id $recipient_id]} errMsg] } {
	# We will try to see if it's a contact and has an email. This will break
	# if the contacts package is not installed so this is why we need to put
	# it inside a catch
	if { [catch { set receiver [contact::email -party_id $recipient_id] } errorMsg] } {
	    set receiver ""
	}
    }
    
    if {[exists_and_not_null package_id]} {
	set package_name [apm_instance_name_from_id $package_id]
	set package_url [apm_package_url_from_id $package_id]
    } else {
	set package_name ""
	set package_url ""
    }

    # We get the related files
    set files [list]
    set file_revisions [application_data_link::get_linked -from_object_id $log_id -to_object_type "content_revision"]
    
    foreach file $file_revisions {
	lappend files [item::get_item_from_revision $file]
    }
    
    foreach file_id [application_data_link::get_linked -from_object_id $log_id -to_object_type "content_item"] {
	lappend files $file_id
    }
    
    set download_files ""
    
    foreach file $files {
	set title [content::item::get_title -item_id $file]
	# Creating the link to dowload the files
	append download_files "<a href=\"[export_vars -base "${tracking_url}download/$title" -url {{file_id $file}}]\">$title</a><br>"
    }

    set object_url "/o/$object_id"
}


 
ad_return_template