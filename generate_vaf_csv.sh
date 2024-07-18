#!/bin/bash

# get first cla
mutation_summary=$1
echo $1
# get directory of $1
flumina_dir=$(dirname $mutation_summary)

vaf_csv=$flumina_dir/vaf.csv

# write column headers to outfile
echo "Accession, Mutation, VAF" > $vaf_csv

while IFS=$'\t' read -r line
do
    # get the 2nd and 4th elements
    gene=$(echo "$line" | awk -F'\t' '{print $2}')
    i=$(echo "$line" | awk -F'\t' '{print $4}')
    # get the mutation by grabbing first character
    mutation=$(echo $i | cut -c 1)
    # if mutation is '*', double escape it
    if [ "$mutation" = "*" ]; then
        mutation="\\*"
    fi
    # get the position by stripping first and last characters
    position=$(echo $i | cut -c 2- | rev | cut -c 2- | rev)
    # get the reference by grabbing last character
    reference=$(echo $i | rev | cut -c 1 | rev)
    # if reference is '*', double escape it
    if [ "$reference" = "*" ]; then
        reference="\\*"
    fi
    # get the alternate
    alternate=$(echo $i | awk -F_ '{print $4}')
    # search for the mutation in the aa_db files and write to vaf.csv
    grep ".*$gene.*,$position,.*$mutation,$reference,YES" $flumina_dir/aa_db/*.csv | awk -v i="$i" -F, '{if ($2 != accession) {if (accession) print accession "," i "," vaf; accession=$2; vaf=$10} else if ($10 > vaf) vaf=$10} END {if (accession) print accession "," i "," vaf}' >> $vaf_csv
done < <(tail -n +2 "$mutation_summary")



# done