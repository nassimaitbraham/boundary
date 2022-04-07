create role "{{name}}"
with login password '{{password}}'
valid until '{{expiration}}' inherit;
grant aitech_dba to "{{name}}";
