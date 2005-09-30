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
    {emp_mail_f:optional 1}
    sender_id:optional
    package_id:optional
    {orderby:optional "recipient_id"}
} -properties {
    acs_mail_log:multirow 
    context:onevalue
}

set page_title [ad_conn instance_name]
set context [list "index"]


set filters [list \
		 sender_id {
		     label "[_ mail-tracking.Sender]"
		     where_clause "sender_id = :sender_id"
		 } \
		 package_id {
		     label "[_ mail-tracking.Package]"
		     where_clause "package_id = :package_id"	
		 }]

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
    -multirow messages \
    -key acs_mail_log_id \
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
	package_id {
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
	}
	file_ids {
	    label "[_ mail-tracking.Files]"
	}
	body {
	    label "[_ mail-tracking.Body]"
	    display_col body;noquote
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
	package_id {
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
    } -filters $filters

set orderby [template::list::orderby_clause -name "messages" -orderby]

db_multirow -extend { file_ids sender receiver package_name package_url } messages select_messages {} {

    set sender [person::name -person_id $sender_id]
    set receiver [person::name -person_id $recipient_id]

    if {[exists_and_not_null $package_id]} {
	set package_name [apm_instance_name_from_id $package_id]
	set package_url [apm_package_url_from_id $package_id]
    } else {
	set package_name ""
	set package_url ""
    }
    set file_ids [application_data_link::get_linked -from_object_id $log_id -to_object_type "file_storage_object"]
    foreach file_id [application_data_link::get_linked -from_object_id $log_id -to_object_type "image"] {
	lappend file_ids $file_id
    }
}
 
ad_return_template