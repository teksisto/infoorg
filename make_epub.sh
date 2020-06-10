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

ruby -e "
     content = IO.readlines('$intermidiate_org')
     content.reject! do |line|
         line =~ /^\#\+SETUPFILE/
     end
     File.write('$intermidiate_org', content.join)
"

# Заменяем непечатный заголовок без номера в самом начале на слово
# "Эпиграф".
#
ruby -e "
     content = IO.readlines('$intermidiate_org')
     content.map! do |line|
         line.sub('* \nbsp{}', '* Эпиграф')
     end
     File.write('$intermidiate_org', content.join)
"

# Добавляем фальшивый заголовок и вставляем туда все картинки, чтобы
# они попали в epub. Calibre их почему-то без этого удаляет из
# манифеста EPUB. Поскольку количество элементов оглавления уже
# посчитано, в оглавление он не войдет.
#
echo "* Images" >> $intermidiate_org
for image in $(find images -type f) ; do
    echo "  [[./$image]]"  >> $intermidiate_org
done


# Конвертация промежуточного org-файла в html. Название у файла будет
# такое же, но с расширением html.
#
emacs -l ~/.emacs.d/init.el --visit  $intermidiate_org --batch -f org-html-export-to-html


#rm $intermidiate_org

# Конвертация промежуточного html в epub c помощью утилиты из набора
# Calibre.
#
ebook-convert $intermidiate_html $output --max-toc-links $toc_size --extra-css css/epub.css

#rm $intermidiate_html

ls -la $output
