<?xml version="1.0"?>

<queryset>
    <rdbms><type>postgresql</type><version>7.1</version></rdbms>

    <fullquery name="select_messages">
        <querytext>
         select 
		message_id, 
		sender_id, 
		recipient_id, 
		package_id, 
		sent_date, 
		body, 
		subject, 
		object_id, 
		log_id
        from 
		acs_mail_log
	where 
		message_id <> 0
		$recipient_where_clause
		[template::list::page_where_clause -and -name messages]		
        	[template::list::filter_where_clauses -and -name messages]
        	[template::list::orderby_clause -orderby -name messages]
        </querytext>
    </fullquery>

    <fullquery name="messages_pagination">
        <querytext>
         select log_id
        from acs_mail_log	
	where message_id <> 0	
	$recipient_where_clause 
        [template::list::filter_where_clauses -and -name messages]
        [template::list::orderby_clause -orderby -name messages]
        </querytext>
    </fullquery>

</queryset>
