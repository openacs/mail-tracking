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
        from acs_mail_log ml left outer join acs_mail_log_recipient_map mlrm on (ml.log_id=mlrm.log_id)
	where 1=1
	$recipient_where_clause 
        [template::list::filter_where_clauses -and -name messages]
        [template::list::orderby_clause -orderby -name messages]
        </querytext>
    </fullquery>

    <fullquery name="files">
        <querytext>
	select o.object_type as content_type, o.object_id as file_id 
	from acs_data_links r, acs_objects o 
	where r.object_id_one = :log_id 
	and r.object_id_two = o.object_id 
	and o.object_type in ([template::util::tcl_to_sql_list $content_types]) 
	order by o.object_type, o.object_id
        </querytext>
    </fullquery>

</queryset>
