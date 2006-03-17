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
    {-recipient_id:required}
    {-body ""}
    {-message_id:required}
    {-subject ""}
    {-object_id ""}
    {-context_id ""}
    {-cc ""}
} {
    Insert new log entry
    @param cc CC E-Mail Address as recieved from the send procedures
} {
    set creation_ip "127.0.0.1"
    return [db_exec_plsql insert_log_entry {select acs_mail_log__new (
								     :log_id,
								     :message_id,
								     :recipient_id,
								     :sender_id,
								     :package_id,
								     :subject,
								     :body,
								     :sender_id,
								     :creation_ip,
								     :context_id,
								     :object_id,
								     :cc
								     )}]
    
}	       
