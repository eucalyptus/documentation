cd $DITAC_HOME
echo "Building HTML docs:"

[ -z "$PRODUCT_DIR" ] && export PRODUCT_DIR=../../../products
export DOC_VER=3.2

for DOC_NAME in admin-guide euca2ools-guide console-guide faststart-guide install-guide user-guide; do
    echo "Building $DOC_NAME..."
    mkdir $PRODUCT_DIR/en_us/www/$DOC_NAME
    $DITAC_HOME/bin/ditac  -f webhelp  -images img  -p use-note-icon yes  -p xsl-resources-directory css  -toc  -p chain-pages both  -p wh-jquery-ui ../../jquery-ui/js/jquery-ui-1.8.23.custom.min.js  -p wh-jquery-css ../../jquery-ui/css/custom-theme/jquery-ui-1.8.23.custom.css  -p wh-user-header ./whc_template/_wh/euca/header_$DOC_NAME.html  -p wh-user-resources ./whc_template/_wh/euca  -p wh-user-css ./whc_template/_wh/euca/eucadoc.css  -p wh-user-footer ./whc_template/_wh/euca/footer.html  -p wh-collapse-toc yes  -index  $PRODUCT_DIR/en_us/www/$DOC_NAME/_.html $DOC_HOME/en_us/$DOC_NAME.ditamap
done
