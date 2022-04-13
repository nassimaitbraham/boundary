#Démarrage de boundary
sudo boundary dev
sudo boundary authenticate password -auth-method-id=ampw_1234567890 -login-name=admin -password=password -keyring-type=none
export BOUNDARY_TOKEN=at_gogzNLZTBW_s1jQHhC5z5snj31e3McKsqFS6hxa5iBW8YCbG2n9MrAN4pXr2oxUuL7WgQuirDE9bYdvTw3uPLihvk1wBxAN96TiEk2rG2JH3VHyA8Zg5yeLEwJrpkUV
# Creation d'une DBA target
boundary targets create tcp \
  -scope-id "p_1234567890" \
  -default-port=16001 \
  -session-connection-limit=-1 \
  -name "aitech DBA Database"

export DBA_TARGET_ID="ttcp_rEHFoRvuO5"

# Creation d'un viewer target
boundary targets create tcp \
  -scope-id "p_1234567890" \
  -default-port=16001 \
  -session-connection-limit=-1 \
  -name "aitech viewer Database"

export VIEWER_TARGET_ID="ttcp_lAHumT351N"
#Déclaration des Host Sets
boundary targets add-host-sets -host-set=hsst_1234567890 -id=$DBA_TARGET_ID
boundary targets add-host-sets -host-set=hsst_1234567890 -id=$VIEWER_TARGET_ID
# Test de connection
boundary connect postgres -target-id $VIEWER_TARGET_ID -username postgres