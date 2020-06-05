set -x

date=$(date '+%F')
input=index.org
intermidiate_org=index-$date.org
intermidiate_html=index-$date.html
output=infoorg-$date.epub

# Вычисляем количество элементов в оглавлении. Если этого не делать,
# calibre начинает добавлять в него мусор из внутренних ссылок.
#
toc_size=$(grep --count '^*' index.org)

[ -f $intermidiate_org ] && rm $intermidiate_org

#echo '#+OPTIONS: toc:nil' > $intermidiate_org

cat $input >> $intermidiate_org

# Убираем SETUPFILE. Для генерации EPUB нужен чистый HTML, без
# дополнительного CSS, который делает тема read-the-org.
#
sed -i '/^#+SETUPFILE/d' $intermidiate_org

# Добавляем фальшивый заголовок и вставляем туда все картинки, чтобы
# они попали в epub. Calibre их почему-то без этого удаляет из
# манифеста EPUB. Поскольку количество элементов оглавления уже
# посчитано, в оглавление он не войдет.
#
echo "* Images" >> $intermidiate_org
for image in $(find images -type f) ; do
    echo "  [[./$image]]"  >> $intermidiate_org
done

emacs -l ~/.emacs.d/init.el --visit  $intermidiate_org --batch -f org-html-export-to-html


#rm $intermidiate_org

ebook-convert $intermidiate_html $output --max-toc-links $toc_size --extra-css css/epub.css

#rm $intermidiate_html

ls -la $output
