#!/usr/bin/env bash

# Tool for generating documentation files: man, help, README.md
# Usage: makedoc.sh [man|help|readme] 

_warn() {
	echo >&2 ":: $*"
}

_die() {
	echo >&2 ":: $*"
	exit 1
}

get_meta() {
	# extract item $1 from $meta_file and transform it for man, help or readme (depending on $doc_type).
	word='([a-zA-Z0-9_\+-])'
	case "$doc_type" in
		man)
			sedcmd='
		# bold and italic
		s/\@\*\*\{ /\\fB/g
		s/\@\*\*\} /\\fR/g
		s/\@\*\{ /\\fI/g
		s/\@\*\} /\\fR/g
		s/\*\*'"$word"'/\\fB\1/g
		s/'"$word"'\*\*/\1\\fR/g
		s/\*'"$word"'/\\fI\1/g
		s/'"$word"'\*/\1\\fR/g

		# escape and unescape
		s/-/\\-/g
		s/\\\[/[/g
		s/\\\]/]/g
		s/`//g

		# custom macros
		s/\@u (.)/\L\1/g
		s/\@t /\n/g
		s/^\@p /.TP\n/
		s/^\@s /.SS /

		# bullet points
		/^\* /{
			x
			/^\s*$/{
				x
				i .IP \\[bu] 3
				h;b end
			}
			x
			i .IP \\[bu]
			h;b end
		}

		# code block
		/^    /{
			x
			/^\s*$/{
				x
				i .P
				i .RS 6
				h;b end
			}
			x
			h;b end
		}

		# end of block
		/^\s*$/{
			x
			/^    /{
				x
				i .RE
				b end
			}
			x
			i .P
			h;b end
		}
		
		:end
		s/^\**\s*//
		'
			;;
		help)
			sedcmd='
		# bold and italic
		s/\@\*\*\{ //g
		s/\@\*\*\} //g
		s/\@\*\{ //g
		s/\@\*\} //g
		s/\*\*'"$word"'/\1/g
		s/\*\*'"$word"'/\1/g
		s/'"$word"'\*\*/\1/g
		s/\*'"$word"'/\1/g
		s/'"$word"'\*/\1/g

		# escape and unescape
		s/\\\[/[/g
		s/\\\]/]/g

		# custom macros
		s/\@u (.)/\U\1/g
		s/\@t /\t/g
		s/^\@p /	/
		s/^\@s //
		
		# other
		s/^\s*$//
		'
			;;
		readme)
			sedcmd='
		# add two trailing spaces to get linebreaks
		s/(\S)\s*$/\1  /

		# bold and italic
		s/\@\*\*\{ /**/g
		s/\@\*\*\} /**/g
		s/\@\*\{ /*/g
		s/\@\*\} /*/g

		# custom macros
		s/\@u (.)/\U\1/g
		s/\@t /\&nbsp;\&nbsp;/g
		s/^\@p //
		s/^\@s /##### /'
			;;
		*) _die "wrong option";;
	esac
	sed -E -e '
		# lines from item $1 to next item
		'"/^$1/,/^\S/!d"'

		# delete item line
		//d

		# delete initial tab
		s/^\t//
		'"$sedcmd"'

		# escape & and \& to avoid interpretation as backreference by gawk
		s/\\\&/\\\\\&/g
		s/\&/\\\&/g
		' "$meta_file" | \
		`# remove trailing lines with spaces only` \
		sed -e ':a;/^[ \n]*$/{$d;N;};/\n *$/ba' | \
		`# remove trailing spaces in last line` \
		sed -e '$s/  $//' | \
		`# remove trailing newline` \
		head -c -1
}

main() {
	doc_type="$1"
	name="${PWD##*/}"
	meta_file="prep/$name.meta"

	declare -A item_var=(\
		[name]="$name" \
		[meta_date]="$(date -r "$meta_file" '+%d %b %Y')")

	declare -A tmpl_file=(\
		[man]="prep/$name.1" \
		[help]="prep/$name" \
		[readme]="prep/README.md")
		# content of $tmpl_file goes to $output (cf. makedoc.items.sh)
	
	[[ ! $doc_type =~ (man|help|readme) ]] && _die "wrong doc_type"

	source prep/makedoc.items.sh

	for item in "${repl_items[@]}"; do
		if [ -n "${item_var[$item]}" ]; then
			# replace <$item> by ${item_var[$item]} 
			output="$(sed -e 's/<'"$item"'>/'"${item_var[$item]}"'/g' <(echo "$output"))"
		else
			# replace <$item> by section $item in $meta_file; cf. https://stackoverflow.com/questions/27361981/sed-replace-pattern-with-file-contents
			tmp="$(gawk 'FNR==NR{s=(!s)?$0:s RS $0;next} /<'"$item"'>/{sub(/<'"$item"'>/, s)} 1' <(get_meta "$item") <(echo "$output"))"
			if [ -n "$tmp" ]; then
				output="$tmp"
			fi
		fi
	done
	echo "$output"
}

main "$1"
