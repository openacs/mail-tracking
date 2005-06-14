--  ================================================================================
-- Postgres SQL Script File
-- 
-- 
-- @Location: mail-tracking\sql\postgresql\acs_mail_log-create.sql
-- 
-- @author: Nima Mazloumi
-- @creation-date: Mon May 30 17:55:50 CEST 2005
-- @cvs-id $Id$
--  ================================================================================
-- 
-- 

--  ======================================================
-- Tracking Table acs_object_log 			--
--  ======================================================

create table acs_mail_log (
	message_id		integer
				constraint acs_mail_log_message_id_pk
				primary key,
	owner_id		integer
				constraint acs_mail_log_owner_id_fk
				references users(user_id),
	recipient_id		integer
				constraint acs_mail_log_recipient_id_fk
				references parties(party_id),
	sender_id		integer
				constraint acs_mail_log_sender_id_fk
				references parties(party_id),
	package_id		integer,
	subject			varchar(1024),
	body			text,
	sent_date		timestamp);



create function acs_mail_log__new (integer, integer, integer, integer, varchar, varchar)
returns integer as '
declare
	p_message_id		alias for $1;
	p_recipient_id		alias for $2;
	p_sender_id		alias for $3;
	p_package_id		alias for $4;
	p_subject		alias for $5;
	p_body			alias for $6;
begin

	insert into acs_mail_log
		(message_id, recipient_id, sender_id, package_id, subject, body, sent_date)
	values
		(p_message_id, p_recipient_id, p_sender_id, p_package_id, p_subject, p_body, now());

	return 0;

end;' language 'plpgsql';


create function acs_mail_log__delete (integer)
returns integer as'
declare
	p_message_id		alias for $1;
begin

		delete from acs_mail_log where message_id = p_message_id;

		raise NOTICE ''Deleting Acs Mail Log Entry...'';

		PERFORM acs_object_delete(p_message_id);

		return 0;

end;' language 'plpgsql';


--  ======================================================
-- Tracking requests table acs_mail_tracking_request	--
--  ======================================================

create table acs_mail_tracking_request (
    request_id                      integer
                                    constraint acs_mail_request_id_pk
                                    primary key,
    user_id                         integer
                                    constraint acs_mail_request_user_id_fk
                                    references users (user_id),
                                    -- on delete cascade,
    -- The package instance this request pertains to
    object_id                       integer
                                    constraint acs_mail_request_object_id_fk
                                    references acs_objects (object_id)
                                    -- on delete cascade
);


create or replace function acs_mail_tracking_request__new (integer,integer,integer)
returns integer as '

DECLARE
        p_request_id			alias for $1;      
        p_object_id			alias for $2;
        p_user_id			alias for $3;
	v_request_id			integer;

BEGIN

	select t_acs_object_id_seq.NEXTVAL into v_request_id;
	
      insert into acs_mail_tracking_request
      	(request_id, object_id, user_id)
      values
      	(p_request_id, p_object_id, p_user_id);

      return v_request_id;

END;
' language 'plpgsql';


create or replace function acs_mail_tracking_request__delete(integer)
returns integer as '
declare
    p_request_id                    alias for $1;
begin
    delete from acs_mail_tracking_request where request_id = p_request_id;
    return 0;
end;
' language 'plpgsql';


create or replace function acs_mail_tracking_request__delete_all(integer)
returns integer as '
declare
    v_request                       RECORD;

begin
    for v_request in select request_id from acs_mail_tracking_request
    loop
        perform acs_mail_tracking_request__delete(v_request.request_id);
    end loop;

    return 0;
end;
' language 'plpgsql';


--  ======================================================
-- Tracking Trigger acs_mail_log_tr			--
--  ======================================================

CREATE OR REPLACE FUNCTION public.acs_mail_log_tr()
  RETURNS trigger AS
'
declare
     v_recepient_id         	integer;  
     v_sender_id       		integer default 0;
     v_track_all_p		bool default 0;
     v_object_id		integer;
     begin

	if old.package_id is null then 
             raise notice \'Tracking: No way to track. Package Id was %. You need to check why.\', old.package_id;
             return old;
        end if;
        
        v_recepient_id := substring (old.to_addr from \'user_id ([0-9]+)\');
	select into v_sender_id party_id from parties where email = old.from_addr;

    if v_recepient_id is null then
         raise notice \'Tracking: Unable to extract user_id from: %. Not able to log this message.\', old.to_addr;
	 return old;
    end if;
    
    if v_sender_id is null then
         raise notice \'Tracking: Unknown sender %. Not able to log this message.\', old.from_addr;
	 return old;
    end if;
    
    -- if TrackAllMails parameter is set to 0 we only track mails from packages that have requests

    select 	into v_track_all_p pv.attr_value 
		from apm_parameter_values pv, apm_parameters p 
    where p.parameter_id = pv.parameter_id
		and p.parameter_name = \'TrackAllMails\'
    and p.package_key = \'mail-tracking\'
    limit 1;
    
    if v_track_all_p = \'1\' then 
    
    perform acs_mail_log__new (
        	old.message_id, 
        	v_recepient_id, 
        	v_sender_id, 
        	old.package_id, 
        	old.subject, 
        	old.body
        );
        
    else
    	select into v_object_id object_id from acs_mail_tracking_request where object_id = old.package_id;
    	
    	if v_object_id is not null then

		raise notice \'Tracking: Logged mail for package_id %.\', v_object_id;

    		perform acs_mail_log__new (
		        old.message_id, 
		        v_recepient_id, 
		        v_sender_id, 
		        old.package_id, 
		        old.subject, 
		        old.body
        	);
        else
		raise notice \'Tracking: No request for package id % and tracking all mails is turned off.\', old.package_id;
	end if;
    
    end if;

     return old;
    end;
'
  LANGUAGE 'plpgsql';


create trigger acs_mail_log_tr after delete on acs_mail_lite_queue
for each row execute procedure acs_mail_log_tr();