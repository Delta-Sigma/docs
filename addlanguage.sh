#!/bin/bash

### WARNING: this is a brittle and poorly tested script that makes
### bulk additions to the repository. Don't run this unless you're
### sure what you're doing and know how to clean up the repo if
### anything goes wrong.

# Usage example: addlanguage.sh ar Arabic

set -u
set -e

lc=$1
language=$2

# check that no collection exists already
f="_${lc}"
if [ -e "$f" ]; then
    echo "$f exists, not clobbering"
    exit 1
fi

# create a language collection
mkdir "$f"
cp _template-overview/template-index.md "$f"

# replace references to "template" with references to the language
# code in the copied materials:
perl -p -i -e 's/template/'"$lc"'/' "_$f"/*.md

tmp=`mktemp addlanguage-tmp-XXX`

# add the newly created collections to config.yml.
(perl -pe 'exit if(/^# Template\s*$/)' _config.yml;
 echo "  ${lc}:
    output: true"
 perl -pe '$past=1 if(/^# Template\s*$/); $_ = "" unless($past);' _config.yml;
) > $tmp; mv $tmp _config.yml

git add _${lc} _config.yml
git commit -m "Added ${language}."

echo "Please edit also codes_and_flags.yaml in the docs-automation repository."
echo "And create at least one repository for a ${language} treebank in the form UD_${language}-TbkID."
echo "Populate its README.md and LICENSE.txt, protect its master branch and make its dev branch writable by the Contributors team."
