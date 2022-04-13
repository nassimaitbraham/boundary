begin;
  
  --Revoke all privilege for the public on schema public
  revoke all on schema public from public;
   
  -- aitech_viewer role
  create role aitech_viewer noinherit;
  grant usage on schema public to aitech_viewer;
  grant select on all tables in schema public to aitech_viewer;

  -- aitech_dba role
  create role aitech_dba noinherit;
  grant all privileges on database aitech to aitech_dba;

  -- Vault
  create role vault with superuser login createrole password 'vault-password';
commit;

