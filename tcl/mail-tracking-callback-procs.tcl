# packages/mail-tracking/tcl/mail-tracking-callback-procs.tcl

ad_library {
    
    Callback procs for mail tracking
    
    @author Malte Sussdorff (sussdorff@sussdorff.de)
    @creation-date 2005-06-15
    @arch-tag: 9d6f99f7-cfec-40e6-8d3f-411f4d3c9b6c
    @cvs-id $Id$
}

ad_proc -public -callback acs_mail_lite::complex_send -impl mail_tracking {
    {-package_id:required}
    {-from_party_id:required}
    {-to_party_id:required}
    {-body ""}
    {-message_id:required}
    {-subject ""}
    {-object_id ""}
    {-file_ids ""}
} {
    create a new entry in the mail tracking table
} {

    set log_id [mail_tracking::new -package_id $package_id \
		    -sender_id $from_party_id \
		    -recipient_id $to_party_id \
		    -body $body \
		    -message_id $message_id \
		    -subject $subject \
		    -object_id $object_id]

    foreach file_id $file_ids {
	application_data_link::new -this_object_id $log_id -target_object_id $file_id
    }
}

ad_proc -public -callback acs_mail_lite::send -impl mail_tracking {
    {-package_id:required}
    {-from_party_id:required}
    {-to_party_id:required}
    {-body:required}
    {-message_id:required}
    {-subject:required}
} {
    create a new entry in the mail tracking table
} {

    set log_id [mail_tracking::new -package_id $package_id \
		    -sender_id $from_party_id \
		    -recipient_id $to_party_id \
		    -body $body \
		    -message_id $message_id \
		    -subject $subject]

}
