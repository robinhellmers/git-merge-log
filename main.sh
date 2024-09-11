#!/usr/bin/env bash

sourceable_script='false'

if [[ "$sourceable_script" != 'true' && ! "${BASH_SOURCE[0]}" -ef "$0" ]]
then
    echo "Do not source this script! Execute it with bash instead."
    return 1
fi
unset sourceable_script

########################
### Library sourcing ###
########################

library_sourcing()
{
    # Unset as only called once and most likely overwritten when sourcing libs
    unset -f library_sourcing

    local -r THIS_SCRIPT_PATH="$(tmp_find_script_path)"

    # Store $THIS_SCRIPT_PATH as unique or local variables
    # LIB_PATH is needed by sourced libraries as well
    readonly PROJECT_BASE_PATH="$THIS_SCRIPT_PATH"
    export PROJECT_BASE_PATH
    readonly LIB_PATH="$THIS_SCRIPT_PATH/lib"
    export LIB_PATH

    ### Source libraries ###
    source "$LIB_PATH/lib_core.bash" || exit 1
    # source_lib "$LIB_PATH/lib.bash"
}

# Minimal version of find_path(). Should only be used within this script to source library defining find_path().
tmp_find_script_path() {
    unset -f tmp_find_script_path; local s="${BASH_SOURCE[0]}"; local d
    while [[ -L "$s" ]]; do d=$(cd -P "$(dirname "$s")" &>/dev/null && pwd); s=$(readlink "$s"); [[ $s != /* ]] && s=$d/$s; done
    echo "$(cd -P "$(dirname "$s")" &>/dev/null && pwd)"
}

library_sourcing

########################
### GLOBAL CONSTANTS ###
########################

# readonly <var>

############
### MAIN ###
############

############
### MAIN ###
############

main()
{
    _handle_args_main "$@"

    current_branch="$(git rev-parse --abbrev-ref HEAD)"

    commit_message=$(git log --pretty=format:'%h %s' "HEAD..$feature_branch")

    define commit_message <<-END_OF_COMMIT_MESSAGE
	Merge '$feature_branch' into '$current_branch'
	
	Merge list:
	${commit_message}
	END_OF_COMMIT_MESSAGE

    git merge --no-ff -m "$commit_message" "${arguments[@]}"
}

###################
### END OF MAIN ###
###################

register_function_flags 'git-merge-log' \
    '-m' '' 'true' 'Is ignored. Merge message overridden by git-merge-log.'

register_help_text 'git-merge-log' <<-END_OF_HELP_TEXT
git merge-log

Creates a better log message for a 'git merge'. Also by default ensures
that no fast-forward (--no-ff) is used.

Arguments:
    See 'git merge'. Will throw away potential '-m' flag.
END_OF_HELP_TEXT

_handle_args_main()
{
    _handle_args 'git-merge-log' --allow-non-registered-flags "$@"

    # Will not include the -m flag
    arguments=("${non_flagged_args[@]}")

    ###
    # Non-flagged arguments
#     if (( ${#non_flagged_args[@]} != 0 ))
#     then
#         # Optional argument 1
#         main_input_dir=${non_flagged_args[0]}
#         if ! [[ -d "$main_input_dir" ]]
#         then
#             define error_info << END_OF_ERROR_INFO
# Given [ DIR ] is not a directory: '$main_input_dir'
# END_OF_ERROR_INFO
#             invalid_function_usage 2 'script name' "$error_info"
#             exit 1
#         fi
#     fi
    ###

    ###
    # -m
    if [[ "$m_flag" == 'true' ]]
    then
        echo "-m option is ignored as git merge-log overrides the message"
    fi
    ###

}

main_stderr_red()
{
    main "$@" 2> >(sed $'s|.*|\e[31m&\e[m|' >&2)
}

#################
### Call main ###
#################
main_stderr_red "$@"
#################
