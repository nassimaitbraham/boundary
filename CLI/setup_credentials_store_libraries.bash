# Create vault credential store
boundary credential-stores create vault -scope-id "p_1234567890" \
  -vault-address "http://127.0.0.1:8200" \
  -vault-token "hvs.CAESIIvtwx669Z5LUw0wG6NGstDZxCjxKOgKucHlqWZJJtyxGh4KHGh2cy5BM3cyR0V3cEk1QmNsOXlVdzdOeEFIeVY"
export CRED_STORE_ID="csvlt_kPwbkr4Zvw"

# Create credential libraries for DBA

boundary credential-libraries create vault \
    -credential-store-id $CRED_STORE_ID \
    -vault-path "database/creds/dba" \
    -name "aitech dba"

export DBA_CRED_LIB_ID="clvlt_vMpAtVXJFz"

# Create credential libraries for VIEWER
boundary credential-libraries create vault \
    -credential-store-id $CRED_STORE_ID \
    -vault-path "database/creds/viewer" \
    -name "aitech viewer"
export VIEWER_CRED_LIB_ID="clvlt_MWDwTjZBT2"

# Add credential libraries to targets for DBA
boundary targets add-credential-libraries \
  -id=$DBA_TARGET_ID \
  -application-credential-library=$DBA_CRED_LIB_ID

# Add credential libraries to targets for VIEWER
boundary targets add-credential-libraries \
  -id=$VIEWER_TARGET_ID \
  -application-credential-library=$VIEWER_CRED_LIB_ID

# Authorize a session to the analyst target
boundary targets authorize-session -id $VIEWER_TARGET_ID

# Connect to the database with viewer profil
boundary connect postgres -target-id ttcp_lAHumT351N -dbname aitech