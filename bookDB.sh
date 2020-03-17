#!/usr/bin/env bash

BOOKS_DIR="/Volumes/Media Center/Shared Books/To Dropbox"

CSV_header () {
	echo "CATEGORY,TITLE,AUTHORS,PUBLISHER,YEAR,COVER,ISBN,AMAZON,GOOGLE" > "${BOOKS_DIR}/books.csv"
}

CSV_row () {
	local category=$1; shift
	local title=$1; shift
	local authors=$1; shift
	local publisher=$1; shift
	local year=$1; shift
	local cover=$1; shift
	local isbn=$1; shift
	local amazon=$1; shift
	local google=$1; shift
	echo "\"${category}\",\"${title}\",\"${authors}\",\"${publisher}\",\"${year}\",${cover},\"${isbn}\",\"${amazon}\",\"${google}\"" >> "${BOOKS_DIR}/books.csv"
}

CSV_footer () {
	:
}

HTML_header () {
	cat <<EOF1 > "${BOOKS_DIR}/books.html"
<html>
  <head>
    <title>My Books Database</title>
  </head>
  <body>
    <table>
	  <tr>
	  <td>CATEGORY</td>
	  <td>TITLE</td>
	  <td>AUTHORS</td>
	  <td>PUBLISHER</td>
	  <td>YEAR</td>
	  <td>COVER</td>
	  <td>ISBN</td>
	  <td>AMAZON</td>
	  <td>GOOGLE</td>
	  </tr>
EOF1
}

HTML_row () {
	echo "<tr>" >> "${BOOKS_DIR}/books.html"; 
	echo "<td>$1</td>" >> "${BOOKS_DIR}/books.html"; shift
	echo "<td>$1</td>" >> "${BOOKS_DIR}/books.html"; shift
	echo "<td>$1</td>" >> "${BOOKS_DIR}/books.html"; shift
	echo "<td>$1</td>" >> "${BOOKS_DIR}/books.html"; shift
	echo "<td>$1</td>" >> "${BOOKS_DIR}/books.html"; shift
	echo "<td>$1</td>" >> "${BOOKS_DIR}/books.html"; shift
	echo "<td>$1</td>" >> "${BOOKS_DIR}/books.html"; shift
	echo "<td>$1</td>" >> "${BOOKS_DIR}/books.html"; shift
	echo "<td>$1</td>" >> "${BOOKS_DIR}/books.html"; shift
	echo "</tr>" >> "${BOOKS_DIR}/books.html"; 
}

HTML_footer () {
	cat <<EOF2 >> "${BOOKS_DIR}/books.html"
    </table>
  </body>
</html>
EOF2
}

cd "${BOOKS_DIR}"
CSV_header;
HTML_header;
for book in */*.pdf
do
	category=`echo ${book} | sed 's/\(.*\)\/.* - .* - .* - .*/\1/'`;
	title=`echo ${book} | sed 's/.*\/\(.*\) - .* - .* - .*/\1/' | sed 's/_ /: /'`;
	authors=`echo ${book} | sed 's/.*\/.* - \(.*\) - .* - .*/\1/'`;
	publisher=`echo ${book} | sed 's/.*\/.* - .* - \(.*\) - .*/\1/'`;
	year=`echo ${book} | sed 's/.*\/.* - .* - .* - \(.*\)\.pdf/\1/'`;
	cover="NO"; [[ -e "${book/pdf/jpg}" ]] && cover="YES";
	allisbn=`mdls "${book}" | grep kMDItemFinderComment | cut -d'=' -f2 | tr -d \"`;
	if [[ ${allisbn} =~ ^.*isbn:.*$ ]]
		then
		isbn_tmp=${allisbn##*isbn:}
		isbn=${isbn_tmp%%,*}
	else
		isbn=
	fi
	if [[ ${allisbn} =~ ^.*amazon:.*$ ]]
		then
		amazon_tmp=${allisbn##*amazon:}
		amazon_id=${amazon_tmp%%,*}
		[[ -n ${amazon_id} ]] && amazon="http://www.amazon.com/gp/product/${amazon_id}";
	else
		amazon=
	fi
	if [[ ${allisbn} =~ ^.*google:.*$ ]]
		then
		google_tmp=${allisbn##*google:}
		google_id=${google_tmp%%,*}
		[[ -n ${google_id} ]] && google="http://books.google.com.mx/books?id=${google_id}";
	else
		google=
	fi
	
	CSV_row "${category}" "${title}" "${authors}" "${publisher}" "${year}" ${cover} "${isbn}" "${amazon}" "${google}"
	HTML_row "${category}" "${title}" "${authors}" "${publisher}" "${year}" ${cover} "${isbn}" "${amazon}" "${google}"
done
CSV_footer
HTML_footer