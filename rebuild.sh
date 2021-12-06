#!/bin/sh

# Rebuilds workspace

WORKSPACE_DIR="Apple.xcworkspace"
REPOS_DIR=Repos

log_error()
{
    MESSAGE=$1
    >&2 echo ${MESSAGE}
}

print_head()
{
    echo "<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
    echo "<Workspace\n   version = \"1.0\">"
}

print_tail()
{
    echo "</Workspace>"
}

print_group_head()
{
    NAME=$1
    echo "   <Group"
    echo "      location = \"container:\""
    echo "      name = \"${NAME}\">"
}

print_group_tail()
{
    echo "   </Group>"
}

append_file_ref() 
{
    FILE_REF=$1
    echo "   <FileRef\n      location = \"group:${FILE_REF}\">"
    echo "   </FileRef>"
}

find_and_append_packages()
{
    PACKAGE_NAME=$1
    # log_error "${REPOS_DIR}/${PACKAGE_NAME}/lib${PACKAGE_NAME}"
    if [ -d "${REPOS_DIR}/${PACKAGE_NAME}/lib${PACKAGE_NAME}" ]; then
        append_file_ref "${REPOS_DIR}/${PACKAGE_NAME}/lib${PACKAGE_NAME}"
    fi
}

find_and_append_project() 
{
    PACKAGE_NAME=$1
    PROJECTS=$(ls ${REPOS_DIR}/${PACKAGE_NAME} | grep -v Tests | grep .xcodeproj)
    for PROJECT in ${PROJECTS}; do
        if [ ! -z "${PROJECT}" ]; then
            append_file_ref "${REPOS_DIR}/${PACKAGE_NAME}/${PROJECT}"
        fi
    done
}

read_package()
{
    PACKAGE_NAME=$1
    if [ -f "${REPOS_DIR}/${PACKAGE_NAME}/Package.swift" ]; then
        append_file_ref "${REPOS_DIR}/${PACKAGE_NAME}"
    elif [ -d "${REPOS_DIR}/${PACKAGE_NAME}/${PACKAGE_NAME}.xcodeproj" ]; then
        append_file_ref "${REPOS_DIR}/${PACKAGE_NAME}/${PACKAGE_NAME}.xcodeproj"
    else
        find_and_append_packages ${PACKAGE_NAME}
        find_and_append_project ${PACKAGE_NAME}
    fi
}

read_swift_packages()
{
    print_group_head "Swift"
    for DIR in `find ${REPOS_DIR} -type d -maxdepth 1 | grep "swift" | sort | uniq`; do
        PACKAGE_NAME=$(basename ${DIR})
        if [ "${REPOS_DIR}" != "${PACKAGE_NAME}" ]; then
            read_package "${PACKAGE_NAME}"
        fi
    done
    print_group_tail
}

read_example_packages()
{
    print_group_head "Examples"
    for DIR in `find ${REPOS_DIR} -type d -maxdepth 1 | grep "example" | sort | uniq`; do
        PACKAGE_NAME=$(basename ${DIR})
        if [ "${REPOS_DIR}" != "${PACKAGE_NAME}" ]; then
            read_package "${PACKAGE_NAME}"
        fi
    done
    print_group_tail
}

read_darwin_packages()
{
    print_group_head "Darwin"
    for DIR in `find ${REPOS_DIR} -type d -maxdepth 1 | grep "darwin" | sort | uniq`; do
        PACKAGE_NAME=$(basename ${DIR})
        if [ "${REPOS_DIR}" != "${PACKAGE_NAME}" ]; then
            read_package "${PACKAGE_NAME}"
        fi
    done
    print_group_tail
}

read_other_packages()
{
    print_group_head "Other"
    for DIR in `find ${REPOS_DIR} -type d -maxdepth 1 | grep -v "swift\|example\|darwin"  | sort | uniq`; do
        PACKAGE_NAME=$(basename ${DIR})
        if [ "${REPOS_DIR}" != "${PACKAGE_NAME}" ]; then
            read_package "${PACKAGE_NAME}"
        fi
    done
    print_group_tail
}

add_scripts_group()
{
    print_group_head "Scripts"
    append_file_ref "refresh.sh"
    append_file_ref "clone.sh"
    append_file_ref "update.sh"
    append_file_ref "rebuild.sh"
    print_group_tail

}

generate_workspace()
{
    print_head
    append_file_ref "README.md"
    append_file_ref "Apple.xcodeproj"
    read_swift_packages
    read_example_packages
    read_darwin_packages
    read_other_packages
    add_scripts_group
    print_tail
}

rebuild_workspace()
{
    mkdir -p "${WORKSPACE_DIR}"
    generate_workspace > "${WORKSPACE_DIR}/contents.xcworkspacedata"
}

rebuild_workspace
