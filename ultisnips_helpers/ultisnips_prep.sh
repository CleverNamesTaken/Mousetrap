#!/bin/bash

#This should be done more intelligently with ask using a render ultisnips_mousetrap option
SNIPPET_DIR=$(awk '/outputdir/ {print $2}' ~/.config/ask/config.yaml)
SNIPPET_WILDCARD=${SNIPPET_DIR}'/*snippets'

sed -i '1 i\endglobal' ${SNIPPET_WILDCARD}
sed -i '1 i\from mousetrap_helpers import *' $SNIPPET_WILDCARD
sed -i '1 i\global !p' $SNIPPET_WILDCARD

sed -i '/FRIENDLY_NAME/s%}%:`!p snip.rv = target()`}%' $SNIPPET_WILDCARD

sed -i '/TARGET_IP/s%}%::`!p snip.rv = lookup(target(),"IP")`}%' $SNIPPET_WILDCARD 
sed -i '/TARGET_USER/s%}%:`!p snip.rv = lookup(target(),"USER")`}%' $SNIPPET_WILDCARD 
sed -i '/TARGET_CRED/s%}%:`!p snip.rv = lookup(target(),"CRED")`}%' $SNIPPET_WILDCARD 

echo "[+] Tried fixing up $SNIPPET_DIR for better UltiSnips integration"
