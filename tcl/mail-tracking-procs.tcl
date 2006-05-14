ad_library {

    Mail-Tracking

    Core procs for tracking mails. Important concepts:
    <ul>
    <li> tracking: each message sent out by acs-mail-lite is tracked - if it was queued.
    <li> intervals: as soon as the email was sent and removed from the queue.
    <li> participation: Either through registering a package instance or by setting the verbose parameter: TrackAllTraffic
    </ul>

    @creation-date 2005-05-31
    @author Nima Mazloumi <mazloumi@uni-mannheim.de>
    @cvs-id $Id$

}

namespace eval mail_tracking {}

ad_proc -public mail_tracking::package_key {} {
    The package key
} {
    return "mail-tracking"
}

ad_proc -public mail_tracking::new {
    {-log_id ""}
    {-package_id:required}
    {-sender_id:required}
    {-recipient_ids:required}
    {-cc_ids ""}
    {-bcc_ids ""}
    {-to_addr ""}
    {-cc_addr ""}
    {-bcc_addr ""}
    {-body ""}
    {-message_id:required}
    {-subject ""}
    {-object_id ""}
    {-context_id ""}
} {
    Insert new log entry

    @param sender_id party_id of the sender
    @param recipient_ids List of party_ids of recipients
    @param cc_ids List of party_ids for recipients in the "CC" field
    @param bcc_ids List of party_ids for recipients in the "BCC" field
    @param to_addr List of email addresses seperated by "," who recieved the email in the "to" field but got no party_id
    @param cc_addr List of email addresses seperated by "," who recieved the email in the "cc" field but got no party_id
    @param bcc_addr List of email addresses seperated by "," who recieved the email in the "bcc" field but got no party_id
    @param body Text of the message
    @param message_id Message_id of the email
    @param subject Subject of the email
    @param object_id Object for which this message was sent
    @param context_id Context in which this message was send.
} {
    set creation_ip "127.0.0.1"

    # First create the message entry 
    set log_id [db_exec_plsql insert_log_entry {select acs_mail_log__new (
								     :log_id,
								     :message_id,
								     :sender_id,
								     :package_id,
								     :subject,
								     :body,
								     :sender_id,
								     :creation_ip,
								     :context_id,
								     :object_id,
								     :cc_addr,
								     :bcc_addr,
								     :to_addr
								     )}]

    # Now add the recipients to the log_id
    
    foreach recipient_id $recipient_ids {
	db_dml insert_recipient {insert into acs_mail_log_recipient_map (recipient_id,log_id,type) values (:recipient_id,:log_id,'to')}
    } 

    foreach recipient_id $cc_ids {
	db_dml insert_recipient {insert into acs_mail_log_recipient_map (recipient_id,log_id,type) values (:recipient_id,:log_id,'cc')}
    } 

    foreach recipient_id $bcc_ids {
	db_dml insert_recipient {insert into acs_mail_log_recipient_map (recipient_id,log_id,type) values (:recipient_id,:log_id,'bcc')}
    } 

    return $log_id
}	       
