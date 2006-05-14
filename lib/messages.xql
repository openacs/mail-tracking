<?xml version="1.0"?>

<queryset>
    <rdbms><type>postgresql</type><version>7.1</version></rdbms>

    <fullquery name="select_messages">
        <querytext>
         select 
		message_id, 
		sender_id, 
		package_id, 
		sent_date, 
		body, 
		subject, 
		object_id, 
		log_id
        from 
		acs_mail_log
	where   [template::list::page_where_clause -name messages]		
        	[template::list::filter_where_clauses -and -name messages]
        	[template::list::orderby_clause -orderby -name messages]
        </querytext>
    </fullquery>

    <fullquery name="messages_pagination">
        <querytext>
         select distinct ml.log_id, sent_date
        from acs_mail_log ml, acs_mail_log_recipient_map mlrm
	where ml.log_id=mlrm.log_id
	$recipient_where_clause 
        [template::list::filter_where_clauses -and -name messages]
        [template::list::orderby_clause -orderby -name messages]
        </querytext>
    </fullquery>

</queryset>
