set -x

date=$(date '+%F')
input=index.org
intermidiate_org=index-$date.org
intermidiate_html=index-$date.html
output=infoorg-$date.epub
toc_size=$(grep --count '^*' index.org)


sed '/^#+SETUPFILE/d' index.org > $intermidiate_org

echo "* Images"                      >> $intermidiate_org
echo "  [[./images/wikipedia.png]]"  >> $intermidiate_org

emacs -l ~/.emacs.d/init.el --visit  $intermidiate_org --batch -f org-html-export-to-html

rm $intermidiate_org

ebook-convert $intermidiate_html $output --max-toc-links $toc_size --extra-css css/epub.css

rm $intermidiate_html

ls -la $output
