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
    {-body:required}
    {-message_id:required}
    {-subject:required}
} {
    create a new entry in the mail tracking table
} {

    db_dml insert_log_entry {insert into acs_mail_log
	(message_id, recipient_id, sender_id, package_id, subject, body, sent_date)
	values
	(:message_id, :to_party_id, :from_party_id, :package_id, :subject, :body, now())
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

    db_dml insert_log_entry {insert into acs_mail_log
	(message_id, recipient_id, sender_id, package_id, subject, body, sent_date)
	values
	(:message_id, :to_party_id, :from_party_id, :package_id, :subject, :body, now())
    }

}
