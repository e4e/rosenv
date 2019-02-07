# Changelog

- fixed IFS overwrite breaking shell autocompletion

+ Changed default csv file dir to same location as rosenv.sh is sourced from.
+ Prettied prints.
+ Undocumented `alias re='rosenv'` removed. Set manually if needed, after sourcing.  
like so: `source $HOME/rosenv/rosenv.sh && alias re='rosenv'`
+ Setup routine now only completes in full or fails entirely
+ Fixed cvs typo. Rename file to csv
+ Enhanced portability
+ Made getIP work in non-interactive shells
