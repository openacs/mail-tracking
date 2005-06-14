<?xml version="1.0"?>

<queryset>
    <rdbms><type>postgresql</type><version>7.1</version></rdbms>

    <fullquery name="select_messages">
        <querytext>
         select message_id, sender_id, recipient_id, package_id, sent_date, body, subject 
        from acs_mail_log
	where message_id <> 0
	$recipient_id_clause
	$sender_id_clause
	$package_id_clause
	$orderby
        </querytext>
    </fullquery>

</queryset>
