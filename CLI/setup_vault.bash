export VAULT_ADDR="http://127.0.0.1:8200"
export VAULT_TOKEN="groot"
# Exécuter Vault en mode développeur
vault server -dev -dev-root-token-id=${VAULT_TOKEN}

# Créer les policy de contrôleur de boundary
# Nouvelle fênetre shell
export VAULT_ADDR="http://127.0.0.1:8200"; export VAULT_TOKEN="groot"
vault policy write boundary-controller boundary-controller-policy.hcl

# Configurer le moteur de secrets de base de données

# Activez le moteur de secrets de base de données.
vault secrets enable database

#Configurez Vault avec le plug-in postgres-database
vault write database/config/aitech \
      plugin_name=postgresql-database-plugin \
      connection_url="postgresql://{{username}}:{{password}}@localhost:16001/postgres?sslmode=disable" \
      allowed_roles=dba,viewer \
      username="vault" \
      password="vault-password"

# Créer le rôle DBA qui créé les informations d’identification avec :dba.sql.hcl

vault write database/roles/dba \
      db_name=aitech \
      creation_statements=@dba.sql.hcl \
      default_ttl=3m \
      max_ttl=60m
# Demandez les informations d’identification DBA de Vault pour confirmer
vault read database/creds/dba

# Créez le rôle viewer qui crée les informations d’identification avec :viewer.sql.hcl
vault write database/roles/viewer \
      db_name=aitech \
      creation_statements=@viewer.sql.hcl \
      default_ttl=3m \
      max_ttl=60m

# Demandez les informations d’identification de l’analyste à Vault pour confirmer.
vault read database/creds/viewer

# creation de aitech-database policy
vault policy write aitech-database aitech-database-policy.hcl

# Création d'un token Vault pour Boundary
vault token create \
  -no-default-policy=true \
  -policy="boundary-controller" \
  -policy="aitech-database" \
  -orphan=true \
  -period=20m \
  -renewable=true

# exemple tocken : hvs.CAESIHFbEP7V62Pn1m5CkAzXy2_RwgWQLHqbzzQTKweaQNAHGh4KHGh2cy4wSnhWS3FXZzdRSk1NTklhdExoZEx5MXQ