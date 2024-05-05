#!/bin/bash

create_directory() {
    if [ ! -d "$1" ]; then
        mkdir -p "$1"
    fi
}

# Function to convert Markdown to PDF using pandoc with listings setup
convert_to_pdf() {
    input_file="$1"
    output_file="$2"

    temp_dir=$(mktemp -d)

    cat << EOF > "${temp_dir}/listings-setup.tex"
\usepackage{xcolor}
\usepackage{listings}

\lstset{
    basicstyle=\ttfamily,
    numbers=left,
    keywordstyle=\color[rgb]{0.13,0.29,0.53}\bfseries,
    stringstyle=\color[rgb]{0.31,0.60,0.02},
    commentstyle=\color[rgb]{0.56,0.35,0.01}\itshape,
    numberstyle=\footnotesize,
    stepnumber=1,
    numbersep=5pt,
    backgroundcolor=\color[RGB]{248,248,248},
    showspaces=false,
    showstringspaces=false,
    showtabs=false,
    tabsize=2,
    captionpos=b,
    breaklines=true,
    breakatwhitespace=true,
    breakautoindent=true,
    escapeinside={\%*}{*)},
    linewidth=\textwidth,
    basewidth=0.5em,
}

EOF

    pandoc "${input_file}" --listings -H "${temp_dir}/listings-setup.tex" -o "${output_file}"

    rm -rf "${temp_dir}"
}

echo "Creating PDFs for Italian chapters..."
create_directory "pdf/ita"
cd markdown/ita
for file in *.md; do
    convert_to_pdf "$file" "../../pdf/ita/${file%.md}.pdf"
done
cd ../..

echo "Creating PDFs for English chapters..."
create_directory "pdf/eng"
cd markdown/eng
for file in *.md; do
    convert_to_pdf "$file" "../../pdf/eng/${file%.md}.pdf"
done
cd ../..

echo "Combining Italian PDFs into a single PDF..."
create_directory "pdf"
cd pdf/ita
pdftk *.pdf cat output ../../handbook_ita.pdf
cd ../..

echo "Combining English PDFs into a single PDF..."
cd pdf/eng
pdftk *.pdf cat output ../../handbook_eng.pdf
cd ../..

echo "PDF creation completed."

