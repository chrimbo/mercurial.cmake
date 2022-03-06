########################################################
# Check if mercurial is installed
find_package(Hg)
if(HG_FOUND)
    ####################################################
    # Some default values
    set(HG_VERSION_MAJOR -1)
    set(HG_VERSION_MINOR -1)
    set(HG_VERSION_RELEASE_TYPE VERSION_RELEASE_TYPE_ALPHA)
    set(HG_VERSION_RELEASE_NUMBER -1)

    ####################################################
    # Get the current changeset
    execute_process(
        COMMAND ${HG_EXECUTABLE} id -i
        OUTPUT_VARIABLE HG_NODE
        )
    string(STRIP ${HG_NODE} HG_NODE) # Remove any trailing or leading whitespaces

    ####################################################
    # Check if the working directory is clean
    string(FIND ${HG_NODE} "+" HG_WD_DIRTY)
    if(${HG_WD_DIRTY} LESS 0)
        set(HG_WD_DIRTY OFF)
        
        ################################################
        # Query all information needed...
        execute_process(
            COMMAND ${HG_EXECUTABLE} log -r${HG_NODE} --template="\;{node}\;{tags}\;{author}\;{date|shortdate}\;{date\(date,'%H:%M:%S'\)}\;"
            OUTPUT_VARIABLE HG_QUERY
            )
        ################################################
        # ...and sort them into the right variables
        list(GET HG_QUERY 1 HG_NODE_FULL)
        list(GET HG_QUERY 3 HG_AUTHOR)
        list(GET HG_QUERY 4 HG_DATE)
        list(GET HG_QUERY 5 HG_TIME)
        list(GET HG_QUERY 2 HG_TAGS)

        ################################################
        # Check if a 'version' Tag is found and extract
        # it's information
        string(FIND ${HG_TAGS} "v" HG_VERSION_IN_TAG)
        if(NOT ${HG_VERSION_IN_TAG} LESS 0)
            string(SUBSTRING ${HG_TAGS} ${HG_VERSION_IN_TAG} 7 HG_VERSION_TAG)
            string(SUBSTRING ${HG_VERSION_TAG} 1 1 HG_VERSION_MAJOR)
            string(SUBSTRING ${HG_VERSION_TAG} 3 2 HG_VERSION_MINOR)
            string(SUBSTRING ${HG_VERSION_TAG} 5 1 HG_VERSION_RELEASE_TYPE)
            string(SUBSTRING ${HG_VERSION_TAG} 6 1 HG_VERSION_RELEASE_NUMBER)
            if(${HG_VERSION_RELEASE_TYPE} STREQUAL "a")
                set(HG_VERSION_RELEASE_TYPE "VERSION_RELEASE_TYPE_ALPHA")
            elseif(${HG_VERSION_RELEASE_TYPE} STREQUAL "b")
                set(HG_VERSION_RELEASE_TYPE "VERSION_RELEASE_TYPE_BETA")
            elseif(${HG_VERSION_RELEASE_TYPE} STREQUAL "r")
                set(HG_VERSION_RELEASE_TYPE "VERSION_RELEASE_TYPE_RELEASE")
            endif()
        endif()
    else()
        set(HG_WD_DIRTY ON)
    endif()
    configure_file(version.h.in version.h)
endif()
